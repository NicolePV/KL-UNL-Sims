# Gravity Algebra — Accessibility Notes (WCAG 2.1 AA)

Human screen-reader QA (NVDA on Windows and VoiceOver on macOS/iOS) is still
required before release; the notes below describe what was built in.

## Structure & semantics
- One `<h1>` — the simulation title — is rendered by the `<kl-unl-masthead>`
  component; the sim does not add a competing `<h1>`.
- `<main class="app-shell">` landmark; the equation lives in a `<section>` labelled
  by its `<h2>` panel heading ("Newton's Law of Universal Gravitation").
- `<html lang="en">`.

## Math is real MathJax (not images, not canvas, not ASCII)
- Every symbol — `F`, `F'`, `G`, `M₁`, `M₂`, `R`, the exponent, the fraction bar, the
  five coefficient choices, and the result (whole number or fraction) — is typeset by
  MathJax from LaTeX. Right-clicking any of it opens MathJax's own "Show Math As →
  TeX / MathML" menu, which is **not** disabled or overridden.
- MathJax uses **tex-svg** output bundled locally (`assets/mathjax/tex-svg.js`), so
  glyphs inherit `currentColor` (the coefficients tint red without baking color into
  the math) and the contextual menu works offline.
- The two decorative/aria-hidden math spans that make up the editable equation are
  paired with a full spoken sentence in `#eq-modified-sr` (updated every render), so
  an audio-only user hears the entire modified formula and its result, not just the
  pieces.

## The coefficient control (custom accessible dropdown)
Built as a separate component in `simulation.js` + `styles/styles.css` (the KL-UNL
foundation files are never modified — hard rule 9).
- Each coefficient is a `<button aria-haspopup="listbox" aria-expanded>` whose
  accessible name is a full spoken sentence, e.g. *"The coefficient on mass M 1,
  currently one half. Press to change its value."* The name is updated on every
  change so the current value is always spoken.
- Activating it opens a `role="listbox"` of five `role="option"` items. Because each
  option's visible label is MathJax, each option also carries an `aria-label` with the
  spoken value (`one third`, `one half`, `one`, `two`, `three`) and `aria-selected`.
- **Keyboard map:**
  - Tab / Shift+Tab — move between the three coefficients (and the rest of the page).
  - Enter / Space / ↓ / ↑ (on the button) — open the menu, focus the current choice.
  - ↑ / ↓ — move between choices (wraps); Home / End — first / last choice.
  - Enter / Space — select the focused choice.
  - Escape — close without changing, return focus to the button.
  - Tab — close the menu and move focus onward normally (no keyboard trap).
- **Pointer / touch:** clicking or tapping the button opens/closes it and focuses it;
  tapping a choice selects it; an outside tap closes it. Targets are ≥ 2.75 rem
  (≈ 44 px). No hover-only behavior (the original's auto-collapse-on-mouse-out was
  dropped — see CONVERSION_NOTES).
- Visible focus ring on both the button and the options (`:focus-visible`, using the
  foundation `--outline-color`).

## Live region / narration
- `#sr-status` is an `aria-live="polite"` `.sr-only` region. On each committed change
  it announces what changed **and** the new result, e.g. *"The coefficient on mass
  M 1 set to three. The modified force F prime is now 3 over 4 times the original
  force F."* Reset announces *"Reset. All three coefficients set to one. The modified
  force F prime equals the original force F."*
- Announcements fire only on commit (menu selection / reset), never per keystroke, so
  the region is not flooded.
- There are no physical units in this sim (the result is a dimensionless factor times
  the force `F`); the factor is always spoken **with context** — "… times the original
  force F" — never as a bare number, and fractions are read as "num over den".

## Color & contrast
- The interactive coefficients are red (`#c0170c`, ≥ 4.5:1 on white) **but color is
  never the only signal**: they are also bordered buttons with a caret and a focus
  ring, are in the tab order, and expose their state through `aria-expanded`,
  `aria-label`, and the live region.
- All other text uses the foundation palette variables and meets AA contrast.

## Text size, zoom & reflow
- Body/hint text ≥ 1.125 rem; equations use `rem`/`clamp()` and scale with the
  browser font setting. No fixed-px heights crop text.
- Verified no horizontal scrolling at 375 px (phone portrait); the equation wraps and
  the fraction shrinks via `clamp()` so it stays on screen. Usable at 200% zoom
  (narrow-width reflow is treated the same as a small viewport).

## Motion
- No animation, no flashing, nothing that moves for more than 5 seconds. The only CSS
  transition is the caret flip, which is disabled under `prefers-reduced-motion`.
- Reset is provided by the masthead (`sim-reset`); the sim does not add a second Reset.

## Cross-browser
- Standards-based HTML/CSS/JS (Pointer/keyboard events, CSS grid/flex, native
  `<dialog>` via the masthead, MathJax SVG). No Chrome-only APIs; no prefix-only CSS.
  Should render and operate the same on Chrome, Edge, Firefox, and Safari (desktop and
  iOS); confirm on real devices during human QA.
