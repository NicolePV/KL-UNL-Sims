# Conversion Notes — Planetary Configurations Simulator

## Behaviour model (one paragraph)

The simulator models two planets orbiting the sun on circular, coplanar orbits in
a simplified Copernican model. Each planet *i* has a semimajor axis `a_i` (AU) and
period `P_i = a_i^1.5` years (Kepler's third law). Given a time `t` and epoch
angles, each planet's angle is `θ_i = epochAngle_i + 2π·t/P_i`. From planet 1
(the *observer's planet*) the code computes the ecliptic longitude of planet 2
(the *target*) and of the sun, and their difference is the **elongation** angle
(0–180°, tagged E or W). The lower-`a` planet is the *inferior* one; the event
names and geometry differ depending on which planet is inferior. Four
configuration events recur each **synodic period** `S = 1/(1/P_inf − 1/P_sup)`:
for an inferior observer they are *opposition, quadrature (eastern), conjunction,
quadrature (western)*; for a superior observer *inferior conjunction, greatest
elongation (western), superior conjunction, greatest elongation (eastern)*. The
three views — orbit **Diagram**, **Zodiac Strip**, and **Timeline** — all render
from the single shared state. The user can drag the planets (moving time, or, with
Shift, one planet's epoch angle), drag the timeline, click event names to slew to
them, animate the system, and change orbit sizes via sliders / editable fields /
planet presets.

## AS → HTML5 mapping

| ActionScript (source) | HTML5 port (`simulation.js`) |
|---|---|
| `ConfigurationsSimulatorClass` (`Configurations Simulator.as`) | the `sim` state object + core functions (`update`, `setTime`, `setSemimajorAxis`, `calculateSystemProperties`, `calculateAnimationRate`, `animateOnEnterFrame`, `slewToEvent`, countdown, `onReset`) — ported method-for-method, constants verbatim |
| `OrbitsDiagramClass` / `OrbitsDiagramPlanetClass` | `drawDiagram()` on `#diagram-canvas` + the two focusable planet handles; drag math (`atan2(-y,x)`, `angleOffset`, snap `angleThreshold = acos(1 − d²/2r²)`) preserved |
| `TimelineClass` / `TimelineEventCycle` / `TimelineEventItem` | `drawTimeline()` on `#timeline-canvas`; scale/unit/precision math and the counter string ported verbatim; event-name click → `slewToEvent` |
| `ZodiacStripClass` + `Constellations Data.as` | `drawZodiac()` on `#zodiac-canvas`; the ecliptic projection (obliquity `0.40913426548833737`, `111.40846…` px/rad) and the pisces (index 7) wrap-around are ported; starfield bitmap and constellation data reused as-is |
| `Slider Logic Class v6` / `Standard Slider v6` (Flash FUIComponent framework) | **not ported.** Only the observable behaviour is reproduced with native `<input type="range">` + editable text fields. Fixed-digits precision 2 → step `0.01`; min-increment nudging on the `a1 == a2` collision reproduced (`setSemimajorAxisFromSlider`). |
| `FComboBoxSymbol` presets | native `<select>` with the verbatim label/data arrays (`<presets>`, Mercury 0.39, Venus 0.72, Earth 1, Mars 1.52, Jupiter 5.2, Saturn 9.54) |
| `FRadioButtonSymbol` "when an event occurs" | native radio group: stop / **keep going** (`run`, default) / pause for N seconds |
| pause-time slider (bar & grabber hidden in source) | editable number field only (1–15), as in the original |
| `onEnterFrame` + `getTimer()` | single `requestAnimationFrame` loop dispatching on `loopMode`; `performance.now()`; timing constants unchanged (`slewTime = 650`, countdown `1000 × pauseTime`) |
| masthead / About / Help / Reset | `<kl-unl-masthead>`; `sim-reset` event wired to `onReset()` |

## Reused assets (not redrawn)

- `assets/zodiac-starfield.png` — the original `images/203.png` (400×60 starfield),
  drawn with `ctx.drawImage`, tiled 3×.
- `assets/constellations.js` — the original `_root.constellationsData` array from
  `Constellations Data.as`, verbatim (only the assignment target changed to a
  browser global). All coordinates/paths unchanged.

Everything else in the three canvases is genuinely code-drawn geometry in the
source (orbits, discs, arrows, timeline scale, elongation arc), so it is
reproduced with canvas 2D drawing.

## contents.json (IMPORTANT — foundation defect worked around)

The `configurationssimulator` entry already existed in the shared
`foundation/contents.json`, with correct Help/About text derived from the
original (`texts/132.txt`, `3.txt`, `8.txt`, `9.txt`, `5.txt`). **However, the
shared file as shipped is not valid JSON** — several *other* sims' entries contain
raw newlines inside string values (`ce_hc`, `eclipsingbinarysim`, …) and
unescaped double quotes (`renaissancePtolemaic`: `<a href="../venusphases">`).
`JSON.parse` (used by the masthead) rejects the whole file, so **no** sim using
this foundation copy can load its masthead.

Because this is the **per-sim copy** and the masthead only reads
`data["configurationssimulator"]`, the copy placed in `html5/foundation/` is a
**minimal, valid** `contents.json` containing this sim's entry (content unchanged
from the source's own `configurationssimulator` entry) plus the `newSim` template.
This is the only content change to any foundation file; `kl-unl.css`,
`kl-unl.js`, and `kl-unl-masthead.js` are copied byte-for-byte unchanged.

If you prefer to keep the full shared file, fix its JSON syntax errors upstream
(escape the stray `"` and remove the embedded newlines) and drop this sim's entry
in alphabetically — the entry itself is standard and valid.

## Deviations from the original

1. **MathJax not used.** The KL-UNL foundation shipped here contains **no** MathJax
   include, and the rules forbid CDNs. This simulator contains **no equations** —
   the only math-flavoured glyphs are the degree sign in elongation readouts and
   unit abbreviations (AU, yr). These are rendered as accessible HTML text with a
   spoken unit form in the ARIA value/description (see ACCESSIBILITY.md). If a
   MathJax build is added to the foundation later, the degree/unit readouts can be
   wrapped in `\( … \)` and driven through `klunlShowEquation`.
2. **Sun/planet disc colours & radii** are approximated for the code-drawn discs
   (the exact fill of the "Orbits Diagram Sun" symbol was not exported): sun
   `#f4c40f` r≈9; observer/target discs use the exact AS colour ints
   (`8626940`, `10000536`) at r≈7. Orbit lines, timeline shading/lines, and the
   elongation-angle line colour use the exact AS ints.
3. **Constellation hover-highlight** (grey → blue + name) is not reproduced: it was
   a hover-only affordance in Flash, and hover-only affordances are disallowed by
   the accessibility rules. The grey constellation outlines still render.
4. **Layout** follows the KL-UNL shell (panel structure + reading order matching the
   provided screenshot: Diagram + Zodiac Strip on the left, Orbit Sizes / Animation
   Controls / Timeline on the right), not the original Flash pixel coordinates,
   palette, or fonts — as required by the priority order.

## Verification performed (no emulator)

Behaviour was checked against the AS source by running the served page and
scripting it: initial state locks on *opposition* at `t=0`, elongation `180.0°`,
synodic period `1.36791`, event times `[0, 0.2484, 0.684, 1.1195]` (matches the
formulas); raising `a1` above `a2` swaps the event-name set to the inferior/superior
family; presets, the `a1 == a2` rejection, planet keyboard drag (time and Shift/epoch
modes), timeline keyboard stepping, and Reset all behave as the source specifies.
A rendered screenshot could not be captured in the headless preview used during
development (its renderer did not paint); the three canvases were confirmed to draw
non-blank content by sampling their pixels. **Human visual + screen-reader QA in a
real browser is still recommended.**
