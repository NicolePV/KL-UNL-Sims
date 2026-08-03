# Accessibility Notes — Photometry Simulator (WCAG 2.1 AA)

## Structure & semantics

- One `<h1>` (rendered by the KL-UNL masthead). Panels are `<section>`s with
  `<h2>` headings ("Star Field", "Magnitude Difference Calculation",
  "Aperture 1 Info", "Aperture 2 Info"); the Inner Disc / Outer Ring groups
  are `<h3>`s. `<main>` landmark wraps the app layout; `lang="en"` set.
- The checkbox has a real `<label>` ("label the apertures", verbatim).

## Text alternatives

- The star-field canvas is `role="img"` with an `aria-label` and a
  continuously updated hidden description (`#fieldDesc`) stating the field
  size, star count, and both aperture positions — an audio-only user gets
  the same "what's happening" as a sighted user.
- Zoom canvases are `aria-hidden`; their information is exposed through the
  focusable wrapper's `aria-label` (selected pixel x, y and counts) and the
  live region.
- Each MathJax equation is paired with a spoken description (via
  `klunlShowEquation` message elements, `aria-describedby`), units-complete
  ("… equals 6058.70 counts", "… equals not defined (the flux ratio is not
  positive)").

## Keyboard operation (no traps; visible focus everywhere)

| Control | Keys |
|---|---|
| Aperture 1 / 2 (movable aperture, `role="application"`) | Tab or click/tap to focus; Arrow keys move 1 pixel (original step); Shift+Arrow ±10; PageUp/PageDown ±10 vertical |
| Zoom window 1 / 2 (pixel inspector, `role="application"`) | Tab or click/tap to focus (focus selects the center pixel, as the original did); Arrow keys move the inspected pixel 1 cell; PageUp/PageDown ±5; Home/End to the row edges; hover also inspects (never hover-only) |
| label the apertures | native checkbox (Space) |
| Reset / Help / About | native buttons in the masthead component (it manages its own dialog focus trap + Escape) |

- Pointer and keyboard paths mutate the same state object, so results are
  identical. Click/tap explicitly calls `.focus()` (Safari does not focus on
  click by itself), so arrows work immediately after clicking.
- `role="application"` is used on the two 2-D draggables and the two pixel
  inspectors so NVDA passes arrow keys through in focus mode;
  `aria-roledescription` ("movable aperture" / "pixel inspector") names them
  for both NVDA and VoiceOver. Their `aria-label`s carry name + value
  ("Aperture 1, center x 196, center y 188 pixels…").
- Tab order contains ONLY interactive controls: aperture 1, aperture 2,
  checkbox, zoom 1, zoom 2 (plus masthead buttons). Typeset MathJax is
  forced to `tabindex="-1"` (a MutationObserver re-applies it after every
  re-typeset); readouts, labels, and canvases are not tab stops.

## Screen-reader narration (NVDA + VoiceOver)

- A single polite live region announces on commit (not per tick):
  - aperture moves (on release / debounced after arrows): "Aperture 1 moved
    to center x 196, center y 188 pixels. Sky-subtracted flux f 1 is 6058.70
    counts. Magnitude difference m 1 minus m 2 is not defined."
  - pixel inspection (debounced): "Pixel x 196, y 188: 2246 counts." or
    "…outside the star field, counts not available."
  - Reset: full restored state with both aperture positions.
- Every number is announced with its quantity name and unit (pixels, counts,
  magnitudes) — never a bare number.

## Color & contrast

- Text uses the KL-UNL palette variables (≥4.5:1). Body text ≥1.125rem in
  rem units.
- Aperture identity is NEVER color-only: apertures are numbered ("1"/"2"
  toggleable labels, panel headings, aria-labels); the green/orange outline
  colors are kept from the original (≈6.5:1 and ≈6.8:1 against the dark
  field — pass 3:1 graphical).
- Focus rings: original Flash color #9090FF (3px) over the dark star field
  (≈5.8:1 there); the zoom windows' ring uses the KL-UNL `--outline-color`
  because #9090FF is under 3:1 against the white panel. This is the one
  color remap; rationale: WCAG 1.4.11.
- The active-pixel outline (#9090FF, 2px) matches the original and is
  supplemented by the text tooltip and live region (not color-only).

## Motion / timing

- The simulation has no animation at all (the field is static), so no Pause
  control is needed and `prefers-reduced-motion` has nothing to suppress.
  Nothing flashes.

## Reflow / zoom / touch

- Layout reflows desktop → iPad → single-column phone portrait with no
  horizontal page scroll (verified at 375px). Wide equations scroll inside
  their own container. Usable at 200% zoom (rem-based sizing, no fixed-px
  crop heights).
- Canvases keep original internal coordinates and scale via CSS with
  preserved aspect ratio; pointer coordinates are mapped back through the
  scale, so touch drag on iOS behaves identically (`touch-action: none` on
  draggables only).
- Aperture drag targets are extended to ≈47×47 px invisible hit areas
  (visual size unchanged).

## Canvas text

- No math and no labels are baked into the canvas: the "1"/"2" aperture
  labels are HTML overlays (zoomable), the pixel tooltip is HTML, and all
  x/y variables and equations are MathJax (right-click menu enabled — the
  contextmenu event is not intercepted anywhere).

## Remaining human QA

Automated/manual DOM checks were done in Chromium; a human screen-reader
pass (NVDA on Windows Chrome/Firefox, VoiceOver on macOS Safari/Chrome and
iOS) and a manual 200%-zoom / high-contrast-mode sweep are still required
before release.
