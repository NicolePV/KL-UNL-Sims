# Galactic Redshift Simulator — conversion notes

## Behaviour model

The simulator shows the measured spectrum of a galaxy — relative flux against
wavelength — as a curve on a plot spanning 250–950 nm of *observed* wavelength. A single
control, the redshift slider `z` (0.00–1.00 in steps of 0.01, with a matching editable
number field), stretches every emitted wavelength by a factor of `1 + z + 0.000684`, so
raising `z` slides the whole spectrum bodily toward longer wavelengths and the
characteristic sharp rise near 400 nm emitted marches to the right. Above the plot a
narrow strip renders what the galaxy's light actually looks like across the visible band
(400–700 nm), computed by binning the redshifted flux into the strip's pixel columns,
normalising to the brightest column, and colouring each column by its wavelength — so as
`z` grows the visible strip dims and reddens. A *show filter details* button reveals,
with a 200 ms cubic ease, the U, B, V and R filter bandpasses drawn over the plot (each
filled at 30% alpha, scaled by the flux underneath it) together with a four-bar chart of
the brightness measured through each filter. Each bar's magnitude is
`m = −ln(∫ T(λ)·F_obs(λ) dλ)` integrated by the trapezium rule over that filter's
transmission table, and its height is `(−m − 1) / (4.8 − 1)` of full scale. The filter
bandpasses stay fixed in observed wavelength; only the flux under them moves, which is
the whole pedagogical point — as the galaxy recedes its light drops out of the blue
filters and into the red ones. Reset returns `z` to 0 and hides the filter details.

## Source files read

| File | Role |
| --- | --- |
| `scripts/GalacticRedshift.as` | main controller; embeds the spectrum + 4 filter tables (307 KB) |
| `scripts/Spectrum.as` | base plot: background, border, mask |
| `scripts/SpectrumGraph.as` | curve drawing, 1 nm resampling, filter fills, magnitudes |
| `scripts/SpectrumVisualization.as` | visible-band colour strip (BitmapData) |
| `scripts/FilterStrengthsChart.as` | the four bars and their scaleY formula |
| `scripts/ProtoSimpleSlider.as`, `ProtoSliderLogic.as` | slider value model + number field |
| `scripts/astroUNL/utils/easing/CubicEaser.as` | the 200 ms show/hide ease |
| `texts/*.txt` | all on-screen strings |
| `frames/1.png`, `Capture.PNG` | stage layout (800×630) and the running original |

## ActionScript → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `Sprite`/`Shape` + `graphics.lineTo/beginFill/drawRect` | canvas 2D paths, identical coordinates |
| `_content.mask = _mask` | `ctx.save(); ctx.rect(...); ctx.clip()` |
| `_filters.alpha` over four 30% fills | fills flattened into an offscreen canvas, then composited once at the ease alpha (reproduces Flash's "composite the Shape, then apply its alpha" order — verified pixel-exact where U/B and V/R overlap) |
| `BitmapData.fillRect` per column | `ctx.fillRect` per column on a 300×30 canvas |
| `Timer(10)` + `getTimer()` | `setInterval(…, 10)` + `performance.now()` |
| `CubicEaser` | ported method-for-method (`doComputations`, `getValue`, `getDerivative`) |
| `ProtoSimpleSlider` + `ProtoSliderLogic` | native `<input type="range">` + `<input type="text">`; the "fixed digits, 2" value model (clamp → snap to 0.01 → `toFixed(2)`) is reproduced |
| `fl.controls.Button` | native `<button class="button">` |
| `NAAPTitleBar` (title, reset, about) | `<kl-unl-masthead>` + its `sim-reset` event |
| `MovieClip.scaleY` on each bar | CSS `transform: scaleY(k)` with `transform-origin: bottom` — identical semantics, including values above 1 (the R bar legitimately overflows its box at low `z`, exactly as in Flash) |
| `trace(...)` | dropped |
| `Spectrum.onMouseMoveFunc` | dropped — it computes a local and discards it (dead code in the original) |

### Constants carried over verbatim

`_redshiftOffset = 0.000684` · plot 700×300 at 250–950 nm, `maxF = 1.05` · strip
300×30 at 400–700 nm, `maxF = 1` · observed-flux resampling at 1 nm over 701 bins
starting at 250 nm · filter fill alpha `0.3` · filter colours `0xB43FFA` (U),
`0x200074` (B), `0x24AA00` (V), `0xE36D00` (R) · bar scale limits `1` and `4.8` ·
ease duration `200` ms · the visible-spectrum colour ramp
`[0, 255, 65535, 65280, 16776960, 16711680, 0]` at stops `[0, 48, 96, 128, 160, 207, 256]`
· tick marks at 250…950 nm every 50 nm, labelled every 100 nm from 300 to 900.

The 4301-point galaxy spectrum (120–980 nm) and the U (157), B (155), V (173) and R
(409) point filter transmission tables were extracted digit-for-digit from the
ActionScript into `assets/spectrum-data.js`. Nothing was rounded or resampled.

### Parity check against the original

The flux curve was sampled from `Capture.PNG` (a screenshot of the running Flash sim,
whose plot border was located at 1.749× stage scale) and from the ported canvas at the
same 21 wavelengths. Agreement is within 0.003 of full scale at most points and within
0.013 at the three noisiest (450, 850, 940 nm) — i.e. within the ±1 px sampling error of
reading an anti-aliased 1 px line out of a 1.75×-scaled screenshot. Redshift behaviour
was checked independently: at `z = 0.50` the 400 nm break lands at 600 nm and at
`z = 1.00` it lands at 800 nm, as `400 × (1 + z + 0.000684)` requires.

## Assets: reused vs. code-drawn

**This simulation has essentially no reusable exported art.** `images/`, `movies/` and
`morphshapes/` are empty; every visual is generated at runtime by ActionScript drawing
code, so preference #3 (code-drawn geometry → canvas 2D) applies almost throughout:

* spectrum curve, filter fills, plot background and border — `graphics.*` calls;
* the visible-spectrum strip — written pixel-column by pixel-column into a `BitmapData`;
* all text — `TextField`s, now HTML (and MathJax where it is mathematics).

Three exported items were consulted, and the exact values taken from them, but are not
shipped as files because none can be used *as-is*:

| Exported item | Why it is reproduced rather than embedded |
| --- | --- |
| `sprites/DefineSprite_119_FilterStrengthsChart/1.png` | the four bars are scaled **independently** at runtime (`uBar.scaleY` …), so a single composite bitmap cannot be used. The bar fills `#d99ffc`, `#8f7fb9`, `#91d47f`, `#f1b67f` were sampled from this render and are used verbatim in `styles/styles.css`. |
| `shapes/86.svg` (labelled tick) | a 2 px × 6 px black line. Rendered as a CSS border so it tracks the responsive, zoomable plot instead of being a fixed-size image. |
| `shapes/84.svg` (unlabelled tick) | a 1 px × 4 px black line. Same reasoning. |

`assets/spectrum-data.js` is therefore the one genuine exported asset — the numeric
tables, copied out unchanged.

The original's embedded Verdana (`fonts/*.ttf`) is **not** shipped: per the cross-OS
rule the sim uses the foundation's own font stack so text renders consistently on
Windows, macOS, Linux, iOS and Android.

## contents.json

### The entry already existed

`galacticredshift` was already present in the shipped `foundation/contents.json` with
`meta.title = "Galactic Redshift Simulator"`, `version 2.0`, and maintainer-authored
Help and About text. No new entry was added. The single content change made was the one
requested: the paragraph *"Permission is granted to use these files for noncommercial
purposes as long as they remain unmodified."* was replaced with the Apache License 2.0
notice, in the same wording and `<p>`-per-paragraph shape already used by the
`photometrySimulator` entry. The NSF grant paragraph (#0231270 / #0404988) and the
astro.unl.edu website paragraph were left untouched, as instructed.

### ⚠️ Pre-existing JSON syntax errors that had to be repaired

**The `foundation/contents.json` shipped in this simulation folder is not valid JSON.**
Six string literals contain raw control characters or unescaped quotes, so
`JSON.parse` fails and the masthead renders **nothing at all — for every simulation
using this copy**, not just this one. The failure is silent apart from a console
message.

The corruption is only in *this* folder's copy: the same file in the previously
converted sims (`Photometry Simulator`, `Radial Velocity Simulator`,
`Configurations Simulator`, …) is already correct, and the repaired text below is
byte-identical to theirs.

| Line (original) | Key | Defect | Repair |
| --- | --- | --- | --- |
| 200–201 | `celestialhorizon` (Rotating Sky) | raw newline before the closing quote | joined |
| 439–440 | `eclipsingbinarysim` | raw newline mid-sentence (`These data were⏎ provided by`) | joined |
| 916–917 | `meltednail` | raw newline before the closing quote | joined |
| 1155–1156 | `positionsdemonstrator` | raw newline before the closing quote | joined |
| 1207 | `ptolemaic` | unescaped `"` in `<a href="../venusphases">` | escaped as `\"` |
| 1224 | *(pulsar period)* | raw TAB inside the string | replaced with a space |
| 1802 | `venusphases` | unescaped `"` in `<a href="../ptolemaic">` | escaped as `\"` |

**These repairs were applied only to `html5/foundation/contents.json`.** The source
folder's `foundation/` was left untouched. The same fixes should be pushed to the
shared/canonical `contents.json`, otherwise the next conversion started from this folder
will hit the same wall.

Note also that the file contains a duplicate `moonphases` key. That is legal JSON
(the last wins) and browsers accept it, but stricter parsers reject it — worth cleaning
up upstream.

## Deviations from the original

1. **A Help button appears; the Flash version had none.** The original sets
   `titlebar.helpContent = ""`, so only *reset* and *about* were shown. The shipped
   `contents.json` already contains maintainer-written Help text for `galacticredshift`,
   and that text was kept rather than blanked — it matches how every sibling entry in
   the pipeline is set up, and it improves the sim for new users. Blank
   `masthead.help.content` if the Flash behaviour is wanted exactly.
2. **Layout is the KL-UNL shell, not the Flash pixel layout.** The original's single
   bordered card is expressed as four KL-UNL `.panel` sections: the three top-of-screen
   areas (introductory text | the `z` control and its equation | filter text, bar chart
   and the show/hide button) sit side by side in the original's left-to-right order,
   with the spectrum stage full width beneath — matching `Capture.PNG`'s arrangement,
   grouping and reading order. Panel headings ("About Redshift", "Redshift Control",
   "Filters", "Galaxy Spectrum") are additions; the original has no headings, but a
   correct heading hierarchy is required and they make the panels navigable.
3. **The show/hide button no longer slides.** In Flash the button animated between
   x = 617 (120 px wide, "show filter details") and x = 736 (42 px wide, "hide") during
   the ease. In a fluid, zoomable layout absolute positions are meaningless, so the
   button stays put and only its label changes. The 200 ms cubic ease itself is
   preserved, driving the fade of the filter overlay, the bar chart and the U/B/V/R
   labels exactly as before.
4. **The two axis direction arrows are inline SVG.** The original's arrows are
   thick solid arrows; MathJax's are thin typographic ones and cannot be bolded
   (TeX bolding does not affect arrow glyphs, and `\boldsymbol` needs an
   extension that is not in the self-hosted bundle — requesting it rejects
   MathJax's startup promise and kills the whole page typeset). The arrows are
   drawn to match the original's weight, sized in `em` so they scale with the
   type, and filled with `currentColor`. The words *Flux* and *Wavelength* are
   still MathJax-typeset. The Flux arrow is deliberately kept **outside** the
   rotated span: the rotation that makes "Flux" read bottom-to-top turns any
   glyph inside it by 90°, which is what previously rendered an up arrow as a
   left arrow. See `ACCESSIBILITY.md`.
5. **The visible-spectrum strip is centred on the plot, by request.** In the
   original it is offset left — it starts at 21.4286% of the plot width, which
   is exactly where 400 nm falls on the 250–950 nm axis, so every colour sits
   directly above its own wavelength on the graph below. Centring trades that
   correspondence for symmetry: at `z = 0` the green in the strip no longer
   lines up with 550 nm on the axis. The strip still covers 400–700 nm and is
   still 42.8571% of the plot width. One line in `styles/styles.css` restores
   the original alignment — see the comment on `.grs-vis`.
6. **Axis labels, tick labels and the U/B/V/R labels live in HTML, not on the canvas.**
   Required by the MathJax rule (canvas-painted text cannot expose the MathJax menu) and
   by the zoom rule (canvas-baked text does not reflow). They are positioned as
   percentages of the plot width, so they stay locked to the axis at every size — the
   500 nm tick was measured to sit within 0.1 px of its exact position from 320 px up to
   1280 px wide and at 200% text zoom.
7. **At viewports below ~34 rem every other tick *label* is hidden** (300/500/700/900
   remain). All fifteen tick *marks* are always drawn. Seven labels cannot fit across a
   250 px-wide plot without overlapping, and overlapping text is a WCAG failure.
8. **The transition is driven by `setInterval(10)`, not `requestAnimationFrame`.** This
   mirrors the original's `new Timer(10)` and, unlike rAF, keeps ticking when the tab is
   backgrounded or not compositing — so the fade can never be stranded part-way. If a
   tick is delayed past the target time the easer snaps to its end state, exactly as
   `updateFiltersTransition` does in the AS.
9. **`prefers-reduced-motion: reduce` skips the ease** and jumps straight to the end
   state. The underlying state transition is unchanged.
10. Colours were **not** remapped — the filter fills and bar colours are the original
   values. See `ACCESSIBILITY.md` for how colour is prevented from being the sole
   carrier of meaning.

## Cross-browser notes

Standards-only HTML/CSS/JS: canvas 2D, Pointer/native form events, CSS grid and flexbox,
`transform`, `writing-mode`, custom properties. No vendor-prefixed-only declarations and
no Chrome-only APIs. `aspect-ratio` is deliberately avoided — the canvases size
themselves from their intrinsic `width`/`height` attributes with `width:100%; height:auto`,
which works identically on Safari and older WebKit. The masthead's `<dialog>` and
`::backdrop` are foundation code and are supported in all current target browsers
(Safari 15.4+). No known per-browser behavioural differences.

*Verified in this environment against a local HTTP server: no console errors, no network
requests beyond the local files listed in `README.md`.*
