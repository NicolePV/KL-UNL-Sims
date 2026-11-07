# Conversion notes — Planet Formation Temperatures Plot

Source: `formationTemps002.swf` / `formationTemps002.fla` (ActionScript 1, Flash
6, stage 760 × 560, 12 fps, version string "formationTemps002, 31 August 2009").
Decompiled with JPEXS/FFDec; the ActionScript, exported bitmaps, exported shapes
and static text are the ground truth for behaviour.

## Behaviour model

The simulation shows how hot the solar nebula was at each distance from the Sun,
and therefore which substances could have condensed out of it where. A log–log
plot carries a single straight trend line: the disk temperature falls as a power
law with distance, fixed by two anchor points that the source hard-codes — 600 K
at Earth's 1 AU and 175 K at Jupiter's 5.203 AU. The nine planets are drawn on
that line at their own distances, and rolling over any of them pops up a small
readout giving that planet's distance and formation temperature. One control, a
logarithmic temperature slider with a matching number field, sets a temperature
between 35 K and 1520 K (600 K initially). Moving it slides a red marker circle
along the trend line to the distance where the disk reached that temperature,
and simultaneously slides the boundary in the right-hand panel that separates
substances which are solid at that temperature (above, green) from those still
gaseous (below, blue). Rolling over the marker reads out its temperature and
distance. Nothing animates and there is no timing logic; the whole simulation is
one temperature value and everything drawn from it.

## ActionScript → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `graphClass` (`graph.as`), registered as symbol `graph` | The `GRAPH` constants plus `findX` / `findY` / `findTemp` / `findDist` / `logBaseTen` in `simulation.js`, translated line for line |
| `layoutClass` (`layout.as`), symbol `layout` | `OVERLAY` constants, `findOverlayY()`, `renderBand()` |
| `layoutClass.update()` (the slider's `changeHandler`) | `setTemperature()` → `scheduleRender()` → `render()` |
| `SliderLogicClassV6`, logarithmic + "fixed digits" mode | `snapValue` / `valueFromParameter` / `parameterFromValue` / `incrementValue` |
| `StandardSliderClassV6` (grabber, bar, value field) | A native `<input type="range">` and `<input type="number">`; only the observable behaviour is reproduced, not the Flash component framework |
| `grabberMC.onKeyDown` (`Key.isDown(37/39)` → ±1 tick) | `keydown` on the range input: Arrow Left/Down and Right/Up step ±1 K |
| `valueField.onKeyDown` (Enter) / `onKillFocus` | `keydown` Enter, plus `change` and `blur`, all committing through the same clamp-and-round path |
| `attachMovie("mercury"…"pluto")` + `place()` | `PLANETS[]` drawn with `drawSymbol()`, which reproduces Flash's `_x`/`_y`/`_width`/`_height` scaling about the registration point |
| `createEmptyMovieClip("myLine")`, `lineStyle(3, 0x000000, 70)`, `moveTo`/`lineTo` | The one genuinely code-drawn element: a canvas stroke, same width, colour and 70 % alpha, same two endpoints (0.2 AU and 65 AU) |
| `circle_mc` / `readout_mc` roll-over handlers | `pointerenter` / `pointerleave` **and** `focus` / `blur` on one transparent `<button>` per plotted object |
| `Title Bar` symbol (title, `about` link, its dialog) | `<kl-unl-masthead sim-id="formationtemps">`; no self-built masthead, dialog or Reset |
| `resetHandlerFunc = ""` (the original had no Reset) | The masthead's Reset is wired to `reset()`, which restores the exact initial state (600 K) |
| `onEnterFrame`, `getTimer()`, `updateAfterEvent()` | Not needed — nothing in this simulation animates. The only `onEnterFrame` in the source is the slider bar's click-and-hold repeat (see deviations) |

### Constants carried over verbatim

Axis anchors: `t_pixel_high 0`, `t_pixel_low 300`, `t_high 2000`, `t_low 20`,
`d_pixel_high 350`, `d_pixel_low 0`, `d_high 50`, `d_low 0.1`.
Trend line anchors: `earth_t 600`, `earth_d 1`, `jupiter_t 175`, `jupiter_d 5.203`.
Planet distances (AU): Mercury 0.387, Venus 0.723, Earth 1, Mars 1.524,
Jupiter 5.203, Saturn 9.529, Uranus 19.19, Neptune 30.06, Pluto 39.53.
Symbol sizes passed to `place()` (width × height in stage px): 10×10, 15×15,
15×15, 10×10, 25×25, 30×41, 20×20, 20×20, 8×8, and 40×40 for the marker circle.
Slider: `minValue 35`, `maxValue 1520`, `initValue 600`, `scalingMode
"logarithmic"`, `precisionMode "fixed digits"`, `precision 0`.
Condensation panel: `temp_high 1500`, `temp_low 65`; `pixel_high 38.1786` and
`pixel_low 458.5047` are `metalO_label._y + _height/2` and
`ArNe_label._y + _height/2` evaluated from the symbol geometry in the SWF
(27.6 + 21.157/2 and 447.9 + 21.209/2), which is what `layoutClass()` computes at
run time. The `2.302585092994046` divisor in `logBaseTen` is copied literally.

Substance labels are verbatim: *Metal Oxides (1500 K)*, *Metallic Fe/Ni (1300 K)*,
*Silicates (1200 K)*, *Feldspars (1000 K)*, *Troilite (FeS) (680 K)*,
*Water (175 K)*, *Ammonia (150 K)*, *Methane (120 K)*, *Argon - Neon (65 K)*,
with the region labels *Solid* and *Gas*. Axis titles are verbatim:
*Temperature (Kelvin)* and *Distance from the Sun (AU)*. Readout formatting
matches the source: the marker prints its temperature as the whole-kelvin slider
value and its distance as `Math.round(100 * d) / 100`; a planet prints
`Math.round(findTemp(d))` and its literal distance value.

## Assets: reused as-is versus code-drawn

Reused, copied unchanged out of the JPEXS export into `assets/`:

| File | Was | Used for |
| --- | --- | --- |
| `assets/planets/*.png` | bitmaps 34, 37, 40, 43, 46, 49, 52, 55, 58 (inside shapes 35, 38, 41, 44, 47, 50, 53, 56, 59) | The nine planets, drawn with `ctx.drawImage` at the original position, size and z-order |
| `assets/plot-axes.svg` | shape 70 | Both axes, the eight distance ticks, the five temperature ticks and the break squiggle on the temperature axis |
| `assets/tick-vertical.svg` | shape 87 | The named `pointOne` and `fifty` tick sprites |
| `assets/tick-horizontal.svg` | shape 89 | The named `twoThous` and `twenty` tick sprites |
| `assets/marker-circle.svg` | shape 61 | The red marker circle |
| `assets/solid-band.svg` | shape 110 | The green solid region of the overlay |
| `assets/gas-band.svg` | shape 112 | The blue gas region of the overlay |
| `assets/state-divider.svg` | shape 109 | The red solid/gas boundary line |

Code-drawn, because the ActionScript builds it at run time and no exported file
exists: the trend line (`myLine`).

Two exported shapes were **not** used as files: shape 98 (the condensation
panel's frame) and shape 63 (the readout box). Both are plain rectangles with a
3 px `#c4d5e5` stroke on white, and both have to resize with their content or
with the panel; stretching a stroked SVG distorts the stroke, so they are drawn
as CSS borders with the identical colour and width. Nothing about their
appearance changes.

The bitmap files match their shape bounds pixel for pixel (e.g. shape 35 is
87 × 92 and `earth.png` is 87 × 92), so `drawSymbol()` can place them by scaling
the shape's bounding box about the registration point, exactly as Flash does when
`_width` / `_height` are assigned.

## contents.json

`foundation/contents.json` in this collection is a shared master that is copied
into each simulation's `html5/foundation/` folder (62 identical copies across the
Summer 26 tree). It **already contains** the `formationtemps` entry, so no edit
was needed and the copy here is byte-for-byte identical to every other copy.
`index.html` passes `sim-id="formationtemps"`.

That existing entry titles the simulation *Planet Formation Temperatures
Explorer* (the Flash title bar read *Planet Formation Temperatures Plot*) and
supplies Help text, so the masthead shows a Help button that the original did not
have (`helpLinkageName` was `""`). Both come from the shared file, which is not
this simulation's to change; flagged here rather than edited.

## Deviations from the original

**Presentation (required by the accessibility rules, priority 2 over layout).**

1. **Chrome and palette.** The Flash title bar, its `about` dialog and the
   1990s panel styling are replaced by the KL-UNL masthead and palette. The
   original's colours are kept where they carry meaning (the green solid band,
   the blue gas band, the red boundary, the `#46576d` substance labels, the
   `#c4d5e5` frames). Two text colours are darkened for contrast: the rotated
   *Solid* label from `#009900` to `#006600` and *Gas* from `#47adde` to
   `#005a9c` — both fell below 4.5:1 on their own translucent bands. The band
   fills and the boundary line are the exported artwork, unchanged.

2. **Text is never painted on the canvas.** Tick values, axis titles, substance
   labels and the roll-over readout are HTML positioned over the canvas, so they
   zoom with the page and can be typeset by MathJax (which canvas text cannot).
   The canvas keeps the original graph coordinate system and is scaled by CSS.

3. **Substance label positions.** In the original the four coldest labels
   (175 K, 150 K, 120 K, 65 K) are hand-placed about 10 px apart at 12 px type and
   their boxes overlap; the label centres are also a few kelvin off their stated
   temperatures. Here each substance has a tick on a rail at the *exact*
   temperature position given by the same linear map the boundary line uses, and
   the label is nudged clear of its neighbours only as far as the minimum
   readable spacing demands (at most about 8 px at the default size), with a
   leader joining the label to its tick. The boundary line and the ticks are
   therefore always unambiguous about which side a substance is on. The panel's
   *minimum* height is set in `rem`, so labels and panel scale together and can
   never collide at any browser font size; above that floor the panel grows to
   match the height of the plot panel beside it, and `simulation.js` re-lays the
   labels out (via a `ResizeObserver`) whenever it does.

4. **Tick label alignment.** The original's axis labels sit about 7 px to the
   right of their ticks (hand placement). Here they are centred on the tick
   (x axis) and right-aligned to a shared column (y axis).

5. **Roll-over readouts have a keyboard and touch path.** Each of the nine
   planets and the marker is a real focusable `<button>`, so the readout appears
   on focus as well as hover and its values are also in the button's accessible
   name. The original was hover-only.

6. **Reset.** The original had no Reset (`resetHandlerFunc = ""`). The KL-UNL
   masthead provides one; it restores 600 K and clears the readout.

**Behaviour (small, and only where the platform differs).**

7. **Slider track clicks.** The Flash bar stepped one tick per click and then,
   after a 500 ms delay, ramped toward the click position at
   `continuousChangeRate 0.05` ticks/ms. A native `<input type="range">` jumps
   straight to the clicked position. The value maths is identical; only the way
   a track click gets there differs. Dragging behaves the same as the original
   (log position in, whole kelvins out).

8. **Slider keyboard range.** The Flash grabber responded to Left and Right only
   (`Key.isDown(37/39)`), one whole kelvin each. That is preserved, and Up/Down
   are added as synonyms, with Page Up / Page Down (±50 K) and Home / End
   (35 K / 1520 K) — required by the accessibility rules, and additive.

9. **Slider parameter space.** The Flash slider's parameter was a pixel
   position on its own bar. Here it is a 0–1000 range, mapped through the same
   `exp`/`log` formulas. This changes only the granularity of a mouse drag, not
   any value the simulation produces.

10. **Number field.** `maxChars 5` and `restrict "0-9.Ee+-"` become
    `<input type="number">` with `min="35" max="1520" step="1"`, which enforces
    the same bounds and rejects the same characters. As in the original, typing
    commits on Enter or on leaving the field, not on every keystroke.

**Layout (priority 3, replicated as far as the shell allows).**

The screenshot's arrangement is kept. There are two panels, side by side and the
same height, as in the original: on the left the plot with the temperature
control inside the same box directly beneath it, on the right the condensation
temperatures as a tall narrow strip. The condensation panel's band grows above
its `rem` floor to whatever height the left panel settles on, which is what keeps
the two boxes level. Below the KL-UNL 56 rem breakpoint the two panels stack in
reading order and each takes its natural height. The original's fixed 760 × 560
pixel stage, its fonts and its panel chrome are not reproduced.

## Cross-browser notes

Everything used here is standards-based and supported in Chrome, Edge, Firefox
and Safari (desktop and iOS): `aspect-ratio` (Safari 15), CSS container query
units (Safari 16), Pointer Events, `<input type="range">` and `type="number"`,
inline SVG and `drawImage` of an SVG that carries intrinsic dimensions. No
vendor-prefixed property appears on its own. Container query units are wrapped in
an `@supports` guard, with width breakpoints as the fallback, so an engine
without them still gets a sensible label size. MathJax is the bundled `tex-svg`
build, which renders identically across engines and keeps its context menu.
