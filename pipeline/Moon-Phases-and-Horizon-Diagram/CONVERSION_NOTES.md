# Conversion Notes — Moon Phases and the Horizon Demonstrator

## Behaviour model (one paragraph)

The sim shows a 3‑D **celestial sphere** with a green **horizon plane** cutting
through it, drawn in an orthographic projection for an observer at an adjustable
latitude. On the sphere are the **celestial equator**, two **hour‑circle
meridians**, the **north/south celestial‑pole axis** stubs, an optional
**±30° ecliptic band**, a **stick figure** observer (with a cast shadow), and
the **Sun** and **Moon**. For teaching purposes the Sun and Moon are each
restricted to **eight evenly‑spaced points on the celestial equator** (selected
by the "sun position" / "moon position" sliders, values 1–8); the eight points
can be shown as numbered red‑cross markers. Moving the Sun changes the **time of
day**; the relative Sun–Moon positions determine the **Moon phase**, shown by
name and on an illuminated phase disc (and optionally on the Moon itself in the
diagram). The user can **click‑drag the diagram to re‑orient** the horizon, and
**drag the Sun/Moon discs** around the equator. Latitude, and the seven display
checkboxes, are all adjustable.

## Source of truth

Decompiled with JPEXS/FFDec into `../decompiled/` (working copy, not shipped).
Behaviour is ported verbatim from the ActionScript‑1 sources:

- `CelestialSphere.as`, `2 CS Getter Setter.as`, `3 CS Geometry.as`,
  `4 CS Mouse.as`, `5 CS Horizon Plane.as`, `6 CS Shading.as`,
  `7 CS Objects.as`, `8 CS Circles.as`, `9 CS Lines.as`,
  `11 CS Shaded Bands.as` — the projection engine.
- `Moon Positions Demonstrator.as` — the controller (constants, formulas,
  checkbox/slider handlers, reset).
- `Moon Disc.as`, `Sun Disc.as`, `drawPhaseDisc Function.as`, `ShadowMaker.as`,
  `CSGradientDisk.as` — the objects.
- Placement `on(initialize)` blocks — slider/checkbox/panel configuration.

## Constants & formulas ported verbatim

| Quantity | Value / formula (from AS) |
|---|---|
| Sphere radius | `size = 320` → `r = 160` |
| Initial view | `viewerAzimuth = 200` → `theta = 160°`; `phi = 30°`; `minViewerAltitude = 7°` |
| Latitude | slider −90…90, init **41.0°**, 1 decimal |
| Sidereal time | 0 |
| Sun/Moon position → RA (hours) | `ra = −3·(value−1) + 6` |
| 8 marker points RA (hours) | `ra = 9 − 3·k`, k = 1…8 |
| Time of day (hours) | `h = (6 + 3·(value−1)) mod 24`, formatted 12‑hour AM/PM |
| Moon phase angle (deg) | `phaseAngle = 15·(sun.ra − moon.ra) + 180` |
| Phase descriptor | thresholds on `((180 − phaseAngle) mod 360)` with limits 12° and 5° → 8 names |
| Phase names | New Moon, Waxing Crescent, First Quarter, Waxing Gibbous, Full Moon, Waning Gibbous, Third Quarter, Waning Crescent |
| Sun altitude shading | `shade = min(40, 40·(1 − alt/90)^4)` % black on the ground |
| Shadow opacity | `1 − 1/(15·tan(alt))` (ShadowMaker) |

All projection maths (`doA`, `doM`, `doB`, `WtoSz`, `CtoSz`, `CtoW`, `WtoC`,
`StoMH`, `MHtoC`, `CtoMH`, great/small‑circle and line clipping) are ported
with identical coefficients and angle conventions (AS colour ints converted to
hex; alpha 0–100 → 0–1; `_rotation` in degrees).

### Verified against the AS (self‑test in browser)

- **Time of day**, positions 1–8: `6:00 AM, 9:00 AM, 12:00 PM, 3:00 PM,
  6:00 PM, 9:00 PM, 12:00 AM, 3:00 AM` ✓
- **Phase name**, Sun = 4, Moon = 1…8: Waxing Gibbous, First Quarter, Waxing
  Crescent, New Moon, Waning Crescent, Third Quarter, Waning Gibbous, Full
  Moon ✓
- Initial readouts match the original screenshot: latitude 41.0°, sun 4, moon
  2, time **3:00 PM**, phase **First Quarter** ✓
- Reset restores the exact initial state ✓

## Sun / Moon position sliders are CONTINUOUS

The AS slider is not a discrete 1–8 control. `hackSlider` sets
`minValue = 0.51`, `maxValue = 8.49`, `precision = 3`: the grabber moves
**smoothly** while dragged (the sun/moon glide around the celestial equator and
the time-of-day readout updates through intermediate values), and only on
release does `doTween` animate the value to the nearest whole position over
200 ms with a `pow(f, 0.3)` ease. The readout always displays
`Math.round(value)`.

The port matches this: the range inputs are `min="0.51" max="8.49" step="0.01"`,
`input` updates continuously, and `change` (pointer release) triggers the
snap-tween. Dragging the Sun/Moon disc on the canvas moves the slider handle in
sync. Verified: 4 → 4.25 → 4.5 → 4.75 → 5 yields 3:00 PM → 3:45 → 4:30 → 5:15 →
6:00 PM, then snaps to position 5.

For **keyboard** the control stays discrete (8 meaningful positions): arrows
move by one whole position with 1↔8 wrap (the AS `incrementValue`), Page keys by
two, Home/End to 1/8 — so screen-reader users are never stranded between
positions. The snap-tween also has a `setTimeout` completion guard so a
backgrounded tab (where `requestAnimationFrame` is throttled) can never leave
the sim on a fractional position.

## Reused vs. code‑drawn art

- **Reused exported assets:**
  - `shapes/59.svg` → `assets/stickfigure.svg` — the **Stickfigure** (sprite 60):
    white head fill, bold black limb strokes, 14.6 × 36.3, registration point
    (7.3, 35.3) at the feet.
  - `shapes/24.svg` → `assets/stickfigure-shadow.svg` — the **Stickfigure
    Shadow** (sprite 25): solid `#333333` silhouette, 12.6 × 34.3, registration
    (6.3, 34.3).

  Both are drawn with `drawImage` at their natural size with the registration
  point at the object's screen position. (Note the shape→sprite pairing: shape
  59 belongs to sprite 60 *Stickfigure*, shape 24 to sprite 25 *Stickfigure
  Shadow* — they are easy to swap by mistake, which produces a dark blob for the
  observer and no real shadow.)
- **Code‑drawn (per the AS `createEmptyMovieClip`/`drawArc`/`beginFill` calls):**
  the horizon ellipse, celestial equator, meridians, pole axes, ecliptic band,
  gradient "celestial bowl" and horizon shading, Sun disc, Moon phase disc,
  red‑cross position markers, and number labels. These are recreated on the
  `<canvas>` with the original geometry and colours because the AS builds them
  at runtime and transforms/composites them every frame (foreshortening,
  ellipse‑scaling of the horizon, front/back hemisphere clipping). Exact colours
  taken from the exported shapes: horizon `#51c451`→`#3aa53a`, Sun
  `#ffcc00`→`#edb101` (outline `#999`/`#000`), equator `#e8d898`, meridians
  `#e0e0e0`, pole axes `#2174fe`, Moon greys `#909090`/`#d0d0d0`/`#a8a8a8`,
  ecliptic band `#b0b0b0` border over a translucent blue fill (Band Disc,
  `shape 86`).

## `contents.json`

The shared project `contents.json` **already contains** the
`positionsdemonstrator` entry (title *"Moon Phases and the Horizon
Demonstrator"*, version 2.0, with Help and About text derived from the original
`texts/21.txt`, `texts/3/5/8/9.txt`). No edit was required; the foundation
folder — including `contents.json` — is copied in byte‑for‑byte unchanged.

## Arc tessellation (circles must render as true smooth ellipses)

A circle on the sphere projects to an **ellipse**, drawn parametrically as
`(v0·cos g + v1·sin g + v2, v3·cos g + v4·sin g + v5)`. The AS `drawArc`
tessellated this with quadratic `curveTo` at coarse π/4 (45°) steps — the
control points make 45° steps look smooth in Flash. The port samples the same
parametric ellipse with straight segments instead, so it must sample far more
finely: `ARC_STEP = π/90` (**2°**). Using the AS's 45° step with straight lines
produced visibly polygonal "circles" — verified and fixed.

### Geometry verified by astronomical invariants

- **Latitude 41° (default):** the celestial equator meets the horizon exactly at
  the **E** and **W** points (true for every latitude); the meridians pass
  through the NCP/SCP axis stubs.
- **Latitude 0°:** both celestial poles lie exactly **on** the horizon at due
  north and due south, and the celestial equator passes through the zenith.
- **Latitude 90°:** the celestial equator coincides exactly with the horizon
  circle (its back half is correctly occluded by the opaque horizon plane), and
  the ground reaches maximum dusk shading because an equatorial sun sits on the
  horizon at the pole.

## Rendering order

The Flash depth‑band scheme (mouse area → back external lines → back circles →
back objects → back band → horizon plane → front objects → celestial‑bowl
shading + front band → front circles → front objects → front external lines) is
reproduced as an explicit back‑to‑front painter's pipeline in `render()`, with
objects bucketed by hemisphere (`bE/bS/bI/aI/fS/fE`) and z‑sorted within each
bucket, exactly as `updateObjectsSort` does. Because the viewer altitude is
clamped to `[7°, 90°]`, only the "above" horizon‑plane case occurs.

## Deviations from the original (and why)

1. **MathJax not used.** Rule 8 mandates MathJax for all mathematics, but the
   provided `foundation/` ships **no MathJax include** and external CDNs are
   disallowed (rule 5, self‑contained). This sim contains **no equations or
   formulas in its UI** — the only mathematical notation is the latitude angle's
   degree sign. It is shown as text (`41.0°`) with the unit fully spelled out for
   screen readers via `aria-valuetext` ("Latitude 41.0 degrees"). If a MathJax
   include is later added to the foundation, the latitude readout is the single
   place that would adopt it. (Higher‑priority rules 5 + accessibility are
   satisfied; no math content is lost.)
2. **Stick‑figure shadow — full ShadowMaker port.** `ShadowMaker.as` builds a
   shear from two nested rotated/scaled clips: `outer` at
   `rotation = 45 + (az−180)/2` with
   `scale = (sin(yr)+cos(xr))/den, (sin(xr)+cos(yr))/den`
   (`den = sin(outer.rotation)·0.7071`), and `inner` at `rotation = −45` with
   `scale = 0.5/cos(yr), (sin(az−90)/tan(alt))·0.5/cos(xr)`. That composite
   matrix `R(Ro)·S(Sox,Soy)·R(−45)·S(Six,Siy)` is reproduced exactly via
   `ctx.transform`, applied inside the shadow object's own placement (normal =
   zenith, up = north, so it lies flat on the ground and is foreshortened by the
   view). Opacity is the original `1 − 1/(15·tan(alt))`; the shadow disappears
   below `alt < 0.1°`. The exported silhouette art is reused as-is.
3. **Number labels and position markers are drawn upright** rather than
   billboarded/foreshortened onto the sphere surface as the AS does, so the
   digits stay legible (educational content) and accessible at all
   orientations. The Sun and Moon discs *are* foreshortened as in the original.
4. **Layout follows the KL‑UNL shell, not Flash pixels.** Panel grouping and
   reading order mirror the original (Horizon Diagram at left; General / Sun /
   Moon settings stacked at right), expressed with KL‑UNL classes. The desktop
   two‑column template is overridden in `styles/styles.css` (diagram wide left,
   controls narrow right) to match the screenshot's proportions without editing
   the foundation; it collapses to a single stacked column at ≤56rem.

## Cross‑browser notes

Uses only broadly‑supported APIs (Canvas 2D, Pointer Events, `aspect-ratio`,
CSS grid). `setPointerCapture` is wrapped in `try/catch` so drag never breaks if
a browser refuses capture. No vendor‑prefixed‑only CSS. No Chrome‑only APIs.
