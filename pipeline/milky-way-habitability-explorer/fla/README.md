# `fla/` — original Flash sim and decompiled source

This folder holds the **legacy Adobe Flash** version of the Milky Way Habitability
Explorer and its decompiled source. It is the historical/reference material that the
accessible HTML5 rebuild (in the repository root) was converted from. Nothing here is
needed to run the HTML5 sim.

## Contents

| Path | What it is |
|------|------------|
| `milkyWayHabitability001.fla` | The original Flash authoring file. |
| `milkyWayHabitability001.swf` | The original compiled Flash movie. |
| `scripts/` | Decompiled ActionScript (AS1), exported with JPEXS/FFDec. The **ground truth for behavior** — constants, drag logic, and the `setRadius` fan-out. |
| `shapes/` | Exported vector shapes (SVG). The two graph curves were reused from `57.svg` (extinction risk) and `51.svg` (heavy elements). |
| `images/` | Exported bitmaps. `33.jpg` is the NASA/JPL-Caltech Milky Way image reused by the HTML5 build. |
| `sprites/`, `frames/`, `texts/`, `symbolClass/` | Other JPEXS export output: sprite/frame breakdowns, on-screen text strings, and the symbol-linkage table. |
| `fonts/` | Font files extracted from the SWF (see note below). |
| `morphshapes/`, `movies/` | Empty in this export; kept for completeness. |
| `foundation/` | Reference copy of the shared KL-UNL foundation files. |
| `Capture.PNG` | Screenshot of the running Flash original, used as the layout reference for the conversion. |

## How this maps to the HTML5 rebuild

The conversion is documented in the repository root:

* [`../CONVERSION_NOTES.md`](../CONVERSION_NOTES.md) — behavior model, the full
  ActionScript → HTML5 mapping, which assets were reused as-is vs. code-drawn, and
  every deviation from the original.
* [`../ACCESSIBILITY.md`](../ACCESSIBILITY.md) — the WCAG 2.1 AA affordances added.

## Notes

* **Flash is end-of-life.** The `.swf` will not run in any modern browser; it is kept
  for archival reference only. Use the HTML5 version at the repository root.
* **Fonts.** `fonts/` contains Verdana faces extracted from the original SWF. Verdana
  is a proprietary Microsoft typeface and is *not* covered by this project's license —
  it is present only as raw decompiler output. The HTML5 build does not use these
  files (it relies on system font stacks instead).
