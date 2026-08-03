# Conversion Notes — Rotating Sky Explorer (`celhorcomp`)

## Behaviour model

The Earth sits at the centre of a celestial sphere. The left panel shows that
sphere from outside, with a small rotating globe at its centre marked with the
observer's latitude and longitude; the right panel shows the same sky as a
horizon diagram for that observer, with a green horizon plane and a stick figure
standing on it. Both panels are freely rotatable by dragging. A user adds stars —
randomly, by shift-clicking either sphere, or by switching on one of three
constellation stick figures (Big Dipper, Orion, Southern Cross) — and clicks a
star to select it, which draws its right-ascension/declination arcs on the
celestial sphere and its azimuth/altitude arcs on the horizon diagram and shows
all four numbers in editable fields. Running the animation advances a simulated
clock, which spins the globe and carries the sky westward past the observer's
horizon so stars rise and set; star trails can be drawn to trace those paths.
Shaded declination bands show which stars never rise, which rise and set, and
which are circumpolar for the current latitude, and an optional wedge reads out
the angle between the celestial equator and the horizon (90° − |latitude|).

## Source

Decompiled from `celhorcomp.swf` (Adobe Flash, ActionScript 1) with JPEXS/FFDec.
The behavioural ground truth is the decompiled ActionScript; every constant,
matrix, table and string below is copied verbatim from it.

## contents.json

**No edit was required.** The shared `foundation/contents.json` supplied with
this simulation folder already contains a complete `celhorcomp` entry —
`meta.title` "Rotating Sky Explorer", `meta.version` "2.0", and `masthead.help` /
`masthead.about` already reflowed from the original Help and About text. The
foundation folder was therefore copied into `html5/foundation/` **byte-for-byte
unchanged**, including `contents.json`. `index.html` passes
`sim-id="celhorcomp" json-url="foundation/contents.json"`.

## ActionScript → HTML5 mapping

| ActionScript (source file) | HTML5 port (`simulation.js`) |
| --- | --- |
| `CelestialSphereClass` + `2 CS Getter Setter.as` | `Sphere` class; `setThetaAndPhi`, `setTheta`, `setLatitude`, `setSiderealTime`, `setSTimeAndLat` |
| `3 CS Geometry.as` — `doA` / `doM` / `doB` | `Sphere.doA/doM/doB`, identical matrix elements |
| `3 CS Geometry.as` — `WtoSz` `CtoSz` `CtoW` `WtoC` `CtoMH` `MHtoC` `StoMH` `parsePointInput` | same names on `Sphere`; `parsePointInput` → `Sphere.parse` |
| `4 CS Mouse.as` — `getMouseRaDec`, drag handlers | `Sphere.screenToRaDec`; pointer handlers in `attachSphere` |
| `5 CS Horizon Plane.as` — `updateHorizonPlane` | `drawHorizonPlane` (canvas transform reproduces `_xscale = r`, `_yscale = r·sin φ`, `_rotation = 180 + θ`) |
| `6 CS Shading.as` — `createMasks` / `updateMasks` | `rimPath` / `boxPath` + `withClip`; the six Flash mask clips become canvas clip paths |
| `6 CS Shading.as` — `addShadingClip` | reused `shading-layer-a.svg` / `shading-layer-b.svg` drawn under the matching clip |
| `7 CS Objects.as` — `CSObjectsClass`, `updateObjectsNoSort` | `SphereObject`; `bucketObjects` reproduces the depth arithmetic exactly (see below) |
| `8 CS Circles.as` — `CSCirclesClass.update`, `drawArc`, `setArcPoints`, `doW` | `Circle.computeArcs` + `emitArc`; `curveTo` → `quadraticCurveTo` (identical tessellation) |
| `9 CS Lines.as` — `CSLinesClass.update` | `Line.computeSegments`, same quadratic-root split and `bE/fE/bI/aI` layer tagging |
| `11 CS Shaded Bands.as` — `CSShadedBandClass.update` | `ShadedBand.buildPaths`, all nine front/back topology cases ported |
| `GlobeComponent.as` — `update`, `setRotationAngle`, `_shoreData` | `drawGlobe` + `globeQ`; `SHORE` is the verbatim table |
| `Location Selector.as` | `renderMap`; the same equirectangular projection, the same Antarctica special case, the same cursor/cross-hair maths |
| `CSGradientDisk.as` | flat fill (each band's `innerColor`/`innerAlpha` equals its `outerColor`/`outerAlpha`, so the gradient is uniform) |
| `Draggable Star` / `Constellation Star` `onPress`/`onRollOver` | pointer handlers + `hoveredStar`; Constellation Star still drawn at 50 % scale |
| `onEnterFrame` + `getTimer()` | one `requestAnimationFrame` loop + `performance.now()`, using elapsed wall-clock time |
| `FPushButton` / `FCheckBox` / `FRadioButton` / `FComboBox` / `Standard Slider v6` | native `<button>` / `<input type=checkbox>` / `<input type=radio>` / `<select>` / `<input type=range>` |
| `Title Bar` symbol (title, reset, help, about) | `<kl-unl-masthead>`; `onReset` is wired to its `sim-reset` event |

### Depth ordering

The Flash engine allocated movie-clip depths in bands of `_N = 10000`. The port
draws in that exact order in `renderSphere`: objects with `r > 1` behind → back
external lines → back outer shading → back circles → objects with `r = 1` behind
→ back inner shading and bands → inner objects below the plane → inner lines →
horizon plane → inner objects above the plane → front inner bands → front
circles → front `r = 1` objects → front outer shading → front `r > 1` objects →
front external lines. The `_iLA` / `_iLB` swap when `φ < 0` is reproduced.
`sortObjects` is `false` on every sphere in this simulation, so objects keep
their insertion order within a band, exactly as `updateObjectsNoSort` does.

### Constants copied verbatim

- Angle factors `0.017453292519943295`, `57.29577951308232`, `0.2617993877991494`, `3.819718634205488`.
- Colours (decimal RGB): RA `16756912`, dec `16777136`, azimuth `12632319`,
  altitude `16777215`, angle wedge `13684944`, celestial equator / 0ʰ circle
  `16769909`, graticule `14737632` at alpha 30, polar axis `7711231`, band
  colours `6316256` / `14704736` / `14737632` at alpha 30 with an `8421504`
  border, trail `16777215` at alpha 60, constellation arcs `16777215` at alpha 80.
- Map: ocean `15068410`, land `13481116`, cross hairs `8421504` at alpha 50,
  width `360`, offset `170`.
- Globe: radius `40`, scale `75`, obliquity terms `0.91706` and `0.39875`.
- Sphere size `350`; sphere 2 minimum viewer altitude `7`.
- Reset state: latitude `40.8`, longitude `-96.7`, sphere 1 θ/φ `100`/`20`,
  sphere 2 θ/φ `145`/`30`, animation rate `0.05`, star limit `50`,
  keyboard step `deltaPos = 5`.
- Animation rate slider: logarithmic, `minValue 0.01`, `maxValue 0.2`,
  `initValue 0.05` (days of simulated time per real second).
- Timed-animation options `continuously / 1 / 3 / 6 / 12` hours, mapping to
  `animateTill = time + hours / 24`.
- Trail lengths: `none` → 0, `short` → 45, `long` → 360 degrees.
- Constellation star tables for the Big Dipper, Orion and the Southern Cross,
  and the full `_shoreData` coastline table.
- Number formatting: `asFixed()` reproduces the AS `Number.prototype.toFixed`
  polyfill, so every displayed number matches digit for digit (one decimal place
  for coordinates and the observer's position).

## Assets reused vs. code-drawn

**Reused as-is** (copied from the JPEXS export into `assets/`, never redrawn):

`star.svg`, `star-hi.svg` (Draggable Star, both frames), `cstar.svg`,
`cstar-hi.svg` (Constellation Star), `stickfigure.svg`, `observer-dot.svg`,
`small-gray-dot.svg`, `location-cursor.svg`, `horizon-plane-above.svg`,
`horizon-plane-below.svg`, `shading-layer-a.svg`, `shading-layer-b.svg`,
`globe-water.svg`, `globe-land.svg`, and `fonts/Verdana.ttf`.

Each is composited with `drawImage` at its original position, size and z-order;
`ASSETS` records each symbol's Flash registration point so the art lands exactly
where the movie clip's origin was.

**Code-drawn in the original, therefore reproduced on canvas** (there is no
exported file for them): all circles and arcs, the polar-axis lines, the shaded
declination band silhouettes, the six mask regions, the globe's coastline
outlines, the world map's land/ocean fills and cross hairs, and the sphere
labels. `images/` in the export is empty — this simulation contains no bitmaps.

## Deviations from the original

1. **Layout, palette, fonts and chrome** follow the KL-UNL foundation and the
   accessibility rules rather than the Flash pixel layout. Panel structure,
   grouping and reading order mirror the original screenshot (two diagram panels
   over Observer's Location / Animation Controls / Appearance Settings / Star
   Controls); the diagram panels keep their black background and the sphere
   artwork keeps the original colours, because those carry meaning.
2. **Title bar, Reset, Help and About** come from `<kl-unl-masthead>`. The
   original's own title bar and dialog windows (`Dialog Window v2`, `Title Bar`)
   are not ported.
3. **Star patterns** was a bespoke pop-up menu (`Constellations Menu`) in the
   original. It is now a real disclosure button plus three checkboxes, so it is
   keyboard-operable and screen-reader-announced. The three constellations, their
   labels and their behaviour are unchanged.
4. **Keyboard equivalents added** for every pointer gesture (see
   `ACCESSIBILITY.md`). The original had arrow-key control of the observer's
   location only; view rotation and star manipulation were mouse-only.
5. **`prefers-reduced-motion`**: when the user has asked for reduced motion and a
   *timed* animation is started, the simulation jumps straight to the end state
   instead of tweening, and says so. Continuous animation still runs when
   explicitly started, since it is the simulation's core teaching mechanism and
   is stoppable at any time from the same button.
6. **Delete-click to remove a star** is preserved, and the modifier state is
   tracked with `keydown`/`keyup` on `window` (AS used `Key.isDown(46)`).
7. **`updateAfterEvent()`** calls are dropped (no-ops in a `requestAnimationFrame`
   renderer), as are all `trace()` calls.
8. The AS `FUIComponent` framework is not ported; only its observable behaviour
   is, using native controls.

### Bug found and fixed during the port

`parsePointInput` in the AS sets *both* `sys` and `system` on its output, and
`pointToHorizon`/`pointToCelestial` re-parse an already-parsed point. An early
version of the port set only `sys`, so a re-parsed celestial point was
reinterpreted as a horizon point — right ascension came back 12ʰ off and altitude
came back equal to declination. `Sphere.parse` now carries `system` through, and
the round trip is exact in both directions. Verified independently: a star due
south (azimuth 180°) at altitude 25° seen from latitude 40.8° is reported at
declination −24.2°, which is `alt − (90 − lat)` exactly.

## Cross-browser notes

Standards-only HTML/CSS/JS: Pointer Events, `Path2D`, `canvas` 2-D,
`aspect-ratio`, CSS grid, `<dialog>`-free markup. No vendor-prefixed-only
declarations and no Chrome-only APIs. `Path2D` and `aspect-ratio` are supported
in Safari 15+ / iOS 15+. Fonts are self-hosted with a sans-serif fallback chain,
so text renders consistently regardless of what is installed on the OS. No
per-browser behavioural difference was found that needed a workaround; the
rendering path is the same everywhere.

A full redraw of both spheres plus the world map, with a constellation, eleven
stars and all three shaded regions enabled, measures ≈2 ms, so the animation has
ample headroom at 60 fps.
