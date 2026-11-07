# Conversion Notes — Pulsar Period Simulator

## Behavior model

A pulsar emits regular pulses (every `pulsePeriod` = 250 ms of sim time)
that travel outward at a fixed speed (`pulseSpeed` = 0.1 stage-units/ms)
until they reach a fixed observer, "earth". In **stationary** mode the
pulsar sits at a fixed point, so every pulse travels the same distance and
arrives at exactly 250 ms intervals — the interval plot on the right is
flat. In **circular** mode the pulsar instead orbits a fixed center (radius
100, period 12000 ms of sim time), representing its orbit around the
pulsar–planet system's common center of mass; because its distance to earth
now varies over the orbit, the light-travel time to earth varies too, so
the interval between pulse *arrivals* at earth oscillates sinusoidally even
though the pulsar's own emission rate never changes. This is the real
technique (pulsar timing) used to discover the first confirmed exoplanets.
An optional color-coding mode tints each pulse/orbit position red or blue
depending on whether the pulsar is receding from or approaching earth at
the moment of emission. A speed slider scales simulation time relative to
real elapsed time (`Math.exp(sliderValue)`), and a run/pause button plus a
reset (via the KL-UNL masthead) control the animation.

## Source

- `scripts/pulsarPeriodSim001_fla/MainTimeline.as` — main controller (frame
  script, orbit/pulse physics, drawing, UI wiring)
- `scripts/Pulsar.as` — pulsar dot symbol class
- `scripts/IntervalsPlot.as` — the interval-vs-time scatter plot

**Note:** this collection's source is decompiled **AS3** (class-based,
`fl.controls.*` UI components), not the AS1/`Object.registerClass` idiom
this prompt template otherwise describes. The same translation principles
apply directly (`Shape.graphics.*` → canvas 2D, `getTimer()` →
`performance.now()`, `onEnterFrame`/`addEventListener` → one
`requestAnimationFrame` loop, `fl.controls` components → native HTML
controls per the "do not port the component framework" rule), so no
architectural change was needed.

## AS → HTML5 mapping

| AS3 | HTML5 |
|---|---|
| `MainTimeline` (frame script + methods) | `simulation.js` state object + `update*()`/`render()` |
| `Pulsar` (MovieClip symbol) | `state.pulsar` position, drawn via `assets/pulsar-dot.svg` |
| `IntervalsPlot` (Sprite subclass) | `IntervalsPlot` class in `simulation.js` (same constructor args, `addData`/`update`/`clearData`) |
| `grayOrbit` / `coloredOrbit` (Shape, drawn via `drawArc`/`lineTo`) | Precomputed once into two offscreen `<canvas>` layers (`buildOrbitLayers()`), then composited each frame — geometry is static, so this avoids redrawing 600 line segments every frame |
| `pulses` (Shape, redrawn every frame in `drawPulses()`) | `render()` recomputes dash positions from `state.pulseList` each frame |
| `fl.controls.RadioButton` × 2 (`motionModeRadioGroup`) | native `<input type="radio" name="motionMode">` × 2 |
| `fl.controls.Button` (`animationButton`) | native `<button id="pauseButton">` |
| `fl.controls.Slider` (`speedSlider`, min -2, max 1.1, step 0.01, default -0.4) | native `<input type="range" min="-2" max="1.1" step="0.01" value="-0.4">` |
| `fl.controls.CheckBox` (`colorCheckBox`) | native `<input type="checkbox">` |
| Button/CheckBox/RadioButton/Slider *skin* symbols (`Button_upSkin`, `SliderThumb_*Skin`, `RadioButton_*Icon`, `focusRectSkin`, `fl.core.ComponentShim`, …) | not reproduced — replaced by native control chrome per the "do not port the Flash component framework" rule |
| `earth` (MovieClip, position set only via the FLA timeline, never in AS) | fixed constant `EARTH_X=822, EARTH_Y=526`; the original's `(864, 568)` was measured from `frames/1.png` (the exact 900×600 stage render, since no `.fla` is available), then nudged up/left at the user's request so it no longer touches the bottom-right corner — see deviation #7 |
| Text assets `texts/76,79,80,81,83,84,85.txt` | reused verbatim as: "earth", the pulsar description paragraph, "Time", "Interval Between Pulse Arrivals" (4-line heading), font name (unused — see Fonts below), "pulsar motion:", "speed:" |

## Assets reused as-is

- `shapes/72.svg` (12×12 radial-gradient circle, `#d0e1fb`→`#9fa7e8`) — the
  pulsar's dot symbol (`DefineSprite_73_Pulsar`) — copied to
  `assets/pulsar-dot.svg`, composited with `ctx.drawImage` every frame since
  it moves and must layer with the canvas-drawn pulse trail.
- `shapes/74.svg` (8×8 solid `#0066ff` circle) — earth's dot
  (`DefineSprite_77`, paired with the static "earth" text) — copied to
  `assets/earth-dot.svg`, also drawn via `ctx.drawImage` so it lines up
  pixel-exactly with the canvas-drawn dashed pulse line that terminates on
  it.
- All other exported shapes/sprites (`Button_*Skin`, `CheckBox_*Icon`,
  `RadioButton_*Icon`, `SliderThumb_*Skin`, `SliderTrack_*Skin`,
  `SliderTick_skin`, `focusRectSkin`, `fl.core.ComponentShim`) are Flash UI
  component chrome, intentionally not reused (see table above).

## Code-drawn geometry (reproduced on canvas, no exported file exists)

- Gray orbit ring (`grayOrbit.graphics.drawCircle`)
- Color-coded orbit ring, 600 line segments (`coloredOrbit` loop in
  `drawOrbit()`) — reproduces the exact per-segment red/blue tint formula
- Pulse dash marks (`pulses.graphics` in `drawPulses()`)
- Interval plot background, border, and data dots (`IntervalsPlot`'s
  `Graphics` calls)

## Fonts

The source embeds Verdana (`fonts/75_Verdana.ttf` etc., used only to skin
the Flash UI components being replaced — see above). Per hard rule 13,
type relies on the foundation's system-font stack rather than an embedded
OS-licensed font; no sim-specific font was carried over.

## Deviations from the literal AS source

1. **Pulsar drag/rotation code is dead and was not reproduced.**
   `Pulsar.as` defines `onMouseDownFunc`/`onMouseMoveFunc`/`onMouseUpFunc`
   (drag-to-move) and `onEnterFrameFunc` (`rotation += 16`), but nothing in
   the decompiled source ever calls `addEventListener` to wire these up on
   the `pulsar` instance — confirmed by searching every `.as` file. The
   pulsar is therefore never draggable or self-rotating in the original's
   actual observable behavior, so the HTML5 port reproduces only the
   AS-driven orbital motion and does not add dragging or independent
   rotation.
2. **`contents.json` already contained this sim's entry — but the shared
   master file did not parse as JSON.** The linked `foundation/contents.json`
   (a large, shared master file covering ~100 sims) already had a
   `"pulsarPeriodSim001"` entry with `meta.title` and verbatim-derived
   Help/About text, so per the "one permitted contents edit" rule no new
   entry needed to be *added*. However, three **pre-existing data bugs**
   elsewhere in that shared file (unrelated to this sim's own entry) made
   the whole file invalid JSON, which breaks `<kl-unl-masthead>` for every
   sim that shares it, including this one (`fetch` succeeds but
   `JSON.parse` throws, so the masthead silently renders empty — no title,
   no Reset/Help/About):
   - `"ce_hc"` entry's help `content`: a literal, unescaped newline inside
     the JSON string (raw control character — invalid per the JSON spec).
   - `"venusphases"` (approx.) and a Ptolemaic-comparison entry: literal
     `<a href="...">` quotes inside a JSON string were not escaped as
     `\"..\"`, unlike every other entry's links.
   These were fixed *only in this project's copied* `html5/foundation/
   contents.json` (the file this rule explicitly permits editing), by
   escaping the offending characters — no wording was changed, only
   invalid syntax was corrected, and the fix was verified by parsing the
   file with the browser's own `JSON.parse`. **The original
   `foundation/contents.json` at the project root (the shared master copy)
   was left untouched**, since fixing it is out of scope here; the same
   three bugs should be corrected there too so every other sim sharing that
   master file isn't also silently broken. Separately, note the existing
   `"pulsarPeriodSim001"` entry sits out of alphabetical order in the
   master file (between `renaissancePtolemaic` and `radecdemo`); this
   preexisting ordering issue was left untouched as out of scope.
   - **About text updated to the Apache 2.0 license (user request).** In
     this project's copied `contents.json`, the `about` content's closing
     sentence — the old "Permission is granted … noncommercial purposes …
     unmodified" boilerplate — was replaced with the Apache License 2.0
     block (copyright line, license grant, the license URL as a link, and
     the AS-IS disclaimer). The standard NSF funding line (grants #0231270
     / #0404988), which this entry had been missing, was added to match the
     sibling entries and the reference layout, and the previously unclosed
     `<a>` around "Nebraska Astronomy Applet Project" was closed so only
     that phrase links to astro.unl.edu. Confined to `html5/foundation/
     contents.json`; the shared master copy is untouched.
3. **No MathJax.** The original UI has no formulas, symbols, Greek letters,
   or unit-bearing numeric readouts anywhere (confirmed: no `TextField`
   creation, no `toFixed`/scientific-notation formatting in the source).
   `klunlInitEqn()` is therefore left at the foundation's no-op default and
   no MathJax script is loaded, avoiding an unnecessary external/CDN
   dependency the hard rules otherwise forbid.
4. **Layout: compact single box with controls overlaid on the stage.** The
   original (`Capture.PNG`) is one box — the orbit top-left, the plot
   top-right, and the controls (pulsar-motion radios / pause+speed / color
   checkbox / description paragraph) tucked into the lower-left, over the
   empty stage area. This port reproduces that: a single `.panel` holds the
   `<canvas>` with the control cluster absolutely positioned in the stage's
   lower-left (`.stage-controls`, at ~2.5%/63% of the scaling stage, measured
   against the original cluster's stage coords x 26-408, y 390-573). The
   lower-left stays clear of graphics: the orbit is top-left, the plot
   top-right, and the pulse trail runs from the orbit down to earth
   (bottom-right), passing above/right of the cluster (verified: zero pulse
   pixels render behind the controls even with a full circular-mode trail).
   The controls remain native semantic elements (real `<fieldset>`/radio/
   button/range/checkbox), so keyboard and screen-reader access are
   unaffected and tab order follows DOM order. For accessibility priority
   over visual fidelity, below the foundation's 56rem breakpoint (narrow /
   phone-portrait, and equivalently at high browser zoom) the overlay drops
   to `position: static` and the controls reflow into a normal stacked block
   below the canvas, so nothing clips or overlaps. The per-panel diagram
   heading is present but `.sr-only` (the original box has no visible
   heading), keeping the compact look while preserving heading structure.
5. **Reduced motion**: see ACCESSIBILITY.md — the animation does not
   auto-start when the user has requested reduced motion, even though the
   original always starts running.
6. **Speed slider spoken value.** The original has no numeric speed
   readout at all. For accessibility (hard rule: always speak a value's
   quantity + unit), the native range control's `aria-valuetext` reports
   the effective rate multiplier (`e^sliderValue`, e.g. "Speed 0.67 times
   normal rate") — new, necessary text with no verbatim source equivalent.
7. **Earth nudged off the corner.** The original earth marker sits at stage
   `(864, 568)` — 96% / 95% of the way to the bottom-right corner. At the
   user's request it was moved up and left to `(822, 526)` so it no longer
   touches the corner, with the "earth" label following it. Because earth's
   position is a physics input (it defines the observer sight-line that
   drives pulse colours and the amplitude/phase of the pulse-arrival
   interval variation), this is a small **intentional geometry deviation**,
   not a pure presentation change: the light-travel distance and the
   red/blue tint mapping shift slightly. The qualitative behaviour — flat
   intervals when stationary, sinusoidally varying intervals when orbiting —
   is unchanged, and no plot scaling constants depend on earth's position
   (`minDelta`/`maxDelta` derive only from `pulsePeriod` and the
   pulsar/pulse speed ratio).
