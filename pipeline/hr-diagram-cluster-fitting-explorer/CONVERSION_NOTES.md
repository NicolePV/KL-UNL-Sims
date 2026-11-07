# Conversion Notes — HR Diagram Star Cluster Fitting Explorer

Flash (AS1) → accessible HTML5, on the KL-UNL foundation. Source of truth for
behaviour is the decompiled ActionScript under `../scripts/`; source of truth
for chrome/layout is the KL-UNL foundation + WCAG.

---

## Behaviour model (one paragraph)

The explorer teaches **main-sequence fitting** to find a star cluster's
distance. The left panel is an HR diagram whose **fixed** model curve is the
zero-age main sequence (luminosity class V), plotted as **absolute bolometric
magnitude** (red, left axis) against **temperature** on a reversed log scale
(hot 20 000 K left → cool 2 500 K right). The right axis shows **apparent
bolometric magnitude** (blue). The student picks a cluster; each of its stars
(stored as apparent visual magnitude + B−V colour) is plotted as a blue point,
its temperature derived from B−V and its apparent bolometric magnitude from
apparent visual magnitude + a bolometric correction. Because the cluster is
distant, its main sequence sits low; dragging the diagram vertically (pointer
**or** keyboard) shifts every star by the current **distance modulus** `m − M`
until the cluster overlaps the model curve. A "show horizontal bar" option adds
a movable reference line reporting matching absolute (red) and apparent (blue)
magnitudes, which differ by the distance modulus. A Distance Modulus Calculator
converts typed `m` and `M` into `m − M` and `d = 10^((m − M + 5)/5)` parsecs.

---

## Physics — ported VERBATIM

All coefficients/tables/formulas were copied character-for-character from
`../scripts/HR Diagram Component 042 Modded.as` into `simulation.js` §1. They
are validated end-to-end: the rendered curve matches an independent evaluation
of the formula at many sampled temperatures to sub-pixel accuracy.

| Quantity | AS function | Notes |
|----------|-------------|-------|
| Spectral-type → log T | `getLogTempFromType` | 8-segment piecewise cubic |
| B−V → spectral-type | `getTypeFromBV` | 17-segment piecewise cubic |
| B−V → log T (for the data) | `getLogTempFromBV` = type∘BV | |
| log T → bolometric correction | `getBCFromLogTemp` | 6-segment |
| log T → log L (main sequence) | `getLogLumFromLogTempAndClass`, class **V** (default branch) | 8-segment |
| magnitude ↔ log L | `getMagFromLogLum` = `4.75 − 2.51189·L` | `M_bol,☉ = 4.75` |

**Axis ranges** (from the AS init):
`setXAxisType("logTemp", 3.397939, 4.3013)` → x from 2 500 K to ~20 023 K,
reversed. `setYAxisType("absBolMag")` default → y from
`getMagFromLogLum(6) ≈ −10.3213` (top) to `getMagFromLogLum(−5) ≈ 17.3095`
(bottom); labels every 2 mag.

**Star plotting** (matches `updateObjectsByList` with `distanceModulus = 0`,
then offset applied): `logTemp = getLogTempFromBV(BV)`,
`appBolMag = appVisMag + getBCFromLogTemp(logTemp)`; the point is drawn at
absolute-equivalent magnitude `appBolMag − distanceModulus` — algebraically
identical to the AS "base position + layer `_y` offset".

**Drag sensitivity** matches the AS exactly. The AS
`scaleFactor = −(yMax − yMin)/height` (height = the 400-unit draggable area).
The port maps a pointer drag of `Δy` CSS-pixels to
`Δmod = −(yMax − yMin)·Δy / plotClientHeight`, i.e. dragging the full plot
height changes the modulus by the whole y-range, then clamps to the AS limits
`[−10, 20]` (`initMinOffset`/`initMaxOffset`).

**Number formatting** ports the AS helpers: the calculator's `m − M` uses an
AVM1-`Number.toString`-equivalent (`flashNum`, 15 significant digits, trimmed);
the distance uses `formatNumber(d, 3)` (3 significant figures) or, for
`d < 0.001` or `d > 100000`, `toScientific(d, 3)` → `sig × 10^exp` — both
faithful ports (`../scripts/DefineSprite_209/frame_1/DoAction.as`,
`../scripts/Number Functions.as`).

---

## ActionScript → HTML5 mapping

| Flash symbol / behaviour | HTML5 realisation |
|--------------------------|-------------------|
| `Cluster Fitting Explorer` controller | `simulation.js` state + `render()` |
| `HR Diagram Component 042 Modded` (curve, axes, dots, masks) | `<canvas>` 2D drawing in original stage coordinates; CSS scales it |
| `HR Diagram Dot` (2-px blue disc) | `ctx.arc` blue dot, radius 1 |
| Luminosity-class-V curve | polyline sampled from `getLogLumFromLogTempAndClass(t, 5)` |
| `Vertically Draggable Area` (drag → `offset` → `distanceModulus`) | full-plot `role="slider"` proxy: Pointer Events + arrow/Page/Home/End keys |
| `HR Horizontal Bar` (movable line, red/blue readouts) | `role="slider"` bar element; readouts typeset by MathJax |
| `FComboBox` "select cluster" | native `<select>` |
| `FCheckBox` "show horizontal bar" | native `<input type=checkbox>` |
| Distance Modulus Calculator (`DefineSprite_209`) | native text inputs + MathJax formula/result |
| `displayText` rich-text (`<sub>`/`<sup>`) | MathJax LaTeX |
| `Title Bar` + About / Reset | the `<kl-unl-masthead>` component (Reset via the `sim-reset` event) |
| `onEnterFrame` / `getTimer()` | event-driven `render()` (no idle animation loop) |

### Asset reuse

`../images/` is **empty** and `../shapes/*.svg` are all Flash UI-component
chrome (combo-box, check-box, scroll-bar, panel backgrounds, dialog, grab-hand
cursors) that the KL-UNL foundation and native controls replace. There is no
photographic/informative exported art to reuse, so **all** plot visuals (curve,
dots, axes, ticks, border) are genuinely code-drawn geometry, reproduced on the
canvas. The Flash-embedded Verdana fonts are standard Verdana; the sim relies on
a system sans-serif stack rather than bundling them.

---

## `contents.json` — changes to this sim's local copy

`foundation/contents.json` already contained a `clusterFittingExplorer` entry
(sim-id used by the masthead). Changes made **only to the local copy** in
`html5/foundation/`:

1. **This sim's About** (`clusterFittingExplorer` → `masthead.about.content`):
   - Closed a stray unterminated `<a>` tag ("Nebraska Astronomy Applet
     Project" now closes before the period).
   - Per instruction, replaced *"Permission is granted to use these files for
     noncommercial purposes as long as they remain unmodified."* with the
     **Apache License 2.0** notice (Copyright 2026 The Board of Regents of the
     University of Nebraska; link to `apache.org/licenses/LICENSE-2.0`).
   - **Kept** the NSF funding numbers (#0231270 and/or #0404988) and the
     `astro.unl.edu` reference.
   - **Help** (`masthead.help.content`): kept the original one-sentence summary
     and added step-by-step usage instructions after it (select a cluster; drag
     the points to align apparent with absolute magnitude; the shift is the
     distance modulus; the horizontal bar; the calculator; Reset). The original
     Flash sim had no Help text, so this is new instructional material rather
     than ported text. Written in words rather than math symbols, because the
     Help dialog renders inside the masthead's Shadow DOM (which MathJax does
     not typeset) and the component flattens it to plain text for VoiceOver.

2. **JSON-validity repairs (required for the file to load at all).** The
   shipped `contents.json` was **not valid JSON** and `response.json()` (used
   by the un-editable masthead) rejected the whole file, breaking the masthead
   for *every* sim, not just this one. The minimal, semantically-invisible
   repairs applied to the local copy were:
   - Removed control characters that appeared **inside** string values (one
     literal TAB in `pulsarPeriodSim001`; literal newlines inside four other
     sims' help/about strings) — replaced with a single space; browsers render
     the HTML identically.
   - Escaped two unescaped `"` characters in cross-link `href` attributes
     (`href="../venusphases"` → `href=\"..\"`, and `../ptolemaic`) inside the
     Venus-phases entries.

   These touch other sims' *whitespace/escaping only* (no wording change) and
   are confined to this local copy. If a canonical shared `contents.json` is
   maintained upstream, the same fixes should be applied there. The foundation
   `.js`/`.css` files are byte-for-byte unchanged.

---

## Deviations from the original (all presentational, none physical)

- **Layout** follows the KL-UNL shell, not Flash pixel coordinates. Panel
  grouping and reading order mirror the original screenshot (large HR-diagram
  panel left; Cluster Selection / Diagram Options / Distance Modulus Calculator
  stacked right). The two-column ratio is set in `styles.css` only above the
  foundation's 56 rem breakpoint, so the foundation's single-column collapse is
  preserved untouched. On wide screens the Distance Modulus Calculator panel
  stretches so its bottom lines up with the plot panel's bottom (the original
  left that slack in the Diagram Options panel instead).
- **Fonts.** MathJax uses CHTML output with `mtextInheritFont`, so the plain plot
  numbers, bar readouts and the `(M)`/`(m)` axis variables are wrapped in
  `\text{…}` and render in the page's own sans-serif font (matching the other
  labels); the calculator's italic `m`/`M`/`d` stay in MathJax's math font, as in
  the original. All remain real MathJax (right-click "Show Math As" works).
- **Colours** keep the original semantic red (absolute) / blue (apparent)
  coding — both already pass WCAG AA on white — but are never the *only* signal
  (axis titles, tick numbers and the calculator name the quantities). See
  `ACCESSIBILITY.md`.
- **Axis tick marks** are drawn **inward** from the plot edges (the original
  drew them outward); this keeps the canvas exactly equal to the plot area so
  the HTML tick-label overlay aligns at any zoom/size. Numbers themselves live
  in MathJax HTML overlays (they zoom and expose the "Show Math As" menu),
  not painted on the canvas.
- **Bar value readouts** are bordered white value-tags just *outside* the plot
  edges (as in the original) on wide screens; on narrow/phone widths they move
  just *inside* the edges so they never overflow the viewport. The reference
  line's travel is also clamped by a few pixels at the very top/bottom so its
  readouts never cover the temperature axis labels (a negligible fraction of the
  magnitude range).
- **Right-column panel heights.** Diagram Options and the Distance Modulus
  Calculator both flex-grow, sharing the vertical slack so neither is left
  entirely blank while the last panel's bottom still lines up with the plot.
- **Dropdown order** is the source definition order (Pleiades, Hyades, NGC 188,
  Messier 67, NGC 3293, Praesepe, h Persei, chi Persei). The original relied on
  AVM1 `for..in`, whose order is not specified.
- **No idle animation** exists in this sim, so there is no Pause button and
  `prefers-reduced-motion` has nothing to suppress (a defensive rule zeroes any
  incidental transitions).

## Cross-browser

Standards-only: Pointer Events, CSS grid, `aspect-ratio`, `writing-mode`,
`:focus-visible`, `inset`, native form controls, and locally-vendored MathJax —
all supported in current Chrome, Edge, Firefox and Safari (desktop + iOS). No
Chrome-only APIs and no prefix-only CSS. Verified functionally in a Chromium
engine here (canvas pixel sampling + DOM/geometry probes; the environment's
screenshot capture was unavailable). Human QA on Safari/iOS and Firefox is still
recommended.
