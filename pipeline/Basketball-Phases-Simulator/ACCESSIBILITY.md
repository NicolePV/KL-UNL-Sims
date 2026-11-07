# Accessibility — Basketball Phases Simulator

Target: WCAG 2.1 AA. **Human screen-reader QA is still required** — everything below was
checked against the live DOM and by reasoning about NVDA and VoiceOver behaviour, not by
listening to either.

## Structure

- One `<h1>`, rendered by `<kl-unl-masthead>`. The page adds no competing `h1`.
- `<main>` containing three `<section class="panel">`, each with an `<h2>` and tied to it
  by `aria-labelledby`: **Overhead View → View of Ball → Controls**. That is also the DOM
  order, so the stacked phone-portrait layout reads in the same order it displays.
- `<html lang="en">`. Every input has a real `<label>`; the radio groups sit in
  `<fieldset>` with `<legend>`.
- A skip link jumps past the diagram to the controls.

## Keyboard

Tab order contains **only** operable controls, in order:

1. Skip link
2. **The eye** (`#eye-handle`)
3. Hide/Show Basketball
4. Move Eye Manually / Animate Eye
5. With Phases / No Phases
6. Speed of Animation

(Reset / Help / About live inside the masthead's shadow root and manage their own focus.)

### The eye

The one draggable object in the sim. It is a `role="slider"` proxy positioned exactly over
the eye artwork — verified to track it to 0 px at 0°, 90°, 180° and 270°.

| Key | Effect |
| --- | --- |
| Tab | focus the eye; visible focus ring |
| Click / tap | also focuses it, so the arrow keys work with no Tab first |
| ← ↓ | −1° |
| → ↑ | +1° |
| Shift + arrow, PageUp / PageDown | ±15° |
| Home | 0° — observer beside the light, ball fully lit |
| End | 180° — observer opposite the light, ball fully dark |

The angle wraps at 0/360. Tab is never intercepted (`defaultPrevented === false`), so
focus always escapes. Pointer and keyboard mutate the same `state.angle` and go through
the same `render()`, so the two can never disagree.

### Speed of Animation

A native `<input type="range">`, so arrows, PageUp/PageDown and Home/End all work without
custom code. A `wheel` handler adds mouse-wheel adjustment while the control is focused
(and only while focused, so the page still scrolls normally otherwise).

## Screen-reader narration

**Every number is announced with its quantity and unit** — never a bare figure.

- The eye's `aria-valuetext`: *"Viewing angle 137 degrees. The basketball appears 87
  percent lit, with the left side in shadow."*
- The speed slider's `aria-valuetext`: *"50 degrees per second"* — the underlying value is
  degrees per **millisecond**, which is not a figure anyone can picture, so it is spoken in
  degrees per second.
- The MathJax readout is paired with a `.sr-only` line reading *"Viewing angle 137
  degrees."*, because the degree symbol alone is unreliably announced.

A single `aria-live="polite"` status region announces committed changes — drag **release**,
each keyboard commit, radio changes, Hide/Show, Reset — debounced by 350 ms so that holding
an arrow key or dragging produces one settled message instead of a flood. Nothing is
announced per animation tick.

Both canvases are `role="img"` with an `aria-describedby` description regenerated from the
same state that draws them, so what is spoken cannot drift from what is drawn. The
overhead description names the light, the track and the current angle; the ball
description gives the illuminated percentage and which limb is shaded.

## Mathematics

The viewing-angle readout is the only mathematics in the sim — the original displays no
numbers, symbols or equations anywhere. It is typeset by MathJax through the foundation's
`klunlShowEquation`, as LaTeX (`\theta = 137^\circ`), never as an image or ASCII. The
MathJax contextual menu is left enabled and the `contextmenu` event is not trapped, so
right-clicking it opens *Show Math As → TeX / MathML*.

Typeset math is display-only and must not be a tab stop: `simulation.js` sets
`tabindex="-1"` on the MathJax container after every typeset pass (confirmed in the
browser). It stays readable to screen readers through the paired `.sr-only` description.

No math is painted onto either canvas.

## Colour and contrast

- Palette comes from the foundation's CSS custom properties. No original Flash colours
  were re-mapped: the artwork is reused as exported, so contrast is unchanged from the
  original.
- **No state is signalled by colour alone.** The phase is conveyed by the shape of the
  shading, by the numeric viewing angle, and by the spoken illuminated percentage plus
  shaded side. Hide/Show is conveyed by the button's own label text, not by appearance.
- Body text is 1.125 rem (18 px at default settings), headings 1.25 rem, all in rem so
  they track the browser font setting.

## Motion

- The sim opens in **Move Eye Manually** — nothing moves until the user asks it to, so
  there is no unsolicited motion on load and `prefers-reduced-motion` is satisfied by
  default. Choosing "Animate Eye" is an explicit request for motion.
- **Move Eye Manually is the stop control**, always one Tab away, so no second Pause
  button is added (the masthead already owns Reset).
- Reset returns to the initial state, which is manual — so reduced-motion users are never
  put back into motion by a Reset.
- Nothing flashes; the fastest setting is one revolution every 3.6 s.

## Touch and pointer

- One Pointer Events path serves mouse, touch and pen. `touch-action: none` on the
  canvases means dragging the eye never scrolls or zooms the page.
- Targets meet 44 px: the eye proxy is 44 × 44, the Hide/Show button and the speed slider
  are 44 px tall, and each radio row is 44 px tall with the label stretched across it, so
  the activatable label + input region clears the minimum. (The foundation's own 1.25 rem
  radio glyph is left alone so this sim matches its siblings.)
- Nothing is hover-only.

## Zoom and reflow

Verified at 1280 px (two columns, 656/336) and at phone portrait (single column, panels
stacked in reading order): `scrollWidth` never exceeds the viewport and no element extends
past its edge. Both canvases keep their original internal coordinates and are scaled by
CSS with the aspect ratio preserved, so 200 % zoom reflows rather than clipping. The
"Light" caption is real HTML positioned as a percentage over the canvas, not text baked
into the bitmap, so it scales with the user's font size.

Nothing that carries meaning is baked into the canvas as text.

## Still to be checked by a human

- NVDA on Windows (Chrome and Firefox) and VoiceOver on macOS (Safari and Chrome), plus
  VoiceOver on iOS: announcement order, no duplication or truncation, and that the
  `role="slider"` eye proxy is reported sensibly in each.
- Safari and Firefox rendering of the canvases, the MathJax readout and the range control.
- Real touch-drag on an iPad and a phone.
