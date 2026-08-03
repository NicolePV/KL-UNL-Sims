# Conversion Notes — Tidal Bulge Simulator

## Behaviour model (one paragraph)

The simulation is a **top-down diagram** of the Earth–Moon system. The Moon
orbits the Earth at a constant rate (one orbit every 51 s of animation). The
Earth's oceanic **tidal bulges** are drawn as a single blue ellipse whose long
axis always points along the Earth–Moon line, so it tracks the Moon around the
orbit; the Earth itself spins 28 times per lunar orbit underneath. Three
checkboxes change the picture: **Run** starts/stops the motion; **Include Sun**
adds day/night shading to the Earth and Moon (the Sun is fixed to the right, so
the right hemisphere is always lit), draws a *To Sun* arrow, and makes the bulge
ellipse vary between an elongated **spring** shape (Moon in line with the Sun,
phase 0°/180°) and a rounder **neap** shape (Moon at right angles, 90°/270°);
**Include Effects of Earth's Rotation** rotates the bulges ahead of the Moon by
a fixed 20° lead, representing the Earth's rotation dragging the bulges forward.
There are no numeric readouts, no equations, and no on-screen text other than
the "To Sun" label.

## Source of truth

Decompiled with JPEXS/FFDec from `tidesim.swf` (600×550 stage). The behaviour
comes from these AS1 scripts:

| Script | Role |
| --- | --- |
| `frame_1/DoAction.as` | change-handlers wiring the four checkboxes to `mySim` |
| `tideAnim.as` (`tideAnimClass`) | the master controller (`mySim`) |
| `earth.as` (`earthClass`) | Earth spin + day/night shadow toggle |
| `moon.as` (`moonClass`) | invisible orbital "driver" that produces the phase angle |
| `tidalBulge.as` (`tidalClass`) | the 360-frame bulge ellipse (spring/neap tween) |
| `arrow.as` | gravity-vector arrows (unused — see below) |

## AS → HTML5 mapping

| ActionScript | HTML5 port |
| --- | --- |
| `Object.registerClass` prototype classes | one plain `state` object + a single `render()` |
| `onEnterFrame` | one `requestAnimationFrame` loop, driven by elapsed `performance.now()` time (not frame counts) |
| `getTimer()` | `performance.now()` |
| `moon._angle` (radians) | `state.angleDeg` (degrees, `[0,360)`) |
| `da = dt*2π/_speed`, `_speed = 510000/10` | `dDeg = dt*360/51000` |
| `earth._tideTime = 360 - degrees(moon._angle)` | `tideTime = 360 - angleDeg` |
| `earth._time = _tideTime * 28` | `earthSpin = (tideTime*28) % 360` |
| `moonVectors._rotation = _tideTime` (Moon position) | `moonPos = earthC + R·(cos, sin)(tideTime°)` |
| `visMoon._rotation = -_tideTime` (keeps Moon upright) | Moon bitmap drawn with no rotation (net 0) |
| `earth.rotateTide(_tideTime [- _offset])`, `_offset = 20` | ellipse rotated by `tideTime` (or `tideTime-20`) |
| `tidalBulge.gotoAndStop(1 or round(phi))` | `bulgeNatural(phi, withSun)` ellipse W/H |
| `myShadow._visible = withShad` (Earth) | fixed left-half `earth-shadow.png` when Sun on |
| `withShad` swap on `visMoon` | swap `moon.png` ↔ `moon-lit.png` when Sun on |
| `toSunArrow._visible` | `drawToSunArrow()` when Sun on |
| `Color.setRGB` on gravity arrows | n/a (arrows never shown — see deviations) |
| `updateAfterEvent()`, `trace()`, `_root/_parent` | dropped / replaced with direct references |

## Constants (verbatim from the AS)

- Orbit period: `510000 / 10 = 51000` ms (`moon._speed` ÷ `tideAnim._speed`).
- Earth spin multiplier: `28`.
- Earth's-rotation bulge lead: `20°` (`tideAnimClass._offset`).
- Bulge fill colour: `0x6699FF` (measured RGB 102,153,255).

## Assets reused as-is (not redrawn)

Exported bitmaps copied into `assets/` and composited on the canvas at their
original relative sizes/positions:

| File | Source symbol | Use |
| --- | --- | --- |
| `earth.png` | `DefineSprite_81` | Earth sphere + continents (`myEarth`), rotated for spin |
| `earth-shadow.png` | `DefineSprite_83` | night-side terminator overlay (left) |
| `moon.png` | `DefineSprite_69` | plain Moon sphere (Sun off) |
| `moon-lit.png` | `DefineSprite_72` | Moon with sunlit hemisphere (Sun on) |

Only genuinely **code-drawn** geometry is reproduced on the 2D canvas: the blue
tidal-bulge ellipse and the "To Sun" arrow.

### Bulge ellipse

In the SWF the bulge is a 360-frame shape tween of one ellipse (`tidalBulge`,
symbol frames measured at W 150–180 px, H 111–125 px). Rather than ship 360
frames, the port reproduces the tween analytically:

- **Sun off** → constant `frame 1` shape (W 170, H 111).
- **Sun on** → `W = 165 + 15·cos(2φ)`, `H = 118 − 7·cos(2φ)` — most elongated at
  φ = 0°/180° (spring), roundest at 90°/270° (neap), matching the measured
  envelope. Natural sizes are scaled to the stage by ×0.6076 (x) and ×0.688 (y),
  derived from the on-stage composite.

## Deviations from the original (and why)

1. **Flash chrome dropped (Goal B > Goal C).** The original ClassAction border
   frame, the "ClassAction" logo, and the grey Flash background are not
   reproduced; the sim is rendered inside the KL-UNL shell (masthead + panels).
   Reset / Help / About come from the `<kl-unl-masthead>` component.
2. **"Show Gravity Vectors" checkbox omitted.** In the source this checkbox
   (`arrowBox`) is created but immediately hidden (`arrowBox._visible = false`),
   so at runtime it is never operable and the gravity/sun vector arrows never
   appear. To match the *observable* behaviour, the checkbox and the arrows are
   omitted. (The `arrow.as` colour logic is therefore unused.)
3. **Diagram on the left, controls on the right.** The original places the three
   checkboxes in the lower-right corner; the KL-UNL `.app-layout` grid uses a
   wide diagram column on the left + a controls column on the right, and the two
   panels are set to equal height. Panel grouping and reading order are
   preserved; exact Flash coordinates are not (Goal C yields to Goal B). On
   narrow/portrait widths the layout stacks to a single column with the diagram
   first.
4. **Bulge tween approximated analytically** (see above) instead of shipping 360
   raster frames — same spring/neap behaviour, cleaner and lighter.
5. **Animation is user-controlled and never auto-plays.** "Run" defaults off, so
   there is no motion until the user asks for it (WCAG 2.2.2). The animation loop
   only spins while running.

## contents.json

The shared `foundation/contents.json` **already contains** a `tidesim` entry
(`meta.title` = "Tidal Bulge Simulator", `version` 2.0, with Help and About
text). No edit to `contents.json` was required; the copy under
`html5/foundation/` is byte-for-byte identical to the source. The masthead is
wired with `sim-id="tidesim"` and `json-url="foundation/contents.json"`.

## Verified

Every visual state and transition was checked against the decompiled stage
renders by capturing the live canvas: default view, Moon at 0/90/180/270°, bulge
tracking the Moon, spring vs neap ellipse with the Sun, the 20° bulge lead, the
day/night terminator, the Moon phase swap, the "To Sun" arrow, and Reset
returning to the exact initial state.
