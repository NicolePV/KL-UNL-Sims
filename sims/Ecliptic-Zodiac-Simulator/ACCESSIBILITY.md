# Accessibility notes — Ecliptic (Zodiac) Simulator

Target: WCAG 2.1 AA, with AAA where it came cheaply.

## Structure

* One `<h1>`, rendered by the `<kl-unl-masthead>` component from
  `contents.json`. The page adds no competing `h1`.
* `<main>` holds three `<section class="panel">` landmarks, each labelled by its
  own `<h2>`: *Zodiac view*, *Date and view*, *Position of the Sun*. No heading
  levels are skipped.
* `<html lang="en">`. A visible-on-focus skip link jumps past the diagram to
  the controls.
* Reading order matches the visual order: picture → timeline → date and view →
  Sun readouts.

## Text alternatives for the picture

The `<canvas>` is `aria-hidden`; its wrapper carries the accessible name and
description instead, so nothing is announced twice.

`#stage-desc` is rebuilt from the same `state` object the canvas is drawn from,
on every change, and reads for example:

> Day 0 of the year, January 1. Earth sits at the centre of the zodiac band; the
> Sun is on the band at right ascension 18 hours 46 minutes, declination minus
> 23.1 degrees, closest to the Sagittarius label, 8 degrees away. The view looks
> along azimuth 154 degrees from an elevation of 30 degrees. Constellations on
> the near side of the band: Scorpius, Sagittarius, Capricornus, Aquarius,
> Pisces.

That last sentence is what a sighted user gets from the picture and an
audio-only user would otherwise lose: which constellations are currently facing
them.

## Live region

`#sim-status` is an `aria-live="polite"` `.sr-only` element. It is updated **on
commit** — pointer release, key release, a slider's `change` event — never on
every drag tick, and updates are coalesced through a short timer so rapid
changes do not flood the screen reader. Its wording is the same sentence as the
description above, so on-screen and spoken text stay consistent.

## Units are always spoken

Every value that has a unit is announced with the quantity name *and* the unit
spelled out as a word, because a screen reader reads only the accessible name
and value and would drop a symbol or a visually adjacent label:

| Control / readout | What is announced |
| --- | --- |
| day-of-year slider | `aria-valuetext` — "Day 47 of the year, February 17" |
| day-of-year field | "day of year", with a visible "days" unit beside it |
| month / day of month | "Month" and "Day of the month", grouped under "calendar date" |
| azimuth slider | `aria-valuetext` — "View azimuth 154 degrees" |
| azimuth field | "azimuth", with a visible "degrees" unit beside it |
| elevation slider | `aria-valuetext` — "View elevation minus 12 degrees" |
| elevation field | "elevation", with a visible "degrees" unit beside it |
| right ascension | "right ascension, 18 hours 46 minutes" |
| declination | "declination, minus 23.1 degrees" |
| nearest label / angle | "nearest label, Sagittarius" / "angle from it, 8 degrees" |

Negative values are read as "minus …", not as a hyphen, and singular/plural is
handled ("1 minute", not "1 minutes"). The visual readouts use the same words —
there are no bare degree glyphs anywhere in the interface.

## Keyboard

The tab order contains **only** operable controls, in reading order:

1. skip link
2. the sphere stage
3. day-of-year timeline
4. day-of-year field
5. month, then day of the month
6. azimuth field, then azimuth slider
7. elevation field, then elevation slider

Nothing else is focusable: the typeset equation, the readouts, the labels and
the canvas have no `tabindex="0"`, and MathJax's own `tabindex` on its SVG
container is reset to `-1` after typesetting (its right-click menu still works).

| Control | Keys |
| --- | --- |
| Sphere stage (equivalent of dragging) | ←/→ swing the view 1° in azimuth, ↑/↓ change elevation 1°, Shift + arrow or PageUp/PageDown 15°, Home/End jump to the elevation limits |
| Sliders | ←/↓ decrement, →/↑ increment, PageUp/PageDown larger step, Home/End minimum/maximum (native `<input type="range">` behaviour) |
| Number fields | ↑/↓ increment and decrement by one step (native `<input type="number">`); type a value directly and it applies as you type |
| Every slider and number field | mouse wheel up/down adjusts by one step **while focused**, with `preventDefault()` so the page does not scroll |

Values are clamped to their range when a field is committed, and the day of the
month is clamped to the length of the selected month (typing 31 in February
gives 28). While you are typing in a field the code deliberately does not
rewrite that field — only that one — so the caret is never moved out from
under you; every other control still updates live.

The stage is focused by clicking or tapping it as well as by tabbing, so the
arrow keys work immediately after a click. Canvas pointer handlers do not
swallow focus or key events, Tab always moves away normally, and there is no
keyboard trap. The focus ring is the foundation's `:focus-visible` outline; on
the timeline it is drawn around the whole strip rather than the invisible thumb.

Pointer and keyboard write the same state object, so the picture, the readouts
and the announcements can never drift apart.

## Colour and contrast

The chrome uses the KL-UNL palette variables — no colours are hard-coded from
the Flash original. Inside the picture the original astronomical palette is kept
(a dark sky, a pale zodiac band, `#dfdfdf` stick figures and labels), because
the day/night shading of the band and of the Earth is the point of the
simulation. **No state is signalled by colour alone**: the date, the viewing
direction and the Sun's position are all given as text and as spoken values, so
the picture is never the only way to read the simulation's state. No colours
were remapped.

## Motion and timing

The original has no animation: every change is the direct result of a user
action, so there is nothing that runs for more than five seconds, nothing that
flashes, and nothing that needs a Pause control. A
`prefers-reduced-motion: reduce` block neutralises any incidental transition
anyway. Reset comes from the masthead's `sim-reset` event and restores the exact
initial state (day 0, azimuth 154°, elevation 30°); the page adds no second
Reset button.

## Zoom and reflow

Body text is 1.125 rem and everything is sized in rem/%/fr, so it tracks the
browser's font setting. The layout is checked at 375 px wide and at 200 % zoom
(a 640 px CSS viewport): no horizontal scrolling, no clipped or overlapping
text. At phone-portrait widths the panels stack into one column and each label
sits above its own full-width readout. Touch targets are at least 44 px, and
nothing is revealed by hover only.

## Equations

The one displayed formula is typeset by MathJax through the foundation's
`klunlShowEquation`, with a paired `.sr-only` sentence describing it in words
("…a sub Earth equals minus 360 degrees divided by 365, times the quantity N
plus 10.8, where N is the day of the year…"). MathJax's context menu is left
enabled and is not intercepted.

## Known limitation

The constellation labels (*Leo*, *Cancer*, …) are drawn on the canvas rather
than as HTML. They are pinned to points on a rotating three-dimensional sphere,
are foreshortened and flipped as the sphere turns, and have no meaningful
position in the document, so they cannot be lifted into an HTML overlay without
losing the geometry that makes them readable as part of the picture. Their
content is not lost: every label currently facing the viewer is named in the
description and the live region, and the Sun's nearest label is a dedicated
readout. Users who need larger label text can zoom the page — the canvas scales
with it.

## Still to do

Automated checks and a careful manual pass got the page this far, but
**human screen-reader QA is still required**: NVDA on Windows (Chrome and
Firefox) and VoiceOver on macOS (Safari and Chrome), plus VoiceOver on iOS for
the touch drag. Confirm in particular that the live region is neither
duplicated nor truncated while dragging, and that each control reads a clear
name, value and unit as focus moves through it.
