# Synodic Lag Demonstrator — accessibility notes

Target: WCAG 2.1 AA (ADA Title II), with AAA where it was reasonable.

## Structure and semantics

* Exactly one `<h1>`, rendered by the `<kl-unl-masthead>` component from
  `foundation/contents.json`. The simulation adds no competing `h1`.
* `<main class="app-shell">` wraps the whole simulation; each panel is a
  `<section>` labelled by its own `<h2>` (*Orbit Diagram*, *Controls*) via
  `aria-labelledby`, so the heading hierarchy does not skip a level.
* Every control group is a `<fieldset>` with a `<legend>` carrying the original's
  own wording (*actions*, *length of day*, *animation*). Every input has a real
  `<label for>`. `<html lang="en">` is set.

## Text alternatives

* The `<canvas>` is `role="img"` with `aria-labelledby="diagram-desc"`.
  `#diagram-desc` is a visually hidden paragraph rebuilt on every `render()` from
  the same state object that draws the canvas, so the description can never drift
  from the picture. It reads, for example:

  > Diagram: the Sun sits at the centre of a circular orbit. Earth is at orbital
  > angle 49.28 degrees, measured counter-clockwise from the right-hand side of
  > the orbit. Earth's meridian marker is 310.72 degrees past pointing at the
  > Sun, so the angle to noon is 310.72 degrees. Length of day 1200 hours.
  > Animation speed fast. Starting-position shadow shown.

* The **angle to noon** readout is paired with `#angle-eqn-sr`, a hidden
  companion carrying the spoken form ("angle to noon 310.72 degrees"), supplied
  through `klunlShowEquation`'s screen-reader message argument.

## Mathematics

* The degree symbol in the readout is mathematical notation, so the readout is
  real HTML typeset by **MathJax** (`\(310.72^\circ\)`), never painted onto the
  canvas and never hand-built from `<sup>`/Unicode. Right-clicking it opens
  MathJax's own *Show Math As → TeX / MathML* menu; that menu is not disabled and
  `contextmenu` is not trapped anywhere.
* MathJax is bundled locally at `assets/mathjax/tex-svg.js` — no CDN at runtime.
* MathJax stamps `tabindex="0"` on the container it emits, which would drop a
  display-only readout into the Tab order. A `MutationObserver` on the readout
  rewrites it to `tabindex="-1"` as each typeset lands, so the math stays
  readable and right-clickable but is not a tab stop. (The observer skips
  containers already at `-1`; `setAttribute` queues a mutation record even when
  the value is unchanged, so re-stamping would otherwise loop.)
* Typesetting is throttled to about 10 updates a second while a run is in flight
  so a 60 Hz loop cannot outrun MathJax. The final value of every run is always
  typeset, because the run stops before the last `render()`.

## Keyboard

Every control is a native element, so all of this is browser-provided and there
are no custom widgets, no `div` handlers and no keyboard traps.

| Key | Effect |
| --- | --- |
| `Tab` / `Shift+Tab` | Move between the nine interactive controls, in reading order |
| `Space` / `Enter` | Press the focused button |
| `←` `→` `↑` `↓` | Move within a radio group (length of day, animation speed) |
| `Space` | Toggle the shadow checkbox |
| `Esc` | Close the masthead Help / About dialog (handled by the component) |

Verified in-browser: the tab order contains exactly
`one sidereal day → one solar day → realign to noon → 24 hours → 240 hours →
1200 hours → fast → slow → shadow`, and nothing else. There are **no**
`tabindex="0"` attributes anywhere in the document — the typeset math, the
readout, the panel text, the hidden description and the canvas are all
display-only and are exposed to screen readers through labels and live regions
rather than by being focusable. Focus rings come from the foundation's
`:focus-visible` rule and are not suppressed.

This simulation has no sliders, no numeric entry fields and no draggable or
rotatable objects — the original is driven entirely by buttons, radios and a
checkbox — so the arrow-key drag/nudge and mouse-wheel value-field requirements
do not apply here. Nothing is mouse-only.

## Screen-reader narration

`#sr-status` is an `aria-live="polite"` visually hidden region. It announces on
**commit**, not per animation tick, so it never floods. No `assertive` region is
used; nothing here is urgent enough to interrupt.

Every announcement names the quantity **and** its unit, spelled as words rather
than symbols, so nothing is read as a bare number:

| Action | Announcement |
| --- | --- |
| Press *one sidereal day* | "Animating one sidereal day. Length of day 240 hours." |
| Run completes | "one sidereal day complete. Angle to noon 359.01 degrees." |
| Press *realign to noon* | "Realigned to noon. Angle to noon 0.00 degrees." |
| Change length of day | "Length of day 1200 hours." |
| Change speed | "Animation speed slow." |
| Toggle shadow | "Starting-position shadow shown." / "…hidden." |
| Pause / Resume | "Animation paused. Angle to noon 143.61 degrees." / "Animation resumed." |
| Masthead Reset | "Simulation reset. Angle to noon 0.00 degrees. Length of day 240 hours. Animation speed fast. Starting-position shadow shown." |

Wording was kept consistent with the on-screen labels, and announcements are
single sentences in a fixed order so neither NVDA nor VoiceOver reads them out of
sequence or truncates them mid-value.

## Colour and contrast

* Colours come from the KL-UNL custom properties. Measured in-browser: body text
  17.4 : 1 and button text 7.14 : 1 against their backgrounds — both well past
  the 4.5 : 1 requirement.
* **No colour remaps were needed.** The original's Sun (`#f8eb56`), Earth
  (`#0066ff`) and grey orbit/line are physically meaningful and are kept exactly
  as exported.
* **Nothing is signalled by colour alone.** The orbital state is always available
  as a number with units in the *angle to noon* readout and in the hidden diagram
  description; the shadow is identified by the labelled *shadow* checkbox and
  named in the description; disabled controls are conveyed by the native
  `disabled` state, not merely by dimming.
* The canvas is left transparent rather than filled with a hardcoded stage
  colour, so it follows `--background-color`.

## Motion and timing

* **Pause** was added (it does not exist in the original): a 1200-hour run at the
  *slow* setting lasts roughly 68 seconds, and WCAG 2.2.2 requires motion longer
  than five seconds to be stoppable. Pausing only suspends the clock — the end
  state is identical whether or not the run was paused.
* `prefers-reduced-motion: reduce` replaces the animated sweep with its
  instantaneous end state, and hides the Pause button since there is no motion
  left to pause.
* Nothing flashes; there is no blinking content at any rate.
* Reset is provided **only** by the masthead's own button, via the `sim-reset`
  event. The simulation adds no second Reset.

## Zoom, reflow and touch

* Body text is 1.125rem with everything sized in rem/em, so it tracks the
  reader's own browser font setting.
* Verified with no clipping, overlap or horizontal page scrolling at 360, 375,
  768 and 1280 px wide, and at root text scaling of 100 %, 125 %, 150 %, 175 %,
  200 %, 250 % and 300 %. At phone-portrait widths everything stacks into one
  column in reading order.
* The canvas keeps the original 300 × 300 Flash coordinate system in its backing
  store (multiplied by `devicePixelRatio`, capped at 3) and is scaled by CSS with
  its aspect ratio preserved, so no drawing or physics maths depends on the
  on-screen size.
* The overlaid *angle to noon* readout is sized `max(1.0625rem, 4.6cqw)`: the rem
  floor keeps it legible on a small phone, and the container-query unit keeps it
  growing in step with the diagram instead of crowding it. It was measured to
  stay inside the orbit circle at every width and zoom level tested.
* All interactive targets are at least 44 px (2.75 rem) tall, measured. Nothing
  depends on `:hover`.

## Canvas content that stays on the canvas

The only text the Flash version drew inside the diagram was the *angle to noon*
label and its value; both were moved into real HTML and are typeset by MathJax.
Nothing else on the canvas is text — it is the orbit circle, the Sun, the Earth
symbol with its meridian marker, the Sun-to-Earth line and the translucent
starting-position shadow, all described in `#diagram-desc`. No canvas-baked
symbols remain.

## Still required

**Human screen-reader QA is still required.** The behaviour above was verified by
inspecting the live DOM, the tab order, computed styles, contrast ratios and
canvas pixels in a browser, and by driving the simulation logic headlessly — but
no automated check substitutes for listening to it. Please test with **NVDA on
Windows** (Chrome and Firefox) and **VoiceOver on macOS** (Safari and Chrome),
paying particular attention to whether the run-completion announcement is spoken
in full before the next interaction, and whether the diagram description is
comfortable to browse or too long in practice.
