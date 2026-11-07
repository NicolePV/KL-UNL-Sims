# Conversion Notes — Eclipse Shadow Simulator

## Behavior model (one paragraph)

The stage (900×500) holds a fixed **Sun** at (54, 250) and two **draggable discs**,
**Earth** and **Moon**. Each disc casts a shadow *away from the Sun*: a dark, opaque
**umbra** cone that converges to a point, and a faint, translucent **penumbra** that
spreads outward past that point (with a thin **antumbra** outline beyond the umbra
tip). Dragging a disc recomputes and redraws only that disc's shadow in real time.
Discs cannot be dropped onto (or too close to) the Sun and are clamped to the stage.
There is no animation, timeline, sound, scoring, or on-screen text in the original —
it is a pure, interactive geometry demonstration of umbral vs. penumbral shadows,
which is the eclipse-shadow concept.

## Source of truth (decompiled ActionScript, AS1)

| Source file | Ported to |
|---|---|
| `scripts/Shadow.as` → `ShadowClass.update()` | `computeShadow()` + `drawShadow()` in `simulation.js` |
| `scripts/frame_1/DoAction.as` → `onMouseMoveFunc` / `onPressFunc` / `onReleaseFunc` | `constrain()`, pointer handlers, `moveObject()` |
| SWF `PlaceObject2` matrices (decoded from `shadows003.swf`) | stage constants (positions, radii) |

### Exact constants (verbatim; do not round)

Decoded from the SWF placement matrices (`scale × native-art-size`) and the frame
script (`objectRadius = mc._width/2`, `illuminantRadius = sunMC._width/2`):

- Stage: **900 × 500**
- **Sun**: center **(54, 250)**, displayed diameter 100 → radius **50** (art `sun.png`, 438px, scale 0.2283173). Not draggable.
- **Earth**: initial center **(310.8, 203.9)**, diameter 50 → radius **25** (art `earth.png`, 130px, scale 0.3846130).
- **Moon**: initial center **(327.9, 313.9)**, diameter 20 → radius **10** (art `moon.png`, 40px, scale 0.5).
- Drag no-overlap margin: **20**; a disc is pushed out to distance `(sunWidth + discWidth)/2 + 20` from the Sun center.
- Shadow colors, copied verbatim from `Shadow.as` (AS color ints → CSS):
  - penumbra fill `beginFill(5263440, 10)` → `0x505050` @ 10% → `rgba(80,80,80,0.10)`
  - umbra fill `beginFill(11579568, 90)` → `0xB0B0B0` @ 90% → `rgba(176,176,176,0.90)`
  - boundary/antumbra lines `lineStyle(0, 5263440, 50)` → `0x505050` @ 50% → `rgba(80,80,80,0.50)`

### Geometry port

`computeShadow()` reproduces `ShadowClass.update()` line-for-line: the shadow
MovieClip sits at the Sun center, the dragged disc is passed as the "illuminant
position", and `s` = Sun radius, `r` = disc radius, `d` = Sun→disc distance. The
internal-tangent branch (`sa = (s+r)/d`) builds the penumbra quad; the
external-tangent branch (`sb = (s-r)/d`) builds the umbra triangle and the antumbra
outline. The Sun→disc rotation matrix `k0..k3` and the mirrored ("prime") points are
copied exactly. Screen-Y is down in both Flash and canvas, so the arithmetic is
transcribed without sign changes. The Flash `trace("time: ...")` line is dropped.

### Drag port

`constrain()` reproduces `onMouseMoveFunc` exactly: push the disc out of the
no-overlap circle around the Sun (radial), then the `newX<0` special-case (with its
`delta` recomputation), then clamp to `[0,900]×[0,500]`. Pointer `xOffset/yOffset`
(grab point) matches `onPressFunc`. The **same** `constrain()` is used by both the
pointer-drag path and the keyboard slider path, so mouse, touch, and keyboard stay
in perfect sync through the single `state` object and one `render()`.

Draw order matches the SWF depths: `earthShadow(1)`, `moonShadow(3)`, `earthMC(5)`,
`sunMC(7)`, `moonMC(9)` → shadows first, then Earth, Sun, Moon.

## Assets reused as-is (not redrawn)

The three gradient-sphere discs are the exported bitmaps from the JPEXS export,
copied unchanged and composited on the canvas with `drawImage` at the original
positions/sizes/z-order:
`sprites/DefineSprite_4_Sun/1.png → assets/sun.png`,
`.../DefineSprite_6_Earth/1.png → assets/earth.png`,
`.../DefineSprite_2_Moon/1.png → assets/moon.png`.
Only the shadows (which the ActionScript draws at runtime via `lineTo`/`beginFill`)
are reproduced as canvas 2D geometry, because there is no exported file for them.

## KL-UNL foundation & contents.json

`sim-id = "shadowsim"`. The `shadowsim` entry **already exists** in the shared
`foundation/contents.json`, so no new entry was added; its Help/About text is the
original's, used verbatim. The whole `foundation/` folder was copied into
`html5/foundation/`. `kl-unl-masthead.js`, `kl-unl.css`, and `kl-unl.js` are
**byte-for-byte unchanged**.

### ⚠️ Required fix to the copied `contents.json` (please review)

The shared `contents.json` as shipped in this bundle is **not valid JSON**, which
made the masthead's `fetch().json()` throw and broke the title/Help/About for
*every* sim (not just this one). Six pre-existing defects, all confined to
`"content"` string values, were corrected **in the copied file only** (never in the
`.js`/`.css`), with **no change to any wording**:

1. Four raw newline characters inside strings (trailing before the closing quote in
   the `ce_hc`, `bbexplorer`-area, and `longlat`-area entries, and one mid-sentence
   wrap in `eclipsingbinarysim`) — removed so the strings are single-line.
2. One raw TAB inside the `pulsar`-timing entry's content (`<p>\tThis…`) — removed.
3. Two unescaped double-quote pairs in `<a href="…">` links (`renaissancePtolemaic`
   and the Copernican `venusphases` entry) — escaped to `href=\"…\"`.

After these fixes the file parses strictly (108 entries) and the masthead loads.
**If your canonical `contents.json` lives elsewhere as a single shared file, apply
the same six corrections there** (or replace this copy with your known-good version);
the `shadowsim` entry itself was already present and correct.

## Deviations from the original

- **Keyboard controls added (accessibility).** The Flash original had no on-screen
  controls — only mouse dragging. Two keyboard paths were added so the simulation is
  fully keyboard- and screen-reader-operable (WCAG 2.1.1): (1) each disc has a
  focusable handle overlaid on the canvas — Tab to it (or click the disc to focus it,
  showing a dashed "focus mode" ring) and move it with the arrow keys (Shift = larger
  steps); and (2) X/Y sliders for Earth and Moon in the Controls panel, plus readouts
  and a shadow key. The physics/geometry is unchanged; every path drives the exact
  same `constrain()`/`state`/`render()` code as dragging, so mouse, touch, and keyboard
  stay in sync. This is the only behavioral addition and it never alters the shadow math.
- **Layout** follows the KL-UNL shell (controls column + diagram panel) rather than
  the Flash pixel layout, per the pipeline rules. The diagram itself replicates the
  original's look (Sun left; Earth and Moon casting umbra+penumbra to the right).
- **No math/MathJax:** the original UI contains no equations, symbols, variables, or
  units-with-notation, so there is nothing to typeset. `kl-unl.js` is still included
  per the foundation protocol but no equations are registered. See ACCESSIBILITY.md.
- **No Pause / reduced-motion handling needed:** the sim has no autonomous animation
  (single static frame, state changes only on user input), so there is no motion to
  pause or to suppress under `prefers-reduced-motion`.

## Verified (served over HTTP, Chromium preview)

- Masthead loads (title + Reset/Help/About); Help/About dialogs show verbatim text.
- Initial render matches the provided screenshot (umbra cones + penumbra spread).
- Distance readouts correct (Earth 261 px, Moon 281 px at defaults).
- Pointer drag matches the AS grab-offset + snapping/clamp math.
- Keyboard sliders update geometry, aria-valuetext carries quantity + unit; the Sun
  no-overlap push-out and stage clamps match the AS.
- `sim-reset` returns to the exact initial state.
- Mobile portrait (375px) reflows to one column with no horizontal scroll; canvas
  keeps the 900:500 aspect ratio and scales via CSS.
