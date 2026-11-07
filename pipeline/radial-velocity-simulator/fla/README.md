# Original Flash source (`fla/`)

This folder holds the **decompiled Adobe Flash source** of the original
Radial Velocity Simulator — the JPEXS / FFDec export of
`radialVelocitySimulator012.swf` (plus the `.fla` and `.swf` themselves).

It is the *ground truth for behavior* that the accessible HTML5 port at the
**repository root** was converted from. Nothing here is used at runtime by the
deployed site; it is included for reference and provenance.

Contents:

- `radialVelocitySimulator012.fla`, `radialVelocitySimulator012.swf` — the
  original Flash movie and its compiled SWF.
- `scripts/` — the decompiled ActionScript 1 (`.as`) — the authoritative
  source for every constant, formula, table, and piece of on-screen text.
- `shapes/`, `sprites/`, `images/`, `morphshapes/`, `movies/`, `fonts/` —
  exported vector shapes, bitmaps, sprite previews, and fonts.
- `symbolClass/symbols.csv` — linkage name ↔ symbol id map.
- `texts/` — extracted text strings.
- `frames/1.png`, `Capture.PNG` — reference screenshots of the running
  original, used as the layout reference for the port.
- `foundation/` — the shared KL-UNL foundation files as originally provided
  (the deployed copy at the repo root is the one actually served).

See `../CONVERSION_NOTES.md` for the full AS → HTML5 mapping.
