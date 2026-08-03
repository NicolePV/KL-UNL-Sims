# Conversion Notes — Influence of Planets on the Sun Explorer

Source: `ca_extrasolarplanets_starwobble.swf`, decompiled with JPEXS/FFDec.
Target: self-contained HTML5 on the KL-UNL foundation, WCAG 2.1 AA.

---

## 1. Behaviour model (one paragraph)

The Sun is drawn at the centre of a black stage with a fixed green cross marking
the solar system's centre of mass (barycentre). A checkbox list of the nine
classical planets lets the user switch each planet's gravitational contribution on
or off. Every animation frame the simulation advances wall-clock time by
*days per second* (a slider, 0–5000), advances each **selected** planet along its
circular orbit by the corresponding fraction of its orbital period, and places the
Sun at the vector sum of the displacements each selected planet imposes:
`d = (m_planet / M_sun) × a_planet`, pointing away from the planet. The Sun's
position is recorded frame by frame and joined into a fading white curve — the
"wobble" path — which is capped at 100 segments, thinned so segments stay about
10 px apart, and fades by 1% per step. An elapsed-time readout counts years.
Toggling any planet clears the path and resets the year counter; the Reset button
does the same.

---

## 2. Source files read

| File | What was taken from it |
| --- | --- |
| `scripts/frame_1/DoAction.as` | `activity_Setup()`, `body_Update()`, `resetSun()`, `onSliderChanged()`, `math_computeFixedDigits()`; the planet table; all constants |
| `scripts/frame_1/PlaceObject2_14_Standard Slider v6_6/CLIPACTIONRECORD on(construct).as` | Slider configuration: min 0, max 5000, init 1000, linear, fixed digits 0, `maxChars` 5 |
| `scripts/frame_1/PlaceObject2_47_Button_9/CLIPACTIONRECORD on(release).as` | Reset button behaviour |
| `scripts/frame_1/PlaceObject2_88_1/CLIPACTIONRECORD onClipEvent(load).as` | Entry point (`activity_Setup`) |
| `scripts/Standard Slider v6.as`, `scripts/Slider Logic Class v6.as` | Slider value model: clamping, `minIncrement = 10^-precision`, one arrow-key tick = 1 |
| `texts/*.txt` | On-screen strings: `Effect of Planets on the Sun`, `Years Elapsed:`, `Animation Speed`, `Days Per Second:` (from the slider's `labelText`) |
| SWF placement tags (parsed directly) | Stage 780 × 420 @ 30 fps; `sun` sprite 88 at (270, 210) scale 1.5; `gravityCenter` sprite 90 at (270, 210) scale 1 |
| `shapes/85.svg`, `86.svg`, `89.svg` | The Sun's glow, the Sun's globe, the green centre-of-mass cross |
| `Capture.PNG`, `frames/1.png` | Layout reference (Goal C) |

The rest of `scripts/` is the Macromedia v2 UI component framework (`mx.*`,
`FocusManager`, `CheckBox`, `Button`, `RectBorder`, …). Per the brief this was **not**
ported; only the observable behaviour of the checkboxes, button and slider was
reproduced with native accessible HTML controls.

---

## 3. Constants and tables (verbatim)

```
sunArray.radius            695500 km
sunArray.mass              1.989 × 10^30 kg
sun.globe symbol width     80 px  (shapes/86.svg)
sun instance _xscale       150      -> onscreenradius = 80/2 × 1.5 = 60 px
kmPerPixel                 695500 / 60 = 11591.666… km per stage pixel
gravityCenter              (270, 210) on the 780 × 420 stage
sunpathSize                100
sunpathSegmentMinimum      10
path line                  lineStyle(2, 0xFFFFFF, 100)
slider                     min 0, max 5000, init 1000, linear, fixed digits 0
```

| Planet | mass (kg) | distance (km) | orbit period (days) |
| --- | --- | --- | --- |
| Mercury | 3.3022 × 10^23 | 5.7909175 × 10^7 | 87.97 |
| Venus | 4.8685 × 10^24 | 1.0820893 × 10^8 | 224.7 |
| Earth | 5.9737 × 10^24 | 1.4959789 × 10^8 | 365.24 |
| Mars | 6.4185 × 10^23 | 2.2793664 × 10^8 | 686.93 |
| Jupiter | 1.8987 × 10^27 | 7.7841202 × 10^8 | 4330.6 |
| Saturn | 5.6851 × 10^26 | 1.4267254 × 10^9 | 10755.7 |
| Uranus | 8.6849 × 10^25 | 2.8709722 × 10^9 | 30687.2 |
| Neptune | 1.0244 × 10^26 | 4.4982529 × 10^9 | 60190 |
| Pluto | 1.3 × 10^22 | 5.90638 × 10^9 | 90553 |

Everything is normalised to the Earth exactly as the source does
(`mass.earthbased`, `distance.earthbased`), and the printed distances use the
source's own rule — 3 decimals below 1 AU, 1 decimal at or above 1 AU, trailing
zeros stripped. The nine values render as `0.387 / 0.723 / 1 / 1.5 / 5.2 / 9.5 /
19.2 / 30.1 / 39.5 AU`, matching the screenshot character for character.

Verified numerically against the port: with Jupiter alone selected the Sun sits
743 072 km — 1.0684 solar radii, 64.10 stage pixels — from the centre of mass, and
that magnitude stays constant as Jupiter orbits.

---

## 4. ActionScript → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `sun.onEnterFrame = body_Update` (30 fps) | one `requestAnimationFrame` loop throttled to a 1000/30 ms cadence, so the per-frame orbital advance and path-point spacing match the original |
| `new Date()` / `getTimer()` | `performance.now()`; elapsed wall-clock time, not frame counts |
| `_x`, `_y`, `_alpha`, `_xscale` | plain properties on the state object, applied at draw time |
| `createEmptyMovieClip` + `lineStyle`/`moveTo`/`lineTo`/`curveTo` for each path segment | one canvas 2D stroke per stored path point; `curveTo` → `quadraticCurveTo` (both are quadratic Béziers) |
| clip depth `level++` above the sun (depth 1) and gravityCenter (depth 4) | draw order: glow → globe → cross → path |
| `duplicateMovieClip` of `checkbox_0` + `createTextField` per planet | nine rows built by `buildPlanetList()` from the same `planetArray` the physics uses |
| `FCheckBox` / `FPushButton` / `Standard Slider v6` | native `<input type="checkbox">`, `<button>`, `<input type="range">` + `<input type="text">` |
| `Slider Logic Class v6` fixed-digits model | `snapSpeed()`: clamp to 0–5000, snap to `10^-0 = 1` |
| slider `valueField` (`restrict = "0-9.Ee+\-"`, `maxChars 5`, Enter/blur commit, NaN reverts) | text input filtered to the same character set, `maxlength=5`, commit on Enter and blur, unparseable input reverts to the current value |
| `math_computeFixedDigits()` | ported line for line, including the `forceFlag` zero-padding used by the years readout |
| `trace()` | dropped |
| `updateAfterEvent()` | no-op |

### Assets: reused, never redrawn

| Original | Copied to | How it is used |
| --- | --- | --- |
| `shapes/85.svg` (150 × 150, radial gradient glow) | `assets/sun-glow-85.svg` | `ctx.drawImage` at the Sun's position, scaled 1.5 (the `sun` instance's `_xscale`) |
| `shapes/86.svg` (80 × 80, orange globe gradient) | `assets/sun-globe-86.svg` | `ctx.drawImage`, same position, scaled 1.5 |
| `shapes/89.svg` (28 × 28, green cross, 3 px stroke) | `assets/center-of-mass-89.svg` | `ctx.drawImage` at (270, 210), scale 1 |

`images/` in the export is empty and `morphshapes/`, `movies/` contain nothing, so
these three vector files are the sim's entire non-code artwork. The only art
redrawn in code is the wobble path, which the ActionScript also drew in code. A
gradient fallback (same colour stops and radii, read from the SVG headers) is
drawn only if an SVG fails to load, so the picture is never blank.

The Flash fonts (`fonts/8_Trebuchet MS.ttf`, `2_/4_Verdana.ttf`) were **not**
copied: they are OS fonts used by the Flash text fields, and the KL-UNL foundation
supplies the type stack. Depending on an OS-installed font would violate the
cross-OS rule.

### Canvas coordinate system

The canvas backing store is the original stage's left-hand region — 540 × 420 of
the 780 × 420 stage (the right 240 px held the checkbox column, which is now its
own panel). **No coordinate is recomputed from the element's on-screen size**: all
drawing and physics run in original Flash stage units, and CSS scales the element
(`width: 100%; height: auto`, capped at 38rem) with the aspect ratio preserved.
The backing store is multiplied by `devicePixelRatio` (capped at 2) with a matching
`ctx.scale`. Nothing on the canvas is draggable, so no pointer-to-stage mapping is
needed.

---

## 5. Layout (Goal C — the screenshot, inside the KL-UNL shell)

The original screenshot's arrangement is reproduced structurally:

| Original (Flash, 780 × 420) | Here |
| --- | --- |
| Orange title at top | rendered by `<kl-unl-masthead>` (from `contents.json`) |
| `Years Elapsed:` + value + Reset button | status line at the top of the visualisation panel; Reset now lives in the masthead |
| Sun + glow + green cross, centred left | `<canvas>` in `.panel__canvas-wrap`, same geometry |
| `Animation Speed` / `Days Per Second:` + field + slider, bottom left | its own full-width panel across the bottom, with the Pause button to the right of the slider |
| Nine planet checkboxes with green AU readouts, right column | `Planets` panel in the right column |

The page is a three-cell grid: the stage (wide) beside the planet list (narrow)
on the first row, and the animation-speed panel spanning the full width beneath
them. The two first-row panels stretch to a common height so their bottom edges
line up, and the speed panel's right edge lines up with the planet panel's. The
top-row split is about 70/30, as in the original. The KL-UNL `.app-layout` grid
ships as `25rem 1fr`; this sim swaps the proportions **in `styles/styles.css`**,
never in `kl-unl.css`, and keeps the foundation's 56rem single-column collapse.

Divergences forced by accessibility or the template, and why:

* **Palette.** The Flash sim was orange-and-green text on black. In the KL-UNL
  shell the panels are white, where the original `#00FF00` distance text would
  give 1.4:1 contrast. All chrome now uses the foundation's CSS custom
  properties. The *canvas* keeps the original black field and the original
  artwork colours, which are high contrast on black. See `ACCESSIBILITY.md`.
* **Panel headings.** The original had no panel titles. Headings
  (`Effect of Planets on the Sun`, `Planets`, `Animation Speed`) were added so
  the page has a correct heading hierarchy and screen-reader landmarks.
* **Legend.** A three-item key (Sun / centre of mass / traced path) was added so
  the diagram's meaning is not carried by colour alone.

### No MathJax

The original displays no equations, formulas or mathematical notation anywhere —
only plain numbers and the unit `AU`. Numbers are therefore rendered as ordinary
sans-serif text, not typeset. This is deliberate and was confirmed with the
project owner:

* An earlier revision typeset every number through MathJax and added a
  "Displacement of the Sun" panel carrying the barycentre formula. **Both have
  been removed** — the panel because it does not exist in the original, the
  typesetting because it served no purpose without it.
* Typesetting also caused a visible defect: values were written as plain text
  first and then replaced by MathJax's own fonts, so the digits of the running
  `Years Elapsed` counter changed typeface several times a second. Plain text
  fixes that at the root.
* `foundation/mathjax/` (which an earlier revision copied in from a sibling sim)
  has been deleted, so `html5/foundation/` now contains exactly the same file set
  as the linked folder's `foundation/`. `kl-unl.js` is still linked as part of
  the foundation reference protocol; `simulation.js` supersedes its
  `klunlInitEqn()` with a no-op, which is what that hook is for.
* The Sun's live offset from the barycentre is still computed and is still
  spoken in the canvas's text description — it just has no visible panel.

---

## 6. Deviations from the original — full list

1. **Initial animation speed: 1000, not 500.**
   The original is internally inconsistent here. `activity_Setup()` sets
   `daysPerSecond = 500`, while the slider is constructed with `initValue = 1000`
   and never calls its change handler at start-up. The Flash sim therefore
   *displays* 1000 days per second while *running* at 500 until the slider is
   first touched. A visible readout (and an `aria-valuetext`) that disagrees with
   the actual state is a WCAG failure, so the port starts at the displayed value:
   **1000 days per second, shown and used.** Everything downstream of
   `daysPerSecond` is unchanged. If parity with the hidden 500 is preferred
   instead, change `SPEED_INIT` in `simulation.js` — but then the initial slider
   position must change with it.

2. **Reset does a full reset.**
   The Flash Reset button ran only `daysTotal = 0; resetSun();` — it cleared the
   traced path and the year counter but left the planet checkboxes and their
   orbital phases alone. Hard rule 3 requires the masthead's `sim-reset` event to
   restore the sim's exact initial state, and no second Reset control may be
   added. The masthead Reset therefore also clears every checkbox, re-randomises
   the starting angles (`Math.random() * 3600`, as at load) and restores the
   initial speed. The original's lighter behaviour is still reachable: toggling
   any planet clears the path and the year counter, exactly as before.

3. **Pause / Resume button added.**
   The original animates forever with no stop. WCAG 2.2.2 requires a mechanism to
   pause motion that runs longer than five seconds. The button also gives
   `prefers-reduced-motion: reduce` a meaning — the sim then starts paused
   instead of animating on load.

4. **Clicking the slider bar jumps instead of ramping.**
   `Standard Slider v6.as` stepped the value one tick, waited
   `continuousChangeDelay` (500 ms), then ramped at `continuousChangeRate`
   (0.05 ticks/ms) toward the pointer. A native `<input type="range">` jumps
   straight to the clicked position. Keyboard behaviour is unchanged (one arrow
   press = 1 day/second, the original's `minIncrement`), and dragging the thumb
   behaves the same. The trade was made for full, reliable keyboard and
   screen-reader support, which the Flash component did not provide.

5. **`resetSun()`'s leftover state is reproduced, not "fixed".**
   The original removes the drawn path clips but deliberately leaves
   `sunpathArray.positionarray` and `counter` untouched, so the first segment
   after a reset is drawn from the Sun's last recorded position and the 100-point
   cap still counts the old points. The port marks the existing points
   `removed` and keeps the array and counter, which is bit-for-bit the same
   observable behaviour.

6. **`" " + planetname` label.** The original prefixed each checkbox label with a
   space for pixel spacing. The HTML label is the bare planet name; spacing is
   CSS.

7. **No Flash component chrome.** Bevelled `RectBorder` borders, the halo focus
   rectangle and the slider's hand-drawn gradient bar/grabber are not reproduced;
   the KL-UNL control styling replaces them (hard rule 2).

8. **Frame cadence.** The physics steps at the SWF's 30 fps rather than at the
   display's refresh rate. This matters: the per-frame orbital advance and the
   spacing of the recorded path points both depend on how much time each step
   covers, so a 60 Hz step would visibly change the path's shape. Elapsed time is
   still real wall-clock time, so the simulation runs at the same speed on any
   machine.

9. **Stalls in the animation loop are discarded, not integrated.**
   `body_Update()` advances the planets by however much real time has passed
   since the previous frame. If the loop stalls — a modal dialog opening, the
   tab going to the background, a slow repaint — the next frame would otherwise
   receive the entire gap as one step. Measured: a 2 second stall at 1000 days
   per second advances Jupiter 166° in a single step and draws a **127 px**
   straight chord across a path whose normal segments are **9 px**, on an orbit
   whose radius is only 64 px. That produced the spikes and polygons users saw
   after opening Help or About. Any gap longer than `MAX_FRAME_GAP_MS` (250 ms,
   about seven missed frames) is now treated as time the simulation was not
   running: the clock is resynced and that frame takes a zero-length step. The
   original has the same flaw — it used `new Date()` deltas — but it is a plain
   defect, and the fix changes no constant, formula or timing of a normally
   running frame.

10. **The animation is suspended while the Help / About dialog is open.**
    A modal `<dialog>` makes the rest of the page inert, so the user cannot
    pause or reset while reading — but the simulation would keep running and
    burn simulated years behind the overlay. `watchMastheadDialog()` observes
    the `open` attribute of the dialog inside the masthead's shadow root and
    suspends the loop for exactly as long as it is showing, resyncing the clock
    on close so nothing jumps. This only *reads* the component's open shadow
    root; `kl-unl-masthead.js` is not modified. A pause the user set themselves
    before opening the dialog is preserved — the sim does not auto-resume into
    a state they did not ask for.

---

## 7. `contents.json`

The shared file **already contained** an entry for this simulation, keyed
`ca_extrasolarplanets_starwobble` (title *Influence of Planets on the Sun
Explorer*, version 2.0). No new entry was added. Two changes were made to the
copy in `html5/foundation/contents.json`:

**(a) The instructed licence replacement**, in `masthead.about.content` — the
sentence *"Permission is granted to use these files for noncommercial purposes as
long as they remain unmodified."* was replaced by the Apache 2.0 block, and the
standard NSF funding sentence (missing from this entry, present in its siblings)
was restored. The "visit Astronomy Education at the University of
Nebraska-Lincoln" line and the WCAG modernisation line were kept. The entry now
reads:

```json
"ca_extrasolarplanets_starwobble": {
  "meta": { "title": "Influence of Planets on the Sun Explorer", "version": "2.0" },
  "masthead": {
    "help": {
      "title": "Help and Instructions",
      "content": "<p>This explorer shows the movement of the sun due to the gravitational pull of the planets. The contribution from each planet can be isolated by toggling checkboxes.</p>"
    },
    "about": {
      "title": "About this Explorer",
      "content": "<p>For additional astronomy education materials please visit <a href=\"https://astro.unl.edu/\">Astronomy Education</a> at the University of Nebraska-Lincoln.</p><p>This explorer has been modernized by the AAS Applet Task Force to meet modern web accessibility standards (WCAG 2.1 AA).</p><p>Initial funding for this work was provided by NSF grants #0231270 and/or #0404988.</p><p>Copyright 2026 The Board of Regents of the University of Nebraska</p><p>Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at</p><p><a href=\"http://www.apache.org/licenses/LICENSE-2.0\">http://www.apache.org/licenses/LICENSE-2.0</a></p><p>Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.</p>"
    }
  }
}
```

**(b) ⚠ A repair to six unrelated entries — please fix this upstream.**
The `foundation/contents.json` in the linked sim folder **is not valid JSON**, so
`kl-unl-masthead.js` cannot parse it and *no* simulation using this copy shows a
title, Reset, Help or About. The defects are:

| Line (original file) | Entry | Defect |
| --- | --- | --- |
| 200 | `ce_hc` | raw newline inside a JSON string |
| 438 | `eclipsingbinarysim` | raw newline inside a JSON string |
| 916 | `meltednail` | raw newline inside a JSON string |
| 1155 | `positionsdemonstrator` | raw newline inside a JSON string |
| 1203 | `renaissancePtolemaic` | unescaped `"` in `<a href="../venusphases">` |
| 1221 | `pulsarPeriodSim001` | raw tab inside a JSON string |
| 1798 | `venusphases` | unescaped `"` in `<a href="...">` |

The copy in `html5/foundation/` has the stray newlines removed, the tab escaped as
`\t` and the four `href` quotes escaped as `\"`. **No wording was changed** — the
rendered Help/About text of those entries is identical. This is outside the
"add your own entry" edit that the brief permits, but the page cannot load
without it. The newer pipeline copy of `contents.json` (for example the one in
`Radial Velocity Simulator/html5/foundation/`) does not have these defects, so
the linked folder's copy is simply stale/corrupted and should be re-synced.

`kl-unl.css`, `kl-unl.js`, `kl-unl-masthead.js` and `README.md` are byte-for-byte
identical to the originals (verified by checksum), and `html5/foundation/`
contains exactly the same file set as the linked folder's `foundation/` —
`contents.json` is the only file whose bytes differ.

---

## 8. Cross-browser notes

* Only standards-based CSS is used — grid, flexbox, `overflow-x`, media queries,
  `filter` on hover. No vendor-prefix-only declarations, no Chrome-only APIs.
  `display: contents` is deliberately avoided (older WebKit dropped such elements
  from the accessibility tree); the planet list is a flat grid instead.
* The canvas keeps its aspect ratio with `width: 100%; height: auto` rather than
  the `aspect-ratio` property, which works identically on every supported engine.
* The SVG artwork carries intrinsic `width`/`height`, which Safari requires before
  it will accept an SVG in `drawImage`.
* Text uses the foundation's own font stack (`Sans-Serif, Arial, Helvetica,
  sans-serif`) with no webfont of any kind, so numbers render consistently on
  every OS. `font-variant-numeric: tabular-nums` keeps the running counter's
  digits from shuffling sideways where the platform font supports it, and
  degrades harmlessly where it does not.
* The one known per-browser difference is cosmetic: the range input's track and
  thumb are drawn by each browser's native control, so the slider looks slightly
  different in Safari, Firefox and Chromium. It behaves identically in all of
  them, and it is left native on purpose — that is what gives arrow / Page / Home
  / End keys and screen-reader value announcements for free.
* The shared masthead's title-plus-buttons bar does not wrap, and is wider than a
  320 CSS px viewport. Since the foundation may not be edited, `styles/styles.css`
  lets that bar scroll on its own so the page body still reflows without
  horizontal scrolling. Above about 375 px it never triggers.

---

## 9. What was verified

Run in the browser against the served build:

* All nine AU readouts match the screenshot exactly.
* `kmPerPixel` = 11591.666…, on-screen Sun radius 60 px — derived from the SWF
  placement tags, not guessed.
* Jupiter alone → 743 072 km = 1.0684 R☉ = 64.10 px offset, constant over 60
  simulated seconds of orbit.
* Path bookkeeping: 100-point cap honoured, alpha fades 100 → 1, point spacing
  6.2–9.3 px (the `sunpathSegmentMinimum = 10` consolidation), quadratic segments
  used, exactly one segment skipped after a checkbox change (`gradualChange`),
  `resetSun()` hides all segments while keeping the array and counter.
* Number formatting: `3 → "3.0"`, `3.24 → "3.2"`, `0.3870991 → "0.387"`,
  `1 → "1"`.
* Slider/field: clamps at 0 and 5000, rounds to whole numbers, junk input reverts.
* Masthead Reset clears the checkboxes, the year counter and the speed.
* About dialog shows the Apache licence and the NSF grant numbers; Help shows the
  original entry's text.
* No horizontal scrolling at 320, 375, 768 or 1280 CSS px; no console errors over
  HTTP; the only requests are to files in this folder.

Not verifiable in this environment: the animation loop itself could not be watched
because the automation browser pane was never composited, so
`requestAnimationFrame` never fired. The physics, path and formatting code was
therefore exercised head-on with synthetic timestamps (results above) rather than
by watching it move. **A human should open the page and confirm the motion and the
traced path look right**, alongside the screen-reader QA noted in
`ACCESSIBILITY.md`.
