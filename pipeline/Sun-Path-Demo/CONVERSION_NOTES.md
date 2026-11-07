# Conversion Notes — Paths of the Sun Demonstrator

## Behaviour model (one paragraph)
The sim is a **horizon diagram** (a celestial sphere drawn as a dome over a
green ground plane, with a stick-figure observer at the centre). A **latitude**
slider (−90 … +90, default 41.0° N) tilts the celestial sphere relative to the
local horizon, moving the celestial equator, ecliptic and the sun's daily path
up or down. An **animate** checkbox steps the day of year forward; on each step
the sun's right ascension and declination are recomputed, the **sun's-path**
circle is reset to the sun's current declination, the **date** readout updates
(e.g. "March 21"), the sky brightens/darkens with the sun's altitude, and the
observer's shadow lengthens/shortens. Because the solar day and sidereal day are
kept in step, the sun stays near the meridian each day while its declination
oscillates over the year, so the animation shows the noon sun's path migrating
between the solstices. The diagram view can also be rotated (pointer drag or
arrow keys). Four great circles are shown: celestial equator (gray/"black"),
ecliptic (red), sun's path on the given day (yellow), and the north–south
meridian (gray).

## Ground truth
* **Behaviour** = the decompiled ActionScript (AS1): `CelestialSphere.as`,
  the `2`–`10 CS *.as` prototype files, `CSGradientDisk.as`,
  `scripts/frame_1/DoAction.as`, `scripts/DoInitAction.as`, and the slider /
  checkbox component scripts. Every constant and formula was copied verbatim.
* **Chrome / layout / style** = the KL-UNL foundation files + the accessibility
  rules, NOT the original Flash pixel layout.
* **Visual layout reference** = `Screenshot 2026-06-22 115914.png` (Goal C).

## Key constants / formulas (verbatim from the AS)
| Quantity | Formula (AS literal) | In code |
|---|---|---|
| Sun right ascension (hours) | `day * 0.06575342465753424` (= 24/365) | `updateSun()` |
| Sun declination (deg) | `23.5 * sin(day * 0.01721420632103996)` (= 2π/365) | `updateSun()` |
| Sidereal time (rad) | `2π * frac(1.0027397260273974 * day)` | `setDay()` |
| Date string | `today = (day + 79.5) mod 365`, month table verbatim | `getDateString()` |
| Sky intensity | `clamp(sunAlt/10 + 0.5, 0, 1)`, day/night alpha ramps verbatim | `setSkyColor()` |
| Shadow scale | `100 / tan(sunAlt)`, capped at 400, sign by azimuth; alpha `(400−|s|)·100/400` | `setShadow()` |
| Circle colours | equator `5263440`, sun's path `16777152`, meridian `12632256`, ecliptic `16732240` | `#505050 #FFFFC0 #C0C0C0 #FF5050` |
| Ecliptic tilt | `23.5°`; sun's-path & equator tilt `0°`; meridian tilt `90°` | `setParams()` |
| View | `viewerAzimuth 200` → θ = 160°, φ = 30°, `minViewerAltitude 7` | `resetState()` |
| Latitude default | `41`, precision 1 (step 0.1) | `<input type=range>` |

## AS → HTML5 mapping
* `Object.registerClass` prototype classes → plain JS objects/closures with the
  same methods. The whole celestial-sphere projection (`doA/doM/doB`, `WtoSz`,
  `CtoSz`, `CtoMH`, `MHtoC`, `StoMH`, `parsePointInput`) is ported 1:1.
* Great-circle drawing (`8 CS Circles.as`: `doW`, `prerender`, `CPtoSYS`,
  `CGtoSYS`, `drawArc`, the front/back split in `update`) is ported 1:1. The
  Flash `MovieClip` drawing API (`moveTo`/`curveTo`) is reproduced by a small
  `Pen` recorder, then stroked onto the `<canvas>` with `quadraticCurveTo`.
  All circles here are full circles (gammaStart == gammaEnd == 0), so only that
  branch of `update()` is exercised.
* `onEnterFrame` + `getTimer()` → a single `requestAnimationFrame` loop using
  elapsed wall-clock time. The original advanced **one day per frame**; we
  advance ~24 days/second (≈ the Flash frame rate) via a time accumulator so the
  speed is machine-independent. (If a more exact speed is desired, change
  `DAYS_PER_SEC` in `simulation.js`.)
* Flash masks (`setMask`, the `M1`/`M3` above-horizon lens clips) → `ctx.clip()`
  paths (`horizonClip("front"|"back")`).
* `CSGradientDisk` `beginGradientFill("radial", …)` → `createRadialGradient`.
* Mouse behaviour `"simple drag"` (`4 CS Mouse.as`) → pointer drag on the canvas
  with the identical `setThetaAndPhi` offset math, **plus** an equivalent
  keyboard path (arrow keys) so the rotation is fully keyboard-operable.
* **Added interaction (not in the Sun Paths source): a draggable sun.** Following
  the sibling Sun Motion Demo, clicking/dragging the sun scrubs the day of year
  (the day whose meridian sun is nearest the cursor, biased toward the current
  day for continuity); clicking elsewhere on the sphere rotates the view. The
  same split applies to the keyboard: after clicking the sun (or pressing Enter to
  toggle), the arrow keys move the sun by day (Page = ±week, Home/End = year
  ends); otherwise they rotate the view. The original only changed the day via the
  animate checkbox; this is an additive convenience and does not alter the
  physics, constants, or the sun's computed position.
* `trace()` calls dropped; `updateAfterEvent()` → no-op.

## Exported assets reused as-is (not redrawn)
Copied from the decompiled `shapes/*.svg` into `assets/` and composited at the
original positions/sizes:
| Asset | Source shape | Use |
|---|---|---|
| `stickman.svg` | `shapes/1.svg` (#cccccc) | observer billboard |
| `shadow.svg` | `shapes/55.svg` (#666666) | observer's shadow |
| `sun.svg` | `shapes/53.svg` (#ffcc00, r≈7.5) | the sun disk |
| `ground-above.svg` | `shapes/26.svg` (radial #51c451→#3aa53a) | horizon plane (φ>0) |
| `ground-below.svg` | `shapes/24.svg` (#006600) | horizon plane underside (φ<0) |
Only genuinely code-drawn geometry (the great circles, the sky-bowl gradients,
the horizon-plane ellipse transform) is reproduced with canvas 2D drawing.

## contents.json — REQUIRED JSON-syntax repair (please read)
The `sunpaths` entry (sim-id **`sunpaths`**, title *"Paths of the Sun
Demonstrator"*) **already exists** in the shared `foundation/contents.json`, so
no new entry was added. However, the shared file as shipped is **invalid JSON**
and the masthead (`fetch` + `JSON.parse`) could not load it for *any* sim:
* a raw newline character inside the `ce_hc` Help string (control char), and
* unescaped `"` from HTML attributes (`href="../venusphases"`, etc.) in at least
  one entry.

To make the masthead work, the copied `html5/foundation/contents.json` was
repaired **only at the JSON-syntax level**: raw control characters inside
strings were turned into spaces and literal `"` inside string values were
escaped to `\"`. **No visible/teaching text was changed** (escaping an HTML
attribute quote and collapsing a stray newline do not change rendered output);
all 108 entries parse and the `sunpaths` Help/About text is byte-for-byte intact.
This is the only change to any foundation file; `kl-unl-masthead.js`,
`kl-unl.css`, and `kl-unl.js` are copied in verbatim. **Recommendation:** push
the same syntax fix back to the shared master `contents.json` so every sim's
masthead loads.

## Deviations from the original (Goal A/B over Goal C)
1. **No MathJax.** This demonstrator contains no equations, variables, or math
   notation — only a degree-unit symbol ("°"). The foundation does not bundle a
   MathJax library and rule 5 forbids a CDN, so none is loaded. Screen readers
   are given the spoken word "degrees" (see ACCESSIBILITY.md). `klunlInitEqn()`
   is redefined to a no-op as the foundation expects.
2. **Stickman + shadow billboards.** Rendered with the same proven method as the
   sibling **Sun Motion Demo** sim (rather than the full `setOrientationType`
   billboard matrix, which produced a wrong, sheared figure):
   * stickman — stands **upright** at the horizon-plane centre (feet at the
     origin), foreshortened vertically by `cos(viewer altitude)` so it stays
     planted as the disk tilts;
   * shadow — the same silhouette mapped **flat onto the ground** by an affine
     transform: feet pinned at the figure's feet, head at the anti-sun ground
     point (azimuth `sun_az + 180`) a distance `L = 0.5/tan(alt)` away, width
     along the perpendicular ground direction; alpha `= 1 − 1/(15·tan(alt))`,
     hidden when the sun is at/below the horizon.
   Because both are pinned at the same feet and projected through the same
   horizon matrix, the shadow stays attached to the figure and points correctly
   away from the sun as the view rotates and as the sun moves. (This is cleaner
   and more correct than the Sun Paths source's own `setShadow`, which only let
   the shadow point due north/south; for this demo the sun stays near the
   meridian so the visible result is equivalent.)
3. **Direction labels (N/E/S/W).** Drawn at the four cardinal points (azimuth
   0/90/180/270, alt 0) projected with the same horizon matrix as the source, so
   they rotate with the view. They are kept upright (not squished with the tilted
   plane) and given a contrasting outline for legibility — a deliberate
   accessibility choice over reproducing the original's flattened label glyphs.
   The cardinal directions are also spoken in the live diagram description.
4. **Ground proportion.** The green horizon plane is drawn at its true size
   (radius r × r·sin φ, i.e. 2:1 at φ = 30°, matching the AS), so it occupies a
   little more of the dome than the reference screenshot appears to show. This
   follows the source geometry (Goal A) over the screenshot (Goal C).
