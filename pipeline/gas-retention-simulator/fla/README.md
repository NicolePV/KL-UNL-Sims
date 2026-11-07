# fla/ — original decompiled Flash source

This folder is the **original Adobe Flash source** for the Gas Retention
Simulator, kept for reference/archival. The accessible HTML5 rebuild that this
repository publishes lives in the repository root (`../`).

Contents (decompiled with JPEXS / FFDec):

- `gasRetentionSimulator022.fla`, `gasRetentionSimulator022.swf` — the Flash project and compiled movie
- `scripts/` — decompiled ActionScript (AS1); the behavioral ground truth for the HTML5 port
- `shapes/`, `sprites/`, `morphshapes/`, `movies/`, `images/` — exported vector/bitmap art
- `fonts/` — embedded fonts
- `texts/` — on-screen / Help / About string exports
- `symbolClass/symbols.csv` — linkage-name ↔ symbol-id map
- `frames/`, `Capture.PNG` — reference screenshots of the original running sim
- `foundation/` — the shared KL-UNL foundation as originally provided (note: its
  `contents.json` is not valid JSON; the published sim ships a corrected per-sim
  copy — see `../CONVERSION_NOTES.md`)

Nothing in this folder is used at runtime by the published HTML5 sim.
