param(
    [int]$Seconds = 120,
    [int]$UpdateMs = 120,
    [switch]$NoTaskManager,
    [switch]$ConsoleOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message" -ForegroundColor Cyan
}

function Get-NpuDevice {
    $devices = Get-PnpDevice -PresentOnly |
        Where-Object {
            $_.FriendlyName -match '\bNPU\b|Neural|AI.*Accelerator|Compute Accelerator' -or
            $_.InstanceId -match 'NPU|XDNA|DEV_17F0'
        } |
        Sort-Object -Property Class, FriendlyName

    return $devices
}

function New-RecallStimulusHtml {
    param([string]$Path)

    $html = @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Local AI NPU Demo</title>
  <style>
    :root {
      color-scheme: light;
      font-family: "Segoe UI", Arial, sans-serif;
      background: #f7f7f2;
      color: #171717;
    }
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      grid-template-rows: auto 1fr;
    }
    header {
      padding: 18px 24px;
      border-bottom: 2px solid #111;
      background: #ffffff;
    }
    h1 {
      margin: 0;
      font-size: 28px;
      letter-spacing: 0;
    }
    main {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 18px;
      padding: 20px;
    }
    section {
      border: 2px solid #111;
      background: #fff;
      padding: 16px;
      min-height: 320px;
      overflow: hidden;
    }
    .big {
      font-size: 34px;
      font-weight: 700;
      line-height: 1.2;
    }
    .dense {
      font-family: Consolas, "Courier New", monospace;
      font-size: 15px;
      line-height: 1.35;
      white-space: pre-wrap;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(8, minmax(0, 1fr));
      gap: 8px;
    }
    .tile {
      border: 1px solid #222;
      aspect-ratio: 1;
      display: grid;
      place-items: center;
      font-weight: 700;
      font-size: 18px;
    }
  </style>
</head>
<body>
  <header>
    <h1>Local on-device AI workload: OCR, indexing, and semantic snapshot stimulus</h1>
  </header>
  <main>
    <section>
      <div id="headline" class="big"></div>
    </section>
    <section>
      <div id="dense" class="dense"></div>
    </section>
    <section>
      <div id="grid" class="grid"></div>
    </section>
    <section>
      <canvas id="canvas" width="900" height="520"></canvas>
    </section>
  </main>
  <script>
    const words = [
      "invoice", "embedding", "receipt", "calendar", "meeting", "project",
      "recall", "snapshot", "semantic", "search", "terminal", "browser",
      "analysis", "local", "private", "index", "npu", "accelerator"
    ];
    const headline = document.getElementById("headline");
    const dense = document.getElementById("dense");
    const grid = document.getElementById("grid");
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext("2d");

    for (let i = 0; i < 64; i++) {
      const tile = document.createElement("div");
      tile.className = "tile";
      grid.appendChild(tile);
    }

    function pick(i) {
      return words[Math.abs(i) % words.length];
    }

    function tick() {
      const now = new Date();
      const t = Math.floor(performance.now() / 120);

      headline.textContent =
        `Frame ${t}: ${pick(t)} ${pick(t + 3)} ${pick(t + 9)} - ${now.toLocaleTimeString()}`;

      let lines = [];
      for (let i = 0; i < 32; i++) {
        lines.push(
          `${String(t + i).padStart(6, "0")} ` +
          `${pick(t + i)} ${pick(t + i * 3)} ${pick(t + i * 7)} ` +
          `case-${(t * 17 + i * 31) % 9973} total=${(t * i + 12345) % 100000}`
        );
      }
      dense.textContent = lines.join("\n");

      [...grid.children].forEach((tile, i) => {
        tile.textContent = `${pick(t + i)[0].toUpperCase()}${(t + i) % 100}`;
        tile.style.background = `hsl(${(t * 9 + i * 17) % 360} 82% 82%)`;
      });

      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      for (let i = 0; i < 72; i++) {
        ctx.fillStyle = `hsl(${(t * 5 + i * 19) % 360} 80% 45%)`;
        ctx.fillRect((i * 47 + t * 13) % canvas.width, (i * 29 + t * 7) % canvas.height, 90, 42);
        ctx.fillStyle = "#111111";
        ctx.font = "18px Segoe UI";
        ctx.fillText(`${pick(t + i)} ${(t + i) % 1000}`, (i * 47 + t * 13) % canvas.width + 8, (i * 29 + t * 7) % canvas.height + 27);
      }

      requestAnimationFrame(tick);
    }

    tick();
  </script>
</body>
</html>
'@

    Set-Content -LiteralPath $Path -Value $html -Encoding UTF8
}

Write-Step "Checking for an NPU device"
$npuDevices = Get-NpuDevice
if ($npuDevices.Count -eq 0) {
    Write-Warning "No obvious NPU device was found through Get-PnpDevice."
} else {
    $npuDevices | Format-Table -AutoSize Status, Class, FriendlyName, InstanceId
}

Write-Step "Before you run the workload"
Write-Host "1. Open Settings > Privacy & security > Recall & snapshots."
Write-Host "2. Confirm Recall/snapshots are enabled for the strongest NPU signal."
Write-Host "3. Watch Task Manager > Performance > NPU."
Write-Host ""
Write-Host "Truthful demo claim: this script creates screen and console stimulus that may be processed by Windows on-device AI."
Write-Host "It does not directly invoke the NPU, and it does not prove Codex, Hewy, Ollama, or an LLM is executing inference on the NPU."
Write-Host "You only have NPU proof if Task Manager > Performance > NPU rises while Recall/snapshots or another NPU-backed feature is active."

if (-not $NoTaskManager) {
    Write-Step "Opening Task Manager"
    Start-Process taskmgr.exe | Out-Null
    Write-Host "If needed, switch Task Manager to Performance > NPU."
}

$tempDir = Join-Path $env:TEMP "npu-recall-demo"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
$htmlPath = Join-Path $tempDir "recall-stimulus.html"

if (-not $ConsoleOnly) {
    Write-Step "Opening browser stimulus"
    New-RecallStimulusHtml -Path $htmlPath
    Start-Process $htmlPath | Out-Null
    Write-Host "Opened $htmlPath"
}

Write-Step "Running console stimulus for $Seconds seconds"
$stopAt = (Get-Date).AddSeconds($Seconds)
$frame = 0
$phrases = @(
    "local ai recall snapshot semantic index invoice meeting",
    "terminal browser document ocr embedding private search",
    "npu accelerator windows copilot plus screen processing",
    "rapid content changes should create sustained indexing work"
)

while ((Get-Date) -lt $stopAt) {
    $phrase = $phrases[$frame % $phrases.Count]
    $stamp = Get-Date -Format "HH:mm:ss.fff"
    Write-Host ("{0} frame={1:D6} {2} value={3}" -f $stamp, $frame, $phrase, (($frame * 7919) % 104729))
    Start-Sleep -Milliseconds $UpdateMs
    $frame++
}

Write-Step "Done"
Write-Host "Expected only if Recall/snapshots or another NPU-backed Windows feature is active: Task Manager's NPU graph rises during the workload and falls after it stops."
Write-Host "If the NPU graph stays flat, the honest conclusion is that this stimulus did not trigger NPU work on this system."
Write-Host "Control test: pause Recall/snapshots and run this again. If nothing changes, Recall was not the driver."
