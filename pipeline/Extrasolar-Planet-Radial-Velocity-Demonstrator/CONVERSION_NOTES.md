# Conversion notes — Radial Velocity Demonstrator

Source: `radialVelocityDemo003.swf` / `radialVelocityDemo003.fla` (ActionScript 1,
600 × 450 stage, 30 fps, black background).
Target: `html5/`, built on the shared KL-UNL foundation.

---

## Behaviour model

A star and a single planet orbit their common centre of mass on the right of the
stage, drawn as two concentric circles with the star on the small inner orbit and
the planet on the large outer one, always diametrically opposite each other. A
telescope on the left points at them, and a spectrometer across the bottom shows
the star's continuous spectrum crossed by ten dark absorption lines. One button
starts and pauses the orbital animation. While the animation runs the pair rotates
rigidly about the centre of mass at 0.04 degrees per millisecond — one revolution
every 9 seconds — and the whole set of absorption lines slides horizontally by
`20 × sin(orbital phase)` pixels, reaching its greatest red shift a quarter turn
after the star passes the left of its orbit and its greatest blue shift a quarter
turn after it passes the right, so the spectral shift is exactly in step with the
star's orbital motion. Nothing else is interactive, nothing is draggable, there is
no state beyond the rotation angle and whether the animation is running, and the
caption on the instrument states that the shift is greatly exaggerated.

---

## What was in the source folder, and what had to be done about it

The linked folder contained only three files:

```
radialVelocityDemo003.fla
radialVelocityDemo003.swf
Screenshot 2026-07-27 101250.png
```

Two of the prompt's "stop and ask" conditions were technically met, and both were
resolved from material already present in the workspace rather than by guessing:

1. **There was no decompiled export** (`scripts/`, `shapes/`, `symbolClass/`, …).
   JPEXS Free Flash Decompiler 26.2.1 is installed on this machine at
   `C:\Program Files (x86)\FFDec`, so the SWF was decompiled here with

   ```
   ffdec-cli -export script,shape,image,text,symbolClass,sprite,frame,font,morphshape <out> radialVelocityDemo003.swf
   ffdec-cli -swf2xml radialVelocityDemo003.swf swf.xml
   ```

   This produces exactly the ground truth the prompt expects — the AS1 source, the
   exported vector shapes, and (via the XML) the display-list matrices. The export
   lives outside this folder, in the session scratchpad; it is not sim output, so
   it was not copied into `html5/`. Only the SVG shapes the sim actually uses were
   copied into `assets/`. **Nothing was invented or fetched from elsewhere.**

2. **There was no `foundation/` subfolder inside the sim folder.** The shared
   foundation lives one level up, at `Summer 26\foundation\`, and is what every
   other converted sim in this workspace copies from. Those files were copied into
   `html5/foundation/` byte-for-byte. `desktop.ini` (Windows folder metadata, not a
   foundation file) was not copied.

If either assumption is wrong, say so and it will be redone against the material
you intend.

### `contents.json`

**No edit was needed.** The shared `contents.json` already contains an entry keyed
`radialvelocitydemo`, with `meta.title` "Radial Velocity Demonstrator",
`meta.version` "2.0", and the Help and About text already written in the house
boilerplate. The file was therefore copied into `html5/foundation/` **unchanged**,
and `index.html` uses `sim-id="radialvelocitydemo"`.

The original SWF contains no Help or About text of its own — the only strings in it
are `SPECTROMETER` and `doppler shift greatly exaggerated`, both of which appear on
the stage — so there was no original wording to fold in.

If the pipeline treats `contents.json` as one shared file rather than a per-sim
copy, delete `html5/foundation/contents.json` and point `json-url` at the shared
one; no entry needs to be added either way.

---

## The whole original program

The entire simulation is the main timeline script (`scripts/frame_1/DoAction.as`),
reproduced verbatim below, plus one `on(construct)` block on the button:

```actionscript
function update() {
   var _loc2_ = Math.sin(bodiesMC._rotation * 0.017453292519943295);
   this.spectrometerMC.linesMC._x = linesX + _loc2_ * linesRange;
}
function animOnEnterFrame() {
   var _loc2_ = getTimer();
   this.bodiesMC._rotation =
      (this.bodiesMC._rotation + this.animRate * (_loc2_ - this.timeLast)) % 360;
   this.timeLast = _loc2_;
   this.update();
}
function toggleAnimation() {
   if (this.onEnterFrame == this.animOnEnterFrame) {
      delete this.onEnterFrame;
      this.toggleAnimationButton.setLabel("start animation");
   } else {
      this.onEnterFrame = this.animOnEnterFrame;
      this.timeLast = getTimer();
      this.toggleAnimationButton.setLabel("pause animation");
   }
   this.update();
}
animRate   = 0.04;
linesX     = this.spectrometerMC.linesMC._x;
linesRange = 20;
update();
```

```actionscript
on(construct) {                      // toggleAnimationButton, an FPushButton
   label        = "start animation";
   clickHandler = "toggleAnimation";
}
```

### Constants, carried over exactly

| Name | Value | Where it came from |
| --- | --- | --- |
| `animRate` | `0.04` deg/ms (9000 ms per revolution) | main timeline |
| `linesRange` | `20` px | main timeline |
| degrees→radians | `0.017453292519943295` | the literal in `update()` |
| `linesX` | `162.45` px | design-time `linesMC._x`, 3249 twips |
| `linesMC._y` | `17.95` px | 359 twips, never changes |
| centre of mass | `(462, 163)` px | `bodiesMC` placement, 9240 / 3260 twips |
| button labels | `"start animation"` / `"pause animation"` | verbatim |
| stage text | `SPECTROMETER`, `doppler shift greatly exaggerated` | verbatim |

### AS1 idiom → HTML5

| ActionScript | Port |
| --- | --- |
| `onEnterFrame` | one `requestAnimationFrame` loop |
| `getTimer()` (ms) | `performance.now()` (ms); the rate constant and the elapsed-time arithmetic are unchanged, so timing matches on any machine |
| `bodiesMC._rotation = θ` | SVG `transform="translate(462,163) rotate(θ)"`. Flash `_rotation` and SVG `rotate()` are both degrees, both clockwise with y downwards, so the value transfers with no conversion |
| `linesMC._x` | SVG `transform="translate(x, 17.95)"` on the lines group |
| `setMask` / clip depth on `spectrometerMC` | `<clipPath>` with the exported mask's rectangle |
| `FPushButton` + `clickHandler` | a native `<button>`; the Flash component framework is not ported, only its observable behaviour |
| `_root` chains, `trace()` | direct references; dropped |

---

## Art: everything is reused, nothing is redrawn

The ActionScript draws nothing at runtime — there is no
`createEmptyMovieClip` / `beginFill` / `drawArc` anywhere in the source. Every
visual element is an exported vector shape, so **all of it is reused as-is** and
none of it was recreated by hand. Each shape was exported by FFDec to SVG, copied
into `assets/`, and placed with `<image>` at the coordinates and scales read out of
the SWF display list.

| Asset | SWF shape | Depth | Placement in the 600 × 450 stage |
| --- | --- | --- | --- |
| `spectrometer-case.svg` | 183 | 1 | x 104.4506, y 293.9979, 391.0879 × 143.6764 |
| `spectrometer-case-inner.svg` | 184 (via sprite 185) | 2 | x 104.45, y 294, 391.0879 × 143.6764, **opacity 0.75** |
| `spectrometer-plate.svg` | 186 | 16 | x 111.5336, y 299.0808, 380.2543 × 133.5450 |
| *(SVG text)* | 188 | 17 | `SPECTROMETER`, baseline (304.867, 327.287) |
| `spectrum-backdrop.svg` | 189 | 18 | x 134, y 346.8, 336 × 58.15 |
| `spectrum-continuum.svg` | 190 (via sprite 191) | 19 | inside `spectrometerMC` at (139.35, 350.8) |
| *(clip rectangle)* | 192 | 19 | x −1.15, y 0.2, 326.95 × 48 |
| `spectrum-lines.svg` | 193 (via sprite 194) | 19 | the moving group, `translate(162.45 + 20 sin θ, 17.95)` |
| `orbit-paths.svg` | 196 | 32 | x 356, y 57, 212 × 212 |
| `star-planet.svg` | 197 (via sprite 198) | 33 | inside the rotating `bodiesMC` group |
| `telescope.svg` | 199 | 47 | x 29.6044, y 129.5011, 120.7434 × 98.0288 |
| *(SVG text)* | 201 | 48 | `doppler shift greatly exaggerated`, baseline (259.35, 424.9) |

**Shape 184 is easy to miss.** It is placed by a `PlaceObject3Tag`, not a
`PlaceObject2Tag`, and carries a colour transform with `alphaMultTerm = 192`. That
is a `#999999` panel laid over the `#7f7f80` case at 75 % opacity, and it is the
only reason the case reads as `#939393` on screen rather than `#7f7f80`. Without
it the whole instrument comes out visibly too dark.

The stage keeps the original Flash coordinate system: the SVG `viewBox` is
`0 0 600 450` and CSS only scales the element, so no ported geometry ever depends
on the on-screen size.

### Verification against the original

The rendered stage was compared pixel-for-pixel against FFDec's own render of SWF
frame 1, and the case grey was cross-checked against your screenshot of the running
Flash sim (both give 147,147,147).

| Region | Mean channel difference | Pixels differing by > 40 |
| --- | --- | --- |
| Whole stage, excluding the button area | **1.49 / 255** | 1.10 % |
| Telescope | 2.01 | 0.64 % |
| Orbits, star and planet | 0.15 | 0.00 % |
| Spectrum band | 3.48 | 1.30 % |
| Spectrometer case | 5.38 | 4.26 % |

The residue is antialiasing on curved edges (the worst pixel is the case's rounded
corner). The two text runs are excluded because their colour was deliberately
changed for contrast, and the button area because the button moved into a control
panel.

All ten absorption lines were also located by scanning the rendered spectrum for
dark minima, at three phases:

| θ | Predicted line centres (px) | Found |
| --- | --- | --- |
| 0° | 206.8 226.8 255.5 306.8 327.7 336.8 356.8 376.8 386.8 396.8 | all ten, within one pixel |
| 90° | 226.8 246.8 275.5 326.8 347.7 356.8 376.8 396.8 406.8 416.8 | all ten, within one pixel |
| 270° | 186.8 206.8 235.5 286.8 307.7 316.8 336.8 356.8 366.8 376.8 | all ten, within one pixel |

The timing was checked by driving the frame callback with synthetic timestamps:
1000 ms of elapsed time advances the rotation by exactly 40.0000°, and the line
offset matches `20 sin θ` to four decimal places at 0°, 30°, 90°, 180°, 210°, 270°
and 359°.

---

## Deviations from the original

Behaviour of the physics and of the ported logic is unchanged. Everything below is
presentation or an accessibility affordance.

1. **The button moved out of the stage.** In Flash it is an `FPushButton` drawn on
   the stage at the top centre. Here it is a real `<button>` in an "Animation"
   panel below the stage, because a canvas- or SVG-drawn button cannot be reached
   by keyboard or announced by a screen reader. Its label text and its effect are
   unchanged. Placing controls below the diagram also matches the KL-UNL house
   layout and the sibling conversions in this workspace.

2. **Orbital phase controls were added** (0–359°). The original has no draggable
   or adjustable element at all, so a visitor using a keyboard or a screen reader
   could only start and stop the motion and never examine a particular phase.
   There are two controls for the one value — a typable `<input type="number">`
   and a slider — so a phase can be entered exactly or scrubbed to. Both write to
   the same state object as the animation, so none of them can disagree. The
   number field clamps to 0–359 on commit, and an abandoned edit (empty box, or
   text the element cannot parse) reverts to the current phase rather than
   snapping the star to zero.

3. **Moving either phase control pauses the animation.** Scrubbing and
   free-running motion would otherwise fight each other. The button label follows,
   exactly as if you had pressed pause.

3a. **Layout: the stage and the controls sit side by side** on screens wider than
   the foundation's 56 rem breakpoint (stage panel 640 px, Animation panel 352 px,
   tops and bottoms aligned), and stack with the stage first below it. The
   original Flash stage had its one button at top centre; this is the KL-UNL house
   arrangement and keeps the 600 × 450 stage at native size on a 1000 px shell.

4. **Two colours were changed for contrast** (details and ratios in
   `ACCESSIBILITY.md`): the `SPECTROMETER` lettering `#d36488 → #ffffff`, and the
   `doppler shift greatly exaggerated` caption `#333333 → #000000`. Both failed
   WCAG 1.4.3 against their own backgrounds in the original. No other colour was
   touched; the spectrum, the orbit strokes, the star and the planet keep their
   exported values.

5. **The two stage text runs are SVG text, not raster.** They stay vector-sharp at
   any zoom, and `textLength` with `lengthAdjust="spacingAndGlyphs"` pins each run
   to its original width (211.564 px and 211.9 px) so the layout is identical
   whichever sans-serif the operating system supplies. The original fonts are Arial
   (shape 187) and italic Verdana (shape 200); the exported glyph subsets were not
   shipped, because both are covered by metric-compatible fallback stacks on every
   target platform and the pinned widths remove the remaining variation.

6. **Background-tab timing.** `requestAnimationFrame` is suspended while a tab is
   hidden, so on returning the first frame sees a large elapsed time and the phase
   jumps. This is deliberate: it is the same arithmetic the original performs with
   `getTimer()`, it keeps the port faithful, and on a periodic orbit the result is
   simply a different phase.

7. **The "Spectral line shift" panel was removed** (at your request, after the
   first build). It had held a live MathJax equation for the sim's own line-offset
   formula plus numeric readouts of the offset and its direction. Removing it
   moves the page *closer* to the original, which displayed no equations or
   readouts at all, so this costs nothing in parity — the shift is still visible
   where it always was, on the spectrometer.

   Two knock-on effects, neither of them silent:

   * **MathJax now typesets nothing.** The vendored copy under `assets/mathjax/`
     (24 MB on disk, a 2.1 MB script on every page load) and the `<script>` tags
     in `index.html` are dead weight. They were kept rather than stripped, because
     the pipeline treats a MathJax include as standard and re-adding an equation
     should not require re-vendoring anything — but if this sim is going to stay
     equation-free, deleting `assets/mathjax/` and the two MathJax `<script>`
     blocks is the right call and takes a minute. The `demoteMathTabStops()`
     observer in `simulation.js` was kept for the same reason.
   * **The size and direction of the shift are no longer shown on screen.** They
     are still announced in full, with units, through the slider's
     `aria-valuetext` and the diagram description, so screen-reader users lose
     nothing; sighted users now read the shift off the spectrum itself. See the
     colour-blindness note in `ACCESSIBILITY.md` if that is a concern.

   The CSS that only served the removed panel (`.sim-equation`, `.sim-readouts`,
   `.sim-num`) was deleted rather than left orphaned, and the on-screen help
   paragraph listing the phase keyboard shortcuts was removed as well, at your
   request. Those shortcuts are unchanged and still documented in
   `ACCESSIBILITY.md`; they are simply no longer spelled out on the page.

8. **Frame-loop guard.** `animOnEnterFrame()` now returns early unless
   `state.running`. `cancelAnimationFrame()` can only cancel the one id the sim
   stores, so if a frame callback were ever already queued when the visitor paused
   or reset, the loop would resurrect itself and advance the rotation out from
   under the new state — Reset would appear to work and then drift. Caught in
   testing; the guard makes stopping depend on state rather than on cancellation
   bookkeeping. No effect on the ported arithmetic.

9. **Two foundation limitations, neither fixed here**, because
   `kl-unl.css` and `kl-unl-masthead.js` must stay byte-for-byte unchanged:

   * `kl-unl.css` line 101 is a stray `u` between the `.app-layout__left` and
     `.app-layout__right` rules. It turns the next selector into
     `u .app-layout__right`, so `.app-layout__right { min-width: 0 }` never
     applies. `styles/styles.css` re-declares it on the sim's own `.sim-split`
     columns to compensate. **Suggested foundation fix: delete the stray `u`.**
   * The masthead's shadow-DOM `.masthead-container` is a non-wrapping flex row
     with 20 px side padding. With three buttons (Reset, Review Help Guide, About)
     its minimum width is **380 px**, so on viewports narrower than that the page
     gains a few pixels of horizontal scroll. At 320 px the document scroll width
     is 380 px and *all* of it comes from the masthead — the simulation's own
     content fits with room to spare, and no sim element overflows at any width.
     Because the container is inside a shadow root, no sim stylesheet can reach it.
     **Suggested foundation fix: add `flex-wrap: wrap` to `.masthead-container`**
     (a no-op at every width where the row already fits). This affects every sim in
     the pipeline equally, so it belongs in the foundation, not here.

---

## Cross-browser notes

Everything used is standards-based with no vendor-prefix-only declarations and no
Chrome-only APIs: inline SVG, `<image>`, `clipPath`, CSS grid and flexbox,
`aspect-ratio`, `prefers-reduced-motion`, Pointer/`wheel` events, and a native
`<input type="range">`.

Verified in this workspace's Chromium browser: no console errors over HTTP, the
only network request beyond the page's own local files is
`foundation/contents.json`, the layout reflows cleanly from 1280 px to 320 px, and
the tab order contains only the skip link, the button and the slider. (The MathJax
context menu was verified while the sim still displayed an equation; there is no
maths on the page now.)

One construct is worth a spot-check on Safari when the sim next reaches a Mac or an
iPhone: the stage composites the exported art with `<image href="assets/….svg">`,
external SVG referenced from inside an inline SVG. This is well supported in
current Safari, and every `<image>` carries explicit `width`, `height` and
`preserveAspectRatio="none"` so nothing depends on intrinsic sizing — but it is the
one place where a WebKit difference would be visible rather than subtle. If it ever
misbehaves, the fix is to inline the same exported path data instead of referencing
the files; the geometry does not change either way.
