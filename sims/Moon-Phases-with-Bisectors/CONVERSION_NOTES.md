# Conversion Notes — Determining Moon Phases Using Bisectors

## Behavior model (one paragraph)

The simulation shows the Earth–Moon–Sun system in an interactive 3‑D orthographic
scene. The Earth sits at the centre of a circular lunar orbit; the Moon travels
around it at a fixed distance. A **Sun Direction** angle and a **Moon Position**
angle drive the geometry. The user rotates the viewpoint freely (drag, arrow
keys, or the **left/right** and **up/down** sliders) and can jump to an "earth"
(edge‑on) or "overhead" viewpoint with an eased camera slew. Six checkboxes build
up a construction that teaches how bisecting planes determine the lunar phase:
**Step 1** shows Sun‑direction arrows, **Step 2** adds an orange plane bisecting
each globe perpendicular to the Sun line, **Step 3** adds day/night shadows,
**Step 4** draws the Earth–Moon line, **Step 5** adds a blue plane bisecting each
globe along the Earth–Moon line, and **Step 6** shows the resulting Moon‑phase
disc plus its name. When the Moon passes behind the Earth the Earth fades toward
transparent so the far‑side geometry stays visible. The Moon‑phase name and disc
are computed from the difference between the Moon and Sun angles.

## Source → this port

Ground truth for **behavior** is the decompiled ActionScript 3 (JPEXS/FFDec
export of `moonbisector.swf`, project `moonBisectorDemo005`). Ground truth for
**chrome/layout** is the KL‑UNL foundation + accessibility rules. This is an
**AS3** sim (packages, `fl.controls`, a hand‑rolled 3‑D engine), not the AS1
idiom the pipeline prompt describes; the mapping below reflects that.

| ActionScript class | HTML5 port (`simulation.js`) |
| --- | --- |
| `Scene3D` | projection matrix `t0..t8` / inverse `it0..it8`, `setViewer`, `screenOf`/`worldOf`; orthographic, painter's‑algorithm depth sort on `screenZ` |
| `Globe` / `Globe3D` | `Globe` class — base disc, coastline/maria layers clipped to the disc with limb‑following arcs (`updateLayers`), scalloped day/night terminator (`updateShading`); `earthBack` renders the far hemisphere for see‑through |
| `BisectingPlanesForGlobe3D` / `BisectingPlaneFragment` | `BisectingPlanes` — 12 depth‑sorted plane wedges per globe (`positionPlane`, `drawSector`, `getArcPoints`) |
| `OrbitalPlane` / `MBDOrbitalPlane` / `PlaneRotator` | `OrbitalPlane` — flat plane rotated by viewer angles, split into 3 depth‑masked horizontal bands; reuses `assets/orbit.svg` and `assets/sun-arrow.svg` |
| `PhaseDisc` | `PhaseDisc` — Step 6 lit/dark disc via the same scallop technique |
| `CubicEaser` | `CubicEaser` — camera‑slew easing (cubic spline), ported verbatim |
| `ProtoSimpleSlider` / `ProtoCyclicSimpleSlider` / `ProtoSliderLogic` | native `<input type="range">` with accessible labels + `aria-valuetext` (see Deviations) |
| `NAAPTitleBar` (title + Reset/Help/About) | `<kl-unl-masthead>` component (`sim-reset` event wired to `resetSim`) |
| `MainTimeline` frame script | top‑level state object + `render()` + control wiring |

Verbatim constants/logic reproduced include: scene scale 100; scene size
600×600; Earth radius 0.4, Moon radius 0.2, Moon distance 2.2; obliquity
`cos = 0.91706`, `sin = 0.39875`; the full projection/`b`/`p`/`r`/`q`/`k`
matrices; the transparency envelope (`minEarthAlpha 0.08 … maxEarthAlpha 1`,
plane alpha `0.05…0.5`, line alpha `0.15…0.8`); slew duration 900 ms; contrast
range 0.5–0.85 (default 0.65); and the phase‑name thresholds in
`getPhaseNameFromAngle` (New Moon ≤12°, First/Third Quarter ±5°, Full/New ±12°).
Phase angle: `discPhaseAngle = π − (moonAngle − sunAngle)·π/180`.

## Reused exported assets vs. code‑drawn

* **Reused as files** (copied to `assets/`, drawn with `drawImage`):
  `orbit.svg` (Flash shape 25 — the orbit ring with its direction arrowhead) and
  `sun-arrow.svg` (Flash shape 27 — the labelled "sun" direction arrow). Their
  SVG internal‑origin offsets (`translate(220.5,220.5)` and `translate(23.6,0.5)`)
  are applied so they sit exactly where the original placed them.
* **Extracted data tables** (reused, not redrawn): `earth-shore.json` (22
  coastline polylines / 330 points, from `Globe.as` `_shoreData`) and
  `moon-layers.json` (2 maria layers, from `MainTimeline.as` `moonLayersData`).
* **Code‑drawn geometry** (redrawn on `<canvas>` because the AS builds it at
  runtime, no exported file exists): the globes' base discs, the projected
  coastline/maria fills, the terminator shading, all bisecting‑plane wedges, the
  Earth–Moon line, and the phase disc.

## The `contents.json` entry

`foundation/contents.json` is a **shared** foundation file that **already
contains** the `"moonbisector"` entry (meta title/version + masthead Help/About
derived from the original NAAP boilerplate). No edit was required; the foundation
folder is copied byte‑for‑byte. The entry's title is
"Determining Moon Phases Using Bisectors" and it supplies Help text (so the Help
button appears — note the original Flash `helpContent` was empty, but the
modernized shared JSON provides Help content, which is the KL‑UNL chrome ground
truth).

## Deviations from the original (Goal A vs. B/C)

1. **Sliders are native `<input type="range">`** instead of the custom Flash
   `ProtoSimpleSlider`/`ProtoCyclicSimpleSlider`. Rationale: full keyboard
   operability + screen‑reader support (WCAG 2.1.1). The value ranges, 0.1°
   snapping (`step="0.1"`), and the effect on the geometry are preserved. The
   original hid the numeric value field (`alpha = 0`); we likewise show no number
   badge but expose the value + unit via `aria-valuetext`. The Sun/Moon sliders
   are conceptually cyclic (0–360°); a native range slider clamps at the ends
   rather than wrapping mid‑drag — a behaviorally negligible difference since 0°
   and 360° are the same direction.
2. **Layout is canvas‑left / controls‑right** (a sim‑specific two‑column grid in
   `styles/styles.css`) to match the original Flash screenshot (Goal C), rather
   than the foundation `.app-layout`'s controls‑left grid. It still uses the
   foundation `.panel` / `.control-fieldset` / `.control-choice` / `.button`
   classes and collapses to a single stacked column below the foundation's 56rem
   breakpoint. This is the only structural divergence from the default `.app-layout`.
3. **Camera slew uses `requestAnimationFrame`** with the same 900 ms duration and
   the ported `CubicEaser`, instead of a 20 ms `Timer`; timing is wall‑clock, so
   it matches across machines. `prefers-reduced-motion: reduce` replaces the
   animation with an instant jump to the end viewpoint (WCAG 2.3.3).
4. **Bisecting‑plane wedge stroking:** the Flash code strokes only some edges of
   each plane wedge (the outer rounded arc plus square corners, but not the
   radial spokes). The port fills the exact wedge geometry and strokes the most
   visible outer arc edge; the barely‑visible corner strokes (thickness 1) are
   omitted to avoid spurious radial lines. Fill geometry, colours, and alphas are
   exact. Purely cosmetic.
5. **No MathJax.** This simulation contains no mathematical equations, formulas,
   or symbolic notation in its UI — only angle readouts in degrees, which are
   quantities‑with‑units handled by labelled controls and `aria-valuetext`. The
   KL‑UNL foundation ships no MathJax include and the no‑CDN rule forbids fetching
   one, so MathJax is (correctly) not used. `foundation/kl-unl.js` is still linked
   for foundation completeness.

## Verification performed

Rendered and inspected (via canvas pixel capture) in the in‑app browser served
over HTTP: initial overhead reset state; a tilted "show all" state (all six
steps); the edge‑on "earth" perspective (Earth correctly fades transparent to
reveal the far‑side Moon and planes); the exact `phi = 0` edge case (special
4‑sector plane branch, no NaNs); and the Step‑6 phase disc (waxing gibbous).
Controls, hide/show‑all enable logic, contrast enable/disable, keyboard rotation,
mouse‑wheel value adjustment, `aria-valuetext`, the live region, single‑column
mobile‑portrait reflow (no horizontal scroll), and reset were all confirmed. No
console errors over HTTP. Human screen‑reader QA (NVDA + VoiceOver) is still
recommended.
