# Accessibility Notes — Planetary Configurations Simulator

Target: WCAG 2.1 AA (AAA where reasonable). Human screen-reader QA on **both**
NVDA (Windows) and VoiceOver (macOS) is still required — the notes below describe
what was built in.

## Structure & landmarks
- One `<h1>` — rendered by `<kl-unl-masthead>` (the sim adds none). Panels use
  `<section>` with `<h2 class="panel__heading">` headings, no skipped levels.
- Landmarks: `<main id="main-content">`; masthead provides the header/nav. A
  "Skip to main content" link is the first focusable element.
- `<html lang="en">` is implied via the page; every input has a real `<label>`,
  `aria-label`, or `<fieldset>/<legend>`.

## Text alternatives for the canvases
Each `<canvas>` has an associated visually-hidden description (`aria-describedby`)
that is rebuilt from state on every render:
- **Diagram** — orbit radii (with units), current configuration, and the elongation
  (quantity + number + unit).
- **Zodiac Strip** — what it shows plus the elongation.
- **Timeline** — the counter string and current configuration.

## Color & contrast
- Palette comes from KL-UNL CSS variables; body text uses foreground/background
  vars. Sim-drawn canvas colours (orbit grey, timeline shading) are decorative;
  the meaningful state (configuration, elongation) is **never** conveyed by colour
  alone — it is always given as text in labels, the live region, and the canvas
  descriptions (e.g. "opposition", "128.5 degrees west").
- Orbit-size rows show a small colour dot **and** the text label ("observer's
  planet" / "target planet"), so the dot is redundant, not the sole cue.

## Keyboard operability
Everything is reachable in a logical tab order with a visible `:focus-visible`
ring; no keyboard traps (the masthead dialog manages its own focus).

| Control | Keys |
|---|---|
| Orbit-size sliders (`#a1-slider`, `#a2-slider`) | native range: ←/↓ decrement, →/↑ increment, PageUp/Down large step, Home/End min/max |
| Orbit-size fields | type a value, Enter/blur commits (clamped 0.25–10; `a1 == a2` rejected) |
| Presets | native `<select>` |
| Speed slider | native range |
| Event-action radios / pause field | native radio + number field |
| **Planet handles** (`role="slider"`, `tabindex=0`) | Tab **or** click/tap focuses; ←/↓ and →/↑ rotate by 2° (PageUp/Down 10°); **Shift+arrow** moves that planet's epoch angle only (mirrors Shift-drag) |
| **Timeline** (`role="slider"`, `tabindex=0`) | Tab/click focuses; ↑/↓ (or ←/→) step time by `synodicPeriod/50`; **PageDown → next event**, **PageUp → previous event** |
| **Zodiac strip** (`role="slider"`, `tabindex=0`) | Tab/click focuses; ←/→ pan the strip |
| Animate / Zero counter | native `<button>` |

Both the pointer path and the keyboard path mutate the same `sim` state, so mouse,
touch, and keyboard stay in sync. Pointer Events are used throughout;
`touch-action: none` is set on the draggable canvases and planet handles so
dragging doesn't scroll the page on touch devices. No hover-only affordances.

## Units are always spoken with numbers (supervisor requirement)
Every value with a unit is announced with its **quantity name and unit**, never a
bare number:
- Sliders set `aria-valuetext`, e.g. *"Observer's planet orbit radius 1.00
  astronomical units"*.
- Planet handles: *"Observer's planet at orbital angle 90 degrees. Elongation
  128.5 degrees west, configuration quadrature (eastern)"*.
- Timeline: the full counter string, e.g. *"1.500 years, (1 year, 182.6 days)"*,
  plus the current configuration.
- The live region announces elongation as *"… degrees east/west"* (full words),
  radii in *"astronomical units"*, time in *"years"*.

## Live region
`#sr-status` (`aria-live="polite"`, `role="status"`) announces meaningful changes
**on commit, not per animation frame**: slider/field changes, preset selection,
drag release, event slews, animation start/stop, event reached, counter zeroed, and
reset. The canvas description regions are `aria-live="off"` (read on demand when the
canvas is focused) so they don't flood the reader during animation.

## Timing / motion
- Animation is user-initiated (Start/Stop animation button) and stoppable at any
  time; there is no auto-running motion on load. Reset is via the masthead.
- `prefers-reduced-motion` is respected in CSS (no smooth-scroll); the simulation's
  own motion only runs while the user has explicitly started it, and the physics can
  always be driven statically via the sliders, drags, and event navigation.
- Nothing flashes; no element blinks > 3×/sec.

## Zoom / responsive
- Body text ≥ 1.05rem, all sizing in rem/%/fr with `clamp`/`min`/`max`; layout
  reflows without clipping at 200% zoom.
- Desktop → iPad → phone-portrait: the KL-UNL 56rem column collapse plus a
  sim-specific 40rem breakpoint stack everything into one column in reading order.
  Verified: no horizontal scrolling at 375px width.
- Canvases keep their original internal coordinate systems and scale via CSS
  (`width:100%; height:auto`), so the ported drawing/physics math is unchanged and
  pointer coordinates are mapped back through the live scale factor for hit-testing.

## Known items for human QA
- Verify NVDA and VoiceOver both read a clear name + value + unit for every control
  and that the live-region announcements are not duplicated, truncated, or read out
  of order.
- **No MathJax:** the foundation shipped without a MathJax include and CDNs are not
  permitted; this sim has no equations, only the degree sign and unit abbreviations,
  which are provided as accessible text (see CONVERSION_NOTES.md). Right-clicking a
  readout will therefore **not** open a MathJax menu — there is no MathJax-typeset
  math in this sim to expose.
- Canvas-baked text that could not move to HTML: the orbit labels ("observer's
  planet" / "target planet"), the zodiac "sun"/"planet" tick labels, timeline event
  names and year ticks, and the elongation numbers are drawn on the canvas for
  visual fidelity. Their information is fully available to screen readers via the
  canvas description regions and the live region, but the on-canvas glyphs
  themselves do not scale with browser font settings (they scale with the canvas).
