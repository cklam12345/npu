# HP Leader NPU Demo

## Current status

No working demo in this repo has successfully loaded the NPU on this machine.

The scripts create screen, browser, terminal, and local text activity. They did not cause Task Manager > Performance > NPU to show load in the current test.

## Truthful claim to make

This HP system has an AMD NPU device, but this repo has not proven that Hewy, Codex, Ollama, or the included scripts execute work on that NPU.

## Claims to avoid

Do not say:

- Hewy is running on the NPU.
- Codex or Claude Code is running on the NPU.
- Ollama is running on the NPU.
- The included scripts demonstrate NPU acceleration.
- Windows Recall is definitely loading the NPU during this demo.

## What the scripts actually do

`Invoke-NpuRecallDemo.ps1` and `Invoke-HeavyNpuScreenStress.ps1` generate changing screen content. That can be useful as a stimulus test, but it is not an NPU workload.

If the NPU graph stays flat, the correct conclusion is: the stimulus failed to load the NPU.

## Honest next step

For a real demo, use a workload that explicitly targets the AMD NPU/XDNA/Ryzen AI runtime, then capture either:

- Task Manager > Performance > NPU showing load during the run, or
- runtime logs/traces proving NPU execution.
