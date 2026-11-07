# Accessibility Notes — Circumstellar Habitable Zone Simulator

Target: WCAG 2.1 AA (AAA where reasonable). Automated checks and manual keyboard
review were done; **human screen‑reader QA on real NVDA + VoiceOver is still
required** before release.

## Structure & semantics
- One `<h1>` — the sim title — is rendered by the `<kl-unl-masthead>` component;
  the sim adds only `<h2>` panel headings (`Star System Diagram`, `General
  Settings`, `Star and Planet Settings and Properties`, `Timeline and Simulation
  Controls`), no competing `h1`.
- `<main>` landmark; each panel is a `<section aria-labelledby>` its heading.
  `<html lang="en">`.
- Every control is a **native** element (`<button>`, `<input type=range|checkbox|
  radio|text>`, `<select>`, `<label>`, `<fieldset>/<legend>`) — no `<div onclick>`.

## Text alternatives (1.1.1)
- Each `<canvas>` has `role="img"`, an `aria-label` (e.g. "Top‑down view of the
  star system") and an `aria-describedby` pointing to a visually‑hidden paragraph
  that is **updated every render** with the current state: star mass/temperature/
  radius, planet distance and classification, habitable‑zone inner/outer bounds,
  the time, and the scale‑bar value. The H‑R, timeline, habitability and history
  canvases each have their own live text equivalent.
- Numeric readouts are MathJax (see below) exposed to screen readers as
  `role="img"` with an `aria-label` giving the spoken form ("1.00 solar masses").

## Mathematics (MathJax)
- **Every** number‑with‑unit and math symbol in the UI is typeset by MathJax
  (foundation `kl-unl.js` + `foundation/mathjax/tex-mml-chtml.js`, fully local):
  the star readouts (M☉, L☉, R☉, K), the planet distance and scale bar (AU) and
  the timeline year scale (My/Gy). Right‑clicking any of them opens MathJax's own
  "Show Math As → TeX / MathML" menu (the contextual menu is left enabled and is
  never trapped/`preventDefault`‑ed).
- Typeset math is **display‑only**: each `mjx-container` gets `tabindex="-1"` so it
  never enters the Tab order; screen readers get the spoken form from the paired
  `aria-label`/description, not the raw symbols.
- The two editable slider values ("initial star mass", "initial planet distance")
  are bare numbers in real text inputs (form values, not math notation), each with
  a units‑complete `aria-label`.

## Colour & contrast (1.4.1 / 1.4.3 / 1.4.11)
- Palette comes from the KL‑UNL CSS custom properties; body text is ≥ 4.5:1 on
  white.
- **State is never colour‑only.** The planet's five states carry distinct reused
  artwork **and** a spoken label ("too hot, inside the habitable zone", "tidally
  locked", "destroyed", …). The habitability strip and history bar keep the
  physically meaningful colours but every region is also named in the panel's text
  description. The "too hot"/"too cold" strip labels are real words.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)
Full operation, logical order, visible `:focus-visible` ring, no traps. Tab order
is **only** the interactive controls (verified): zoom, planet, the two checkboxes,
the system select, mass field+slider, distance field+slider, run, rate, time
cursor. Readouts, labels, MathJax and canvases are not tab stops.

| Control | Keys |
|---|---|
| **Planet** (focusable `role=slider` over the canvas; click/tap also focuses it) | ←/↓ nearer, →/↑ farther, PageUp/Down ×10, Home/End = min/max distance; new distance + zone state announced on commit |
| **Diagram zoom** (focusable `role=slider`) | ←/→ (or ↑/↓) zoom out/in, PageUp/Down coarser, Home = min zoom, End = large zoom; scale‑bar value announced |
| **Time cursor** (focusable `role=slider`; click/tap anywhere on the strip scrubs) | ←/→ (or ↑/↓) step to the previous/next data point (AS snapping), PageUp/Down ±5 %, Home/End = 0 / end |
| **Sliders** (mass, distance, rate — native `<input type=range>`) | ←/↓ decrement, →/↑ increment, PageUp/Down larger, Home/End min/max — all native; each announces a units‑complete `aria-valuetext` |
| **Fields, select, checkboxes, radio, run** | native behaviour |

Both the pointer and keyboard paths for the planet, zoom and time cursor mutate the
**same** `state` object, so mouse/touch and keyboard stay in sync.

## Screen‑reader narration (NVDA + VoiceOver)
- A single `aria-live="polite"` status region announces **committed** changes only
  (slider/drag release, cursor step, checkbox/radio/run, reset) — never per animation
  frame — so an audio‑only user can follow the sim without flooding.
- **Units are always spoken with the quantity name.** `aria-valuetext` /
  `aria-label` give e.g. "planet distance 1.00 astronomical units, too hot, inside
  the habitable zone", "star mass 0.30 solar masses", "temperature 5700 kelvin",
  "0 megayears since star system formation" — never a bare number. Units are spelled
  as words (megayears/gigayears, kelvin, astronomical units, solar masses/
  luminosities/radii) even where the symbol is shown visually.
- The per‑panel description paragraphs give the "what's happening" a sighted user
  sees, updated from the single `render()`.

## Timing / motion (2.2.2 / 2.3.3)
- The only long‑running motion is **Run**, which is user‑started and is its own
  Pause (the button toggles run⇄pause); it is never auto‑started. Reset is the
  masthead's `sim-reset` event (no second Reset button).
- `prefers-reduced-motion: reduce` makes the zoom easing instant and disables CSS
  transitions/animations. Nothing flashes; there is no >3 Hz flashing content.

## Responsive / touch
- Original 966×250 (and 130×140, 870×…) canvases keep their internal coordinates and
  are CSS‑scaled with preserved aspect ratio; pointer coordinates are mapped back
  through the scale so hit‑testing/snapping match the source at any size.
- Pointer Events give one mouse+touch path; `touch-action: none` on the draggable
  overlays. Desktop → iPad → phone‑portrait reflows to a single column with no
  horizontal scroll; interactive targets are ≥ 44 px; no hover‑only affordances.

## Known limitations / residual risks
- **Human SR QA still required** — automated + code review only so far.
- **Compact type in the Star & Planet panel.** To reproduce the original's dense,
  aligned settings layout (right-aligned labels, "star properties now:" centred
  against its four values), the labels/readouts in that panel use 0.95rem
  (~15px, just under the browser default) instead of the ≥1.125rem used for the
  rest of the sim. It is still rem-based (scales with the user's font setting and
  browser zoom) and reflows at 200%; every value is also exposed to screen
  readers with full units via aria-label.
- The reused planet frames and H‑R density map are bitmaps; their fine internal
  detail is conveyed by the spoken planet‑state label and the H‑R text description
  rather than pixel‑by‑pixel.
- Diagram/orbit/zone text labels live on (or over) the canvas; they scale with the
  canvas and are duplicated in the panel description, but do not re‑layout
  independently at very high zoom.
- The manual diagram‑zoom slider spans the whole diagram; a screen‑reader user
  reaches it before the planet handle when tabbing in.
