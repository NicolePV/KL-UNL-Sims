# Retrograde Motion — conversion notes

## Behaviour model

Earth and a superior planet each ride the **upper half** of an ellipse centred on
the Sun (Earth on the inner orbit, the planet on the outer one). A single
timeline value drives both: Earth sweeps left at 1.3 stage pixels per frame and
the planet at 1.05, so Earth — the faster, inner body — catches and overtakes it.
A magenta sight line is drawn from Earth through the planet and extended out to a
distant line of background stars at `y = -400`; a second copy of the planet is
painted where that line crosses. As Earth overtakes, the projected planet
reverses its drift against the stars — first eastward, then westward, then
eastward again — which is retrograde motion. The user either plays the sequence
with START / STOP or scrubs it by hand with the timeline marker, and RESTART
returns the timeline to its beginning. Three annotation lines appear at fixed
points along the animation to name what is happening.

## Source

The folder held only `retrograde.swf` (700 × 600, 12 fps, SWF v6, AS1) with no
decompiled export, so the SWF was decompiled with JPEXS/FFDec 26.2.1 into the
usual sibling folders (`scripts/`, `shapes/`, `images/`, `sprites/`, `texts/`,
`fonts/`, `frames/`) before conversion. `retrograde.jpg` and `frames/1.png` were
the layout references.

## ActionScript → HTML5 mapping

| Original | Port |
| --- | --- |
| `DefineSprite_12` frames 1–3 (marker-driven state) | `positionsAt(temp)` + `render()`, driven by the slider |
| `DefineSprite_12` frames 4–5 (animating state) | `tick()` on `requestAnimationFrame` |
| `onEnterFrame` at 12 fps | one rAF loop; `temp` advances at `FPS` units per second of elapsed wall-clock time |
| `time` clip: `onClipEvent(load)` `right = left + 250`, `onClipEvent(enterFrame)` `temp = _x - left` | `<input type="range" min="0" max="250">`; `state.temp` |
| `DefineButton2_36` `startDrag`/`stopDrag` on the marker | native range input (pointer **and** keyboard) |
| `DefineButton2_19` / `_24` (START / STOP, sprite 25 frames 1–2) | one `<button>` toggling its label between `START` and `STOP` |
| `DefineButton2_33` (RESTART) | `<button id="restart-btn">` |
| `createEmptyMovieClip("line")` + `lineStyle(2, 16711935, 100)` + `moveTo`/`lineTo` | canvas `stroke()` in `#ff00ff` at 2 px |
| `_root.statusLabel` (`DefineEditText` 43, Verdana bold 16, centred, white) | `#sim-status`, an `aria-live="polite"` caption below the sky |
| Stage title / subtitle (`DefineText` 42) | masthead `<h1>` (from `contents.json`) + `.sim-subtitle` |
| `EAST` / `WEST` (`DefineText` 40, 41) | HTML overlays on the stage, at their original stage percentages |
| `trace()`, `updateAfterEvent()` | dropped / no-op |

## Constants, copied verbatim

```
Earth orbit    x^2/22500 + y^2/11025 = 1      (a = 150, b = 105)
planet orbit   x^2/40000 + y^2/19600 = 1      (a = 200, b = 140)
earth._x = 150 - temp * 1.3        clamped at -149
mars._x  = 135 - temp * 1.05       clamped at -125
background-star line               y = -400
sight line                         colour 16711935 (#ff00ff), width 2, alpha 100
marker travel                      right = left + 250   -> temp in 0 .. 250
frame rate                         12 fps
sprite "retrograde" placed at      (349.95, 556)  — the Sun
earth / mars symbols               26 × 26 px, centre origin
sun symbol                         50 × 50 px, centre origin
```

Annotation thresholds, exactly as `DefineSprite_12` frame 4 branches on
`_root.time.temp` (note the deliberate gaps, where the label is blank):

```
temp < 20                 "The planet is initially moving \neastward relative to the background stars"
26 <= temp < 70           "The planet slows, stops and begins moving \nwestward relative to the background stars"
137 <= temp < 200         "The planet now slows, stops and begins \nmoving eastward again"
otherwise                 ""
```

The animation ends when the planet reaches its clamp:
`135 - temp × 1.05 = -125` → `temp = 247.619…`. At that point the original
calls `_root.startstop.gotoAndStop(1)` and returns to frame 2, so the button
reverts to `START` and the annotation blanks. The port does the same.

Because `temp` and the two x-positions are all linear in the same quantity
(`earth._x = 150 − 1.3·temp` in the scrub state, and `temp = (135 − mars._x)/1.05`
in the animating state give the identical relation), the port carries a **single**
state variable, `temp`, from which every position is recomputed.

## Assets reused as-is (never redrawn)

| Export | Used as | Where |
| --- | --- | --- |
| `shapes/2.svg` (702.1 × 601.3) | `assets/starfield.svg` | `<img>` layer at stage (−0.5, 0) |
| `shapes/3.svg` (403 × 283) | `assets/orbits.svg` | `<img>` layer, origin (201.45, 141.5) placed at the Sun |
| `images/10.png` | `assets/sun.png` | `drawImage`, 50 × 50 centred on the Sun |
| `images/4.png` | `assets/earth.png` | `drawImage`, 26 × 26 centred on Earth |
| `images/7.png` | `assets/mars.png` | `drawImage`, 26 × 26 — used twice, for the planet and its projection |

Only the sight line is code-drawn on the canvas, because it is the only art the
ActionScript builds at runtime. The canvas keeps the original 700 × 600 internal
coordinate system (multiplied by `devicePixelRatio` for crispness) and CSS scales
it; no geometry is ever recomputed from the on-screen size.

`fonts/39_Verdana.ttf` (the status label's font) was **not** copied. Text now uses
the foundation's own font stack so it renders consistently across operating
systems, per the cross-OS requirement.

## contents.json

`foundation/contents.json` **already contains a `retrograde` entry** with the
correct title, version and Help/About text, so no edit was required — the file is
copied in byte-for-byte unchanged along with the rest of `foundation/`. The
existing entry is used as-is:

```json
"retrograde": {
  "meta": { "title": "Retrograde Motion", "version": "2.0" },
  "masthead": {
    "help":  { "title": "Help and Instructions", "content": "<p>This demonstrator shows the retrograde motion of mars with an annotated animation.</p><p>The animation can be started, stopped, and restarted, or the marker can be dragged to and fro along the timeline.</p>" },
    "about": { "title": "About this Demonstrator", "content": "…standard KL-UNL boilerplate…" }
  }
}
```

## Deviations from the original, and why

1. **The timeline marker moved out of the sky into a Controls panel.** The
   original drew a red marker on a track at the top right of the star field. A
   canvas-drawn marker cannot be reached by keyboard or named to a screen reader,
   so it is now a native `<input type="range">` in its own panel. This is the one
   substantial departure from the screenshot's layout (Goal C yields to Goal B).

   The page is laid out in **two columns** — the stage on the left, the timeline
   and buttons in a panel beside it — which puts the controls down the right-hand
   edge much as the original did, and keeps the whole simulation on one screen
   with no vertical scrolling. The stage is capped against the viewport height
   (`max-width: calc((100dvh - 19rem) * 7 / 6)`, so `aspect-ratio` derives the
   height and the 700 × 600 ratio is never broken); measured with no vertical or
   horizontal scrolling at 1440 × 900, 1366 × 768, 1280 × 720 and 1280 × 600.
   Below the foundation's own 56rem breakpoint the two columns collapse to one,
   the height cap is dropped, and the page scrolls normally — at that width
   reflow matters more than fitting one screen.

2. **Scrubbing during the animation stops it instead of being ignored.** The
   original guards `startDrag` with `if (_parent.retrograde._currentframe != 4)`,
   silently dropping the interaction while the animation runs. Silently
   discarding keyboard input is an accessibility failure, so moving the slider now
   pauses the animation and jumps to the scrubbed position. No physics changes.
   (The original guard is also inconsistent in its own right: while playing, the
   timeline alternates between frames 4 and 5, so a press landing on frame 5
   would have been allowed through.)

3. **RESTART always works.** The original disables it while the animation runs
   (`if (startstop._currentframe != 2)`). Here it stops the animation and returns
   the timeline to 0, for the same reason as (2).

4. **Degenerate sight line guarded.** At `temp = 60` Earth and the planet share
   the same x, so the source computes `m = Δy / 0` and `marsretro._x` becomes
   `NaN`. The port detects `|Δx| < 1e-9` and uses the limit of the same formula —
   a vertical sight line, `retroX = earthX` — which is what the geometry means.

5. **The annotation sits below the sky, not over it.** The original painted it
   across the middle of the star field. Long text over a scaled canvas clips at
   large font sizes and 200 % zoom, so it is a caption strip directly under the
   sky, on the same black, with height reserved for two lines so the layout never
   jumps. The wording and its embedded line break are verbatim.

6. **The stage subtitle keeps its original spelling.** The Flash stage reads
   *"the apparent westward motion of a superrior planet"* — "superrior" is
   misspelled in the source. It is reproduced verbatim under the rule that
   educational text is copied exactly. **Recommend correcting it to "superior"**
   before release; that is a content decision, not a conversion one.

7. **The last ~1 % of the slider is inert.** The animation ends at `temp = 247.6`
   but the marker travels to 250, and both planets are clamped over that last
   stretch. This dead zone exists in the original and is preserved.

8. **Timeline announced as a percentage.** The raw slider value is the original's
   0–250 marker travel in stage pixels, which is meaningless spoken aloud, and the
   simulation defines no physical time unit (the orbit ratio is only roughly
   Mars-like). `aria-valuetext` therefore announces "timeline *n* percent".

9. **One-frame ordering difference.** In Flash the `time` clip's
   `onClipEvent(enterFrame)` updates `temp` before the timeline frame script reads
   it, so frame 4's annotation test lagged the marker by one frame (1/12 s). The
   port evaluates both from the same value. Imperceptible, and it removes a bug.

10. **`scaleX = 0.9998779` on the "retrograde" sprite is treated as 1.0**, as are
    the equivalent sub-pixel scales on the buttons and text. These are authoring
    artefacts, below a tenth of a pixel over the whole stage.

## Known issue, in the foundation rather than this sim

At very small effective widths (a phone-portrait viewport **combined with** 200%
text zoom — roughly a 190px layout) the page gains a horizontal scrollbar. The
overflow is entirely inside the masthead's shadow DOM: `.masthead-container` and
`.controls-group` in `kl-unl-masthead.js` are non-wrapping flex rows, so the
title plus the Reset / Help / About buttons cannot reflow. The simulation's own
content measures clean at every width and zoom tested.

Because the shadow root is not stylable from outside and hard rule 7 forbids
editing foundation files, this is left alone. **Suggested foundation fix** (would
benefit every sim): allow `.masthead-container` and `.controls-group` to wrap —
`flex-wrap: wrap` on both, plus `row-gap` on the container.

## Cross-browser notes

- Layout uses grid/flex, `aspect-ratio` and `clamp()`; the canvas also carries its
  own `width`/`height` attributes, so it keeps its intrinsic ratio even where
  `aspect-ratio` is unavailable.
- The EAST/WEST labels size with container query units (`cqi`, Safari 16+,
  Chrome 105+, Firefox 110+) and declare a plain `rem` value first as the
  fallback for older engines.
- Exported SVGs are used as `<img>` layers rather than being drawn into the
  canvas, which sidesteps the historic WebKit restrictions on `drawImage()` with
  SVG sources.
- No vendor-prefix-only declarations; the `-webkit-` selection and callout
  properties are additive.
- MathJax is vendored locally (`assets/mathjax/`), no CDN.
