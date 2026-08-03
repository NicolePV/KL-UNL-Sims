# Accessibility Notes — Blackbody Curves and Filters Explorer

Target: WCAG 2.1 AA (AAA where reasonable). Tested mentally against **NVDA**
(Windows / Chrome + Firefox) and **VoiceOver** (macOS / Safari + Chrome). Human
screen-reader QA is still required before release.

## Structure & semantics
- The single `<h1>` (the sim title) is rendered by the `<kl-unl-masthead>`
  component; the sim adds no competing `<h1>`.
- Panels are `<section>`s with `sr-only` `<h2>` headings ("Blackbody spectrum
  plot", "Curves and filters", "Plot scaling") to give a non-skipping heading
  outline without visual clutter (matching the original's clean, title-less
  panels). `<main>` landmark wraps the app.
- Tabs use the ARIA tablist pattern (`role="tablist/tab/tabpanel"`, roving
  tabindex, `aria-selected`, Arrow/Home/End keys).

## The canvas is not the accessibility layer
- `<canvas>` is `aria-hidden="true"`. A continuously-updated `sr-only`
  description (`#plot-desc`) states what the plot currently shows — number of
  curves, the selected curve's temperature and peak wavelength, and whether the
  filters overlay is active — updated from the single `render()`.
- Axis tick labels live in HTML (positioned over the canvas), so they zoom with
  the page and are exposed to assistive tech and the MathJax menu, rather than
  being baked into the canvas.

## MathJax (all math typeset; menu preserved)
- Every mathematical symbol is MathJax-typeset (tex-svg, bundled locally):
  y-axis values `5.0×10¹²`…`3.5×10¹³`, x-axis `100 nm`…`1 µm`, the y-axis title
  `Flux (J/s·m²·Δλ·sr)`, the peak-wavelength label, the "1 R☉" reference, the
  color-index `−`/`=` operators and result, and the "area under curve"
  scientific values in the curve list.
- Right-clicking any of these opens MathJax's "Show Math As → TeX / MathML" menu.
  The MathJax contextual menu is **not** disabled or overridden, and the
  `contextmenu` event is not trapped.

## Units are always spoken with numbers (supervisor requirement)
Every value with a unit is announced with its quantity name **and** unit — never
a bare number:
- Temperature slider `aria-valuetext` = "Temperature 6000 kelvin".
- Rightmost-limit slider `aria-valuetext` = "Rightmost limit 2500 nanometers,
  2.5 micrometers".
- Each curve row's `aria-label` = "Curve 1: temperature 6000 kelvin, peak
  wavelength 483.0 nanometers, area under curve 7.35 times 10 to the 7 watts per
  square meter, selected".
- The `aria-live="polite"` region (`#sr-status`) announces, on commit, e.g.
  "Selected curve temperature 6000 kelvin, peak wavelength 483.0 nanometers, area
  under curve 7.35 times 10 to the 7 watts per square meter."; add/remove curve;
  scale-mode changes; color-index changes ("Color index B minus V, 0.45").

## Keyboard
- Everything is reachable and operable by keyboard in a logical order; the
  foundation supplies the visible `:focus-visible` ring.
- **Sliders are native `<input type="range">`** — Arrow keys (± step), Page
  Up/Down (larger step), Home/End (min/max) all work out of the box; the
  temperature field also accepts direct typing. Tab always moves away cleanly (no
  trap). Announcements fire on `change`/commit, not on every tick, to avoid
  flooding.
- Curve selection is a radiogroup: the row shows a focus ring via `:focus-within`.
- **Every button, tab, and radio is an individual Tab stop.** Browsers apply
  radio-button "roving" (Tab lands only on the checked radio and skips the rest),
  and this is *not* overridable with `tabindex`. So the vertical-scale options and
  each curve-list row use a **unique `name` per radio** (making each its own
  single-member group, which is always sequentially focusable) inside a
  `role="radiogroup"` container, with single-selection enforced in JavaScript.
  Result: a user navigating by Tab alone reaches every option; Space/Enter selects.
  Trade-off: because the radios aren't a single native name-group, the arrow-key
  "cycle within group" gesture no longer moves selection — a deliberate choice to
  guarantee full Tab reachability (an explicit requirement here).
- The masthead dialog (Help/About) manages its own focus trap and Escape — the
  sim does not interfere.

## Color & contrast
- Palette uses the KL-UNL CSS custom properties. Text meets ≥4.5:1.
- **Curve colors are the original pastel set** (salmon, green, periwinkle, gold,
  grey) to preserve the Flash look and keep physically meaningful hues. Color is
  **never the only signal**: each curve is also identified by its row text
  (temperature / peak / area) and by the selected curve being drawn thicker (3 px
  vs 1 px) and highlighted in the list. A thin 1-px pastel line on white can fall
  below the 3:1 graphical-contrast target, but the redundant textual and
  line-thickness encoding keeps every curve unambiguous. If stricter graphical contrast is
  required, darken `CURVE_COLORS` in `simulation.js` (documented here so the
  change is intentional).
- The visible-spectrum rainbow is decorative/pedagogical (marks 380–720 nm); the
  numeric x-axis labels carry the wavelength information independently.

## Motion / timing
- The sim has **no continuous animation** and nothing that flashes — there is
  nothing to pause. `prefers-reduced-motion` additionally suppresses incidental
  CSS transitions.

## Responsiveness / touch
- Canvas keeps the original internal coordinate system and scales via CSS with a
  preserved aspect ratio; physics/drawing math is never recomputed from live
  element size.
- Layout reflows from desktop → iPad → phone portrait (single column, no
  horizontal scroll — verified at 375 px). The foundation's 56 rem collapse is
  intact; sim breakpoints live only in `styles/styles.css`.
- All controls are native and pointer/touch friendly; interactive targets meet
  the ≥44 px (2.75 rem) minimum from the KL-UNL styles; no hover-only affordances.

## Residual items for human QA
- Confirm NVDA and VoiceOver read the curve rows, slider values (with units), and
  live-region updates in the intended order without duplication.
- Confirm the MathJax "Show Math As" menu appears on every symbol in the target
  browsers (Chrome, Edge, Firefox, Safari desktop + iOS).
