# `fla/` — original Flash source (decompiled)

This folder is the **input** to the conversion: the original Adobe Flash
Circumstellar Habitable Zone Simulator as decompiled with JPEXS / FFDec, kept
here for reference and provenance. Nothing in this folder is used at runtime by
the published simulator — the live site is built from the files in the repository
root (`index.html`, `simulation.js`, `styles/`, `assets/`, `foundation/`).

| Path | What it is |
|---|---|
| `stellarHabitableZone.swf` | the original compiled Flash movie |
| `scripts/` | decompiled ActionScript — the ground truth for all behaviour (`stellarHabitableZone004_fla/MainTimeline.as`, the `SHZ*` classes, `ProtoSlider*`) |
| `shzStars.dat` | stellar-evolution tracks (zlib + AMF3); decoded to `assets/shzStars.json` |
| `sprites/`, `shapes/`, `images/`, `frames/` | exported art. The planet state frames, the H-R density map and the zone arrow are reused as-is in `assets/` |
| `fonts/` | the embedded Verdana subsets used by the original |
| `texts/` | on-screen / Help / About strings |
| `symbolClass/symbols.csv` | linkage name ↔ symbol id map |
| `foundation/` | the KL-UNL foundation copy that shipped with this sim folder |
| `Capture.PNG` | screenshot of the running Flash original, used as the layout reference |
| `morphshapes/`, `movies/` | empty in this export (kept for completeness) |

See `../CONVERSION_NOTES.md` for how each piece maps onto the HTML5 rebuild.
