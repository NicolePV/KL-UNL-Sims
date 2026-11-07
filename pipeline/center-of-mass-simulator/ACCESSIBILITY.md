# Accessibility — Center of Mass Simulator

Target: **WCAG 2.1 AA**, AAA where it came for free. This file records what was
added, what was changed away from the Flash original and why, and what a human
still needs to check.

## Structure and landmarks

- One `<h1>` only — the simulation title rendered by `<kl-unl-masthead>`. The
  page adds no competing `h1`.
- `<main class="app-layout">` holds three `<section class="panel">` regions,
  each labelled by its own `<h2>`: **Diagram**, **Controls**, **Center of
  Mass**. Heading levels do not skip.
- The **Controls** heading is `.sr-only`. It was visually redundant — the three
  labelled rows say what the panel is — but deleting it outright would have left
  the section without an accessible name and put a gap in the heading outline,
  so it is hidden rather than removed. Screen-reader users still get all three
  regions when listing headings.
- `<html lang="en">`.
- Reset / Help / About and their modal come entirely from the masthead
  component. The sim listens for its bubbling `sim-reset` event and restores the
  exact initial state (7.0, 3.0, 10.0, keep CM fixed on). No second Reset button,
  no home-made dialog.

## The diagram

The diagram is a canvas (grid and arrow shafts) with an HTML overlay above it
(the exported sphere, cross and arrowhead art, plus the MathJax labels). The
whole stage is exposed to assistive technology as a single image:

```html
<div class="com-stage" role="img"
     aria-label="Two objects on a scaled grid with their center of mass marked"
     aria-describedby="canvasDesc">
```

`role="img"` hides the decorative pieces inside from AT, so nothing is announced
twice. `#canvasDesc` is a visually-hidden paragraph that the single `render()`
rewrites on every state change, so the spoken description can never drift from
the picture. A worked example:

> Object 1, of mass 7.0 mass units, is on the left; object 2, of mass 3.0 mass
> units, is on the right, separated by 10.0 distance units. A green cross
> labelled C M marks the center of mass. A blue arrow spans r 1, 3.00 distance
> units, from object 1 to the center of mass, and a red arrow spans r 2, 7.00
> distance units, from the center of mass to object 2. Object 1 is the heavier
> object, so the center of mass lies closer to it. Keep CM fixed is on, so the
> center of mass stays at the middle of the grid and the two objects move when
> the masses change.

An audio-only user therefore gets which object is where, both distances with
units, which object is heavier and which way the frame is anchored — everything
a sighted user reads off the picture.

## Mathematics

Every mathematical symbol in the UI is typeset by MathJax — the `m₁` / `m₂`
object labels, the `CM` marker caption and the `r₁ = …` / `r₂ = …` labels on the
diagram from LaTeX, and the relation panel from MathML. None of it is painted on
the canvas, none of it is an image and none of it is hand-built
`<sub>`/`<sup>` markup. Right-clicking any of it opens MathJax's own menu
(*Show Math As → TeX / MathML*); the contextual menu is not disabled, not
overridden, and no `contextmenu` handler is attached anywhere in the sim.

The relation panel goes through the foundation helper
`klunlShowEquation(['eqnMain', latex], ['eqnSrMsg', spoken], ['eqnSrFig', figure])`,
so the equation carries a spoken description alongside it:

> The center of mass relation: mass 1 times r 1 equals mass 2 times r 2. With
> object 1 at 7.0 mass units and r 1 at 3.00 distance units, and object 2 at 3.0
> mass units and r 2 at 7.00 distance units, both products equal 21.00.

`klunlInitEqn()` is redefined in `simulation.js`, as the foundation intends.

### MathJax and the tab order

MathJax 3's CHTML output puts `tabindex="0"` on every `<mjx-container>`, which
put six non-controls into the Tab sequence. `simulation.js` drops each one to
`tabindex="-1"` after typesetting and keeps a `MutationObserver` watching for
new containers (the foundation's `klunlShowEquation` typesets on its own
schedule). The maths stays in the accessibility tree, stays right-clickable, and
is no longer a tab stop. Verified: tabbing through the page now lands on exactly
seven elements, all of them real controls.

## Keyboard

Tab order, in order: masthead **Reset → Review Help Guide → About**, then

| # | Control | Keys |
| --- | --- | --- |
| 1 | object 1 mass value box | type a number, **Enter** commits; blur also commits |
| 2 | object 1 mass slider | ←/↓ −0.1, →/↑ +0.1, PageUp/PageDown larger step, Home/End 1.0 / 10.0 |
| 3 | object 2 mass value box | as above |
| 4 | object 2 mass slider | as above |
| 5 | separation value box | as above |
| 6 | separation slider | ←/↓ −0.1, →/↑ +0.1, PageUp/PageDown, Home/End 1.0 / 20.0 |
| 7 | keep CM fixed checkbox | Space toggles |

Notes:

- Every slider is a **native `<input type="range">`** with `step="0.1"`, so the
  full arrow / Page / Home / End set is the browser's own and cannot get stuck.
  A step of 0.1 is exactly one tick of the Flash slider's
  `getIncrementedValueObject(null, ±1)`, so keyboard stepping matches the
  original.
- No keyboard trap anywhere. The masthead dialog manages and restores its own
  focus; the sim does not interfere.
- The focus ring is the foundation's `:focus-visible` outline.
- Nothing in the diagram is draggable in the original — the only draggable
  objects in the SWF were the slider grabbers — so there is no canvas drag to
  provide a keyboard equivalent for. The pointer and keyboard paths on the
  sliders write to the same `state` object and go through the same `render()`.
- Display-only content carries no `tabindex="0"`: not the diagram labels, not
  the equation, not the canvas.

## Units are always spoken

Never a bare number. The original quantities are dimensionless — the separation
and the two distances share one arbitrary length unit, the masses share one
arbitrary mass unit — so the spoken form names the unit as *"mass units"* and
*"distance units"* rather than inventing a physical unit that is not in the
source.

| Where | What is spoken |
| --- | --- |
| slider value | `aria-valuetext="Object 1 mass 7.0 mass units"` — quantity, number and unit in the element's own value |
| value box | `<label>` gives the quantity; `aria-describedby` gives the unit and range: *"Masses are in mass units, from 1.0 to 10.0 in steps of 0.1…"* |
| relation panel | the `.sr-only` message spells the whole relation out with units, see "Mathematics" above |
| live region | full sentences with units, see below |
| diagram description | full sentences with units, see above |

## Live region

One `aria-live="polite"` `role="status"` region, visually hidden,
`aria-atomic="true"`. It fires **on commit only** — slider `change` (pointer
release or after an arrow key), Enter/blur in a value box, the checkbox, and
Reset — never on `input`, so dragging a slider does not flood the buffer.

Examples:

- *"Object 1 mass 7.1 mass units. Object 1 is 2.97 distance units from the
  center of mass; object 2 is 7.03 distance units."*
- *"Keep CM fixed is off. The two objects stay in place and the center of mass
  moves. Object 1 is 3.00 distance units from the center of mass; object 2 is
  7.00 distance units."*
- *"Simulator reset. Object 1 mass 7.0 mass units, object 2 mass 3.0 mass units,
  separation 10.0 distance units, keep CM fixed on. …"*

The region is cleared and re-set on the next frame so that repeating an
identical message still announces.

## Colour and contrast

Source colours are the literal ActionScript colour ints. Two are re-mapped, for
text only.

| Element | Flash | Here | Ratio on white | Threshold |
| --- | --- | --- | --- | --- |
| blue arrow shaft + heads | `26367` = `#0066ff` | unchanged | 4.83:1 | 3:1 (graphic) ✓ |
| `r₁ = …` label | `#0066ff` | unchanged | 4.83:1 | 4.5:1 (text) ✓ |
| red arrow shaft + heads | `16711680` = `#ff0000` | unchanged | 4.0:1 | 3:1 (graphic) ✓ |
| `r₂ = …` label | `#ff0000` | **`#cc0000`** | 5.89:1 | 4.5:1 (text) ✓ |
| CM cross | rendered `#6dbf6d` | **`#017e01`** | 5.27:1 | 3:1 (graphic) ✓ |
| `CM` caption | rendered `#6dbf6d` | **`#017e01`** | 5.27:1 | 4.5:1 (text) ✓ |
| grid lines | `14737632` = `#e0e0e0` | unchanged | 1.24:1 | — see below |
| `m₁` / `m₂` on the spheres | white | white + dark outline | see below | 4.5:1 |

**Why the CM marker changed.** The SWF stacks `69.svg` (a pale
`#d9ffd9` cross at 50 % alpha) over `51.svg` (`#017e01`), which composites to
exactly `#6dbf6d` — verified by sampling the exported sprite render. `#6dbf6d`
is 2.25:1 on white, failing both the 3:1 graphical and 4.5:1 text thresholds.
Omitting the highlight layer leaves the exported dark green, which passes both.
`69.svg` is still shipped in `assets/shapes/` for provenance.

**Why red text changed but red arrows did not.** `#ff0000` is 4.0:1 — enough for
a graphical object (3:1) but not for text (4.5:1). The arrows keep the source
colour; only the `r₂` caption darkens. The slight tone difference between the
red arrow and its red caption is deliberate.

**Why the grid was left at `#e0e0e0`.** At 1.24:1 it is well under 3:1, but the
grid is a decorative scale backdrop: every quantity that could be read off it —
the separation, `r₁`, `r₂` — is also given as text in the relation panel and
spoken with units in the live region and the diagram description. Keeping it at
the source value preserves the original's visual character without withholding
any information. Under `prefers-contrast: more` it darkens to `#949494` (3.0:1)
along with a stronger blue, red and green.

**White labels on grey spheres.** `#ffffff` on the sphere gradient is roughly
3.2:1 at the point where the label sits. The labels keep the original white and
carry a solid `#111111` outline, so the effective background at every glyph edge
is the dark outline (>18:1). Three details make that outline work rather than
smear:

- The glyphs are set with `\mathbf`, matching the SWF's bold labels. MathJax's
  default light italic strokes were thinner than the outline meant to protect
  them, which closed up the counters of the `m`.
- The outline is eight hard offsets at 0.045em/0.032em with **no blur**. The
  earlier version used four offsets at 0.06em plus a 0.12em blur — wider than
  the stroke weight — which read as grime around the glyph.
- The labels are set slightly smaller than the other diagram text so the pair
  sits comfortably inside even the smallest sphere.

This preserves the original look; it is the one contrast decision on this page
that a human auditor should look at and sign off.

**Label centring.** A MathJax container is as deep as the maths inside it, and
`m` with a subscript has depth below the baseline but nothing above, so centring
the *box* on a sphere leaves the visible glyph sitting low.
`calibrateMassLabels()` in `simulation.js` measures the glyph-versus-box offset
against the current font size and publishes it as `--mass-label-shift` for the
stylesheet to subtract. It re-measures rather than latching the first reading,
because MathJax inserts its container before its web fonts arrive and the
fallback font's metrics are different. Measured result: ink centred on both
spheres to within 0.01 stage units in x and y.

**The relation panel is tinted too.** In `m₁r₁ = m₂r₂` and its numeric
substitution, `r₁` and the number standing for it are `#0066ff` and `r₂` and its
number are `#cc0000`, tying each term to its arrow on the diagram. Both clear
4.5:1 as text. The tint is applied through MathML's `mathcolor` attribute rather
than LaTeX's `\color`, which is in a TeX extension the vendored MathJax bundle
does not carry.

**No colour-only signalling.** Every colour-coded thing is also named: the blue
arrow is labelled `r₁`, the red one `r₂`, the green cross is captioned `CM`, the
tinted terms in the relation are themselves the symbols `r₁` and `r₂`, and the
diagram description, the live region and the equation's spoken message state all
of it in words. Removing all colour would lose nothing.

## Text size and reflow

- Body copy is `1.125rem`, headings and control labels scale up from there.
  Everything is sized in `rem`/`em`, so it tracks the browser font setting.
- At 200 % zoom (≈640 px effective width) the layout collapses to one column, no
  content is clipped and there is no horizontal scrolling. Verified at 1265 px,
  640 px, 375 px and 320 px.
- The diagram scales rather than reflowing: the canvas keeps its 428 × 168
  internal coordinate system and the whole stage is sized in percentages, so the
  picture stays proportional at any width.
- **Diagram labels scale with the diagram**, with a `0.55rem` floor. On a phone
  they are small — that is the trade-off for keeping the original's proportions.
  The mitigation is that both distances also appear in the relation panel's
  substitution line at full page-text size in `rem`, so nothing is only legible
  inside the diagram.
- Touch targets: sliders are `2.75rem` tall, checkbox `1.5rem` with a large
  label hit area, value boxes `2.5rem`. Nothing relies on `:hover`.

## Motion

Nothing in this simulator animates — there is no `onEnterFrame`, no timer and no
randomness in the source, and every change is drawn in a single `render()`.
There is therefore no motion to pause and nothing that flashes. No Pause button
is needed or added. A `prefers-reduced-motion: reduce` block is present anyway so
that any future transition inherits the right behaviour.

## Forms

Every input has a real `<label>` with a matching `for`. Each range has a
visually-hidden label of its own (*"object 1 mass slider"*) so it is never
announced as an unnamed control, and the visible label belongs to the value box
it sits beside. The three sliders are grouped in a `<fieldset>` with the legend
*"Masses and separation"*; the checkbox is in a second fieldset,
*"Frame of reference"*.

## Known limitations / human QA still required

1. **Screen-reader QA has not been done with real software.** All of the above
   was verified structurally and programmatically in Chromium. NVDA on
   Windows (Chrome and Firefox) and VoiceOver on macOS and iOS (Safari and
   Chrome) still need a human pass, particularly for announcement ordering
   after a slider release and for how each screen reader reads the MathML
   relation panel.
2. **The white sphere labels rely on an outline** rather than on a raw
   foreground/background ratio. See above.
3. **The grid is intentionally below 3:1** at the default setting, on the
   grounds that it is decorative and its information is duplicated in text. If
   an auditor disagrees, darkening `--com-grid` in `styles/styles.css` is a
   one-line change.
4. **The masthead scrolls horizontally below ≈340 px** because its title and
   three buttons hit their min-content width inside a shadow DOM that must not
   be edited. The page itself never scrolls sideways. Fixing this properly means
   letting `.controls-group` wrap in `kl-unl-masthead.js`.
5. **Safari and Firefox have not been exercised here.** Nothing in the sim uses
   a Chrome-only API and every prefixed property is paired with its standard
   form, but a real pass on iOS Safari — especially the range slider skin and
   touch dragging — is worth doing.
