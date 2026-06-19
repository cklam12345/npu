# HP Leader NPU Demo

## Claim to make

This HP system is using local on-device AI on the AMD NPU during a real Hewy work session.

## Claim to avoid

Do not say Hewy, Codex, Claude Code, or Ollama is running its model inference on the NPU unless a separate backend proves that directly. The verified NPU activity here is Windows Copilot+ on-device AI, especially Recall/snapshot OCR and semantic indexing, processing the local Hewy work context.

## Demo steps

1. Open Task Manager and switch to Performance > NPU.
2. Open Settings > Privacy & security > Recall & snapshots.
3. Confirm Recall/snapshots are enabled.
4. Run:

```powershell
.\Invoke-NpuRecallDemo.ps1
```

5. Watch the NPU graph while the browser and terminal content changes rapidly.
6. Pause Recall/snapshots and run the script again as a control test.

## Talk track

This is local AI running on the device during a Hewy workflow. Hewy is the work surface; the NPU is processing the local screen context for on-device understanding, OCR, and semantic indexing. Codex is useful as the operator that builds and runs the demo, but the honest technical proof is that Windows on-device AI lights up the AMD NPU while Hewy is active.

## Short command for a faster demo

```powershell
.\Invoke-NpuRecallDemo.ps1 -Seconds 45
```
