# Accessibility Notes — Eclipsing Binary Simulator

WCAG 2.1 AA affordances added in the HTML5 conversion. **Human screen-reader
QA (NVDA on Windows, VoiceOver on macOS/iOS) is still required before
release.**

## Structure

- One `<h1>` (rendered by the KL-UNL masthead). Each of the four panels has an
  `<h2>`; all four are visually hidden because the visible group titles are
  `<legend>` elements, which name their `<fieldset>` for assistive technology
  more precisely than a heading would.
- Landmarks: masthead `<nav>` (from the component), `<main>` for the sim,
  `<section>` per panel, `fieldset`/`legend` for each control group.
  `<html lang="en">`.
- Tab order contains only operable controls, in reading order (column-major,
  matching the visual columns): masthead buttons → orientation sliders →
  animation controls → visualization checkboxes → HR-diagram button →
  light curve cursor → phase-axis offset → light curve checkbox → preset
  select/buttons → star and system sliders (+ the HR window's controls while
  it is open; the perspective proxy joins the order only while the perspective
  is unlocked). Typeset MathJax gets `tabindex="-1"` so it never becomes a tab
  stop.

## Keyboard map

| Control | Keys |
| --- | --- |
| Every slider (custom `SliderV5` thumb, `role="slider"`) | ←/↓ smaller, →/↑ larger, Shift+Arrow = fine (one original tick), PageUp/PageDown = ×10, Home/End = min/max |
| Slider value fields | type digits, commit with Enter or blur (chars restricted to `0-9.Ee+-`) |
| Light curve phase cursor (focusable proxy over the red line) | ←/→ ±0.01 phase, PageUp/Down ±0.1, Home 0, End 0.99; click/tap the cursor also focuses it |
| Phase-axis offset (tick strip, `role="slider"`) | ←/→ ±0.01, PageUp/Down ±0.1, Home 0, End 0.5 (initial value); dragging the plot background does the same |
| Perspective view (proxy, only when unlocked; click/tap focuses it) | ←/→ rotate viewing direction, ↑/↓ change viewing height (2° steps, Shift = 0.5°, PageUp/Down = 15°), pointer drag identical to the original |
| HR-diagram points 1 and 2 (focusable, click/tap focuses) | ←/→ temperature (left = hotter, as on the diagram), ↑/↓ luminosity, PageUp/Down = coarse; pointer drag identical to the original; while focused/dragging the allowed-region shading is shown |
| HR-diagram window | draggable by its title bar (pointer); Escape or the close button closes it; focus moves in on open and returns to the opener on close |
| Buttons / checkboxes / preset list | native controls (Space/Enter, arrow keys in the list) |

No keyboard traps; focus rings come from the foundation's `:focus-visible`
styles (an inset ring is added for the full-bleed perspective proxy).

## Units are always spoken with values

Every slider exposes `aria-valuetext` = *quantity + value + unit in words*
("Star 1 mass 1.0 solar masses", "Star 2 temperature 5070 kelvin",
"Inclination 79.50 degrees", "Separation 10.00 solar radii"). Value fields
carry matching `aria-label`s ("Star 1 mass in solar masses"). The visual unit
symbols (\(M_\odot\), \(R_\odot\), K, °) are MathJax-typeset and
`aria-hidden`; speech always comes from the words, never the glyphs. The
period readout is announced as "System period 2.58 days"; HR-point positions
as "Star 1: temperature 8700 kelvin, luminosity 11.3 solar luminosities."

## Live region and diagram descriptions

- A single polite `role="status"` live region announces state changes **on
  commit** (drag release, key-idle ≈0.5 s, checkbox toggle, preset load,
  reset, animation start/pause) — never per tick, so audio users are not
  flooded during drags or animation.
- `#visDesc` (visually hidden, tied to the visualization panel) is a
  continuously updated text equivalent of the 3-D view: perspective state,
  phase, both stars' temperature/radius, separation, eccentricity and period.
- `#lcDesc` describes the light curve: whether eclipses occur and the depth of
  the deepest eclipse as a fraction of full brightness.
- The masthead Help/About dialogs manage their own focus and Escape handling
  (foundation component, untouched).

## Color and contrast

- All chrome uses the KL-UNL palette variables (≥4.5:1 text contrast).
- The excluded slider ranges are shown with a darker shade **plus a diagonal
  hatch pattern**, so the restriction is not signaled by color alone.
- Star-disc colors are physical blackbody colors (educational content —
  unchanged); the same information is available as numeric temperature
  readouts and in the live descriptions, so color is never the only signal.
- The light curve cursor is red *and* has a labelled focusable proxy; the
  earth-direction arrow is described in `#visDesc` when the perspective is
  unlocked.

## Motion

- The orbit animation runs only after the user presses "start animation" and
  can always be paused with the same button (2.2.2). Nothing flashes.
- `prefers-reduced-motion: reduce` replaces the continuous animation with
  discrete 2 Hz phase steps; all manual controls behave identically.

## Zoom / reflow

- Body text is 1rem (the browser's own default size) and every other size is
  in rem/em, so all text still scales with the reader's browser font setting.
  The maintainer asked for one uniform size across the interface; group titles
  are the only larger text, at 1.1rem bold. The layout stacks to one column
  below 56rem (foundation breakpoint) and reflows further for phone portrait
  (sim breakpoints in `styles/styles.css`), so 200% zoom reflows without
  clipping or horizontal scrolling. Canvases keep their original internal
  coordinates and scale via CSS with preserved aspect ratio; pointer
  coordinates are mapped back through the scale.
- Axis titles and tick labels for both plots and the HR diagram live in HTML
  (they zoom and can be read by AT), not baked into the canvas.

## Known limitations (documented for human QA)

- Numbers drawn *inside* canvases are limited to nothing — all tick labels
  are HTML. The only text-bearing raster is the reused main-sequence
  **background cloud** (decorative, `aria-hidden` canvas) — the mass labels of
  the main-sequence track are MathJax-typeset HTML overlays.
- The observed-data bitmaps (grey measurement dots) are described in `#lcDesc`
  only as part of the selected preset; individual data points are not
  enumerated (matching the original, which provided no textual access either).
- Touch targets: buttons, checkboxes and the preset drop-down are ≥44px
  everywhere. Slider rows are 44px under `@media (pointer: coarse)` (touch
  devices) but 32px for mouse users, so that eleven slider rows do not force
  the page to scroll on a laptop; the grabbable thumb stays 29px tall, above
  the 24px WCAG 2.2 (2.5.8) minimum, and every slider is fully keyboard
  operable regardless. The HR-diagram points are 24px. All of these grow with
  browser zoom.
