# Accessibility — Sun's Position on Horizon

Target: WCAG 2.1 AA (ADA Title II), with AAA where it came cheaply.

## Structure

* One `<h1>` — the simulation title, rendered by `<kl-unl-masthead>`. The page
  adds only `<h2>` panel headings ("Horizon View", "Controls"), so the outline
  does not skip levels.
* Landmarks: `<main>` wrapping the two `<section>` panels; the masthead supplies
  its own `<nav>`. `<html lang="en">`.
* A visually-hidden skip link jumps past the scene to the controls.

## Text alternatives

The scene is a single `<svg role="img">` with `aria-labelledby` pointing at its
own `<title>` and `<desc>`, both rewritten by `render()` on every state change:

* **title** — "Sunrise view toward the eastern horizon" / "Sunset view toward
  the western horizon".
* **desc** — the current date plus where the sun is, in words, e.g.
  *"June 20. The sun rises 100 percent of the way from due east toward the north
  end of the horizon."*

Because the SVG is `role="img"`, its internal text ("East", "To North", the date)
is not announced separately, so nothing is read twice.

A `role="status" aria-live="polite"` region announces committed changes: view
switches, slider commits, play/pause, and reset. While the animation runs it
speaks at most once every two seconds so it informs without flooding. Nothing is
announced per animation frame.

## Units are always spoken

Every announced value carries its quantity and its unit:

* Date slider — `aria-valuetext` is *"June 20, day 92 of 366"*, never a bare
  number.
* The live region and the scene description use *"… percent of the way from due
  east toward the north end of the horizon"* rather than a raw offset.
* The visible readout beside the slider shows the same date string, so audio and
  visual users hear and see identical wording.

## Colour and contrast

The original painted its captions in white directly on the pale sky gradient —
roughly **2.2:1**, well under the 4.5:1 minimum. Two different fixes, chosen by
whether the text has to stay anchored to the diagram:

| Element | Original | Now |
| --- | --- | --- |
| Caption ("Position of the sun on the horizon at …") | white on sky, ~2.2:1 | moved out of the artwork into an HTML paragraph in the foundation's text colour on the panel background (~16:1) |
| "East" / "West", "To North" / "To South" | white on sky, ~2.2:1 | kept in place, kept white, given a `#241a2e` halo via `paint-order: stroke` → **16.6:1** against the halo |
| Date label | black on sky | unchanged (already high contrast); a white halo was added so it stays legible wherever the sun carries it |

No state is signalled by colour alone. The sunrise/sunset distinction is carried
by the radio labels, the caption text, the "East"/"West" label and the
"To North"/"To South" labels — not by the sky's hue.

The landscape's own silhouette colours are reproduced from the SWF's colour
transforms unchanged; they are decorative scenery, not information.

## Keyboard

Full operation, in this tab order and nothing else:

1. skip link → 2. East/Sunrise radio → 3. West/Sunset radio → 4. date slider →
5. Month select → 6. Day field → 7. Play/Pause button. (Plus the masthead's own
Reset / Help / About.)

| Key | Effect |
| --- | --- |
| ←/↓ and →/↑ on the slider | one day |
| Page Up / Page Down on the slider | ten days |
| Home / End on the slider | ends of the year |
| Mouse wheel over the focused slider | one day per notch |
| ↑/↓ on the Day field | one day |
| Page Up / Page Down on the Day field | ten days |
| Home / End on the Day field | first / last day of the month |
| Mouse wheel over the focused Day field | one day per notch |
| ↑/↓ or a letter key on the Month select | change month |
| Space / Enter on Play | start / stop the animation |
| ↑/↓ or ←/→ on the radios | switch view |

The date slider is a native `<input type="range">` and the day field a native
`<input type="number">`, so arrow-key behaviour is the browser's own and cannot
get stuck; Tab always moves away normally. Page Up/Down and Home/End are added
to the day field, which browsers do not provide natively, so both numeric
controls answer to the same key set. Both wheel handlers call `preventDefault()`
only while their own control has focus, so the page still scrolls otherwise.

Typing a date is fully validated: the day is clamped to the selected month's
length (choosing February after "January 31" lands on February 29 — the month
table in the source treats February as 29 days), out-of-range and empty entries
are corrected rather than rejected silently, and every route — slider, month,
day, wheel, animation, Reset — writes through the same `setDay()` state path, so
the fields, the slider, the readout, the scene and the announcements can never
disagree.

Verified programmatically: the tab order contains only those five interactive
controls, there are no `tabindex="0"` attributes anywhere, and the SVG stage
reports `tabIndex === -1`. Static content — the scene, the caption, the readout,
the labels — is exposed through names and live regions, never by being a tab
stop. Focus rings come from the foundation's `:focus-visible` rule.

Nothing here is drag-operable, so the pointer-drag / arrow-key pairing the
pipeline requires for draggable objects does not apply. The date slider provides
the equivalent affordance for the one continuously variable quantity.

## Motion

* The animation **never autoplays** — the simulation loads paused, so WCAG 2.2.2
  is satisfied without needing a stop control beyond the Play/Pause toggle that
  is already there.
* Nothing flashes; the scene changes smoothly and slowly (a full year takes
  14.6 s).
* `prefers-reduced-motion: reduce` reduces the sampling rate to ~4 updates per
  second instead of every frame. Because `_day` is integrated from elapsed
  wall-clock time rather than from a frame count, the date shown at any given
  instant is identical either way — only the smoothness changes, so no behaviour
  is altered.
* The date slider gives a completely motion-free way to explore the whole year.

## Touch and pointer

* All controls are native, so mouse, touch and stylus share one code path; no
  hover-only affordances exist.
* Measured at a 375 px viewport: Play button 337 × 44, slider 337 × 44, each
  radio row 337 × 44, the radio inputs themselves 24 × 24, the month select
  110 × 44, the day field 60 × 44, the help disclosure 337 × 55 — all at or
  above the 44 px comfortable target, and above the 24 px WCAG 2.5.8 minimum for
  the controls themselves.
* The day field carries `inputmode="numeric"`, so touch keyboards open on digits.

## Zoom and reflow

* Body text is 1.125 rem with headings and labels scaled from it; everything is
  sized in rem/em so it tracks the browser font setting.
* The scene is inline SVG with a `viewBox`, so it stays sharp at any zoom rather
  than softening the way a rasterised canvas would.
* Measured `scrollWidth === clientWidth` at 375 px, 485 px, 737 px and 1249 px —
  no horizontal scrolling, and an element-by-element sweep found nothing
  overflowing the viewport at any of those widths.
* Below 48 rem the controls collapse to a single column; the foundation's own
  56 rem panel collapse is left intact.

## Known limitation

The "East" / "West" and "To North" / "To South" labels live inside the scene
because they label positions *on the horizon* — detaching them would destroy
their meaning. They therefore shrink with the scene on a narrow phone. The
information they carry is duplicated in text that does not shrink: the caption,
the date readout, and the live-region description ("… toward the north end of
the horizon").

## Still required

**Human screen-reader QA has not been performed.** The behaviour above was
verified by inspecting the accessibility properties in the DOM, not by listening.
Before release this should be exercised with **NVDA on Windows** (Chrome and
Firefox) and **VoiceOver on macOS** (Safari and Chrome), checking in particular
that announcements are not duplicated or truncated, that the live region does
not talk over itself while the animation runs, and that the masthead dialog's
focus handling behaves with the sim's own controls.
