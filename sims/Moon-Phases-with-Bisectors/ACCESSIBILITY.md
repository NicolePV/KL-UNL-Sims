# Accessibility Notes — Determining Moon Phases Using Bisectors

Target: WCAG 2.1 AA (AAA where reasonable). Built on the KL‑UNL foundation.
**Human screen‑reader QA on NVDA (Windows) and VoiceOver (macOS) is still
required** — the notes below describe the affordances that were built in.

## Structure & landmarks

* One `<h1>` — the simulation title, rendered by `<kl-unl-masthead>` (in its
  shadow DOM). The page does not add a competing `h1`.
* `<main>` wraps the sim; each panel is a `<section>` with an `<h2>` heading
  (the diagram section's `h2` is visually hidden but present for structure).
  Heading order does not skip levels.
* `<html lang="en">`.

## Text alternatives for the canvas (1.1.1)

The `<canvas>` scene is informative, not decorative. Two visually‑hidden,
`aria-live="polite"` regions convey it to non‑visual users:

* **`#scene-desc`** — a continuously‑updated description of what the diagram
  currently shows: Sun direction and Moon position (in degrees), the current
  viewing angles, which construction steps are visible, and the resulting Moon
  phase. Updated from the single `render()`/state path.
* **`#live-status`** — announces the result of each discrete action (toggling a
  step, moving a slider on release, rotating the view, resetting), debounced so
  dragging does not flood the screen reader.

The Step‑6 phase disc `<canvas>` is `aria-hidden` because the adjacent phase
**name** text (e.g. "Waxing Gibbous") is the accessible equivalent.

## Units are always spoken with numbers (supervisor requirement)

Every numeric value is exposed with its **quantity name and unit**, never a bare
number:

* Sun Direction slider → `aria-valuetext="Sun direction N degrees"`
* Moon Position slider → `aria-valuetext="Moon position N degrees"`
* left/right slider → `aria-valuetext="left/right N degrees"`
* up/down slider → `aria-valuetext="up/down N degrees"`
* contrast slider → `aria-valuetext="Shadow contrast N percent"`
* Live/description regions spell out "degrees" (and "percent") as full words.

## Keyboard operability (2.1.1 / 2.1.2 / 2.4.7)

Only interactive controls are in the tab order. Tabbing lands on: hide all,
show all, the six step checkboxes, the contrast slider, the Sun/Moon sliders, the
earth/overhead buttons, the left‑right/up‑down sliders, and the scene canvas.
Static content (headings, phase name, live regions, the disc canvas) is **not**
focusable. The foundation supplies the visible `:focus-visible` ring.

**Sliders** are native `<input type="range">`: Left/Down decrement, Right/Up
increment, PageUp/PageDown larger step, Home/End min/max — all for free, no
"stuck" slider. They also respond to **mouse‑wheel** while focused (up = increase,
down = decrease). Tab always moves away cleanly (no trap).

**The 3‑D view is the draggable object**, and it is fully keyboard‑operable:

* **Tab to focus** — the canvas is in the tab order (`role="application"`,
  `tabindex="0"`, described by help text).
* **Click/tap to focus** — pointer‑down focuses the canvas, so the arrow keys
  work immediately after clicking.
* **Arrow keys rotate** — Left/Right change the left/right angle, Up/Down change
  the up/down angle (5° step; Shift = 15°); Home resets left/right to 0°, End
  sets up/down to 90° (overhead). The equivalent left/right and up/down sliders
  in the Perspective panel provide the same control. New angles are announced
  with units via the live region; both paths update the same state.

## Colour & contrast (1.4.1 / 1.4.3 / 1.4.11)

Colours use the KL‑UNL palette variables for chrome. The scene keeps the
original physically‑meaningful colours (orange Sun‑bisector planes and arrows,
blue Earth‑Moon planes and line, lit/dark globe hemispheres). **State is never
encoded by colour alone:** every construction step has a text label (Step 1–6),
the Moon phase is given as text ("Waxing Gibbous" …), and all angle/contrast
values are announced as text with units. The disc's lit/dark split is mirrored by
the spoken phase name.

## Motion (2.2.2 / 2.3.3)

The only motion is the ~0.9 s camera slew when "earth"/"overhead" is pressed —
well under 5 s and not flashing. `prefers-reduced-motion: reduce` replaces it
with an instant jump to the target viewpoint. Nothing flashes more than 3×/sec.
Reset is provided by the masthead (`sim-reset`); no continuous animation runs, so
no separate Pause control is needed.

## Responsive / zoom (1.4.4 / 1.4.10)

Body text ≥ ~1.05rem, sized in rem/em so it tracks the browser font setting.
Layout is a two‑column grid (diagram + controls) that collapses to a single
stacked column below the foundation 56rem breakpoint and reflows to phone
portrait with no horizontal scrolling. The canvas keeps its original 600×600
internal coordinate system and is scaled by CSS with preserved aspect ratio;
pointer coordinates are mapped back through the scale so drag/hit‑testing match
the source at any display size. Verified usable at narrow (phone‑portrait) widths,
which also covers 200 % zoom reflow.

## Touch & cross‑browser (2.5.x, general)

Pointer Events give one code path for mouse and touch; `touch-action: none` on the
canvas means dragging rotates instead of scrolling the page. Interactive targets
meet the ≥44 px minimum via the foundation `.button`/control sizing; no control is
hover‑only. Standards‑based HTML/CSS/JS only (no Chrome‑only APIs, no
prefix‑only CSS), so it works in Chrome, Edge, Firefox, and Safari (desktop + iOS).

## Note on mathematics

This simulation has no equations or symbolic math in its interface, so MathJax is
not used (and the foundation ships none). Angle and percentage readouts are
plain quantities with units, handled by labelled controls and `aria-valuetext`
rather than typeset math.
