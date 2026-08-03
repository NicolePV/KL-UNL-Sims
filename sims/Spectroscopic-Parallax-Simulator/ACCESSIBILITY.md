# Accessibility — Spectroscopic Parallax Simulator

Target: WCAG 2.1 AA (ADA Title II), with AAA where it came cheaply.

**Human screen-reader QA is still required.** Everything below was verified by
inspecting the rendered accessibility tree and by keyboard, not by listening.
Please run the simulation with NVDA (Windows, Chrome and Firefox) and VoiceOver
(macOS Safari and Chrome, plus iOS Safari) before release.

## Structure and semantics

* One `<h1>` only — rendered by `<kl-unl-masthead>`. The simulation adds no
  competing `h1`.
* `<main class="app-shell">` is the single main landmark; each panel is a
  `<section>` labelled by its own `<h2>` through `aria-labelledby`, so the
  headings run h1 → h2 with no skipped level.
* A "Skip to main content" link is the first tab stop.
* `<html lang="en">`.
* Every control has a real label: `<label for>` on the magnitude field and on
  each luminosity-class radio, `aria-label` on the range input, and
  `<legend>`s on both fieldsets.

## Text alternatives for the three diagrams

The canvases and the SVG artwork are the visual layer only; none of them is the
accessibility layer.

| Diagram | How it is exposed |
| --- | --- |
| Absorption-line plot | The inline SVG is `aria-hidden`; a visually hidden `#lines-desc` describes what the plot shows and where the cursor sits, and is rewritten on every state change |
| Simulated spectrum | The canvas is `role="img"` with `aria-describedby="spectrum-desc"`; the description names every line family currently drawn and its percentage strength, and states the line thickness's meaning |
| HR diagram | The canvas is `role="img"` with `aria-describedby="hr-desc"`; the description gives both axis ranges with units, names the shaded regions, and states the marked star's temperature, luminosity and class |

The curve labels, region labels and tick labels are decorative duplicates of
information already in those descriptions, so their containers are
`aria-hidden="true"` — they are not read twice.

## Units are always spoken

Screen readers announce only an element's accessible name and value, so every
number that has a unit carries the unit and the quantity name in that value, as
full words rather than symbols:

* Cursor: `aria-valuetext="spectral type G 2, temperature 5840 kelvin"` — the
  subtype letter and digit are separated so they are not read as a word.
* Magnitude slider: `aria-valuetext="apparent magnitude 1.0"`.
* Magnitude field: labelled *apparent magnitude*, with a hidden description
  giving the range, the step and how to change it.
* Live region: *"Spectral type G 2, temperature 5840 kelvin, luminosity class V,
  main sequence dwarfs. Apparent magnitude 1.0, absolute magnitude 4.8, distance
  1.70 parsecs."*
* Equation description: the distance modulus is spelled out in words —
  *"Apparent visual magnitude m sub v minus absolute visual magnitude M sub v
  equals minus 5 plus 5 times the base ten logarithm of the distance d in
  parsecs"* — followed by the current numbers.
* Each luminosity-class radio has a hidden expansion of its Roman numeral
  (*"luminosity class three, giants"*), because `III` alone is ambiguous in
  speech.

## Live region

`#sr-status` is `aria-live="polite"` and `aria-atomic="true"`. It is updated
250 ms after the last change, so dragging the cursor or holding an arrow key
produces one announcement when the value settles rather than one per pixel.
Nothing uses `aria-live="assertive"`; there are no alerts in this simulation.

## Keyboard

Tab order, in order: skip link → masthead Reset / Help / About → spectral-type
cursor → apparent-magnitude field → apparent-magnitude slider → the five
luminosity-class radios. Nothing else is focusable — the typeset mathematics,
the readouts, the labels and all three diagrams are display-only and carry no
`tabindex="0"`. There is no keyboard trap; the masthead's dialog manages its own
focus and Escape.

| Control | Keys |
| --- | --- |
| Spectral-type cursor (`role="slider"`) | ← / ↓ one subtype hotter, → / ↑ one subtype cooler, Page Up / Page Down ten subtypes, Home = O0, End = M9; mouse wheel steps one subtype while focused |
| Apparent-magnitude number field | ↑ / ↓ ± 0.1 (native), Page Up / Page Down ± 1.0, Home = −5, End = 15; mouse wheel ± 0.1 while focused |
| Apparent-magnitude slider | ← / ↓ / → / ↑ ± 0.1, Page Up / Page Down larger step, Home / End to the limits (all native) |
| Luminosity class | Arrow keys move within the radio group (native) |

The cursor is focusable both ways required of a draggable object: it is in the
tab order, and clicking or tapping it also focuses it (`focus()` on
`pointerdown`), so the arrow keys work immediately after a click. It shows the
foundation's focus ring plus a faint tint, and Tab moves away from it normally.
The pointer path and the keyboard path mutate the same state object, so the two
can never drift apart.

## Colour and contrast

The exported Flash artwork is reused unmodified. Text that the original drew in
a hue too light to read on white was darkened while keeping its hue, so a label
still reads as "the orange one" next to its orange curve. Ratios are against
`--background-color` (#ffffff).

| Item | Original | Ratio | Used here | Ratio |
| --- | --- | --- | --- | --- |
| Ionized Helium label | `#ff9900` | 2.14 | `#a35c00` | 5.14 |
| Neutral Helium label | `#0099ff` | 3.00 | `#0063a8` | 6.27 |
| Hydrogen label | `#ff0000` | 4.00 | `#cc0000` | 5.89 |
| Ionized Metals label | `#009900` | 3.78 | `#006b00` | 6.77 |
| Neutral Metals label | `#ff00ff` | 3.14 | `#a800a8` | 6.50 |
| Molecules label | `#cc6600` | 3.84 | `#8a4500` | 7.16 |
| Dwarfs (V) region label | `#3a8c1e` | 4.24 | `#2f7018` | 6.08 |
| m_v term and its value | `#ff0000` | 4.00 | `#cc0000` | 5.89 |
| d term and its value | `#00ccff` | 1.90 | `#00647f` | 6.71 |
| Supergiants (I) label | `#164ea9` | 7.79 | unchanged | 7.79 |
| Giants (III) label | `#b44401` | 5.57 | unchanged | 5.57 |
| M_v term, White Dwarfs label | `#666666` | 5.74 | unchanged | 5.74 |
| HR luminosity-class curves (canvas) | `#ff6666` | 2.86 | `#e84a4a` | 3.81 |

Colour is never the only signal:

* Each curve is named in words by the label sitting on it, and every line family
  currently drawn is named in the spectrum's text description together with its
  strength.
* Each shaded HR region is named in words inside it and in the diagram
  description. The five class curves are drawn in one colour, so they carry no
  colour coding of their own; which track is which follows from the region
  labels beside them and from the diagram description.
* In the distance-modulus panel the colour only links a symbol to the value
  directly beneath it; the two rows are column-aligned and the spoken
  description names each quantity, so the pairing does not depend on colour.

**Known limitation:** the absorption-line curves themselves are the original
exported artwork and keep the original hues, several of which fall between 2.1:1
and 4.0:1 against white as graphical objects. Recolouring them would mean
redrawing exported art, which the conversion brief forbids. The information they
carry is fully available in text through `#lines-desc`, which states the line
description for the selected type, and through the spectrum description, which
gives each family's numeric strength.

## Mathematics

Every mathematical symbol in the interface is typeset by MathJax with SVG
output, so right-clicking any of it opens the MathJax menu (*Show Math As →
TeX / MathML*): the spectral type and temperature readouts, the spectral-type
axis letters O–M, the luminosity ticks 10⁶ … 10⁻⁵, the temperature ticks, the
axis units `(L_⊙)` and `(K)`, the Roman numerals on the radios and in the HR
region labels, and the whole distance-modulus calculation. The MathJax
contextual menu is not disabled and `contextmenu` is not intercepted anywhere.

Typeset output is display-only, so `tabindex="-1"` is set on every
`mjx-container` and its `svg` after typesetting — it is readable by screen
readers (assistive MathML is enabled) but is not a tab stop.

The two exceptions, both inherent: the values inside the editable magnitude
field cannot be typeset because the field is a text control, and the numbers
inside a `<canvas>` are never painted at all — every tick label was moved into
HTML precisely so that it could be typeset.

## Text size, zoom and reflow

Body text is 1.125 rem and every size is in `rem` or `em`, so it tracks the
browser's own font setting. No container has a fixed pixel width or height; the
three diagrams are sized with `aspect-ratio` and scale with their panel. At 200 %
browser zoom the layout reflows to the single-column arrangement rather than
clipping, and there is no horizontal scrolling at any width down to 390 CSS
pixels (verified at 1280, 768, 640 and 390).

## Touch and pointer

Pointer Events give mouse, pen and touch a single code path. The cursor's stage
sets `touch-action: none` so dragging it does not scroll or zoom the page, while
the rest of the page scrolls normally. No control depends on hover. Interactive
targets are at least 2.75 rem (44 px): the cursor handle, the radio rows, the
slider and the number field.

## Motion

The original has no timeline animation — no `onEnterFrame`, no `getTimer` loop —
and neither does this port. Every change is a direct response to user input, so
there is nothing that runs for more than five seconds, nothing that flashes, and
no Pause control is needed. `prefers-reduced-motion: reduce` is honoured anyway
by removing the transition on focus and hover states.

## Reset

Reset comes from the masthead (the `sim-reset` event); the simulation adds no
second Reset button. It restores the exact start-up state — spectral type G2,
luminosity class V, apparent magnitude 1.0 — and the change is announced through
the live region like any other.
