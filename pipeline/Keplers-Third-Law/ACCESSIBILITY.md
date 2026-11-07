# Kepler's Third Law — Accessibility

Target: **WCAG 2.1 AA** (ADA Title II), with AAA where it was reasonable.

## Structure and semantics

- `<html lang="en">`; `<main class="app-shell">` is the single main landmark.
- Exactly one `<h1>` — "Kepler's Third Law" — rendered by `<kl-unl-masthead>`.
  The sim adds no competing `<h1>`.
- The calculator is a `<section class="panel">` labelled by its `<h2>`
  ("Period and Semimajor Axis Calculator"), so the heading hierarchy is h1 → h2
  with no skipped level.
- Reading order matches visual order: equation → input row → caption → hint.

## Forms and labels

Both value boxes have a real `<label for="…">`. The labels are visually hidden
(the foundation's `.sr-only`) because, as in the Flash original, the boxes are
identified visually by the equation around them — but their accessible names are
complete and units-bearing:

| Field | Accessible name |
| --- | --- |
| `#p-input` | "Period P, in years" |
| `#a-input` | "Semimajor axis a, in astronomical units" |

## Units are always spoken (supervisor requirement)

No value is ever announced as a bare number. The `aria-live="polite"` status
region (`#sr-status`) names the quantity, the value, and the unit **as a word**,
and singular/plural is handled:

> "Period P 8 years. Semimajor axis a 4 astronomical units."
> "Period P 1 year. Semimajor axis a 1 astronomical unit."
> "Period P is empty. Semimajor axis a is empty."
> "Calculator reset. Both boxes are empty."

Because both quantities are announced together, an audio-only user always hears
the pair and never has to infer which number changed.

**Announcements are debounced by 700 ms**, so typing "1234" produces one
announcement rather than four. Reset announces immediately (it is a discrete
action, not a stream of keystrokes).

## Keyboard

The tab order contains **only** the two inputs. Verified in-browser: no
`tabindex="0"` on any display content, and `mjx-container[tabindex="0"]` count is
**0** after typesetting.

| Key | Effect on the focused box |
| --- | --- |
| Arrow Up / Arrow Down | ±0.1 |
| Page Up / Page Down | ±1 |
| Home | 0 (the minimum) |
| Tab / Shift+Tab | move away normally — no trap |

`preventDefault()` is called on exactly these keys so the page does not scroll
instead; `End` is left to the browser because the quantity has no maximum. Every
change routes through the same `setPeriod()` / `setAxis()` state path as typing
and the mouse wheel, so all input methods stay in sync.

**Mouse wheel:** scrolling over a *focused* box steps it by ±0.1. When the box is
not focused the handler does nothing and does not call `preventDefault()`, so
ordinary page scrolling is unaffected (verified).

There are no draggable or rotatable objects in this sim, so the focus-then-arrow
requirements for draggables do not apply.

## MathJax

Every mathematical symbol in the UI is MathJax-typeset — not only the reference
equation but each individual glyph: the exponents ² and ³ beside the boxes, the
equals sign between them, and the variables *P* and *a* inside the caption. Six
`mjx-container` elements in total; none is painted onto a canvas, and there is no
ASCII math, no `<sup>`, and no math-as-image anywhere.

Right-clicking any of them opens MathJax's own context menu ("Show Math As →
TeX / MathML"). The menu is **not** disabled or overridden, and no
`contextmenu` handler is trapped. Output is `tex-svg` with `assistiveMml: true`,
so the math is also exposed to screen readers as MathML.

The reference equation goes through the foundation helper
`klunlShowEquation()`, paired with a spoken description in `#eq-reference-sr`:

> "Kepler's third law: P squared equals a cubed, where P is the orbital period in
> years and a is the semimajor axis in astronomical units."

`klunlInitEqn()` is redefined in `simulation.js`, as `kl-unl.js` intends.

**MathJax is kept out of the Tab order.** MathJax gives every `mjx-container`
`tabindex="0"` so keyboard users can reach its context menu; that would have put
*P*, *a*, both exponents and the equals sign in the tab sequence.
`stripMathTabstops()` resets them to `tabindex="-1"` after typesetting. This does
not affect the right-click menu, and the math stays readable to screen readers
via the paired descriptions and assistive MathML — `aria-hidden` is *not* used as
the fix. Each decorative `.mj` span that duplicates adjacent readable text (the
caption's *P* and *a*) is `aria-hidden` with an `.sr-only` twin, so the caption
reads as one clean sentence: "where P is in years and a is in AUs".

## Text size, zoom and reflow

- Body copy is **1.125 rem (18 px)**, above the pipeline floor and well above the
  foundation's 0.9 rem default; the boxes are 1.25 rem and the equation scales
  with `clamp()`. Everything is in rem/em, so it tracks the browser font setting.
- No fixed pixel heights crop text.
- Verified at the WCAG 1.4.4 / 1.4.10 condition (1280 px at 200 % zoom = 640 px
  CSS): **no horizontal scrolling, nothing clipped**. Also verified at 640 px with
  doubled root font (≈400 % zoom): still no horizontal scrolling — the input row
  wraps, which is the intended reflow.

## Responsive and touch

- Single centred column at every width; the foundation's 56 rem collapse is left
  intact and the sim's own breakpoint at 32 rem carries it down to phone portrait.
- Verified at 375 px (phone portrait): no horizontal scroll, nothing overflowing.
- Both boxes are **44 px tall** at every width — the touch-target floor — and are
  identical in width, height, and baseline to each other.
- No hover-only affordances; nothing depends on `:hover`.

## Colour and contrast

The sim introduces **no colours of its own** — it uses only the foundation's
custom properties (`--foreground-color` #1a1a1a on `--background-color` #ffffff,
≈16.1:1; `--border-color` #767676 on white, ≈4.5:1 for the box outlines;
`--outline-color` #005fcc for focus). Nothing is signalled by colour alone; the
original used no colour coding either. Focus is shown by a 0.125 rem solid
outline with offset, from the foundation's `:focus-visible` handling.

## Motion

The sim has no animation, no timers, and nothing that flashes — the original is a
single static frame. `prefers-reduced-motion` therefore has nothing to disable,
and no Pause control is needed. Reset is provided by the masthead's `sim-reset`
event; the sim adds no second Reset button.

## Known limitations

- The foundation masthead's own flex row overflows by 3 px at a 320 px viewport
  (see CONVERSION_NOTES.md). Foundation files are not edited, so this is left as
  is; it affects every sim equally and does not occur at 375 px or above.
- Invalid input (for example a lone ".") silently clears the other box with no
  error message, exactly as the Flash original behaves. An explicit error message
  would be an accessibility improvement but would change behavior, which the
  priority order forbids.

## Screen-reader QA still required

The wording above was written and reasoned against **NVDA** (Windows, Chrome and
Firefox) and **VoiceOver** (macOS, Safari and Chrome), and the DOM/ARIA structure
was verified programmatically in a real browser. That is not a substitute for
human testing. A person using each screen reader should still confirm that
announcements are not duplicated, truncated, or read out of order, and that
tabbing through the two boxes reads a clear name, value, and unit for each.
