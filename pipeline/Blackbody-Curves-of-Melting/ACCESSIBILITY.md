# Accessibility Notes — Melted Nail Demonstration

Target: WCAG 2.1 AA (AAA where reasonable). The `<canvas>` plots and the `<video>`
are the **visual layer only**; native controls plus `sr-only` descriptions and a live
region are the accessibility layer.

## Structure & landmarks
- One `<h1>` — rendered by `<kl-unl-masthead>` ("Melted Nail Demonstration"); the sim
  does not add a competing `h1`.
- `<main class="app-shell">` with two `<section>` panels, each labelled by an `<h2>`
  ("Melted nail demonstration" is `sr-only`; "Blackbody Curve" is visible).
- `<html lang="en">`.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)
- Tab order contains **only interactive controls**, in reading order:
  masthead buttons → **start/pause button** → **frame slider**. Verified: no other
  tab stops.
- **Frame slider** is a native `<input type="range">`: Left/Down decrement, Right/Up
  increment, Page Up/Down large step, Home/End = first/last frame — all for free.
  It also responds to **mouse wheel** while focused (one frame per notch;
  `preventDefault` so the page doesn't scroll).
- The **button** cycles start → pause → resume → restart, matching the original.
- Visible focus ring via the foundation `:focus-visible` styling; no keyboard traps.
  The masthead dialog manages its own focus/Escape.

## Non-interactive content is not focusable
- Typeset MathJax, axis labels, the plots, the video, and all readouts are **not** tab
  stops. MathJax containers are forced to `tabindex="-1"` by a `MutationObserver`
  (MathJax re-adds `tabindex="0"` asynchronously, so a one-time strip is not enough).
  Verified: 0 focusable math nodes after repeated re-typesetting.

## Math via MathJax (rule 8)
- All math is typeset by locally-hosted MathJax (`assets/mathjax/tex-svg.js`, no CDN):
  the temperature readout `\(300\ \mathrm{K}\)`, the x-axis labels
  (`\(300\ \mathrm{nm}\)` … `\(800\ \mathrm{nm}\)`, `\(0/5/10\ \mathrm{\mu m}\)`), and
  the Wien's-law readout. Right-clicking any of it opens the MathJax "Show Math As"
  menu (not disabled/overridden). During animation the temperature/Wien typeset is
  throttled to ~10 Hz so it stays smooth; the canvas still updates every frame.

## Text alternatives (1.1.1)
- The nail `<video>` is `aria-hidden` and paired with a live-updated `sr-only`
  description: e.g. *"The nail is at 1497 kelvin, glowing bright orange."* (color is
  derived from temperature so audio users get the visual information).
- The plots are `aria-hidden` `<canvas>` paired with an `sr-only` description of what
  they currently show (temperature, peak wavelength in nm and µm, what each plot
  covers).

## Screen-reader narration (NVDA + VoiceOver)
- `aria-live="polite"` status region announces state changes **on commit** (start,
  pause, reset, completion) with units and context — not on every frame (no flooding).
- **Units are always spoken with numbers.** The slider's `aria-valuetext` is e.g.
  *"Temperature 1800 kelvin. Frame 429 of 849, paused."* (never a bare frame number).
  The Wien readout's `sr-only` companion spells units as words
  (*"…peak wavelength is 1610 nanometers, 1.61 micrometers"*).

## Color & contrast (1.4.1 / 1.4.3 / 1.4.11)
- Palette from KL-UNL CSS variables. State is never encoded by color alone: the
  button carries a text label, temperature is text, the visible-spectrum band is
  supplemented by the numeric wavelength axis. The rainbow band is physically
  meaningful and supplemented with the 300–800 nm labels.

## Timing / motion (2.2.2 / 2.3.3)
- Nothing auto-plays: the sim opens paused at frame 1. The animation is user-initiated
  and **pausable** at any time (the button becomes pause/resume), satisfying 2.2.2 for
  the ~42 s playthrough. The scrub slider lets users step through at their own pace.
- No content flashes more than 3×/second.
- `prefers-reduced-motion`: honored implicitly (no motion until the user starts it) and
  incidental CSS transitions are disabled for those users.

## Responsive / zoom (1.4.4 / 1.4.10)
- Body text ≥ 1.125rem (18px), sized in rem/em so it tracks the browser font setting.
- Layout reflows desktop → iPad → phone portrait (foundation 56 rem grid collapse plus
  sim breakpoints in `styles/styles.css`); canvases scale via CSS with fixed aspect
  ratios while the drawing math stays in internal coordinates. No horizontal scroll;
  touch targets ≥ 44px (slider and button). Verified no page-level horizontal overflow.

## Cross-browser
- Standards-based HTML/CSS/JS; Pointer/`timeupdate` events and `<video>` with both
  WebM (VP9) and MP4 (H.264) sources work on Chrome, Edge, Firefox, and Safari
  (desktop + iOS). Vendor-prefixed slider rules are additive only.

## Remaining QA
Human screen-reader QA (NVDA on Windows, VoiceOver on macOS/iOS) is still required, as
automated checks cannot fully substitute for it.
