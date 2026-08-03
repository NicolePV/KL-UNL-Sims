# Conversion Notes — Gas Retention Plot

## Behavior model (one paragraph)

The Gas Retention Plot is a **static log-log plot** of molecular speed
(0.5–100 km/s, vertical) versus temperature (30–1000 K, horizontal). It teaches
which gases a body can gravitationally retain: a body retains a gas
indefinitely when its escape speed exceeds 10× the gas's average molecular
speed, and quickly loses it below 6×. The user (a) checks gases in the **Gases**
panel — each adds a dashed "10×V<sub>avg</sub>" line and a shaded retention
region (solid above the 10× line, fading through the 6×–10× band); (b) checks
categories in **Plot Options** to show labelled dots for solar-system bodies;
and (c) manipulates a single red **custom-object** dot, either by dragging it in
the plot or via the **Custom Object Properties** sliders (temperature, radius,
density). Radius and density together set the escape speed
(`v = radius·0.0007477·√density`); temperature sets the x-position and implies a
distance from the Sun. Dragging the dot within 8 px of a shown body snaps it onto
that body and copies the body's radius and density (the body's label turns red).
Nothing animates; the view re-renders on each interaction.

## Ground truth

- **Behavior**: the decompiled ActionScript — `Gas Retention Plot.as`,
  `GRP Object.as`, `GRP Gas.as`, `Number Functions.as`,
  `Slider Logic Class v6.as`, `Standard Slider v6.as`, and
  `frame_1/DoAction*.as` plus the `on(initialize)` clip records.
- **Layout reference**: `../Capture.PNG` (a screenshot of the running Flash
  version). Note this screenshot shows a *used* state (several gases/categories
  checked); see "Initial state" below.

## Initial state (important)

The AS calls `onResetClicked()` at the end of setup, and `FCheckBox.setValue()`
**does** fire its change handler (`FCheckBoxSymbol.as` line 203). Therefore the
true initial state is: **all nine gas checkboxes and all three category
checkboxes are UNCHECKED** — only the red draggable dot is shown, at
temperature 70 K, radius 600 km, density 5.0 g/cm³, escape speed ≈ 1.0 km/s.
The `Capture.PNG` screenshot is a later, interacted state, not the load state.
This port reproduces the code's initial state, matching the screenshot only for
panel structure and layout.

## Constants / formulas copied verbatim

| Quantity | Source | Value / formula |
|---|---|---|
| Plot ranges | PlaceObject init | temp 30–1000 K, speed 0.5–100 km/s |
| log base | AS | `Math.log(x)/2.302585092994046` |
| Object escape speed | DoAction.as | `mass = ρ·1000·(r·1000)³·4π/3`, `v = √(1.3346e-10·mass/(r·1000))/1000` |
| Slider escape speed | DoAction_3.as | `v = r·0.0007477·√ρ` (and its inverses) |
| Mass readout | updateMassInfo | `ρ·1.3333333333333333·π·(1000r)³·100³/1000` kg |
| Distance readout | updateDistanceInfo | `(278.8/T)²` AU |
| V<sub>avg</sub> (per gas) | GRP Gas.update | `√(3·1.3806503e-23·T/(mass·1.66053886e-27))/1000` km/s; lines at 6× and 10× |
| Dashed line | GRP Gas | grey `#909090`, width 2, dash 4 / gap 8 |
| Snap distance | userObject.onMouseMove | 8 stage px |
| Sci-notation / toFixed / formatNumber | Number Functions.as | ported exactly |
| Sig-digit slider snapping | Slider Logic Class v6 | ported exactly (temp 2, density 2, radius 3 sig figs, log scaling) |

All on-screen strings ("an object with this radius and density would have…",
"this temperature would be associated with an object about … AU from the sun",
gas names, `N u`, axis titles) are verbatim from the source. The original
British/US spelling "**terrestial**" in "show terrestial planets" is preserved.

## AS → HTML5 mapping

| ActionScript | HTML5 port |
|---|---|
| `GasRetentionPlotClass` (code-drawn plot, ticks, border) | `<canvas>` 2D drawing in `drawCanvas()` |
| `GRP Gas` shading + dashed lines (masked to plot rect) | `drawGas()`, clipped with `ctx.clip()` |
| `GRP Object` grey dots + labels; red draggable userObject | `drawPlanet()` / `drawUserDot()` |
| `Standard Slider v6` + `Slider Logic Class v6` | `SigSlider` (native `<input type=range>` + editable text field) |
| `FCheckBoxSymbol` | native `<input type=checkbox>` |
| Title bar + reset/help/about + About dialog | `<kl-unl-masthead>` (foundation component) |
| `displayText()` sub/superscript engine | MathJax (LaTeX in HTML overlays) |
| `onEnterFrame` / `getTimer()` | not needed — the sim has no animation |
| Axis titles, tick numbers, gas-line labels (canvas text in Flash) | HTML overlays, MathJax-typeset, positioned by % of the stage |

## contents.json entry

The shared `foundation/contents.json` **already contains** the `gasRetentionPlot`
entry (meta + Help + About, derived from the original Help/About text), so no new
entry needed to be added for this sim.

### ⚠️ Required JSON syntax repairs to `foundation/contents.json` (please forward upstream)

The delivered `foundation/contents.json` is **invalid JSON** — `JSON.parse` throws
on it, which means the KL-UNL masthead's `fetch(...).json()` fails and the
title/Help/About bar comes up empty **for every simulation that uses this file**,
not just this one. To make the deliverable functional I had to repair the copied
`html5/foundation/contents.json` (this is the one foundation file the pipeline
permits editing). The fixes are **syntax only and change no visible text**:

1. `ce_hc` → help: a stray literal newline before the closing quote of the
   `content` string (`…animated.</p>⏎"`). Joined onto one line.
2. `eclipsingbinarysim` → help: a literal newline inside the string
   (`…These data were⏎ provided by…`). Joined.
3. Two other entries (`sun`/blackbody and a rotating-sky help block): the same
   `…</p>⏎"` stray-newline pattern. Joined.
4. `venusphases` and `ptolemaic` → help: unescaped double quotes inside an
   `<a href="…">` (`href="../venusphases"` and `href="../ptolemaic"`), which
   prematurely terminate the JSON string. Escaped to `href=\"…\"`.
5. One remaining literal TAB inside a `<p>\t…` string was replaced with a space
   by a control-character sweep restricted to *inside* JSON string values.

After these repairs the file parses cleanly (108 sim entries) and the masthead
loads. **These are pre-existing defects in the shared foundation file, not a
result of this conversion** — the upstream `contents.json` should be corrected so
every sim using it works. This copy's `gasRetentionPlot` entry itself was already
valid and is unchanged.

Otherwise the foundation `.js`/`.css` files are copied in byte-for-byte unchanged.

## Assets reused vs. code-drawn

Nothing needed reuse: `images/` is empty, and the exported `shapes/*.svg` are all
Flash UI chrome (sliders, checkboxes, scrollbars, panel backgrounds, title bar)
which are replaced by native KL-UNL controls. The entire plot (background,
shading gradients, dashed lines, dots, ticks, border) is genuinely code-drawn in
the AS and is reproduced on the canvas. The self-hosted Verdana fonts in
`../fonts/` are not shipped; the canvas planet labels fall back to
`Verdana, Geneva, sans-serif` so text renders consistently across OSes.

## Deviations from the original (and why)

1. **Layout is KL-UNL, not the Flash pixel layout** (required by the pipeline).
   Panel grouping and reading order match the screenshot: wide plot on the left;
   Gases and Plot Options stacked on the right; Custom Object Properties full
   width below. Below 56 rem everything collapses to a single column.
2. **Absolute plot pixel size approximated.** The decompiled AS does not contain
   the stage placement matrix for the plot symbol, so `PLOT_W`/`PLOT_H`
   (632×688) and the margins were chosen from the screenshot's proportions. This
   affects only pixel-level feel (e.g. the 8 px snap radius); **all physics and
   the log-scaling are dimension-independent** (position fractions cancel the
   absolute size), so plotted positions are exact.
3. **Gas shading uses uniform fills, not the original gradient** (per supervisor
   feedback that the faded left edge was undesirable). Each gas fills its fully-
   retained region (above the 10× line) at ~20% opacity and its 6×–10× transition
   band at a lighter, *uniform* ~12% opacity, with the dashed 10× line still
   marking the boundary. The Flash original used a `beginGradientFill` that faded
   toward the 6× line; this is a presentational change only — the band boundaries
   (6× and 10×) and all physics are unchanged.
4. **Editable value fields kept.** Like the Flash sliders, each custom-object
   slider has an editable numeric field; typing a value and pressing Enter (or
   blurring) commits it with the same clamping/snapping and coupling logic.
5. **Snapped-body cue is not colour-only.** The Flash only turns the body's label
   red. For accessibility this port additionally draws a ring around the snapped
   dot, bolds the label, and announces the snap in the live region.
6. **No Pause / reduced-motion handling needed** — the simulation has no
   continuous motion.

## Cross-browser notes

Uses only broadly supported APIs (Canvas 2D, Pointer Events, CSS grid,
`aspect-ratio`). MathJax uses SVG output (no web-font files) so math renders
identically on Chrome, Edge, Firefox, and Safari (desktop + iOS). `touch-action:
none` on the canvas makes dragging work on iOS Safari without scrolling the page.
