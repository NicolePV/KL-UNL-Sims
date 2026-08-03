# Conversion Notes — Circumstellar Habitable Zone Simulator

## Behaviour model (one paragraph)

The simulator shows a single planet orbiting a single star, drawn top‑down, and
lets you watch the star's **habitable zone** (the ring of distances where liquid
surface water is possible) sweep outward as the star ages and brightens. You pick
a star **mass** (0.3–30 M☉, the 17 stellar‑evolution tracks in the data file) or a
real **star system** (which fixes the mass and offers its planets' distances), and
a planet **distance**. A **timeline** scrubs "time since star system formation";
at each time the star's mass, luminosity, radius and temperature are interpolated
from its evolution track, the habitable zone is recomputed (inner =
`0.95·√L`, outer = `1.37·√L` for the pessimistic assumption), the planet's
distance is scaled by the star's mass loss, and the planet is classified **too
hot / just right / too cold / tidally locked / destroyed**. Three strips under the
timeline summarise the planet's temperature vs. the zone, and the system history
(when hydrogen fusion ends, when the star dies, when the planet is tidally locked
or destroyed). An H‑R diagram plots the star's evolutionary track with a "now"
marker, and the main diagram auto‑zooms (and can be manually zoomed) so the planet
stays visible.

## Ground truth for behaviour

All physics constants, tables, formulas and on‑screen text are copied **verbatim**
from the decompiled ActionScript (`scripts/…`), principally
`stellarHabitableZone004_fla/MainTimeline.as` plus the `SHZ*` display classes and
`ProtoSliderLogic.as`. Verified against `Capture.PNG`: the default Sun at t = 0
reads mass 1.00 M☉, luminosity 0.739 L☉, temperature 5700 K, radius 0.890 R☉,
planet distance 1.00 AU — reproduced exactly.

## The stellar data (`shzStars.dat` → `assets/shzStars.json`)

`shzStars.dat` is a zlib‑compressed AMF3 `ByteArray` (the AS does
`loader.data.uncompress(); readObject()`). It decodes to an array of **17 stars**,
each `{ mass, timespan, epochsList:[{time,type}…], rawDataTable }`, where
`rawDataTable` is a nested `ByteArray` of big‑endian `float32` rows of
`[time, mass, logLum, logRadius, logTemp]` (20 bytes/row), exactly as
`doneLoadingData()` reads them. Browsers can't `readObject()` AMF, so the file was
decoded once (zlib‑inflate + a hand‑written AMF3 reader) to `assets/shzStars.json`,
preserving each float's exact round‑tripped value. `simulation.js` rebuilds each
star's `dataTable` from the flat rows at load, identical to the AS. Masses:
0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.5, 2, 2.5, 4, 8, 15, 30 M☉.

## AS → HTML5 mapping

| ActionScript | HTML5 |
|---|---|
| `MainTimeline` controller | the IIFE in `simulation.js`: one `state` object + one `update()`/`render()` |
| `getData`, `getSHZTemp`, `completeDataTable1/2`, `findTimeOfHabitabilityCrossing`, `getNumberString`, Roche & tidal‑lock formulas | ported line‑for‑line |
| `SHZDiagram` + `SHZDiagramStar/Zone/RefOrbits/Grid/Scalebar` (code‑drawn) | `drawDiagram()` on `<canvas>` in original 966×250 stage coords |
| `SHZDiagramPlanet` (embedded movie clip, 5 state frames) | reused frame PNGs drawn with `drawImage` (see below) |
| `SHZHRDiagram` (embedded bitmap + curves) | `drawHR()`: reused `hr-background.jpg` + code‑drawn curves |
| `SHZHabitabilityPlot`, `SHZSystemHistory(+Tag)` | `drawPlot()`, `drawHistory()` + HTML tag overlays |
| `SHZTimeline(+Cursor)` | `<canvas>` ticks + MathJax labels + a focusable cursor handle |
| `ProtoSimpleSlider` / `ProtoSliderLogic` (log scaling, sig‑digit format, finite‑set snap, editable field) | native `<input type=range>` (index for finite sets, log‑param for continuous) + editable text field |
| `ComboBox`, `CheckBox`, `RadioButton`, `Button` (Flash components) | native `<select>`, `<input type=checkbox/radio>`, `<button>` |
| `NAAPTitleBar` (title + reset/about) | the shared `<kl-unl-masthead>`; Reset is the `sim-reset` event |
| `onEnterFrame` + `getTimer()` | one `requestAnimationFrame` loop + `performance.now()`, same ms constants |

## Reused exported assets vs. code‑drawn

- **Reused as‑is** (copied to `assets/`, never redrawn): the planet's five state
  frames plus its blank default (`sprites/DefineSprite_38_SHZDiagramPlanet/1–6.png`
  → `planet-*.png`), the H‑R density map (`images/43.jpg` →
  `hr-background.jpg`), and the habitable‑zone indicator arrow
  (`sprites/DefineSprite_54_SHZDiagramZoneArrow/1.png` → `zone-arrow.png`). Frame→label order was read from the `FrameLabel` tags in
  `_assets/assets.swf` and cross‑checked visually: 1 = default, 2 = destroyed,
  3 = tidally locked, 4 = too hot, 5 = just right (Earth), 6 = too cold.
- **Code‑drawn** (built at runtime by the AS, so reproduced on canvas): the star
  disc/halo (temperature‑coloured), the habitable‑zone annulus, the reference‑orbit
  ellipses and their curved labels, the scale grid, the AU scale bar, the timeline
  tick marks, the H‑R curves, the habitability curve/shading, and the history bar.
- The three embedded Verdana subsets (`fonts/*.ttf`) are included for reference,
  but the UI uses a standard sans‑serif stack for cross‑OS consistency (the subsets
  contain only selected glyphs and are unsafe as a primary UI font).

## The `contents.json` entry (shared‑file model)

`foundation/contents.json` is the **single shared** KL‑UNL file (many sims). Per
the pipeline it is copied whole into `html5/foundation/` and this sim's entry
(`sim-id: stellarHabitableZone`, which already existed) is the only content
adjusted. Two changes were made **to the copy only**:

1. **Required licence swap** — in this sim's About, the line *"Permission is
   granted to use these files…"* was replaced with the Apache 2.0 text, keeping the
   NAAP link and the "Nebraska Space Grant" funding line. The final entry:

   ```json
   "stellarHabitableZone": {
     "meta": { "title": "Circumstellar Habitable Zone Simulator", "version": "2.0" },
     "masthead": {
       "help": { "title": "Help and Instructions",
         "content": "<p>This simulator demonstrates the location and evolution of the stellar habitable zone, the region around a star where surface water may exist on an earth-like planet.</p>" },
       "about": { "title": "About this Simulator",
         "content": "<p>This simulator is part of the Habitable Zones Lab of the <a href=\"https://astro.unl.edu/naap/\">Nebraska Astronomy Applet Project. Supporting materials and additional astronomy education resources can be found there.</p><p>This simulator has been modernized by the AAS Applet Task Force to meet modern web accessibility standards (WCAG 2.1 AA).</p><p>Initial funding for this work was provided by the Nebraska Space Grant.</p><p>Copyright 2026 The Board of Regents of the University of Nebraska</p><p>Licensed under the Apache License, Version 2.0 (the &quot;License&quot;); you may not use this file except in compliance with the License. You may obtain a copy of the License at <a href=\"http://www.apache.org/licenses/LICENSE-2.0\">http://www.apache.org/licenses/LICENSE-2.0</a></p><p>Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.</p>" }
     }
   }
   ```

   If your deployment keeps `contents.json` as one canonical shared file rather
   than a per‑sim copy, apply just the About‑paragraph swap above to that file.

2. **Pre‑existing invalid‑JSON fixes (necessary)** — the shared copy shipped in
   this sim's folder was an **older, malformed** version that the browser's strict
   `JSON.parse` rejects (so the masthead could not load *any* sim). Two unescaped
   `"` inside string values (the `ptolemaic`/`venusphases` `href`s) were escaped,
   and five raw control characters (newlines/CR/tab) inside string values (in the
   `ce_hc`, `celhorcomp`, `eclipsingbinarysim` entries) were escaped to `\n`/`\r`/
   `\t`. Only JSON‑validity was fixed; no textual content changed. (A newer,
   already‑valid copy of the shared file exists elsewhere in the pipeline; using
   that verbatim is equally fine.)

## Deviations from the original (accessibility / template win over pixel/behaviour)

- **Units as math notation.** Readouts show properly typeset units (M☉, L☉, R☉,
  K, AU via MathJax) rather than the Flash ASCII "Msun/Lsun/Rsun". Numbers are
  verbatim; screen readers hear the full words ("solar masses", etc.). The math
  is set with `\text{…}` + `mtextInheritFont`, so it renders in the page's own
  sans‑serif font (identical to the rest of the UI, not a serif math font), and
  the pre‑typeset plain‑text fallback is the same symbol form so nothing visibly
  changes while a slider is dragged.
- **Habitable‑zone assumption control omitted.** The Flash file instantiated
  optimistic/pessimistic radio buttons but left the optimistic one permanently
  disabled, so it always used the pessimistic limits, and the control is not part
  of the original visible layout. It is therefore omitted here; the zone limits
  are fixed to pessimistic (inner 0.95·√L, outer 1.37·√L), matching the original's
  actual behaviour.
- **Help button now shown.** The Flash titlebar set `helpContent = ""` (no Help).
  The curated KL‑UNL `contents.json` supplies a one‑line Help description, so a
  Help button appears — an accessibility gain, kept as the foundation defines it.
- **Mass‑slider thumb spacing.** The mass slider snaps to the same 17 discrete
  track masses as the AS (identical values, identical arrow‑key stepping), but the
  thumb is positioned by index (even spacing) rather than the AS's log position.
- **Manual zoom feel.** Drag‑to‑zoom on the diagram reproduces the AS zoom factor
  (1.3) and re‑centres on release; the exact dead‑zone acceleration curve is
  approximated, and the gesture also has a keyboard path (it is a focusable
  slider), which the Flash version lacked.
- **Zoom easing** uses a smoothstep on `log(scale)` instead of the AS cubic‑spline
  easer (visual only), and is made instant under `prefers-reduced-motion`.
- **Star blur.** The AS `BlurFilter` on the star disc is approximated by the soft
  radial‑gradient edge (canvas `ctx.filter` blur is unreliable on Safari/WebKit).
- **Star colour green channel** is clamped to 0–255 (the AS left the green
  polynomial unclamped; clamping only affects out‑of‑range extremes and avoids
  wrap‑around artefacts).
- **Timeline interaction.** The cursor is a full scrubber (pointer sets time
  continuously anywhere on the strip); the AS's click‑to‑step‑and‑repeat is
  replaced by continuous scrubbing, while the arrow keys keep the AS data‑point
  snapping. Selecting/deselecting a star system resets the timeline to t = 0
  (the AS resets on select; here also on deselect — a harmless consistency).
- **Diagram text labels** ("Habitable Zone", orbit names, "too hot/too cold",
  history tags) are HTML overlays or canvas text that scale with the canvas; they
  are also included in the screen‑reader description of each panel.
- **Habitable‑zone indicator arrow** is ported from `SHZDiagramZone.update()`
  with the same thresholds: it appears pointing right when the zone's inner edge
  lies past the right edge of the diagram (`inner·scale > width − starX − 7`), and
  rotated back toward the star when the whole zone is smaller than 22 px
  (`outer·scale < 22`). It reuses the exported arrow art and is placed relative to
  the "Habitable Zone" label exactly as the AS does. The label is now clamped to
  the right edge (as the AS does) rather than hidden. Both arrow states are also
  described in the diagram's screen‑reader text.

Nothing in the underlying physics/logic was changed; only presentation adapts.
