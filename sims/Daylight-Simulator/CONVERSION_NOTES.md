# Daylight Simulator — Flash (AS1) to HTML5 conversion notes

Source: `daylightsimulator.swf` (SWF **version 6**, 30 fps, 780 × 515 stage),
decompiled with JPEXS/FFDec into `scripts/`, `shapes/`, `images/`, `sprites/`,
`texts/`, `symbolClass/` beside this folder.

---

## Behaviour model

The simulation shows an equirectangular map of Earth split into a sunlit day
region and a night region by the terminator curve, and animates that pattern in
one of two modes. In **Year** mode the Sun's declination sweeps through the
seasons — `dec = -23.26° · cos(2π/365 · (dayOfYear + 10))` — so the terminator
bulges north in June and south in December, while the date, the declination, the
latitude of direct rays, and the number of daylight hours at the user's latitude
all update. In **Day** mode the declination is held and the map scrolls beneath
the Sun one degree per frame, advancing a local clock four minutes per degree.
The user sets their own latitude and longitude with two sliders, which moves a
red "you are here" marker on the map and recomputes the local time and daylight
hours; an animation-speed slider scales the step size, a "Reset to (0,0)" button
returns the marker to the equator and prime meridian, and a Start/Stop button
halts the animation — while stopped, the map itself can be dragged east and west.

---

## Source files read

| File | What was taken from it |
| --- | --- |
| `scripts/frame_1/DoAction.as` | The controller: `component_Animate`, `long1Changed`, `lat1Changed`, `animChanged`, `resetChanged`, `animationChanged`, all constants and number formatting |
| `scripts/Flat Map Component 007.as` | Terminator geometry, grid, border, border labels, longitude offset, drag |
| `scripts/SliderV3Symbol.as` | Slider min/max/value/precision and hemisphere-label semantics |
| `scripts/frame_1/PlaceObject2_*/…on(initialize).as` | Per-instance init: slider ranges, radio labels, button labels, map component options |
| `symbolClass/symbols.csv`, SWF tag dump | Instance names, placement matrices, bitmap and shape ids |
| `texts/*.txt` | On-screen label strings |
| `frames/1.png` | Authoring-time layout reference (panel grouping and reading order) |
| `daylightsimulator.jpg` | Screenshot of the running original |

## Geometry recovered from the SWF

The map component sizes itself from its placeholder *before* resetting its own
scale:

```
placeholder shape 217 = 9000 × 4500 twips = 450 × 225 px
mapMC placed with scaleX = scaleY = 1.1500092 at (131.25, 35.45)
=> mapHeight = 225 × 1.1500092 = 258.75    mapWidth = 2 × mapHeight = 517.5
```

The canvas therefore uses an internal coordinate system of
`529.5 × 270.75` (map plus the 6 px border) and is scaled by CSS. All ported
drawing and physics maths stays in these original stage units; pointer
coordinates are mapped back through the current scale factor so the drag
arithmetic matches the ActionScript at any display size.

## ActionScript idiom translation

| AS1 | HTML5 |
| --- | --- |
| `Object.registerClass` + `prototype = new MovieClip()` | Plain functions over one `S` state object |
| `onEnterFrame` at 30 fps | One `requestAnimationFrame` loop with a wall-clock accumulator stepping at `1000/30` ms, so pacing is display-independent |
| `createEmptyMovieClip` / `beginFill` / `curveTo` | Canvas 2D `Path2D` + `quadraticCurveTo`, same coordinates |
| `setMask` | `ctx.clip()` with the same region |
| `attachMovie("FMC Map Rev 1 Day", …)` | `drawImage` of the exported bitmap |
| `maskedAreaMC._x` | A single `ctx.translate` applied to all map-layer drawing |
| `FPushButton`, `FRadioButton`, `SliderV3Symbol` | Native `<button>`, `<input type="radio">`, `<input type="range">` + `<input type="number">` — the Flash component framework is not ported, only its observable behaviour |
| `trace()` | Dropped |

**SWF 6 is case-insensitive**, which matters in three places the decompiler
preserves verbatim: `longit1.setminLabel` resolves to `setMinLabel`,
`math.cos` to `Math.cos`, and — importantly — `this.mapheight` in
`updateDayAndNightRegionsOffset` resolves to `this.mapHeight`. Without that last
one the night mask would sit half off the top of the map.

## Assets: reused, not redrawn

| Asset | Source | How it is used |
| --- | --- | --- |
| `assets/map-day.jpg` | `images/199.jpg` (904 × 229) | `drawImage`, two world copies |
| `assets/map-night.jpg` | `images/194.jpg` (900 × 225) | `drawImage`, masked by the night region |
| `assets/marker.svg` | `shapes/196.svg` | `drawImage` at the observer's position |

Code-drawn only (no exported file exists for these, they are built at runtime by
the ActionScript): the terminator curve, the day/night masks, the latitude and
longitude grid, and the map border with its alternating blocks.

## contents.json

**No edit was required.** `foundation/contents.json` already contains a
`daylightsimulator` entry with the correct `meta.title`, `meta.version`, and
`masthead.help` / `masthead.about` content. The whole `foundation/` folder is
copied in **byte-for-byte unchanged** (verified with `cmp`), and the page uses
`sim-id="daylightsimulator" json-url="foundation/contents.json"`.

---

## Deviations from the original

### Approved with the requester

1. **"You are here" marker placement — corrected.**
   The frame script positions the marker with constants left over from an
   earlier 450 × 225 map:
   `uHere._x = 225 + lon·450/360`, `uHere._y = 112.5 − lat·225/180`.
   On the real 517.5 × 258.75 map that puts latitude 0, longitude 0 at roughly
   **3° W, 1.6° N** and drifts about 2 % across the map. The marker is instead
   placed with the component's own projection
   (`x = mapWidth·((lon+180)/360)`, `y = (90−lat)·mapWidth/360`), which is exact.
   The numeric readouts were never affected by this bug.

2. **MathJax is vendored locally** at `assets/mathjax/tex-mml-svg.js`
   (MathJax 3.2.2, ~2.1 MB). The pipeline's own `demo_01.html` loads MathJax from
   the jsDelivr CDN, but the brief requires a self-contained sim with no external
   dependencies. The SVG build was chosen over CHTML because it is a single file
   with no accompanying web-font directory. The demo's
   `options.renderActions.addMenu = []` was **deliberately not copied**, because
   it disables the MathJax context menu that the brief requires to stay working.

### Judgement calls made during the port

3. **Day bitmap drawn from its content rect.** `images/199.jpg` is 904 × 229 —
   the same map as the 900 × 225 night export inside a 2 px frame. The original
   scales the whole thing to `mapHeight`, which makes the day map about 1.3 %
   smaller than the night map and knocks the two out of register. It is drawn
   here from source rect `(2, 2, 900, 225)` so day and night line up exactly
   (verified at an equinox: coastlines are continuous across both terminators).

4. **Terminator offset normalised.** `updateDayAndNightRegionsOffset` draws three
   copies of the terminator at `base − W`, `base`, `base + W`. In Day mode
   `base` is driven by `_sunLatitude`, which reaches −2·mapWidth, so three copies
   can leave a gap. The pattern tiles with period `mapWidth`, so `base` is
   reduced modulo `mapWidth` and four copies are drawn — mathematically identical
   where the original was correct, and gap-free where it was not.

5. **One marker instead of two.** `uHere1`/`uHere2` exist inside *both* the day
   and night map sprites. Since the night layer is masked and sits above the day
   layer, exactly one marker is ever visible; it is drawn once, above both.

6. **Readouts are primed with one animation step** rather than showing the
   authoring placeholders. The SWF starts animating immediately, so its first
   frame overwrites the placeholder strings `"Angle"` (declination, latitude of
   direct rays) and `"January 1"` (daylight hours) about 1/30 s after load.
   Running one step at start-up reproduces that first frame instead of flashing
   placeholder text — and matters when the simulation starts paused (see 7).

7. **Reduced motion starts paused.** With `prefers-reduced-motion: reduce`, the
   simulation loads showing the equivalent state but stopped, and announces that
   Start Animation will run it (WCAG 2.3.3 / 2.2.2).

8. **MathJax readouts are rate-limited to ~5 Hz.** Typesetting is synchronous
   main-thread work, and in Year mode the declination readout changes 30 times a
   second — far faster than it can be read. The canvas keeps its full frame rate;
   only the typeset readouts are throttled. Without this the renderer stalls.

9. **The simulation keeps its own "Reset to (0,0)" button.** This is the
   original `resetButton`, which resets *only the observer's location*, not the
   simulation. It is not a second masthead Reset — the masthead's Reset is wired
   through the `sim-reset` event and restores the full initial state.

### Dead code in the original, not ported

- `latitudeChanged()` and `longitudeChanged()` are defined but no control calls
  them; the sliders use `lat1Changed` / `long1Changed`.
- `onDragHandler = "onDrag"` is set on the map, but no `onDrag` function exists
  on the timeline, so dragging never had a side effect beyond scrolling the map.
- `longitudeSlider` and `latitudeSlider` are assigned to but never exist as
  instances (the instances are `longit1`, `latit1`, `animationSpeed`); in AS1
  those assignments silently do nothing.

### Original quirks preserved verbatim

- **The clock offset differs between call sites.** The animation branch uses
  `|long1| − 1` / `180 + (180 − long1)`; `long1Changed` and `resetChanged` use
  `|long1| + 1` / `181 + (180 − long1)`. Both are reproduced exactly.
- **`resetChanged` tests `lat1`, everything else tests `-lat1`** in the
  polar-day/polar-night fallback. Reproduced.
- **`lat1Changed` uses `count2`, the year animation uses `count2 · speed`** for
  the day-of-year in the daylight-hours formula. Reproduced.
- **The date advances every frame at every speed.** The guard
  `if (changeMD % speed < 2)` is true for every speed the slider can produce
  (0.2 … 2.0), so the `else` branch is unreachable. Reproduced.
- **`if (count3 === 366)` only fires at integer speeds.** At other speeds
  `count2` grows without resetting; declination still cycles because cosine is
  periodic. Reproduced.

### Foundation bug left alone

`foundation/kl-unl.css` line 101 contains a stray `u` before
`.app-layout__right`, which turns that rule into the descendant selector
`u .app-layout__right` and silently drops its `min-width: 0`. The foundation is
copied in unchanged as required, so this is **not fixed here** — the sim simply
does not rely on that rule. Worth reporting upstream.

---

## Verification performed

Served over HTTP and checked in-browser:

- **Physics.** Early January (declination −22.84°): equator 12.12 h, Tropic of
  Cancer 10.72 h, Tropic of Capricorn 13.55 h, 45° N 8.84 h, 45° S 15.54 h,
  66.5° N 2.74 h, 66.5° S 24 h, 80° N 0 h, 80° S 24 h. Solstice lands on
  June 20 at +23.25°.
- **Clock.** 0° → 12:00 PM, 90° W → 6:00 AM, 90° E → 6:00 PM, 180° → 12:00 AM.
- **Day mode.** One degree of scroll and four minutes of clock per step;
  `count1` wraps 360 → 1.
- **Drag.** A 51.75 px drag changes the offset by exactly −36°, per
  `offset = initOffset − dx · 360/mapWidth`.
- **Reset.** `sim-reset` restores the exact initial state.
- **Registration.** At an equinox, coastlines are continuous across both
  terminators, confirming the day/night bitmaps align.
- **Network.** Ten requests, all local; nothing external. No console errors.
- **Layout.** No horizontal scroll at 1280, 768, or 375 px, nor at 200 % text
  size; canvas aspect ratio preserved exactly; the 0° label sits on the map
  centre.

Not verified here — **needs a human**: real screen-reader passes with NVDA and
VoiceOver, and rendering checks on actual Safari, Firefox, iOS, and Android.
