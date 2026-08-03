# Conversion Notes — Gas Retention Simulator (Flash AS1 → HTML5)

## Behaviour model (one paragraph)

The simulator shows how gases of different molecular masses behave in thermal
equilibrium and how a planet preferentially retains heavy gases while light gases
escape. The user builds a mixture of up to **three** gases (from a menu of nine).
Each gas is drawn as ~160 tracer particles bouncing in a **Chamber**, coloured
and sized per gas. A **Distribution Plot** shows each gas's Maxwell–Boltzmann
speed distribution (taller/narrower for heavier gases, shorter/wider for lighter,
scaled by amount), with an optional draggable **speed cursor** that reports the
fraction of the selected gas moving slower/faster than that speed, and an optional
**escape‑speed** marker. **Chamber Properties** set the temperature (100–1000 K)
and, when "allow escape from chamber" is on, the escape speed (100–1900 m/s). When
the simulation runs with escape enabled, each gas's amount decays exponentially at
a rate proportional to the fraction of its particles faster than the escape speed
(`λ = 0.001·(1 − CDF(v_escape))`), so light gases bleed away far faster than heavy
ones. The **Gases** panel holds a draggable bar chart of absolute amounts, the
gas list with live percentages, and controls to add/remove gases and reset
proportions. The sim **starts empty**; Reset returns it to empty with temperature
300 K, escape speed 1500 m/s, escape off, cursor off.

## Physics — verbatim constants & formulas (from `scripts/*.as`)

| Quantity | Value / formula | Source |
|---|---|---|
| Boltzmann k | `1.3806503e-23` | Gas Retention Simulator.as, TGC Gas Class.as |
| kg per u | `1.66053886e-27` | same |
| Gas const (a = √(R·T/M)) | `8314.47147` | Maxwell Plot Component.as, recalculatePlotScale |
| MB speed param | `a = sqrt(R·T/mass)` = `sqrt(kT/m)` | (identical; k/m ≡ R/M) |
| MB speed pdf | `√(2/π)·v²/a³·exp(−v²/2a²)` | drawMaxwell |
| Cumulative (slower than v) | `erf(v/(√2·a)) − √(2/π)·v·exp(−v²/2a²)/a` | getCDF |
| Peak‑height const C | `0.5870506526949597` (=2√(2/π)/e) | recalculatePlotScale |
| Escape decay | `λ = 0.001·(1 − CDF(v_esc))`, `frac(t)=frac₀·exp(−λ·t_ms)` | onStartSimulation / enterFrame |
| Particles per gas | `160 × fraction` | numParticlesMultiplier |
| Gas limit | 3 | gasLimit |
| Chamber scale / animationRate | `0.001` / `0.00015` | Thermal Gas Component init |
| Particle fade | fadeTime 2500, maxAlphaTime 10000, lifetime 15000 ms, alpha 10→100 | TGC Gas Class |
| Collision refresh F | `0.1·(Σfraction/3)·√(T/1000)` | doPseudoCollisions |
| Temperature slider | 100–1000 K, init 300 | Standard Slider init |
| Escape‑speed slider | 100–1900 m/s, init 1500 | Standard Slider init |

The **error function** (`erf` via the incomplete‑gamma series `gser`/`gcf`/
`gammln`) and the **Maxwell inverse‑CDF speed sampler** (the long rational
polynomial) are ported byte‑for‑byte from `Error Function.as` and
`TGC Gas Class.as` so sampled speeds and CDF percentages match the original
exactly. The nine gases' names, symbols, masses, colours and particle sizes are
copied verbatim from `Gas Retention Simulator.as`.

## AS1 → HTML5 mapping

| ActionScript | HTML5 port |
|---|---|
| `Object.registerClass` prototype classes | plain JS functions/objects in `simulation.js` |
| `onEnterFrame` + `getTimer()` | single `requestAnimationFrame` loop; `performance.now()` |
| Thermal Gas Component (createEmptyMovieClip, attachMovie particles, masks) | `<canvas>` 2D: particles as filled circles clipped to the box; escaping "ghost" particles drawn in the margin and faded |
| Maxwell Plot Component (drawMaxwell curveTo, background, x‑axis ticks) | `<canvas>` curves + fill; **axis numbers are HTML/MathJax**, tick marks drawn on canvas |
| Maxwell Plot Cursor Overlay (mouse band, onMouseMove, CDF text) | focusable HTML `role="slider"` cursor: pointer drag **and** keyboard, CDF text as MathJax overlay |
| Proportions Adjuster (draggable bars) | custom accessible bar‑slider component (`role="slider"`, arrows/Page/Home/End) in `styles.css` + `simulation.js` |
| Gas List / Gas List Entry | `<ul>` of `<button>` rows (dot, name+symbol, mass, %) |
| FComboBox (add gas) | native `<select>`; "(limit reached)" when 3 gases |
| FPushButton / FCheckBox / Standard Slider | native `<button>` / `<input type=checkbox>` / `<input type=range>` |
| Title Bar / About / Help dialog | the shared `<kl-unl-masthead>` (Reset/Help/About); `sim-reset` event wired to reset |
| `displayText` sub/sup renderer, Number.toFixed polyfill | native strings + MathJax for subscripts/superscripts |
| `_x/_y/_alpha`, `setMask`/`clip`, colour ints | canvas coords, `ctx.clip`, `#rrggbb` from decimal RGB |

## The contents.json edit (and a required correction)

The masthead resolves this sim by `sim-id="gasRetentionSimulator"`, whose entry
**already existed** in the shared `foundation/contents.json`. The Help/About text
is therefore used **verbatim** from that entry (no wording changed).

However, the shared `contents.json` as provided is **not valid JSON** and the
browser's `JSON.parse` (used by `kl-unl-masthead.js`) rejects it, which breaks the
masthead for *every* sim:

1. Raw control characters (a literal TAB and literal newlines) inside string
   values — e.g. `"content": "<p>\t…"` and a trailing newline before a closing
   quote (around line 200/1224 of the source).
2. Unescaped double quotes inside string values in unrelated entries — e.g.
   `renaissancePtolemaic` contains `href="../venusphases"` (the inner `"` closes
   the JSON string prematurely).

Because `contents.json` is the only foundation file I may modify, and the masthead
cannot function otherwise, I ship a **valid per‑sim copy** at
`foundation/contents.json` containing this sim's entry **verbatim** (plus the
`_comment` and the `newSim` template). This is the "per‑sim copy" model described
in the pipeline spec and avoids inheriting the other sims' malformed entries. The
other foundation files (`kl-unl-masthead.js`, `kl-unl.css`, `kl-unl.js`) are copied
**byte‑for‑byte unchanged**.

**Action for the pipeline maintainers:** fix the shared `contents.json` upstream
(escape the inner quotes; remove/escape the raw control characters) so a full
shared file can be used. This sim's entry to keep is exactly:

```json
"gasRetentionSimulator": {
  "meta": { "title": "Gas Retention Simulator", "version": "2.0" },
  "masthead": {
    "help":  { "title": "Help and Instructions", "content": "…verbatim…" },
    "about": { "title": "About this Simulator",   "content": "…verbatim…" }
  }
}
```
(full content is in `foundation/contents.json`).

## Assets

No exported bitmaps/photos are used — **every** visual element in this sim is
code‑drawn in the original (particles, curves, bars, dashed line, cursor). They
are reproduced with canvas 2D drawing, so `assets/` contains no reused art (see
`assets/README.md`). The Flash UI‑component skins (combo box, checkbox, button,
slider, scrollbar) are intentionally **not** ported; native accessible controls
replace them per the pipeline rules.

## Deviations from the original (and why)

1. **MathJax library not bundled.** The foundation export contained `kl-unl.js`
   (which expects `window.MathJax`) but no MathJax library, and CDNs are
   disallowed. Math is authored as LaTeX and typeset via MathJax from the expected
   local path `foundation/mathjax/tex-mml-chtml.js`; readable plain‑text fallbacks
   are shown until/if it loads. Drop the foundation's MathJax build there. (See
   README + ACCESSIBILITY.)
2. **Sliders are native `<input type=range>`, linear, step 10.** The original
   temperature slider used a *logarithmic* mapping and both sliders used
   "significant‑digits" snapping. Native ranges give full keyboard operability for
   free (a stated priority); step 10 keeps every value on the original's
   2–3 significant‑figure grid. Only the *mapping/feel* differs — the achievable
   values and all physics are unchanged.
3. **Proportions bars use absolute pointer mapping** (pointer Y sets the fraction
   directly) rather than the original grab‑offset drag. Behaviourally equivalent;
   more predictable for a slider and identical for keyboard.
4. **Colours kept for fidelity; identity never conveyed by colour alone.** The
   original per‑gas identity colours are retained (to match the screenshot), with
   thicker curve lines for legibility. Every gas is *always* also identified by
   name + chemical symbol (list, bars, cursor, plot fill), so no information is
   colour‑only. (See ACCESSIBILITY.)
5. **Animation pauses in hidden browser tabs** (standard `requestAnimationFrame`
   behaviour). Escape decay is based on elapsed wall‑clock time (matching the AS
   `getTimer()` model), so it resumes consistently when the tab is shown again.
6. **Layout** follows the KL‑UNL shell (panels via foundation classes), not the
   original Flash pixel coordinates, but mirrors the screenshot's quadrant
   arrangement: Chamber + Chamber Properties (left), Distribution Plot + Gases
   (right); it collapses to a single stacked column on narrow/portrait widths.

## Verification performed (no emulator)

Served over HTTP and exercised programmatically: add/remove gases (limit 3 →
"(limit reached)"), selection sync across list/bars/cursor/plot fill, proportion
changes and normalized percentages, temperature/escape readouts with units, the
speed cursor CDF (water at 1000 m/s → 93.5% slower, matching the original
screenshot), and escape decay (1000 K / 500 m/s: hydrogen → 8% while xenon → 51%
after 2.5 s — light escapes, heavy retained). Masthead loads and Reset returns to
the empty initial state. Note: raster screenshots and the rAF animation could not
be captured in the headless preview because it runs the page in a *hidden* tab
(which pauses `requestAnimationFrame`); the time‑based logic was verified by
driving the decay/step functions directly. Human screen‑reader QA is still
required (see ACCESSIBILITY.md).
