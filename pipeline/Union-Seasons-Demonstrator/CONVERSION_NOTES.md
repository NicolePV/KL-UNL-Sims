# Conversion Notes — Time-Lapse Seasons Demonstrator

## Behaviour model

The simulation shows how the sun's position, and therefore the shadow it casts,
changes across a year. A sequence of 315 webcam photographs of Memorial Plaza at
the University of Nebraska–Lincoln — each taken at the moment the sun reached its
highest point in the sky, the meridional transit — is indexed by day of year. A
horizon diagram beside the photograph shows the same instant geometrically: the
sun sits due south at that day's transit altitude, riding a yellow declination
circle that slides up and down between the two white ±23.44° limit circles as the
year turns. The user picks a day by dragging the timeline cursor, by pressing on
the timeline to step toward the press, by dragging the sun disc up or down the
diagram (which maps a declination back onto a day), or by running the animation
at an adjustable rate. Days with no photograph are skipped automatically, and an
"exclude overcast days" option additionally skips days when the building casts no
shadow, which makes the shadow's seasonal march much easier to follow while
animating.

## Where the source came from

The original is two SWFs:

- `transitmovie.swf` — the controller, the celestial-sphere engine, and the UI.
- `transitimages.swf` — loaded at runtime by `imagesMC.loadMovie(...)`; holds the
  315 photographs **and** the day table that everything else depends on.

The provided decompile of `transitimages.swf` contained only `images/` and
`shapes/` — no ActionScript — so the day table was missing. It was recovered by
re-running JPEXS with script export enabled; the result is in
`../transitimages_scripts/scripts/Transit Image Sequence.as`. Without it there is
no declination, altitude, right ascension, timestamp, or overcast/missing flag
for any day, and the sim cannot be built.

## Data extraction and how it was verified

`assets/daydata.json` carries the day table over verbatim: 366 entries of
`time`, `timeZone`, `ra`, `dec`, `alt`, `eqnOfTime`, plus the `overcast` and
`missing` flags and the resolved image filename. Nothing is rounded or
recomputed.

The `overcast` and `missing` flags are applied exactly as the AS constructor
does, mapping frame numbers to day indices through `(frame - offset) mod length`
with `offset = 123`.

Resolving **which photograph belongs to which day** needed the image SWF's
timeline, since JPEXS exports bitmaps by character id, not by frame. The
`DefineSprite_631` timeline was read out of the SWF structure to get
frame → shape, and each shape's bitmap fill gave shape → bitmap (consistently
`bitmap = shape − 1`). Day → frame follows `setImageDay()`:
`frame = day + 123`, less the table length when `day >= firstDay` (270).

Three independent checks agree, which is why this mapping is trusted:

1. Exactly 51 days resolve to no image, and the AS `missingFrames` list has
   exactly 51 entries — and they are the *same* 51 days (zero mismatches).
2. 366 − 51 = 315 images, which is exactly the number of exported JPEGs, each
   used once.
3. Day 282 (the default start day) resolves to `21.jpg` and renders
   "Thursday 9 October 2003, 1:13 pm CDT", altitude 42.9°, declination −6.3° —
   character-for-character what the reference screenshot of the running Flash
   original shows.

As a further sanity check on the physics, the table's altitudes span 25.74° to
72.62°, matching `90° − latitude + declination` at latitude 40.8° N
(25.76°/72.64°) to within 0.02°.

## AS → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `DefineSprite_165/frame_2` controller | the `state` object + `setDay`, `setSunDec`, `analyzeDayTable`, `incrementUpBy/DownBy` in `simulation.js` |
| `CelestialSphereClass` + `2..9 CS *.as` | `doA`/`doM`/`doB` projection, `circleV`/`splitCircle`/`traceArc`, `clipAbove` |
| `Object.registerClass` prototype classes | plain functions over one shared state object |
| `onEnterFrame` + `getTimer()` | one `requestAnimationFrame` loop over `performance.now()`, same ms constants |
| `drawArc` (tessellated with `curveTo`) | `traceArc`, same parametric ellipse, finer step since canvas has no `curveTo` tessellation to lean on |
| `setMask` / the `M0..M5` mask clips | `ctx.clip()` regions (`clipAbove`, `clipSphere`) |
| `FCheckBox`, `FPushButton`, `Standard Slider v6` | native `<input type="checkbox">`, `<button>`, `<input type="range">` — the Flash component framework is **not** ported, only its observable behaviour |
| slider `scalingMode: "logarithmic"` | `value = exp(t·(ln max − ln min) + ln min)`, the same geometric interpolation `SliderLogicClassV6` used |
| `Timeline.as` month ticks + no-image bands | code-drawn on a canvas strip; month **names** moved into HTML so they zoom |
| `ShadowMaker.as` | `drawShadowAndStickman`, same `1/tan(altitude)` scaling and alpha fade |
| `_root.startDay` | the `?startDay=` query parameter |
| masthead, About/Help dialogs, Reset | the shared `<kl-unl-masthead>` component and its `sim-reset` event |

## Assets: reused vs. code-drawn

**Reused as-is** (copied from the JPEXS export, never redrawn):

- `assets/images/*.jpg` — all 315 photographs.
- `assets/shapes/34.svg` — the green horizon plane (`CSAboveHorizonPlane`).
- `assets/shapes/49.svg`, `50.svg` — the sun disc and its focus/hover outline.
- `assets/shapes/55.svg`, `53.svg` — the figure and its shadow.
- `assets/shapes/61.svg`, `59.svg` — the timeline cursor and shadow cursor.
- `assets/shapes/11.svg` — the "show directions" overlay on the photograph.

**Code-drawn on canvas** (these have no exported file; the ActionScript builds
them at runtime with `drawArc`/`beginFill`):

- The six circles: two meridians, the ±23.44° declination limits, the celestial
  equator, and the sun's daily declination circle.
- The sky gradient discs (`CSGradientDisk`), front and back.
- The timeline month ticks and the "days with no image" bands.

## contents.json

**No edit was needed.** `foundation/contents.json` already contains a
`transitmovie` entry whose Help text matches the original `texts/28.txt` verbatim
(reflowed into the four paragraphs the source's line breaks imply) and whose
About text carries the standard boilerplate. All four foundation files are
byte-for-byte identical to the originals — verified by checksum.

## Deviations from the original

- **Right Ascension is not displayed.** The SWF contains a "Right Ascension:"
  label and value field, and `setDay()` still computes `raString`, but the
  reference screenshot of the running original shows only *Sun's Altitude* and
  *Declination* in that panel. The screenshot was followed. The value is still
  computed and is available to screen readers through the diagram description.
- **Direction labels (N/E/S/W) live in HTML, not on the canvas.** In Flash they
  were text inside the horizon-plane clip, so they were squashed by the plane's
  vertical scale. As HTML they stay upright and legible, honour the user's font
  size, and are positioned at the projected cardinal points each frame. Their
  colour also changed — see ACCESSIBILITY.md.
- **Month names on the timeline live in HTML** for the same zoom reason; the
  ticks and bands are still drawn on the canvas.
- **A frame-time clamp was added.** `requestAnimationFrame` is paused while a tab
  is in the background, so the first frame after the user returns would otherwise
  carry the entire away-time as one delta and jump the sim to an arbitrary day.
  Each frame now advances by at most 100 ms of elapsed time. Flash had no
  equivalent problem because it kept running.
- **`prefers-reduced-motion` is honoured.** The continuous animation does not
  start; the live region explains why and points at the timeline and arrow keys.
  Every other route to every day remains available, so nothing is lost.
- **Panel layout is the KL-UNL grid, not Flash pixel coordinates.** The original
  820×600 arrangement (`frames/1.png`) — large photo left, horizon diagram above
  animation controls right, full-width timeline below — is reproduced in grouping
  and reading order, and collapses to a single column on narrow screens. The
  photo panel is stretched to span the full height of the two panels beside it,
  matching the original, where the left panel's 455px equals the right column's
  335 + 5 + 115.

## The shadow

The figure and its shadow are the one place where the port does real geometry
rather than replaying a Flash transform, so it is worth setting out.

**The figure is pinned in world units, not pixels.** `PERSON_WORLD_HEIGHT` and
`PERSON_WORLD_WIDTH` are constants, chosen so that at the sim's default
viewpoint the figure projects to exactly the pixel size of the exported art
(`h · r · cos 40° = 35.55 px`, `w · r = 14.3 px`). Everything else is projected
from them.

**The figure turns with the ground.** It is drawn through
`absoluteOrientation()`, a port of the `oType 2` branch of
`CSObjectsClass.update()`. The figure is a flat card facing south — the
direction the sun transits — with the zenith as its up-axis, exactly as
`initializeHorizonDiagram()` sets it up. The card is foreshortened by the
component of its facing direction along the view axis and rotated so its
up-axis follows the zenith, which makes it turn and squash together with the
plane instead of standing rigidly upright whatever the viewer does:

| view | height factor | width axis |
| --- | --- | --- |
| az 200°, alt 40° | 0.766 | 0.965 at −13° |
| az 230°, alt 40° | 0.766 | 0.810 at −38° |
| az 260°, alt 40° | 0.766 | 0.656 at −75° |
| az 290°, alt 40° | 0.766 | 0.694 at −120° |
| az 200°, alt 70° | 0.342 | 0.993 at −19° |
| az 200°, alt 85° | 0.087 | 1.000 at −20° |

Swinging the azimuth turns and compresses the figure's width axis; raising the
viewing elevation shrinks its height until, seen from almost overhead, the
standing figure nearly disappears and its shadow is fully exposed. The up-axis
stays vertical on screen throughout, which is correct — a vertical world vector
always projects to a vertical screen vector in this projection, so it is the
*width* that shears, not the height.

**Registration points are honoured.** The two sprites disagree about where
their origin sits: `StickmanShadow`'s is at the exact bottom of its 33.55px
image, while `Stickman`'s is 1px up from the bottom of its 35.55px image
(`translate(7.15, 34.55)` in the SVG). Drawing both flush to their image
bottoms left the shadow's base and the figure's feet on different points.
`STICKMAN_REG_Y` and `SHADOW_REG_Y` anchor each sprite by its own registration
point; measured in isolation, the figure's feet now land at y = 151 and the
shadow's base at y = 150, with their bases overlapping horizontally.

**The shadow is laid into the ground plane.** Two ground-plane basis vectors —
one along the shadow, one across it — are projected to screen, and the shadow
art is drawn through the resulting 2×2 map. Because those two axes foreshorten
by *different* amounts, the result is genuinely sheared: at the default view
the projected ground axes sit 106° apart, not 90°. That is what makes the
shadow read as lying on the ground rather than standing up and rotated.

**Length is `height / tan(altitude)`**, evaluated in world units and then
projected, and the shadow fades near the horizon by ShadowMaker's own
`1 − 1/(15·tan(altitude))` relation.

Verified against the rendered canvas:

- The shadow's bearing matches the computed away-from-the-sun ground direction
  to within 1–3° on days 0, 80, 260 and 356, and still does after the view is
  rotated 30° — so it is derived, not tuned to one viewing angle.
- Recovering the shadow's length in world units from its measured pixel length
  gives an L/h ratio of 2.04, 0.87, 0.84 and 2.10 against a predicted
  `1/tan(altitude)` of 2.03, 0.85, 0.81 and 2.08.
- Holding the sun fixed and rotating the viewing elevation from 40° to 55°
  leaves the recovered world length at 0.394 → 0.389 (about 1%), while the
  on-screen pixel length correctly grows 35.5 → 42.5 px as the ground plane
  opens up.

The residual 1–3% is measurement bias: the probe finds the farthest dark pixel,
and the art's rounded head extends slightly past its bounding box.

### An independent cross-check

The shadow's placement was derived physically rather than by replaying
ShadowMaker's nested skew transforms, so it is worth confirming the two agree.
Feeding the shadow's own setup (`n` = zenith, `u` = azimuth 0) through
`absoluteOrientation()` gives an outer rotation of 0°, a vertical scale of
`sin(phi)` = 0.643 and an inner rotation of −20°; combined with ShadowMaker's
net vertical stretch of `1/tan(altitude)` for a due-south sun, that puts the
shadow's length axis at bearing −119.5° and its width axis along
(0.9736, −0.2279). The physical derivation independently gives −119.5° and
(0.9736, −0.2279). The two methods agree exactly.

### Five defects this replaced

Earlier revisions got the figure and shadow wrong five separate ways, all now
fixed:

1. The shadow was rotated by an ad-hoc `−theta + 90°`, with the plane's
   vertical squash applied *before* the rotation instead of after — which
   pointed it in the wrong direction entirely.
2. It was rigidly rotated with an unchanged width, so only its length was
   foreshortened and it never lay down into the plane.
3. Its world height was back-derived from the *live* viewing elevation, so
   rotating the camera from 40° to 55° stretched the shadow by 33% even though
   neither the sun nor the figure had moved.
4. The figure was drawn as a plain upright sprite, ignoring the original's
   orientation math, so it stayed rigidly fixed while the ground rotated
   beneath it.
5. Both sprites were drawn flush to the bottom of their images, ignoring their
   differing registration points, so the shadow's base did not meet the
   figure's feet.

## Two bugs in the foundation, worked around not fixed

Both live in files that are copied in unchanged, so neither was edited; both are
compensated for from `styles/styles.css`. Both affect **every** sim built on this
foundation, so both are worth reporting upstream.

**1. Stray `u` in `kl-unl.css`.** There is a bare `u` token on the line
immediately before the `.app-layout__right` rule (line 101). That turns the
selector into `u .app-layout__right`, so the rule only applies inside a `<u>`
element and its `min-width: 0` never takes effect anywhere.
`styles/styles.css` restores the intended `min-width: 0`.

**2. The masthead does not wrap below ~360px.** In `kl-unl-masthead.js`,
`.masthead-container` is a `display: flex` row (title against Reset / Help /
About) with no `flex-wrap`, and `.controls-group` is likewise a non-wrapping
flex row. At 320px the row still demands about 380px, which pushed the entire
page into horizontal scrolling — a WCAG 1.4.10 reflow failure that had nothing
to do with the simulation's own layout. Since the markup and its styles are
inside the component's shadow root, the only fix available from outside is to
style the host element, so `styles/styles.css` sets `overflow-x: auto` on
`kl-unl-masthead`. That confines the scroll to the masthead strip and leaves the
simulation itself free of horizontal scrolling at every width down to 320px.
The real fix is a `flex-wrap: wrap` on those two rules in the component.
