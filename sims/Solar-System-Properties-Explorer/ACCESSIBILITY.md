# Accessibility — Solar System Properties Explorer

Target: **WCAG 2.1 AA**, with AAA where it came for free. Human screen-reader QA is still required;
everything below was verified by inspection and in-browser DOM/pixel testing, not by a person
listening to NVDA or VoiceOver.

## Structure and semantics

* One `<h1>` — the simulation name, rendered by `<kl-unl-masthead>`. The sim adds no competing `h1`.
* `<main>` wraps the content; each panel is a `<section>` with an `<h2>` and `aria-labelledby`.
  Heading levels do not skip.
* Both control groups are real `<fieldset>`s with a `<legend>` ("Types of planets to show",
  "Property to plot"). The legends are visually hidden because the panel heading above already
  carries the same words on screen; screen readers get both, which reads naturally.
* Every input has a real `<label>` with a `for` attribute.
* `<html lang="en">`.
* A "Skip to controls" link is the first focusable element.

## The chart (1.1.1 — text alternatives)

The `<canvas>` carries only geometry. It is `role="img"` with:

* an `aria-label` that updates from state — e.g. *"Bar chart of semi-major axis in astronomical
  units, 9 of 9 objects shown"*;
* an `aria-describedby` paragraph that states the axis range **with units**, whether the scale is
  linear or logarithmic, which groups are shown, and the objects left to right.

Behind that is a visually hidden `<table>` with a `<caption>`, a `<th scope="col">` header row and
`<th scope="row">` object names, giving every plotted number in navigable form. Each value cell
repeats its unit ("0.39 astronomical units", "1 satellite"), so a cell read in isolation is never a
bare number. The table is rebuilt by the same `render()` that draws the canvas, so it can never
drift out of sync.

## Units are always spoken (explicit supervisor requirement)

Every number the sim exposes to assistive technology carries its quantity name and its unit, spelled
as words:

| Property | Spoken unit |
| --- | --- |
| Semi-Major Axis | astronomical units / astronomical unit |
| Orbital Period | years / year |
| Mass | Earth masses / Earth mass |
| Radius | Earth radii / Earth radius |
| Satellites | satellites / satellite |
| Density | grams per cubic centimeter |

Singular and plural are handled (`1 satellite`, `1 Earth mass`). The chart title's spoken twin is a
full phrase — *"Density in grams per cubic centimeter"* — not the visual shorthand `Density (g/cm³)`.

## Live region

`#sim-status` is a visually hidden `aria-live="polite" aria-atomic="true"` paragraph. It announces
only **committed** changes — a checkbox toggled, a property selected, Reset pressed — never
per-frame or per-resize updates. Each announcement names what changed, then restates the axis range
with units, the scale type, and which objects are now shown, for example:

> Jovian planets hidden. Vertical axis from 0 astronomical units to 40 astronomical units, linear
> scale. Showing 5 of 9 objects: Mercury, Venus, Earth, Mars, Pluto.

`aria-live="assertive"` is not used anywhere.

## Mathematics (MathJax)

* The chart title and every axis value label are typeset by MathJax through the foundation helper
  `klunlShowEquation()` in `foundation/kl-unl.js`. Nothing mathematical is drawn on the canvas, baked
  into an image, or hand-built from `<sup>`/`<sub>`.
* The density title's `<sup>3</sup>` from the original becomes a genuine typeset exponent.
* Right-clicking any typeset symbol opens MathJax's own context menu (Show Math As → TeX / MathML).
  The menu is left enabled; no `contextmenu` handler is installed anywhere in the sim.
* **MathJax output is not a tab stop.** After each typeset pass `untabMath()` sets `tabindex="-1"`
  on every `mjx-container`, so the math is readable and right-clickable but never focusable. Verified:
  the page contains zero elements with `tabindex="0"`.
* The axis labels' container is `aria-hidden` — the axis range is spoken through the chart
  description and the data table instead, so the numbers are not read twice.

## Keyboard

Nothing in this simulation is draggable or rotatable, and there are no sliders or numeric fields, so
there is no pointer-only path to mirror. Every control is a native form control:

| Key | Action |
| --- | --- |
| `Tab` / `Shift+Tab` | move between the skip link, the three checkboxes, the radio group, and the masthead buttons |
| `Space` | toggle the focused checkbox |
| `↑` `↓` `←` `→` | move within the property radio group (selects as it moves) |
| `Enter` / `Space` | activate a masthead button |
| `Esc` | close the Help / About dialog (handled by the masthead) |

The tab order contains **only** interactive controls. Typeset math, the chart title, the axis
labels, the object names, the canvas, the description paragraph and the data table are all
display-only and carry no `tabindex`. There are no keyboard traps; the masthead's dialog manages and
restores focus itself and the sim does not interfere. Focus rings come from the foundation's
`:focus-visible` rule.

## Colour and contrast

* Text is the foundation's `--foreground-color` (`#1a1a1a`) on `--background-color` (`#ffffff`) —
  about 16.9:1, comfortably past AAA.
* The bar fills are the original's exact colours (`#F58181`, `#80A9E6`, `#74CF7C`). Against white
  these sit near 2.6:1 on their own, so **every bar is drawn with the original's 2-unit `#333333`
  outline**, which supplies the ≥3:1 boundary contrast that 1.4.11 asks of a graphical object. No
  colour was remapped, so the chart still looks like the original.
* **Colour is never the only signal.** Each bar is individually labelled with its object's name; the
  legend entries are text ("Terrestrial", "Jovian", "Pluto (not a planet)"); and the hidden data
  table gives every object's *type* in its own column, so a user who cannot distinguish the red and
  green fills — the classic deuteranopia pair — still gets the grouping from text.
* The legend swatches are decorative (`aria-hidden`); they were given a 1 px `#333333` outline the
  original did not have, so they stay visible for low-vision users. This is the only colour-related
  change to the artwork.

## Text size, zoom and reflow (1.4.4 / 1.4.10)

* Body copy is `1.125rem` and all sim sizing is in `rem` / `%` / `clamp`-style relative units, so it
  tracks the browser's font-size setting.
* The layout has no fixed pixel widths or heights that could crop text; panels wrap and the canvas
  scales.
* Chart labels are sized from `--stage-scale` (CSS px per Flash stage unit) with a `0.6875rem`
  floor, so they grow with the chart and with page zoom and never fall below a readable size.
  Because `.app-shell`'s max width is itself in `rem`, raising the browser's default font size widens
  the chart and therefore enlarges the labels too.
* At 200% zoom the layout behaves exactly as it does at the equivalent narrow viewport: one column,
  panels full width in reading order, no horizontal scrolling, nothing clipped. Verified at 375 px,
  768 px and 1280 px viewport widths — `document.scrollWidth` never exceeds `clientWidth`.
* **No text remains baked into the canvas.** Axis values and object names were moved into HTML
  precisely so they zoom; there is nothing left that could not move.

## Motion (2.2.2 / 2.3.3)

The simulation has no animation, no timing, and nothing that flashes — the original's
`onEnterFrame` only polled the controls, and every visual change is instantaneous. There is
therefore nothing to pause, and no Pause control is added. `prefers-reduced-motion: reduce` is
honoured explicitly anyway, so no future transition can slip past it.

## Touch

Every checkbox and radio row is at least `2.75rem` (44 px) tall and the `<label>` stretches across
the row, so the whole row is the tap target. Nothing is revealed on hover only. There are no
draggable elements, so no `touch-action` handling is needed.

## Still to be done by a human

* NVDA on Windows (Chrome and Firefox) and VoiceOver on macOS (Safari and Chrome) and iOS: confirm
  the live-region wording is not truncated, duplicated or read out of order, and that tabbing
  through the controls reads a clear name and state for each.
* Confirm the hidden data table is announced as a table and is navigable with table-reading keys.
* Confirm the MathJax context menu behaves under each screen reader's virtual cursor.
