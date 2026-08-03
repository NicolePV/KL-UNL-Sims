# Accessibility — Declination Ranges Simulator

Target: WCAG 2.1 AA (with AAA where it was reasonable). The original Flash
simulation had no keyboard path, no text alternatives and no screen-reader
support at all; everything below is new.

## Structure and semantics

* One `<h1>`, rendered by `<kl-unl-masthead>` from `contents.json`. The sim adds
  no competing `h1`; each panel is a `<section>` with an `<h2>` referenced by
  `aria-labelledby`, so the heading order is h1 → h2 with no skips.
* Landmarks: `<main class="app-shell">`, `<header>`/`<nav>` from the masthead,
  three `<section>` panels. The three declination ranges are a `<dl>`, which is
  what they are — terms and their values.
* `<html lang="en">`.
* Reading order matches the visual order: diagram, latitude control,
  declination ranges.

## Text alternatives (1.1.1)

* The `<canvas>` is `aria-hidden="true"` — it is the visual layer only.
* `#sky-desc` is a visually hidden description of what the diagram currently
  shows, rewritten from `render()` on every change, e.g. *"Edge-on view of the
  celestial sphere for an observer at latitude 41 degrees north. Circumpolar
  declinations: plus 49 degrees to plus 90 degrees. …"*
* The decorative overlays (tick labels, `NCP`/`SCP`/`NP`/`SP`/`CE`) are
  `aria-hidden="true"`; their information is carried by `#sky-desc` and the
  range readouts instead of being read twice.
* Each range readout has a visible MathJax value plus an `.sr-only` twin with
  units spelled out.

## Units are always spoken (explicit supervisor requirement)

No number is ever announced bare.

| Control / readout | What a screen reader says |
| --- | --- |
| Latitude slider | `aria-valuetext` — "41 degrees north", "0.6 degrees south", "0 degrees" |
| Latitude box | `aria-label` "Observer's latitude in degrees, positive north", plus a description explaining the sign convention and the step. It shows signed degrees on screen, but is announced in the original's magnitude-plus-hemisphere form |
| Horizon-line handle | `aria-valuetext` — "Latitude 41 degrees north" |
| Circumpolar / Rise and set / Never rise | "plus 49 degrees to plus 90 degrees", or "None" |
| Live region | "Latitude 41 degrees north. Circumpolar plus 49 degrees to plus 90 degrees. Rise and set …" |

Units are spelled as words ("degrees", "north", "south"), never left to the `°`
glyph or to a visually adjacent label. `+` and `−` become "plus" and "minus" so
signed declinations are unambiguous in audio.

The latitude box is the one place where the spoken form deliberately differs from
the visible one: it *shows* −24.7 (a number input has to be signed to step across
the equator) but *announces* "24.7 degrees south", which is both the original's
wording and less ambiguous in speech than a minus sign.

## Live region

`#sr-status` is `aria-live="polite"` and `.sr-only`. It is updated **on commit
only** — pointer release, `change`, a keyboard step, toggling Enlarge Earth,
Reset — never on every drag tick, so it does not flood the buffer.
`aria-live="assertive"` is not used; nothing here is urgent.

## Keyboard

The tab order contains exactly four stops, all of them operable controls:

1. `#observer-handle` — the horizon line
2. `#lat-number` — the editable latitude box
3. `#lat-slider`
4. `#enlarge-check`

Nothing else is focusable: typeset maths, readouts, labels, the sky marks and
the canvas have no `tabindex="0"`.

| Control | Keys |
| --- | --- |
| Horizon line handle | ←/↓ −1°, →/↑ +1°, PageDown/PageUp ∓10°, Home −90°, End +90° |
| Latitude slider | native range behaviour: arrows, PageUp/PageDown, Home/End |
| Latitude box | ↑/↓ ±0.1° (native), PageUp/PageDown ±10°, Home/End to the limits, **and mouse wheel ±0.1° while focused**. Values outside −90…90 are clamped on commit |
| Enlarge Earth | Space |

Every draggable thing is also **click-to-focus**: `pointerdown` on the horizon
line calls `.focus()` on the handle, so after clicking it the arrow keys work
without tabbing first. Both paths write to the same `state` object, so keyboard,
pointer and slider never disagree. Tab always moves away normally — there is no
keyboard trap, and the masthead dialog manages its own focus.

Focus is visible everywhere: the foundation's `:focus-visible` ring, plus an
explicit high-contrast ring and a translucent fill on the handle, since it sits
on a dark canvas where the default ring alone would be easy to miss.

## Colour and contrast

The three band colours are the original's, unchanged:

| Band | Colour | Contrast on the `#333333` stage |
| --- | --- | --- |
| Circumpolar | `#ff9900` | 5.4 : 1 |
| Rise and set | `#33ccff` | 7.0 : 1 |
| Never rise | `#33cc66` | 5.9 : 1 |

All three clear 3 : 1 for graphical objects (1.4.11) and in fact clear 4.5 : 1.
The dark stage background was kept for exactly this reason — on the KL-UNL white
panel background these three colours would land at 1.8–2.4 : 1 and fail.

**Colour is never the only signal.** In the ranges panel each row carries a
colour swatch *and* a text label ("Circumpolar:", "Rise and Set:", "Never Rise")
*and* its numeric declination limits, so the three bands are distinguishable
without perceiving colour at all. The swatch is drawn as the band colour over the
same dark background it has on the canvas, so the chip matches what is on screen.

Panel text uses the foundation's palette variables (`--foreground-color` on
`--background-color`, 16.9 : 1). The white overlay labels on the dark stage are
well above 4.5 : 1.

## Text size and zoom

* Body copy is `1.125rem`, above the 1.125rem floor, and everything is sized in
  `rem`/`em`/`%`, so it tracks the browser font setting.
* Verified at a 640px effective width (≈200% zoom on a 1280px viewport): no
  horizontal scrolling, no clipping, no overlap. There are no fixed pixel heights
  that could crop text.
* The canvas keeps its original 450 × 450 internal coordinates and is scaled by
  CSS with the aspect ratio preserved, so the physics never has to know the
  display size. All the text over it is HTML and zooms with the page.

## Mathematics

Every number, sign, degree symbol and expression in the interface is typeset by
MathJax (`tex-svg`, bundled locally) — the 20 declination tick labels, the
latitude readout, the slider's end labels, the degree unit on the number field,
and all three range readouts. Right-clicking any of them opens MathJax's own
"Show Math As…" menu; that menu is neither disabled nor intercepted.

MathJax's `tex-svg` output puts `tabindex="0"` on every `<mjx-container>`, which
would drop display-only mathematics into the tab order. `stripMathTabStops()`
resets these to `tabindex="-1"` after each typeset pass — the context menu still
works, and the maths stays readable to screen readers through the paired
`.sr-only` descriptions. Verified: 30 typeset containers, 0 in the tab order.

## Motion and timing

The simulation has no free-running animation — every redraw is the direct result
of a user action — so there is nothing that runs for more than 5 seconds, nothing
that flashes, and no Pause control is needed (2.2.2, 2.3.1). A
`prefers-reduced-motion` guard is present in `styles.css` in case a transition is
added later.

Reset is the masthead's own button; the sim listens for its `sim-reset` event and
restores latitude 41° N with the Earth un-enlarged — the exact initial state. No
second Reset button was added.

## Touch and pointer

Pointer Events are used throughout, so mouse, pen and touch share one code path.
`touch-action: none` on the diagram stops a drag from scrolling the page.
Nothing is hover-only. Interactive targets measured at 375 px width:
handle 44 × 44, slider 343 × 44, number field 96 × 44, checkbox 24 × 24 inside a
44 px-tall clickable row.

The foundation sizes checkboxes at 1.25rem (20 px), below the 24 px minimum, so
`styles.css` nudges this one to 1.5rem. The foundation file itself is unchanged.

## Forms

Every input has a real `<label>` (`for`/`id`). The number field and the handle
have `aria-describedby` help text explaining the sign convention and the key
map.

## What still needs human QA

Automated and scripted checks cannot substitute for a person with a screen
reader. Still outstanding:

* **NVDA on Windows** (Chrome and Firefox) and **VoiceOver on macOS** (Safari and
  Chrome), plus **VoiceOver on iOS**: confirm the live-region wording is read
  once, in order, and is not truncated; confirm the slider announces name, value
  and unit on focus and on each step.
* Confirm the MathJax context menu opens on the typeset values in Safari.
* Confirm the drag works with VoiceOver's cursor active, and with a switch device.
* Real-device testing on iOS Safari and Android Chrome for the pointer drag and
  the pinch-zoom interaction with `touch-action: none`.
* A visual check in each target browser: this port was verified numerically and
  geometrically (pixel sampling of the canvas, bounding-box measurements at
  desktop, tablet and phone widths), because the development environment could
  not produce screenshots.
