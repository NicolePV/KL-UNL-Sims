# Accessibility Notes — Gas Retention Plot

Target: WCAG 2.1 AA (AAA where reasonable). Human screen-reader QA with **both
NVDA (Windows) and VoiceOver (macOS/iOS)** is still required before release —
the notes below describe what was built in.

## Structure & landmarks

- One `<h1>` only — rendered by the `<kl-unl-masthead>` component ("Gas
  Retention Plot"). Panels use `<h2>` headings (`Gases`, `Plot Options`,
  `Custom Object Properties`, plus a visually-hidden `<h2>` for the plot).
- Content is a single `<main class="app-shell">`; each panel is a `<section>`
  labelled by its heading (`aria-labelledby`).
- `<html lang="en">`.

## The plot (canvas)

- The `<canvas>` has `role="img"` and a descriptive `aria-label` summarising the
  axes and contents.
- A visually-hidden, continuously-updated description (`#plot-description`)
  reports the custom-object dot's temperature and escape speed (with units), the
  list of gases shown, and the list of solar-system bodies shown with their
  coordinates — so an audio-only user gets the same "what's on the plot" a
  sighted user sees.
- **All math is in HTML overlays, not painted on the canvas**: axis titles
  ("Speed (km/s)", "Temperature (K)"), the numeric tick labels, and the gas-line
  labels ("H₂, 10×V<sub>avg</sub>", …) are MathJax-typeset HTML positioned over
  the canvas. Right-clicking any of them opens MathJax's "Show Math As" menu.
  - **Exception (documented):** the solar-system body **names** (Earth, Jupiter,
    …) are drawn as plain text on the canvas. They contain no mathematical
    notation, so rule 8a (every *math* symbol via MathJax) is not implicated;
    they are also reported through the hidden plot description for audio users.

## Math via MathJax

- MathJax is loaded locally (`assets/tex-svg.js`, SVG output) and its contextual
  menu is left **enabled** (`options.enableMenu: true`); the `contextmenu` event
  on math is never trapped.
- Every mathematical symbol/expression in the UI is MathJax-typeset: gas
  formulas (H₂, CO₂, …), molecular masses (`2 u`), slider units (K, km, g/cm³),
  the AU distance, the scientific-notation mass (e.g. 4.5×10²¹ kg), and the
  km/s escape velocity.

## Keyboard

- Everything is operable by keyboard in a logical tab order, with the visible
  `:focus-visible` ring from the foundation CSS. No keyboard traps; the masthead
  dialog manages its own focus.
- **Sliders** are native `<input type="range">`: Left/Down decrement,
  Right/Up increment, Page Up/Down large step, Home/End min/max — all for free.
  Each also has an editable numeric field for typing an exact value (Enter or
  blur commits).
- **The draggable red dot** has a focusable proxy (`role="application"`,
  `tabindex="0"`):
  - Tab to focus it (visible focus ring), or click/tap the dot to focus it.
  - Arrow keys move it — Left/Right change temperature, Up/Down change escape
    speed; Page Up/Down take larger speed steps; Home/End jump to min/max
    temperature. Movement uses the same snapping logic as the mouse.
  - Tab moves away normally.

## Screen-reader narration (units always spoken)

- A polite live region (`#sr-status`) announces committed changes with full
  quantity + number + **unit**, e.g. *"Custom object: temperature 70 kelvin,
  escape speed 1.0 kilometers per second."*, *"nitrogen shown."*, *"Gas giants
  shown."*, and on snap *"…snapped to Earth."*
- Range sliders expose `aria-valuetext` = quantity + value + spoken unit
  (e.g. *"temperature 70 kelvin"*, *"density 5.0 grams per cubic centimeter"*,
  *"radius 600 kilometers"*) so the value is never read as a bare number.
  **Escape speed has no slider of its own** (it's derived from radius &
  density), so all three sliders' `aria-valuetext` also append it — e.g.
  *"radius 600 kilometers, escape speed 1.0 kilometers per second"* — so the
  custom object's full location (both plot axes) is always spoken no matter
  which control is focused, not just the axis that control directly sets.
- The dot proxy exposes `aria-label` = *"Custom object marker at temperature N
  kelvin, escape speed N kilometers per second[, snapped to Planet]. …"*
  (it uses `role="application"`, not `role="slider"`, since it moves on two
  independent axes at once, so `aria-label` carries the live position instead
  of `aria-valuetext`).
- Units are spelled as full words for speech (kelvin, kilometers, grams per
  cubic centimeter, kilometers per second, AU) while the symbol is shown
  visually via MathJax.
- Announcements fire on commit (release / change / key), not on every drag tick,
  to avoid flooding.
- **Gases table:** the abbreviation "u" (atomic mass unit) is a bare letter
  that can audibly blend into whatever is read next (e.g. the following row's
  gas name reads as "uhelium"). The visual MathJax "16 u" is hidden from
  screen readers (`aria-hidden`, still visible and right-click-able for
  sighted/mouse users) and paired with a `.sr-only` spoken equivalent, "16
  atomic mass units.", whose trailing period guarantees a clean pause. The
  parenthetical chemical symbol next to each gas name (e.g. "(H₂)") is
  likewise `aria-hidden` with no spoken replacement — the gas name alone
  ("hydrogen") is already a complete, unambiguous accessible label for the
  row, so the symbol is treated as decorative for audio purposes.

## Colour & contrast

- Palette uses the KL-UNL CSS custom properties. Text is ≥ 4.5:1.
- **No state is signalled by colour alone.** Each gas is always identified by its
  name and symbol text (not just its shading colour). The custom dot is
  identified as "custom object" in the description, not only by being red. The
  "snapped to a body" state adds a ring + bold label + spoken announcement in
  addition to the red label colour.
- The physically-meaningful gas shading colours from the original are retained
  (they are decorative bands; meaning is carried by the always-present labels).

## Timing / motion

- The sim has no continuous animation, nothing flashes, and there is no motion
  lasting > 5 s, so no Pause control is required. `prefers-reduced-motion` is
  honoured by disabling incidental transitions. Reset is provided solely by the
  masthead (the `sim-reset` event); no second Reset button is added.

## Zoom & responsive

- Body text is ≥ 1.125 rem and everything is sized in rem/em, so it tracks the
  browser font size and remains usable at 200 % zoom without clipping (the
  canvas scales via CSS while keeping its internal coordinates).
- Layout reflows from desktop → iPad → phone portrait (single column, no
  horizontal scroll). Interactive targets meet the 44 px minimum; no hover-only
  affordances (Pointer Events power both mouse and touch).
