# NPU Activity During Claude Code / Hewy Sessions — Investigation Note

**Machine:** Omen Dream (hpcoo)
**Date investigated:** 2026-06-18
**Evidence:** `C:\Users\hpcoo\Videos\using_AMD_NPU_Totally.mp4` (recorded 2026-06-17 during the wisdomGraph QA session); still frame `npuusage.png`.

---

## TL;DR

The AMD NPU shows **real, sustained activity** during a Claude Code / Hewy working session. It is **not** driven by Claude Code or the local LLMs — it's **Windows Copilot+ on-device AI (Recall)** processing the rapidly-changing screen on the NPU. The glow is real; the cause is a Windows feature, not the AI you're typing to.

> Do **not** present this as "Claude Code runs on our NPU." That's false and a technical teammate will catch it. The honest framing is "*Windows on-device AI (Recall) uses our NPU.*"

---

## Hardware

| Component | Detail |
|---|---|
| CPU / NPU | **AMD Ryzen AI 9 HX 375** — XDNA2 NPU, ~50 TOPS (Copilot+ class) |
| Discrete GPU | **NVIDIA GeForce RTX 5080 Laptop** |
| Integrated GPU | **AMD Radeon 890M** |
| OS | Windows 11 Home, build 26200 (Copilot+ capable) |
| NPU device | "NPU Compute Accelerator Device" — driver `32.0.203.329`, status OK |

---

## What the recording shows

- **Sustained** high NPU utilization (large plateaus), not brief spikes — across most of the 2:22 recording.
- On screen: Microsoft Edge (Hewy Smart Qual UI) + a terminal running the **actual Claude Code wisdomGraph session** (the `wisdomgraph_issue_0.3.1` draft, `gh auth login`, etc.).
- **No camera / no video-call window** anywhere in frame.
- NPU plateaus track screen activity: high while the terminal/UI changes rapidly, dropping when the screen settles.

---

## What is (and isn't) driving the NPU

| Candidate | Uses the NPU? | Verdict |
|---|---|---|
| **Claude Code** | No — cloud API, network only | Bystander in the frame, not the cause |
| **Ollama (Fara-7B / Qwen2.5)** | No — runs on the RTX 5080 GPU / CPU; no XDNA backend | Not the cause |
| **Windows Studio Effects** (camera) | Yes, but only when camera is live | Ruled out — camera was off |
| **Windows Recall / Copilot+ on-device AI** | **Yes** — continuous screen snapshots → on-device OCR + semantic embedding on the NPU | **Most likely driver** |

**Conclusion:** the sustained-NPU-tracks-screen-activity signature, with camera off and a busy Edge + terminal, is the fingerprint of **Recall** (or equivalent Copilot+ screen-content AI) running on-device. As the screen changed rapidly during the session, Recall worked harder and the NPU plateaued; when activity settled, it dropped.

**The poetic version:** while we built a memory in the Neo4j wisdom graph, Windows was quietly building its *own* memory of the same session on the NPU. Two recordings of one afternoon.

---

## How to confirm / demo honestly

1. Open **Task Manager → Performance → NPU** (keep it visible). *(Note: Windows shows NPU only in aggregate — there is no per-process NPU column.)*
2. **Settings → Privacy & security → Recall & snapshots** — check whether Recall is **On**.
3. **Pause Recall**, repeat a busy terminal/Edge session → the NPU plateaus should disappear.
4. **Re-enable Recall**, repeat → the glow returns.

Whichever toggle reliably moves the graph **is** the driver. Demo it as *"our NPU runs Windows on-device AI in real time,"* not as Claude Code.

---

*Investigated by reading frames extracted from the recording (ffmpeg) and querying live hardware/process state. The NPU was healthy and idle at rest; it lit up only under active screen workload.*
