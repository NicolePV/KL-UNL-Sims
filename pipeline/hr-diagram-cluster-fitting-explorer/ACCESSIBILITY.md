# Accessibility Notes — HR Diagram Star Cluster Fitting Explorer

Target: **WCAG 2.1 AA** (AAA where reasonable). This records the affordances
added and how they were verified. Automated/geometry checks are not a substitute
for **human screen-reader QA (NVDA on Windows, VoiceOver on macOS/iOS)** — that
is still required before release.

## Structure & landmarks
- One `<h1>` — rendered by `<kl-unl-masthead>` (the simulation title). No
  competing `<h1>` is added.
- `<main>` wraps the layout; each panel is a `<section>` with an
  `aria-labelledby` `<h2>` heading (`HR Diagram`, `Cluster Selection`,
  `Diagram Options`, `Distance Modulus Calculator`). `<html lang="en">`.

## Keyboard map (2.1.1 / 2.1.2 / 2.4.7)
Tab order contains **only** the five interactive controls, in reading order:
**diagram fit slider → cluster select → show-bar checkbox → `m` input →
`M` input**. Verified: no MathJax output, tick label, readout, or the canvas is
ever a tab stop; the reference bar is only in the tab order while shown.

| Control | Keys |
|---|---|
| **Diagram fit** (`role="slider"`, vertical) | ←/↓ −0.1, →/↑ +0.1 mag of distance modulus; PageDn/PageUp ±1; Home = −10, End = +20. Both pointer drag and keys mutate the same state. Click/tap also focuses it, so arrows work immediately. |
| **Horizontal reference bar** (`role="slider"`, shown via checkbox) | ↑/← move up (brighter, lower magnitude), ↓/→ move down; Page keys ±1; Home = top, End = bottom. |
| Cluster `<select>`, checkbox, `m`/`M` inputs | native keyboard behaviour. |

Visible focus ring comes from the foundation `:focus-visible`. No keyboard
traps; the masthead dialog manages its own focus/Escape and is not fought.

## Draggable objects — both paths (per spec)
Every mouse-draggable object is (i) reachable by **Tab** and (ii) focused on
**click/tap** (`.focus()` on `pointerdown`), after which arrow keys move it.
Pointer and keyboard update the same state object; results are announced with
units on commit. Pointer coordinates are mapped back through the live canvas
scale, so drag/offset math matches the ActionScript at any display size.
`touch-action: none` on the draggables prevents the page scrolling during a
drag on touch devices; nothing relies on hover.

## Mathematics — MathJax only (2.x)
Every symbol, variable, subscript and expression in the UI is typeset by
**MathJax** (locally vendored, CHTML output): axis-title variables `M` and `m`,
all axis tick numbers, the horizontal-bar readouts, and the calculator formula
and result. The plain numbers and the `(M)`/`(m)` axis variables use
`\text{…}` with `chtml.mtextInheritFont`, so they render in the page's own
sans-serif font (matching the surrounding labels) while remaining real MathJax.
Verified: right-clicking any math opens the MathJax **"Show Math As"**
context menu (the menu is enabled, never trapped or `preventDefault`-ed). No
math is a raster image, ASCII, or painted on the canvas. Typeset math is
display-only and kept out of the Tab order (`tabindex="-1"` applied to any
MathJax node that would otherwise become focusable). Each equation is paired
with a units-complete screen-reader description (below).

## Text alternatives & screen-reader narration (1.1.1, 4.1.3)
- The canvas is `aria-hidden`. A visually-hidden **diagram description**
  (`#cfe-diagram-desc`) is continuously rebuilt from state: axes and their
  units, the model curve, the selected cluster and star count, the current
  distance modulus, and the reference-line magnitudes.
- A polite live region (`#cfe-live`, `role="status"`) announces state changes
  **on commit** (drag/keys release, selection, checkbox, reset) — never per
  tick — to avoid flooding.
- **Units are always spoken with numbers** (explicit requirement). Values are
  put in the accessible value itself, e.g.
  `aria-valuetext="Distance modulus m minus M, 9.5 magnitudes."`,
  `"Reference line. Absolute magnitude 3.5, apparent magnitude 7.0."`; the
  calculator's SR line says `"m minus M equals 10 magnitudes. Distance d equals
  1000 parsecs."` Sign is spoken as "minus"; units are full words
  ("magnitudes", "parsecs", "kelvin").
- Inputs have real accessible names with quantity + unit
  (`"m, apparent magnitude"`, `"M, absolute magnitude"`).

## Colour & contrast (1.4.1 / 1.4.3 / 1.4.11)
Colours are the original Flash semantics, kept because they are meaningful and
already pass AA on the white plot:

| Use | Colour | Contrast on white |
|---|---|---|
| Absolute-magnitude axis + model curve | red `#d03030` | ≈ 5.1 : 1 (text) |
| Apparent-magnitude axis + star points | blue `#1d5ef3` | ≈ 5.3 : 1 |
| Temperature axis, border | near-black `#1a1a1a` | ≥ 12 : 1 |

Colour is **never the sole signal**: the red/blue axes are also labelled
"Absolute Magnitude (M)" / "Apparent Magnitude (m)"; the curve is a line and the
data are points (distinct shapes); every value is stated numerically. Red vs.
blue is distinguishable across common colour-vision deficiencies. No remap was
required for contrast, so none was made.

## Text size, zoom & reflow (1.4.4 / 1.4.10)
Body copy is ≥ 1.125 rem, all sizing in rem/em, so it tracks the browser font
setting. The canvas keeps its internal coordinate system and is CSS-scaled with
a fixed aspect ratio; tick numbers are HTML (they zoom). Verified usable with no
clipping at 200% zoom and reflowing to a single-column **phone-portrait** layout
(≤ ~26 rem) with **no horizontal scrolling**; touch targets are ≥ 2.75 rem.

## Timing / motion (2.2.2 / 2.3.3)
The simulation has no autonomous animation (rendering is event-driven), so
nothing moves for >5 s and nothing flashes; no Pause is needed.
`prefers-reduced-motion` is honoured (any incidental transition is zeroed).

## Known limitations / QA still needed
- Human screen-reader passes on **NVDA + VoiceOver** (desktop and iOS) and
  manual testing in **Safari and Firefox** are still required.
- The diagram description summarises the cluster (name, star count, fit state)
  rather than enumerating hundreds of individual stars; per-star values are not
  individually announced (matching the original's non-verbal plot).
