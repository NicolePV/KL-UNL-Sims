# Conversion Notes — Phase Positions Demonstrator

## Behaviour model (one paragraph)

A star sits at the centre of a 506×506 black "orbital view". Two planets orbit it
and can be dragged anywhere on the field. Geometry alone determines what each
planet looks like *as seen from the other*: the controller computes a phase angle
for each viewing direction (law of cosines on the two star-centred positions) and
draws a lit/dark phase disc for each in the right-hand **Disc Appearances** column.
Dragging one planet within a snapping distance of the other turns it into a *moon*
of that planet, locked at a fixed separation and bearing; dragging a moon away
frees it. Holding **Shift** while dragging keeps an object in its current circular
orbit (though it can still snap into a moon if it gets too close). Neither object
may approach the star closer than a minimum separation, nor leave the field. A
**show orbits** checkbox draws each object's orbit circle, and each disc has a
**hide/show** toggle. There is no animation loop — the sim is entirely
drag/event-driven.

## Source of truth

Decompiled with JPEXS/FFDec from `phaseDemonstrator.swf` (Flash / AS1). The two
SWFs in the sim folder (`phaseDemonstrator.swf`, `phaseDemonstrator004.swf`) share
identical ActionScript; the `.html` wrapper loads `phaseDemonstrator.swf`, so that
is the ground truth. Key scripts:

- `Phase Demonstrator.as` — controller: `setPlanetPosition`, `updatePhases`,
  `updateOrbits`, `updatePanelTitles`, `drawCircle`, and the class constructor
  (initial planet placements + drag limits).
- `Draggable Planet.as` — the planet disc, grab-offset drag (`onPress`/
  `onMouseMove`), label placement.
- `Phase Panel.as` — `setPhaseAngle` (the phase-disc terminator drawing) and the
  hide/show `toggleVisibility`.
- `on(initialize)` blocks in `DefineSprite_106` — per-instance colours, titles,
  the show-orbits checkbox initial value.

## Constants copied verbatim

| Meaning | AS | Value |
|---|---|---|
| moon separation | `p.moonDistance` | 30 |
| moon snapping distance | `p.moonSnappingDistance` | 42 |
| minimum star separation | `p.sunSeparation` | 50 |
| drag margin | `p.dragMargin` | 20 |
| planet disc radius | `p.discRadius` (Draggable Planet) | 6 |
| label radius | `p.labelRadius` | 20 |
| phase disc radius | `p.discRadius` (Phase Panel) | 70 |
| active area | shape 103 | 506 × 506, origin centred |
| drag limit x/y | `activeArea._width/2 − discRadius − dragMargin` | 253 − 6 − 20 = **227** |
| planet 1 start | attachMovie initObj | (100, −160) |
| planet 2 start | attachMovie initObj | (120, −40) |

Colours (AS decimal → hex):

| Element | AS int | hex |
|---|---|---|
| planet 1 disc | 16748688 | `#ff9090` |
| planet 2 disc | 9474303 | `#9090ff` |
| planet border | 16777215 | `#ffffff` |
| orbit 1 line | 16752800 | `#ffa0a0` |
| orbit 2 line | 9211315 | `#8c8db3` |
| disc 1 light / dark | 16769248 / 6307904 | `#ffe0e0` / `#604040` |
| disc 2 light / dark | 14737663 / 4210752 | `#e0e0ff` / `#404040` |

Disc 2's dark colour is the `PhasePanelClass` prototype default (4210752); its
`on(initialize)` overrides only `lightColor`.

## AS → HTML5 mapping

- **`Object.registerClass` + prototype methods** → plain functions in a module
  closure operating on one `state` object. A single `render()` redraws all three
  canvases and syncs the DOM + live region from `state`, per the pipeline rule.
- **`setPlanetPosition(id, x, y)`** → transcribed line-for-line, including the
  `Key.isDown(16)` shift-orbit lock (passed in as `shiftDown`), the bounds clamp
  (`wasOutOfBounds`), the minimum-star-separation push-out, the moon-snap /
  moon-follow branch (`state` values 0 / 1 / −1), and the orbit-radius update
  guard.
- **`updatePhases`** → verbatim law-of-cosines geometry (`theta`, `d`, `beta1`,
  `beta2`, the `theta < PI` branch) producing the two phase angles and the label
  bearings. A `d === 0` guard was added (coincident points never occur in play,
  but it keeps JS from producing `NaN`); behaviour is otherwise identical.
- **`Phase Panel.as setPhaseAngle`** → `drawPhaseDisc()` on a 2D context. The
  `curveTo` terminator construction (n = 4 segments, `kr`/`ks` control radii, the
  `dir = ±1` side flip, dark fill then light fill on top) is transcribed exactly.
  Flash Y-down = canvas Y-down, so every coordinate is the AS value. The invisible
  `lineStyle(1, 0xff0000, 0)` outline is simply omitted (alpha 0).
- **`updateOrbits` / `drawCircle`** → `ctx.arc` (an exact circle; the AS `curveTo`
  version was a 4-segment approximation of the same circle). Same per-object logic:
  a circle round the star at radius = distance, or a small circle round the primary
  when the object is a moon.
- **`onPress` / `onMouseMove` grab-offset drag** → Pointer Events. `xOffset =
  planet._x − _xmouse`, then `setPlanetPosition(id, xOffset + mouse, …)`. Pointer
  coordinates are mapped back through the current CSS scale so the maths always
  runs in original 506-unit stage coordinates (parity at any zoom / size).
- **Star glow** — the star is a Flash gradient fill inside the active area (no
  exported bitmap). Reproduced with a canvas radial gradient (code-drawn art,
  preference #3). This is the only visual not taken from an exported file, because
  there is no exported file for it.
- **Title Bar / Help / About / Reset** → the shared `<kl-unl-masthead>` component.
  The original had Help + About (no Reset); the masthead adds Reset, wired to
  restore the exact initial state. Help/About text is **not** hardcoded — it lives
  in `foundation/contents.json` under the key `phaseDemonstrator`, which **already
  existed** in the shared file (Help text matches the original `texts/40.txt`
  verbatim). No contents.json edit was required.
- **FUIComponent / FPushButton / FCheckBox** (the Flash component framework) → not
  ported; only the observable behaviour is reproduced with native `<button>` and
  `<input type="checkbox">`.

## The contents.json entry

No edit was needed. The shared `foundation/contents.json` already contains the
`phaseDemonstrator` entry (meta title/version + Help/About). `index.html` passes
`sim-id="phaseDemonstrator"`.

## Assets reused vs code-drawn

- **Code-drawn (no exported file exists):** the star glow, the orbit circles, the
  planet discs + white hover/focus borders, and the phase-disc terminators — all
  built at runtime by the ActionScript via the Flash drawing API, so reproduced on
  `<canvas>`.
- **Exported assets:** none of the sim's live visuals are exported bitmaps or
  static shapes; the black active-area square and phase-panel backgrounds are flat
  fills reproduced directly. Nothing was traced or redrawn from a bitmap.

## Deviations from the original

- **Reset button added** (the masthead provides it); the original had none. It
  restores the exact initial state — a pure convenience/accessibility gain, no
  behaviour change.
- **Illuminated-fraction readouts + formula added** for accessibility (the original
  showed no numbers). Values are derived from the same phase angle that draws each
  disc — `f = (1 + cos α) / 2` — verified pixel-for-pixel against the drawn discs
  (0.87 drawn vs 0.875 computed; 0.421 vs 0.422). They cannot drift from the
  picture.
- **Phase-panel titles rendered as HTML headings** above each disc rather than as
  Flash text fields inside the black box. Same text, same update logic; better for
  zoom and screen readers (KL-UNL favours panel structure over pixel layout).
- Layout uses the KL-UNL shell/classes rather than the original Flash pixel
  coordinates, per the pipeline rules. Panel grouping and reading order match the
  screenshot (wide orbital view left; Disc Appearances column right).

## Cross-browser

Standards-based Canvas 2D, Pointer Events, native form controls, and MathJax SVG
output — all supported on Chrome, Edge, Firefox, and Safari (desktop + iOS). No
Chrome-only APIs; no prefix-only CSS (`-webkit-` appears only as additive
fallbacks for user-select / tap-highlight). `touch-action: none` on the canvas
makes dragging work on iOS Safari without scrolling the page.
