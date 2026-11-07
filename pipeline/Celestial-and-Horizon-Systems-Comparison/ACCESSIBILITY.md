# Accessibility Notes — Celestial and Horizon Systems Comparison

Target: WCAG 2.1 AA (ADA Title II), with AAA where it was reasonable.

**Human screen-reader QA is still required.** Everything below was reasoned
through and checked in code and in a browser, but no run against real NVDA or
VoiceOver has been done. Please test with NVDA on Windows (Chrome and Firefox)
and VoiceOver on macOS (Safari and Chrome) before sign-off.

---

## Structure and landmarks

* `<html lang="en">`.
* One `<h1>` only — rendered by `<kl-unl-masthead>`; the page adds no competing
  `h1`. Panels use `<h2>` (“Diagram”, “Controls”), so the hierarchy does not
  skip levels.
* `<main class="app-layout">` with two `<section>` panels, each labelled by its
  heading via `aria-labelledby`. The controls panel is placed to the right of
  the diagram with CSS grid only — DOM order stays diagram → controls, so the
  visual order and the reading/tab order agree at every width (WCAG 1.3.2 and
  2.4.3). Below 56 rem the panels stack in that same order.
* Controls are grouped in `<fieldset>` / `<legend>` (“Diagram shown”,
  “Observer's latitude”).

## Text alternatives for the canvas

The canvas is the visual layer only; it is never the accessibility layer.

* The canvas carries an `aria-label` that is rewritten on every render with the
  current view name and the viewing direction, e.g.
  *“Celestial sphere diagram, currently showing the celestial sphere. View
  direction: azimuth 270 degrees, altitude 30 degrees. Drag, or use the arrow
  keys, to rotate the view.”*
* `aria-describedby` points at a visually hidden paragraph that describes what
  the diagram currently shows — the globe, the observer's dot, which circles are
  which colour and what they represent, and what happens as the view morphs to
  the horizon diagram. It is regenerated from the single `render()`/state path,
  so it can never drift from the picture.
* An `aria-live="polite"` status region announces committed changes only
  (see below), not every animation tick.

## Speaking numbers with their units

Every number that has a unit is announced with the quantity name **and** the
unit, spelled as words, never as a bare number or a bare degree glyph:

* Latitude slider: `aria-valuetext` — *“Observer's latitude 41.0 degrees, that
  is 41.0 degrees north”*; negatives read *“latitude minus 5.0 degrees, that is
  5.0 degrees south”*; zero reads *“latitude 0.0 degrees, on the equator”*.
* Latitude number field: the same string as its `aria-label`.
* View direction: *“View rotated to azimuth 260 degrees, altitude 20 degrees”*,
  announced when a drag is released or an arrow key commits — both components
  named and given their unit, so the pair is unambiguous in audio.
* The equation's paired screen-reader message repeats the value with its unit.

## Keyboard map

Tab order contains only operable controls, in reading order:

`diagram → switch → latitude number → latitude slider`
(plus the masthead's Reset / Help / About buttons, which come first).

| Control | Keys |
| --- | --- |
| Diagram (canvas, `role="application"`, `tabindex="0"`) | `←` `→` rotate the view in azimuth by 5°; `↑` `↓` change viewing altitude by 5°; `Page Up` / `Page Down` change altitude by 15°; `Home` / `End` jump to the lowest / highest viewing altitude. Clicking or tapping the diagram also focuses it, so the arrow keys work immediately without tabbing first. `Tab` always moves away — no trap. |
| **switch** button | `Enter` / `Space` |
| Latitude number field | `↑` `↓` ±0.1°; `Page Up` / `Page Down` ±1°; `Home` / `End` −90° / +90°; mouse wheel ±0.1° while focused (the page does not scroll while the field handles the wheel) |
| Latitude slider | native `<input type="range">`: `←` `↓` decrement, `→` `↑` increment, `Page Up` / `Page Down` larger steps, `Home` / `End` minimum / maximum |

Pointer and keyboard paths write to the same state object and go through the
same `setThetaAndPhi` / `setLatitude` functions, so the two can never diverge.
Focus is visible everywhere via the foundation's `:focus-visible` rule, and the
canvas keeps focus for the duration of a drag (pointer capture).

Non-interactive content is **not** focusable: the equation container is
`tabindex="-1"`, and no readout, label or hidden description carries
`tabindex="0"`.

## Colour and contrast

* Palette comes from the foundation's CSS custom properties.
* **Remap:** the original faded the two view labels and the arrow between
  `#e0e0e0` and `#000000`. `#e0e0e0` on white is roughly 1.3:1 and fails
  1.4.3, so the endpoints are now `#767676` (4.54:1 on white) and `#1a1a1a`
  (15.9:1). The interpolation itself is the original formula.
* **Never colour alone:** the dominant view is also rendered in bold, and each
  label carries hidden text — “(view shown)” or “(view not shown)” — that
  updates with the transition. Changes are announced in the live region.
* The diagram's own colours are physically meaningful (pale yellow celestial
  circles, faint white horizon circles, pale blue axis, green horizon plane) and
  are kept, but every one of them is named in the hidden diagram description, so
  nothing depends on distinguishing them visually.
* The direction letters N / S / E / W are drawn white on the lit face of the
  horizon plane and `#999999` on the shaded face, as in the original.

## Motion and timing

* The only animation is the user-initiated three-second view transition — under
  the five-second threshold of 2.2.2, self-terminating, and re-triggerable at
  any moment by pressing **switch** again (which reverses it from wherever it
  is). No separate Pause control is needed, and none was added.
* `prefers-reduced-motion: reduce` replaces the transition with an immediate
  jump to the equivalent end state.
* Nothing flashes; nothing repeats more than three times per second.
* Reset is the masthead's own button via the `sim-reset` event; the simulation
  adds no second Reset.

## Text size, zoom and reflow

* Body copy is 1.125 rem and everything is sized in `rem`/`em`/`%`, so it tracks
  the browser font setting.
* No fixed pixel heights crop text; grid and flex items carry `min-width: 0` so
  content wraps instead of forcing overflow.
* Verified at 320 px and 375 px viewports with the root font size forced to 16,
  24 and 32 px (i.e. up to 200% text scaling): the panels stack in reading
  order, there is no page-level horizontal scrolling, and no element is pushed
  outside the viewport.
* The switch row's connecting arrows are governed by a container query on the
  controls panel, so they respond to the width of that panel rather than the
  window — necessary once the panel sits in a column beside the diagram. Where
  container queries are unsupported the arrows simply shrink instead of being
  hidden; the labels, the button and the layout are unaffected either way.
* The canvas keeps the original 380 × 380 stage coordinates and is scaled by CSS
  with its aspect ratio preserved; its backing store is matched to the displayed
  size × `devicePixelRatio` so it stays crisp. Pointer coordinates are mapped
  back through the current scale, so drag maths still matches the ActionScript
  at any display size.

## Touch

* Pointer Events give mouse, pen and touch a single code path.
* `touch-action: none` on the canvas, so dragging the diagram does not scroll or
  zoom the page; normal scrolling is unaffected elsewhere.
* All targets meet 44 px: the switch button, the number field and the slider all
  measure 44 px high at the default font size.
* Nothing is revealed by hover only.

## Known limitations

1. **Canvas-baked text.** The four direction letters (N, S, E, W) live on the
   rotating horizon plane and are squashed and rotated by the same 3-D
   projection as the plane itself, exactly as in the original. They cannot be
   moved into HTML without losing that projection, so they are drawn on the
   canvas — and named in the hidden diagram description instead. They are
   decorative-plus-described, never the only way to get the information.

2. **Masthead width.** The foundation masthead's title/button bar is a
   non-wrapping flex row needing about 361 px. Below that it would push the
   whole page into horizontal scrolling. Since foundation code must not be
   edited, `styles/styles.css` confines the overflow to the bar
   (`kl-unl-masthead { overflow-x: auto }`). The proper fix is upstream:
   `flex-wrap: wrap` on `.masthead-container`.

3. **MathJax is absent from the supplied foundation.** See the open question at
   the end of `CONVERSION_NOTES.md`. Until a local MathJax is added, the
   `\( \phi = 41.0^{\circ} \)` container stays hidden rather than printing raw
   LaTeX, and the latitude value with its unit is still conveyed through the
   controls' accessible names and the screen-reader message. Right-clicking to
   get the MathJax context menu (the pipeline's verification test) will only
   work once that include is present.

4. **`role="application"` on the diagram.** This is what lets arrow keys reach
   the rotation handler under a screen reader, but it also suppresses browse
   mode over the canvas. The surrounding description and live region are outside
   the application region, so they remain readable in browse mode. Worth
   confirming in NVDA and VoiceOver QA that this trade-off reads well.
