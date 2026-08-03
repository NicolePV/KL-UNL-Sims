# Conversion Notes — Supernova Light Curve Fitting Explorer

## Behavior model

The sim shows a fixed theoretical Type Ia supernova light curve (a red
curve peaking at absolute magnitude −19.5 at day 0) on a plot of B
magnitude versus days from peak (x: −50 to 400 days; y: −22 to −10). The
user picks one of 13 real supernovae from a combo box; its B-band
observations appear as blue dots, positioned horizontally by days since
the first observation and vertically by apparent magnitude. Dragging
anywhere on the plot shifts the dots: horizontally by up to 200 plot
pixels (aligning the observed peak with day 0) and vertically without a
fixed limit — the vertical shift IS the distance modulus (m − M), and it
also slides the blue apparent-magnitude labels on the right-hand axis
(apparent = absolute + modulus). When a supernova is selected the
vertical shift is clamped so at least 1 magnitude of the data stays
within the plot. Fitting the dots onto the template reads off the
supernova's distance modulus. An optional horizontal bar (checkbox) can
be dragged vertically to read matched absolute (left, red) and apparent
(right, blue) magnitudes, each shown to 1 decimal in bordered value tags.
A Distance Modulus Calculator takes m and M and displays m − M and the
distance d = 10^((m−M+5)/5), formatted as "x pc" (3 significant digits),
"x.x Mpc" (outside 0.001–100000 pc), "0 pc", or "…" while either input is
empty/invalid. Reset restores the initial state.

## Source → HTML5 mapping

| Original (decompiled AS)                              | HTML5 port                            |
| ----------------------------------------------------- | ------------------------------------- |
| `SN Curve Fitting Explorer.as` init/onDrag/onReset/onSelectorChanged/onShowHorizontalBarChanged | `simulation.js` (same names in comments) |
| `HR Diagram Component 042.as` (only the parts this sim uses: absBolMag y-axis −22…−10, appBolMag right scale, distance-modulus object-layer offset, plot mask, border) | canvas rendering + HTML tick overlays |
| `Supernova Data.as` (`_global.snList`)                | `assets/snData.js` (mechanical sed transcription — verbatim) |
| `Draggable Area.as` (2-D drag, xScaleFactor 1, yScaleFactor −(yMax−yMin)/height, NaN-safe clamps) | pointer drag + keyboard path on `#sn-drag` |
| `HR Horizontal Bar.as` (bar drag, `toFixed(1)` value tags, reset to plot middle) | `#sn-bar` slider + readouts |
| `DefineSprite_194` calculator (`update()`, `formatNumber()`, restrict `0-9.+\-`) | `updateCalculator()` (exact port incl. the Mpc branch) |
| `Number Functions.as` `toFixed` polyfill              | `asToFixed()` (round-half-away-from-zero) |
| `Title Bar` + `Dialog Window v2` + `About`            | `<kl-unl-masthead>` (helpLinkageName was `""` in the original — see Help note below) |
| FCheckBox / FComboBox Flash components                | native `<input type="checkbox">` / `<select>` |
| `displayText` sub/sup renderer                        | MathJax (all math, incl. axis variables M_B, m_B and tick numbers) |

Key verbatim constants: peakAbsMag −19.5; timeRange 450; timeAtLeft −50;
labelled ticks −50…400 step 50; unlabelled ticks −25…375 step 50; plot
460×325 (Draggable Area width/height); x-offset clamp 0…200; y-clamp
minMag+1−(−10) … maxMag−1−(−22); curve scale factors
1.205141938939475·(plotWidth/timeRange) and
0.0330760749724366·(plotHeight/12); the 8 quadratic Bézier control points;
colors 13643824 (red) and 1924851 (blue); distance thresholds 0.001 /
100000 pc and the ÷1 000 000 → "Mpc" formatting.

## Assets

- `images/` in the decompile is **empty** — the sim has no bitmaps.
- `shapes/*.svg` are all Flash UI chrome (checkbox/combo-box states, scroll
  bar, dialog close button, panel backgrounds, title bar, the open/closed
  grabber hands, value-tag boxes). Per the pipeline rules these are
  replaced by native accessible controls, the KL-UNL masthead, and CSS
  `grab`/`grabbing` cursors — not redrawn as art.
- Everything visible in the plot (curve, dots, ticks, bar) is code-drawn
  in the AS (`createEmptyMovieClip`/`lineStyle`/`curveTo`/`drawCircle`),
  so it is reproduced with canvas 2D at the same coordinates.
- MathJax is vendored locally in `assets/mathjax/` (no CDN at runtime).

## contents.json

The sim uses the pre-existing `snCurveExplorer` entry in the per-sim copy
`foundation/contents.json`. Changes made to the copy:

1. Per instruction, the "Permission is granted…noncommercial…" sentence in
   this sim's About content was replaced with the Apache License 2.0
   notice (Copyright 2026 The Board of Regents of the University of
   Nebraska). The NSF funding sentence and the astro.unl.edu link are
   kept.
2. The shipped foundation `contents.json` is **invalid JSON** as delivered
   (confirmed: the browser's `JSON.parse` rejects it, so the masthead of
   every sim fails to load its text). The following escaping/whitespace-only
   repairs — no wording changes — were applied to this sim's copy, matching
   the precedent set by the earlier "HR Diagram Star Cluster Fitting
   Explorer" conversion:
   - two unescaped `"` characters in cross-link `href="…"` attributes
     (`renaissancePtolemaic` and `venusphases` entries) escaped to `\"`;
   - four raw newlines inside string literals (help content of `ce_hc`,
     `eclipsingbinarysim`, `meltednail`, `moonbisector`-area entries)
     joined onto one line;
   - one raw tab character inside the `pulsarPeriodSim001` help string
     replaced with a space.
   The shared master copy of contents.json needs the same repairs.

## Help button

The original Flash sim sets `helpLinkageName = ""` (no Help button). The
pre-existing `snCurveExplorer` contents.json entry, however, already ships
Help text ("This explorer allows one to determine the distance to a
supernova by fitting observations to a theoretical Type Ia light curve."),
so the masthead shows a Help button with that curated text. That entry was
left as the pipeline maintainers wrote it (the only edit was the license
swap above). If strict parity (no Help button) is preferred, set that
entry's `help.content` to `""`.

## Deliberate deviations from the original

- **Combo order**: AVM1 `for..in` iterates arrays in reverse insertion
  order, so the original combo listed 1993J first and 1999ee last. This is
  replicated. (Noted here because it looks "backwards" relative to the
  data file.)
- **Reset keeps old drag limits**: after Reset, the vertical-drag limits
  from the last selected supernova remain in force until a new supernova
  is chosen — exactly as in the AS (`onReset` does not clear
  `minYOffset`/`maxYOffset`). Kept for parity.
- **Unbounded vertical drag before first selection** is likewise kept
  (limits are `NaN` until a supernova is chosen); the right-axis labels
  are generated dynamically so any modulus value renders correctly.
- **Grabber cursors**: the original's custom open/closed-hand movie clips
  are replaced by the standard CSS `grab`/`grabbing` cursors (and the
  keyboard path has a visible focus ring instead).
- **Hover thickening of the bar** (2 px → 3 px) is preserved, and also
  triggered by keyboard focus (`:focus-visible`) so it is not hover-only.
- **Value tags and tick labels** are HTML/MathJax overlays instead of
  canvas text so they zoom, reflow and expose the MathJax context menu;
  their positions are driven by the same plot fractions the canvas uses.
- **Layout** follows the KL-UNL shell (panels, fonts, palette for chrome)
  rather than the Flash pixel layout; the panel structure, grouping and
  reading order (controls → plot → calculator) mirror the original
  screenshot. The physics colors (red/blue) are kept for the plot.
- The original's `trace("init time: …")` debug output is dropped.

## UI refinements

- **Compact single-column width**: the sim shell is capped (`.app-shell.sn-shell`
  max-width 41rem) so the plot stays a moderate, original-like size and the
  plot + calculator fit on one screen instead of the plot ballooning to full
  page width.
- **Crisp canvas**: the `<canvas>` backing store is sized to its *displayed*
  pixel size × devicePixelRatio (via `getBoundingClientRect`), with the
  original stage coordinate system mapped on through `ctx.setTransform`. This
  keeps the drawing/physics math in original units (parity unchanged) while
  eliminating the blur that came from stretching a fixed logical backing store.
- **All-sans MathJax in the calculator**: every token in the calculator formula
  and result (`m`, `M`, `-`, `= -5 + 5 log`, the subscript `10`, `d`, and the
  computed modulus/distance) is wrapped in `\text{}` so MathJax renders it in
  the page sans-serif font (via `chtml.mtextInheritFont`), matching the rest of
  the UI. It is still MathJax output, so the "Show Math As" right-click menu
  still works and the math stays screen-reader exposed. The empty state shows
  the original's literal "..." placeholders.
- **Tick-label spacing**: the axis tick numbers sit in the plot padding with a
  gap that clears the original's outward-pointing tick marks, so numbers never
  touch the ticks or the rotated axis titles at any supported width/zoom.

## Cross-browser notes

Standards-only: Pointer Events, canvas 2D, CSS grid/flex, `aspect-ratio`
(supported in all evergreen browsers and Safari ≥ 15). `touch-action:
none` on the drag surfaces keeps iOS Safari from scrolling during drags.
No vendor-prefix-only CSS, no Chrome-only APIs. MathJax CHTML output is
identical across browsers (fonts are vendored .woff files).
