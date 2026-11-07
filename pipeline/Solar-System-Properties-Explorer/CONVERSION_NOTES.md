# Conversion Notes — Solar System Properties Explorer

## Behaviour model

The Explorer draws a single bar chart (histogram) of one physical property across the eight planets
plus Pluto. Three checkboxes select which *groups* of objects appear — terrestrial planets, jovian
planets, Pluto — and six radio buttons select *which property* is plotted: semi-major axis, orbital
period, mass, radius, number of satellites, or density. Whenever either control changes, the sim
tears down every bar, re-attaches one bar per visible object, spaces them evenly along a fixed-length
axis (halving the bar width until at least 10 units of gap remain), and rescales the vertical axis.
The axis end points are computed from the **full nine-object data set**, not from the visible subset,
so hiding a group never rescales the chart. If the full range spans more than 50 units the axis
switches to a base-10 logarithmic scale. Bars are coloured by group (terrestrial red, jovian blue,
Pluto green), labelled with the object's name underneath, and the property name is drawn as a
centred title above the plot. Nothing animates and there is no timing behaviour at all.

## Source recovery — read this first

**The linked simulation folder did not contain a JPEXS/FFDec export.** It held only
`solarSystemProperties003.fla`, `solarSystemProperties003.swf` and a screenshot — no `scripts/`,
`shapes/`, `images/`, `symbolClass/` or `texts/` folders, and no `foundation/` subfolder.

Rather than guess, the SWF was decompiled directly for this conversion:

* the compressed (`CWS`) SWF was inflated and its tag stream parsed;
* every `DoAction`, `DoInitAction`, `DefineButton2` and `PlaceObject2` clip-action block was
  disassembled from AS1 bytecode and then decompiled back to readable ActionScript by
  reconstructing the stack machine's expressions;
* placement matrices, shape fill/line styles, `DefineEditText` fields and `DefineText` static
  strings (via the `DefineFont2` glyph→character tables) were read out of the tag stream to recover
  exact geometry, colours and wording.

Everything below is taken from that recovered source. Nothing was invented or inferred from the
screenshot except where explicitly noted.

The `foundation/` folder was taken from the shared pipeline copy that sits one level up, beside the
simulation folders (`Summer 26/foundation/`), and copied in byte-for-byte.

## contents.json

**No edit was needed.** The shared `contents.json` already contains a `solarsystemproperties`
entry with `meta.title`, `meta.version` and the `masthead.help` / `masthead.about` content, in
alphabetical position. That file was copied into `html5/foundation/` unchanged along with the rest
of the foundation, and `index.html` passes `sim-id="solarsystemproperties"` and
`json-url="foundation/contents.json"`. No foundation file — including `contents.json` — differs
from the shared copy.

## AS1 → HTML5 mapping

| ActionScript | HTML5 port |
| --- | --- |
| `Object.registerClass('histogram_component', histoClass)` | plain state object + `render()` in `simulation.js` |
| `histoClass()` constructor data tables | module-level constants (`semiMajorAxis_array` … `density_array`), copied verbatim |
| `p.onEnterFrame` polling `checkBox._changed` / `radio._changed` | `change` listeners on the native `<input>`s call `render()` directly — same observable result, no frame loop |
| `p.placeBars(num)` / `p.spaceBars(num)` | `computeBarLayout(num)` + `barX(layout, k)` — same halve-until-10-units-of-gap loop |
| `p.placeLabel(label, index)` (`misc_label`, centred, `_x = bar_w / 2`) | an HTML `<span>` anchored at the bar centre in `renderBarLabels()` |
| `p.placeValues(radio_value)` switch | the `PROPERTIES` table; titles are the verbatim strings |
| `p.place(array_obj)` | `buildModel()` — high/low, log decision, bar heights, tick loop |
| `p.findHighValue` / `findLowValue` / `findGoodHigh` / `findGoodLow` / `findPixelVal` / `logBaseTen` | one-for-one JS functions, same branches, same constants (including `2.302585092994046`) |
| `barClass.changeHeight(val, newH)` (`myBack`, tinted `myColor`, 2-unit `#333333` outline) | `drawBar()` on the 2-D context, including the non-uniform x-scale so the outline's vertical strokes scale with the bar exactly as Flash scaled them |
| `barClass.setColor(col)` (`Color.setRGB`) | per-bar `fillStyle` |
| `bar.value` text field (`_visible = false`) | not drawn — the original never shows it. The values are exposed to screen readers instead (see ACCESSIBILITY.md) |
| `radioClass()` / `checkClass()` and their `changeHandler` functions | native `<input type="radio" name="property">` and `<input type="checkbox">` |
| root `onReset()` | listener for the masthead's `sim-reset` event; restores the exact initial state |
| Flash `Title Bar` symbol with its `reset` / `about` links, `Dialog Window v2`, `About` | `<kl-unl-masthead>` — no self-built masthead, dialog or Reset button |
| `FUIComponent` / `FRadioButton` / `FCheckBox` component framework | **not ported.** Only the observable behaviour is reproduced, using native accessible controls |
| `_global.displayText(...)` with its `<sup>`/`<sub>` parser | MathJax via `klunlShowEquation()`; the density title's `<sup>3</sup>` becomes a real typeset exponent |

## Constants recovered from the SWF (not from the source text)

These come from the placement matrices and shape records of the `histogram_component` symbol,
because the AS reads them off the stage at runtime (`this.graphLine._width`, `this.high_tick._y`, …):

| Constant | Value | Where it comes from |
| --- | --- | --- |
| `PIXEL_HIGH` | `-350` | `high_tick` placement `ty` |
| `PIXEL_LOW` | `0` | `low_tick` placement `ty` |
| `X_OFFSET` | `100.1` | `graphLine` placement `tx` |
| `GRAPH_LENGTH` | `502 × 1.1200103760` | `graphLine` symbol width × its placement x-scale |
| `BAR_NATURAL_WIDTH` | `9 × 8.8888854980` | `myBack`'s 9-unit shape × its placement x-scale |
| `BAR_COLOR_WIDTH` | `80 × 0.9994964600` | `myColor`'s 80-unit shape × its placement x-scale |
| tick mark | x 70 → 80, 2-unit stroke | `tick_mark` symbol (shape 112) |
| bar colours | `#F58181` / `#80A9E6` / `#74CF7C` | `p.terrColor` = 16089473, `p.jovColor` = 8432102, `p.pluColor` = 7655292 |
| bar backing plate | `#CCCCCC` | shape 68 fill |
| bar outline / axis / ticks | `#333333` | `lineStyle(2, 3355443, 100)` and the shape 112 / 114 line styles |

## Assets

**No exported bitmaps or SVGs exist for this simulation**, and none are needed: the Explorer draws
everything at runtime or from trivial primitive shape records. Concretely —

* the axis line, the tick marks, the bar body and the bar backing plate are axis-aligned rectangles
  and horizontal 2-unit strokes, read out of the SWF's `DefineShape` records and reproduced on the
  canvas with the same coordinates, stroke weights and colours;
* the bar outline is genuinely code-drawn (`createEmptyMovieClip` + `lineStyle`/`lineTo` inside
  `barClass.changeHeight`), so it is reproduced with canvas 2-D drawing;
* the only bitmaps in the SWF belong to the Flash chrome (title bar, dialog window, the About
  panel's photograph and the `FUIComponent` widget skins), all of which are replaced by the KL-UNL
  masthead and native controls.

`assets/` therefore holds only the vendored MathJax build. Had a JPEXS export been available, no
element of this sim would have needed a file from it.

## Deviations from the original

1. **Chrome.** The Flash title bar with its `reset` / `about` links, its custom dialog window and
   the About panel are replaced by `<kl-unl-masthead>`, per the pipeline rules. Reset behaviour is
   identical (`onReset()`), and the About/Help wording comes from `contents.json`.
2. **Layout is the KL-UNL shell, not the Flash pixel layout.** The panel structure, grouping and
   reading order of the original are preserved — chart on top, "Types of Planets" on the left,
   "Properties" on the right in two columns of three in exactly the original's visual order — but
   expressed with `.app-shell` / `.app-layout` / `.panel` / `.control-*` classes rather than fixed
   coordinates. The two control panels sit side by side on desktop and stack at the foundation's
   own 56 rem breakpoint.
3. **Chart title placement.** The original centred the title over the *plot area* (x = 375 of 680).
   Here it is the panel's `<h2>` heading and is centred over the *panel*. A ~5% horizontal shift.
4. **The bar `value` text field.** `barClass()` sets `value._visible = false` and nothing ever shows
   it, so no numeric labels are drawn — matching the original. The numbers are exposed to assistive
   technology instead (a visually hidden data table), which adds no visible UI.
5. **Rotation Period is not offered.** The source contains `rotationPeriod_array` and a
   `changeToRotation()` handler, but `radioClass()` runs `this.rotation_radio._visible = false` and
   no `rotation_radio` instance is placed in the `radio_buttons` symbol, so the original sim cannot
   plot it. The port keeps the data table and the property definition but, like the original,
   exposes no control for it.
6. **Control labels are trimmed.** The original labels carry leading spaces used purely for Flash
   layout (`' Semi-Major Axis'`, `'    Terrestrial'`). Those are dropped; the words are unchanged.
7. **Object names rotate on narrow screens.** When the per-bar pitch drops below the width of the
   widest name — phone portrait, or high zoom — the names under the bars pivot to −60° instead of
   overlapping. The text is never abbreviated or dropped. On desktop and iPad they stay horizontal,
   exactly as in the original.
8. **Touch targets.** Each checkbox/radio row is at least 44 px tall, which makes the two control
   panels taller than the original's 30 px rows.
9. **All text moved off the canvas.** Axis values and object names are HTML, not canvas-painted, so
   they zoom with the page and the axis numbers can be typeset by MathJax. Their positions are still
   computed in the original Flash stage coordinates.

## Rendering architecture

The canvas keeps the original internal coordinate system: a stage rectangle of
x ∈ [0, 680], y ∈ [−366, 6] in Flash stage units, matching the `histogram_component` symbol's own
coordinates. All drawing and physics math runs in those units and is never recomputed from the live
element size. `sizeCanvas()` sets the backing store to the rendered CSS size × `devicePixelRatio`
and installs a single `setTransform`, so the drawing code never learns the on-screen size while the
output stays crisp at any scale. HTML overlays are positioned as percentages of the same stage
rectangle, and a `--stage-scale` custom property (CSS px per stage unit) drives their type size.

## Browser notes

Standards-only HTML/CSS/JS: no vendor-prefixed-only declarations, no Chrome-specific APIs. The
features used with the narrowest support are `aspect-ratio`, `ResizeObserver` and CSS `max()`, all
of which have been supported in Safari (desktop and iOS), Chrome, Edge and Firefox for several
years; `ResizeObserver` additionally has a `window.resize` fallback. Pointer input is not needed —
every control is a native form control — so there is no touch/hover path to diverge. Fonts fall back
through `Verdana, "DejaVu Sans", Geneva, Tahoma, sans-serif` so the chart labels render sensibly on
Linux and Android, which ship none of the original's Windows/macOS fonts. No per-browser differences
are known.
