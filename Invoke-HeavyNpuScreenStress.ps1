param(
    [int]$Seconds = 180,
    [int]$Windows = 4,
    [int]$UpdateMs = 80,
    [switch]$NoTaskManager
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

function New-StressPage {
    param(
        [string]$Path,
        [int]$Index,
        [int]$UpdateMs
    )

    $html = @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Heavy Local AI Screen Stress __INDEX__</title>
  <style>
    body {
      margin: 0;
      font-family: "Segoe UI", Arial, sans-serif;
      background: #fff;
      color: #111;
      overflow: hidden;
    }
    header {
      height: 64px;
      display: flex;
      align-items: center;
      padding: 0 18px;
      border-bottom: 2px solid #111;
      font-size: 26px;
      font-weight: 700;
    }
    main {
      display: grid;
      grid-template-columns: 1fr 1fr;
      grid-template-rows: 1fr 1fr;
      gap: 10px;
      height: calc(100vh - 86px);
      padding: 10px;
    }
    section {
      border: 2px solid #111;
      overflow: hidden;
      padding: 10px;
    }
    #ocr {
      font-family: Consolas, "Courier New", monospace;
      font-size: 14px;
      line-height: 1.2;
      white-space: pre-wrap;
    }
    #large {
      font-size: 44px;
      line-height: 1.08;
      font-weight: 800;
    }
    #grid {
      display: grid;
      grid-template-columns: repeat(12, 1fr);
      gap: 5px;
    }
    .cell {
      aspect-ratio: 1;
      display: grid;
      place-items: center;
      border: 1px solid #222;
      font-size: 13px;
      font-weight: 700;
    }
    canvas {
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
  <header id="title">Hewy local AI screen stress __INDEX__</header>
  <main>
    <section><div id="large"></div></section>
    <section><div id="ocr"></div></section>
    <section><div id="grid"></div></section>
    <section><canvas id="canvas" width="1000" height="700"></canvas></section>
  </main>
  <script>
    const updateMs = __UPDATE_MS__;
    const words = [
      "Hewy", "WisdomGraph", "quality", "evidence", "agent", "screen",
      "OCR", "semantic", "index", "snapshot", "NPU", "AMD", "XDNA2",
      "local", "private", "context", "recall", "copilot", "task", "trace"
    ];
    const large = document.getElementById("large");
    const ocr = document.getElementById("ocr");
    const grid = document.getElementById("grid");
    const title = document.getElementById("title");
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext("2d");

    for (let i = 0; i < 144; i++) {
      const cell = document.createElement("div");
      cell.className = "cell";
      grid.appendChild(cell);
    }

    function word(n) {
      return words[Math.abs(n) % words.length];
    }

    function render() {
      const t = Math.floor(performance.now() / updateMs);
      title.textContent = "Hewy local AI screen stress __INDEX__ - frame " + t;
      large.textContent = `${word(t)} ${word(t + 5)} ${word(t + 11)}\n${word(t + 17)} ${word(t + 23)} ${Date.now()}`;

      const lines = [];
      for (let i = 0; i < 58; i++) {
        lines.push(`${String(t).padStart(8, "0")} row=${String(i).padStart(3, "0")} ${word(t+i)} ${word(t+i*3)} ${word(t+i*7)} id=${(t*7919+i*1543)%999983}`);
      }
      ocr.textContent = lines.join("\n");

      [...grid.children].forEach((cell, i) => {
        cell.textContent = `${word(t + i).slice(0, 2).toUpperCase()}${(t + i) % 99}`;
        cell.style.background = `hsl(${(t * 13 + i * 29) % 360} 88% 78%)`;
      });

      ctx.fillStyle = "#fff";
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      for (let i = 0; i < 120; i++) {
        const x = (i * 67 + t * 31) % canvas.width;
        const y = (i * 43 + t * 17) % canvas.height;
        ctx.fillStyle = `hsl(${(t * 7 + i * 23) % 360} 80% 52%)`;
        ctx.fillRect(x, y, 120, 50);
        ctx.fillStyle = "#111";
        ctx.font = "18px Segoe UI";
        ctx.fillText(`${word(t + i)}-${(t + i * 13) % 1000}`, x + 8, y + 31);
      }
    }

    setInterval(render, updateMs);
    render();
  </script>
</body>
</html>
'@

    $html = $html.Replace('__INDEX__', [string]$Index).Replace('__UPDATE_MS__', [string]$UpdateMs)

    Set-Content -LiteralPath $Path -Value $html -Encoding UTF8
}

Write-Step "NPU device"
Get-NpuDevice | Format-Table -AutoSize Status, Class, FriendlyName, InstanceId

Write-Step "Best settings for load"
Write-Host "Enable Recall/snapshots and keep Task Manager on Performance > NPU."
Write-Host "This is a screen-understanding stress test, not proof that an LLM backend is on the NPU."

if (-not $NoTaskManager) {
    Start-Process taskmgr.exe | Out-Null
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$root = Join-Path $env:TEMP "heavy-npu-screen-stress-$stamp"
New-Item -ItemType Directory -Force -Path $root | Out-Null

Write-Step "Opening $Windows stress windows"
for ($i = 1; $i -le $Windows; $i++) {
    $page = Join-Path $root "stress-$i.html"
    New-StressPage -Path $page -Index $i -UpdateMs $UpdateMs
    Start-Process $page | Out-Null
    Start-Sleep -Milliseconds 300
}

Write-Step "Churning local text files for $Seconds seconds"
$stopAt = (Get-Date).AddSeconds($Seconds)
$frame = 0
while ((Get-Date) -lt $stopAt) {
    $path = Join-Path $root ("hewy-context-{0:D3}.txt" -f ($frame % 20))
    $lines = for ($i = 0; $i -lt 80; $i++) {
        "frame=$frame row=$i Hewy WisdomGraph local AI AMD NPU OCR semantic index value=$((($frame + 1) * ($i + 17) * 7919) % 999983)"
    }
    Set-Content -LiteralPath $path -Value $lines -Encoding UTF8
    Write-Host ("{0} frame={1:D6} updating local Hewy context files and stress windows" -f (Get-Date -Format "HH:mm:ss.fff"), $frame)
    Start-Sleep -Milliseconds $UpdateMs
    $frame++
}

Write-Step "Done"
Write-Host "Stress folder: $root"
Write-Host "If NPU only spikes briefly, try real Windows NPU apps: Studio Effects, Recall search, Click to Do, or AMD Amuse with XDNA2 offload."
