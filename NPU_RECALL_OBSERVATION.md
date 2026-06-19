# NPU Activity During Hewy Sessions: Revised Investigation Note

## Current conclusion

The current scripts in this repo failed to load the NPU.

Earlier screen recordings appeared to show NPU activity during a Hewy/Codex working session, but the scripts here have not reproduced that result. Treat the earlier observation as unconfirmed until a repeatable control test proves the driver.

## What is confirmed

- The machine has an AMD NPU device in previous hardware evidence files.
- Codex and Claude Code do not run their cloud models on the local NPU.
- Ollama is not proven to use the AMD NPU in this repo.
- The screen-stress scripts are not direct NPU workloads.

## What is not confirmed

- Recall/snapshots loading the NPU during these scripts.
- Hewy causing NPU activity.
- Any LLM inference running on the AMD NPU.
- Any repeatable NPU workload from this repo.

## Correct interpretation

If Task Manager > Performance > NPU stays flat while the scripts run, the honest result is:

The scripts did not trigger NPU work on this system.

## Required proof before making an NPU claim

Use a workload that explicitly targets the NPU, then capture one of:

- Task Manager > Performance > NPU showing load during that workload.
- Runtime logs showing AMD XDNA/Ryzen AI/NPU execution.
- ONNX Runtime, Windows AI, or AMD tooling output that identifies the NPU provider/device.

Until then, the defensible claim is only that the machine has NPU hardware, not that the current Hewy/Codex/Ollama/scripts workload uses it.
