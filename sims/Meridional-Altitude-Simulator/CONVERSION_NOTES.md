# Conversion Notes — Meridional Altitude Simulator

## Behaviour model

The simulation shows the same sky twice and links the two pictures. On the left is
a cross-section of the Earth: a circle with its polar axis and equator, and a
draggable observer sitting on the surface, whose zenith, horizon (north/south) and
celestial-pole directions are drawn as arrows that swing round as the observer's
latitude changes. On the right is that same observer's horizon diagram — a dome
with north and south on the horizon, the zenith overhead, and arrows for the north
(or south) celestial pole and the celestial equator, whose altitudes follow
directly from the latitude. The user picks an object (none, star, Sun, planet or
Moon), sets its declination with a slider whose limits depend on the object
(±90° for a star, ±23.5° for the Sun and planets, ±29.3° for the Moon), and the
object is placed on the meridian of the horizon diagram with a sight line and a
shaded declination angle measured from the celestial equator. A readout builds the
arithmetic for the object's meridional altitude term by term — `90 − latitude +
declination`, wrapped as `180 − (…)` when the object culminates past the zenith —
with the latitude and declination terms colour-matched to the shaded angles.
Two checkboxes shade the band of the sky the Sun/planets and the Moon can occupy.

## Source

The folder contained only `meridaltdiagram.swf` (no decompiled sources), so the
SWF was decompiled with the JPEXS/FFDec build already installed on this machine
(`C:\Program Files (x86)\FFDec`). The decompiled ActionScript and exported assets
live in the session scratchpad, not in the simulation folder. The behavioural
ground truth is:

| Source file | Role |
| --- | --- |
| `scripts/question.as` | Main controller: `onEnterFrame`, `moveObj`, `moveText`, `drawAngles`, `calcAlt` |
| `scripts/tangDiagram.as` | Earth cross-section: `setPos`, `calculatePos` |
| `scripts/SliderV3Symbol.as`, `SliderV3forLat.as`, `SliderV3forDec.as` | Slider value rounding, limits, label text |
| `scripts/SliderV3GrabberSymbol.as`, `SliderV3BarSymbol.as` | Slider drag and click-to-step |
| `scripts/objectRadio.as`, `rangeCheckbox.as`, `arrow.as` | Radio group, checkboxes, arrow tinting |
| `DefineSprite_*/…/CLIPACTIONRECORD on(initialize).as` | Initial values and every on-screen label string |
| SWF placement matrices (`-swf2xml`) | Exact stage geometry |

`scripts/FUIComponentSymbol.as`, `FCheckBoxSymbol.as`, `FRadioButtonSymbol.as` and
`FLabelSymbol.as` are the Flash UI component framework. Per the conversion brief
these were **not** ported; only their observable behaviour is reproduced, using
native accessible controls.

## Geometry

Original stage: 720 × 560 at 12 fps. The `question` clip sits at (17.1, 17.1).
Absolute stage coordinates used by the port:

| Anchor | Coordinates |
| --- | --- |
| `merDiag` (horizon diagram, right) | (478.2, 260.05) |
| `tanDiag` (Earth cross-section, left) | (153.2, 200.05) |

The canvas keeps the original coordinate system exactly: its backing store is
720 × 400 (× `devicePixelRatio`), covering the diagram area of the Flash stage.
The bottom 160 px of the original stage was the control strip; that is now HTML,
so the static line art that spans both regions is simply clipped by the canvas.
CSS scales the canvas; pointer coordinates are mapped back through that scale, so
no drawing or physics maths is ever recomputed from the on-screen size.

## ActionScript → HTML5 mapping

| ActionScript idiom | HTML5 equivalent |
| --- | --- |
| `Object.registerClass` + `prototype = new MovieClip()` | Plain state object plus drawing functions; no class hierarchy needed |
| `onEnterFrame` (12 fps polling loop) | Event-driven `render()`. The original loop is idempotent — nothing moves without user input — so a `requestAnimationFrame` loop would burn cycles to redraw an identical frame. Every input path calls `render()` instead. |
| `createEmptyMovieClip` + `beginFill` / `lineTo` / `curveTo` | Canvas 2D paths with identical coordinates |
| `curveTo` (quadratic Bézier approximating an arc) | `ctx.quadraticCurveTo` with the *same* control points, **not** `ctx.arc`. The source picks its control point on the arc's mid-angle; reproducing the quadratic keeps the wedge outlines pixel-faithful, especially for the wide 120 px range bands. |
| `_rotation` (degrees) | `ctx.rotate(rad(deg))` around a translated origin |
| AS colour ints, alpha 0–100 | Hex colours, `globalAlpha` = alpha / 100 |
| `Color.setRGB` tinting one shared arrow shape | The exported `arrow.svg` is reused and its single fill/stroke colour substituted, producing one crisp scalable image per colour — the shape is never redrawn |
| `attachMovie` + depth ordering | Fixed draw order. Note that clips created at runtime by `createEmptyMovieClip` (depths 1–7) sit **above** all timeline content in AS1, which is why the angle wedges and range bands are painted last. |
| `_root` / `_parent` chains | Direct references |
| `SliderV3` component | Native `<input type="range">`, step 0.1 (the component's `_minIncrement` = 10^−precision) |
| `FCheckBox` / `FRadioButton` | Native `<input type="checkbox">` / `<input type="radio">` |
| `setTextFormat(start, end, format)` colouring characters of the altitude string | MathJax `\color{…}{…}` around the same latitude and declination terms |

## Assets reused vs. code-drawn

**Reused as files** (copied to `assets/`, never traced or redrawn):

| Output file | Source | Used for |
| --- | --- | --- |
| `arrow.svg` | `shapes/84.svg` | Every arrow (tinted per instance) |
| `right-angle.svg` | `shapes/87.svg` | Right-angle tick in the pole group |
| `earth-circle.svg` | `shapes/83.svg` | The r = 60 Earth circle |
| `earth-axes.svg` | `shapes/91.svg` | Polar axis and equator lines inside the circle |
| `diagram-lines.svg` | `shapes/101.svg` | Horizon dome and static rules |
| `sun.svg` | `shapes/124.svg` | The Sun |
| `star.svg` | `shapes/126.svg` | The star |
| `planet.png` | `images/116.png` | Saturn (bitmap preferred per the brief) |
| `moon.png` | `images/120.png` | The Moon (bitmap) |

**Reproduced with canvas drawing** (art the ActionScript builds at runtime, so no
exported file exists): the zenith line, the object sight line, the declination
wedge, the three latitude wedges, and the Sun/planet and Moon range bands.

The `#333333` panel background is a solid-fill rectangle in the export
(`shapes/99.svg`, a single path); it is reproduced as one `fillRect` rather than
loading a 459-byte SVG of a rectangle. The decorative rounded border
(`shapes/100.svg`) around the Flash panels is replaced by KL-UNL panel styling.

MathJax is vendored locally in `assets/mathjax/` (copied from the sibling
converted sim), since the foundation folder for this sim does not include it and
rule 5 forbids a CDN.

## contents.json

**No edit was made.** `foundation/contents.json` already contains an entry under
this sim's id, `meridaltdiagram`, so it was copied in byte-for-byte along with the
rest of the foundation. Two things about that pre-existing entry are worth the
maintainer's attention:

1. `meta.title` reads **"Meridial Diagram"**. "Meridial" is not a word;
   this is almost certainly a typo for "Meridional", and the title does not match
   the simulation's own name ("Meridional Altitude Simulator", per the original
   `meridaltdiagram.html`). The masthead renders this string as the page's `<h1>`.
2. The Help text is a one-line stub. The original SWF contains **no** Help or
   About text at all — there is no `texts/` string, no dialog and no info button
   anywhere in the decompiled source — so there is nothing verbatim to import.

Because the conversion brief permits only *adding* an entry, neither was changed.
If you want the title corrected and the Help expanded, replace the
`"meridaltdiagram"` entry with:

```json
  "meridaltdiagram": {
    "meta": {
      "title": "Meridional Altitude Simulator",
      "version": "2.0"
    },
    "masthead": {
      "help": {
        "title": "Help and Instructions",
        "content": "<p>This simulator shows the geometry for calculating the meridional altitude of objects &mdash; the altitude an object reaches when it crosses the meridian.</p><p>The left panel is a cross-section of the Earth. Drag the observer marker, or focus it and use the arrow keys, to change the observer's latitude. The right panel shows that observer's horizon, with the celestial pole and the celestial equator drawn at the altitudes the latitude implies.</p><p>Choose an object and set its declination with the slider. The declination range available depends on the object: a star may take any declination, the Sun and planets stay within &plusmn;23.5&deg;, and the Moon within &plusmn;29.3&deg;. The readout builds the arithmetic for the object's meridional altitude, with the latitude and declination terms coloured to match the shaded angles in the diagrams.</p><p>The two checkboxes shade the band of sky that the Sun and planets, or the Moon, can occupy at the chosen latitude.</p>"
      },
      "about": {
        "title": "About this Simulator",
        "content": "<p>For additional astronomy education materials please visit <a href=\"https://astro.unl.edu/\" target=\"_blank\" rel=\"noopener noreferrer\">Astronomy Education<span class=\"sr-only\"> (opens in new tab)</span></a> at the University of Nebraska-Lincoln.</p><p>This simulator has been modernized by the AAS Applet Task Force to meet modern web accessibility standards (WCAG 2.1 AA).</p><p>Initial funding for this work was provided by NSF grants #0231270 and/or #0404988.</p><p>Copyright 2026 The Board of Regents of the University of Nebraska</p><p class=\"p-indent\">Licensed under <a href=\"https://www.apache.org/licenses/LICENSE-2.0\" target=\"_blank\" rel=\"noopener noreferrer\">the Apache License, Version 2.0<span class=\"sr-only\"> (opens in new tab)</span></a> (the \"License\"); you may not use this file except in compliance with the License.</p><p class=\"p-indent\">Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.</p>"
      }
    }
  },
```

Note that this Help text is **newly written**, not imported from the original —
it describes the simulation as built. It needs a subject-matter review before use.

### Two further foundation issues found while testing

**`kl-unl-masthead.js` does not reflow.** Its shadow DOM lays the title and the
Reset / Review Help Guide / About buttons out in a flex row with no `flex-wrap`.
On a 375 px screen at 200% zoom that row measures 540 px and dragged the entire
page into horizontal scrolling — the sim's own content measured exactly 375 px.
The component's code is off-limits and it exposes no custom property for this, so
the host element (which belongs to this document, not the foundation) is given
`max-width: 100%; overflow-x: auto` in `styles/styles.css`. The page is now
reflow-clean; at that extreme the masthead bar alone scrolls. **The real fix is a
`flex-wrap: wrap` on `.masthead-container` in `kl-unl-masthead.js`**, which would
benefit every sim in the pipeline.

Also note that the copied `foundation/kl-unl.css` contains a stray `u` on line 101
(between the `.app-layout__left` and `.app-layout__right` rules). This is a defect
in the foundation, not in this conversion; it was deliberately **not** fixed,
since the foundation files are copied byte-for-byte. It is harmless (the browser
discards the invalid token) but worth fixing upstream.

## Deviations from the original

1. **Layout.** The Flash pixel layout, palette, fonts and chrome are not
   reproduced. The panel structure and reading order of the original are kept —
   diagram on top, then Object | Coordinates | Meridional Altitude along the
   bottom — expressed with KL-UNL classes. The three-across control row uses the
   foundation's `.app-layout` plus one sim-specific breakpoint (in
   `styles/styles.css`, never in the foundation) for the pair on the right.

   The row is reproportioned to roughly 325 / 246 / 410 px at the shell's full
   width, rather than the foundation's flat `25rem + 1fr`. The Meridional
   Altitude panel needs to be the widest of the three because it holds the
   equation — which is also how the original is laid out. Because
   `styles.css` loads after `kl-unl.css`, this override would otherwise
   out-cascade the foundation's own collapse at 56rem, so the single-column rule
   is explicitly restored in the sim's matching media query.

   The three panels in that row are held to a common height so the bottom of the
   page reads as one band rather than a ragged edge, matching the original's
   uniform control strip. This needs an explicit `flex-direction: row` on the
   wrappers: the foundation makes `.app-layout__left` a *column* flex container,
   which sizes its panel to content, so the Object panel would otherwise come out
   60 px shorter than its neighbours. Heights stay matched as the declination row
   appears and disappears with the object selection. (When the row collapses to a
   single column the panels are full width and take their natural heights, which
   is correct.)

   The equation is sized with a container query against its own panel
   (`clamp(1.125rem, 4.5cqi, 1.25rem)`), so the longest form it can produce —
   `180 − (90 − 15.3 + 89.9) = 15.4°`, about 31.8ex or 16.5× the font size —
   fits whole at every layout width without horizontal scrolling. It never drops
   below the body text size, and returns to the full 1.25rem once the panel is
   wide enough (which includes every stacked/mobile layout, where the panel is
   full width).
2. **Diagram labels moved from canvas to HTML.** Every symbol (`NCP`/`SCP`, `CE`,
   `N`, `S`, `Z`, `NP`, `SP`, `EQ`) is a MathJax-typeset HTML overlay positioned
   from the original `moveText()` anchors, rather than text painted on the canvas.
   This is required by the MathJax rule and also makes the labels zoom with the
   browser. Side effect: the labels now paint above the translucent range bands,
   whereas in the original they sat below them. They remain legible either way.
3. **Latitude rounding during drag.** The original draws one frame using the raw
   `atan2` angle and only writes the rounded value into the slider on the
   following frame, so the drawing can lead the slider by a frame. The port
   rounds to the slider's own 0.1° precision immediately, which matches the
   original's steady state and removes the one-frame disagreement. The displayed
   altitude is unaffected: `calcAlt` rounds to 0.1° anyway.
4. **Larger drag target.** The original starts a drag only when the pointer is on
   the thin arrow graphics. The port uses a 44 px circular handle at the same
   anchor, meeting the touch-target minimum. It is therefore possible to start a
   drag from a spot the original would have ignored.
5. **No object selected.** The original simply hides the altitude field. The port
   shows the sentence "Select an object to see its meridional altitude." in its
   place rather than leaving an empty box.
6. **"Ranges" legend.** The two checkboxes have no group label in the original;
   a `<legend>Ranges</legend>` was added so the grouping is exposed to assistive
   technology.
7. **Colour remaps for contrast.** Three colours were lightened within their own
   hue to meet WCAG contrast; see `ACCESSIBILITY.md` for the values and ratios.
   The translucent range bands keep their original fill and gain a contrast-safe
   outline rather than being recoloured.
8. **No Pause button.** The original has an `onEnterFrame` loop but nothing moves
   without user input — there is no animation, timer or motion to stop — so a
   Pause control would have nothing to pause. `prefers-reduced-motion` is honoured
   defensively in CSS.

## Verification performed

- **`calcAlt` parity:** the ported function was checked against a direct
  line-by-line transcription of the ActionScript over **35,862** latitude ×
  declination combinations spanning the full ±90° range. Both the computed
  altitude and the `180 − (…)` wrapping flag matched on every one; zero failures.
- **Drag maths:** pointer positions due east, north and south of the
  cross-section centre, and at 41°, return latitudes 0, +90, −90 and 41
  respectively; the source's `if (x < 0) x = 0` clamp reproduces correctly.
- **Keyboard path:** arrows step 0.1°, Page keys 10°, Home/End reach ∓90°, and
  produce the same state as the pointer path.
- **State transitions:** declination clamps to ±23.5° when switching to the Sun
  and stays put when the new limit is wider; the object hides when its computed
  angle leaves the −180°…0° window; `N`/`S` labels hide at ±90°; the pole label
  switches NCP ↔ SCP across latitude 0.
- **Reset:** the masthead `sim-reset` event restores object, latitude,
  declination and both checkboxes to their exact initial values.
- **Layout:** no horizontal page overflow at 1280 px, 920 px, 768 px or 375 px,
  nor at 375 px with a simulated 200% zoom; panels stack to a single column in
  reading order at phone width.
- **Panel heights:** the three control panels measure identically (272 px at
  1280 px, 279 px at 920 px) with tops and bottoms aligned, both with an object
  selected and with "No Object" hiding the declination row.
- **Equation fit** (its longest possible form) measured against the space
  available, at every layout width:

  | Viewport | Layout | Font | Headroom |
  | --- | --- | --- | --- |
  | 1280 px | three across | 18.5 px | 18% |
  | 920 px | three across (tightest) | 18 px | 12% |
  | 768 px | stacked | 20 px | 54% |
  | 375 px | stacked | 18 px | 11% |
  | 375 px @ 200% | stacked | 36 px | scrolls in its own box |

  Only the last case scrolls, and only inside the equation box — the page itself
  does not. That is an effective 187 CSS px of width, well past the 320 px that
  WCAG 1.4.10 asks for.
- **Tab order:** contains only interactive controls. All 19 MathJax containers
  carry `tabindex="-1"`; none is a tab stop.
- **Console:** no errors over a full interaction cycle served over HTTP; the only
  requests are to files inside `html5/`.

**Not verified:** the browser tooling in this session could not capture page
screenshots, so the canvas was inspected directly (rendered and compared against
the original's own frame render and screenshot) but the assembled HTML page —
panel spacing, label placement over the canvas, alignment — was checked
numerically rather than visually. A human visual pass is still needed, as is
real screen-reader QA and a check on Safari and mobile hardware.
