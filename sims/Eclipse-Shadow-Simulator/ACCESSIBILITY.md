# Accessibility Notes — Eclipse Shadow Simulator

Target: WCAG 2.1 AA (AAA where reasonable). Human screen-reader QA with **NVDA**
(Windows) and **VoiceOver** (macOS/iOS) is still required before release — the notes
below describe what was built and mentally tested, not a substitute for that QA.

## Structure & semantics

- Single `<h1>` — the simulation title — is rendered by the `<kl-unl-masthead>`
  component. Panels use `<h2>` (`Controls`, `Diagram`); no heading levels are skipped.
- Landmarks: `<main class="app-layout">`; each panel is a `<section>` labelled by its
  heading (`aria-labelledby`). `<html lang="en">`. A "Skip to the shadow diagram"
  link is the first focusable element.
- Controls use native semantics: `<fieldset>`/`<legend>` group Earth, Moon, and the
  shadow key; every slider is a real `<input type="range">` with an associated
  `<label>`; readouts use `<output>`.

## The canvas (informative image + text equivalent)

- The `<canvas>` has `role="img"`, an `aria-label`, and `aria-describedby` pointing at
  a visually-hidden `#stage-desc` paragraph that is **rewritten on every `render()`**
  with the current, units-complete state: Sun position, and each disc's position and
  distance from the Sun. An audio-only user gets the same "what's on screen" a sighted
  user sees, and it stays in sync with the single state object.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)

- Everything is operable by keyboard in a logical tab order; focus rings come from
  `:focus-visible` (foundation) plus a slider-specific ring in `styles.css`.
- **Sliders are fully keyboard-operable** (native `<input type="range">`): Left/Down
  decrement, Right/Up increment, PageUp/PageDown large steps, Home/End min/max. Tab
  moves away cleanly — no traps. The canvas pointer handlers do not intercept slider
  focus (drag uses `setPointerCapture` on the canvas only).
- **Dragging has two keyboard equivalents:** (a) each disc has its own focusable
  handle overlaid on the canvas — press **Tab** to reach the Earth or Moon disc (or
  **click** a disc to focus it, which turns on a visible dashed "focus mode" ring),
  then move it with the **arrow keys** (hold **Shift** for 10-pixel steps); and (b) the
  X/Y sliders in the Controls panel. All paths mutate the same state as the pointer
  drag, so nothing is mouse-only. The disc handle exposes an `aria-label` carrying its
  quantity + units ("Earth disc, horizontal 311 pixels, vertical 204 pixels. Use the
  arrow keys to move…"), updated on every change.
- The masthead dialog manages its own focus trap / Escape / restoration; the sim does
  not interfere with it.

### Keyboard map

| Control | Keys | Effect |
|---|---|---|
| Earth / Moon disc handle (Tab to it, or click the disc) | ←/→ move X, ↑/↓ move Y; hold Shift for 10-px steps | move that disc in 2-D (constrained); shows the focus-mode ring |
| Earth Horizontal / Vertical sliders | ←/↓, →/↑, PageUp/PageDown, Home/End | move Earth in stage X / Y (constrained) |
| Moon Horizontal / Vertical sliders | same | move Moon in stage X / Y (constrained) |
| Reset / Help / About (masthead) | Enter/Space | reset state / open dialogs |
| Dialog | Esc | close, restore focus to the trigger |

## Screen-reader narration (units always spoken)

- **Every numeric value is announced with its quantity name and unit** via
  `aria-valuetext`, e.g. *"Earth horizontal position: 311 pixels from the left edge,
  range 0 to 900"* and *"…vertical position: 204 pixels from the top edge, range 0 to
  500"*. Units are spelled out ("pixels"), never left as a bare number or a symbol
  that a reader might skip. The visible `<output>` shows the short form (`311 px`).
- A polite `aria-live` region (`#live`, `aria-atomic`) announces committed changes —
  on drag **release** and on slider **change**, not on every tick (debounced ~120 ms)
  — e.g. *"Earth moved to horizontal 311 pixels, vertical 204 pixels. Distance from
  the Sun 261 pixels."* Reset announces a confirmation. `assertive` is not used.
- Wording in the live region, the readouts, and the hidden description is kept
  consistent with the visible labels.

## Color & contrast (1.4.1 / 1.4.3 / 1.4.11)

- Text and controls use the KL-UNL palette variables (dark charcoal on white ≥ 7:1;
  the blue slider thumb/buttons ≥ 4.5:1 against white). Body copy is ≥ 1.125rem in
  rem/em (WCAG 1.4.4) and the layout reflows without clipping at 200% zoom (1.4.10).
- **Color is never the only signal.** The umbra/penumbra are also named in text (the
  shadow key, the hidden canvas description, and the live region), and the shadow key
  swatches are paired with word labels.
- **Shadow shading is intentionally faithful to the physics** and therefore low
  contrast by design: the penumbra is a very light gray (`0x505050` @ 10% over white)
  and the umbra a medium gray (`0xB0B0B0` @ 90%). These come straight from the source
  and represent the real partial/total shadow — re-coloring them would misrepresent
  the phenomenon. Because they are not the sole carrier of meaning (text names both
  shadows and their roles), this satisfies 1.4.1; the exact shades are preserved for
  educational correctness (parity Goal A). Thin boundary lines (`0x505050` @ 50%)
  reinforce the shadow edges.

## Timing / motion (2.2.2 / 2.3.3)

- No autonomous animation: the sim is a single static frame that only changes on user
  input, so there is nothing that moves > 5 s, nothing flashes, and there is nothing
  to pause. `prefers-reduced-motion` therefore needs no special handling. (Reset is
  provided by the masthead's `sim-reset` event — wired, not duplicated.)

## Mathematics / MathJax

- The original simulation displays **no equations, formulas, variables, Greek
  letters, subscripts/superscripts, or units in mathematical notation** anywhere in
  its UI — it is a purely visual, drag-driven geometry demo. The HTML5 version keeps
  this: the only numbers shown are plain pixel positions/distances (e.g. "311 px"),
  which are not mathematical notation. Consequently there is nothing for MathJax to
  typeset, and no math is painted on the canvas. `kl-unl.js` is still loaded per the
  foundation protocol, but `klunlShowEquation`/`klunlInitEqn` register no equations.
  The "right-click → MathJax menu" verification does not apply because there is no
  math content. If pixel readouts are later reframed as formal notation, route them
  through `klunlShowEquation` with a units-complete spoken description.

## Touch / responsive

- Pointer Events drive one code path for mouse + touch; `touch-action: none` on the
  canvas and sliders prevents drags from scrolling/zooming the page. No hover-only
  affordances.
- Slider thumbs and masthead buttons meet the ≥ 44px (2.75rem) target size. Layout
  reflows from desktop → iPad → phone portrait (single column, no horizontal scroll);
  the canvas keeps its 900:500 internal coordinate system and scales via CSS, so drag
  hit-testing stays exact at any display size.

## Still to verify with real assistive tech

- NVDA + Firefox/Chrome and VoiceOver + Safari reading of slider `aria-valuetext`,
  the live-region announcements, and the canvas description (order, no duplication or
  truncation).
- That focus order and the skip link behave as intended on iOS VoiceOver.
