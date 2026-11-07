# Accessibility Notes — Phase Positions Demonstrator

Target: WCAG 2.1 AA (AAA where reasonable). Human screen-reader QA on both **NVDA**
(Windows) and **VoiceOver** (macOS/iOS) is still required — the notes below
describe what was built and mentally tested, not a substitute for that QA.

## Structure & landmarks

- One `<h1>` — the simulation title, rendered by `<kl-unl-masthead>` (the sim adds
  no competing `h1`).
- `<main>` wraps the two-column layout. Panels are `<section>`s with
  `.panel__heading` `<h2>`s; each phase disc has an `<h3>` title. Headings do not
  skip levels.
- `<html lang="en">`.

## The two draggable planets (mouse + keyboard)

Each planet is a canvas-painted disc with an invisible focus proxy
(`.sim-planet-handle`, `role="application"`, `tabindex="0"`) tracking its on-screen
position. Both input paths mutate the same `state` via the same
`setPlanetPosition`, so they can never diverge.

- **Tab to focus** — each handle is in the tab order with a visible focus ring.
- **Click/tap to focus** — `pointerdown` on a disc calls `.focus()` on its handle,
  so the arrow keys work immediately after a click, no Tab needed.
- **Arrow keys** move the planet by 2 stage units (Left/Right = x, Up/Down = y,
  screen-up = −y).
- **Shift + arrow** keeps the planet in its current circular orbit (reproduces the
  original's `Key.isDown(16)` shift-drag), i.e. it rotates the planet around the
  star.
- **Page Up / Page Down** rotate the planet a coarse 15° step around the star.
- **Home / End** snap to the nearest allowed orbit (minimum star separation) /
  farthest allowed orbit along the current bearing.
- `role="application"` is used so NVDA/JAWS forward the arrow keys to the handler.
  Only the movement keys are `preventDefault`-ed; **Tab always escapes normally**
  (no keyboard trap).
- On commit (key release / drag end) the live region announces the planet's polar
  position **with units** and both discs' phases (see below). Announcements are
  debounced (~350 ms) so holding a key or dragging yields one settled message, not
  a flood.

## Units are always spoken

The sim uses arbitrary stage coordinates, so positions are announced as an **angle
in degrees** (measured counter-clockwise from the right / east) and a **distance in
units** from the star — e.g. *"Planet 1 at angle 58 degrees, distance 189 units
from the star."* Each handle's `aria-label` is kept in sync with this text. No bare
numbers are exposed: the degree and percent glyphs are never relied on for speech;
the spoken forms spell the words out.

## Diagram descriptions (audio-only users)

- The orbital-view canvas is `role="img"` with an `aria-describedby` region that is
  continuously updated: it states both planets' positions and whether orbit circles
  are shown.
- Each phase-disc canvas is `role="img"` labelled by its `<h3>` title and described
  by a live region giving the phase name, **percent illuminated**, and which limb is
  in shadow — e.g. *"planet 1 as seen from planet 2: gibbous, 87 percent
  illuminated, with the right side in shadow."* When a disc is hidden it says so.
- A single polite `role="status"` live region carries committed state changes
  (moves, snapping to/from a moon, toggling orbits, hide/show, reset).

## Math via MathJax

- The illuminated-fraction relationship `f = (1 + cos α)/2` and each disc's live
  percentage are typeset by MathJax (via the foundation's `klunlShowEquation`),
  never as images or ASCII. Right-clicking any of them opens the MathJax menu
  (*Show Math As → TeX / MathML*); the context menu is not disabled.
- Each equation is paired with an `.sr-only` spoken description that is
  units-complete.
- Typeset math is **display-only**: it is not in the tab order. MathJax v3 doesn't
  add `tabindex` by default, but as a belt-and-braces measure the sim sets
  `tabindex="-1"` on every `mjx-container`/`svg` it produces after each update.

## Colour & contrast

- The physically meaningful disc colours are kept (planet 1 pink, planet 2 lavender,
  matching each planet's dot), but **state is never encoded by colour alone**:
  planet identity is also given by the visible "1" / "2" HTML labels and by every
  `aria-label`/description; phase is given by name + percent + shadowed-side text.
- Panel chrome, focus rings, and buttons use the KL-UNL palette variables (≥ 4.5:1
  text, ≥ 3:1 focus indicators). No original Flash colours are hardcoded into the
  chrome. The "1"/"2" labels are white with a dark text-shadow for contrast over
  either disc colour.

## Keyboard: only interactive things are tab stops

Tab lands only on: the two planet handles, the **show orbits** checkbox, the two
**hide/show** buttons, and the masthead's Reset / Help / About. Typeset math, the
"1"/"2" labels, readouts, disc titles, and all canvases are **not** tab stops
(exposed to AT via labels/live regions instead). The **show orbits** checkbox and
each hide/show button meet the 44 px touch-target minimum.

## Motion / reduced motion

The original has **no animation loop** — it only redraws in response to user input.
There is therefore no continuous motion, nothing flashing, and no Pause control is
needed. `prefers-reduced-motion` has nothing to suppress; the sim already never
moves on its own.

## Zoom / reflow / touch

- Body copy is ≥ 1.125 rem, sized in rem/em so it tracks the browser font setting.
  The layout reflows without clipping at 200% zoom and collapses from two columns to
  a single stacked column (orbital view, then Disc Appearances) at narrow / phone-
  portrait widths — no horizontal scrolling.
- Canvases keep their original internal coordinates and scale via CSS with preserved
  aspect ratio; pointer coordinates are mapped back through the scale, so drag and
  moon-snapping stay pixel-accurate at any size. `touch-action: none` on the
  canvas keeps a drag from scrolling/zooming the page on touch devices; no affordance
  depends on hover.

## Known limitations

- At the very narrowest phone-portrait widths (≈ 375 px and below) the page can
  scroll horizontally by about 5 px. This originates entirely inside the shared
  `<kl-unl-masthead>` component's shadow DOM — its Reset / Review Help Guide /
  About button row is slightly wider than the viewport before "Review Help Guide"
  shortens to "Help" on first use. The masthead is a foundation file that must not
  be edited, and shadow-DOM encapsulation prevents the sim's stylesheet from
  reflowing it; clipping the host would cut off a control, which is worse. The sim's
  own content (canvases, controls, discs) fits without overflow at these widths.
- `role="application"` on the planet handles is the pragmatic choice for a
two-dimensional drag target (there is no standard 2-D range widget). It means NVDA/
JAWS treat each handle as an application region while focused. This was chosen over
a pair of x/y sliders to preserve the original's free 2-D dragging; the trade-off
should be confirmed in live screen-reader QA.
