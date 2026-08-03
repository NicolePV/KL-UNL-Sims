# Conversion notes — Ecliptic (Zodiac) Simulator

## Behaviour model

The simulation draws the celestial sphere as a wide band of sky centred on the
ecliptic, seen from outside and slightly above, with the twelve zodiac
constellations drawn as stick figures on the inside of the band and labelled by
name. A small Earth, complete with coastlines and a day/night terminator, sits
at the centre; the Sun sits on the band directly opposite the Earth's
heliocentric direction. A year timeline beneath the picture sets the day of the
year: moving through the year swings the Earth around its orbit, which carries
the Sun around the band so that it passes in front of each zodiac constellation
in turn. Dragging on the sphere itself rotates the viewpoint in azimuth and
elevation. There is no animation, no randomisation and no timed behaviour — the
picture is a pure function of (day of year, viewing azimuth, viewing
elevation).

## Source of truth

The folder was supplied as `zodiac.swf` only, so it was decompiled with JPEXS /
FFDec 26.2.1 into the usual `scripts/`, `shapes/`, `sprites/`, `texts/`,
`fonts/`, `frames/` and `symbolClass/` folders alongside the SWF. Nothing in
those folders has been modified. `zodiac.jpg`, the screenshot of the running
Flash original, was the layout reference.

## ActionScript → HTML5 map

| ActionScript | HTML5 |
| --- | --- |
| `CelestialSphereClass` (`CelestialSphere.as`, `2 CS Getter Setter.as`, `3 CS Geometry.as`) | `class CelestialSphere` — the `a`, `b` and `m` matrices, `doA/doM/doB`, `parsePointInput`, `WtoSz/CtoSz/CtoW/WtoC`, `pointToHorizon/pointToCelestial` are ported line for line |
| `CSObjectsClass` (`7 CS Objects.as`) | `class CSObject` — position, `"absolute"` orientation, and the shell/instance transform computed in `update()` |
| `p.updateObjectsSort` | `ZodiacViewer.sortedObjects()` — the same `bS / fS / bI / aI` depth bands, each sorted by screen z |
| `CSCirclesClass` (`8 CS Circles.as`) | `class CSCircle` — `doW`, the `v` matrix, and the ascending/descending-node split that decides which part of a circle is in front |
| `MovieClip.drawArc` / `curveTo` tessellation | `arcFromV()` / `sweep()` feeding `ctx.quadraticCurveTo` with the same anchors and control points |
| `GlobeComponentClass` (`GlobeComponent.as`) | `class GlobeComponent` — precession/rotation matrices, `buildShorePath()` (the coastline mask) and `buildNightSide()` (the terminator) |
| `ZodiacViewerClass` (`ZodiacViewer.as`) | `class ZodiacViewer` — `setDayOfYear`, `updateGlobe`, `updateConstellations`, `updateZodiacBand`, `drawZodiacBandMasks` |
| `Modified Year Slider` + `YearSliderGrabber` | a native `<input type="range">` styled as the timeline, with the original grabber artwork as the marker |
| `setMask` / mask clips | `ctx.clip(Path2D)` over the same outline |
| `_x/_y/_rotation/_yscale` | `ctx.translate/rotate/scale` at draw time (`_rotation` converted from degrees) |
| `onEnterFrame`, `getTimer()`, `updateAfterEvent()` | not needed — the original has no animation; the canvas is redrawn on demand via `requestAnimationFrame` |
| `trace()` | dropped |

Constants copied verbatim include the orbital rule
`az = -0.9863013698630136 * (dayOfYear + 10.8)`, the sidereal-day ratio
`1.0027397260273974`, the obliquity pair `0.91706` / `0.39875`, the sphere size
600, Earth disk 35, Earth orbit 250, initial `theta` 206 and `phi` 30, latitude
66.5, sidereal time 18, `maxViewerAltitude` 50, the band half-angle 24, the
15° band gradient half-width, the ecliptic tilt 23.5, and the colours
`14671839` (constellations), `5263440` (ecliptic), `11455999` / `4671303`
(band gradient). The month table `[0,31,59,90,120,151,181,212,243,273,304,334]`
comes straight from `p.setMonthAndDay`.

The full star tables and coastline outlines were extracted mechanically from
`scripts/ZodiacViewer.as` into `assets/sim-data.js`, so they are byte-identical
to the source rather than retyped.

## One place where the decompiled source is ambiguous

`CSObjectsClass.prototype.update` computes, for the "flat" orientation type:

```actionscript
_loc1_.shell._rotation = 57.29577951308232 * Math.atan2(sp_o.y - _loc3_.y, sp_o.x - _loc3_.x) + 90;
```

The Earth uses that branch with the default zero orientation vector, which makes
`sp_o` exactly equal to the object's own screen position — so the call is
`Math.atan2(0, 0)`, and read literally the globe would be rotated by 90°.

Rendering it both ways and comparing against `zodiac.jpg` settles it: with the
90° applied, the continents lie on their side and the night-side crescent falls
on the wrong limb; with no rotation, Africa stands upright with Europe above it
and the crescent hugs the top edge — which is exactly what the original
screenshot shows. Flash evidently produces a non-finite value here and its
`_rotation` setter ignores the assignment, leaving the clip unrotated. The port
reproduces that: the rotation is only assigned when the two points actually
differ. See the comment in `CSObject.update()`.

## Deliberate deviations

1. **Timeline resolution.** The Flash slider has `initPrecision = 2`, so it
   stepped in hundredths of a day. A control with 36 500 steps is unusable from
   a keyboard, so the HTML5 timeline steps in whole days. Nothing else changes:
   the day of the year still feeds the same `updateGlobe` chain, and a hundredth
   of a day is below the resolution of anything the picture shows.
2. **Viewing direction also has sliders.** The original view is rotated only by
   dragging. The drag is reproduced exactly (same offset maths, same clamping to
   `maxViewerAltitude` 50 and `minViewerAltitude` −90), and the canvas is a real
   focus stop that responds to the arrow keys — but two labelled sliders for
   azimuth and elevation were added as well, because they are far more reliable
   with NVDA and VoiceOver than a `role="application"` region alone. All three
   paths write the same state object.
3. **Typed entry, and readouts added.** The Flash slider's own title, value and
   min/max text fields exist in the SWF but are drawn in black on a black stage,
   so nothing was ever visible (see `texts/7.txt`, `texts/9.txt`,
   `texts/11.txt`). Rather than reproduce invisible text, the HTML5 version
   gives the day of the year, the calendar month, the day of the month, the
   azimuth and the elevation as editable fields, and shows the Sun's right
   ascension and declination as labelled readouts. Month and day of the month
   go through `ZodiacViewer.setMonthAndDay`, which is a direct port of
   `p.setMonthAndDay` in `ZodiacViewer.as` — a function the original defines but
   never wires to any control. The Sun readouts are computed with the ported
   `pointToCelestial`. No new physics is involved: every field writes into the
   same state object the drag and the timeline do.
4. **"Nearest label" is a proximity measure.** The readout reports which of the
   twelve constellation labels the Sun is angularly closest to, together with
   that angle. The Flash original knows only these twelve label centres — it has
   no constellation boundaries — so the reading is deliberately phrased as
   nearest *label*, with the separation shown, rather than claimed as "the Sun
   is in constellation X".
5. **Canvas extent.** The Flash stage is 800 × 650 with the viewer at (400, 300)
   and the slider at y ≈ 609. The sphere is only 600 px across, so the canvas is
   620 × 620 with the origin at its centre and the timeline moved into HTML
   beneath it. Every ported coordinate is unchanged; only the empty left and
   right margins of the old stage are gone. This also lets the picture scale
   cleanly on narrow screens.
6. **No Pause button.** The original has no animation to pause — every change of
   the picture is the direct result of a user action.

## Assets reused as-is (never redrawn)

| File | Was | Used for |
| --- | --- | --- |
| `assets/shape-1.svg` | `shapes/1.svg`, `GlobeComponentWater` | the ocean disk |
| `assets/shape-3.svg` | `shapes/3.svg`, `GlobeComponentLand` | the land disk, clipped to the coastline mask |
| `assets/shape-13.svg` | `shapes/13.svg`, `YearSliderGrabber` | the red timeline marker |
| `assets/shape-49.svg` | `shapes/49.svg`, `Symbol 65` | the near-side haze over the band |
| `assets/shape-51.svg` | `shapes/51.svg`, `Symbol 64` | the far-side haze behind the band |
| `assets/shape-55.svg` | `shapes/55.svg`, `Sun Disk` | the Sun |
| `assets/sim-data.js` | `scripts/ZodiacViewer.as` | star positions and coastlines |

Only genuinely code-drawn geometry is recreated on the canvas: the constellation
stick figures, the ecliptic circle, the zodiac band gradient and its masks, the
coastline mask and the night-side terminator. There are no bitmaps in the
export (`images/` is empty), and the two unused symbols in the SWF (`cow`,
`Symbol 62`, `ZodiacViewerSun`, `temp label`, `temp label 2`) are not referenced
by the ActionScript and so are not shipped.

Constellation and month labels are drawn on the canvas in
`14px Arial, Helvetica, sans-serif` rather than with the subsetted Verdana and
Arial faces in `fonts/`, which contain only the glyphs the SWF happened to use.
The label size (280 twips) and colour (`#dfdfdf`) come from `texts/47.txt` and
`texts/53.txt`.

## contents.json

**No edit was needed.** The shared `contents.json` already carries a `zodiac`
entry with `meta.title = "Ecliptic (Zodiac) Simulator"`, `meta.version = "2.0"`
and both Help and About text. The file was copied into `foundation/` unchanged,
byte for byte, along with `kl-unl-masthead.js`, `kl-unl.css`, `kl-unl.js` and
the two favicons. `index.html` uses `sim-id="zodiac"`.

## MathJax

The supplied `foundation/` folder contains no MathJax include, and fetching one
from a CDN is not allowed, so the local MathJax build already vendored by a
sibling simulation in this collection was copied into `assets/mathjax/`
(SVG output, `fontCache: 'local'`, context menu enabled). It is loaded from
`index.html` and driven through the foundation's `klunlShowEquation` /
`klunlInitEqn`. Note that `kl-unl.js` only *defines* `klunlInitEqn` — nothing
calls it — so `simulation.js` invokes it once `MathJax.startup.promise`
resolves.

## Browser notes

Verified in the Chromium-based preview: no console errors over HTTP, no network
requests outside this folder, no horizontal scrolling from 375 px up, and the
layout intact at 200 % zoom. The code sticks to widely supported APIs —
Pointer Events, `Path2D`, `ctx.clip(path)`, CSS grid, `aspect-ratio` (with a
`@supports` fallback for older WebKit) — and uses no vendor-prefix-only
declarations, but **human verification on Safari (desktop and iOS) and Firefox
is still outstanding**.
