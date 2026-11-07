# Accessibility Notes — Three Views Simulator

Target: WCAG 2.1 AA (AAA where reasonable). Human screen-reader QA with **NVDA
(Windows)** and **VoiceOver (macOS/iOS)** is still required before release.

## Structure & semantics
* One `<h1>` only — rendered by the `<kl-unl-masthead>` component. Panels use
  non-skipping `<h2>` headings. `<main>` landmark; each panel is a `<section>`
  with `aria-labelledby`.
* `<html lang="en">`. A "Skip to main content" link is the first focusable item.

## Text alternatives (1.1.1)
* Both canvases have `role="img"` + `aria-describedby` pointing at a concise,
  continuously-updated text description of what the diagram currently shows
  (`#orbit-desc`, `#moon-desc`), regenerated from the single `state`/`render()`.
* The moon description names the current phase (From Earth), states "fully
  illuminated" (From Sun), or gives the illuminated percentage (From Space).

## Screen-reader narration (units always spoken)
* An `aria-live="polite"` status region (`#sr-status`) announces state changes
  **on commit** (perspective change, Run/Stop, Restart, Reset, Hide/Show, and the
  observer position on drag-release or each keyboard step) — never on every
  animation tick.
* Every announced numeric value carries its quantity name and unit, e.g.
  "Animation speed 50 out of 100", "Observation point 260 units right of the
  Sun, 260 units above", "…75 percent illuminated". Phase names ("Waxing
  Crescent", "First Quarter", …) are spoken in full and are copied verbatim from
  the source thresholds.

## Keyboard operability (2.1.1 / 2.1.2 / 2.4.7)
* Tab order contains **only** interactive controls: perspective radios →
  Animation-Speed slider → Run/Stop → Restart → Hide/Show Moon → (in Space view)
  the observer proxy → masthead Reset/Help/About. Canvases, descriptions and the
  live region are **not** tab stops (no stray `tabindex="0"`).
* **Animation-Speed slider** is a native `<input type="range">`: Left/Down
  decrement, Right/Up increment, PageUp/PageDown larger steps, Home/End min/max,
  and **mouse-wheel** while focused — with `aria-valuetext` giving the spoken
  value. It never gets "stuck" and Tab moves away cleanly.
* **Draggable space observer**: the `#space-observer` proxy (role="slider",
  `tabindex="0"`, visible focus ring) can be reached by Tab **and** is focused on
  click/tap of the arrow. Once focused, arrow keys nudge it (±10 stage units),
  PageUp/PageDown move vertically by 40, Home/End jump to the horizontal
  extremes, and the mouse wheel moves it vertically. Pointer drag and keyboard
  update the same `state` (clamped to ±280, exactly matching the ActionScript),
  and the new position + resulting Moon appearance are announced with units.
  Both paths use Pointer Events, so touch works on iOS Safari.

## Color & contrast (1.4.1 / 1.4.3 / 1.4.11)
* Colors come from the KL-UNL palette variables. No original Flash colors are
  hard-coded for state. **State is never encoded by color alone**: the phase is
  always available as text (phase name / illuminated percentage) in the live
  region and description, and each perspective has a text label. The Moon
  photograph and its dark terminator are physically meaningful imagery, not a
  color-coded status.

## Timing & motion (2.2.2 / 2.3.3)
* The only motion is the user-initiated **Run** animation, which is fully
  stoppable (the Run button toggles to **Stop Animation**) — this is the required
  pause control. Nothing animates until the user presses Run, and nothing
  flashes. `prefers-reduced-motion` is honored implicitly: the page is static
  until the user explicitly chooses to animate, and the render loop only runs
  while animating.
* Reset is provided solely by the masthead (`sim-reset` event); no second Reset
  button was added.

## Zoom & reflow (1.4.4 / 1.4.10)
* Body type is ≥ 1.125 rem and sized in rem/em; layout uses relative units and
  reflows without clipping at 200 % zoom. Canvases keep their internal
  coordinate system and scale with CSS (`width:100%; height:auto`), so text and
  controls in surrounding HTML zoom normally.
* Verified: single-column reflow at phone-portrait width (375 px) with **no**
  horizontal scrolling; touch targets ≥ 44 px.

## Math / MathJax
* The original simulation displays **no equations, numbers, or mathematical
  symbols** on screen, so none were invented. To stay self-contained (no CDN)
  and faithful, the UI contains no math notation: units and quantities are
  spelled as words ("degrees", "percent illuminated") in the accessible text.
  The foundation `klunlInitEqn()` hook is redefined to a no-op. If equations are
  added later, route them through `foundation/kl-unl.js` (`klunlShowEquation`).

## Known limitations
* The tiny orbit-view Earth day/night shadow and Moon terminator are not drawn
  (see CONVERSION_NOTES.md); this does not affect any labeled state or the
  accessible descriptions.
* Automated checks here are structural. Human NVDA + VoiceOver testing of reading
  order, announcement timing, and the draggable-observer experience is still
  required.
