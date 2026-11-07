# Conversion notes &mdash; Eclipse Table

## Behaviour model (one paragraph)

The Eclipse Table is a **static data plot**, not an animated simulation. On load it
reads two hard-coded tables &mdash; `solarEclipses` (68 entries) and `lunarEclipses`
(70 entries), 138 eclipses total, covering 2000&ndash;2029 &mdash; and draws one dot
per eclipse on a 600&times;450 grid whose horizontal axis is the year and whose
vertical axis is the month. Solar eclipses are orange, lunar eclipses grey; the dots
naturally form diagonal bands (the Saros series / "eclipse seasons"). Each dot stores
its own precomputed stage coordinates. In the original, `onRollOver` for an eclipse
icon shows its highlight glow and pops an information panel next to it
(date, eclipse type, Saros number, duration, region of visibility);
`onRollOut`/`onReleaseOutside` hides them. There is **no** animation, timing, drag,
randomness, slider, or physics formula anywhere in the source
(`scripts/DefineSprite_50/frame_1/DoAction.as`,
`scripts/SolarEclipseIcon.as`, `scripts/LunarEclipseIcon.as`).

## Data record format (verbatim from `DoAction.as`)

```
[ x, y, type, month, day, year, saros, magnitude, duration, visibility ]
```

* `x, y` &mdash; original Flash stage coordinates of the dot (reused as-is; the
  canvas keeps these coordinates and is scaled by CSS).
* `type` &mdash; type index. **Solar:** 0 Total, 1 Annular, 2 Hybrid, 3 Partial.
  **Lunar:** 0 Total, 1 Penumbral, 2 Partial. (Both taken verbatim from the `switch`
  statements in `displaySolarEclipseInfo` / `displayLunarEclipseInfo`.)
* `month` 0&ndash;11 into `months[]`, `day`, `year` &mdash; calendar date.
* `saros` &mdash; Saros series number.
* `magnitude` &mdash; present in the source but **the original info panel never
  displays it**, so it is not shown here either (parity). It is retained in the data.
* `duration` &mdash; duration string, exactly as in the source (`"-"` when none,
  `"Non-Central"`, solar `"04m57s"`, lunar `"03h24m (01h18m)"`).
* `visibility` &mdash; region-of-visibility string.

All data arrays, type names, month names, the static panel labels
("Eclipse Type:", "Saros:", "Duration:", "Visibility:") and the credit line
("Eclipse Predictions by Fred Espenak, NASA/GSFC") are **copied verbatim** from the
decompiled source and `texts/*.txt`.

## Flash (AS1) &rarr; HTML5 mapping

| Original (ActionScript) | HTML5 port |
|---|---|
| `attachMovie("SolarEclipseIcon"/"LunarEclipseIcon", ...)` in a `while` loop | one `<button class="et-point">` per eclipse, generated in `buildEclipseButtons()` |
| Icon `_x = data[0]`, `_y = data[1]` (grid coords, y = &minus;450..0) | `toStageX/​toStageY` map to canvas pixels; buttons positioned by % so they scale with the canvas |
| `gotoAndStop(1 + type)` (type frame) | type is shown as text in the info panel & table; all solar dots render identically orange, all lunar grey, matching the screenshot |
| `onRollOver` &rarr; highlight `_visible = true` + `displayEclipseInfo` | `pointerenter` **and** keyboard `focus` &rarr; `showInfo()` (draws the glow on canvas + shows the HTML info panel + announces) |
| `onRollOut` / `onReleaseOutside` &rarr; hide | `pointerleave` (when not focused) / `blur` &rarr; `hideInfo()` |
| `displayEclipseInfo` quadrant placement (`x < 300`, `y < -225`, `&plusmn; margin`, `- _width/_height`) | `positionInfoPanel()` reproduces the same thresholds and flip logic with CSS transforms (verified to keep the panel inside the plot at all four corners) |
| Highlight glows (`shapes/1.svg` green lunar, `shapes/5.svg` blue solar) | reused as-is, drawn on the canvas under the active dot |
| Info panel backgrounds (blue `#eaf2ff` solar, green `#eeffee` lunar) | reproduced as the info-panel tint via CSS variables |
| `trace()`, `FUIComponent`/component framework | dropped (no observable behaviour) |

## Assets: reused as-is vs. code-drawn

**Reused exported art (copied to `assets/`, never redrawn):**

* `shapes/7.svg` &rarr; `dot-solar.svg` (orange radial dot `#ffe9c4`&rarr;`#feb316`)
* `shapes/3.svg` &rarr; `dot-lunar.svg` (grey radial dot `#dadada`&rarr;`#8a8a8a`)
* `shapes/5.svg` &rarr; `glow-solar.svg` (blue rollover halo)
* `shapes/1.svg` &rarr; `glow-lunar.svg` (green rollover halo)
* `shapes/31.svg` &rarr; `grid.svg` (the 600&times;450 grid with the shaded 5-year bands)
* `fonts/11_Verdana.ttf` &rarr; `verdana.ttf` (the sim's text font)
* **ClassAction logo** &rarr; `classaction-logo.png`. There was no standalone export
  for the logo (`images/` is empty and it is baked into the main-stage composite), so
  it was cropped losslessly from the provided screenshot and alpha-keyed. This is the
  one asset not taken from a clean export; noted here for transparency.

**Code-drawn (reproduced on the 2D canvas):** only the compositing of the grid image
and the dots/glows. Axis tick labels (years, months), the logo and the credit line are
placed as real HTML in the overlay (so they zoom crisply and are inspectable) rather
than baked into the canvas.

## The KL-UNL contents entry

This sim's masthead entry already existed in the shared `foundation/contents.json`
under the key **`eclipsetable`** (title "Eclipse Table", version 2.0, with Help and
About text derived from the original). **No new entry was added** &mdash; the existing
one is used as-is.

### Correction applied to `contents.json` (please review)

The shared `contents.json` as shipped in the decompiled folder was **not valid JSON**,
which caused the masthead to fail for *every* sim (`SyntaxError: Bad control character
&hellip;`). `contents.json` is the one foundation file the pipeline permits editing, so
the following **purely mechanical, meaning-preserving** corrections were made so the
file parses (validated with a strict JSON parser afterwards):

* **5 stray control characters inside string values** collapsed to a single space:
  raw line breaks at the end of four `content` strings (`configurationssimulator`,
  `eclipsingbinarysim`, `meltednail`, `radecdemo` regions) and one literal TAB
  (`radialvelocitysimulator` region).
* **4 unescaped double-quotes** escaped (`"` &rarr; `\"`): the `href` attributes in the
  two `<a href="../venusphases">` / `<a href="../ptolemaic">` links inside the
  `ptolemaic` and `venusphases` `content` strings.

Net change: **+4 bytes**; 108 sim entries preserved. **The `eclipsetable` entry was
not touched.** `kl-unl-masthead.js`, `kl-unl.css`, and `kl-unl.js` are byte-for-byte
unchanged. If the shared `contents.json` is maintained elsewhere, apply the same nine
character fixes there (or the masthead will keep failing on the pristine copy).

## Deviations from the original

* **Type is not encoded by dot appearance.** The original has a frame per type but the
  running sim (and the provided screenshot) render all solar dots identically orange
  and all lunar dots identically grey; type is conveyed textually. This matches the
  visual ground truth and never uses colour as the only signal (see ACCESSIBILITY.md).
* **Added an equivalent, non-original "Eclipse list" table and a "Key".** These do not
  change any behaviour or data; they exist purely as accessibility affordances
  (comprehensive screen-reader-readable view + a colour-blind-safe legend).
* **Layout follows the KL-UNL shell**, not the original Flash pixel chrome, per the
  pipeline. The plot itself replicates the screenshot's arrangement closely (year axis
  on top, month axis at left, shaded 5-year bands, logo bottom-left, credit
  bottom-right).
* **No MathJax equations.** The sim contains no mathematical notation &mdash; only
  calendar dates and catalogue numbers (Saros series, years) &mdash; so there is
  nothing for MathJax to typeset. `kl-unl.js` is still loaded for pipeline consistency
  and `klunlInitEqn()` is redefined as a no-op.
