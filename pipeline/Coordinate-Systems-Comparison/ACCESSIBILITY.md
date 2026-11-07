# Accessibility — Rotating Sky Explorer

Target: **WCAG 2.1 AA**, with AAA where it was reasonable.

> **Human screen-reader QA is still required.** Everything below was verified by
> inspection and by scripted DOM checks in Chromium. It has *not* been driven by
> a person using NVDA or VoiceOver end to end. Please schedule that before
> release.

## Structure and semantics

- `<html lang="en">`; one `<h1>` — rendered by `<kl-unl-masthead>`, so the page
  adds none of its own. Each panel is a `<section>` with an `<h2>`, referenced by
  `aria-labelledby`. No heading levels are skipped.
- Landmarks: the masthead supplies the header; the panels live inside `<main>`.
- A "Skip to controls" link is the first tab stop.
- Every input has a real `<label>` or, where the visible text is not a suitable
  name, an `aria-label`. Related controls are grouped in
  `<fieldset>`/`<legend>`.

## Text alternatives for the diagrams (1.1.1)

The three canvases are `role="img"` with a short `aria-label` plus an
`aria-describedby` pointing at a visually hidden paragraph that is rewritten from
`state` on every `render()`. Those descriptions state, in words and with units,
what the diagram currently shows: the observer's latitude and longitude, the star
count, the current view orientation, the elapsed simulated time, and — when it is
switched on — the angle between the celestial equator and the horizon.

## Units are always spoken (explicit supervisor requirement)

No numeric value is ever announced bare. Every announcement names the quantity
and the unit as full words:

- Coordinate fields carry `aria-label`s such as *"Right ascension of the selected
  star, in hours"* and *"Declination of the selected star, in degrees"*. The
  degree and hour symbols beside them are decorative (`aria-hidden`), so a
  missing glyph can never swallow the unit.
- The animation-rate slider carries an `aria-valuetext` of the form
  *"Animation rate 1.2 hours of simulated time per second"* — never the raw
  slider integer.
- Live-region messages spell everything out, e.g. *"Star selected. Right
  ascension 5.1 hours, declination 31.8 degrees. Azimuth 103.8 degrees, altitude
  31.8 degrees."* and *"Observer at latitude 45.8 degrees, longitude minus 96.7
  degrees."*
- Negative numbers are spoken as **"minus 24.2"** rather than relying on the "−"
  glyph, which screen readers routinely drop.
- Coordinate pairs are always announced as *name + number + unit* for each
  component, so RA/dec and azimuth/altitude are never ambiguous in audio.

## Live region

`#sr-status` is an `aria-live="polite"` visually hidden paragraph. It announces on
**commit**, not per tick: on pointer-up after a drag, on `change` for fields and
sliders, on each button press and checkbox toggle, and on each keyboard step.
Nothing is announced during a continuous animation, which would otherwise flood
the buffer. `aria-live="assertive"` is not used — there are no urgent alerts.

## Keyboard map

| Control | Keys |
| --- | --- |
| Celestial sphere view / horizon diagram view | `Tab` to focus, then `←`/`→` rotate the view in azimuth, `↑`/`↓` in altitude (5° steps; `Shift` for 15°). `PageUp`/`PageDown` = 15° in altitude, `Home`/`End` = azimuth 0°/180°. Clicking or tapping the canvas also focuses it, so the arrow keys work straight after a click. |
| World map (observer location) | `Tab` or click to focus, then arrows move the observer by 5° (`Shift` 15°), `PageUp`/`PageDown` ±15° latitude, `Home`/`End` = north/south pole. |
| Latitude, longitude, RA, dec, azimuth, altitude | Native `<input type="number">`: `↑`/`↓` step, and a **mouse-wheel** handler steps by the same amount while the field is focused. `Enter` or blur commits; min/max/step are respected. |
| Animation rate | Native `<input type="range">`: `←`/`↓` decrement, `→`/`↑` increment, `PageUp`/`PageDown` larger steps, `Home`/`End` min/max. |
| Animation duration, hemisphere selects | Native `<select>`. |
| All buttons, checkboxes, radios, the star-patterns disclosure | Native, `Space`/`Enter`. |
| Remove one star | Hold `Delete` and click the star (as in the original). |
| Add a star | `Shift`-click either sphere, or the *add star randomly* button. |

Every pointer gesture in the original has a keyboard equivalent, and both paths
mutate the same `state` object and go through the same `render()`, so keyboard,
mouse and touch never drift apart. `Tab` always moves away normally — there are
no keyboard traps. The masthead dialog manages its own focus trap and `Escape`;
the simulation does not interfere with it.

## Tab order contains only interactive controls

Verified programmatically: the tab order is the skip link, the two view handles,
the location fields and selects, the map handle, the animation controls, the
appearance checkboxes, the star-control buttons and radios, and (when a star is
selected) the four coordinate fields. Nothing else is focusable.

- Typeset MathJax is **not** a tab stop. `mjx-container` elements are given
  `tabindex="-1"` after every typeset pass (a helper re-applies this), and any
  descendant that MathJax marks focusable is demoted too. A scripted check
  confirms zero tabbable `mjx-container`s. The MathJax context menu still opens
  on right-click — it is deliberately left enabled and the `contextmenu` event is
  never trapped.
- Readouts, labels, the diagram descriptions and the canvases carry no
  `tabindex="0"`. The focusable view/map handles are `role="application"`
  proxies for a drag gesture, not decoration — they are genuinely operable.

## Mathematics

All mathematical notation that lives in HTML is typeset by MathJax (SVG output,
vendored locally in `assets/mathjax/`, no CDN): the hour and degree unit symbols
beside the coordinate fields, and the `0ʰ` in the *show 0ʰ circle* label. Each is
paired with a spoken form — either an `aria-label` on the field or an `.sr-only`
companion ("zero hour") — so the meaning survives in audio. Right-clicking any of
them opens the MathJax menu ("Show Math As → TeX / MathML").

### Canvas-baked labels — a documented exception

The labels drawn **on the spheres** are not MathJax:

- the fixed labels `ncp`, `scp`, `zenith`, `nadir`, `meridian`, `0h circle`,
  `celestial equator`, and the `N`/`S`/`E`/`W` direction letters on the horizon
  plane;
- the live coordinate labels on the arcs (`17.6h`, `−24.2°`, `180.0°`, `19.9°`)
  and the celestial-equator/horizon angle (`44.1°`).

These are attached to the 3-D scene: each carries a per-frame rotation *and* a
signed non-uniform y-squash derived from the surface normal, and mirrors when it
passes to the far side of the sphere. Reproducing that with HTML overlays would
mean re-typesetting several elements every animation frame, which is not viable
at 60 fps. **Every one of these values is also present in HTML**, where it *is*
MathJax-typeset and screen-reader accessible:

- the arc coordinates appear in the four labelled fields under the diagrams;
- the celestial-equator/horizon angle is stated, with units, in the horizon
  diagram's description text;
- the fixed labels name features that the descriptions also name in words.

So nothing is available only as canvas paint. This is recorded here as the
divergence the conversion rules ask to be noted.

## Colour and contrast

- The KL-UNL palette variables drive all chrome. Body text on white and white
  text on the black diagram panels both exceed 4.5:1; the help text on black
  (`#d8d8d8`) exceeds 12:1.
- The sphere artwork keeps the original's physically meaningful colours, but
  **colour is never the only signal**:
  - the three declination regions are each named in their own checkbox label
    ("show never rise region", "show rise and set region", "show circumpolar
    region"), each has a distinct grey border, and only the ones you switch on
    are drawn — so which band is which is knowable without seeing hue;
  - the RA/dec/azimuth/altitude arcs are each labelled with their numeric value
    on the sphere *and* in a named field below the diagram;
  - the selected star is identified by the presence of its arcs and by the live
    region, not by colour.
- Focus indication is a 2 px `--outline-color` ring via `:focus-visible`,
  including on the canvas view handles and the map handle.

## Motion and timing (2.2.2 / 2.3.3)

- The animation only runs when the user starts it, and the same button stops it.
  Timed runs (1, 3, 6, 12 hours) stop themselves.
- Nothing flashes; the sky rotates smoothly and there is no flicker above
  3 Hz at any animation rate.
- `prefers-reduced-motion: reduce` is honoured: a *timed* animation jumps
  straight to its end state (advancing the clock and growing star trails by the
  same amount) rather than tweening, and the live region says so. Continuous
  animation is left available because it is the simulation's core teaching
  mechanism and is stoppable at any moment.
- Reset comes from the masthead's `sim-reset` event; the simulation adds no
  second Reset button.

## Zoom, reflow and touch

- Body text is 1.125 rem with everything sized in rem/em, so it tracks the
  browser font setting.
- The layout is a 12-column grid that collapses to a 2-column tablet
  arrangement below 75 rem and to a single full-width column below 56 rem (the
  foundation's own breakpoint, left intact). At 390 px wide the page has **no**
  horizontal scrolling and nothing clips or overlaps; 200 % zoom behaves the same
  way, because zoom-induced narrow widths hit the same breakpoints.
- The canvases keep their original internal Flash stage coordinates and are
  scaled by CSS with a fixed aspect ratio, so no physics or geometry is ever
  recomputed from the on-screen size. Pointer coordinates are mapped back through
  the current scale, so hit-testing and drag maths match the ActionScript at any
  display size.
- Pointer Events give mouse and touch a single code path; `touch-action: none`
  on the canvases stops a drag from scrolling the page. Nothing is revealed by
  hover only — the star hover highlight is a cosmetic echo of the original and
  carries no information.
- Interactive targets are at least 44 px tall, including the checkbox and radio
  rows (the whole row is the target, not just the box).
