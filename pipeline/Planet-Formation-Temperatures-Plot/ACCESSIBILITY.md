# Accessibility — Planet Formation Temperatures Plot

Target: WCAG 2.1 AA (ADA Title II), with AAA where it came cheaply.
**Human screen-reader QA is still required.** Everything below was verified by
inspection and by scripted measurement in the browser; nothing here replaces a
pass with NVDA on Windows and VoiceOver on macOS and iOS.

## Structure and landmarks

- One `<h1>`, rendered by `<kl-unl-masthead>` from `contents.json`; the page adds
  no competing `h1`. There are two panels, each with an `<h2>`: *Formation
  Temperature and Distance* (the plot and, beneath it, the temperature control)
  and *Condensation Temperatures*. No skipped levels. The temperature control
  needs no heading of its own — it is a `<fieldset>` whose legend, *Formation
  temperature*, names the group.
- `<main class="app-shell" id="main-content">` with a skip link ahead of it;
  each panel is a `<section>` tied to its heading with `aria-labelledby`; the
  masthead supplies `<nav>`.
- `<html lang="en">`.

## Text alternatives (1.1.1)

- The `<canvas>` is `aria-hidden`; it is decorative in the accessibility tree
  because everything it shows is described in prose.
- `#plot-desc` (visually hidden) describes the plot and is rewritten from
  `render()` on every state change: the shape of the trend line, every planet
  with its distance and formation temperature, and where the marker currently
  sits.
- `#states-desc` (visually hidden) lists, by name, which substances are solid and
  which are gaseous at the current temperature.
- The band artwork, the boundary line and the leader lines are `alt=""` /
  `aria-hidden`; the label layers over the canvas are `aria-hidden` because the
  same information is in the descriptions and in the control values.

## Every number is announced with its quantity and its unit

This is the failure this project has hit before, so it is handled explicitly:

| Element | What a screen reader says |
| --- | --- |
| Number field | `aria-label="Temperature in kelvin"` — the visible `<label>` reads *Temperature*, so the accessible name starts with the visible text (2.5.3) and adds the unit |
| Slider | `aria-valuetext="Temperature 600 kelvin"`, rewritten on every change |
| Distance readout | a visually-hidden companion reading *Distance from the Sun 1 astronomical unit* (singular and plural both handled) |
| Marker button | *Formation temperature marker, 600 kelvin, 1 astronomical unit from the Sun* |
| Planet buttons | e.g. *Saturn, 9.529 astronomical units from the Sun, formation temperature 111 kelvin* |
| Live region | *Temperature 600 kelvin. Distance from the Sun 1 astronomical unit. 5 of 9 substances are solid: metal oxides, metallic iron-nickel, silicates, feldspars, troilite.* |

Units are spelled out for speech (*kelvin*, *astronomical unit*) even where the
visible text uses the symbol, and chemical names are spoken in full
(*metallic iron-nickel*, *argon and neon*).

## Live region

`#sr-status` is `aria-live="polite" aria-atomic="true"`. It fires 350 ms after
the last change, so dragging the slider produces one announcement rather than a
flood, and it is never used for anything the user did not just do. Nothing uses
`aria-live="assertive"`.

## Keyboard

Tab order, in visual order: skip link → masthead (Reset, Help, About) → the nine
planet buttons left to right → the marker button → the number field → the slider.
Nothing else is a tab stop.

| Control | Keys |
| --- | --- |
| Slider (`<input type="range">`) | ← ↓ −1 K, → ↑ +1 K (the original's step), Page Down / Page Up ∓50 K, Home 35 K, End 1520 K, mouse wheel ±1 K while focused |
| Number field (`<input type="number">`) | ↑ ↓ ±1 K (native), Page Up / Page Down ±50 K, Home / End min / max, mouse wheel ±1 K while focused, Enter commits |
| Planet / marker buttons | Tab to focus (shows and announces the readout); clicking or tapping also moves focus there, so the readout is never hover-only |
| Masthead dialog | Managed by the foundation component: it traps focus, closes on Escape and restores focus to the trigger. Not interfered with. |

No keyboard traps; Tab always moves on. Focus indicators come from the
foundation's `:focus-visible` rule and are visible on the transparent plot
buttons because they also take a translucent highlight.

Wheel handlers call `preventDefault()` only while the field in question is
focused, so the page still scrolls normally everywhere else.

## Typeset mathematics

Every number, symbol and unit in the interface is typeset by MathJax as inline
LaTeX — the axis tick values, the `AU` in the x-axis title, the `K` beside the
number field, each substance's condensation temperature, the roll-over readout
and the distance readout. Right-clicking any of them opens MathJax's own menu
(*Show Math As → TeX / MathML*); the menu is neither disabled nor
`preventDefault`-ed anywhere.

Typeset mathematics is display-only, so `untabMath()` sets `tabindex="-1"` on
every `mjx-container` (and its `<svg>`) after each typeset pass — MathJax adds
`tabindex="0"` in some configurations, which would put 28 non-interactive nodes
into the tab order. The assistive MathML is left intact, so screen readers still
read the mathematics.

The only text that is *not* typeset is prose: panel headings, help paragraphs,
substance names, and the words *Solid*, *Gas*, *Temperature (Kelvin)* and
*Distance from the Sun*. These carry no mathematical notation, and *Kelvin*
appears as a word inside a verbatim axis title.

## Colour and contrast

- No state is signalled by colour alone. A substance's state is given by which
  side of the boundary line its rail tick falls on (position), by the *Solid* and
  *Gas* labels written on the two regions (text), and by `#states-desc` (text).
- Body text is `#1a1a1a` on `#ffffff` (≈ 16:1). Substance labels are the
  original `#46576d`; on white that is ≈ 7:1, on the 20 %-opacity green band
  ≈ 5.3:1, on the 20 %-opacity blue band ≈ 5.6:1.
- Two colour remaps, both to reach 4.5:1 on their own band: the rotated *Solid*
  label `#009900` → `#006600` (2.9:1 → 5.6:1) and *Gas* `#47adde` → `#005a9c`
  (fails → 6.0:1). The bands themselves are unchanged exported artwork.
- The red boundary line is the original `#ff0000`, kept because it is the
  simulation's one visual anchor; against the pale green above it that is
  ≈ 3.1:1, which clears the 3:1 required of a graphical object (1.4.11). It is
  never the only indicator of anything.
- All palette values come from CSS custom properties in `foundation/kl-unl.css`
  or from the small sim-specific block at the top of `styles/styles.css`.

## Text size, zoom and reflow (1.4.4, 1.4.10)

- Body copy is 1.125 rem, control labels and readouts 1.125 rem, panel headings
  1.125 rem, all in `rem` so they follow the browser's font setting.
- Diagram annotation is smaller, as diagram annotation is: tick values up to
  0.9375 rem, substance labels up to 0.8125 rem. Both are `clamp()`ed against a
  container-relative ceiling so they shrink with the diagram instead of colliding
  when the panel is narrow, and both have a `rem` floor so they never become
  unreadable. The condensation panel's *minimum* height is in `rem` too, so its
  labels and its temperature scale enlarge together; above that floor it grows to
  match the plot panel's height, and a `ResizeObserver` re-spaces the labels
  whenever it does.
- Verified by measurement at 1280 px and at 360 px viewport width, and at 320 px:
  no label overlaps, no clipping, and no element of this simulation extends past
  the viewport.
- At 360 px combined with a **text-only** 200 % font increase (root font size
  doubled without shrinking the window — Firefox's font-size-only mode) the
  x-axis tick values begin to crowd, by up to about 7 px. Ordinary page zoom to
  200 %, which is what SC 1.4.4 and 1.4.10 are measured against, reduces the CSS
  viewport instead and lays out exactly like the verified 360 px case.

## Touch and pointer

- Pointer Events are used throughout, so mouse, pen and touch share one path.
- Buttons, the slider and the number field are at least 2.75 rem (44 px) on their
  smaller axis.
- **Known exception.** The nine planet buttons and the marker button are sized to
  the object they cover, with a floor of 16 graph units (about 24 CSS px at the
  default desktop size). They cannot be 44 px: at 1 AU and 1.524 AU the planets
  are about 27 px apart on screen, so 44 px targets would overlap and make the
  neighbouring planet unreachable. WCAG 2.1 AA does not require 44 px (that is
  2.5.5, AAA), and every one of these targets is reachable by Tab, with its full
  value in its accessible name, so nothing depends on hitting the small target.
- Nothing is hover-only: every roll-over readout also appears on focus, and
  focus follows a click or tap.

## Motion (2.2.2, 2.3.3)

Nothing in this simulation animates and nothing flashes — the original had no
`onEnterFrame` animation either, only the slider's click-and-hold repeat, which a
native range input replaces. There is therefore no Pause control to add. A
`prefers-reduced-motion` block is present so that any future transition inherits
the right behaviour.

## Forms

Both inputs have a real `<label>` with `for`. The pair sits in a
`<fieldset>` with the legend *Formation temperature*. The slider's label is
visually hidden because the visible *Temperature* label belongs to the number
field beside it; its accessible name and `aria-valuetext` are both complete.

## Known limitation outside this simulation's control

At viewport widths below about 400 px the KL-UNL masthead's own shadow DOM
overflows horizontally by a few pixels — its title and its three buttons are laid
out in a flex row that does not wrap, and its padding, gaps and button font size
are hard-coded in `kl-unl-masthead.js`. That file is foundation code and must not
be edited, and its styles cannot be reached from the page stylesheet. Every
simulation in this collection shares the behaviour. This simulation's own content
has zero horizontal overflow at 320 px.
