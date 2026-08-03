# Accessibility Notes — Pulsar Period Simulator

## Structure

- One `<h1>` (rendered by `<kl-unl-masthead>`); two `<h2>` panel headings
  ("Orbit and Pulse Diagram", "Controls"); `<main>` landmark; each panel is
  a labelled `<section>`.
- All controls use native elements: `<input type="radio">` ×2 (grouped by
  `name="motionMode"`, each with a real `<label>`), `<input type="range">`
  for speed, `<input type="checkbox">` for color coding, `<button>` for
  run/pause. Every input has a real, visible `<label>` or fieldset
  `<legend>`; two purely-structural `<legend>` elements are `.sr-only`
  since their fieldset is visually obvious from context (the speed row's
  button+slider grouping, and the single checkbox's own group).

## Color & contrast

- Body copy uses the foundation's `--foreground-color`/`--background-color`
  pair (4.5:1+). The diagram's red/blue pulse and orbit tinting is
  physically meaningful (approach/recede at emission) but is never the only
  signal: motion mode and color-coding are both stated in the live/
  description region, and the plot's y-axis position (interval length)
  conveys the same information as the color even with color vision
  deficiency or in the default color-coding-off / gray state.
- No color-only UI state: the run/pause button uses its text label ("pause"
  vs "run"), not color, to indicate state.

## Keyboard & focus

- Every control (2 radio buttons, checkbox, button, slider) is a native
  element, so full keyboard operability (Tab order, Space/Enter to
  activate, Left/Right/Up/Down/Home/End on the slider) comes for free from
  the browser; `:focus-visible` styling comes from `kl-unl.css`.
- **No draggable/rotatable canvas object.** `Pulsar.as` defines
  drag-handler methods, but they are never wired to any event listener
  anywhere in the decompiled source (see CONVERSION_NOTES.md #1) — the
  pulsar is not draggable in the original's actual behavior, so there is no
  canvas object here that needs the tab-to-focus / click-to-focus /
  arrow-key-move pattern. The Reset button, run/pause button, mode radios,
  checkbox, and slider are the sim's complete interactive surface, and all
  are native controls.

## Screen-reader narration

- `#diagram-desc` is a visually-hidden `aria-live="polite"` region, also
  wired as the canvas's `aria-describedby`. It is updated (not on every
  animation frame) whenever motion mode, color coding, run/pause state, or
  the speed value changes (on slider *commit*, i.e. the `change` event, not
  every `input` tick — avoids flooding), e.g.: "Pulsar motion: circular.
  Animation running. Color coding on. Speed 0.67 times normal rate."
- The speed slider's `aria-valuetext` always announces the quantity name
  and a spoken-safe value — "Speed 0.67 times normal rate" — never a bare
  number, and updates live as the value changes (native range-input
  behavior, so no flooding risk).
- The canvas itself has `role="img"` with a static `aria-label` ("Pulsar
  orbit and pulse-arrival diagram") plus the live `aria-describedby` text
  above, so an audio-only user gets both what the diagram *is* and what
  it's *currently doing*.
- The plot heading ("Interval Between Pulse Arrivals"), its "Time" axis
  caption, and the "earth" label are real HTML text overlaid on the canvas
  (not baked into the canvas pixels), so they're directly readable by
  screen readers and scale/reflow with browser zoom.

## Motion

- The sim's own run/pause button (native `<button>`) satisfies the
  "provide a way to stop motion >5s" requirement; Reset comes from the
  masthead's `sim-reset` event.
- **Deviation from the literal source default:** the original always
  auto-starts the animation on load (and after Reset). This HTML5 port
  additionally checks `prefers-reduced-motion`: if the user has requested
  reduced motion, the sim loads (and resets) in the *paused* state instead
  of auto-running, requiring an explicit "run" click to start continuous
  motion. This is a presentation-only change (per the priority rules,
  accessibility wins over literal default-state parity); the underlying
  physics, controls, and all other behavior are unchanged.
- Nothing flashes; the only continuously moving elements are the orbiting
  pulsar dot, the pulse dash marks, and the plot's scrolling data window,
  all of which stop immediately on pause.

## Zoom / reflow

- Body text sizes are in `rem`; the diagram uses an `aspect-ratio` box with
  a `<canvas>` scaled by CSS (backing resolution stays at the original
  900×600 stage coordinates — see hard rule on canvas scaling), so it
  resizes without ever needing JS-side relayout of the physics/drawing
  code. Overlay text labels are positioned with percentages of the same
  box, so they track the canvas at any zoom level or viewport width.
- Verified no clipping/overlap requirement is addressed by using
  flex/grid-based control rows (`control-grid`, `control-row`) that wrap
  rather than truncate.

## Responsive / touch

- `.controls-panel` uses the foundation's existing two-column → single
  column collapse at the existing 56rem breakpoint (`kl-unl.css`); no new
  breakpoint was needed since the sim has no canvas-embedded controls that
  need their own touch handling (there is no draggable canvas object — see
  Keyboard & focus above).
- All controls meet the ≥44px target size via the foundation's `.button`
  and `.control-choice` input sizing.

## Known limitations / follow-up

- Human screen-reader QA (VoiceOver + NVDA) is still required; the above
  was verified by structural/code inspection only, not a live AT session.
- The exact original pixel position of the "earth" symbol was reconstructed
  by measuring `frames/1.png` (the true 900×600 stage render) rather than
  read from `.fla` data, since no `.fla` source is available for this sim.
