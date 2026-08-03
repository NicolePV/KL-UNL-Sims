# Conversion Notes — Basketball Phases Simulator

## Behaviour model

A basketball sits at the centre of a circular track and is lit from the left by a bank of
four light rays. An eye rides the track and always faces the ball. What that eye sees is
drawn in the "View of Ball" panel: one of 79 pre-rendered rotation frames of the ball,
overlaid with a dark terminator region whose shape depends on where the observer is
standing. Walking the eye once around the track therefore cycles the ball through a full
set of phases — full when the observer stands beside the light, new when they stand
opposite it — which is the point of the analogy to lunar phases. The eye can be dragged
by hand or set running at a chosen speed; the phase shading and the light rays can both
be switched off together; and the ball itself can be hidden so a student can predict the
phase before revealing it.

## Source

The linked folder contained only `basketball.swf`, `basketball.html` (a Ruffle wrapper)
and `basketball.jpg` (a screenshot) — no decompiled export. The SWF was decompiled with
the locally installed JPEXS/FFDec 26.2.1 into `../decompiled/` (scripts, shapes, sprites,
images, texts, frames). That folder is source material, not output, and is left untouched.

`basketball.swf` is **SWF version 6**, so its ActionScript is case-insensitive. This
matters: `eye_clip.as` defines `p.onEnterframe` (lower-case `f`). Under AS2 semantics that
handler would never fire and the eye would neither animate nor rotate. Under Flash 6 it
fires normally, which is what the original does, and what this port reproduces.

## Stage geometry

Stage 720 × 430 at 12 fps. The whole simulation lives in one clip, `animation`, placed at
(288, 215) and scaled 0.72. All coordinates below are in that clip's local units, whose
origin is the centre of the ball — the port keeps exactly this coordinate system.

| Object | Placement in `animation` |
| --- | --- |
| `eyeball` (the track, ball and eye) | (0, 0) |
| `rotator` ("View of Ball") | (470, −177.8), scale 0.8934 |
| `myLight` (rays + "Light") | (−330.85, 4.2) |
| `animRadio`, `phRadio`, `mySlider`, `hide_show` | right-hand column |

## ActionScript → JavaScript mapping

| ActionScript | Port |
| --- | --- |
| `Object.registerClass` + `prototype = new MovieClip()` | plain functions over one `state` object |
| `animation.onEnterFrame` (the controller) | `render()`, called after every state change |
| `eye_clip.onEnterframe` (motion) | `tick()` on `requestAnimationFrame` |
| `getTimer()` | `performance.now()` |
| `the_eye.onPress` / `onMouseMove` / `onRelease` | Pointer Events on the canvas |
| `_x` / `_y` / `_rotation` / `_visible` | applied at draw time from `state` |
| `_mask_mc.beginFill(0, 70)` + `curveTo` | canvas path, `globalAlpha = 70/100`, non-zero winding |
| `attachMovie("BasketballSequence")` + `gotoAndStop(n)` | `drawImage` of `assets/sequence/fNN.png` |
| `Color.setRGB(16763904)` on the arrow | the exported arrow SVG tinted `#ffcc00` through its own alpha |
| `FPushButton` / `FRadioButton` / `FUIComponent` | native `<button>`, `<input type="radio">`, `<input type="range">` |
| `updateAfterEvent()`, `trace()` | dropped |

### Constants, copied verbatim

From `BasketballRotator.as`: `_frames = 79`, `_stepSize = 2π/79`, `_margin = 10`,
`_radius = 86`, `_N = 5`. From the instance initialisers: `initLongitude = 0`,
`initSunAngle = 0`, `initDarkAlpha = 70`. From `eye_clip.as`: orbit radius `250`.
From the slider initialiser: `init_min = 0.01`, `init_max = 0.1`, `init_value = 0.05`
(degrees per millisecond, so 0.05 is 50 °/s), `init_title = "Speed of Animation"`, with
`min_text = "Slow"` and `max_text = "Fast"` set in `Slider v2.as`.

### The terminator

`BasketballRotator.updateMask` is transcribed line for line. It draws a box covering one
side of the disc, closed by a five-segment quadratic half-ellipse whose horizontal extent
is `cos(phase)`. Flash's drawing API fills with the non-zero winding rule, and so does
`<canvas>` by default, so the box and the closing curve add or cancel exactly as they do
in the original: at full phase the two cancel over the disc and nothing is shaded; at new
phase they combine and the whole disc is shaded.

Verified in the browser by comparing each half-disc's mean brightness with phases on
against phases off, at the same rotation frame:

| Viewing angle | Left half retained | Right half retained |
| --- | --- | --- |
| 0° | 1.00 | 1.00 (full) |
| 90° | 0.30 | 1.00 |
| 180° | 0.30 | 0.30 (new) |
| 270° | 1.00 | 0.30 |

0.30 is exactly `1 − 70/100`, confirming both the geometry and `initDarkAlpha`.

### Frame selection

`setLongitude` computes `1 + mod(floor(longitude / stepSize), 79)`. Checked against the
exported frames in the browser — 0° → frame 1, 45° → 10, 90° → 20, 137° → 31, 180° → 40,
250° → 55, 300° → 66, 359° → 79 — and the rendered disc interior is pixel-identical to the
corresponding `assets/sequence/fNN.png` (max channel difference 0 inside radius 84).

### Motion

`_time += dt * _speed; angle = _time % 360`. The original ran on a 12 fps `onEnterFrame`
but advanced by elapsed wall-clock time, so `requestAnimationFrame` reproduces it exactly.
Measured in the browser: 0.01 → 9.9 °/s, 0.05 → 49.2 °/s, 0.1 → 97.8 °/s (targets 10, 50,
100; the shortfall is the whole-degree rounding of the sampled readout).

The animation loop only runs while the eye is actually animating, so an idle sim costs
nothing. Dragging suspends it and releasing resumes from wherever the eye landed, matching
the original's `_time = angle` handoff.

## Assets: reused, not redrawn

| Asset | Origin | Use |
| --- | --- | --- |
| `sequence/f01..f79.png` | shapes 64…220 (each wraps a 175 × 175 JPEG) | the 79 rotation frames |
| `eye.svg` | shape 256 | the observer's eye |
| `ball.svg` | shape 252 | the ball in the overhead view |
| `ball-shadow.svg` | shape 260 | the unlit half of that ball |
| `orbit.svg` | shape 258 | the observer's circular track |
| `arrow.svg` | shape 240 | one light ray, drawn four times |

The sequence is exported as PNG rather than reusing `images/*.jpg` directly because the
Flash shape clips each JPEG to a circle; the PNG carries that alpha, the bare JPEG does
not. The underlying bitmaps are 175 × 175 natively, so this is a 1:1 export with no
resampling. Only the rotator's plain black 225 × 225 backing square (shape 250) is drawn
in code, as a `fillRect`.

## Deviations from the original

1. **Chrome and layout.** Presentation follows the KL-UNL shell and the accessibility
   rules, not the Flash pixel layout, palette or fonts. Panel structure, grouping and
   reading order do mirror the original: wide overhead view on the left, "View of Ball"
   above the controls on the right. `.app-layout`'s default columns are narrow-left, so
   `styles.css` flips the proportions and re-declares the foundation's own 56 rem collapse
   at matching specificity.
2. **Panel headings.** The original labels only the right panel, as vertical "View of
   Ball" text. Headings are required for a correct document outline, so the left panel is
   titled "Overhead View" and the control panel "Controls"; the vertical text becomes a
   normal horizontal `<h2>`.
3. **Fieldset legends.** The radio groups are unlabelled in the original. Grouping them
   needs an accessible name, so they gained the visible legends "Eye Motion" and "Phases".
   The radio labels themselves are verbatim.
4. **Hide/Show button.** The original stacks a "Hide Basketball" button on top of a "Show
   Basketball" button and toggles which is visible. This is one button whose label swaps —
   the same observable behaviour, and one fewer thing in the tab order.
5. **Viewing-angle readout.** Added, typeset by MathJax. The original displays no numbers
   at all; this makes the eye's position legible to everyone and gives the pipeline's
   MathJax requirement something real to render.
6. **Eye grab radius.** Flash hit-tests the eye artwork itself. The port uses a 38-unit
   radius around the eye's centre so the target clears the minimum touch size. The drag
   maths — `angle = 180 + degrees(atan2(y, x))` — is unchanged.
7. **ClassAction logo.** The animated ClassAction logo in the original's bottom-left
   corner is dropped; KL-UNL branding comes from the masthead.
8. **Two sub-pixel details dropped.** A 4.4 × 10 highlight sliver (shape 255) and a
   rotated "Smith" text field scaled to about 6% (character 254, an artist's signature)
   sit inside the eye clip. Both render below one pixel in the original and are omitted.
9. **Terminator drawn even with phases off.** `setSunAngle(0)` still calls `updateMask`,
   which fills a region entirely outside the disc. Faithfully reproduced; it is invisible
   (black on black) apart from a hairline at the disc's antialiased rim.

## contents.json

**No edit was required.** The shared `foundation/contents.json` already contains a
`basketball` entry (title "Basketball Phases Simulator", version 2.0, with Help and About
text). The foundation folder is copied into `html5/foundation/` byte-for-byte unchanged,
including that entry, and `index.html` uses `sim-id="basketball"`.

If the deployment model is instead a single shared `contents.json` rather than a per-sim
copy, nothing needs pasting — the entry is already in the shared file.

## Browser support

Standards-only: Pointer Events, `<canvas>` 2D, CSS grid/flex, `prefers-reduced-motion`.
No Chrome-only APIs and no prefix-only declarations (`-webkit-user-select` and
`-webkit-touch-callout` appear only alongside their standard counterparts). The canvas
carries `width`/`height` attributes, so `width:100%; height:auto` preserves its aspect
ratio without relying on the `aspect-ratio` property. Verified in the bundled Chromium at
device pixel ratios 1 and 2, desktop and phone-portrait widths; Safari, Firefox and iOS
still want a human pass.

## Known limitation of the automated verification

The verification harness ran in a hidden browser pane, where `requestAnimationFrame` is
suspended. The animation was therefore driven through a timer-backed `rAF` shim, which
exercises the real `tick()` path and its elapsed-time arithmetic. Everything else — the
terminator geometry, frame selection, pixel comparisons, drag, keyboard, reset, layout —
was measured against the live DOM and live canvases.
