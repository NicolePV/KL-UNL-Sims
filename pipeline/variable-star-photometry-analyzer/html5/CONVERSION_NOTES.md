# Conversion Notes — Variable Star Photometry Analyzer

## Behavior model

The sim presents a simulated CCD star field (400×300 px, 16-bit) containing 26
stars: constant stars, pulsating stars (Fourier-series Cepheid/RR Lyrae
presets), and eclipsing binaries (physical two-disc eclipse model with
Kepler-equation orbits). A settings file (`settings.xml`) defines the field
parameters (noise mean 2300, sigma 330, saturation magnitude 3, Airy PSF
radius 5) and 113 observation epochs, each with a noise seed. On load, the sim
"observes" the field at every epoch: for each star it sums the counts in a
circular aperture (radius = PSF radius + 3) and subtracts the mean background.
The user clicks two stars — first the **comparison star** (blue square halo),
then the **star of interest** (green circle halo); clicking one of the selected
pair swaps the roles, clicking a third star replaces the star of interest. The
Observations Plot then shows the differential magnitude
Δm = −2.5·log₁₀(F_interest/F_comparison) versus time (days) or phase. The PDM
panel computes the Stellingwerf phase dispersion minimization statistic theta
over 12,000 trial periods between 0.2 and 12 days (Nb=5 bins, Nc=2 covers);
minima in theta mark candidate periods. A draggable pointer/cursor (snap:
4 decimals) selects the period used for phase folding and for the period lines
overlaid on the time plot; zoom buttons and a drag-to-zoom window (click the
window to commit, 1000 ms cubic ease animation) explore the PDM plot. A
"difference tool" overlays two draggable horizontal bars on the lightcurve and
reads out their separation in magnitudes.

## Source → HTML5 mapping

| Original (decompiled AS3) | HTML5 port |
| --- | --- |
| `MainTimeline.as` frame1 + handlers | main controller IIFE in `simulation.js` |
| `StarField.as` (noise LCG, chunk shuffle, star stamping, `getStatistics`) | `StarFieldModel` (verbatim math; pixel bytes derived at paint time — see below) |
| `AiryDisc.as` (J1 rational approx, first zero 3.831705970256774) | `AiryDisc` |
| `GammaTransferFunction.as` (γ=1.8 lookup table) | `GammaTransferFunction` |
| `PixelMask.as` | `PixelMask` |
| `Star.as` / `PulsatingStar.as` (PRESETS) / `EclipsingBinary.as` (PRESETS) | same classes, all constants/tables verbatim |
| `Plot.as` (tick algorithm, region-code series clipping, xZoomOnly window, 1000 ms cubic ease zoom) + `PlotSeries.as` | `SimPlot` |
| `StarHalo.as` (square/circle halos, colors 0x3399FF / 0x339900) | halos drawn on the star-field canvas; invisible hit circles replaced by accessible proxy `<button>`s |
| `DeltaMagOverlay.as` (4 px checkered pattern 0x50F0F0F0/0x50C0C0C0, bars 0x909090, label `" X.XX mag "`) | checkered regions on canvas + two `role="slider"` bar handles + HTML label |
| `Coordinates_41` crosshair MC (shape 169) | `assets/shapes/169.svg` reused in an HTML overlay with live x/y values |
| Period pointer triangle (shape 146), off-scale arrows (shapes 153/156) | reused as-is from `assets/shapes/` |
| Embedded Verdana fonts (`fonts/*.ttf`) | copied to `assets/fonts/`; `136_Verdana.ttf` registered as a fallback face |
| Flash `TextInput` restrict `0-9.`/maxChars 8, italic while editing | native `<input>` with the same filtering and an italic editing style |
| `onEnterFrame` incremental data generation (target 40 ms/frame) and PDM calculation (target 30 ms/frame) with adaptive batching | single `requestAnimationFrame` scheduler with the same target-time constants and `performance.now()` |

## Recovered data file

The decompiled export did **not** include `settings.xml` (it is loaded at
runtime beside the SWF, so JPEXS could not export it). It was recovered
byte-for-byte from the original deployment at
`https://astro.unl.edu/naap/vsp/animations/settings.xml` and shipped as
`assets/settings.xml`. Like the original (`loaderInfo.parameters.settingsFile`),
an alternate file can be passed with `?settingsFile=<url>`.

## Verbatim behavior details preserved

- Noise: minimal-standard LCG (s → s·16807 mod 2³¹−1) from seed 1, polar
  Box-Muller; 280 chunks of 430 values; per-observation Fisher-Yates chunk
  shuffle from the observation `noiseSeed`. The imagery and every photometric
  measurement are therefore bit-deterministic and identical to the Flash sim.
- Aperture sum truncates each clamped pixel value to an integer (`uint` cast)
  before accumulating; background subtraction is `totalCounts − nPixels·noiseMean`.
- PDM: `c1=(N−1)/((Σd²−(Σd)²/N)(N·Nc−M))`, `c2=c1·Nc·Σd²`,
  `theta(P)=c2−c1·Σ(binSum²/binCount)` with the exact binning expression
  `floor(Nb·((phase + k/M) % 1 + k))`; 12,000 samples across the x-range at
  calculation time (curve is *not* recomputed on zoom — matching the original).
- Period snapping: rounded to 4 decimals, nudged one step inside the axis
  range; off-scale pointer parked 10 px outside the plot at alpha 0.4 with a
  7 px snap margin during drags; zoom buttons round ranges to 4 decimals and
  respect the minimum x-range 0.065 (= 650·10⁻⁴).
- Number formats: period `toFixed(4)`; loading progress `toFixed(1)+"% done"`;
  difference label `" "+diff.toFixed(2)+" mag "`; axis tick labels via the
  ported `getFormattedNumber`.
- All on-screen text is verbatim from `texts/*.txt` / AS literals.

## contents.json entry

`foundation/contents.json` already contained a `variableStarPhotometryAnalyzer`
entry (title "Variable Star Photometry Analyzer", version 2.0, short Help
text). Per instructions, the About permission sentence was replaced with the
Apache License 2.0 notice (Copyright 2026 The Board of Regents of the
University of Nebraska); the rest of the entry (astro.unl.edu link, AAS
modernization sentence) is unchanged. This entry has no NSF grant sentence to
preserve.

## Deviations from the original (all deliberate)

1. **Foundation `contents.json` JSON repair (required for function).** The
   shipped shared `contents.json` is not valid JSON — `kl-unl-masthead.js`
   does `response.json()`, so the file as shipped breaks the masthead for
   **every** sim. Defects found and fixed (syntax only, no wording changed)
   in the copy at `html5/foundation/contents.json`:
   - unescaped quotes in the `venusphases` and `ptolemaic` entries
     (`href="../ptolemaic"` → `href=\"../ptolemaic\"`, and vice-versa);
   - raw newlines inside string literals in the `ce_hc`, `eclipsingbinarysim`
     and `stellarlum`-area entries (strings ending `…</p>\n"` were joined, and
     "These data were␊ provided" was joined into one line);
   - a raw tab character inside one `content` string (`<p>\tThis simulator…`).
   The upstream shared file should get the same fixes.
2. **Masthead chrome replaces the Flash title bar** (KL-UNL requirement). The
   original had no Reset/Help/About; Reset restores the exact initial
   post-load state (the measured photometry is deterministic, so it is kept).
3. **Layout** uses KL-UNL panels mirroring the original panel structure and
   reading order (Star Field | Observations Plot / PDM full-width below)
   rather than the Flash pixel coordinates. Plot areas keep the original
   internal dimensions (380×260, 650×230) so ticks/zoom limits match.
4. **Axis titles ("magnitude difference", "theta") and overlay text moved from
   canvas/stage text into HTML** so they scale with browser zoom; "theta" is
   typeset through MathJax (`\text{theta}` — wording kept verbatim) with a
   spoken description, and the crosshair `x:`/`y:` labels are MathJax inline
   math per the "every math symbol through MathJax" rule. MathJax's SVG output
   is configured with `mtextInheritFont: true`, so `\text{}` labels render in
   the page's sans-serif face and match the sim's other labels instead of
   MathJax's serif math font (real math variables keep the math font). The
   label stays MathJax-typeset, so its right-click MathJax menu still works.
4a. **Both plots are displayed at the same scale.** They draw tick labels at
   the same internal 12 px and use the same tick lengths, so they only look
   consistent if both canvases are displayed at the same px-per-canvas-unit
   ratio. `matchPlotScales()` in `simulation.js` sizes the lightcurve canvas
   from the PDM canvas's measured width; this is a CSS display size only —
   internal coordinates and all ported math are untouched, and pointer input
   already maps through `getBoundingClientRect`, so parity is unaffected.
5. **Star halos**: the original invisible-hit-area `StarHalo` clips are
   replaced by transparent option elements at the same positions (~22 px hit
   circles vs. the original 16 px), giving keyboard and touch access. The
   field itself is a single tab stop (`role="listbox"` +
   `aria-activedescendant`); arrow keys move the highlight to the nearest star
   in that direction and Enter/Space selects, so keyboard users are not forced
   to Tab through 26 separate stops. Halo outlines are drawn on canvas exactly
   as `drawHalo` did, and the pointer path is unchanged.
6. **Difference-tool bars and the period pointer are HTML sliders** overlaid
   at the original positions so they are keyboard-operable; drag math (offset,
   clamping, snapping) is the verbatim port.
7. **MathJax self-hosted** (`assets/mathjax/tex-svg.js`, MathJax 3.2.2): the
   foundation folder shipped no local MathJax include and runtime CDN use is
   not allowed, so the standard bundle is included locally. No network
   requests leave the host at runtime.
8. **`prefers-reduced-motion`**: the 1000 ms zoom animation is replaced by an
   instantaneous jump to the same end state.
9. **Crosshair readout** is a pointer-hover affordance in the original; it
   remains pointer-only (hidden from screen readers). Star positions are
   available to keyboard/SR users from each star button's accessible name.
10. **PDM zoom-window drag** has no direct keyboard equivalent; keyboard users
    reach every zoom state through the four zoom buttons and the period input
    (the buttons cover in/out/full/undo around any chosen period).

## Per-browser notes

- Canvas text metrics for tick labels may differ by a pixel or two between
  browsers/OSes depending on the available Verdana face; the exported subset
  Verdana is registered as a fallback (`Verdana Embedded`).
- The star-field image is drawn with image smoothing disabled so CCD pixels
  stay crisp when the canvas is scaled; Safari, Chrome, Edge and Firefox all
  honor `imageSmoothingEnabled` on 2D contexts.
