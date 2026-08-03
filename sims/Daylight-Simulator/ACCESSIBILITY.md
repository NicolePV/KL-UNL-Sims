# Daylight Simulator — accessibility notes

Target: **WCAG 2.1 AA** (ADA Title II), with AAA where it was reasonable.

> **Human QA is still required.** Everything below was verified structurally and
> programmatically in one browser. It is not a substitute for a real screen-reader
> pass with **NVDA** (Windows, Chrome and Firefox) and **VoiceOver** (macOS,
> Safari and Chrome), or for looking at the page on real hardware.

---

## Structure

- One `<h1>` — "Daylight Simulator" — rendered by the `<kl-unl-masthead>`
  component. The simulation adds no competing `h1`.
- Four `<h2>` panel headings under it, no skipped levels: Flat Map of Earth,
  Current Conditions, Your Location, Animation Mode.
- Landmarks: `<header>`/`<nav>` from the masthead, `<main id="main-content">`,
  and a `<section>` per panel, each tied to its heading with `aria-labelledby`.
- `<html lang="en">`. A "Skip to main content" link is the first tab stop.
- Reading order in the DOM matches the visual order, and is what the layout
  collapses to on a phone: map → readouts → location → animation.

## Text alternatives

- The `<canvas>` is `aria-hidden="true"`. It is decorative *as a canvas* — its
  content is conveyed by `#map-description`, a visually hidden paragraph
  rewritten from the same `render()` that draws the map:

  > "Flat map of Earth showing the daylight and night-time regions. The Sun is
  > overhead at latitude 23.25 degrees north. Your location marker is at latitude
  > 40 degrees north, longitude 96 degrees west. Local time there is 12:00 PM on
  > June 20, with 15.02 hours of daylight. The yearly animation is running."

- The three typeset readouts are `aria-hidden` and paired with `#sr-readouts`,
  which carries their spoken form. This avoids screen readers announcing the
  MathJax markup and the plain text twice.

## Units are always spoken

This was an explicit requirement — a real failure had been observed where right
ascension and declination were read as bare numbers. Every value that has a unit
is announced with **both the quantity name and the unit, spelled as words**:

| Control / readout | Announced as |
| --- | --- |
| Latitude slider | "Latitude 40 degrees north" (and "0 degrees, the equator" at zero) |
| Longitude slider | "Longitude 96 degrees west" (and "0 degrees, the prime meridian") |
| Animation speed | "Animation speed 5 of 10" |
| Map drag proxy | "Map centred on longitude 16 degrees west" |
| Sun declination | "Sun declination minus 22.84 degrees" |
| Latitude of direct rays | "Latitude of direct rays 22.84 degrees south" |
| Daylight hours | "Daylight hours 12.12 hours" |

Singular is handled ("1 degree north", not "1 degrees north"). Signs are spoken
as "minus"/"plus", not the glyph. Latitude and longitude are always announced as
a labelled pair so neither is ambiguous in audio.

## Live region

`#sr-live` is `aria-live="polite" aria-atomic="true"`. It announces **on commit,
not per tick** — on slider `change` (not `input`), on drag release, on button
activation, on mode change — so continuous dragging never floods the queue. A
120 ms debounce plus a duplicate-suppression check prevents repeats. Nothing
uses `assertive`.

The 30 fps animation deliberately does **not** announce each frame; a user who
wants the current state reads the readouts or the map description.

## Keyboard

Every control is reachable and operable. The tab order was verified to contain
**only** interactive elements, in visual order:

```
skip link → map (drag proxy) → latitude box → latitude slider
→ longitude box → longitude slider → Reset to (0,0)
→ Year → Day → speed box → speed slider → Start/Stop Animation
```

| Control | Keys |
| --- | --- |
| Sliders (`<input type="range">`) | ←/↓ decrement, →/↑ increment, PageUp/PageDown large step, Home/End min/max — all native, none get stuck, Tab always moves away |
| Number boxes | ↑/↓ step, PageUp/PageDown large step, Home/End min/max, **and mouse wheel while focused** |
| Map | Tab to focus **or** click/tap to focus; then ←/→ (and ↑/↓) scroll 1°, PageUp/PageDown 15°, Home recentres |
| Buttons, radios | Native activation |

The map is a `role="slider"` proxy element with `aria-valuemin/max/now` and an
`aria-valuetext` naming the longitude at the map's centre. It sits above the
canvas so canvas pointer handling cannot swallow focus or key events, and it
shows a visible focus ring. There are no keyboard traps; the masthead dialog
manages its own focus and is left to do so.

Wheel and handled keys call `preventDefault()` **only while the control is
focused**, so the page still scrolls normally everywhere else.

Pointer and keyboard paths mutate the same state object and go through the same
`render()`, so the two can never drift apart.

## Mathematics

All mathematical notation is typeset by **MathJax 3.2.2** (SVG output, vendored
locally) from LaTeX — never a raster image, ASCII art, or hand-built
`<sup>`/`<sub>`. That covers not just equations but **every symbol**: the degree
signs on the readouts, the signed declination, the hemisphere letters, the
slider min/max labels, and all 30 map border labels.

- Right-clicking any math opens MathJax's own menu ("Show Math As → TeX /
  MathML"). The context menu is **not** disabled and `contextmenu` is not
  trapped. The demo's `options.renderActions.addMenu = []` was intentionally not
  copied, since it would have suppressed exactly this.
- Typeset output is **display-only and never a tab stop**: every `mjx-container`
  and its `svg` carry `tabindex="-1"` and `focusable="false"`, applied after each
  typeset pass. Verified: 72 containers, 0 focusable.
- Math is not painted on the canvas. The border labels in particular were moved
  out of the canvas into positioned HTML precisely so they could be typeset and
  so they scale with browser zoom. **Nothing mathematical remains canvas-baked.**

## Colour and contrast

- The KL-UNL palette variables supply all page colour; no Flash colours are
  hardcoded into the chrome.
- **Remapped:** the map's border labels are `#E8B175` (tan) in the original,
  drawn on the black Flash stage. On the KL-UNL white panel that is roughly 2:1
  and fails. They are rendered in `--foreground-color` (`#1a1a1a`) instead —
  about 16:1. The map's own border keeps the original black/tan, which is high
  contrast against itself and is decorative.
- **No state is signalled by colour alone.** Day versus night is conveyed by the
  map imagery *and* by the numeric readouts and the map description; the observer
  marker is a distinct shape at a stated latitude and longitude, not just "the
  red dot".

## Motion

- The animation can always be stopped — the Start/Stop button is the original's
  own control, so nothing runs more than 5 s without a stop (2.2.2).
- Nothing flashes. The animation steps 30 times a second but changes the scene
  continuously and gradually; there is no flashing above 3 Hz (2.3.1).
- `prefers-reduced-motion: reduce` loads the simulation **stopped**, showing the
  equivalent state, and says so in the live region (2.3.3).
- Reset is the masthead's, via the `sim-reset` event. No second Reset was added.

## Targets, touch, and reflow

- Interactive targets are at least 44 × 44 px: the number boxes and sliders have
  `min-height: 2.75rem`, the buttons inherit the foundation's `.button`, and the
  radio rows were widened (the bare 20 px radio dot would not have qualified —
  the whole 44 px label row is the target).
- Pointer Events drive mouse and touch through one code path;
  `touch-action: none` on the map means dragging it never scrolls or zooms the
  page. Nothing is hover-only.
- Body text is 1.125rem, sized in rem/em throughout, so it tracks the browser
  font setting.
- Reflow verified with no horizontal scrolling at 1280, 768, and 375 px, and at
  200 % text size. Two fixes were needed for this: `min-width: 0` on the
  fieldsets (a `<fieldset>` will not shrink below its min-content width) and
  `minmax(0, 1fr)` on the control grid.
- The canvas keeps its original internal coordinate system and is scaled by CSS
  with `aspect-ratio`, so it never crops or distorts.

## Forms

Every input has a real `<label>`; the visible grouping labels are
`<fieldset>`/`<legend>`. Where a visible label would duplicate the legend, the
label is `.sr-only` but still present and correctly associated — verified that no
input lacks an accessible name.

---

## Known limitations

- The map is a raster image; a blind user gets its state from
  `#map-description`, not from the imagery itself.
- MathJax readouts refresh about 5 times a second during animation rather than
  every frame (a performance necessity — see CONVERSION_NOTES.md). The live
  region and the map description are unaffected.
- Screen-reader wording has been written for both NVDA and VoiceOver but
  **verified with neither**. This is the main outstanding QA item.
