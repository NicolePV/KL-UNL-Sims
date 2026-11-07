# Conversion Notes — Three Views Simulator

## Behavior model (one paragraph)

The Three Views Simulator shows how the **phase of the Moon depends on the
viewing geometry**. A top-down "Orbit View" shows the Sun at the center with the
Earth revolving around it and the Moon revolving around the Earth. A second
"View of Moon" panel shows the Moon as it would actually appear **From Earth**,
**From the Sun**, or **From a chosen point in Space** (a draggable observer).
Internally the whole animation is driven by a single hidden "clock" Moon whose
angle advances at a rate set by the Animation-Speed slider. That one angle
determines the Moon's orbital position, the Earth's rotation (28 spins per
orbit), and the Earth's slow revolution about the Sun (27.6° per synodic cycle).
From those, the code computes the Sun–Earth–Moon geometry and renders the
correct illuminated fraction (a dark "terminator" lune drawn over a real Moon
photograph) plus, for the Sun/Space views, the correct rotated lunar face.

## Source → target mapping

Ground truth for behavior was the decompiled ActionScript-1 (`scripts/…`,
JPEXS/FFDec export of `moonphases.swf`). Ground truth for layout intent was the
running screenshot (`../moonphases.jpg`) and the design frame (`frames/1.png`).

| ActionScript symbol / class          | HTML5 counterpart |
|---------------------------------------|-------------------|
| `animation` (`animation.as`, top clip)| `updatePhysics()` per-frame block + `render()` |
| hidden clock `moon` (`moon.as`)       | `state.moonAngle` advanced by `dt·2π·animSpeed/510000` |
| `tideAnim.as` (frame/time coupling)   | `frameDeg`, `moonTime`, `earthTime = moonTime·28` |
| `sunEarth.as` (law-of-cosines dist.)  | `angMES`, `distSM = √(203² + 61² − 2·203·61·cos)` |
| `earth.as` (spin)                     | Earth globe rotated by `earthTime` on the canvas |
| `moonPhaseSymbol.as` (Earth view)     | `renderMoonView()` earth branch + `drawTerminator(…, 'earth')` |
| `MoonRotator.as` (Sun/Space view)     | `renderMoonView()` else branch + `drawTerminator(…, 'rotator')` + `longitudeToFrame()` |
| `perspectRadio.as` + radio buttons    | `input[name="perspective"]` |
| `Slider v2.as` grabber drag           | native `<input type="range">` (keyboard + wheel for free) |
| `startButton.as` / `DefineSprite_241` | Run/Stop toggle button + Restart button |
| `hide_show.as`                        | Hide/Show Moon toggle button |
| draggable `spaceArrow` (onMouseMove)  | pointer drag on the canvas **and** `#space-observer` keyboard proxy |
| Help / About text                     | already present in `foundation/contents.json` under key `moonphases` |

All physics constants and phase-name thresholds are copied **verbatim**
(`SYNODIC = 29.5`, Earth–Sun = 203, Earth–Moon = 61, clock constant 510000 ms,
`earth._time/365 − 27.6`, phase tolerance `12·360/(29.5·24)`, etc.). The
numerical check `updatePhysics(1000 ms)` at speed 50 yields exactly 35.294° of
Moon-angle advance, matching the ported formula.

### The `contents.json` edit
**No edit was required.** The shared `foundation/contents.json` already contains
a `moonphases` entry whose `meta.title` is "Three Views Simulator" with tailored
Help and About text, so the copied foundation is byte-for-byte identical to the
source. `index.html` uses `sim-id="moonphases"`.

## Reused assets vs. code-drawn

**Reused as-is** (exported bitmaps copied to `assets/`, never redrawn):
the Sun disk, the Earth globe, the small orbit-view Moon, the direction arrow,
the full Earth-view Moon photograph (`moon_earthview.png`), and the 59-frame
Moon-rotation sequence (`moon_seq/1…59.png`).

**Code-drawn** (runtime `drawArc`/`beginFill`/`curveTo` in the AS, so redrawn on
the 2-D canvas with matching geometry): the terminator "lune" that darkens the
unlit part of the Moon (70 % opaque black, `drawTerminator()`), reproduced from
`moonPhaseSymbol.updateMask` / `MoonRotator.updateMask` including their exact
anchor/control-point tables and box-direction sign conventions.

## Layout / presentation deviations (Goal C vs. Goals A & B)

* The original Flash pixel layout, palette, fonts and vertical side-labels are
  **not** reproduced; the sim uses the KL-UNL panels and palette. Panel grouping
  and reading order mirror the original: Orbit View (left), View of Moon
  (upper right), Perspective + speed + Run/Restart (lower right).
* The original "View of Moon" and "Perspective" **vertical** text labels became
  normal horizontal `<h2>` panel headings (accessibility + template usage).
* The Orbit-View canvas keeps the original stage coordinate system (Sun at stage
  (298, 304); Earth orbit radius 203; Moon orbit radius 61; observer clamp ±280)
  and is scaled by CSS. As in the original, the Sun sits left-of-center with
  generous margins; this is intentional replication, not misalignment.
* The Run/Stop control is a single toggle button (the original overlaid a hidden
  "Stop Animation" button behind the "Run Animation" button — same observable
  behavior).

## Minor behavior approximations (documented)

* **Earth day/night shadow** (`myShadow`, sprite 211) on the ~30 px orbit-view
  Earth, and the dynamic terminator on the ~14 px orbit-view Moon, are **not**
  overlaid; those tiny icons use the baked sprite art. The pedagogically
  important terminator is the large "View of Moon" disk, which is reproduced
  exactly for all three perspectives.
* Animation timing uses `performance.now()` elapsed wall-clock time (matching the
  AS `getTimer()` deltas), so speed is machine-independent and a
  backgrounded tab advances by real elapsed time on resume, as in the original.

## Cross-browser

Standards-only HTML/CSS/JS: Canvas 2D, Pointer Events (`touch-action: none` on
the draggable observer), native `<input type="range">`, `<dialog>` (used only by
the foundation masthead). No Chrome-only APIs and no prefix-only CSS, so it
renders and operates the same on Chrome, Edge, Firefox and Safari (desktop + iOS)
across Windows/macOS/Linux/Android.
