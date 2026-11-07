# Accessibility Notes — Small-Angle Approximation Demonstrator

Target: WCAG 2.1 AA (AAA where reasonable). Built on the shared KL-UNL
foundation (palette, focus handling, responsive grid) — foundation files are
unmodified.

## Structure & landmarks
- The masthead component renders the page title (the `<h1>`). Panels use `<h2>`
  (`Diagram`, `Distance`, `Diameter`) in a non-skipping order.
- `<main class="app-layout">`; each panel is a `<section>` labelled by its
  heading (`aria-labelledby`). A "Skip to controls" link is the first focusable
  element.

## Text alternatives (1.1.1)
- The canvas is `role="img"` with `aria-label="Small-angle diagram"` and an
  `aria-describedby` pointing at a polite live region that states the current
  diameter, distance, and small-angle angle.
- The reused observer and ball bitmaps are composited on the canvas; their
  meaning is conveyed by that text description (not by the image alone).
- The equation and the angle label **α** are real HTML typeset by MathJax, each
  paired with a screen-reader string via `klunlShowEquation`.

## Math via MathJax (rule 8 / 8a)
- The small-angle equation and **every** math symbol shown (the constant, the
  fraction, the `α` on the arc, and the `α` in the help text) are typeset by the
  locally-vendored MathJax (SVG output, no CDN). Right-clicking any of them opens
  the MathJax menu ("Show Math As → TeX / MathML"). The menu is **not** disabled
  (`enableMenu: true`); the `contextmenu` event is not trapped.
- Nothing mathematical is baked onto the `<canvas>`: the formula and the α label
  live in HTML so they zoom and expose the menu. The α label is absolutely
  positioned over the scaled canvas and repositioned on every render/resize.
- The screen-reader description of the equation is spoken prose, e.g.
  *"Alpha equals 206,265 times linear diameter over distance, equals 10313.3
  arcseconds, for a linear diameter of 2.0 units and a distance of 40.0 units."*

## Color & contrast (1.4.1 / 1.4.3 / 1.4.11)
- All palette colors come from the foundation CSS custom properties.
- **Color remaps** (recorded per the prompt): tangent lines `0xA0A0A0` →
  `#5f5f5f` (the original grey is ~2.6:1 on white, below the 3:1 graphical
  minimum); the angle arc `0x000000` → `--foreground-color` `#1a1a1a`.
- **Color is never the only signal.** Every quantity the diagram encodes is also
  given as text: the slider value outputs, the equation, and the live region.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)
- Tab order: Skip link → masthead (Reset / About) → distance slider → distance
  presets → diameter slider → diameter presets. Focus is never trapped; the
  masthead dialog manages its own focus and Escape.
- **MathJax containers are kept OUT of the tab order.** With its menu enabled,
  MathJax makes every `mjx-container` focusable (`tabindex="0"`), which had put the
  decorative angle label α and the aria-hidden equation into the tab order. A small
  `MutationObserver` sets `tabindex="-1"` on the sim's MathJax containers so tabbing
  skips them; right-clicking still opens the MathJax context menu.
- **Both sliders are native `<input type="range">`**, so they are fully
  keyboard-operable for free: ← / ↓ decrement, → / ↑ increment (step 0.1),
  PageUp / PageDown larger steps, Home / End for min / max. Tab moves away
  cleanly. No custom slider was needed, so no foundation override was required.
- **Drag parity:** the ball can be dragged with pointer or touch; the distance
  slider is its exact keyboard equivalent (both go through `applyDistance`, with
  identical clamp + 0.1 snapping).
- Focus is visible via the foundation `:focus-visible` ring. Canvas pointer
  handlers use pointer capture and never steal focus from the controls.

## Timing / motion (2.2.2 / 2.3.3)
- Motion is the brief **300 ms** cubic ease of the canvas picture when distance or
  diameter changes (presets, slider, or ball drag) — far under 5 s, nothing flashes.
  Only the canvas drawing eases; the slider, its ARIA value, and the readouts update
  immediately, so the easing never delays the value announced to a screen reader.
  No Pause control is needed (no long-running or looping animation).
- `prefers-reduced-motion: reduce` is honored: changes jump straight to the end
  state (no ease).

## Live region (status)
- A polite `aria-live` region (`#stage-desc`) announces the settled state on
  **commit** — slider release (`change`), end of a preset ease, end of a ball
  drag, and Reset — not on every animation tick. Wording matches the on-screen
  equation.

## Forms & language
- `<html lang="en">`. Every control has a real `<label>` (sliders) or is inside a
  `<fieldset>`/`<legend>` group (preset rows use `role="group"` + `aria-label`).
- Touch targets (sliders, buttons) are ≥ 44 px (2.75 rem) via the foundation
  `.button` rules and sim slider sizing; no hover-only affordances.

- Diagram is a full-width box on top; Distance and Diameter sit below in the
  foundation `.app-layout` (side by side on PC, collapsing to stacked at the
  foundation's 56rem breakpoint). There are **no sim-specific breakpoints** — the
  shared template governs the multi-column responsiveness. The canvas scales
  (keeping original internal stage coordinates) with preserved aspect ratio. Usable
  at 200% zoom.
- The small-angle equation is a single math expression; on very narrow widths it
  scrolls horizontally **within its own box** (math is exempt from 1.4.10
  reflow). Its value is also available in the slider output and live region.

## Still required
Automated checks and this review do not replace **human screen-reader QA**
(NVDA / JAWS / VoiceOver) and real keyboard-only testing, which should be done
before release.

---

## AUDIO / SCREEN-READER PASS

An accessibility-only retrofit to make the sim fully usable by audio alone (NVDA
on Windows, VoiceOver on macOS), targeting standard ARIA that works in both. **No
behavior, layout, visuals, physics, or on-screen text were changed**; MathJax,
responsiveness, and cross-browser behavior were re-verified afterward. Foundation
files are untouched; all new logic is in `simulation.js`, no new styling needed.

### Values made units-complete (no bare numbers)
The sim's quantities are in generic **"units"** (its own unit word); the computed
angle is in **arcseconds**.

- **Distance slider** (`#distance-range`): `aria-valuetext` carries the spoken
  value **with unit**, e.g. `"40.0 units"`, kept in sync with the visible value
  and precision on every change (drag, keyboard, preset ease). The `<label
  for="distance-range">distance:</label>` supplies the quantity name, so a screen
  reader speaks **"distance, 40.0 units"**. (The old `aria-describedby` was
  removed so "units" isn't spoken twice.)
- **Diameter slider** (`#diameter-range`): same pattern → **"diameter, 2.0 units"**.
- **Preset buttons**: each given a descriptive accessible name via `aria-label`
  so it speaks the quantity + value + unit instead of a bare number —
  `"Set distance to 20 units"` … `"Set distance to 60 units"`, and
  `"Set diameter to 1 units"` … `"Set diameter to 3 units"` ("units" kept for
  consistency with the sim's wording).
- **Visual value echoes** (`<output>` "40.0" and the "units" span) are marked
  `aria-hidden="true"` — they duplicate what the slider's `aria-valuetext` already
  speaks, so hiding them from the reader avoids a redundant bare "40.0" in browse
  mode. They remain fully visible on screen.

### Live-region status wording
A single polite live region (`#stage-desc`, which also serves as the canvas's
`aria-describedby`) is updated **from the sim's state on commit only** (slider
release / `change`, end of a preset ease, end of a ball drag, and Reset) — never
per animation tick, so audio users aren't flooded. Wording (units-complete):

> "Ball of linear diameter 2.0 units at a distance of 40.0 units. Angular size by
> the small-angle approximation: 10313.3 arcseconds."

Per-tick feedback while arrowing a slider comes from the slider's own
`aria-valuetext` (standard SR behavior), not from the live region. The unused
empty `#sr-status` region was removed so there is exactly one status region and no
double-announcements.

### Canvas description approach
The `<canvas>` is `role="img"` with `aria-label="Small-angle diagram"` and
`aria-describedby="stage-desc"`. `#stage-desc` holds the current-state sentence
above, updated from state, so the otherwise-invisible diagram is reachable by ear.
The decorative α overlay is `aria-hidden="true"` (its meaning is given in prose).

### Equation
The MathJax equation (`#angle-eqn`) is `aria-hidden="true"` and paired with a
units-complete spoken companion (`#angle-eqn-sr`, `.sr-only`), set via
`klunlShowEquation`:

> "Alpha equals 206,265 times linear diameter over distance, equals 10313.3
> arcseconds, for a linear diameter of 2.0 units and a distance of 40.0 units."

This gives one clean, units-complete reading rather than letting the symbolic
MathJax and a prose description both be spoken. The visual equation and its
right-click MathJax menu are unaffected.

### Unit-word mappings applied
- generic unit → spoken **"units"** (matches the sim's own label)
- `arcsec` → **"arcseconds"**
- The constant `206{,}265` and the words "linear diameter" / "distance" are spoken
  as words in the equation companion.
- No negative quantities occur in this sim, so no "minus"/"negative" handling is
  needed.

### Not verified by machine
Screen-reader compatibility is **not** claimed as verified. The accessibility tree
was reasoned about and inspected (DevTools/DOM), but final confirmation requires a
**human listening test on NVDA (Windows; Chrome + Firefox) and VoiceOver (macOS;
Chrome + Safari)**.
