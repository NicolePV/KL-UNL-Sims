# Accessibility — Influence of Planets on the Sun Explorer

Target: WCAG 2.1 AA (ADA Title II), with AAA where it came cheaply.
Everything below is implemented in `index.html`, `styles/styles.css` and
`simulation.js`. The KL-UNL foundation files are not modified.

**Human screen-reader QA is still required.** Automated and scripted checks
cannot confirm how NVDA and VoiceOver actually pace and phrase these
announcements. Please test with NVDA on Windows (Chrome and Firefox) and
VoiceOver on macOS (Safari and Chrome) before publishing.

---

## 1. Structure and semantics

* One `<h1>` only — the simulation title, rendered by `<kl-unl-masthead>` from
  `contents.json`. The page adds no competing `h1`.
* `<main class="app-layout">` is the main landmark; each panel is a `<section>`
  with an `<h2>` referenced by `aria-labelledby`, so heading levels do not skip.
* Controls are grouped in `<fieldset>`/`<legend>`. Two legends are `.sr-only`
  because the panel heading already carries the same words visually.
* Every input has a real `<label for=…>`. `<html lang="en">`.
* The nine planet rows and the two offset readouts are flat CSS grids rather than
  wrapper elements with `display: contents`, which older WebKit removed from the
  accessibility tree.

## 2. Text alternatives (1.1.1)

* The `<canvas>` has `role="img"`, an `aria-label` naming the diagram, and
  `aria-describedby="stageDesc"`.
* `#stageDesc` is a visually hidden paragraph rewritten from the single
  `render()` at most once a second. It states, in words, what a sighted user
  sees: which planets are selected, the elapsed time, and how far and in which
  direction the Sun sits from the centre of mass, e.g.

  > Diagram: the Sun is drawn on a black field with the fixed center of mass of
  > the solar system marked by a green cross at the middle. Jupiter and Saturn
  > are selected. Elapsed time 12.4 years. The Sun is 1.31 solar radii from the
  > center of mass: 0.42 solar radii to the right of it and 1.24 solar radii
  > below it. A fading white curve traces where the Sun has been.

  It is a description, **not** a live region, so it never interrupts; it is read
  on demand when the canvas is reached.
* The legend swatches are `aria-hidden`; each legend entry's meaning is in its
  text.

## 3. Colour and contrast (1.4.1 / 1.4.3 / 1.4.11)

Colour remaps and their rationale:

| Original (Flash) | Here | Why |
| --- | --- | --- |
| Orange title/labels `#FF9900` on black | foundation `--foreground-color` on `--background-color` (16.9:1) | the KL-UNL shell is a light theme; the original pairing does not exist in it |
| Planet distances in `#00FF00` on black | foundation foreground on white | `#00FF00` on white is 1.4:1 — a hard failure |
| Flash component chrome (bevels, halo focus ring) | KL-UNL `.button`, `.control-*`, `:focus-visible` | hard rule 2 |

Kept as-is, because they are the physical picture and are high contrast on the
canvas's black field: the Sun's orange globe (`#FECB00`→`#FE9100`, ≈9:1), the
yellow glow, the white path (21:1) and the green `#00FF00` centre-of-mass cross
(15.3:1).

**Nothing is signalled by colour alone.** The green cross, the Sun and the white
path each appear in the diagram key with a word beside a swatch, and the same
three things are named in the spoken description. Planet selection is a checkbox
state, not a colour.

## 4. Keyboard (2.1.1 / 2.1.2 / 2.4.3 / 2.4.7)

Tab order — **operable controls only**, in this order:

1. masthead **Reset**, **Review Help Guide**, **About** (inside the component)
2. the nine planet checkboxes, Mercury → Pluto
3. **Days Per Second** text field
4. **Animation speed** slider
5. **Pause / Resume** button

This follows the visual order exactly (WCAG 2.4.3): the planet list is in the
top row beside the stage, the speed controls are in the full-width row beneath.
It differs from the original's Flash order — slider, then checkboxes, then Reset
— because the speed controls have moved below the planet list; matching the
visible layout matters more here than matching the old order.

| Control | Keys |
| --- | --- |
| Animation speed slider | ← / ↓ −1 day per second, → / ↑ +1 (the original's `minIncrement`), Page Down / Page Up a larger step (browsers use a tenth of the range, 500 here), Home 0, End 5000 |
| Days Per Second field | type digits, **Enter** commits; leaving the field commits; unparseable input reverts to the current value |
| Planet checkboxes | Space toggles |
| Pause / Resume | Enter or Space |
| Masthead dialog | the component traps and restores focus and handles Escape itself — the sim does not interfere |

There are **no draggable canvas objects** in this simulation — the only drag in
the original was the slider's grabber, which is now a native
`<input type="range">` and therefore keyboard-operable by construction, cannot be
"stuck", and releases Tab normally. Focus rings come from the foundation's
`:focus-visible` rule.

**Not in the tab order:** the years readout, the legend, the diagram description
and the canvas graphics. No element carries a stray `tabindex="0"`, and tabbing
lands only on the twelve controls listed above.

## 5. Numbers and text (no MathJax)

The original simulation displays **no** equations, formulas or mathematical
notation of any kind — only plain numbers and the unit `AU`. There is therefore
nothing to typeset, and MathJax is not loaded at all. Numbers are ordinary
sans-serif body text in the foundation's own font stack.

This is also a correctness fix, not only a simplification. An earlier revision
typeset every value through MathJax, which wrote the plain-text value first and
then swapped in MathJax's own fonts — so the digits of the running
`Years Elapsed` counter visibly changed typeface several times a second. Plain
text removes the cause.

| Where | Shown | Spoken form |
| --- | --- | --- |
| Planet distances | `0.387 AU` | "mean orbital distance 0.387 astronomical units" (`.sr-only`, via `aria-describedby` on the checkbox) |
| Years Elapsed | `3.2` | "Years elapsed 3.2 years" (`.sr-only` companion) |
| Days Per Second | `1000` in the text field | the `<label>` names the quantity and unit; the slider carries "Animation speed 1000 days per second" in `aria-valuetext` |
| Sun's offset from the barycentre | not shown (the original shows no such readout) | included in the canvas description: "…1.068 solar radii, or 743,072 kilometers, from the center of mass" |

The visible `0.387 AU` spans are `aria-hidden` so the unit is never read out as
the letters "A U"; the spelled-out `.sr-only` sibling carries the spoken form.
`foundation/kl-unl.js` is still linked as part of the foundation reference
protocol, and `simulation.js` supersedes its `klunlInitEqn()` with a deliberate
no-op — which is exactly what that hook exists for.

## 6. Screen-reader narration — units always spoken

Every number is announced with the quantity it measures **and** its unit; no bare
numbers.

* **Live region** — `#srStatus`, `role="status" aria-live="polite"
  aria-atomic="true"`, visually hidden. It fires **on commit only**, never per
  animation tick, so it cannot flood:
  * planet toggled — *"Jupiter added. Jupiter and Saturn are selected. Traced
    path cleared and elapsed time reset to 0.0 years."*
  * slider or field committed (`change` / Enter / blur) — *"Animation speed 1500
    days per second."* Dragging updates `aria-valuetext` continuously but only
    announces on release.
  * pause — *"Animation paused at 12.4 years elapsed."* / *"Animation running at
    1000 days per second."*
  * masthead Reset — *"Simulation reset. No planets are selected, elapsed time
    0.0 years, animation speed 1000 days per second."*
* **Slider value** — `aria-valuetext="Animation speed 1500 days per second"`,
  rewritten on every change, so arrowing through values speaks the unit each
  time rather than a bare number.
* **Distances** — each checkbox is `aria-describedby` a hidden span reading
  "mean orbital distance 0.387 astronomical units". The unit is spelled out;
  only the visual shows the `AU` symbol.
* **Elapsed time and offsets** — hidden companions read "Years elapsed 3.2
  years" and "…1.068 solar radii, or 743,072 kilometers, from the center of
  mass". Kilometres are given as a grouped decimal rather than
  `7.43 × 10^5`, which is easier to hear.
* Wording is kept consistent with the on-screen text, and each announcement is a
  single atomic string so it cannot be read out of order or half-updated.

## 7. Motion and timing (2.2.2 / 2.3.3)

* A **Pause / Resume** button stops the animation at any time. (Reset comes from
  the masthead's `sim-reset` event — no second Reset control was added.)
* `prefers-reduced-motion: reduce` → the simulation **starts paused**, with the
  button reading *Resume*. There is no meaningful "instantaneous end state" for a
  continuous orbital animation, so opting in explicitly is the equivalent.
* Nothing flashes. The path fades by 1% per step and the Sun drifts smoothly;
  there is no flicker above 3 Hz anywhere.
* Pausing does not lose time: the paused interval is excluded, so resuming
  continues rather than jumping.
* **The animation suspends itself while the masthead's Help or About dialog is
  open.** The dialog makes the page behind it inert, so a user reading Help
  cannot reach the Pause button; leaving the simulation running would let
  hundreds of simulated years elapse behind the overlay, and the stall in the
  animation loop also corrupted the traced path. The loop stops for as long as
  the dialog is showing and resumes exactly where it left off. If the user had
  already paused manually, it stays paused.
* Any other stall in the animation loop (tab backgrounded, slow repaint) longer
  than 250 ms is discarded rather than replayed as one large step, so returning
  to the tab never produces a jump.

## 8. Text size, zoom and reflow (1.4.4 / 1.4.10 / 1.4.12)

* Body copy is 1.125rem, headings 1.25rem, help text 1rem — all in `rem`, so the
  page follows the reader's browser font setting. No fixed pixel heights crop
  text.
* Verified with no horizontal page scrolling at **320**, **768** and **1280**
  CSS px. Below 46rem the speed row breaks so the slider and the Pause button
  each take their own line instead of being squeezed.
* The one thing that cannot reflow is the shared masthead's title-plus-buttons
  bar, which the foundation lays out as a non-wrapping flex row and which is
  wider than 320 px. Since `kl-unl-masthead.js` may not be edited,
  `styles/styles.css` gives that bar its own horizontal scroll so the page body
  still reflows. It is unaffected at 375 px and above.
* Canvas text: **there is none** — the original drew no text on the stage inside
  the simulated area, so nothing had to be lifted out of the canvas. Every label,
  number and unit is HTML and therefore zooms and is selectable.

## 9. Touch and pointer

* One code path for mouse and touch (native controls use Pointer Events
  internally); nothing depends on `:hover`.
* Touch targets: buttons, the slider, the value field and each planet row are all
  at least 2.75rem (44 px) tall, and the planet `<label>` fills its row so the
  whole row is tappable.
* Nothing on the canvas is draggable, so the page keeps normal scrolling and
  pinch-zoom over the picture (`touch-action: auto`) rather than swallowing them.

## 10. Forms and error handling

* The value field filters keystrokes to `0-9 . e E + -`, exactly as the original's
  `restrict`, and is capped at 5 characters (`maxChars`).
* Out-of-range input is clamped silently to 0–5000 and the committed value is
  announced, so the user always hears what was actually accepted. Unparseable
  input reverts to the previous value — matching the original — and is likewise
  announced, so the revert is never silent.
* An `aria-describedby` hint tells the user the accepted range and that Enter
  commits.

## 11. Known limitations

1. Human screen-reader QA (NVDA + VoiceOver) has not been performed.
2. The animation was not observed running in this environment — the automation
   browser never composited a frame, so `requestAnimationFrame` never fired. The
   physics, path and formatting logic was verified head-on with synthetic
   timestamps instead. A sighted human should confirm the motion looks right.
3. The masthead's own contrast, focus handling and dialog semantics are the
   foundation's responsibility and were not altered.
