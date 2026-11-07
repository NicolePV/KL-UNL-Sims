# Accessibility Notes — Variable Star Photometry Analyzer

Target: WCAG 2.1 AA (AAA where reasonable). Built on the KL-UNL foundation
(masthead component, palette variables, focus-visible styles, `.sr-only`).

## Structure and semantics

- One `<h1>` (rendered by `<kl-unl-masthead>`); panels are `<section>`s with
  `<h2 class="panel__heading">` headings and `aria-labelledby`.
- `<main>` landmark wraps the simulation; the masthead supplies the header
  and its own accessible Reset/Help/About dialog (focus trap + Escape).
- `<html lang="en">`; every input has a real `<label>`; the radio group has a
  `<fieldset>/<legend>` ("lightcurve plot type:").

## Text alternatives

- Each canvas is `aria-hidden="true"` and paired with a visually-hidden
  description (`#starfieldDescription`, `#lightcurveDescription`,
  `#pdmDescription`) stating what the diagram shows and how to operate it.
- A single `aria-live="polite"` region announces state changes **with units**
  on commit (not per tick), e.g. "Period 5.3663 days.", "PDM plot now shows
  periods 4.0000 to 8.0000 days.", "Comparison star selected at pixel x 29,
  y 42.", "Magnitude difference between bars 0.45 magnitudes." Announcements
  are debounced (120 ms) to avoid flooding NVDA/VoiceOver.
- The theta axis label is MathJax-typeset and paired with a spoken
  description via the foundation's `klunlShowEquation` message argument.

## Keyboard map (only interactive controls are tab stops)

| Control | Keys |
| --- | --- |
| Star field (26 stars) | **One** tab stop for the whole field, not one per star. Tab to focus it, then ←/→/↑/↓ move the highlight to the nearest star in that direction, Home/End jump to the first/last star, and Enter/Space chooses the highlighted star. Clicking/tapping a star also selects it and moves the highlight there, so the arrow keys continue from the clicked star. Tab leaves the field normally. |
| show crosshairs / show difference tool / plot-type radios | native checkbox/radio semantics |
| period text field | type digits and `.`, Enter or blur commits; invalid values revert |
| period pointer (`role="slider"`) | ←/↓ and →/↑ move one plot-pixel (≥0.0001 days), PageUp/PageDown ×10, Home/End = axis min/max; click/tap focuses it, then arrows work; `aria-valuetext` = "period 7.0000 days" |
| difference-tool bars (`role="slider"`, vertical) | ↑/↓ 2 px, PageUp/PageDown 20 px, Home/End = plot top/bottom; `aria-valuetext` includes the bar value and the current difference in magnitudes |
| zoom buttons | native buttons; disabled states mirror the original logic |

The star field is implemented as `role="listbox"` (`aria-multiselectable`)
whose options are the stars, with `aria-activedescendant` tracking the
arrow-key highlight — so screen readers announce each star as the highlight
moves without the field costing 26 tab stops. The two chosen stars carry
`aria-selected="true"`, and each option's accessible name states its position
and current role (comparison star / star of interest). Because DOM focus stays
on the container, the highlighted star draws its own high-contrast ring
(amber on a dark halo, visible over both sky and star cores) to satisfy 2.4.7.
Arrow navigation was verified to reach all 26 stars from every starting star.

No keyboard traps: all handlers leave Tab alone, and pointer capture is
released on pointerup/cancel. MathJax output, readouts, labels and canvases
are **not** focusable (`mjx-container` gets `tabindex="-1"` if the renderer
adds one).

## Units with numbers

Every announced or slider-exposed value names its quantity and unit in full
words: "days", "magnitudes", "pixel x / y". The visual difference label keeps
the original abbreviated text (" 0.45 mag ") while the sliders' cursor
`aria-valuetext` and the live region speak "magnitudes".

## Color and contrast

- Chrome colors come from the KL-UNL palette variables.
- State is never color-only: the comparison star is a blue **square** and the
  star of interest a green **circle** (shape + color), matching the labeled
  key row; off-scale period states show arrows **plus** the original text
  ("selected period is off to the left/right"); disabled buttons are
  dimmed **and** `disabled`.
- Prose and headings are 1.125 rem; the compact control rows (key row,
  lightcurve plot type row) and the "select two stars" overlay are 1 rem
  (16 px = the browser default), set at the maintainer's request so those
  labels do not dominate the panels. All sizes are in rem, so they track the
  user's browser font setting and the layout reflows at 200% zoom (canvases
  scale, text is HTML). Note this is below the project style guide's ~1.125 rem
  body-copy floor for those two rows; raise the `font-size` on `.sim-key-row`
  and `.sim-plot-controls` in `styles/styles.css` to restore it.
- Original in-plot colors are preserved (data marks on a white plot at ≥3:1;
  the loading message red was darkened to #cc0000 for 4.5:1 on white).

## Motion

- The only animation is the 1000 ms zoom transition; under
  `prefers-reduced-motion: reduce` it becomes an instantaneous jump to the
  same end state. Nothing flashes; no continuous motion, so no Pause control
  is needed. Reset is provided by the masthead `sim-reset` event.

## Touch

- Pointer Events everywhere; `touch-action: none` only on the draggable
  surfaces (plots, bars, pointer). The period pointer's touch target is
  44×36 px CSS; buttons/checkboxes use the KL-UNL ≥44 px sizing.
- Star buttons are ~22 px (screen) — enlarging them to 44 px would make
  adjacent stars (21 px apart in the 400 px field) unselectable, breaking
  functional parity. Noted as a deliberate trade-off (WCAG 2.1 AA does not
  mandate target size; 2.5.5 is AAA).

## Known limitations / human QA still required

- The crosshair x/y readout is a pointer-hover affordance (as in the
  original) and is hidden from screen readers; star coordinates are exposed
  on the star buttons instead.
- The PDM drag-to-zoom window is pointer-only; keyboard users have full
  zoom coverage via the four zoom buttons + period field, but not arbitrary
  window placement.
- The theta curve and lightcurve shapes are conveyed via summary
  announcements, not sonification; an expert screen-reader pass (NVDA on
  Windows/Chrome+Firefox, VoiceOver on macOS/Safari+Chrome) is still
  required before release.
