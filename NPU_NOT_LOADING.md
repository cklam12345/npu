# NPU Not Loading: Honest Diagnosis

## What is true

The scripts in this repo failed to load the NPU on this machine.

They create screen, terminal, and browser activity. They do not directly run an NPU kernel.

Because Task Manager > Performance > NPU stayed flat, the honest conclusion is that the workload did not trigger NPU-backed processing on this system.

## Why this happens

- Recall/snapshots may be off, paused, unavailable, or not processing the current app/window.
- Windows may batch screen indexing instead of processing continuously.
- Ollama, Codex, Claude Code, and normal browser rendering do not automatically use the AMD NPU.
- PowerShell exposes GPU counters on this machine, but not reliable public NPU counters. Task Manager is usually the visible aggregate NPU check.

## Best direct tests

1. Open Task Manager > Performance > NPU.
2. Run a known NPU-backed Windows feature, such as Studio Effects with the camera active.
3. Try Recall search or Click to Do if those features are available and enabled.
4. For model inference proof, use a runtime or sample that explicitly targets AMD XDNA/Ryzen AI/NPU, then keep its logs or runtime trace.

## What to say

Use: "This PC has an AMD NPU, but the scripts in this repo did not load it. NPU use is proven only when the NPU graph or runtime trace shows activity."

Avoid: "Hewy/Codex/Ollama is running on the NPU" unless the backend explicitly proves NPU execution.
