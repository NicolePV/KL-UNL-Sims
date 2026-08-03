# Conversion Notes — Eclipsing Binary Simulator (binSys097.swf → HTML5)

## Behavior model

The simulator models two stars orbiting their common center of mass. The upper
left panel is a 3-D visualization of the system (spheres on a translucent
orbital-plane grid, with orbital paths and a center-of-mass marker); it can be
locked to the perspective from earth or freely rotated by dragging (an arrow
then shows the direction to earth). The upper right panel plots the system's
normalized visual flux versus phase, computed from 300 Kepler-solved orbit
positions, the projected overlap area of the two discs, and
bolometric-correction polynomials; a red cursor marks the current phase and
the phase axis can be scrolled by dragging the plot. The lower panels control
longitude/inclination, animation (start/pause, speed, phase), display options,
and the physical parameters of both stars (mass, radius, temperature — each
optionally constrained to the main sequence) plus separation and eccentricity.
Sliders continuously restrict each other's ranges (dark shading) so the stars
can never overlap and stay inside the H-R diagram's luminosity limits.
Presets load 8 teaching examples and 46 real systems (with observed CALEB flux
data overlaid on the light curve); a draggable "HR Diagram" window shows both
stars as draggable points with an optional main-sequence track.

## Source → port mapping

| Source (decompiled AS) | Port |
| --- | --- |
| `scripts/DefineSprite_486/frame_1/DoAction.as` (onReset) | `onReset()` in simulation.js |
| `DoAction_2.as` (H-R relations, T(L), T(R), M↔L polynomials) | `getRfromTL`, `getLfromRT`, `getTfromLR`, `getLfromT`, `getTfromL`, `getLfromM`, `getMfromL`, `getTfromR` — all constants verbatim |
| `DoAction_3.as` (range setters, setMass/Radius/Temp/Eccentricity/Separation, restrict-to-main-sequence) | same-named functions, logic verbatim |
| `DoAction_4.as` (animation, setPhase) | `setPhase`, `changeAnimateState`, rAF loop using `performance.now()` elapsed ms (same `phase += dt_ms * speed` law) |
| `DoAction_5.as` (systemsArray) | `systemsArray` — 54 entries verbatim, incl. group boundaries 8/17/24 |
| `DoAction_6.as` (change handlers, presets) | same-named functions (the CALEB-link button is not ported — see Deviations) |
| `DoAction_7.as` (initialize, view control, drag, `Math.toSigDigits`) | `initialize()`, `changeLongitude/Inclination`, `changePerspectiveLock`, perspective drag (same `57.29577951308232 * dpx / 400` law), `toSigDigits` |
| `Binary System.as` | `BinarySystem` canvas renderer: same view matrix (`doA`), Kepler iteration (`|Δ|>0.001`, ≤100 iters), 12-segment quadratic ellipse tessellation, mask/equator geometry, earth-line region splitting incl. arrowhead, depth ordering (back half → plane → front half, bodies sorted by screen z), auto-rescale `targetSize/(2h)` |
| `Lightcurve.as` | `Lightcurve` canvas renderer: plotWidth 320 / plotHeight 200 / margins 17-5-1, 300-point tables, overlap (lens) areas, BC polynomials, flux/magnitude constants (`1.89553328524593e-43`, `1521837746881349890`, `-18.9669559998301`, `1.0857362047581294`), closest-index refinement (15 steps), phase-offset wrap with 3 drawn copies, cursor mapping `w*((offset+phase)%1)` |
| `Sphere.as` | `getColorFromTemp` verbatim; disc = flat temp color + reused highlight gradient (white 70%→45%→10% alpha, from shape 172) |
| `sliderV5Component.as` + `sliderV5DefaultBar.as` | `SliderV5`: same snapping (significant-digits tick math, fixed-decimal rounding), same increment/decade logic, same 500 ms bar hold-repeat, same field restriction `0-9.Ee+\-`, range shading = excluded-range overlays (updateBar) |
| `Animation Speed Slider.as` | same `SliderV5` component (identical logic in source), no value field shown (matches the running original) |
| `Mini HR Diagram.as` | `MiniHRDiagram`: same axes (T 45000→3000 log, L 0.001→10⁶ log, 300×200), point drag → `setTempAndLuminosity`, ranges overlay verbatim (incl. constant `k2 = 0.071168672`), label-avoidance offsets |
| `DefineSprite_485` (HR window) | floating dialog: draggable title bar, close box, "show main sequence track" checkbox |
| `shapes/224.svg`, `shapes/230.svg` (HR plot art) | the 1 px plot border, the five temperature ticks (x = 0, 89.8, 166.6, 243.4, 300, 4 px below the axis) and the ten luminosity ticks (22.2 px apart, 4 px to the left) are reproduced on the canvas at those exact coordinates; the canvas is 305 x 205 so the outward ticks have room, with the plot area at (4.5, 0.5)-(304.5, 200.5) |
| Slider/checkbox/button `on(initialize)` records | all init values, ranges, scale modes, precisions and labels verbatim |

## Reused exported assets (never redrawn)

- `assets/data/<star name>.png` — all 46 observed-flux dataset bitmaps
  (`images/32.png` … `167.png`, mapped via the `<name> - flux` sprites), drawn
  at the original position (bitmap spans plot x 0–320, y −220–0) with the
  original 3-copy wraparound.
- `assets/hr-cloud.png` — HR-diagram background star cloud (`images/223.png`).
- `assets/com-marker.png` — Center of Mass Marker sprite render (green cross),
  drawn with the orbital-plane rotation + sin(φ) squash it inherits in the
  original display list.
- The star-disc highlight gradient is reproduced from the exported shape
  `shapes/172.svg` gradient stops (white 0.702 → 0.451 → 0.102 alpha); the
  disc itself is a flat fill recolored per temperature exactly as
  `Color.setRGB` did in the original.

Code-drawn art (orbit paths, plane grid, masks, equators, earth line, curve,
cursor, ticks, HR points/ranges) is redrawn on canvas from the same AS calls.

## contents.json

The sim's entry (`eclipsingbinarysim`) already existed in the foundation's
`contents.json` and is used as-is, with one content change per the conversion
instructions: the "Permission is granted…" sentence in the About tab was
replaced with the Apache License 2.0 notice (Copyright 2026 The Board of
Regents of the University of Nebraska). The NSF funding numbers and the
astro.unl.edu pointer are retained.

**Repairs (required for the file to parse):** the shipped `contents.json` was
not valid JSON — it contained raw newlines inside three string literals
(`celestialhorizon` help, `eclipsingbinarysim` help, `meltednail` help), a raw
tab inside the `pulsarperiodsim` help string, and unescaped inner quotes in
the `ptolemaic` and `venusphases` help strings. `JSON.parse` (used by the
masthead component) rejects all of these, so the copy in
`html5/foundation/contents.json` joins those line breaks, replaces the tab
with a space and escapes the inner quotes — character-level fixes only, no
wording changed. The already-converted sibling sims' foundation copies contain
the same repairs.

## Deviations from the original (all presentation-level)

- **KL-UNL shell (by design):** masthead + Reset/Help/About come from
  `<kl-unl-masthead>`; panel chrome, fonts and palette follow `kl-unl.css`
  instead of the Flash pixel layout. Panel structure and grouping mirror the
  original screenshot: two equal columns, each holding a display panel
  (visualization / light curve) above a single control panel whose groups are
  fieldsets. Group titles are plain bold legends, with no rule beside them and
  no underline beneath them. The
  two columns are independent flex stacks (as in the original, the panel
  boundary sits at a different height in each column). Both control panels
  keep their natural height so their internal rhythm is identical; the
  visualization panel — whose background is the black sky — absorbs the
  leftover height, which is what keeps the two columns finishing level.
  All spacing comes from one four-step scale (`--ebs-s1` … `--ebs-s4`, 0.25 /
  0.5 / 0.75 / 1.25rem): 4 px between slider rows, 8 px between blocks inside
  a group, 20 px between groups, everywhere in the sim.
- **Reading order is column-major:** visualization → orientation/animation
  controls → light curve → presets/star properties. This follows the visual
  columns, so each display panel is immediately followed by the controls that
  sit beneath it. (The Flash version's tab order was row-major, but its
  controls were not reachable by keyboard at all.)
- **"open CALEB info page" button removed (behavioral, at the maintainer's
  request).** `DoAction_6.as` defines an `openInfoPage` handler that opened
  `http://ebola.eastern.edu/star_summary.php?star_id=N` in a new window, and a
  button labelled "open CALEB info page" wired to it. That button does not
  appear in the released simulation (see the reference screenshot, which shows
  only "reset parameters to match"), and the maintainer asked for it to be
  dropped, so the button, its handler and the enable/disable calls are omitted.
  Nothing else depends on it — `systemsArray[i].id` is now unused. This is the
  only intentional departure from functional parity; the CALEB dataset overlays
  themselves are unaffected.
- **"lightcurve" is spelled "light curve"** in all UI text, announcements and
  the Help entry, at the maintainer's request (the Flash original ran the two
  words together).
- **Presets list:** the Flash combo box used non-selectable blank rows and
  heading rows inside the list; the HTML `<select>` uses `<optgroup>` labels
  for the same four headings ("Student Guide Examples", "Datasets with
  Complete Parameters", "Datasets with Incomplete Parameters", "More
  Datasets"). Numbering (`1.` … `54.`) is preserved.
- **Presets group is one row.** The original stacked the drop-down above its
  button and kept a comment field below that showed
  `"\n\n     - select a preset -"` while nothing was selected. At the
  maintainer's request the drop-down and "reset parameters to match" now share
  a row, and the idle placeholder is dropped (the drop-down itself already
  reads "- select a preset -"), so the comment line collapses until a preset
  supplies text. That takes about 100 px off the panel. The eight Student
  Guide examples still show their comments verbatim; the 46 catalog systems
  define no comment, and rather than the source's unfinished
  "comments for this preset go here" placeholder the line simply stays empty.
- **One text size.** At the maintainer's request every piece of interface text
  is 1rem — labels, value fields, buttons, the drop-down, plot tick labels and
  the unit symbols — with the bold 1.1rem group titles as the only exception.
  MathJax's `matchFontHeight` is turned off in the config block, because it
  otherwise scales math to match the surrounding x-height and renders the unit
  symbols about 17% larger than the labels beside them. Checkboxes are 1rem
  and buttons 2.25rem tall to match; `@media (pointer: coarse)` restores the
  1.25rem checkboxes and 2.75rem controls on touch devices.
- **Page height.** The sim is sized so it fits on screen without scrolling
  (≈934 px tall including the masthead, at the default browser font size).
  Getting there meant not blowing the two canvases up far past their native
  size: the shell is capped at 62rem and the light-curve assembly at 26rem, so
  the plot renders near its original 322 x 222 and the visualization near its
  400 x 400. Slider rows are 32 px for mouse users and keep the full 44 px
  under `@media (pointer: coarse)`.
- **Slider keyboard steps:** the original sliders had no keyboard support at
  all. Arrow keys move a scaled step (~150 presses across the range;
  Shift+Arrow = one original tick; PageUp/Down = 10 steps; Home/End = min/max)
  — pointer behavior (thumb drag, bar click + 500 ms hold-repeat) matches the
  source math exactly, and both paths share the same state.
- **Cursor hover state:** the Lightcurve Cursor's two frames (normal/hover)
  are reproduced as a thin/thicker red line on hover/focus.
- **`toSigDigits` on the period readout** returns the same numeric strings as
  the Flash version (e.g. "2.58", "3.36").
- **Animation under `prefers-reduced-motion`:** phase updates step at 2 Hz
  instead of continuously; the same phase law applies, and the animation only
  ever runs after the user presses "start animation".
- **HR main-sequence mass labels:** the original drew the track, its
  perpendicular mass ticks and the `20 M☉ … 0.2 M☉` labels as one exported
  bitmap. Rule 8a requires the unit symbols to be MathJax, so the labels are
  HTML overlays typeset by MathJax and the ticks are drawn on the canvas. Each
  label is measured after typesetting and clamped inside the plot box, so it
  sits just above and left of its tick (as the sprite drew it) without ever
  covering the axis numbers.
- **HR window "radius limit" clips:** the original placed two
  `lowerRadiusLimitMC`/`upperRadiusLimitMC` clips whose art is empty in the
  decompiled export and which are not visible in the reference screenshot;
  they are not reproduced. The drag-time range shading (`showRanges`) — the
  visible behavior — is fully ported.
- **"visual magnitude" plot mode:** `Lightcurve.as` contains a magnitude
  branch, but this sim never exposes a control for it (`dataType` is set once
  to "visual flux", and no `- mag` dataset sprites exist in the export), so
  only the flux branch is active in the port (the magnitude tables are still
  computed, as in the source).
- **MathJax:** unit symbols (M☉, R☉, K, °) and HR-diagram labels are typeset
  with self-hosted MathJax (`foundation/mathjax/`, same copy as the sibling
  conversions). The MathJax context menu is left enabled.
  MathJax is loaded `async`, so on a warm cache it can finish *before* this
  script builds the sliders and HR labels — in that case the page's initial
  typeset finds no math and the raw LaTeX would be left on screen. The sim
  therefore typesets explicitly at the end of its own boot (waiting on
  `MathJax.startup.promise` when MathJax is already present), while the
  `pageReady` hook covers the opposite order. Both paths are idempotent.

## Cross-browser notes

Pointer Events with `setPointerCapture` + `touch-action: none` are used for
every drag (supported in Chrome, Edge, Firefox, Safari 13+, iOS Safari 13+).
Canvas 2D, `<optgroup>`, CSS grid/flex, `clamp()`-free relative sizing and
`prefers-reduced-motion` are all baseline features in the target browsers. No
vendor-prefixed or Chrome-only APIs are used. The one known per-browser
difference: form-control (checkbox/select) chrome follows the platform theme,
as in every KL-UNL sim.
