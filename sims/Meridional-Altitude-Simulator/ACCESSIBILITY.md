# Accessibility — Meridional Altitude Simulator

Target: WCAG 2.1 AA (ADA Title II), AAA where it came for free.

## Structure and semantics

- One `<h1>`, rendered by the shared `<kl-unl-masthead>` component. The sim adds
  no competing `h1`.
- `<h2>` headings for each panel: Diagram, Object, Coordinates, Meridional
  Altitude. No levels are skipped.
- Landmarks: `<main>` for the simulation, `<section>` per panel, each tied to its
  heading with `aria-labelledby`. The masthead supplies the `<nav>`.
- `<html lang="en">`. Every control has a real `<label>`; each control group sits
  in a `<fieldset>` with a `<legend>`.
- A skip link jumps past the diagram to the controls.

## Text alternatives (1.1.1)

The canvas is `role="img"` with an `aria-label` naming both diagrams, and an
`aria-describedby` pointing at `#stage-desc` — a visually hidden paragraph that is
rewritten by `render()` on every state change. It states, in full sentences and
with units, the observer's latitude, the altitude of the celestial pole and of the
celestial equator on the horizon diagram, which object is selected and at what
declination, its meridional altitude (or that it never crosses the visible
meridian), and whether either range band is shown.

The equation carries a paired screen-reader description (`#altitude-eqn-sr`)
written out in words: *"Meridional altitude equals 90 degrees minus latitude 41
degrees plus declination 23.5 degrees, equals 72.5 degrees."*

## Mathematics (MathJax)

Every mathematical symbol in the interface is typeset by MathJax via LaTeX — not
only the altitude equation, but each individual diagram symbol (`NCP`, `SCP`,
`CE`, `N`, `S`, `Z`, `NP`, `SP`, `EQ`), every slider readout (`41° N`, `23.5°`)
and every slider end label (`90° S`, `90° N`, `−23.5°`, `23.5°`). Nothing is a
raster image, ASCII art, or hand-built HTML `sub`/`sup`.

This is why the diagram symbols are **HTML overlays positioned over the canvas**
rather than text painted onto it: text drawn on a canvas cannot expose the MathJax
context menu and does not respond to browser zoom. Right-clicking any symbol or
equation in the running sim opens MathJax's own menu (Show Math As → TeX / MathML).
The MathJax context menu is left enabled and no `contextmenu` handler intercepts it.

**No maths remains on the canvas.** Every symbol was moved into HTML; there is no
exception to note.

Typeset maths is display-only and is kept out of the tab order: MathJax v3 puts
`tabindex="0"` on its `mjx-container`, so `stripMathTabStops()` rewrites it to
`-1` after every typeset pass. Verified: 19 containers present, none a tab stop.
`aria-hidden` is deliberately *not* used on them — the spoken form comes from the
paired `.sr-only` descriptions, so the maths stays available to screen readers.

## Colour and contrast (1.4.1 / 1.4.3 / 1.4.11)

The canvas keeps the original dark `#333333` diagram field. Three original colours
failed contrast against it and were lightened **within the same hue**; everything
else is the original colour, reused unchanged.

| Element | Original | Ratio | Now | Ratio |
| --- | --- | --- | --- | --- |
| South horizon arrow, `S` label | `#33990C` | 3.4:1 ✗ | `#66CC33` | 6.2:1 ✓ |
| Zenith arrow, `Z` label | `#999999` | 4.4:1 ✗ | `#B3B3B3` | 5.9:1 ✓ |
| Latitude angle wedges | `#D80101` | 2.4:1 ✗ | `#FF6B6B` | 4.6:1 ✓ |
| North horizon arrow, `N` label | `#33CC99` | 6.2:1 ✓ | unchanged | — |
| Celestial-pole arrow, `NCP`/`SCP` | `#FFFFCC` | 17:1 ✓ | unchanged | — |
| Celestial-equator arrow, `CE` | `#FFFFFF` | 21:1 ✓ | unchanged | — |
| Declination wedge | `#FFFF00` | 15:1 ✓ | unchanged | — |

The two translucent range bands are a different case. Their original 40% fills
(`#FF9999` Sun/planet, `#FF9933` Moon) composite to about 2.2:1 against the
background — below the 3:1 required of meaningful graphics. Rather than recolour
them and lose the original look, each band **keeps its original fill and gains a
solid outline** (`#FFB3B3` at 6.1:1 and `#FFC266` at 7.4:1), which carries the
contrast requirement.

The altitude equation sits on the light KL-UNL panel, where the bright diagram
hues are unreadable. It uses darker members of the same hues — latitude `#C00000`
(6.5:1 on white), declination `#7A5C00` (6.4:1) — so the visual link to the shaded
angles survives at an accessible contrast.

**Colour is never the only signal.** Every arrow and angle is labelled in text
(`NCP`, `CE`, `N`, `S`, `Z`), the equation terms are named in the spoken
description and in the adjacent slider labels, and each range band is identified
by the checkbox that turns it on.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)

Everything is operable from the keyboard, in a logical order, with the
foundation's `:focus-visible` ring. There are no keyboard traps; the masthead
dialog manages its own focus and Escape handling and is left alone.

| Control | Keys |
| --- | --- |
| Observer marker (draggable) | Tab to focus, or click/tap to focus. ←/↓ −0.1°, →/↑ +0.1°, PageDown/PageUp ∓10°, Home −90°, End +90°. Mouse wheel while focused: ±0.1° |
| Latitude slider | Native range: arrows ±0.1°, Page ∓10, Home/End to limits. Mouse wheel while focused: ±0.1° |
| Declination slider | Same, within the current object's limits |
| Object radios | Arrow keys within the group, Space to select |
| Range checkboxes | Space to toggle |
| Reset / Help / About | Masthead buttons, Enter or Space |

The draggable observer meets both required behaviours: it is a real focusable
element (`role="slider"` with `tabindex="0"`, live `aria-valuenow` and
`aria-valuetext`), and clicking or tapping it calls `.focus()` so the arrow keys
work immediately without tabbing first. Tab always moves away normally. Pointer
and keyboard mutate the same state object, so the two can never disagree.

**Only interactive controls are in the tab order.** Readouts, labels, the diagram
description and all typeset maths have no `tabindex="0"`.

## Screen-reader narration

A single `aria-live="polite"` region (`#live-region`) announces committed changes:
on pointer release, on a keystroke, on a slider `change`, on a radio or checkbox
change, and on Reset — never on every pointer tick, so the region is not flooded.
`aria-live="assertive"` is not used; nothing here is urgent enough.

**Every number is announced with its quantity name and its unit** — never bare.
Units are spelled as words, since a degree glyph is unreliably spoken:

- `aria-valuetext="Latitude 41 degrees north"` — not `41`
- `aria-valuetext="Declination minus 23.5 degrees"` — not `-23.5`
- *"Latitude 55 degrees south. On the horizon diagram the south celestial pole
  stands 55 degrees above the south horizon, and the celestial equator crosses the
  meridian 35 degrees above the north horizon. Moon selected, Declination minus
  29.3 degrees. Its meridional altitude is 64.3 degrees."*

The hemisphere is spoken as "north"/"south" rather than a sign, and latitude 0 is
announced as "0 degrees, on the equator".

Wording was written to work for both NVDA (Windows, Chrome/Firefox) and VoiceOver
(macOS/iOS, Safari/Chrome): full sentences, no reliance on punctuation for
meaning, no duplicated announcements, and the live region is cleared and refilled
on a later task so an identical repeated string is still re-read.

## Zoom, reflow and touch

- Body text is 1.125rem, sized in rem/em throughout, so it tracks the browser's
  font setting. No fixed pixel heights crop text; the equation box uses
  `min-height` and scrolls its own overflow rather than the page.
- Verified: no horizontal page scrolling at 1280 px, 920 px, 768 px or 375 px,
  nor at 375 px with a simulated 200% zoom. Panels collapse to a single column in
  reading order (diagram → object → coordinates → altitude) at phone-portrait
  width.
- The altitude equation is sized against its own panel with a container query, so
  its longest form fits whole without horizontal scrolling at every layout width,
  and never renders smaller than the body text. Only at 375 px *and* 200% zoom
  (an effective 187 CSS px, well past the 320 px WCAG 1.4.10 asks for) does it
  fall back to scrolling inside its own box — never the page.
- Two upstream issues had to be worked around rather than fixed, since the
  foundation files are copied byte-for-byte: `<fieldset>`'s UA `min-width:
  min-content` (reset in `styles.css` so labels wrap), and the masthead's
  non-wrapping button row, which pushed the page 165 px wide at high zoom. The
  masthead host is constrained from `styles.css`; see `CONVERSION_NOTES.md` for
  the upstream fix worth making.
- The canvas keeps its original internal coordinates and is scaled by CSS with a
  preserved aspect ratio; pointer coordinates are mapped back through that scale.
- Pointer Events give mouse and touch a single code path. `touch-action: none` on
  the canvas and the drag handle stops dragging from scrolling the page.
- Interactive targets are at least 44 px (2.75rem). Nothing is hover-only.

## Motion (2.2.2 / 2.3.3)

The simulation has no animation, timer or autoplay — nothing moves except in
direct response to user input — so there is nothing to pause and nothing that
flashes. `prefers-reduced-motion` is honoured defensively in CSS. Reset is
provided by the masthead's `sim-reset` event; no second Reset button was added.

## Still required

Automated and structural checks are not a substitute for the real thing. Before
release this needs:

- **Human screen-reader QA** with NVDA on Windows and VoiceOver on macOS and iOS,
  covering the full interaction cycle.
- **A human visual pass.** The tooling in this session could not capture page
  screenshots, so panel spacing, label placement over the canvas and alignment
  were verified numerically rather than by eye.
- **Real-device testing** on Safari (desktop and iOS) and on Android, including
  the drag interaction and MathJax rendering.
- A subject-matter review of the Help text proposed in `CONVERSION_NOTES.md`,
  which is newly written rather than imported (the original SWF has none).
