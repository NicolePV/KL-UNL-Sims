# Decompiled Flash source (`fla/`)

This folder holds the original Adobe Flash simulation as decompiled with
JPEXS / FFDec — the ground-truth source the accessible HTML5 port (in the
repository root) was built from. It is included for reference and is **not**
part of the running web app.

Contents:

| Path | What it is |
| --- | --- |
| `pulsarPeriodSim001.swf` | the original compiled Flash movie |
| `Capture.PNG` | screenshot of the running original (layout reference) |
| `scripts/` | decompiled ActionScript (behavior ground truth) — `pulsarPeriodSim001_fla/MainTimeline.as`, `Pulsar.as`, `IntervalsPlot.as`, plus the Flash UI-component framework |
| `shapes/` | exported vector shapes (SVG) |
| `sprites/` | exported sprite bitmaps (PNG) |
| `fonts/` | embedded fonts (Verdana) |
| `frames/` | exported stage frame render |
| `texts/` | static text strings from the movie |
| `symbolClass/` | `symbols.csv` — linkage name ↔ symbol id map |
| `foundation/` | the KL-UNL foundation files as originally supplied |

See `../CONVERSION_NOTES.md` for how these map onto the HTML5 port.
