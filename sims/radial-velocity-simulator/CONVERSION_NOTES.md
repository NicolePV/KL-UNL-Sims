# Conversion Notes — Radial Velocity Simulator

## Behavior model

This simulator models a star and a planet (or two stars) orbiting their common
center of mass, and the radial-velocity ("Doppler wobble") technique used to
detect the unseen companion. Six physical parameters — star mass, planet mass,
orbital separation (semimajor axis), eccentricity, inclination, and longitude
of periastron — plus an orbital phase drive two synchronized views: a
rotatable 3D "free space" visualization of the orbiting bodies and their
orbital plane (optionally split into fixed side/earth/orbit sub-views), and a
plot of the star's line-of-sight radial velocity vs. orbital phase, computed
by solving Kepler's equation and rendered as a Keplerian RV curve with an
optional draggable "current phase" cursor and optional simulated noisy
measurement points. Star mass also drives a fitted main-sequence
luminosity → temperature → radius → spectral-type readout. An animation loop
advances the orbital phase at a user-set rate; sliders control simulated
measurement noise and count; seven named presets (two of them real exoplanet
systems) can be applied via a dropdown + Set button. Reset restores the exact
documented initial state (star mass 1 M_sun, planet mass 1 M_jup, separation
1 AU, eccentricity 0.2, inclination 90°, longitude 45°, phase 0, orientation
theta=80°/phi=45°, noise 15 m/s, 150 measurements, animation stopped).

## Source → HTML5 mapping

| AS source | HTML5 equivalent |
|---|---|
| `Radial Velocity Component.as` | `renderRVPlot()` in simulation.js — canvas plot + Kepler-solved curve + measurement scatter, native slider-driven noise/count, draggable phase cursor as a `role="slider"` proxy |
| `Binary System Component.as` | `renderBinarySystem()` — front/back half compositing (star & planet discs, orbital paths, orbital plane grid, direction line), replicated 1:1 (rotation matrix `doA`, mask ellipse math, grid spacing algorithm) |
| `Visualization.as` | `renderVisualization()` — wires 3 (or 1) Binary System Component instances + a simplified celestial-sphere-lite rotation for the free-space view and its direction arrows |
| `CelestialSphere.as` + `2..7 CS *.as` | `sphereLite` helper (theta/phi rotation, horizon-system point projection, absolute-orientation arrow math) — **only the subset this sim actually exercises**. See "Omitted subsystems" below. |
| `8/9/10/11 CS *.as` (circles, lines, declination trails, shaded bands) | **Not ported** — see below |
| `Slider Logic Class v6.as` / `Standard Slider v6.as` | `makeSlider()` — native `<input type="range">` whose displayed/announced value goes through the same linear/logarithmic parameter↔value mapping and significant-digits/fixed-digits formatting as the original |
| `Number Functions.as` | `getLuminosityFromMass`, `getTempFromLuminosity`, `getRadiusFromTempAndLuminosity`, `getSpectralTypeFromTemp`, `toFixed`/`toSigDigits` — ported verbatim (same polynomial coefficients, same spectral-type tables) |
| `DefineSprite_244` frame scripts (main controller) | top-level wiring in simulation.js (`onXxxChanged` handlers, `presetsList`, `onResetClicked`) — ported verbatim including all constants |
| `Title Bar.as`, `Dialog Window v2.as`, FPushButton/FCheckBox/FComboBox/FScrollBar/FLabel | replaced by `<kl-unl-masthead>` + native `<button>`/`<input type=checkbox>`/`<select>` per hard rule 3 |

### Omitted subsystems (justified)

`Visualization.as` never calls `addCircle`, `addLine`, `addDeclinationTrail`,
or `addShadedBand` on its `CelestialSphere` instance, `showUnder` is left at
its default `true` (nothing is ever culled), and the one shading clip
(`celestialBowl`) is immediately removed while the horizon plane is hidden
(`showHorizonPlane = false`). Consequently the generic mask/clip system
(`createMasks`/`updateMasks`), the horizon-plane/shading renderers, and the
circles/lines/declination-trails/shaded-bands subsystems (source files `6`,
`8`, `9`, `10`, `11 CS *.as`) produce **no visible output** in this specific
simulation — they exist in the shared `CelestialSphere` component for reuse by
other sims in the collection. Porting them faithfully would be substantial
unused code, so this conversion implements only what's exercised: theta/phi
rotation (`doA`), horizon-system point projection (`WtoSz`), and the
"absolute" orientation-type math used by the direction-arrow objects
(`7 CS Objects.as`, kept in full).

### Discovered discrepancy: `amplitudeField`

`displayPlotInfo()` in the AS source sets both `amplitudeField.text` and
`periodField.text`, but the reference screenshot (`Capture.PNG`) and the
placeholder wireframe (`frames/1.png`) show only a "system period: NNN days"
readout — no visible amplitude label/field anywhere in the layout. The
amplitude value is still computed (`radialVelocityPlotMC.amplitude`) and is
exposed through the plot's screen-reader description (aria-live region) for
completeness, but no visible "amplitude" UI element was added, to match the
screenshot exactly. Flagging in case this was an intentional but incomplete
readout in the original.

## Assets reused as-is

- `shapes/134.svg` → `html5/assets/direction-arrow.svg` — the downward
  chevron/pennant shape used by both "Direction Arrow" and "Direction Arrow 2"
  symbols (confirmed by matching fill color `#8adb59` and point geometry
  against the rendered sprite previews; both symbols recolor it at runtime via
  `Color.setRGB`, so only the silhouette matters).
- All other visuals (star/planet discs, orbital ellipses, orbital-plane grid,
  RV curve, plot axes, sliders, panel chrome) are genuinely code-drawn in the
  AS source (`drawCircle`, `curveTo`, gradient fills) and are reproduced with
  canvas 2D drawing calls using the same coordinates/formulas, per the asset
  preference order.

## contents.json

The linked `foundation/contents.json` is the **shared** file for the whole
KL-UNL simulation collection (confirmed: it already contains complete,
correct entries for this project's sibling sims — `ptolemaic`,
`pulsarPeriodSim001`, `parallaxExplorer`, `transitsimulator`,
`milkyWayHabitability` — each matching an already-converted sibling folder on
disk). It also **already contains a complete, correct entry for this sim**,
keyed `radialvelocitysimulator`, with `meta.title = "Radial Velocity
Simulator"` and verbatim-derived help/about text matching `texts/11.txt` and
the standard NAAP/Extrasolar-Planets-Module boilerplate. No edit was needed —
the file was copied into `html5/foundation/contents.json` unchanged, and
`index.html` references `sim-id="radialvelocitysimulator"`.

Note: `meta.title` ("Radial Velocity Simulator") is used for the masthead
title bar rather than the AS-hardcoded `Title Bar` text ("Exoplanet Radial
Velocity Simulator"), matching the established sibling-sim convention of
deferring to `contents.json`.

## Deviations log

- **Fixed after visual review round 12:**
  - **Simulated measurements re-sampled on every redraw.** The Gaussian error
    was rolled inside the render loop (`gaussianPair()` per point per render),
    so every animation frame, phase-cursor drag, axis pan, or visibility
    toggle produced a brand-new scatter — the dots visibly jittered while the
    animation ran. Each cached point now stores its own standard-normal
    deviate alongside its orbital position, and the renderer just scales that
    stored deviate by `activeNoise()`. The dataset is now STATIC: verified
    byte-identical scatter after 8 intervening re-renders at other phases and
    after toggling the checkbox off/on. Points are only (re)generated when the
    eccentricity changes (new sampled phases, as `doKeplersEquation` does) or
    when more are needed; moving the noise slider now smoothly rescales the
    same pattern instead of reshuffling it. This intentionally goes further
    than the AS source, which re-rolls the errors on every `update()` — a
    stable dataset is what was asked for and is truer to "these are your
    observations".
  - **Slider arrow keys were far too slow.** The range inputs carry a
    NORMALIZED 0..1 parameter with `step="0.001"`, so one arrow press moved
    0.1% of the range (~1000 presses end to end). Added explicit key handling:
    1% per arrow, 10% per PageUp/PageDown, Home/End to the ends, with a nudge
    loop so significant/fixed-digit rounding can never swallow a press.
    `step` stays fine so dragging remains precise. Measured single-press
    deltas: noise 15->16, number 150->155, animation speed 0.00050->0.00051,
    star mass 1.00->1.02, planet mass 1.00->1.12, inclination 90.0->91.8,
    longitude 45.0->48.6, eccentricity 0.20->0.21, phase 0.000->0.010.
- **Fixed after visual review round 11:**
  - **X-axis ticks/numbers moved to the BOTTOM** (they were at the top,
    overlapping the plot's top edge). This actually matches the AS source
    (`xTickmarksMC._y = plotHeight`); round 10 had wrongly placed them above
    the top border. The bottom margin was enlarged (OB 8 -> 30) and the top
    margin shrunk (OY 20 -> 12, now only needs room for the topmost y-label);
    the x-ticks now extend down from the bottom border with numbers below,
    clearing the HTML "Phase" title. Verified: x-axis ink is entirely below
    the plot band, none above.
  - **Axis tick font enlarged** 13px -> 15px (both x and y numbers) — the
    labels read as too small.
- **Fixed after visual review round 10:**
  - **X and Y axis tick marks + numbers were missing (y entirely, off-canvas).**
    The plot was drawn filling the whole canvas, so the y-axis numbers (drawn
    at negative x) and the x-axis numbers were clipped by the canvas edge.
    Introduced a margin system: the plot canvas backing is enlarged
    (OX=46 left, OY=20 top, OR=16 right, OB=8 bottom) and the plot rectangle
    is inset within it (renderer `translate(OX,OY)`s; all curve/cursor/
    measurement/pointer math stays in [0,PW]x[0,PH] plot coordinates, with the
    three pointer mappings — background pan/crosshair, phase-cursor drag, and
    the cursor proxy CSS position — subtracting/adding the margin). The x-axis
    ticks+numbers now sit just above the top border, the y-axis ticks+numbers
    just left of the left border. Verified: ink present in both margins, all
    labels within the plot band, curve/measurements never drawn outside it,
    and the phase cursor + crosshair still map correctly.
  - **Y-axis was over-zoomed (curve looked too small) when measurements were
    off.** The vertical-scale margin uses `margin * noise`; with measurements
    hidden the AS source uses `noMeasurementsNoise` (0.1), but this port was
    using the noise slider's value (15) after reset, blowing the y-range out
    to ~±60 instead of ~±30 and shrinking the curve. Added `activeNoise()`
    (= slider value when measurements shown, else 0.1) and used it for both
    the vertical-scale margin and the measurement scatter; `state.noise` now
    always holds the slider value. The curve now fills the plot as in the
    original.
  - **Row labels aligned at the colon.** `.rvs-align` row labels are now
    right-aligned, so every trailing ":" lines up in a column just before the
    value boxes (verified: label right-edges identical within each panel).
- **Fixed after visual review round 9 (small layout polish):**
  - **Phase value box now sits next to "phase:".** In Animation Controls
    the subgrid alignment sized the shared label column to the widest label
    ("animation speed:"), pushing the phase box far to the right. The
    no-value row's label ("animation speed:") now spans the label + value-box
    columns, so it no longer widens the label column; the phase box sits ~6px
    after "phase:" while the two sliders still align.
  - **Plot-controls (checkboxes / noise / number) no longer hug the left
    border.** They inherited the tight 0.6rem fieldset padding used to give
    the narrow bottom panels more slider room; the wide plot panel doesn't
    need that, so its fieldset padding-left is now 1.5rem (indent ~24px). The
    `.rvs-plot-controls.control-fieldset` selector raises specificity to beat
    the general `.rvs-panel .control-fieldset` padding rule.
- **Fixed after visual review round 8:**
  - **Curve/measurements ran out of the plot box for eccentric orbits.**
    The full line-of-sight velocity is `K*cos(w+ta) + K*e*cos(w)`; the AS
    source draws only the first term but in a frame whose vertical centre
    reads `centerVelocity = K*e*cos(w)`, so the drawn curve is physically
    the actual velocity and always fits. This port maps the curve in the
    actual-velocity frame (the `yAxisMin/yAxisMax` frame the axis labels and
    hover crosshair use) but was plotting only `K*cos(w+ta)` — omitting the
    `centerVelocity` offset. For low eccentricity the offset is tiny and it
    looked fine, but at high `e` with `w` near 0/180 the offset approaches
    `0.8*K` and pushed the curve (and the simulated-measurement dots) out the
    bottom/top of the box. Fixed by adding `centerVelocity` in
    `radialVelocityAtPhase()` and the measurement velocity. Verified at the
    extreme (e=0.8, w=0): curve y-extent 80..306 of 380px, zero pixels on
    the top/bottom edges; measurements likewise 0 clipped.
  - **"system period: N days" blanked out while dragging.** `setMath()` was
    writing raw `\(...\)` LaTeX into the readout on every drag tick and
    typesetting on a 120ms throttle, so a fast drag left the node showing
    raw LaTeX or, when a new value arrived mid-typeset, briefly empty.
    Rewrote the MathJax helper to (a) show the readable plain-text fallback
    immediately — which looks the same as the typeset output thanks to
    `mtextInheritFont` — (b) DEBOUNCE the actual typeset so a burst of drag
    updates coalesces into one typeset when the drag pauses, (c) guard
    against overlapping `typesetPromise` calls with a busy flag and re-flush
    if new work arrived, and (d) skip nodes already rendered to the same
    value (`data-rendered`). Verified over a simulated 40-tick rapid drag:
    the readout is always a readable "N days", never raw LaTeX, never empty,
    and settles to real MathJax (`<mjx-container>`) once the drag stops.
- **Fixed after visual review round 7:**
  - **Arrow digits rendered upside-down.** Drawing the digit inside the
    arrow's full transform chain (previous round) meant the negative
    foreshortening scale (`yscale < 0`) and rotations mirrored/flipped the
    text at many orientations. Now the digit's anchor point (the arrow's
    local centre) is mapped through the same chain mathematically
    (`arrowLocalToStage()`), but the text itself is rendered upright and
    unmirrored at that point — anchored ON the arrow, always readable.
    This deliberately deviates from the original's baked-into-the-art
    digit (which also appears flipped in the original at such
    orientations) in favor of readability (WCAG 1.4.4).
  - **Crosshair velocity readout box collapsed to a strike-through line.**
    `.rvs-plot-stage` sets `line-height: 0` (the standard fix for phantom
    whitespace under a canvas); the absolutely-positioned readout `<div>`
    inside it inherited that, collapsing its line box to ~0 height so its
    top/bottom borders drew through the middle of the (overflowing) text.
    Fixed with an explicit `line-height: 1.3` on the readout. Verified:
    box now measures ~69x24px around its text.
  - **Same-column panel gaps restored.** The flush stacking from round 2
    is superseded per user request: `.rvs-col` now uses the same 0.6rem
    gap as the row/column gaps everywhere else. Verified all three column
    gaps and the top-row gap measure identically (10px at default zoom).
  - **Horizontal overflow at mid viewport widths.** With the slider bars'
    new `min-width: 5rem`, three bottom columns no longer fit between
    ~992-1184px and forced a page scrollbar. The 3-to-2 column collapse
    breakpoint moved from 62rem to 74rem (the top row still stacks at
    62rem); verified no horizontal scroll at 1000px and at full desktop
    width, with the square/aligned top panels unaffected.
- **Fixed after visual review round 6:**
  - **RV curve only covered 3/4 of the plot; phase-0 cursor invisible.**
    Root cause for both: the AS `setPhaseOffset` setter normalizes into
    [0,1) (`(arg % 1 + 1) % 1`), so `initPhaseOffset: -0.25` is stored as
    **0.75** — but this port kept the raw -0.25. The two wrapped curve
    copies (drawn at `plotAreaX` and `plotAreaX - plotWidth`) then covered
    [-1.25·PW, 0.75·PW] instead of [-0.25·PW, 1.75·PW], leaving the right
    quarter of the plot empty; and the phase-0 cursor computed to
    x = -0.25·PW, off-canvas. Fixed by storing the normalized 0.75
    (init/reset), normalizing on background-pan, and wrapping the drawn
    cursor line + its keyboard/pointer proxy with the same modulo (the
    original equivalently draws the cursor at 0 AND at -plotWidth inside
    the wrapping plotAreaMC). Verified by pixel-scan: curve present in the
    leftmost, middle, and rightmost plot columns; red cursor at exactly
    0.75 of the width (under the "0.0" tick, as in the original) and
    nowhere else.
  - **Arrow numbers were floating next to the arrows.** Now drawn inside
    the arrow's own transform (translate → shell rotation → foreshorten →
    instance rotation), so the digit sits on the arrow art and rotates/
    skews with it, exactly like the original symbol's baked-in number.
  - **Multi-view arrows slightly enlarged** (iconScale 1.15 vs the
    original's 1.0) — at 50% quadrant scale they were hard to make out; a
    small deliberate readability concession. Note the side/orbit arrows
    genuinely appear near-edge-on at the reset orientation (θ=80°) — the
    foreshortening math (`yscale = n·rot/r`) is a faithful port of
    CSObjects.update's "absolute" case, and the original shows the same
    thing at that orientation.
  - **Sub-view star/planet were nearly invisible (temperature-tinted
    near-white on white).** Visualization.as assigns FIXED colors this
    port had missed: sub-views `color1 = 16769136` (#FFE070 yellow star)
    and `color2 = 9474192` (#909090 gray planet); free-space
    `color2 = 10526880` (#A0A0A0) with only its star temperature-driven.
    Now honored via explicit color overrides that win over the
    temperature-derived color.
- **Fixed after visual review round 5 — multi-view mode corrected against
  Visualization.as:**
  - **Quadrant layout was wrong.** I had put the free-space view top-left
    and an extra earth view bottom-right. Per the AS source (and the
    reference screenshot): **1 side view** top-left, **2 earth view**
    top-right, **3 orbit view** bottom-left, and the **free-space view**
    bottom-right (`freeSpaceViewWrapperMC._x/_y = 300` at 50% scale in
    `setShowMultiplePanels`). Also added the side-view wrapper rotation
    (`sideViewWrapperMC._rotation = linePhi` from `reconcile()`), which I
    had missed.
  - **Label/arrow colors now verbatim from the AS constants**: side
    2805840 = #2AD050 (green), earth 16757557 = #FFB335 (orange), orbit
    4955113 = **#4B9BE9 (blue)** — my "3" had wrongly been dark green, and
    the others were approximations. The single-view earth arrow is also
    #FFB335 now (was #FFA500) with a white label (matching the original's
    white "earth view" text), and panel-label discs draw their number in
    white like the original "Visualization Panel Label" symbol.
  - **Arrow numbers drawn on the arrows** (white with dark outline), as in
    the original "Direction Arrow" symbol art, instead of colored text
    beside them. The orbit arrow keeps its constructor orientation
    (n = {-1,0,0}, up = zenith) since `reconcile()` only re-orients the
    side/earth arrows — previously all three shared one normal vector.
  - **Sub-view orbits were nearly invisible**: they used a pale
    rgba(180,180,180) instead of the AS `initOrbitalPathsColor` 7368816 =
    #707070; now #707070, clearly visible on the white sub-views.
    Verified by pixel-sampling: green/orange/blue arrow pixels and
    #707070 orbit pixels all present, zero console errors across a full
    slider sweep in both view modes.
- **Fixed after visual review round 4:**
  - **"earth view" direction arrow mis-positioned.** In single-view mode the
    binary system was drawn about the diagram centre (200,200) but the
    "earth view" arrow was drawn at the raw projected coordinates (relative
    to the stage origin 0,0), so it floated at the top-left, detached from
    the diagram. `computeArrowScreen()` returns a position relative to the
    sphere centre, so the arrow draw is now wrapped in `translate(200,200)`
    (the same centre the diagram uses); it now sits at the sphere's edge
    pointing toward earth, matching the original. (The multi-view branch
    already offset its arrows by the sub-view centre, which is why only
    single-view was wrong.)
  - **Sliders too short.** In the narrow bottom-row panels the label +
    value-box columns consumed almost the whole width, leaving ~52px bars.
    Reclaimed width for the slider (the flexible 3rd column) by tightening
    the column gaps (0.6rem->0.4rem), the value/unit gap (0.4->0.3rem), and
    the fieldset horizontal padding (foundation default 1rem -> 0.6rem,
    overridden in styles.css, not by editing the foundation), plus a
    `min-width: 5rem` floor on the bars. Result: e.g. Planet Properties bars
    52px->84px, System Orientation/Star Properties ~145px, plot noise/number
    ~196px. Planet Properties bars stay the shortest because "semimajor
    axis:" is a long label and the value box must stay ~4.5rem wide to fit
    the widest value (planet mass renders as "0.00100" at its minimum); the
    box width can't drop without clipping that value.
- **Fixed after visual review round 3:**
  - **Value boxes aligned into a column per panel.** Each slider row was its
    own independent grid, so within a panel the value boxes sat at different
    x positions (the label widths differ, e.g. "mass:" vs "semimajor axis:"
    vs "eccentricity:"). Fixed by making each control fieldset (and the plot-
    controls' left block) a 3-column grid `[label | value-box | slider]` and
    having each slider row adopt those same tracks via CSS `subgrid`
    (`.rvs-align`), so every value box and every slider lines up in a column
    down the panel. Non-row children (checkboxes, the animation button, the
    star-info paragraph) span all columns; no-value rows (animation speed)
    keep their slider in the 3rd column so it still aligns. Verified: within
    each panel all boxes share one x and all sliders share one x.
  - **Reverted the "fill the panel rectangle" approach in favor of a genuine
    SQUARE left panel + tightened right panel** (per updated user request).
    The left visualization panel is now a true square, and the RIGHT (plot)
    panel is shortened to match it rather than the left being stretched
    rectangular. Mechanism: `.rvs-top` uses near-equal columns and
    `align-items: stretch`; the plot panel is a flex column whose RV plot
    area flexes to fill whatever height remains above its fixed controls; and
    `relayoutTop()` (run on load, resize, and after fonts load) forces both
    top panels to a height exactly equal to the left panel's width — making
    the left a perfect square and the right the same height with bottoms
    aligned. `box-sizing: border-box` on the panels (so the forced height
    includes padding) and removing the viz panel's bottom padding (so the
    black canvas fills the square edge-to-edge, no thin strip) get the square
    exact. Verified: viz panel height − width = 0px, bottoms aligned to 0px,
    canvas backing square, no non-black bottom strip. In the stacked
    (narrow) layout `relayoutTop()` clears the forced heights; the viz stays
    square via a CSS `aspect-ratio: 1` fallback and there's no horizontal
    scroll. Because the plot panel can now be shorter than the plot canvas's
    700×380 backing aspect, the plot may scale slightly non-uniformly; the
    plot's pointer→data mapping was updated to use separate x/y scale factors
    so the hover velocity readout stays correct.
- **Fixed after visual review round 2 (against the reference screenshot):**
  - **MathJax font mismatch.** MathJax's default CHTML output renders even
    plain unit text in its own serif math font, visibly clashing with the
    sim's sans-serif UI. Fixed by wrapping every unit LaTeX string fully in
    `\text{...}` (including the base letter, e.g. `\text{M}_{\text{jup}}`
    instead of `M_{\text{jup}}`) and setting `chtml: { mtextInheritFont:
    true, merrorInheritFont: true }` in the MathJax config, so `\text{}`
    content inherits the surrounding CSS `font-family` — verified the
    rendered `<mjx-container>`'s computed font-family now matches a plain
    label element's exactly.
  - **Missing orbital-plane grid lines.** `drawBinarySystem()`'s
    `showOrbitalPlane` branch only drew the translucent fill quad and
    skipped `updateOrbitalPlane()`'s actual grid-line-drawing algorithm
    entirely (the "nice" 1-2-5 log-spaced gray minor/major grid lines, plus
    green origin lines at x=0/y=0 using `axisGridLineStyle`) — a real,
    visible gap versus the reference screenshot, now ported in full
    (verified: rendered pixels include both the gray grid and green origin
    lines).
  - **Visualization panel white gaps / alignment with the RV plot panel.**
    The plot panel is taller than the visualization once its checkboxes/
    sliders/period readout are counted. First attempt: `align-items:
    stretch` + a JS-sized square canvas — but a square canvas can't fill a
    taller-than-wide panel, so it left black-canvas-with-white-margins
    (dead white bands above and below the square). Final fix (matches the
    original, where the black background fills the whole panel and the
    round diagram sits centered with black margins): the viz canvas now
    fills the entire rectangular panel (backing store sized to the panel's
    pixel size in `resizeVizCanvas()`), the black background is painted
    across the FULL canvas, and the 400x400 stage is drawn centered and
    uniformly scaled inside it (`renderVisualization()` sets a
    translate+scale transform; pointer→stage mapping in `setupVizDrag`'s
    `toInternal()` inverts that same transform so drag rotation still
    matches the AS source at any panel size). No white gaps at any aspect
    ratio, circles stay round (uniform scale, never stretched), and with
    `align-items: stretch` the two panels' bottom edges align to 0px.
    Verified: viz canvas backing is now rectangular (e.g. 462×559) filling
    the panel, near-zero white pixels in single-view mode, drag still
    rotates correctly.
- **Vendored a real MathJax build; fixed two rendering/layout bugs it
  surfaced.** `foundation/mathjax/` was empty (no sibling sim in this
  collection had populated it either), so subscripted units were only ever
  showing their plain-text fallback ("Msun" instead of a typeset M with a
  "sun" subscript). Fetched MathJax v3.2.2's `tex-mml-chtml` bundle + its
  woff-v2 font files once from jsdelivr (with explicit user confirmation
  before keeping it) and vendored them locally — the page makes no CDN
  requests at runtime, verified via the network panel. Also corrected the
  solar-mass unit to render literally as source text ("M" with a "sun"
  subscript, `M_{\text{sun}}`) rather than the astronomical ⊙ symbol I'd
  substituted, since the AS source's literal label is `M<sub>sun</sub>`,
  not the symbol.
  - Fixed a real bug this surfaced: `.rvs-plot-xtitle` ("Phase", below the
    RV plot) inherited `line-height: 0` from the foundation's
    `.panel__canvas-wrap` rule (meant to remove whitespace under bare
    canvases) since `line-height` is an inherited property and this text
    sibling never overrode it — collapsing its box to ~0 height so the
    label rendered overlapping the plot above it. Fixed by restoring a
    normal `line-height` on `.rvs-plot-xtitle` (the y-axis title already
    had this override; the x-axis title was the one missed).
  - Tightened `.rvs-bottom`'s same-column panel stacking (`.rvs-col`) from
    a `0.6rem` gap to flush (`gap: 0`), matching the reference screenshot
    where e.g. "Visualization Controls" and "Animation Controls" sit
    directly against each other with only their `.panel` drop-shadows
    (from `kl-unl.css`, unedited) separating them, not a visible gap.
- **Fixed after initial build: slider value fields are separate from their
  units, and are directly editable.** The first pass rendered each
  slider's value as a single read-only `<output>` combining the number and
  its unit into one MathJax string (e.g. "1.00 Msun") inside a bordered
  box, and dragging the range input was the only way to change it. This
  didn't match the AS source, which has two distinct display objects —
  `valueField` (a plain editable text field showing only the bare number,
  `type="input"`, restricted to numeric characters, committed on Enter or
  on blur) and a separate `unitsTextMC` positioned outside the field. Fixed
  by splitting each slider's readout into `<input type="text"
  class="rvs-value-field">` (editable, commits via the same
  linear/logarithmic value-object rounding as a slider drag — verified:
  typing "0.157" into eccentricity commits and reformats to "0.16" on
  Enter) plus a separate `<span class="rvs-units mjx">` for the
  MathJax-typeset unit, matching the original's visual and functional
  split. Also fixed a related bug this surfaced: the field was guarded
  against being overwritten while focused (to avoid clobbering an in-
  progress edit), which incorrectly also blocked the field's own
  post-commit reformatting and blocked Reset from updating the field if it
  still had focus — removed the guard since the field and its range slider
  can never be focused at the same time, so there's nothing to clobber.
- **Pre-existing JSON syntax bugs in the shared `contents.json`, fixed in
  this sim's local copy only.** Seven unrelated entries in the shared file
  contained invalid raw control characters inside JSON string values —
  literal unescaped newlines inside the help `content` strings of `ce_hc`,
  `eclipsingbinarysim`, `fusion01` ("Melted Nail Demonstration"), and
  `moonhorizon` ("Moon Phases and the Horizon Demonstrator"); a literal
  tab character inside `pulsarPeriodSim001`'s help `content`; and
  unescaped `"` characters around two `<a href="...">` links (in
  `renaissancePtolemaic` and a second Venus-phases demonstrator entry).
  Any single one of these breaks strict `JSON.parse` (as used by browsers
  — Node/PowerShell's more lenient parsers didn't all flag them, which is
  how several were missed on the first pass) for the *entire* file, which
  would otherwise leave every sim's masthead (title/Help/About) broken,
  including this one. Fixed by escaping/removing the offending characters
  with **no wording/content changes** — purely a syntax fix, verified by
  re-fetching and `JSON.parse`-ing the file in-browser until clean.
  **The canonical/production shared `contents.json` should receive the
  same fix** so other sims built from a fresh copy aren't affected.
- Binary System Component's "direction line/arrow" feature (`_showLine` /
  `updateLine`) is never enabled by this sim (`initShowArrow: false` on
  every Binary System Component instance it creates) — omitted from the
  port as dead code for this sim.
- The fine "lens" edge-clipping of each body's icon against the orbital
  plane silhouette (`updateMask`) is simplified to a plain shaded circle;
  the body's position, size, color, and front/back z-order are exact. Noted
  in ACCESSIBILITY.md/here as a minor visual simplification, not a behavior
  change.
- The RV curve is rendered by densely sampling phase (240 points) and
  solving Kepler's equation at each, rather than the AS source's
  bezier-fit-through-fewer-points technique — same physics/formulas,
  different (simpler, equally smooth) rendering technique.
- The "earth view" arrow's label is drawn upright rather than skewed with
  the arrow's 3D foreshortening, for legibility/zoom (WCAG 1.4.4/1.4.10);
  the arrow icon itself still foreshortens/rotates correctly.
- The RV plot's background-drag-to-pan-the-phase-axis gesture is pointer-
  operable (matching the source) but has no dedicated keyboard equivalent
  (it only changes which portion of the wraparound x-axis is visible, not
  any physical parameter — the phase cursor itself, which does carry
  physical meaning, is fully keyboard-operable via its own proxy).
- This session's automated browser tool could not capture screenshots (it
  timed out even on an unrelated external page, confirming an environment
  issue unrelated to this sim) and `requestAnimationFrame` never fired in
  it either (0 callbacks in 500ms on a trivial test loop) — both point to
  the tab's render/compositor loop not being driven in this harness.
  Verification was therefore done via the accessibility tree, page text,
  canvas pixel sampling (`getImageData`), and dispatched DOM events
  (slider drags, keyboard presses, checkbox/button clicks, preset apply,
  reset) rather than visual screenshots — all of which passed, including a
  full sweep of every slider at its min/mid/max plus every checkbox/preset/
  reset combination with zero thrown errors. A manual visual check (actual
  screenshot, 200% zoom reflow, phone-portrait width, and the
  requestAnimationFrame-driven animation) in a normal browser is still
  recommended before sign-off.
- Exact original pixel dimensions for the RV plot's placeholder MovieClip
  were not recoverable from the exported AS/text (they live in the binary
  .fla stage placement, not in code). Chosen internal canvas resolution
  (700x380) matches the screenshot's proportions; all plot geometry is
  computed from `plotWidth`/`plotHeight` variables exactly as in the AS
  source, so the relative layout logic is unaffected by this choice.
