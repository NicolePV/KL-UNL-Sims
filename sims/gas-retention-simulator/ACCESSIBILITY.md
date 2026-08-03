# Accessibility Notes — Gas Retention Simulator

Target: WCAG 2.1 AA (AAA where reasonable). Human screen‑reader QA on **NVDA
(Windows / Chrome + Firefox)** and **VoiceOver (macOS / Safari + Chrome)** is
still required — the notes below describe what was built for.

## Structure & landmarks
- Single `<h1>` = the simulation title, rendered by `<kl-unl-masthead>` (no
  competing `<h1>` is added).
- `<main>` holds four `<section>` panels, each labelled by its own `<h2>`
  (Chamber, Chamber Properties, Distribution Plot, Gases). Heading order does not
  skip levels.
- `<html lang="en">`. Every control has a real `<label>`/`<legend>` or
  `aria-label`.

## Canvas text alternatives
- The two `<canvas>` elements are `role="img"` with descriptive `aria-label`s.
- A visually‑hidden **`aria-live="polite"` description** (`#chamberDesc`) is kept
  continuously updated from the single render/state, e.g. *"Chamber holds 2 gases:
  hydrogen 50 percent, xenon 50 percent. temperature 300 kelvin. Simulation
  stopped."* so an audio‑only user gets the same "what's shown" a sighted user sees.
- A separate `aria-live="polite"` status region (`#liveStatus`) announces discrete
  changes (gas added/removed, simulation started/stopped, proportions reset,
  slider commits, cursor moves) **with units**. `aria-live="assertive`" is reserved
  for rare alerts.

## Units are always spoken with numbers
Screen readers only read the accessible name/value, so units are baked into the
accessible value, never left to an adjacent visual label:
- Temperature slider `aria-valuetext` = *"temperature 300 kelvin"*.
- Escape‑speed slider = *"escape speed 1500 meters per second"*.
- Speed cursor = *"1025 meters per second, 94.5% of water moves slower, 5.5%
  moves faster"*.
- Proportion bars = *"xenon 50 percent of full amount"*.
- Gas masses read as *"18 u"*, percentages as *"33.4%"* (via MathJax / fallback).

## Keyboard operability
Everything is reachable in a logical tab order with a visible `:focus-visible`
ring (from `kl-unl.css`); no keyboard traps; the masthead dialog manages its own
focus/Escape and is not fought.

| Control | Keys |
|---|---|
| Temperature / escape‑speed sliders (native range) | ←/↓ decrement, →/↑ increment, PageUp/PageDown ×, Home/End min/max |
| **Speed cursor** (custom `role="slider"`) | Tab to focus **or** click/tap to focus; ←/↓ −25, →/↑ +25 m/s, PageUp/Down ±100, Home/End 0/2000; announced on commit with units |
| **Proportion bars** (custom `role="slider"`) | Tab **or** click/tap to focus; ↑/→ +5%, ↓/← −5%, PageUp/Down ±20%, Home full, End empty; selects that gas on focus |
| Add gas | native `<select>` |
| Buttons (start/stop, remove, reset proportions, masthead Reset/Help/About) | Enter/Space |

Both draggable objects (speed cursor, proportion bars) satisfy the two required
focus behaviours: **(i)** Tab to focus, then arrow‑key move, and **(ii)** click/tap
focuses the same element so arrows work immediately. Pointer and keyboard paths
mutate the same state object. Canvas pointer handlers do not swallow focus or key
events, and Tab always moves away normally.

## Sliders don't get "stuck"
Temperature and escape speed are native `<input type="range">` (full arrow /
Page / Home / End support for free), with `aria-valuetext` carrying the
quantity + value + unit. See CONVERSION_NOTES deviation #2 for the linear/step‑10
choice.

## Colour & contrast
- Text/UI uses the KL‑UNL palette variables (≥ 4.5:1).
- Per‑gas **identity colours are retained** for fidelity with the original, but
  identity is **never** conveyed by colour alone: every gas is simultaneously
  labelled by name and chemical symbol in the gas list, the proportion bars, the
  cursor read‑out, and the plot fill (selected gas). Selection is shown by **bold +
  a background tint + a filled area**, not colour. Curve lines are drawn at ~1.6–2.4
  px (selected thicker) for legibility. A few identity hues (e.g. the CO₂ olive)
  fall below 3:1 against white as thin lines; this is acceptable because they carry
  no unique information — hence documented here rather than remapped, to preserve
  recognisability with the Flash original.

## Motion
- Nothing animates on load and nothing flashes. Motion happens only after the user
  presses **start simulation**, and the same button **stops** it (acts as Pause);
  Reset is provided by the masthead. This satisfies 2.2.2 (moving content is
  user‑started and can be paused).
- `requestAnimationFrame` naturally pauses in hidden tabs.
- `prefers-reduced-motion`: there is no autonomous/looping motion to suppress
  (the idle chamber is static; motion is user‑initiated and stoppable). The CSS
  honours the query and avoids animated transitions.

## Mathematics (MathJax)
- All math/symbols — chemical formulas (H₂O, CO₂ …), axis numbers (0…2000), units
  (m/s, K, u), percentages, and the cursor speed — are authored as **MathJax
  LaTeX** so they are exposed to assistive tech and expose MathJax's "Show Math As"
  context menu (which is **not** disabled). No math is rendered as a raster image
  or ASCII.
- Math lives in **HTML overlays**, never painted on the `<canvas>`: axis tick
  numbers, the x‑axis unit "(m/s)", the cursor speed/percentage read‑outs, gas
  symbols and masses are all HTML so they zoom and are typeset by MathJax. Only
  non‑text graphics (curves, particles, tick marks, dashed line) are on the canvas.
- **Known limitation:** the MathJax library itself was not included in the provided
  foundation export and CDNs are disallowed, so until the foundation's local
  MathJax build is placed at `foundation/mathjax/tex-mml-chtml.js`, the math shows
  as readable Unicode fallbacks (e.g. `H₂O`, `300 K`, `1025 m/s`) and the right‑click
  math menu is unavailable. Once the library is present (as in the production
  pipeline) every symbol is fully MathJax‑typeset. See CONVERSION_NOTES.

## Zoom / responsive
- Body text ≥ 1.125rem, all sizing in rem/em, so text tracks the browser font
  setting and reflows without clipping at 200% zoom.
- Layout reflows desktop → iPad → phone portrait: two columns collapse to one
  stacked column (Chamber, Chamber Properties, Distribution Plot, Gases) with no
  horizontal scroll. Canvases keep their internal coordinate systems and are scaled
  by CSS with preserved aspect ratio; pointer coordinates are mapped back through
  the scale so drag/cursor math stays exact at any size.
- Touch: Pointer Events power both mouse and touch; draggable canvases/cursor use
  `touch-action: none`; interactive targets meet the ≥ 44 px minimum; no hover‑only
  affordances.
