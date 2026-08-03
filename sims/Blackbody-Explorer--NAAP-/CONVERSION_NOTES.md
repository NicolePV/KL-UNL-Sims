# Conversion Notes — Blackbody Curves and Filters Explorer

## Behavior model (one paragraph)

The explorer plots one or more **blackbody (Planck) spectra** — flux vs.
wavelength — on a shared graph, and lets the user compare how a thermal source
(a star, to first approximation) changes with temperature. Each curve has a
temperature (3000–25000 K); the graph autoscales (or locks) vertically and the
user sets the rightmost wavelength limit (1–5 µm) horizontally. A **curves** tab
manages up to five curves (add / remove / select), shows each curve's
temperature, **peak wavelength** (Wien's law) and **area under curve**
(Stefan–Boltzmann), and can highlight the area under, or the peak of, the
selected curve. A **filters** tab overlays the standard **U, B, V, R** filter
passbands on the selected curve, computes the star's apparent magnitude through
each filter (for a 1 R☉ star at 10 pc), a user-chosen **color index**
(magnitude difference), and a bar graph of the relative flux each filter admits.
A rainbow band marks the visible part of the spectrum (≈380–720 nm).

## Source → ground truth

Decompiled with JPEXS/FFDec from `bbExplorer026.swf`. Behavior ports the
ActionScript (AS1) in `decompiled/scripts/`; the screenshot
(`Screenshot 2026-07-12 125138.png`) is the layout reference.

Key source files ported:
- `Blackbody Explorer.as` — top controller (add/remove/select, tabs, scaling).
- `Simple Blackbody.as` — Planck curve drawing, autoscale, axis tick generation.
- `Filterer.as` + `Filter Data.as` — U/B/V/R passbands, filter flux integrals.
- `Filter Details Panel.as` — magnitudes, color index, bar graph.
- `Number Formatting.as`, `Scientific Notation Number.as` — number/sci formatting.
- `sliderV5Component.as` — log/linear sliders with significant-figure snapping.
- Component-instance parameters read from the `on(initialize)` clip scripts in
  `DefineSprite_295_Blackbody Explorer/frame_1/`.

## Verbatim constants and formulas (copied exactly, never rounded)

| Quantity | Value (verbatim) | Source |
|---|---|---|
| Planck A | `1.1910425859324616e-16` | Simple Blackbody.redraw |
| Planck B (hc/k) | `0.014387750559248378` | Simple Blackbody.redraw |
| Wien constant | `0.0028977682864295084` m·K | getPeakWavelength |
| Wien (nm form) | `2897768.2864295086 / T` | updateCurveInformation |
| Stefan–Boltzmann | area `= 5.669e-8 * T^4` | updateCurveInformation |
| autoscale target | `0.9` (peak reaches 90 % height) | updateScale |
| curve colors | `[15753312,6344800,10526960,15580466,10526880]` | curveColorsList |
| min wavelength | `2.5e-8` m (25 nm), fixed | Simple Blackbody init |
| temp slider | 3000–25000 K, **log**, 3 sig figs, default 6000 | slider init |
| rightmost limit | 1000–5000 nm, **linear**, 2 sig figs, default 1000 | slider init |
| magnitude offset const | `2.5*log10(1.288659793814433² / 0.37037037037037035²)` | Filter Details Panel.update |
| filter offsets | U 18.7781722700872, B 18.3809597325381, V 17.9576848442658, R 18.2183567502167 | Filter Data.as |
| bar normalizers | U 101.6, B 70.45, V 47.7, R 60.65 (× `32500·π·sum/area`) | updateBarGraph |
| visible spectrum | colors/ratios/alphas gradient over 380–720 nm | updateHorizontalAxis |

The full U/B/V/R transmittance tables are copied byte-for-byte into
`assets/filter-data.js` (from `Filter Data.as`) and never edited.

Verified numerically in-browser: 6000 K → peak **483.0 nm**, area **7.35×10⁷ W/m²**
(matches the original screenshot); 3000 K → peak **965.9 nm**; filter magnitudes
U 5.65, B 5.06, V 4.61, R 4.36; color index B−V = 0.45.

## AS idiom → HTML5 mapping

- `Object.registerClass` prototype classes → plain state object + functions.
- `createEmptyMovieClip` / `lineTo` / `curveTo` / `beginGradientFill` curve and
  spectrum drawing → HTML5 `<canvas>` 2D drawing in the **original stage
  coordinates** (canvas backing 612×478; CSS scales it, preserving aspect ratio).
  The Planck curve is sampled one point per pixel column — physically identical
  to the source's adaptive-Bézier tessellation, which was a rendering detail, not
  physics.
- `attachMovie` tick-label symbols → HTML spans positioned in % over the canvas,
  **typeset by MathJax** (so `×10ⁿ`, `µ`, `Δλ`, `m²` are real math, zoom with the
  page, and expose the MathJax "Show Math As…" menu).
- `sliderV5Component` (log scale + significant-figure snapping) → native
  `<input type="range">` whose position maps through the same log/linear + sig-fig
  math, plus an editable numeric field. Fully keyboard operable.
- `FUIComponent` / `FPushButton` / `FComboBox` / `FRadioButton` / `Tab Group` →
  native `<button>`, `<select>`, `<input type="radio/checkbox">`, and an ARIA
  tablist. The Flash component framework itself is **not** ported.
- `getTimer()` / `onEnterFrame` — not needed: this sim has **no continuous
  animation** (curves are static until an input changes). No rAF loop.

## The KL-UNL foundation & contents.json

`foundation/` is copied in **unchanged**. `contents.json` **already contained a
complete `bbexplorer` entry** (meta.title "Blackbody Curves and Filters Explorer",
version 2.0, and Help/About text derived from the original `texts/19.txt`, `21`,
`25`, `26`). Its bytes are already correct UTF-8 (the en-dash renders fine). **No
edit to any foundation file was required or made.** The page uses
`sim-id="bbexplorer"` and `json-url="foundation/contents.json"`.

## Assets: reused vs. code-drawn

The JPEXS export contains **no bitmaps** (`images/` is empty). All original
`shapes/*.svg` are Flash UI chrome (panel backgrounds, tab shapes, button skins,
slider tracks) that the KL-UNL foundation + native controls replace, so none are
reused as art. Everything on the plot (curves, axes, tick marks, rainbow band,
filter passbands) is genuinely **code-drawn** in the AS and is reproduced with
canvas 2D drawing. MathJax is vendored locally in `assets/mathjax/` (no CDN).

## Deviations from the original (all presentation-only; physics unchanged)

1. **Chrome/layout/palette** follow the KL-UNL shell and WCAG rules, not the
   Flash pixel layout, per the pipeline's priority order. Panel grouping and
   reading order (spectrum plot left; curves/filters + scaling controls right)
   mirror the screenshot.
2. **Visible-spectrum band** is drawn 14 px tall (vs. the source's 7 px
   `minorTickmarkExtent`) so the rainbow is clearly legible; position (sitting on
   the x-axis, 380–720 nm) and gradient colors are unchanged.
3. **Rightmost-limit slider** gains a live "2.5 µm" readout (the Flash slider had
   only fixed "1 µm"/"5 µm" end labels) for clarity and screen-reader support.
4. **Curve list** is a single-select ARIA radiogroup styled as the original
   table; selection is keyboard-operable (the Flash list was mouse-click only).
5. Numeric tabular cells use ~1 rem (vs. the ≥1.125 rem body floor) so the 4-column
   curve table fits the narrow panel without clipping; still legible and zoomable.
6. Bar-graph heights use the exact per-filter normalizers from the source, then a
   single uniform display scale to fit the graph box — relative strengths (the
   pedagogical point) are preserved exactly.
7. **Y-axis labels** factor the common power of ten into a single "×10ⁿ" header
   (centered above the axis) with ticks shown as MathJax mantissas (3.5, 3.0, … 0)
   instead of "3.5×10¹³" on every tick — same values, far less clutter. Both axes'
   labels are MathJax-typeset and centered/right-aligned on their tick marks.
8. **X-axis labels** are thinned to every other major (e.g. 200/400/600/800 nm,
   1 µm) when a full set would crowd; all tick *marks* are still drawn at every
   major/minor position. Tick values and the plot's coordinate math are unchanged.
9. The left plot panel is stretched to match the height of the stacked right-hand
   panels; the plot is centered within it. The "K" temperature unit sits outside
   the value box. Read-only MathJax labels are removed from the tab order
   (`tabindex="-1"`) so keyboard Tab visits only interactive controls (right-click
   still opens the MathJax menu).

## Known tooling note

The IDE's automated screenshot capture times out on this page (the large
MathJax-SVG global font cache stalls the headless screenshotter); the rendered
DOM, canvas pixels, tick labels, and all interactions were verified directly and
match the original. Human visual QA in a normal browser is still recommended.
