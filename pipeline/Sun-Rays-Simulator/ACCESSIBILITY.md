# Sun's Rays Simulator — accessibility notes

Target: WCAG 2.1 AA (ADA Title II), built on the shared KL-UNL foundation. The foundation
files are copied in unchanged; every accessibility affordance below lives in this
simulation's own `index.html`, `styles/styles.css` and `simulation.js`.

## Structure and semantics

* One `<h1>` only — rendered by `<kl-unl-masthead>`. The simulation adds `<h2>` panel
  headings ("Earth and the Sun's Rays", "Date and Direct Rays"); the hierarchy does not
  skip a level.
* `<main>` landmark; each panel is a `<section>` labelled by its own heading via
  `aria-labelledby`. The masthead supplies the `<nav>` for Reset / Help / About.
* `<html lang="en">`.
* A "Skip to controls" link is the first focusable element.

## Text alternatives (1.1.1)

* The canvas has `role="img"` with a short `aria-label` and an `aria-describedby` pointing
  at a visually hidden paragraph that is rewritten from `render()` on every state change.
  It states what the diagram currently shows: the marked latitude circles, that the rays
  arrive horizontally from the left, that the far half of the globe is night, the current
  tilt of the ray bundle and which hemisphere the direct rays have moved into, plus the
  date, season and latitude readouts.
* Every diagram label — `NP`, `SP`, `EQ`, `Arctic Circle`, `Tropic of Cancer`,
  `Tropic of Capricorn`, `Antarctic Circle`, `Least Direct`, `Most Direct` — was moved out
  of the canvas into real HTML so it scales with page zoom and is available to assistive
  technology. The label layer itself is `aria-hidden` because the same information is
  carried, in a readable order, by the canvas description; leaving both exposed would
  make a screen reader read the labels twice.
* **Nothing is baked into the canvas as text.** No exception needs recording here.

## Colour and contrast (1.4.1 / 1.4.3 / 1.4.11)

| Element | Original | Port | Reason |
| --- | --- | --- | --- |
| Sun rays | `#ffff00` on `#f3f3f3` (≈1.07:1) | `#ffe000` core in a `#6b5200` casing | The casing gives the ray a 7.4:1 edge against the panel, so the graphic meets 1.4.11 while still reading as a yellow sunbeam |
| Diagram labels | black text painted directly onto the rotating shadow (≈2:1 where the shadow covers them) | black text on an 88%-white plate | Holds ≥ 12:1 whichever side of the terminator the label falls on |
| Globe, latitude lines, night shadow, readout boxes | unchanged | unchanged | Already compliant |

Colour is never the only signal. The night side is identified in the canvas description
and by the live region, not only by being darker; the hemisphere of the direct rays is
always stated in words ("north" / "south"), not just by which way the rays tilt.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)

The original simulation has exactly one interactive control — the Start/Stop button — and
nothing draggable, rotatable or slider-driven. The port has the same single control, so
there is no pointer-only interaction to provide a keyboard equivalent for.

* Tab order: skip link → masthead Reset / Help / About → **Start/Stop**. That is the
  complete list of tab stops; verified programmatically.
* Display-only content is **not** focusable: the canvas, the diagram labels, the two
  readout boxes and the typeset latitude value carry no `tabindex="0"`.
* MathJax v3 stamps `tabindex="0"` on its `mjx-container`. A `MutationObserver` resets it
  to `-1` as each typeset lands, so the readout stays out of the tab order. The MathJax
  context menu still opens on right-click at `tabindex="-1"`, and the menu is not disabled
  or overridden anywhere.
* Focus is never trapped; the masthead dialog manages its own focus and is left alone.
* `:focus-visible` rings come from `kl-unl.css` and are not suppressed.

## Mathematics

* The latitude readout is rendered as LaTeX through the foundation helper
  `klunlShowEquation(['latitude-eqn', …], ['latitude-eqn-sr', …], ['date-sr', …])`, with
  `klunlInitEqn()` redefined in `simulation.js` as required. `\(23.5^{\circ}\,\mathrm{N}\)`
  is typeset by MathJax; right-clicking it opens MathJax's own menu (Show Math As →
  TeX / MathML).
* Each typeset value is paired with a screen-reader string that spells the quantity, the
  number and the unit in full: *"The direct rays hit at latitude 23.5 degrees north."*
* A calendar date is not mathematical notation, so "March 21" is left as plain text.
  There is no other maths anywhere in the interface.

## Screen-reader narration

* A single `aria-live="polite"` region (`#live-region`) carries every committed change.
  Announcements are made on Start, on Stop, on Reset, and — while the animation runs — at
  most once every two seconds, so the region is never flooded frame by frame.
* Units are always spoken with the number and the quantity name, never a bare value:
  * *"Animation started. One year passes every 30 seconds. Date March 21, Vernal Equinox.
    The direct rays hit at latitude 0.0 degrees."*
  * *"Date June 3, Summer Solstice. The direct rays hit at latitude 23.5 degrees north."*
  * *"Animation stopped. Date December 2. The direct rays hit at latitude 22.3 degrees
    south."*
  * *"Simulation reset. Date March 21, Vernal Equinox. The direct rays hit at latitude
    0.0 degrees."*
* The wording of the announcements matches the on-screen readouts, with "degrees north"
  in place of the `°` glyph and `N` so that both NVDA and VoiceOver speak it correctly.
* The canvas description gives an audio-only user the same "what is happening" a sighted
  user gets from the picture, and is updated from the same single `render()`.

## Motion and timing (2.2.2 / 2.3.3)

* The animation never starts on its own; the user starts it, and the same button stops it
  at any moment. (Reset comes from the masthead's `sim-reset` event — no second Reset
  button was added.)
* Nothing flashes. The only repeating change is the smooth rotation of the ray bundle,
  well under 3 Hz.
* `prefers-reduced-motion: reduce` drops the repaint rate to 4 Hz, so the diagram steps
  rather than sweeps. The simulated year still takes 30 seconds and every number is
  unchanged — only the smoothness of the picture is reduced. A cyclic animation has no
  "end state" to jump to, so it cannot be replaced by one.

## Zoom, reflow and responsiveness (1.4.4 / 1.4.10)

* Body copy is 1.125 rem, headings and readouts scale from it, and everything is sized in
  rem / em / % / `cqw`, so the page tracks the browser's font setting.
* Verified with no horizontal scrolling and no clipped or overlapping labels at 1280 px,
  at 640 px (equivalent to 200% zoom on a 1280 px desktop) and at 375 × 812 phone
  portrait. Diagram labels were checked programmatically to stay inside the stage at every
  width.
* Below 40 rem the readout strip collapses to one stacked column in reading order; the
  foundation's own 56 rem collapse is left intact and untouched.
* The diagram label type floors at 0.625 rem on a phone-portrait stage. This is small in
  absolute terms because the whole diagram is scaled down with the viewport; the same
  information is available at full size in the canvas description, and browser zoom scales
  the labels with everything else.

## Targets and pointer

* The Start/Stop button is at least 2.75 rem tall and full-width in the stacked layout, so
  it clears the 44 px touch-target minimum.
* Nothing depends on `:hover`. There is no drag interaction, so no `touch-action`
  suppression is needed anywhere — the page scrolls normally on touch.

## Cross-browser

Only widely supported, standards-based features are used: `<canvas>` 2D, Pointer-free
click handling, CSS grid / flex, `aspect-ratio`, container query units (`cqw`),
`ResizeObserver` and `MutationObserver` — all available in Chrome, Edge, Firefox and
Safari (desktop and iOS). No vendor-prefixed declaration stands alone and no Chrome-only
API is used. MathJax is vendored locally with `fontCache: 'local'`, so its SVG output is
self-contained and renders identically everywhere. Fonts fall back through
`Arial, Helvetica, sans-serif`, which resolves on every target OS.

## Human QA still required

Automated and structural checks cannot substitute for real assistive-technology testing.
Before release this simulation should be exercised with **NVDA** on Windows (Chrome and
Firefox) and **VoiceOver** on macOS (Safari and Chrome) and iOS, checking in particular
that the two-second live-region cadence reads comfortably during the animation, that the
canvas description is announced in a sensible order, and that the MathJax latitude value
is spoken with its units. A visual pass in Safari on macOS and iOS is also recommended.
