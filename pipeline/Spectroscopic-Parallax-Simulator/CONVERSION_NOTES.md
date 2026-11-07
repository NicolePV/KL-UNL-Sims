# Conversion notes — Spectroscopic Parallax Simulator

Source: `spectroParallax013.swf` / `spectroParallax013.fla` (SWF version 6,
870 × 600 stage, 1 frame, ActionScript 1), decompiled with JPEXS/FFDec.
Reference screenshot: `Screenshot 2026-07-27 121113.png` in the simulation
folder.

## Behaviour model

The simulator teaches spectroscopic parallax: how a star's distance follows from
its spectrum. A red cursor is dragged across a plot of absorption-line strength
versus spectral type; wherever it lands fixes a spectral subtype (O0 … M9, 70
steps), and from that subtype a cubic fit gives the star's effective temperature.
Choosing a luminosity class (I … V) then fixes which track the star sits on in
the HR diagram, so temperature plus class gives its luminosity, and luminosity
plus a bolometric correction gives its absolute visual magnitude. The user also
sets an apparent magnitude with a slider. The distance follows from the distance
modulus, m − M = −5 + 5 log₁₀ d, and is displayed with the formula and the
numbers stacked one above the other. Meanwhile the simulated spectrum is redrawn:
a continuous rainbow band crossed by absorption lines whose opacity comes from
six line-strength tables (ionized helium, neutral helium, hydrogen, ionized
metals, neutral metals, molecules) evaluated at the chosen subtype, drawn more
thickly for the more luminous classes. Nothing animates on its own; every change
is driven by user input.

## Source files read

| Decompiled file | What was taken from it |
| --- | --- |
| `scripts/DefineSprite_164/frame_1/DoAction.as` | The simulator controller: `init`, `setCursorPosition`, `spectralClassUpdate`, `classChange`, `makeSpectrum`, `createArrays`, `createLineArrays`, `formatNumber`, `getDistanceFromAbsAndApp`, `onReset`, and the 70-entry line-description table |
| `scripts/spectra.as` | `spectPos`, `xPos`, the seven-stop gradient, `drawColorLineAt`, `drawColorSet` |
| `scripts/HR Diagram Component 043.as` | `getLogTempFromType`, `getBCFromLogTemp`, `getLogLumFromLogTempAndClass`, `getMagFromLogLum`, `getAbsVisMagFromLogLum`, `getSpectralTypeNumber`, `setXAxisType`/`setYAxisType`, `updateLuminosityClassLines`, `drawYScale`, `drawTemperatureScale`, `updateObjectsByList` |
| `scripts/Slider Logic Class v6.as` | Value quantisation and `toFixed` formatting for the magnitude slider |
| `scripts/HR Diagram Dot.as` | Marker size and colour |
| `PlaceObject2 … on(initialize)` clip actions | Panel titles, slider parameters, radio-button values, HR component options |
| `swf.xml` (`ffdec -swf2xml`) | Placement matrices, symbol bounds, text colours |

## Assets reused as-is (never redrawn)

All five are exported vector shapes, copied into `assets/` and placed at their
original stage coordinates.

| File in `assets/` | Original symbol | Used for |
| --- | --- | --- |
| `absorption-plot-box.svg` | Shape 159 | The plot frame, stage rect (58.05, 108) – (409, 290) |
| `absorption-curves.svg` | Shape 152 | The six line-strength curves |
| `absorption-tickmarks.svg` | Shape 141 | One tick-mark decade; placed seven times at x = 80.5 … 380.5, y = 289 |
| `spectral-type-cursor.svg` | Shape 162 | The draggable red cursor with its two arrowheads |
| `hr-luminosity-class-regions.svg` | Shape 12, inside `Luminosity Classes Overlay` (Symbol 21) | The shaded supergiant / giant / dwarf / white-dwarf regions |

`assets/mathjax/tex-svg.js` is a local MathJax build (no CDN at run time).

There are no bitmaps in the export (`images/` is empty), so nothing is drawn with
`drawImage`.

## Code-drawn art, redrawn on canvas

Only art the ActionScript builds at run time is reproduced in code:

* **Simulated spectrum** (`spectra.as`) — the seven-stop linear gradient and the
  absorption lines, on a canvas that keeps the original 500 × 50 internal
  coordinates. The clip is placed on stage with `scaleX = −0.84`, so the canvas
  is drawn in screen order (`500 − xPos(λ)`), which puts violet at the left.
* **HR diagram** (`HR Diagram Component 043.as`) — the plot background and
  border, the left luminosity scale (7-unit major ticks at each decade, 3-unit
  minor ticks at log₁₀2 … log₁₀9), the bottom temperature ticks, the five
  luminosity-class curves (100 segments across the axis, each clipped to its own
  log T span), and the star marker (`HR Diagram Dot`, `dotSize: 6`,
  `dotColor: 0`).

## ActionScript → HTML5 mapping

| AS1 idiom | HTML5 |
| --- | --- |
| `Object.registerClass` + `prototype = new MovieClip()` | Plain functions and one `state` object; a single `render()` redraws everything |
| `createEmptyMovieClip` + `beginGradientFill` / `lineStyle` / `lineTo` | Canvas 2D with the same coordinates and the same colour/alpha values (AS colour ints converted to hex, alpha 0–100 divided by 100) |
| `setMask` on the spectrum and plot area | `ctx.clip()` and an `overflow: hidden` wrapper for the HR region artwork |
| `cursorMC.onPress` → `onMouseMove` → `onReleaseOutside` | Pointer Events with pointer capture; the grab offset and `setCursorPosition`'s snapping are unchanged |
| `_xmouse` in the parent's space | Pointer coordinates mapped back through the stage's scale, so the drag maths runs in original stage units at any display size |
| `_x` / `_rotation` placement matrix of `cursorMC` | The same matrix on an SVG `<g>`: `matrix(0, 0.7069092, −0.6000061, 0, x, 199.5)`; only `x` changes |
| `FRadioButtonSymbol`, `Standard Slider v6`, `FUIComponent` | Not ported. Native `<input type="radio">`, `<input type="range">` and `<input type="number">` reproduce the observable behaviour with real keyboard and screen-reader support |
| `Title Bar` symbol (title + Reset / About) | `<kl-unl-masthead>`; `onReset` is wired to the component's `sim-reset` event |
| `Dialog Window v2` / `About` symbols | The masthead's own modal, fed from `contents.json` |
| `Number.prototype.toFixed` polyfill, `formatNumber` | Reproduced exactly, including `formatNumber`'s significant-figure rounding |
| `onEnterFrame`, `getTimer`, `updateAfterEvent` | Not needed: the original has no timeline animation |

## Constants and formulas

Every constant is verbatim. Spot checks against an independent reimplementation
of the ActionScript (all agree to the last displayed digit):

| Subtype | Class | m | T | M_v | d |
| --- | --- | --- | --- | --- | --- |
| 42 (G2) | V | 1.0 | 5840 K | 4.8 | 1.70 |
| 43 (G3) | V | 1.0 | 5760 K | 5.0 | 1.59 |
| 53 (K3) | V | 1.0 | 4770 K | 6.8 | 0.692 |
| 0 (O0) | V | 1.0 | 50200 K | −5.8 | 228 |
| 69 (M9) | V | 1.0 | 2370 K | 20.1 | 0.00153 |
| 69 (M9) | I | 1.0 | 2370 K | −1.8 | 37.1 |
| 69 (M9) | I | 7.3 | 2370 K | −1.8 | 675 |

The G2 / 5840 K / 4.8 / 1.70 row is the start-up state and matches the reference
screenshot exactly.

Geometry taken from the source rather than measured off the screenshot:

* Spectral-type axis: `x_start = 58`, `x_width = 350`, `x_inc = 5`, 70 subtypes;
  start-up cursor at `x = 268` → subtype 42 → G2.
* HR plot size: `setDimensions(this._width, this._height)` on the 301 × 351
  placeholder scaled by the component's placement matrix (0.9833374, 0.9142914)
  → 295.9846 × 320.9163.
* HR axes: x from `getLogTempFromType(70)` = 3.358827 to `getLogTempFromType(0)`
  = 4.7009, mirrored so hot is at the left; y from −5 to 6.
* Region artwork: anchored at (logTemp 4.6021, logLum 6) and scaled by
  `0.3758787878787879 × xAxisScale` and `2.7027027027027026 × yAxisScale`, as in
  `init()`, then clipped to the plot area.

## Quirks of the original that are preserved

* **Absorption, not emission.** `createArrays()` tests `emission_radio.getState()`,
  but no `emission_radio` instance is placed on the stage, so the test is always
  false and every line is drawn black. The port draws black lines and has no
  emission control, matching the original's observable behaviour.
* **Wavelengths are truncated, not rounded.** `drawColorSet` passes
  `parseInt(elementArray[i])`, so 433.9 nm is drawn at 433 nm. The helium line at
  706.5 nm truncates to 706, falls outside the 395–705 nm window, and is clamped
  to 700 nm; the 393.3 and 396.8 nm ionized-metal lines are clamped up to 400 nm.
  All of this is reproduced.
* **Lines below 10 % are not drawn at all** (`if (alphaArray[i] > 10)`).
* **`formatNumber` can print a rounded integer or a fixed-point value**
  depending on the magnitude; both branches are kept, so the distance reads
  `1.70`, `228`, `0.00153` exactly as the original does.
* **Reset does not touch the luminosity-class line thickness directly.** In the
  original, `class5_radio.setValue(true)` calls the radio's change handler, which
  recomputes it; the port resets both explicitly and lands in the same state.

## Deviations from the original, and why

1. **Layout is the KL-UNL shell, not the Flash pixel layout.** The five panels
   keep the original's arrangement — absorption-line plot, simulated spectrum and
   distance modulus stacked on the left, HR diagram spanning the first two rows on
   the right with star attributes beneath it — but they are built from `.panel`,
   `.control-fieldset`, `.control-row` and `.control-choice`, sized in `rem`, and
   they collapse to a single column below the foundation's 56 rem breakpoint.
   Original coordinates survive only inside the three diagrams, where they must.
2. **Text moved out of the artwork.** The curve names, the axis tick labels and
   the HR region names are HTML, positioned over the stage in percentages derived
   from the original coordinates, so they scale with the page and can be typeset
   by MathJax. Nothing that a user reads is baked into a canvas.
3. **Some colours are darkened.** Six curve labels, one HR region label, two of
   the distance-modulus terms and the code-drawn luminosity-class curves
   (`#ff6666`, 2.86:1) failed WCAG 1.4.3 or 1.4.11 at their original values. Each
   was darkened while keeping its hue. The exported artwork itself is untouched.
   Full table in `ACCESSIBILITY.md`.
4. **The cursor's grab area is larger.** The original hit area is a 12 px-wide
   strip; here it is 2.75 rem wide so it meets the 44 px touch-target minimum.
   The snapping maths is unchanged, so the result of a given drag is identical.
5. **A Help button is present although the original had none.** The original's
   `Title Bar` is initialised with `helpLinkageName = ""`, which suppresses Help.
   The shared `contents.json` already ships a curated `spectroparallax` entry with
   Help text, and that entry is used unchanged — adding a Help panel is an
   accessibility gain and the foundation file is not edited.
6. **The apparent magnitude field is a real number input.** The original's slider
   has an editable four-character text field; here it is `<input type="number">`
   with the same range, the same 0.1 step and the same one-decimal formatting, so
   it also gets arrow-key and wheel stepping for free.
7. **`contents.json` needed no edit.** The `spectroparallax` key already existed
   in the shared file with the correct title and version, so the whole
   `foundation/` folder is a byte-for-byte copy — verified with `cmp` for all
   seven files.

## Known cross-browser notes

* The three diagrams use `aspect-ratio`, CSS `grid`, Pointer Events, `<image>`
  inside inline SVG and 2D canvas — all supported in Chrome, Edge, Firefox and
  Safari (desktop and iOS). No vendor-prefixed property is used on its own and no
  Chrome-only API is used.
* MathJax is configured with `svg` output so the contextual menu is available on
  every expression; `\color` and `\class` are deliberately avoided because the
  TeX packages that provide them are not in the local bundle and would trigger a
  network fetch. Colour comes from CSS instead, which MathJax's SVG output picks
  up through `currentColor`.
* Fonts are the foundation's own stack plus generic fallbacks, so nothing depends
  on a font being installed on a particular operating system.
