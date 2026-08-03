# Accessibility Notes — Paths of the Sun Demonstrator

Target: WCAG 2.1 AA (AAA where reasonable). **Human screen-reader QA is still
required** — this documents the affordances built in; it is not a substitute for
testing with NVDA (Windows) and VoiceOver (macOS/iOS).

## Structure & landmarks
* One `<h1>` only: rendered by the `<kl-unl-masthead>` component (the sim does
  not add a competing `<h1>`). Panels use `<section>` with `<h2>` headings
  ("Horizon Diagram", "Settings"). `<main class="app-shell">` is the main
  landmark. `<html lang="en">`.

## Keyboard
| Control | Keys |
|---|---|
| Latitude (slider) | native `<input type="range">` — Left/Down −0.1°, Right/Up +0.1°, PageUp/PageDown larger step, Home/End = −90 / +90 |
| Latitude (type a value) | editable text field — type a number and press Enter (or Tab/click away). Accepts `41`, `23.5 S`, `-23.5`, `19.5° N`; out-of-range values clamp to ±90°, invalid input reverts. Stays in sync with the slider both ways. |
| Animate | checkbox — Space toggles |
| Rotate view | focus the diagram (Tab or click the sphere), then Arrow keys (Left/Right = azimuth, Up/Down = altitude, clamped 7–90°) |
| Move the sun (day of year) | click/drag the sun, or press Enter on the focused diagram to switch the arrow keys to the sun: Left/Down −1 day, Right/Up +1 day, PageUp/PageDown ±1 week, Home/End = ends of the year. Press Enter again to return to rotating the view. |
| Reset / Help / About | masthead buttons (the component manages the dialog, focus trap, and Escape) |

All controls are reachable in a logical tab order with a visible focus ring
(from `kl-unl.css` `:focus-visible`). The diagram canvas is `tabindex="0"`; Tab
moves away from it normally (no keyboard trap). The pointer-drag rotation and the
arrow-key rotation mutate the **same** state, so mouse, touch, and keyboard stay
in sync.

## Screen-reader narration — units always spoken
A visually-hidden `aria-live="polite"` status region (`#sr-status`) announces
state changes **on commit** (not on every tick) with full quantity + unit:
* Latitude change → "Latitude 41.0 degrees north."
* Animate → "Animation stopped on April 14." / "Animation started."
* View rotation → "View rotated. Azimuth 195 degrees, altitude 35 degrees."
* Reset → "Simulation reset to latitude 41.0 degrees north on March 21."

The latitude slider carries a units-complete `aria-valuetext` (e.g.
**"41.0 degrees north"**, "23.5 degrees south") so the value is never read as a
bare number. The date readout has an `.sr-only` companion ("Date: March 21").

**Diagram description.** Because a `<canvas>` is not accessible on its own, a
continuously-updated, visually-hidden description (`#canvas-desc`,
`aria-describedby` on the canvas) states what the diagram currently shows, e.g.:
> "Horizon diagram for latitude 41.0 degrees north on March 21. Sun's
> declination 0.0 degrees. The sun is up at altitude 49 degrees, toward the
> south."
This gives an audio-only user the same "what's happening" a sighted user sees,
updated from the single `render()`/state path. The on-canvas N/E/S/W labels are
kept upright with a contrasting outline for legibility, and the cardinal
directions (north, east, …) are also spoken here for audio-only users.

## Colour & contrast
* No information is conveyed by colour alone. The legend names **both** the
  colour and the feature ("yellow – sun's path on the given day"), and the
  on-canvas circles are also identified in the diagram description.
* Legend swatches on the white panel use contrast-safe colours and meet ≥3:1
  for graphical objects; each swatch is paired with a text label that names both
  the colour and the feature, so the swatch colour is never the only signal. The
  swatches mirror the diagram's line styles (all solid, matching the source). The
  panel/control palette comes from the KL-UNL CSS variables (≥4.5:1 body text).
* The great-circle colours **on the canvas** are kept faithful to the original
  (they sit on the coloured sky/ground dome, not on white). The original
  "celestial equator" colour is a dark gray (`#505050`, labelled "black"); it is
  the source's own choice and is supplemented by the text legend and the spoken
  description so colour is never the sole signal.

## Motion
* The only continuous motion is the optional **animate** loop, which the user
  starts and stops with the checkbox (an always-available pause), satisfying
  2.2.2. Nothing flashes more than 3×/second.
* `prefers-reduced-motion: reduce` is honoured: when set, checking **animate**
  advances a **single day** (an instantaneous state change) and re-clears the
  box instead of running the continuous animation, with an announcement.

## Text size & reflow
* Body copy is ≥ 1.125rem and all sizing is in rem/em, so it tracks the browser
  font setting. The layout reflows without clipping at 200% zoom and collapses
  from the desktop/iPad two-column layout to a single stacked column at narrow /
  phone-portrait widths (no horizontal scrolling). Touch targets are ≥ 44px.
* The canvas keeps the original internal stage coordinates and is scaled by CSS
  with its aspect ratio preserved; pointer coordinates are mapped back through
  the scale factor so drag/rotation math matches the source at any size. No
  hover-only affordances.

## Mathematics
This demonstrator has **no equations or math notation** (only the degree-unit
symbol, spoken as "degrees"). MathJax is therefore not used (and the foundation
does not bundle it; a CDN is disallowed). If math is added later, route it
through the foundation's `kl-unl.js` (`klunlShowEquation`) with a units-complete
spoken description, per the pipeline rules.

## Known items for human QA
* Verify NVDA and VoiceOver both read each control's name + value + unit and that
  live announcements are not duplicated/truncated.
* Confirm the diagram description is announced at a comfortable cadence during
  latitude changes and after animation stops.
