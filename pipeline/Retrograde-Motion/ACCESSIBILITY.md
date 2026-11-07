# Retrograde Motion — accessibility notes

Target: **WCAG 2.1 AA** (ADA Title II), with AAA where it came cheaply.
The original Flash sim had no keyboard path, no text alternative, and no
programmatic labels: everything below is new.

## Structure and semantics

- `<html lang="en">`. One `<h1>` only — rendered by `<kl-unl-masthead>` from
  `foundation/contents.json`. The sim adds no competing `h1`.
- `<main>` with two `<section class="panel">` landmarks, each labelled by its own
  `<h2>` (`Diagram`, `Controls`) via `aria-labelledby`. Headings do not skip levels.
- A "Skip to controls" link is the first focusable element.
- Controls sit in a `<fieldset>`/`<legend>` ("Timeline"); the slider has a real
  `<label for>`.
- Reset, Help and About come from the shared masthead component, which owns its
  own dialog, focus trap and Escape handling. The sim only listens for the
  bubbling `sim-reset` event; it builds no masthead, dialog or Reset button of
  its own.

## Text alternatives

- The star field and orbit SVG layers are decorative duplicates of information
  given in text: `alt=""` and `aria-hidden="true"`.
- The canvas is `role="img"` with an `aria-label` naming what it shows, plus
  `aria-describedby="stage-desc"`.
- `#stage-desc` is a visually hidden, `aria-live="polite"` description rebuilt
  from the same `render()` that draws the canvas, so it can never drift from the
  picture. Sample:

  > "Timeline 60 percent. Earth is 129 degrees around its orbit and the superior
  > planet is 100 degrees around its orbit, both measured from the right-hand
  > side. Seen from Earth, the planet appears 68 percent of the way from east to
  > west across the background stars, moving westward."

## Screen-reader narration (NVDA and VoiceOver)

- **Every number is spoken with its quantity name and its unit.** The slider's
  `aria-valuetext` is "timeline *n* percent", never a bare number; the
  description spells out "degrees" and "percent" as words. The visible `%` echo
  next to the slider is `aria-hidden` so the value is not read twice.
- Two polite live regions, both updated only on commit:
  - `#sim-status` — the simulation's own annotation text, verbatim from the
    original. It changes only at the three documented thresholds, so it speaks a
    handful of times across a 21-second run rather than on every frame.
  - `#stage-desc` — the diagram description. Updated when the user commits a
    slider change (`change`, not `input`), on START / STOP / RESTART / Reset, at
    each annotation transition, and when the animation ends.
- `aria-live="assertive"` is not used anywhere; nothing here is an alert.
- The START/STOP button changes its own label rather than relying on state
  conveyed elsewhere, so its accessible name always states what pressing it does.

## Keyboard

Tab order contains **only** operable controls, in this order:

1. Skip link
2. Masthead: Reset, Review Help Guide, About
3. `timeline` slider
4. START / STOP
5. RESTART

Nothing else is focusable: the canvas, the EAST/WEST labels, the legend, the
annotation caption and the hidden description carry no `tabindex`.

| Key | On the timeline slider |
| --- | --- |
| Left / Down | −1 |
| Right / Up | +1 |
| Page Up / Page Down | larger step (native) |
| Home / End | start / end of the timeline |
| Mouse wheel (while focused) | ±1, with `preventDefault` so the page does not scroll |

The original's only draggable object was the timeline marker; it is now a native
`<input type="range">`, which gives pointer, touch and keyboard operation from
one element and one state variable. There is no canvas-draggable object left in
the sim, so no proxy focus target is needed.

Focus is never trapped, never moved without user action, and never removed
mid-interaction — in particular the slider is **not** disabled while the
animation runs (the original blocked it; see CONVERSION_NOTES deviation 2), so a
keyboard user cannot lose focus underneath themselves.

Focus indication is the foundation's `:focus-visible` ring; nothing here
overrides it.

## Colour and contrast

- Body text is the foundation's charcoal on white (≥ 12:1). The sky caption is
  white on black (21:1).
- Graphical elements against the black sky: the green orbit (15.3:1), the blue
  orbit (≈ 13:1) and the magenta sight line (6.7:1) all clear the 3:1 minimum
  for graphical objects. Original colours were kept — they are legible, so no
  remapping was needed.
- **Colour is never the only signal.** The original distinguished the two orbits
  and the sight line by colour alone; a legend now names each one in words
  ("Earth, on the inner green orbit", "superior planet, on the outer blue orbit",
  "sight line from Earth, extended to the background stars"), and the same
  information is in the diagram description.
- The palette comes from the foundation's CSS custom properties; the sky's black
  and the orbit colours are the original art and are declared in
  `styles/styles.css`, never in a foundation file.

## Text size, zoom and reflow

- Body copy is `1.125rem`, sized in `rem`/`em` throughout, so it tracks the
  browser's font setting.
- The desktop layout is two columns (stage | controls), sized so the simulation
  fits one screen without vertical scrolling. It reflows to a single column and
  stays free of horizontal scrolling and clipping at 200% zoom and at
  phone-portrait widths — the height cap that keeps it on one screen is dropped
  once stacked, so nothing is ever squeezed to fit. The foundation's own 56rem
  breakpoint is left intact and matched; the sim adds one 30rem breakpoint of its
  own in `styles/styles.css`.
- Canvas-internal text was eliminated: EAST/WEST are HTML overlays and the
  annotation is an HTML caption, so all text zooms. **No text is baked into the
  canvas.**
- The annotation strip reserves height for two lines so a text change never
  shifts the layout under the pointer.

One reflow exception, and it is not this sim's: at a phone-portrait width
*combined with* 200% text zoom, the shared masthead's non-wrapping flex row
(title + Reset / Help / About) overflows and the page scrolls horizontally. The
simulation's own content measures clean at every width and zoom tested. The fix
belongs in `kl-unl-masthead.js`, which must not be edited here — see
CONVERSION_NOTES, "Known issue, in the foundation rather than this sim".

## Motion and timing

- Nothing moves until the user presses START, and STOP halts it instantly —
  so there is no unrequested motion and no motion the user cannot stop
  (WCAG 2.2.2). STOP is the sim's Pause.
- Nothing flashes; the only animation is smooth planetary motion at well under
  3 changes per second of anything flash-like.
- `prefers-reduced-motion`: the animation is deliberately **not** replaced by a
  jump to its end state, because the motion *is* the lesson — a still frame of
  the final configuration teaches nothing about retrograde motion. Instead, the
  timeline slider is a complete, fully keyboard-operable static path through the
  identical sequence, one step at a time, with the same annotations available at
  each position. A reduced-motion user therefore has an equivalent, motion-free
  route through the whole demonstration and is never shown motion they did not
  ask for.

## Touch

- The slider meets the 44px minimum via the foundation's control sizing plus a
  `min-height: 2.75rem`; the buttons use the foundation `.button` (2.75rem
  minimum) and widen to fill the row on phones.
- No hover-only affordances anywhere.
- `touch-action: pan-y` on the slider keeps horizontal drags with the control
  while vertical scrolling still works; the canvas has no drag behaviour to
  guard.

## Mathematics

This simulation displays no mathematical notation — no equations, variables,
subscripts, Greek letters or units in maths form anywhere in the interface.
MathJax is nonetheless vendored locally and wired to the foundation's
`klunlShowEquation` / `klunlInitEqn` helpers, so that any maths added later is
typeset by MathJax (with its context menu enabled and its output kept out of the
tab order) rather than as plain text or canvas paint.

## Still required

**Human screen-reader QA is still required.** These notes describe what was built
and tested by inspection and by driving the DOM; they are not a substitute for a
real pass with NVDA on Windows (Chrome and Firefox) and VoiceOver on macOS
(Safari and Chrome), listening for duplicated, truncated or out-of-order
announcements — particularly around the two live regions during a full START-to-
finish run. Keyboard-only navigation and 200% zoom should be spot-checked on a
real device as well.
