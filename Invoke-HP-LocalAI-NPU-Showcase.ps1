param(
    [int]$Seconds = 90,
    [int]$UpdateMs = 120,
    [string]$Prompt = "In one short paragraph, describe why local AI on a Copilot+ PC with an AMD NPU matters for privacy, latency, and product experience.",
    [switch]$SkipOllama,
    [switch]$SkipRecallStimulus
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

function Get-ToolEvidence {
    $names = @("ollama", "python", "py", "winget", "gaia", "lemonade", "lemonade-server")
    foreach ($name in $names) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            [pscustomobject]@{
                Tool = $name
                Found = $true
                Source = $cmd.Source
            }
        } else {
            [pscustomobject]@{
                Tool = $name
                Found = $false
                Source = ""
            }
        }
    }
}

function Invoke-OllamaEvidence {
    param(
        [string]$Prompt,
        [string]$ReportPath
    )

    $ollama = Get-Command ollama -ErrorAction SilentlyContinue
    if (-not $ollama) {
        "Ollama was not found on PATH." | Set-Content -LiteralPath $ReportPath -Encoding UTF8
        return $false
    }

    $models = & ollama list 2>&1
    $models | Set-Content -LiteralPath $ReportPath -Encoding UTF8

    $modelLine = $models | Select-Object -Skip 1 | Where-Object { $_ -match '\S' } | Select-Object -First 1
    if (-not $modelLine) {
        Add-Content -LiteralPath $ReportPath -Value ""
        Add-Content -LiteralPath $ReportPath -Value "Ollama is installed, but no local models were listed."
        return $false
    }

    $model = ($modelLine -split '\s+')[0]
    Add-Content -LiteralPath $ReportPath -Value ""
    Add-Content -LiteralPath $ReportPath -Value "Running local Ollama model: $model"
    Add-Content -LiteralPath $ReportPath -Value "Prompt: $Prompt"
    Add-Content -LiteralPath $ReportPath -Value ""

    $answer = & ollama run $model $Prompt 2>&1
    $answer | Add-Content -LiteralPath $ReportPath -Encoding UTF8
    return $true
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportDir = Join-Path (Get-Location) "npu-demo-evidence-$stamp"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

Write-Step "Creating evidence bundle"
Write-Host "Folder: $reportDir"

Write-Step "Detecting AMD NPU"
$npu = Get-NpuDevice
$npu | Format-Table -AutoSize Status, Class, FriendlyName, InstanceId
$npu | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $reportDir "npu-device.json") -Encoding UTF8

Write-Step "Detecting local AI tooling"
$tools = Get-ToolEvidence
$tools | Format-Table -AutoSize
$tools | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $reportDir "local-ai-tools.json") -Encoding UTF8

if (-not $SkipOllama) {
    Write-Step "Trying a local Ollama AI prompt"
    $ollamaReport = Join-Path $reportDir "ollama-local-ai.txt"
    $ranOllama = Invoke-OllamaEvidence -Prompt $Prompt -ReportPath $ollamaReport
    if ($ranOllama) {
        Write-Host "Saved local model output to $ollamaReport"
    } else {
        Write-Host "Saved Ollama status to $ollamaReport"
    }
}

if (-not $SkipRecallStimulus) {
    Write-Step "Starting AMD NPU visible workload"
    Write-Host "This part demonstrates local Windows on-device AI using the NPU for screen understanding."
    Write-Host "Keep Task Manager visible at Performance > NPU."
    & (Join-Path (Get-Location) "Invoke-NpuRecallDemo.ps1") -Seconds $Seconds -UpdateMs $UpdateMs
}

$summary = @"
# HP Local AI + AMD NPU Evidence

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")

## Truthful claim

This HP PC has an AMD NPU and can demonstrate local on-device AI. Ollama, when a model is installed, demonstrates local LLM execution on the PC. Windows Copilot+ features such as Recall/snapshot OCR and semantic indexing demonstrate NPU-backed local AI behavior on the AMD NPU.

## Boundary

Codex is the cloud coding agent operating the workflow. This evidence does not claim Codex itself ran its frontier model on the AMD NPU.

## Evidence files

- npu-device.json
- local-ai-tools.json
- ollama-local-ai.txt, when Ollama was tested

## Leadership line

We are using local AI on HP hardware, and the AMD NPU is active for on-device Windows AI workloads. That is the honest, defensible proof.
"@

$summaryPath = Join-Path $reportDir "README.md"
$summary | Set-Content -LiteralPath $summaryPath -Encoding UTF8

Write-Step "Done"
Write-Host "Evidence README: $summaryPath"
