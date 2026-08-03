# Accessibility Notes — Tidal Bulge Simulator

Target: **WCAG 2.1 AA** (AAA where reasonable). Built on the KL-UNL foundation,
which supplies the palette, focus-visible handling, `.sr-only`, and the masthead
dialog (focus trap + restore + Escape).

Human screen-reader QA is still required — the notes below describe what was
built and reasoned through, not a substitute for testing with real AT.

## Structure & semantics

- One `<h1>` only — rendered by the `<kl-unl-masthead>` component. Panel
  headings use `<h2>` (`.panel__heading`); the heading hierarchy does not skip.
- Landmarks: `<main class="app-layout">`, `<section class="panel">` per panel,
  the masthead's own `<header>`/`<nav>` (Shadow DOM). `<html lang="en">`.
- The `<canvas>` has `role="img"`, an `aria-label` ("Earth–Moon tidal diagram"),
  and an `aria-describedby` pointing at a `.sr-only` description of what the
  diagram shows.

## Keyboard

- **Everything is operable by keyboard.** The three controls are native
  `<input type="checkbox">` elements with real `<label>`s, so they toggle with
  Space and are reachable in a logical tab order. Reset / Help / About are native
  `<button>`s inside the masthead.
- **Tab order contains only interactive controls:** the three checkboxes then the
  masthead buttons. Verified there are no stray `tabindex="0"` values; the canvas,
  the help paragraph, the live region and the description text are **not** tab
  stops.
- Visible focus ring comes from the foundation's `:focus-visible` rule. No
  keyboard traps (the masthead manages its own dialog focus).
- There are **no draggable/rotatable objects and no numeric fields** in this sim,
  so the "focus-then-arrow-keys" and "arrow/wheel to change a value" patterns do
  not apply. Nothing in the original is dragged or typed into — it is three
  toggles driving an animation.

## Color & contrast

- Text and UI use the KL-UNL palette variables (charcoal on white, ≥ 4.5:1).
- **State is never conveyed by color alone.** Each option is a labelled checkbox
  with a checked state; the live region announces every change in words. The Sun
  on/off state is signalled by the day/night shading *and* the "To Sun" label
  *and* the spoken announcement, not by color alone.
- Physically meaningful colors are kept (blue ocean bulge `#6699FF`, olive Moon)
  but are always accompanied by text/labels. No source colors were remapped.

## Screen-reader narration (tested mentally against NVDA + VoiceOver)

An audio-only user can follow the sim through an `aria-live="polite"`,
`role="status"` region (`#sr-status`, visually hidden):

- **On every control change and on Reset** a full sentence is spoken, e.g.
  *"Animation running. Moon to the right of Earth. Sun included: day and night
  shading shown; bulges vary between spring and neap tides. Earth's rotation
  effect on: the tidal bulges lead the Moon by 20 degrees."*
- **While running**, progress is announced only when the Moon crosses into a new
  quadrant (right → above → left → below), not every frame, to avoid flooding.
- The Moon's position is always described in words ("to the right of Earth",
  "above Earth", …) so the pair Earth/Moon is unambiguous in audio.
- The one numeric quantity that carries a unit — the bulge **lead angle** — is
  always spoken as *"20 degrees"* (unit spelled out), never a bare number.

Because the diagram has no numeric readouts (no RA/Dec, temperature, wavelength,
etc.), there are no other unit-bearing values to announce.

## Motion (WCAG 2.2.2 / 2.3.3)

- Nothing animates automatically: **"Run" is the play/pause control and defaults
  off**, so there is no auto-starting motion to stop. The animation loop only
  runs while "Run" is checked.
- Nothing flashes; the animation is smooth continuous motion, well under
  3 flashes/second.
- `prefers-reduced-motion`: the sim never auto-plays, so a reduced-motion user is
  never shown unexpected motion — animation happens only on their explicit
  request via "Run", and can be stopped again at any time. Reset (masthead) and
  "Run" together give full control over motion.

## Math / MathJax

This simulation contains **no equations and no mathematical notation** anywhere
in the UI (the only on-screen text is the label "To Sun"). MathJax is therefore
not required and is not loaded. The foundation's `kl-unl.js` is still included,
and `klunlInitEqn()` is overridden to a no-op. If math is ever added, it must be
rendered through `klunlShowEquation()` per the pipeline rules.

## Responsive / zoom

- Body text is ≥ 1.125rem and sized in rem/em, so it tracks the browser font
  setting and reflows at 200% zoom without clipping.
- The layout uses the KL-UNL responsive grid; below 56rem it collapses to a
  single column (diagram first, then controls), with no horizontal scrolling down
  to phone-portrait widths (verified at 375px: no horizontal overflow).
- The canvas keeps the original 600×550 internal coordinate system (backing store
  multiplied by `devicePixelRatio` for crispness) and is scaled by CSS with its
  aspect ratio preserved, so the ported drawing math never changes.
- Pointer/touch: the controls are native and touch-friendly (≥ 44px targets via
  the KL-UNL control styles). The canvas is display-only (no dragging), so no
  touch-drag handling is needed; there are no hover-only affordances.

## Known items for human QA

- Confirm NVDA (Chrome/Firefox) and VoiceOver (Safari) both read the live-region
  sentences cleanly and do not double-announce on rapid toggles.
- Confirm the quadrant-progress cadence feels informative but not chatty during a
  full orbit.
