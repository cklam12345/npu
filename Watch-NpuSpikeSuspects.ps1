param(
    [int]$Seconds = 90,
    [int]$IntervalMs = 500,
    [int]$Top = 20,
    [switch]$OpenTaskManager
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message" -ForegroundColor Cyan
}

function Get-NpuDevice {
    Get-PnpDevice -PresentOnly |
        Where-Object {
            $_.FriendlyName -match '\bNPU\b|Neural|AI.*Accelerator|Compute Accelerator' -or
            $_.InstanceId -match 'NPU|XDNA|DEV_17F0'
        } |
        Sort-Object -Property Class, FriendlyName
}

function Get-ProcessSnapshot {
    $targets = 'codex|node|python|pwsh|powershell|WindowsTerminal|OpenConsole|conhost|ollama|msedge|Copilot|Recall|SearchHost|StartMenuExperienceHost|TextInputHost|ShellExperienceHost|RuntimeBroker|ApplicationFrameHost|Widgets|PhoneExperienceHost'

    Get-CimInstance Win32_PerfFormattedData_PerfProc_Process |
        Where-Object {
            $_.Name -ne '_Total' -and
            $_.Name -ne 'Idle' -and
            (
                $_.Name -match $targets -or
                $_.PercentProcessorTime -gt 1
            )
        } |
        Select-Object Name, IDProcess, PercentProcessorTime, WorkingSetPrivate |
        Sort-Object PercentProcessorTime -Descending |
        Select-Object -First $Top
}

function Get-GpuProcessSnapshot {
    $gpu = @()
    try {
        $gpu = Get-Counter '\GPU Process Memory(*)\Dedicated Usage','\GPU Process Memory(*)\Shared Usage' -ErrorAction Stop
    } catch {
        return @()
    }

    $gpu.CounterSamples |
        Where-Object { $_.CookedValue -gt 0 } |
        ForEach-Object {
            [pscustomobject]@{
                Path = $_.Path
                Bytes = [int64]$_.CookedValue
            }
        } |
        Sort-Object Bytes -Descending |
        Select-Object -First $Top
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outDir = Join-Path (Get-Location) "npu-spike-watch-$stamp"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$processCsv = Join-Path $outDir "process-samples.csv"
$gpuCsv = Join-Path $outDir "gpu-process-memory-samples.csv"
$notes = Join-Path $outDir "README.md"

Write-Step "NPU device"
Get-NpuDevice | Format-Table -AutoSize Status, Class, FriendlyName, InstanceId

Write-Step "Important limitation"
Write-Host "Most stable Windows builds expose NPU usage as an aggregate graph, not reliable per-process PowerShell counters."
Write-Host "This watcher correlates spikes with likely processes while you type in Codex CLI."

if ($OpenTaskManager) {
    Start-Process taskmgr.exe | Out-Null
    Write-Host "Switch Task Manager to Performance > NPU."
}

@"
# NPU Spike Watch

Started: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")

## How to use

1. Keep Task Manager open to Performance > NPU.
2. Start this script.
3. Type normally in Codex CLI until you see a large NPU spike.
4. Press Ctrl+C after the spike or wait for the script to finish.

## What this can prove

This can correlate NPU spikes with active processes, terminal rendering, browser activity, Copilot, Search, Recall-adjacent components, and GPU memory users.

## What this cannot always prove

On many Windows builds, per-process NPU attribution is not exposed through public PowerShell counters. A spike may be caused by a Windows service or driver path that only appears as aggregate NPU usage in Task Manager.
"@ | Set-Content -LiteralPath $notes -Encoding UTF8

Write-Step "Watching for $Seconds seconds"
Write-Host "Output folder: $outDir"
Write-Host "Now type in Codex CLI and watch Task Manager > Performance > NPU."

$stopAt = (Get-Date).AddSeconds($Seconds)
while ((Get-Date) -lt $stopAt) {
    $now = Get-Date -Format o

    Get-ProcessSnapshot | ForEach-Object {
        [pscustomobject]@{
            Time = $now
            Name = $_.Name
            PID = $_.IDProcess
            CPUPercent = $_.PercentProcessorTime
            PrivateWorkingSetBytes = $_.WorkingSetPrivate
        }
    } | Export-Csv -LiteralPath $processCsv -Append -NoTypeInformation

    Get-GpuProcessSnapshot | ForEach-Object {
        [pscustomobject]@{
            Time = $now
            Path = $_.Path
            Bytes = $_.Bytes
        }
    } | Export-Csv -LiteralPath $gpuCsv -Append -NoTypeInformation

    Start-Sleep -Milliseconds $IntervalMs
}

Write-Step "Top correlated process names"
if (Test-Path $processCsv) {
    Import-Csv -LiteralPath $processCsv |
        Group-Object Name |
        ForEach-Object {
            $maxCpu = ($_.Group | Measure-Object CPUPercent -Maximum).Maximum
            $count = $_.Count
            [pscustomobject]@{
                Name = $_.Name
                Samples = $count
                MaxCPU = [double]$maxCpu
            }
        } |
        Sort-Object MaxCPU -Descending |
        Select-Object -First $Top |
        Format-Table -AutoSize
}

Write-Step "Done"
Write-Host "Process samples: $processCsv"
Write-Host "GPU memory samples: $gpuCsv"
Write-Host "Notes: $notes"
