# Accessibility — Moon Phases and the Horizon Demonstrator

Target: **WCAG 2.1 AA** (AAA where reasonable). Human screen‑reader QA with real
NVDA (Windows) and VoiceOver (macOS/iOS) is still required before release; this
document records the affordances built in.

## Structure & landmarks

- Single `<h1>` is rendered by the `<kl-unl-masthead>` component (the sim adds
  no competing `h1`). Panel titles are `<h2>` / `<legend>`; heading order does
  not skip.
- `<main>` holds the diagram `<section>` and the controls; each control group is
  a `<fieldset>` with a `<legend>` (General Settings / Sun Settings / Moon
  Settings). `<html lang="en">`.
- A "Skip to controls" link (`.sr-only-focusable`) is the first focusable item.

## Keyboard map

| Control | Keys |
|---|---|
| Diagram (role `application`, focusable) | **←/→** change viewing azimuth (±5°), **↑/↓** change viewing altitude (±5°), **Shift/PageUp/PageDown** coarser (±15°), **Home/End** max/min altitude |
| Latitude slider (native `range`) | ←/↓ decrement, →/↑ increment, PageUp/PageDown larger, Home/End min/max, **mouse wheel** while focused |
| Sun / Moon position sliders (native `range`) | ←/↓ −1, →/↑ +1 **whole positions**, **wraps 1↔8 at the ends** (matching the AS), PageUp/PageDown ±2, Home/End = 1/8, **mouse wheel** while focused |

> The Sun/Moon sliders are continuous under the pointer (`min 0.51`, `max 8.49`,
> matching the original Flash slider, which snaps to a whole position on
> release). **Keyboard operation stays discrete** — arrows always land on one of
> the 8 meaningful positions, so a keyboard or screen-reader user is never
> stranded between positions or forced to make 800 key presses to cross the
> range. `aria-valuetext` reports the whole position ("Sun position 4 of 8")
> rather than the raw fractional value.
| Checkboxes | Space toggles |
| Masthead Reset / Help / About | Enter/Space; dialog traps focus and closes on Esc (handled by the component) |

- **Every draggable object has a keyboard path.** The diagram's click‑drag
  rotation is mirrored by focusing the canvas and using the arrow keys. The
  Sun/Moon disc drags map onto their respective position sliders, which are
  fully keyboard‑operable; clicking a disc also focuses the canvas.
- Only interactive controls are in the tab order. The canvas is a real focusable
  control; static content (readouts, the event/phase text, the live region, the
  visually‑hidden diagram description) has **no** `tabindex="0"`. There are no
  keyboard traps; Tab always moves away normally.

## Screen‑reader narration (units always spoken)

- **`aria-live="polite"` status region** announces every committed change with
  units and context, e.g. *"Sun position 5 of 8. Local solar time 6:00 PM. Moon
  phase Full Moon."*, *"Latitude −30.5 degrees."*, *"View azimuth 205 degrees,
  altitude 35 degrees."* Slider/drag results are announced on commit (on
  `input` and on drag release), not on every intermediate tick.
- **Continuously‑updated diagram description** (visually hidden) gives an
  audio‑only user the same "what's shown" a sighted user sees: viewing
  azimuth/altitude, observer latitude, Sun position + altitude + local solar
  time, and Moon position + phase — each value paired with its unit.
- **Units are never bare numbers.** Every numeric control exposes a
  units‑complete spoken value via `aria-valuetext` (e.g. "Latitude 41.0
  degrees", "Sun position 4 of 8") or an associated `<label>`; angles are spoken
  as "degrees", positions as "N of 8", time in 12‑hour clock form. Coordinate‑
  like values (azimuth **and** altitude) are announced together, each labelled.

## Colour & contrast

- Uses the KL‑UNL palette variables for all chrome; sim text is dark
  (`#1a1a1a`/`#333`) on white, ≥4.5:1.
- **State is never conveyed by colour alone.** The Moon phase is given by name
  ("First Quarter") as well as the illuminated disc; the time is text; the
  position markers carry visible numbers; every checkbox has a text label.
- Diagram colours reuse the original physically‑meaningful scheme (green ground,
  yellow Sun, grey Moon, blue pole axis, pale equator) and are supplemented by
  text/number/shape cues, so no information is lost to colour‑blind users.

## Motion

- No continuous/auto animation. The only motion is the ≤200 ms slider
  snap‑tween after a Sun/Moon drag; it is **skipped entirely under
  `prefers-reduced-motion: reduce`** (the value jumps to its final state).
  Nothing flashes.

## Zoom, reflow, touch

- Body copy is ≥1.125rem, sized in rem/em so it tracks the browser font setting;
  layout reflows without clipping at 200% zoom and down to phone‑portrait
  (single stacked column, no horizontal scroll).
- The canvas keeps its original 400×400 internal coordinate system and is scaled
  by CSS with a fixed aspect ratio; pointer coordinates are mapped back through
  the scale so hit‑testing and drag maths stay exact at any size.
- Pointer Events unify mouse/touch; `touch-action: none` on the canvas prevents
  the page scrolling during a drag. Interactive targets meet the ≥44 px
  (2.75rem) minimum. No hover‑only affordances.

## Canvas text alternatives

The `<canvas>` is decorative‑plus‑described: it carries an `aria-label` and an
`aria-describedby` help string, and the live region + hidden description convey
its current content. The mini phase‑disc canvas is `aria-hidden` because the
phase is already given by name in adjacent text.

## Known items for human QA

- Verify NVDA and VoiceOver both read each control's name + value + unit in a
  natural order, and that live‑region announcements are not duplicated or
  truncated during rapid slider changes.
- The stick figure and its cast shadow are decorative (they reuse the original
  exported vector art); they are exposed to SR users only via the general
  diagram description, which already reports the Sun's altitude.
- **No MathJax:** the foundation ships no MathJax include and CDNs are
  disallowed; this sim has no equations. The one angular readout (latitude)
  shows a degree glyph visually and speaks "degrees" via `aria-valuetext`. See
  CONVERSION_NOTES.md deviation #1.
