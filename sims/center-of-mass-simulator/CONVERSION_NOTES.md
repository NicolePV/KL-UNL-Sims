# Conversion Notes — Center of Mass Simulator

## Behaviour model

The simulator shows two spheres sitting on a scaled grid with a green cross
marking their common centre of mass. Three sliders set the mass of object 1
(1.0–10.0), the mass of object 2 (1.0–10.0) and the separation between them
(1.0–20.0), each in steps of 0.1 and each with an editable value box beside it.
The two objects are always drawn exactly 200 stage units apart no matter what
the separation says; changing the separation rescales the *grid* instead, so one
grid square is always one distance unit. The centre of mass is placed by the
lever rule — object 1 sits at `x1 = -200·m2/(m1+m2)` and object 2 at
`x2 = -x1·m1/m2` relative to it — and the labelled distances are the same ratio
in the user's units, `r1 = m2·d/(m1+m2)` and `r2 = m1·d/(m1+m2)`, so `r1 + r2`
is the separation and `m1·r1 = m2·r2` always. Each sphere is drawn at
`100·m^0.37` percent of the exported ball art. A "keep CM fixed" checkbox
chooses the frame: checked, the centre of mass stays at the middle of the grid
and both objects move; unchecked, the objects stay put at ±100 and the centre of
mass slides between them. Nothing animates — every change redraws the whole
scene once.

## Source of truth

| Source file | What was taken from it |
| --- | --- |
| `scripts/DefineSprite_72/frame_1/DoAction.as` | the entire `update()` controller: all positions, scalings, colours, grid loops, `pixelSeparation = 200`, `gridWidth = 420`, `gridHeight = 160`, and the `Number.prototype.toFixed` polyfill |
| `scripts/DefineSprite_72/frame_1/PlaceObject2_14_Standard Slider v6_{9,11,13}/CLIPACTIONRECORD on(initialize).as` | slider labels, ranges, initial values, `precision = 1`, `scalingMode = "linear"`, `precisionMode = "fixed digits"` |
| `scripts/DefineSprite_72/frame_1/PlaceObject2_50_FCheckBoxSymbol_3/CLIPACTIONRECORD on(initialize).as` | checkbox label `" keep CM fixed"`, `initialValue = true` |
| `scripts/Slider Logic Class v6.as` | value quantisation (`minIncrement · round(x/minIncrement)`), clamping order, and the `toFixed` used for the value string |
| `scripts/Standard Slider v6.as` | commit behaviour of the editable value field (Enter commits, focus loss commits, a non-finite entry is rejected and the field re-synchronised), arrow-key step of one tick |
| `sprites/DefineSprite_71/1.png`, `Capture.PNG` | the fixed vertical offsets inside the object container, measured from the exported sprite render and cross-checked against the screenshot of the running original |

`Capture.PNG` is the screenshot of the running Flash sim (869 × 642, i.e. the
500 × 370 stage at ≈174 %). It was measured pixel-by-pixel to confirm every
derived constant. Sample checks, all agreeing to within a pixel: grid pitch
34.95 px ↔ `200/10 × 1.7475`; sphere 1 centre at x = 315 ↔ `x1 = −60`; sphere 1
radius 50.5 px ↔ `14 × 7^0.37`; blue arrow tip at x = 314 ↔ `x1`; red arrow tip
at x = 665 ↔ `x2 = +140`.

## AS1 → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `update()` called by every `changeHandler` | one `render()` driven by one plain `state` object |
| `gridMC.clear(); lineStyle(1, 14737632, 100); moveTo/lineTo` loops | the same two loops on a `<canvas>` 2D context, same `Math.floor(half/spacing)` bounds |
| `linesMC` shafts `lineStyle(1, 26367 / 16711680, 100)` | two `ctx.stroke()` calls; `26367 = #0066ff`, `16711680 = #ff0000` |
| `containerMC.massNMC._xscale = _yscale = 100·m^0.37` | `assets/shapes/53.svg` in an `<img>`, width/height set in percent of the stage box |
| `linesMC.left1MC/right1MC/left2MC/right2MC` at `x1`, `0`, `0`, `x2`, scaled `100·sqrt(|x|/200)` | four elements masked with `assets/shapes/60.svg`, positioned from the arrowhead tip; the two "right" heads carry `rotate(180deg)` about that tip, matching the `_rotation = 180` instances in the SWF |
| `Number.prototype.toFixed` polyfill | `asToFixed()`, ported line for line so every digit matches |
| `SliderLogicClassV6.getValueObjectFromValue` | `quantise()` — clamp into range first, then snap to 0.1 |
| `FUIComponent` / `Standard Slider v6` / `FCheckBoxSymbol` | native `<input type="range">`, `<input type="text">` and `<input type="checkbox">`; none of the Flash component framework is ported, only its observable behaviour |
| `_root`/`_parent` chains, `trace()` | direct references; dropped |

There is no `onEnterFrame`, no `getTimer()` and no randomness anywhere in this
sim, so no animation loop or timing constants were needed.

## Assets: reused vs code-drawn

Reused as-is from the JPEXS export, copied into `assets/shapes/`:

| File | Used for |
| --- | --- |
| `53.svg` | the mass sphere (28 × 28, radial gradient `#cfcfcf → #707070`) |
| `51.svg` | the centre-of-mass cross (12 × 12, `#017e01`) |
| `60.svg` | the arrowhead (22.6 × 22.6, tip at 0.5, 11.3) |
| `69.svg` | the SWF's pale 50 %-alpha highlight cross — **copied for provenance but deliberately not rendered**, see below |

Redrawn on the canvas, because the ActionScript built them at run time and there
is no exported file for them: the grid lines and the two arrow shafts. That is
all.

Nothing was traced or re-vectorised by hand.

**Arrowhead tint.** The SWF has one arrowhead symbol (red) and applies a colour
transform to get the blue pair. Here the same one file is used as a CSS `mask`
with `background-color` supplying the colour, which is the direct equivalent.
`-webkit-mask` is included as an additive fallback alongside the standard
`mask` property.

**`69.svg` is not rendered.** In the SWF the pale cross is stacked at 50 % alpha
on top of `51.svg`, which lightens the marker to exactly `#6dbf6d` — a value
confirmed by sampling the exported sprite render. That colour is 2.3:1 against
white and fails the 3:1 graphical-contrast threshold, and the matching "CM"
caption fails 4.5:1 as text. Omitting the highlight layer leaves the exported
`#017e01`, which clears both. See ACCESSIBILITY.md.

**Fonts.** `fonts/*.ttf` are Verdana subsets embedded by the original SWF.
Verdana is not redistributable and the subsets carry only the glyphs the SWF
used, so they are not shipped. All maths is typeset by MathJax in its own
bundled fonts, and the surrounding UI uses the foundation's font stack.

## The contents.json entry

`sim-id` is **`centerofmass`**, which already existed in the shared
`contents.json`. The copy in `html5/foundation/contents.json` differs from the
shipped file in exactly nine lines:

**1. This sim's `about` content** — the sentence *"Permission is granted to use
these files for noncommercial purposes as long as they remain unmodified."* is
replaced by the Apache License 2.0 notice, and the NSF funding sentence (which
this entry was missing, though most sibling entries have it) is restored. The
astro.unl.edu link and the AAS Applet Task Force sentence are untouched.

**2. This sim's `help` content** — the original SWF contains no Help or About
text at all (its only chrome is an `astro.unl.edu` link), so there was nothing to
copy verbatim. The one-sentence description already in the shared file is kept
and extended with a description of the panels and controls, in the same style as
sibling entries such as `hydrogenatom`.

**3–9. JSON syntax repairs to other sims' entries.** The shipped
`contents.json` does not parse: `JSON.parse` rejects it, so the masthead fetch
fails and no sim using this file gets a title, Reset, Help or About. Four string
values contained a raw newline or tab, and two contained an unescaped `"`:

| Line (original file) | Entry | Problem |
| --- | --- | --- |
| 200–201 | `ce_hc` | literal newline before the closing quote |
| 439–440 | `eclipsingbinarysim` | literal newline before the closing quote |
| 916–917 | `meltednail` | literal newline before the closing quote |
| 1155–1156 | `positionsdemonstrator` | literal newline before the closing quote |
| 1207 | `renaissancePtolemaic` | unescaped `"` in `<a href="../venusphases">` |
| 1224 | `pulsarPeriodSim001` | literal tab inside the string |
| 1802 | `venusphases` | unescaped `"` in an `<a href="...">` |

No wording was changed — only the control characters removed and the quotes
escaped. The same repair is already present in at least one earlier conversion
in this pipeline (`Photometry Simulator`), so this matches existing practice.

**If `contents.json` is meant to be a single shared file** rather than a per-sim
copy, delete `html5/foundation/contents.json`, apply the seven syntax repairs
above to the shared file, and paste this entry into it (it is already in
alphabetical position, between `celhorcomp` and `clusterFittingExplorer`):

```json
  "centerofmass": {
    "meta": {
      "title": "Center of Mass Simulator",
      "version": "2.0"
    },
    "masthead": {
      "help": {
        "title": "Help and Instructions",
        "content": "<p>This simulator shows how the center of mass of two objects changes as their masses change.</p><p>The Diagram panel shows two objects drawn on a grid. The green plus marks the center of mass, labelled CM. The blue arrow spans the distance <em>r</em><sub>1</sub> from object 1 to the center of mass, and the red arrow spans the distance <em>r</em><sub>2</sub> from object 2 to the center of mass. The grid squares are one distance unit on a side, so the grid rescales when the separation changes.</p><p>Use the Controls panel to set the mass of object 1, the mass of object 2, and the separation between the two objects. Each control has a slider and a value box; type a number into the box and press Enter to jump straight to that value, or use the arrow keys on the slider to step by 0.1.</p><p>When keep CM fixed is checked the center of mass stays at the middle of the grid and both objects move. When it is unchecked the two objects stay put and the center of mass shifts between them.</p><p>The Center of Mass Relation panel gives the distances <em>r</em><sub>1</sub> and <em>r</em><sub>2</sub> and shows that the products <em>m</em><sub>1</sub><em>r</em><sub>1</sub> and <em>m</em><sub>2</sub><em>r</em><sub>2</sub> are always equal.</p>"
      },
      "about": {
        "title": "About this Simulator",
        "content": "<p>For additional astronomy education materials please visit <a href=\"https://astro.unl.edu/\">Astronomy Education</a> at the University of Nebraska-Lincoln.</p><p>This simulator has been modernized by the AAS Applet Task Force to meet modern web accessibility standards (WCAG 2.1 AA).</p><p>Initial funding for this work was provided by NSF grants #0231270 and/or #0404988.</p><p>Copyright 2026 The Board of Regents of the University of Nebraska</p><p>Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at</p><p><a href=\"http://www.apache.org/licenses/LICENSE-2.0\">http://www.apache.org/licenses/LICENSE-2.0</a></p><p>Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.</p>"
      }
    }
  },
```

## MathJax

The sim folder's `foundation/` contains only the four required files — there is
no MathJax include and no `demo_01.html` to copy a reference protocol from.
Since rule 8 requires MathJax for all mathematics and rule 5 forbids a CDN,
MathJax 3.2.2 (`tex-mml-chtml` plus its CHTML web fonts, 24 files, 1.6 MB) was
vendored at `foundation/mathjax/`, which is where earlier conversions in this
pipeline put it and the path their `index.html` files reference.

Two things worth knowing for the next conversion in this pipeline:

- **`\boldsymbol` is not available in this build.** It is not in the base TeX
  package and this configuration does not autoload it, so `noundefined` renders
  the macro name as literal red text next to the maths. Use `\mathbf`, which is
  in the base package. The `m₁` / `m₂` object labels use it.
- **MathJax containers cannot be centred by their boxes.** The container is as
  deep as the maths inside it, so `m` with a subscript has depth below the
  baseline and nothing above; centring the box leaves the glyph low. See
  `calibrateMassLabels()` in `simulation.js` and the note in ACCESSIBILITY.md.
- **`\color` is not available either**, for the same reason: it autoloads from
  `input/tex/extensions/color.js`, which the bundle does not contain, and
  fetching it would mean a network request. Where maths has to be tinted — the
  relation panel, where `r₁`, `r₂` and the numbers standing for them are
  colour-matched to their arrows — the equation is written as **MathML** and
  uses MathML's own `mathcolor` attribute. MathML input is part of
  `tex-mml-chtml`, so nothing extra loads. It is still real MathJax output (the
  right-click menu works) and it degrades to native browser MathML if MathJax
  is ever missing, which is better than the LaTeX fallback would have been.

## Deviations from the original

Behaviour is unchanged everywhere. These are presentation and framing changes.

1. **Layout is the KL-UNL shell, not the Flash pixel layout.** Panel structure
   and reading order follow the screenshot: diagram across the top, the three
   sliders below it on the left, the centre-of-mass panel on the right. The
   original's controls sat under the diagram with the checkbox alone in the
   bottom-right corner; here the checkbox lives in the right-hand panel under a
   "Frame of reference" legend, which both balances the two panel heights and
   keeps it next to the relation it governs.

2. **A "Center of Mass" panel was added.** The original showed the r values only
   as small canvas text. Because rule 8a moves all maths out of the canvas and
   into HTML, and because canvas-overlay text has to scale with the diagram (so
   it gets small on a phone), the relation `m₁r₁ = m₂r₂` and its numeric
   substitution are shown here at full page-text size — which also means both
   distances are always legible regardless of how small the diagram gets.
   `r₁`, `r₂` and the numbers standing for them are tinted to match their
   arrows. This displays the sim's own numbers; no new physics.

   An earlier revision also carried two labelled readout boxes repeating
   `r₁ = …` and `r₂ = …`. They were removed as redundant: the diagram already
   labels both distances, and the substitution line shows the same two numbers.

3. **Canvas box is 428 × 168, not 420 × 160.** A 4-unit margin was added around
   the drawn grid so the outermost grid lines are not sliced in half by the edge
   of the element. The internal coordinate system is otherwise untouched: (0, 0)
   is still the grid centre and every ported formula runs in original stage
   units.

4. **The canvas is drawn at display resolution rather than upscaled.** The
   backing store is sized to the displayed box × `devicePixelRatio` and the
   context is scaled once, so the drawing code still works in original
   coordinates but 1-unit grid lines stay crisp at any size — the same result
   Flash gave when the stage was scaled.

5. **Two colours are re-mapped for contrast**, and the CM highlight layer is
   omitted. Details and ratios in ACCESSIBILITY.md. Arrow shafts and arrowheads
   keep the exact source colours.

6. **The `astro.unl.edu` link at the bottom left is not reproduced.** The
   masthead's About dialog carries that link, so a second one would be a
   duplicate.

7. **The masthead can scroll horizontally below ≈340 px.** The title and its
   three buttons reach their own min-content width inside the component's shadow
   DOM, which must not be edited. `kl-unl-masthead { overflow-x: auto }` in
   `styles/styles.css` keeps that overflow inside the masthead so the page
   itself never scrolls sideways.

8. **`kl-unl.css` has a stray `u` character** on its own line between the
   `.app-layout__left` and `.app-layout__right` rules, which makes the
   `.app-layout__right { min-width: 0 }` rule unreachable. The foundation is not
   edited; `styles/styles.css` re-declares `min-width: 0` on this sim's panels
   instead. Worth fixing upstream.

9. **The annotations are drawn at 80 % of the original's size**, at the
   reviewer's request — the arrowheads, and the `CM`, `r₁` and `r₂` labels.
   This is the one place where the port deliberately departs from measured
   parity: at 100 % the arrowheads and the `r` captions matched `Capture.PNG`
   almost exactly (the `r₁` caption measured 60.3 stage units against the
   original's ≈59.5), but they read as heavy in the wider KL-UNL panel, where
   the stage is scaled up more than the Flash version ever was.

   The change is presentation only and is expressed as a single multiplier,
   `ARROWHEAD_DISPLAY_SCALE = 0.8` in `simulation.js`, applied on top of the
   untouched AS formula `100·sqrt(|x|/200)`. The heads therefore still grow and
   shrink with their arrow exactly as the original did. The label sizes are the
   `.com-lbl` font-size in `styles/styles.css`, reduced from `0.82rem` to
   `0.66rem` per unit of stage scale. The `m₁`/`m₂` object labels were left at
   their own size, which was set separately to fit the smallest sphere.

## Cross-browser notes

Everything used here is standards-based: `<canvas>` 2D, Pointer/native form
controls, CSS grid, `aspect-ratio`, `mask`, `max()`, `ResizeObserver`,
`MutationObserver`, `prefers-contrast` and `prefers-reduced-motion`. All are
supported in current Chrome, Edge, Firefox and Safari (desktop and iOS).

- `mask` ships with `-webkit-mask` alongside it, so WebKit takes the prefixed
  form and Firefox the standard one.
- `prefers-contrast: more` is not implemented by every browser; where it is
  absent the sim simply keeps the default palette, which already meets AA.
- `ResizeObserver` is present everywhere the sim targets, but `resize`, `load`
  and `pageshow` listeners are registered alongside it so a browser without it,
  or a tab that has never been composited, still gets a correctly sized canvas.
- The range slider is skinned through `::-webkit-slider-*` and `::-moz-range-*`
  in parallel; it stays a native `<input type="range">`, so its keyboard
  behaviour is the browser's own in every engine.

Verified in this environment against Chromium. Human QA on Safari (desktop and
iOS) and Firefox is still worth doing before release.
