# Accessibility Notes — Supernova Light Curve Fitting Explorer

Target: WCAG 2.1 AA (ADA Title II). Built on the KL-UNL foundation
(shared palette, focus styles, responsive shell).

## Structure & semantics

- Single `<h1>` rendered by `<kl-unl-masthead>`; the two panels are
  `<section>`s with `<h2 class="panel__heading">` headings inside
  `<main>`.
- All controls are native elements: `<input type="checkbox">`, `<select>`,
  `<input type="text">` (calculator), each with a real `<label>` or
  `aria-label`. `<html lang="en">`.
- The canvas is `aria-hidden` (visual layer only). Its text equivalent is
  `#sn-plot-desc` (visually hidden, continuously updated from the single
  `render()`), plus the polite live region `#sn-live`.

## Keyboard map

Tab order contains ONLY operable controls: masthead buttons → checkbox →
supernova select → data-drag surface → (reference bar, when shown) →
calculator m → calculator M. Typeset MathJax, readouts, tick labels and
the canvas are not tab stops (`tabindex="-1"` is enforced on any MathJax
container that tries to become focusable).

**Data drag surface** (`role="application"`, focus by Tab or by
click/tap; the drag is two-dimensional, exactly like the original's
Draggable Area):

| Key                | Action                                             |
| ------------------ | -------------------------------------------------- |
| Left / Right       | shift observations 1 day earlier / later           |
| Shift + Left/Right | shift 10 days                                      |
| Home / End         | smallest (0) / largest (200 px ≈ 195.7 days) shift |
| Up / Down          | distance modulus +0.1 / −0.1 magnitudes            |
| Shift+Up/Down, PageUp/PageDown | distance modulus ±1 magnitude          |

**Reference bar** (`role="slider"`, vertical, −22 … −10):
Up/Left = brighter 0.1 mag, Down/Right = fainter 0.1 mag, PageUp/PageDown
= 1 mag, Home/End = top/bottom. `aria-valuetext` always carries both
readouts with quantity names.

Both drag proxies focus themselves on `pointerdown`, keep a visible focus
ring (foundation `:focus-visible` styles, drawn inset on the plot), and
never trap Tab.

## Screen-reader narration (NVDA + VoiceOver)

- Every announcement carries the quantity name and unit: "Time shift 37
  days. Distance modulus m minus M 33.2 magnitudes.", "Reference bar.
  Absolute magnitude minus 16.0, apparent magnitude 17.2.", "Distance d
  equals 4370 parsecs." Never a bare number.
- Announcements happen on commit (pointer release / each key press /
  selection change), not per pointer-move tick.
- The calculator has a visually-hidden formula description and a polite
  live line for the result; the displayed equation is updated through the
  foundation's `klunlShowEquation` with a paired spoken message.
- MathJax (CHTML) exposes math to AT; every math symbol on the page —
  axis variables M_B and m_B, tick numbers, the formula, the results, the
  bar value tags — is real MathJax (right-click opens "Show Math As").

## Color & contrast

- Physics colors kept from the original and used on white:
  red #d02c30 (≈5.0:1) for the absolute-magnitude scale + template curve,
  blue #1d5ef3 (≈5.3:1) for the apparent-magnitude scale + data points.
  Both exceed 4.5:1 for their text labels and 3:1 for graphics.
- Color is never the only signal: both axes are labelled in words
  ("Absolute Magnitude (M_B)" / "Apparent Magnitude (m_B)"), the bar's two
  value tags are also distinguished by side, and all states are available
  as text via the live region/description.
- UI chrome uses the KL-UNL palette custom properties.

## Zoom, reflow, motion

- Body text ≥1.125rem, all sizing in rem/%; layout reflows to a single
  column with no horizontal scrolling down to phone-portrait widths and at
  200% zoom (the plot scales, preserving the original 460×325 internal
  coordinates; labels are HTML so they zoom crisply).
- Touch targets ≥44px (2.75rem) for the checkbox row, select, inputs and
  both drag surfaces; `touch-action: none` only on the drag surfaces.
- The sim has **no autonomous animation** (nothing moves unless the user
  drags), so no Pause control is required; `prefers-reduced-motion`
  still zeroes any incidental transitions. Nothing flashes.

## Known limitations / notes for human QA

- The 2-D drag surface uses `role="application"`; NVDA switches to focus
  mode on it automatically, but a human pass should confirm the
  arrow-key experience in NVDA (Chrome + Firefox) and VoiceOver (Safari +
  Chrome), including that announcements are not duplicated.
- The right-axis apparent-magnitude tick labels re-typeset ~0.2 s after a
  drag settles (they render instantly as plain text in the same font in
  the meantime) — confirm this is not disruptive with AT.
- Automated checks cannot replace human screen-reader QA; please test the
  full flow (select supernova → drag to fit → read modulus → calculator)
  with NVDA and VoiceOver before release.
