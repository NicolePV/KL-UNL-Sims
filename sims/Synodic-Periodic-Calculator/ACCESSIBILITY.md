# Accessibility Notes — Synodic Period Calculator

Target: WCAG 2.1 AA (AAA where reasonable). A final human screen-reader pass with
**NVDA** (Windows) and **VoiceOver** (macOS/iOS) is still required — the notes
below describe what was built and mentally verified, not a substitute for that QA.

## Structure & landmarks

* One `<h1>` only — the simulation title, rendered by `<kl-unl-masthead>` (we add
  no competing `h1`). Panels use `<h2>` ("Configuration", "Calculation") in order.
* `<main class="app-layout">` is the main landmark; each panel is a `<section>`
  with `aria-labelledby` pointing at its heading.
* `<html lang="en">`; every control has a real `<label>` / `<legend>`.

## Keyboard map

| Control                         | Keys                                                        |
|---------------------------------|-------------------------------------------------------------|
| Planets / Units radio groups    | Tab to group, Arrow keys to choose (native radios)          |
| Synodic period **S** field      | Type digits/`.`/`e`; ↑/↓ ±step; PageUp/PageDown ±10×step; Home → 0 |
| Planet period **P** field       | same as S                                                   |
| Reset / Help / About            | Masthead buttons (Enter/Space); dialog traps + restores focus (component-managed) |

* Step size: `0.01` in Years, `1` in Days (matches the unit scale).
* **Tab order contains only the 6 interactive controls** (2 + 2 radios, S, P).
  Verified in-browser: no readouts, labels, event text, or MathJax output are tab
  stops. The read-only Earth value is an `<output tabindex="-1">`.
* Visible focus ring comes from the foundation `:focus-visible` rule; no traps.

## MathJax (all math typeset, none focusable)

* The equation and every variable symbol (`S`, `E`, `P` in the equation, the help
  sentence, and the three value-cell labels) are typeset by MathJax (LaTeX). None
  are canvas-baked. Verified: 7 `mjx-container` nodes render and **right-clicking
  any of them opens the MathJax menu** (Show Math As → TeX / MathML); the context
  menu is not disabled.
* `menuOptions.settings.inTabOrder:false` keeps MathJax out of the Tab order;
  verified zero `mjx-container` elements carry `tabindex="0"`.
* The equation is paired with a spoken description via `klunlShowEquation`'s
  screen-reader message arg, e.g. *"Superior planet relation: one over S equals
  one over E minus one over P."*
* Numbers the user types live in the `<input>` form fields (interactive controls,
  not display math) — the one place math notation is legitimately not typeset.

## Screen-reader narration (units always spoken)

* An `aria-live="polite"` region (`#syn-live`) announces every computed result
  **with quantity name and unit**, e.g. *"Synodic period S is 2.14 years."*,
  *"Planet sidereal period P is 686.98 days."*, or *"Synodic period S: Ouch, no
  valid value for these inputs."* Announcements fire on the input event (the
  natural commit point for a calculator), not on a continuous timer.
* Mode/unit changes announce the new state and that the fields were cleared,
  e.g. *"Units set to days. Earth period E is 365.25 days. Planet and synodic
  period cleared."*
* Every value field carries a units-complete accessible name via `aria-label`:
  "Synodic period S, in years", "Planet sidereal period P, in days", "Earth
  period E, 365.25 days". The visual unit chips (`years`/`days`) are
  `aria-hidden` so the unit is spoken once, from the label, not duplicated.

## Colour & contrast (1.4.1 / 1.4.3 / 1.4.11)

* Palette comes entirely from KL-UNL CSS variables; no hardcoded Flash colours.
* The original's result/error colours (`#1818FF` / `#F800FF`) are **not** used.
  Valid values use the normal foreground colour; the `Ouch!` state uses
  `--alert-color-r` **and** a thickened 2px border **and** the literal word
  `Ouch!` — state is never conveyed by colour alone.
* Foreground/background text meets ≥ 4.5:1; control borders ≥ 3:1.

## Zoom, reflow, responsiveness (1.4.4 / 1.4.10)

* Body copy ≥ 1.125rem; all sizing in rem/em, so text tracks the browser font
  setting and zoom. Verified no horizontal scrolling and no clipping at
  phone-portrait width (375 px) — the value cells stack to one column and the
  Planets/Units groups stack below 30rem.
* Touch targets meet ≥ 44px (radios' `.control-choice` rows are 44px tall); no
  hover-only affordances (calculator is fully operable by keyboard and pointer).

## Motion

* There is no animation in this sim, so there is nothing to pause and no flashing.
  A defensive `prefers-reduced-motion` rule disables any transitions regardless.
* Reset is provided solely by the masthead `sim-reset` event (no second Reset
  button); it restores the exact initial state (Superior, Years, E = 1.00, fields
  cleared) and announces the reset.
