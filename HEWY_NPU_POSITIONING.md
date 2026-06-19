# Hewy + AMD NPU Positioning

## Current status

The current scripts did not load the NPU.

Hewy can still be positioned as a meaningful local AI work surface, but this repo does not prove that Hewy itself, Codex, Ollama, or the included stress scripts use the AMD NPU.

## Strongest truthful claim

This HP machine has AMD NPU hardware. Hewy creates rich local work context. We still need a direct NPU-backed runtime or Windows feature trace before claiming that the NPU is actively processing Hewy work.

## What not to overclaim

Do not say Hewy runs inference on the NPU unless Hewy is actually calling a Windows AI, Ryzen AI, ONNX Runtime, AMD XDNA, or other NPU backend and the run is verified.

Do not say Ollama, Codex, or Claude Code used the AMD NPU unless a backend trace proves it.

Do not say the screen-stress scripts are NPU demos. They are failed stimulus tests unless the NPU graph rises.

## Safe wording

Hewy is a local AI workflow that could benefit from NPU-backed on-device intelligence. On this machine, the included scripts did not prove NPU usage. The next proof point must come from a direct NPU runtime, supported Windows NPU feature, or traceable AMD Ryzen AI/XDNA workload.
