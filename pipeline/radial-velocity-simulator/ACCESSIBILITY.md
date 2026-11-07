# Accessibility notes — Radial Velocity Simulator

WCAG 2.1 AA baseline. **Human screen-reader QA (NVDA/Chrome+Firefox,
VoiceOver/Safari+Chrome) is still required** — this document records what
was built and manually exercised via the DOM/accessibility tree in an
automated browser, not a substitute for that testing.

## Structure & semantics

- One `<h1>` — rendered by `<kl-unl-masthead>`; no competing heading added.
- Each panel is a `<section>` with its own `<h2 class="panel__heading">`.
  The Visualization and Radial Velocity Plot panels have **no visible**
  heading text in the original (matching the reference screenshot exactly),
  so their `<h2>` is present but visually hidden (`sr-only`) — satisfies
  both the heading-hierarchy requirement and the visual-fidelity goal.
- `<main class="app-layout">` wraps the panel grid; every input has a real
  `<label>` (or `aria-label` for the two canvas drag proxies, which have no
  visual label by design) and every fieldset has a (visually-hidden)
  `<legend>`.
- `<html lang="en">`.

## Color & contrast

- Uses the KL-UNL palette variables for all chrome (buttons, focus rings,
  borders). Sim-specific colors (RV curve blue, measurement-dot gray, body
  discs) are the original AS palette re-rendered on white/black canvas
  backgrounds; none are the sole carrier of meaning — every colored
  element (curve, measurement dots, phase cursor, direction arrow, orbit
  bodies) also has a text label, readout, or live-region description.
- No color-only signaling: e.g. the "earth view" arrow has a text label,
  the phase cursor position is always available via its readout + live
  region, star/planet identity is conveyed by size/position/labels, not
  color alone.

## Keyboard

- All ten sliders are native `<input type="range">`: full Left/Right/Up/
  Down/PageUp/PageDown/Home/End support for free, with `aria-valuetext`
  set on every change to the full spoken quantity + value + unit (e.g.
  "Planet mass 0.316 Jupiter masses", "Inclination 135.0 degrees").
  Verified: dragging any slider via a synthetic `input` event updates the
  displayed readout, the `aria-valuetext`, and the physics/render output
  in the same call, and none of them get stuck disabled/enabled
  incorrectly (noise/number sliders correctly enable only when "show
  simulated measurements" is checked).
- Nine of the ten sliders also have a real `<label>`-associated, directly
  editable `<input type="text">` value field beside them (matching the AS
  source's typeable `valueField`), with its own `aria-label` and the same
  Enter/blur-commit + reformat-and-clamp behavior as the original — a
  second, often faster, input path for sighted keyboard and screen-reader
  users alike, not just a slider-only affordance. The (separate) unit text
  beside it is `aria-hidden` since the full spoken form already lives in
  the slider's `aria-valuetext`.
- Two custom draggable canvas objects, each a real focusable proxy element
  (`tabindex="0"`, `role="slider"`) satisfying the tab-to-focus AND
  click/tap-to-focus pattern (`.focus()` called on `pointerdown`):
  - **System orientation** (`#vizDragProxy`, over the Visualization canvas):
    Left/Right = azimuth ±3° (±10° with Shift), Up/Down = altitude ±3°
    (±10° with Shift, clamped to ±90°), Home = reset to 80°/45°. Both the
    pointer-drag and keyboard paths call the same `renderVisualization()`
    and update the same `state.theta/state.phi`.
  - **Current phase cursor** (`#phaseCursorProxy`, over the RV plot):
    Left/Right = phase ∓/± 0.01 (∓/± 0.05 with Shift), Home = 0, End =
    0.999, wrapping at 0/1. Both paths update `state.phase` and stay in
    sync with the Animation Controls phase slider (verified: a keyboard
    ArrowRight press moved the cursor from 0.000 to 0.010 and updated the
    phase-slider readout and the live region together).
- Visible `:focus-visible` ring on every control (from `kl-unl.css`); no
  keyboard traps (verified Tab moves through all controls in DOM order and
  the masthead's own Help/About dialog manages its own focus/Escape).
- One gap, documented rather than silently dropped: the RV plot's
  background-drag-to-pan-the-phase-axis gesture (`phaseOffset`) is
  pointer-only. It only changes which portion of the wraparound x-axis is
  visible, not any physical parameter — the phase *cursor*, which does
  carry physical meaning, is fully keyboard-operable via its own proxy
  above.

## Screen-reader narration

- `#liveStatus` (`aria-live="polite"`) announces discrete commits: preset
  applied, reset, orientation-drag release, phase-cursor commit — with
  units and quantity names, not bare numbers (e.g. "View orientation:
  azimuth 83 degrees, altitude 48 degrees.").
- `#vizDesc` and `#plotDesc` (`aria-live="polite"`, tied to their canvases
  via `aria-describedby`) hold a continuously-updated plain-language
  description of what the diagram currently shows — verified to include
  the amplitude and period (with units) even though no *visible* amplitude
  readout exists in the original layout (see CONVERSION_NOTES.md
  "amplitudeField" discrepancy) — so an audio-only user isn't missing
  information a sighted user has to compute themselves.
- Every numeric value with a unit is announced via `aria-valuetext` /
  `aria-label`, spelled out as full words for speech ("degrees",
  "Jupiter masses", "solar masses", "astronomical units", "meters per
  second"), never a bare number.

## Math / MathJax

- All slider readouts, the "system period" readout, and unit-bearing text
  are routed through a MathJax-typesetting helper (`setMath()`) using the
  same `window.MathJax.typesetPromise` API the foundation's `kl-unl.js`
  wraps; `klunlInitEqn` is redefined (as a no-op) per the foundation's
  contract, matching the established convention already used by sibling
  sims in this collection.
- `foundation/mathjax/tex-mml-chtml.js` + its `output/chtml/fonts/woff-v2/`
  fonts are vendored locally (see README.md), so MathJax is genuinely
  active, not just theoretically wired up — verified in-browser: unit
  readouts contain real `<mjx-container>`/`<mjx-msub>` elements (proper
  subscript markup), e.g. star mass renders "M" with a "sun" subscript
  (`M_{\text{sun}}`, matching the AS source's literal `M<sub>sun</sub>`
  label rather than the ⊙ symbol), and the network panel shows zero
  external requests (all `foundation/mathjax/...` resolve locally). If
  `foundation/mathjax/tex-mml-chtml.js` is ever removed, every readout
  falls back to plain, fully readable text (e.g. "0.316 Mjup", "135.0°")
  rather than showing raw LaTeX or breaking.
- The MathJax context menu is not disabled or intercepted anywhere —
  verified the typeset containers carry MathJax's own `ctxtmenu_counter`
  attribute, confirming its contextual-menu handling is attached normally.

## Motion

- No animation runs by default; the orbital-phase animation only starts
  when the user presses "start animation" and is driven by
  `requestAnimationFrame`, fully stoppable via the same button (label
  toggles "start animation" ⇄ "pause animation"). No motion exceeds 5s
  without a way to stop it, and nothing flashes.
- `prefers-reduced-motion: reduce` is honored for CSS transitions; there
  is no scroll-triggered or auto-starting motion to suppress.

## Known simplifications (see CONVERSION_NOTES.md for full list)

- The "earth view" arrow's text label is drawn upright rather than skewed
  with the arrow's 3D foreshortening — deliberately favors legibility/zoom
  (WCAG 1.4.4/1.4.10) over exact visual replication of the original's
  baked-rotation label.
- Body-icon "lens" edge-clipping against the orbital plane is simplified
  to a plain shaded circle (position/size/color/z-order are exact).

## Not yet verified in this session

- Real NVDA/VoiceOver pass (tooling in this session could drive the DOM
  and accessibility tree but not a live screen reader).
- Visual 200% zoom reflow and phone-portrait width (screenshots became
  available again partway through this session and were used to catch and
  fix a real layout bug — see CONVERSION_NOTES.md — but a dedicated 200%
  zoom / narrow-viewport visual pass hasn't been done yet; the CSS uses
  rem units and flex/grid wrapping throughout, so it's expected to reflow
  correctly, but this should still get a manual look).
