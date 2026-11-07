# Accessibility — Radial Velocity Demonstrator

Target: WCAG 2.1 AA, with AAA where it was free.

**Human screen-reader QA is still required.** Everything below was checked
structurally and programmatically in a Chromium browser. Nobody has yet driven this
page with NVDA on Windows or VoiceOver on macOS and iOS, and no automated check
substitutes for that. Please run both before this goes to students.

---

## Structure

* One `<h1>`, rendered by the shared masthead. The sim adds no competing `<h1>`;
  its three panels use `<h2>`, so the heading order is h1 → h2 with no skips.
* Landmarks: `<main>` wraps the simulation; each panel is a `<section>` tied to its
  heading with `aria-labelledby`; the masthead supplies the `<header>`/`<nav>`.
* `<html lang="en">`.
* A "Skip to controls" link is the first tab stop.
* Every control has a real `<label>` or is inside a `<fieldset>`/`<legend>`.

## Keyboard

Everything is operable from the keyboard, the focus ring is the foundation's
`:focus-visible` outline, and there are no traps — Tab always moves on. The
masthead dialog manages its own focus and Escape handling; the sim does not
interfere with it.

The orbital phase has **two** controls for one value: a typable number field and a
slider. Either can be used, they stay in sync, and both write to the same state.

| Key | Where | What it does |
| --- | --- | --- |
| Tab / Shift-Tab | anywhere | skip link → Reset → Review Help Guide → About → **start/pause animation** → **orbital phase** (number) → **orbital phase slider** |
| Enter / Space | start/pause button | starts or pauses the orbital animation |
| any digit | orbital phase number field | types a value directly; the diagram follows each keystroke as soon as the box holds a number |
| ↑ / ↓ | orbital phase number field | one degree forward / back (native `<input type="number">`) |
| ← / ↓ | orbital phase slider | one degree back |
| → / ↑ | orbital phase slider | one degree forward |
| Page Up / Page Down | either phase control | ten degrees (added by the sim on the number field; native on the slider) |
| Home / End | either phase control | 0° / 359°. On the number field this replaces caret movement, which is of little use in a three-digit box |
| Mouse wheel | either phase control, while focused | one degree per notch; `preventDefault` only while the control holds focus, so the page scrolls normally everywhere else |
| Escape | masthead dialog | closes it and restores focus (handled by the component) |

The number field takes `min="0" max="359" step="1"`. Values outside that range are
clamped on commit, and while one is pending the field's `:invalid` state thickens
the border as well as colouring it, so the warning is not carried by colour alone.
Clearing the field (which is also what the element reports for unparseable text)
and clicking away reverts to the current phase rather than snapping the star to
zero, so an abandoned edit is never destructive. `inputmode="numeric"` brings up
the numeric keypad on phones.

**Only interactive controls are in the tab order.** Confirmed in the browser: the
tab stops are exactly the skip link, the button, the phase number field and the
phase slider. The panel text and the SVG stage are *not* tab stops.

MathJax v3 puts `tabindex="0"` on every `mjx-container` when its context menu is
enabled, which would drop display-only maths into the tab order. `simulation.js`
demotes them to `tabindex="-1"` with a `MutationObserver`, so it also catches
containers created by later equation updates. The right-click MathJax menu still
works — verified while the sim still displayed an equation: it opens with "Show
Math As", "Copy to Clipboard", "Math Settings", "Accessibility". The menu is
neither disabled nor overridden, and no `contextmenu` handler is trapped anywhere
in the sim. The guard now normally finds nothing (see **Mathematics** below) and is
kept so that adding any equation back cannot silently reintroduce the tab stop.

## Text alternatives

* The stage `<svg>` carries `role="img"`, an `aria-label` describing what the
  picture is, and `aria-describedby="stage-labels stage-desc"`.
* `#stage-labels` (static) carries the two pieces of lettering drawn on the stage
  verbatim, because `role="img"` hides the SVG subtree from assistive technology:
  *"The instrument is labelled SPECTROMETER and carries the note: doppler shift
  greatly exaggerated."*
* `#stage-desc` is rewritten from the single `render()` on every commit, e.g.
  *"Orbital phase 123 degrees. The planet is below and left of the centre of mass
  and the star is above and right of it. The absorption lines are shifted 16.8
  pixels toward the red end of the spectrum. The animation is running."*

## Numbers are always spoken with their quantity and unit

No bare numbers anywhere. The slider's `aria-valuetext` carries the whole spoken
value, so nothing depends on a visually adjacent unit label being picked up:

> `Orbital phase 123 degrees, spectral lines shifted 16.8 pixels toward the red end of the spectrum`

and at rest:

> `Orbital phase 0 degrees, spectral lines at their rest positions`

The number field is announced from its own `<label>` plus the visible "degrees"
span, which it references with `aria-describedby` — so it reads as *"orbital
phase, edit, 123, degrees"* rather than as a bare number. The unit is a real
visible element rather than an `aria-hidden` echo, which also keeps the visible
label contained in the accessible name (WCAG 2.5.3). Units are spelled as words
("degrees", "pixels"), never as glyphs.

## Live region

`#sr-status` is `role="status"` / `aria-live="polite"`, and speaks **on commit
only** — a button press, the end of a slider adjustment, a reset — never once per
animation frame. Slider announcements are debounced by 400 ms so holding an arrow
key does not flood the buffer. While the animation runs, the `aria-valuetext` and
the diagram description refresh at 5 Hz rather than 60 Hz for the same reason.
`aria-live="assertive"` is not used anywhere.

## Mathematics

**The sim currently displays no mathematics.** The "Spectral line shift" panel,
which held the live `Δx = R sin θ` equation and the numeric line-offset readout,
was removed at your request. That returns the page to the original Flash sim, which
showed no equations either, so the pipeline's MathJax rule is satisfied vacuously —
there is nothing mathematical rendered as a raster image, as ASCII art, as
hand-built HTML `<sub>`/`<sup>`, or painted onto the graphic, because there is
nothing mathematical rendered at all.

MathJax itself is still loaded and still vendored under `assets/mathjax/`, and
`klunlInitEqn()` is still redefined in `simulation.js` as the sim's initialisation
hook, so an equation can be added back without any plumbing. If it is, note the
finding that made the old caption work: **this MathJax build produces SVG with
`assistiveMml` off, so its typeset output carries no accessible text of its own.**
A bare `\(R\)` in a sentence is silent to a screen reader — the old caption read as
*"the maximum offset is 20 pixels and is the orbital phase"* until each symbol was
paired with an `.sr-only` word. Pair every symbol, or turn `assistiveMml` on.

Because the shift is no longer shown numerically on screen, its size and direction
now reach assistive technology only through the slider's `aria-valuetext` and the
diagram description — both of which still carry them in full, with units.

## Colour and contrast

Two colours were changed. Both failed WCAG 1.4.3 in the original; everything else
is untouched.

| Element | Original | Now | Contrast before | Contrast after |
| --- | --- | --- | --- | --- |
| `SPECTROMETER` lettering | `#d36488` | `#ffffff` | 2.5 : 1 on the red plate — **fail** | ≥ 5.1 : 1 across the whole plate gradient |
| `doppler shift greatly exaggerated` | `#333333` | `#000000` | 3.2 : 1 on the `#939393` case — **fail** | 5.3 : 1 |

Checked and left alone: the orbit strokes `#666666` on black are 3.7 : 1, which
passes the 3 : 1 required of graphical objects; the star `#ffffcc`, the planet
`#cccccc` and the spectrum itself keep their exported values, so the physically
meaningful spectrum is not distorted.

**No state is signalled by colour alone.** The direction of the shift is stated in
words — "shifted toward the red end of the spectrum" / "toward the blue end" / "at
rest positions" — in the slider's `aria-valuetext` and in the diagram description,
each alongside the size of the shift in pixels.

One caveat now that the "Spectral line shift" panel is gone: those words are the
*only* non-colour statement of the shift direction, and both live in the
accessibility layer rather than on screen. A sighted visitor who is red-green
colour blind sees the lines move but has no on-screen text naming which end of the
spectrum they moved toward. If that matters for your students, the cheapest fix is
a one-line status sentence under the slider echoing the `aria-valuetext`; say the
word and I will add it.

## Motion

* Nothing moves until the visitor presses **start animation**; the page never
  auto-animates.
* The same button pauses it, so WCAG 2.2.2 is satisfied without adding a second
  control. Reset comes from the masthead's own button via the `sim-reset` event —
  the sim does not draw a second Reset.
* Nothing flashes. The only motion is a 9-second rotation and a slow horizontal
  slide, far below 3 flashes per second.
* Under `prefers-reduced-motion: reduce` a note appears explaining that the
  animation only ever runs on an explicit press and pointing at the orbital phase
  control as the way to step through the orbit without continuous movement. The
  animation is left working, because starting it is a deliberate request and the
  motion is the content of the simulation rather than decoration.

## Zoom, reflow and touch

* Body copy is 1.125 rem in the sim's own scale, sized in rem so it tracks the
  browser's font setting. The foundation's 0.9 rem default is overridden only
  within the sim's subtree, in `styles/styles.css`.
* No fixed pixel heights crop text; the stage scales by `viewBox` and CSS, so a
  200 % zoom is just a narrower layout. Measured: at 1280 px the stage panel
  (640 px) and the Animation panel (352 px) sit side by side with their tops and
  bottoms aligned and the stage at its native 600 × 450; 768 px collapses to one
  column, stage first, at the foundation's own 56 rem breakpoint; 375 px and
  320 px stack everything full width in reading order with nothing clipped or
  overlapping.
* Touch targets: the button, the phase number field and the slider track are all
  44 px tall. Pointer and touch share one path, the slider has
  `touch-action: pan-y` so a horizontal drag adjusts it while a vertical swipe
  still scrolls the page, and nothing is revealed on hover.

## Known issue that could not be fixed here

Below about 380 px viewport width the page gains a few pixels of horizontal scroll.
**All of it comes from the shared masthead**, whose shadow-DOM `.masthead-container`
is a non-wrapping flex row: with three buttons plus 20 px side padding its minimum
width is 380 px. Measured at a 320 px viewport, the document scroll width is 380 px
and the masthead container's own scroll width is also 380 px, while every element
of the simulation itself fits.

Because the container lives inside a shadow root, no sim stylesheet can reach it,
and `kl-unl-masthead.js` must stay unchanged. The one-line fix belongs in the
foundation, where it would benefit every sim in the pipeline:

```css
.masthead-container { flex-wrap: wrap; }
```

It is a no-op at every width where the row already fits.
