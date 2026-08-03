# Synodic Lag Demonstrator — conversion notes

Source: `synodiclag.swf` (Adobe Flash, SWF version 6, ActionScript 1, 300 × 400
stage, 60 fps). Decompiled with JPEXS/FFDec; the decompiled ActionScript is the
ground truth for behaviour, the KL-UNL foundation files and the accessibility
rules are the ground truth for presentation.

## Behaviour model

Earth orbits the Sun counter-clockwise on a fixed circle while spinning
counter-clockwise on its axis, and a long tick mark on the Earth symbol marks the
local meridian — the side experiencing noon when it points at the Sun. The user
picks a **length of day** (24, 240 or 1200 hours), then presses **one sidereal
day** (run until Earth has spun exactly 360° with respect to the stars) or **one
solar day** (run until Earth has spun 360° *relative to the Sun direction*).
Because Earth also moves along its orbit during the run, the sidereal day ends
with the meridian marker short of noon by exactly the angle Earth swept along its
orbit — that gap, the synodic lag, is what the **angle to noon** readout reports.
The solar day always ends back at the same angle it started from. **realign to
noon** snaps the spin so the marker faces the Sun again without losing the whole
rotations already completed, a translucent **shadow** copy of Earth marks where
it stood when the run began, and the **animation** radios pick a fast or slow
playback rate. Exaggerating the length of day to 240 or 1200 hours makes the lag
large enough to see; at a realistic 24 hours it is under one degree.

## ActionScript → HTML5 mapping

| ActionScript (frame 1 script) | HTML5 port (`simulation.js`) |
| --- | --- |
| `var x0=150, y0=150, r0=125` | `X0`, `Y0`, `R0` — original stage coordinates, unchanged |
| `var year = 8766.15271` | `YEAR` — hours in a year, verbatim |
| `setposition(obj, theta)` | `setPosition(thetaDeg)`; keeps the negated sine (`y = -r·sin θ + y0`) so the orbit runs counter-clockwise on a y-down screen |
| `update(time)` | `update(t)`; `revRate = 360`, `spinRate = 360·year/day`, and the same two clamp-and-stop branches for mode 1 / mode 2 |
| `updatetext()` | `angleToNoon()` — `phi % 360 − theta % 360`, wrapped into `[0, 360)` |
| `onEnterFrameFunc()` + `getTimer()` | one `requestAnimationFrame` loop + `performance.now()`; identical `(now − timeLast)/1000/50/delay` elapsed-time formula, so a run takes the same number of seconds on any machine |
| `animateSidereal()` / `animateSynodic()` | `startAnimation(MODE_SIDEREAL / MODE_SYNODIC)` |
| `stopAnimation()` | `stopAnimation()` — carries `theta`/`phi` into `theta0`/`phi0` |
| `toggleNoon()` | `toggleNoon()` — `phi0 = theta0 + floor(phi0/360)·360`, verbatim |
| `showShadow()` | `shadow` checkbox → `state.shadow`, applied in `render()` |
| `disableButtons()` / `enableButtons()` | same three push buttons plus the length-of-day `<fieldset disabled>`; the speed radios and the shadow checkbox deliberately stay live during a run, as in the original |
| `earth.duplicateMovieClip("earthShadow", 50)`, `_alpha = 25` | `state.shadowX/Y/Rot` drawn at `globalAlpha = 0.25`, at SWF depth order |
| `Number.prototype.toFixed` polyfill (in `toFixed.as`) | `asToFixed()` — the SWF ships its own polyfill because AS1 has none, so it is reproduced exactly rather than delegating to JS `toFixed`, keeping rounding identical at `.005` ties |
| `_rotation` (degrees, clockwise on screen) | `ctx.rotate(deg · π/180)` — canvas rotates clockwise for positive angles too, so `-theta` / `-phi` carry over unchanged |
| `FPushButton` / `FRadioButton` / `FCheckBox` (`FUIComponent` framework) | not ported; only the observable behaviour is reproduced, using native `<button>`, `<input type="radio">` and `<input type="checkbox">` |
| `trace()`, `updateAfterEvent()`, `_root`/`_parent` chains | dropped / no-ops / explicit references |

One AS1 detail worth recording: `init()` calls `update()` with **no argument**.
The SWF targets Flash 6, where a missing argument coerces to `0` in numeric
context, so the simulation opens at `theta = phi = 0` (readout `0.00°`) rather
than `NaN`. The port sets `time = 0` explicitly to the same effect.

## Verification

`simulation.js` was driven headlessly against a stub DOM with a controllable
clock and checked against an independent transcription of the AS1 maths — 23
assertions, all passing, covering: the opening readout; sidereal and solar runs
at 24, 240 and 1200 hours; the analytically-derived end values (`359.01°` for a
24-hour sidereal day, `310.72°` for 1200 hours, `0.00°` for every solar day);
control enable/disable during a run; realign-to-noon; reset; and pause/resume
leaving the end state unchanged. Canvas output was verified by sampling pixels in
the browser at both 1× and 2× device pixel ratio: Sun `#f8eb56` at (150, 150),
Earth `#0066ff` at (275, 150), the orbit ring at radius 125 and the Sun-to-Earth
line all land on their original stage coordinates.

## Assets: reused vs. code-drawn

Every visual element in this simulation is an **exported vector shape**; there is
no runtime `createEmptyMovieClip`/`drawArc` art at all, so nothing was redrawn by
hand. All four SVGs are copied from the JPEXS export into `assets/shapes/` and
composited onto the canvas with `drawImage` at their original placements:

| File | Symbol | Placement in the SWF |
| --- | --- | --- |
| `101.svg` | orbit path | (150.4, 150), scaled 1.2503 × 1.2500 → radius 125 |
| `105.svg` | Sun-to-Earth line | (150, 150), scaled 0.88461 in x, rotated `-theta` |
| `91.svg` | Sun | (150, 150) |
| `99.svg` | Earth (disc, three ticks, meridian marker) | orbital position, rotated `-phi` |

Each shape's registration point is the offset FFDec baked into the SVG's own
`<g transform>`; those offsets are recorded in the `ART` table in
`simulation.js`. Draw order follows the SWF depths: orbit (1), line (12),
earth shadow (50), Sun (59), Earth (100). There were no bitmaps in the export
(`images/` is empty) and no sim-specific fonts.

## `contents.json`

**No edit was required.** `foundation/contents.json` already contains a
`synodiclag` entry (title *Synodic Lag Demonstrator*, version 2.0, Help and About
text). The whole `foundation/` folder is therefore copied in byte-for-byte
unchanged — verified with a recursive diff against the source folder — and
`index.html` passes `sim-id="synodiclag"` and
`json-url="foundation/contents.json"`.

## Deviations from the original

1. **Pause button added.** A 1200-hour run at the *slow* setting lasts about 68
   seconds. WCAG 2.2.2 requires the user to be able to stop motion that runs
   longer than five seconds, and the original offers no way to interrupt a run.
   Pause only suspends the clock; no state or physics is altered, and a paused
   run resumes to exactly the same end state (covered by the test harness).
2. **Reduced motion.** With `prefers-reduced-motion: reduce`, pressing a run
   button jumps straight to the end state instead of animating. The physics is
   untouched — `update()` clamps the time to the end of the run exactly as it
   would have on the final animated frame — and the Pause button is hidden
   because there is no longer any motion to pause.
3. **Layout (Goal C).** The panel grouping and reading order of the original are
   preserved — orbit diagram first, then the *actions* / *length of day* /
   *animation* control groups side by side, in the original left-to-right order —
   but expressed with the KL-UNL classes rather than the Flash 300 × 400 pixel
   layout, palette and fonts. The **angle to noon** readout is kept in its
   original position, centred just below the Sun and inside the orbit circle, but
   it is real HTML overlaid on the canvas rather than canvas-painted text, so it
   zooms with the page and the degree symbol can be typeset by MathJax.
4. **Panel headings added.** The original has no panel titles; *Orbit Diagram*
   and *Controls* were added because the accessibility rules require a correct,
   non-skipping heading hierarchy. All control labels are verbatim from the
   ActionScript (`one sidereal day`, `one solar day`, `realign to noon`,
   `length of day`, `24 hours`, `240 hours`, `1200 hours`, `animation`, `fast`,
   `slow`, `shadow`, `angle to noon`), including their original lower-casing.
5. **A short explanatory sentence** was added below the controls describing the
   shadow and the sidereal/solar distinction. It is new text, not a paraphrase of
   anything in the source, and it changes no behaviour.

## Two foundation constraints worked around from outside

The foundation files are never edited; both of these are handled additively in
`styles/styles.css`.

1. **Masthead overflow on phones.** The masthead renders its title and three
   buttons as a single non-wrapping flex row inside its own shadow DOM, which
   needs roughly 25rem. Below that it would push the whole *page* into horizontal
   scrolling. The overflow is contained on the host element instead
   (`kl-unl-masthead { overflow-x: auto }` below 25rem), so the simulation content
   stays fully reflowed and only the masthead itself scrolls. `showModal()` puts
   the Help/About dialog in the top layer, so the dialog is not clipped by that
   scroll container.
2. **Fixed 25rem diagram column at high zoom.** `.app-layout` sizes the left
   column at a flat `25rem`, which at 200% zoom is most of the viewport and
   squeezes the controls until they overflow. On our own `.sim-layout` class the
   track is capped at `min(25rem, 45%)` above the foundation breakpoint — the
   same 400px column at default zoom, but able to give ground as text grows. The
   foundation's own `@media (max-width: 56rem)` collapse to a single column is
   left intact.

Separately, `kl-unl.css` contains a stray `u` character between the
`.app-layout__left` and `.app-layout__right` rules, which makes
`.app-layout__right` parse as `u .app-layout__right` and never match. That file
is not edited; the `min-width: 0` it was meant to supply is restated on this
sim's own class.

## Cross-browser notes

Everything used here is standards-based and supported in current Chrome, Edge,
Firefox and Safari on desktop and iOS: `aspect-ratio`, CSS grid/flex `gap`,
`min()`/`max()`, container queries (`cqw`, behind an `@supports` guard with a rem
fallback), `<fieldset disabled>`, Pointer-free native controls, `<dialog>` (used
by the foundation masthead) and MathJax. No vendor-prefix-only declarations and
no Chrome-only APIs.

Two things to be aware of:

* **SVG rasterisation on canvas.** The exported shapes are drawn with
  `drawImage` from `<img>` elements holding SVG files. Browsers re-rasterise SVG
  images at the destination scale, which was confirmed in-browser at
  `devicePixelRatio` 2 (the orbit stroke samples at genuinely higher resolution
  rather than as an upscaled 1× bitmap). Older WebKit builds that rasterise at
  intrinsic size would show slight softness on the 1-pixel orbit and Sun-Earth
  lines; nothing else is affected.
* **Background-tab runs.** `requestAnimationFrame` is suspended in a hidden tab,
  so a run started and then backgrounded resumes with a large elapsed time and
  lands immediately on its end state. This matches the original's wall-clock
  (`getTimer()`) behaviour, and `update()` clamps to the correct end state either
  way.
