# Accessibility — Milky Way Rotational Velocity Explorer

Target: WCAG 2.1 AA (ADA Title II), with AAA where it was free.

The original Flash version was operable by mouse only: a single 10-pixel ring dragged
along a curve, with every readout painted into the SWF as bitmap text. Everything below
describes how that was made usable without a mouse and without sight, while keeping the
physics and the numbers byte-identical (see CONVERSION_NOTES.md).

---

## Structure and semantics

* One `<h1>` — rendered by `<kl-unl-masthead>` inside its shadow root. The page adds no
  competing `h1`.
* `<main>` wraps the two `<section class="panel">` panels, each labelled by its own
  `<h2>`: *Milky Way Disc*, then *Rotational Velocity Plot*. No heading levels skipped.
* `<html lang="en">`.
* Reading order matches visual order at every width; when the layout collapses to one
  column the panels stack as galaxy → plot → equation → hint.

## Text alternatives

| Element | Treatment |
| --- | --- |
| Galaxy photograph (`assets/milkyway-nasa-jpl-caltech.jpg`) | `<img>` with descriptive `alt` |
| Galaxy overlay canvas (the red radius circle) | `role="img"` + `aria-labelledby="srGalaxyDesc"`; that description is rewritten on every state change with the current radius **and unit** |
| Plot canvas (axes, curve, guide lines) | `role="img"` + `aria-labelledby="srPlotDesc"`; rewritten on every change, and it describes the *shape* of the curve, not just the cursor value |
| Sun marker + "NASA/JPL-Caltech" credit | `aria-hidden` decorations; the Sun's position is stated in `srGalaxyDesc` prose instead |
| The equation | MathJax exposes it as MathML; a plain-language sentence sits immediately after it in `#srEqnDesc`, written by `klunlShowEquation`'s `msg1` argument |

## Mathematics — all of it through MathJax

Every mathematical thing on screen is MathJax-typeset from LaTeX: the enclosed-mass
equation, **every axis tick number**, and both axis titles (which carry the `kpc` and
`km/s` units). Nothing mathematical is painted onto the canvas, and nothing is an
image or hand-built `<sub>`/`<sup>`.

Verification: right-clicking any number or symbol in the plot or the equation opens
MathJax's own context menu (*Show Math As → TeX / MathML*). The context menu is not
disabled, and no `contextmenu` handler is attached anywhere.

Typeset math is **display-only and never a tab stop**. MathJax's context-menu extension
gives each `mjx-container` `tabindex="0"`; a `MutationObserver` resets every container to
`tabindex="-1"` as it appears, including on each equation update. The right-click menu
still works at `-1`. Measured: the light DOM's only tab stop is the plot cursor.

## Keyboard

There are two focusable controls, both real `role="slider"` elements rather than canvas
hit regions: the **plot cursor** and the **grip on the red radius ring**. They drive the
same underlying value, so they always agree and share one key map. Tab order is
ring grip → plot cursor.

Both are keyboard-operable because both are mouse-draggable: anything you can do by
dragging, you can do with the keyboard.

| Key | Action |
| --- | --- |
| `Tab` | moves focus between the two controls (and away again — no trap) |
| click / tap | also focuses the control, so the arrow keys work straight afterwards |
| `←` `↓` | move inwards along the curve |
| `→` `↑` | move outwards along the curve |
| `Page Up` / `Page Down` | ten steps at once |
| `Home` / `End` | the innermost / outermost reachable point |

Steps walk the curve by **arc length**, not by distance along the x axis. That matters:
inside about 1 kpc the curve is almost vertical, so an x-based step would move the
cursor a hair while the speed jumped by tens of km/s — the steep inner rise would be
effectively unreachable by keyboard even though a mouse user can scrub it freely.
Roughly 240 arrow presses traverse the whole curve. The keyboard range is clamped to
exactly the stretch the mouse can reach (0.8 – 39.1 kpc, i.e. the same
`_y > -100` velocity clamp the ActionScript applies), so the two input paths cannot
disagree. Both write to the same state object and go through the same `render()`.

Focus is visible: `:focus-visible` draws a ring tightly around the 10 px marker rather
than around its 44 px hit area, and the marker also swaps to the original's larger,
darker roll-over ring while focused.

## Screen-reader narration (NVDA and VoiceOver)

**Units are always spoken, never bare numbers.** The two controls' `aria-valuetext` read,
in full:

> "8.0 kiloparsecs from the galactic center, rotational speed 233 kilometers per second,
> enclosed mass 1.01 times 10 to the power 11 solar masses" *(plot cursor)*
>
> "Measured region radius 8.0 kiloparsecs, rotational speed 233 kilometers per second,
> enclosed mass 1.01 times 10 to the power 11 solar masses" *(ring grip)*

Units are spelled as words (`kiloparsecs`, `kilometers per second`, `solar masses`,
`10 to the power 11`) so nothing is dropped or mangled in speech, while the visible text
keeps the compact symbols (`kpc`, `km/s`, `M☉`).

**Announcement timing.** During a pointer drag the `aria-*` attributes are deliberately
left stale, and are refreshed once on release. Updating them per pointer-move would make
a focused slider speak continuously and drown the user. Keyboard steps commit
immediately, which is standard slider behaviour and what NVDA/VoiceOver expect.

**Channels, chosen so nothing double-speaks:**

* `aria-valuetext` on the cursor — the primary channel for value changes (keyboard steps
  and drag releases). This is the mechanism screen readers already announce for a
  focused slider, so it needs no live region.
* `#srStatus` (`aria-live="polite"`) — used only for events that are *not* a slider
  change, i.e. Reset: *"Simulation reset. Cursor returned to 8.0 kiloparsecs from the
  galactic center, rotational speed 233 kilometers per second."* Keeping drag/keyboard
  results out of the live region is what prevents every change being spoken twice.
* `#srPlotDesc` / `#srGalaxyDesc` — non-live descriptions attached to the two canvases,
  so a reader browsing the page hears what each diagram currently shows.
* `#srEqnDesc` — the spoken form of the equation, written through
  `klunlShowEquation(eqn, msg1, msg2)` exactly as `kl-unl.js` intends.

`aria-live="assertive"` is not used anywhere.

## Colour and contrast

* **The rotation curve was darkened.** The Flash colour is `16740464` = `#FF7070`, which
  reaches only **2.69:1** against the white plot — below the 3:1 that WCAG 1.4.11 requires
  of a graphical object you need in order to understand the content. It is drawn as
  **`#E85C50` (3.45:1)** instead: same hue and weight, just enough darker to pass. This
  is the only colour changed from the source.
* **The galactic-radius ring gained a white casing.** The original 1 px pure-red
  (`#FF0000`) outline sits on a photograph, and against the bright galactic bulge it
  falls to roughly 2.9:1. A 3 px white casing is now stroked underneath the 1.5 px red
  ring, so at every point on the photo one of the two edges clears 3:1 — white against
  the dark sky, red against the bright bulge. The red is unchanged, and the 20 %
  translucent red fill is exactly the original `beginFill(16711680, 20)`.
* Everything else uses the KL-UNL custom properties (`--foreground-color`,
  `--border-color`, `--outline-color`, …). No sim-specific palette is hard-coded beyond
  the two graph colours above and the exported guide-line green (`#009900`, 3.78:1).
* **Colour is never the only signal.** The shaded region's meaning is stated in the
  visible caption, in the equation, in `srGalaxyDesc`, and in the cursor's spoken value.
* A `forced-colors: active` block keeps borders and the focus ring visible in Windows
  High Contrast mode.

## Text size, zoom and reflow

* Body copy is **1.125rem**, above the browser default and above the 1rem the foundation
  sets, and every size in the sim is in `rem`/`em`/`%` — nothing is pinned in `px`.
* No fixed pixel heights anywhere, so nothing crops when text grows.
* Verified with the layout measured, not eyeballed:
  * 1280 px — two columns, no horizontal scrolling.
  * 768 px (iPad) — single column, no horizontal scrolling.
  * 640 px (equivalent to 200 % zoom of a 1280 px window) — no horizontal scrolling,
    tick labels still 42 px apart.
  * 390 px and 320 px (phone portrait) — single column, `window.scrollX` maxes at 0,
    i.e. genuinely no horizontal scrolling; tick labels never collide.
  * 200 % text-only enlargement — no horizontal scrolling; the equation automatically
    reflows from two lines to three so it still fits its box.
* Axis numbers and titles live in HTML, so they scale with the reader's font settings
  instead of being baked into the canvas bitmap. Nothing mathematical remains on the
  canvas, so there is no canvas-baked text that could not be moved.

## Pointer, touch and motion

* One Pointer Events path serves mouse, pen and touch. `touch-action: none` on the
  cursor means dragging it never pans or zooms the page; the rest of the page scrolls
  normally.
* Pointer coordinates are mapped back through the canvas's current CSS scale, so the
  grab offset and the snapping run in the original Flash plot coordinates at any display
  size and match the ActionScript exactly.
* The cursor's tap target is **44 × 44 px** (WCAG 2.5.5 AAA) while the drawn marker stays
  the original 10 px.
* Nothing hover-only: the roll-over ring is decorative, and every affordance is reachable
  by keyboard and touch.
* **No animation exists in this simulation** — the original has no `onEnterFrame`, no
  timer and no motion, so there is nothing to pause and no flashing. A
  `prefers-reduced-motion` block is included anyway to neutralise CSS transitions.
  For the same reason no Pause control was added; Reset comes from the masthead.

## Known limits / still to do by a human

* **Screen-reader QA on real assistive technology is still required.** All of the above
  was verified structurally and programmatically (roles, names, values, tab order, live
  regions, contrast ratios, reflow measurements). It has not been listened to with NVDA
  on Windows or VoiceOver on macOS/iOS. Custom `role="slider"` widgets in particular can
  behave differently under iOS VoiceOver's rotor, and that needs a real ear.
* Cross-browser verification was done in a Chromium engine. Firefox, Safari (desktop and
  iOS) and Android Chrome need a human pass — especially the Pointer-Events drag on iOS
  Safari and MathJax's font rendering.
* The `srPlotDesc` summary describes the curve's overall shape in prose. A reader who
  needs the underlying numbers point by point would be better served by a data table;
  that was out of scope for a parity conversion, but it would be a genuine improvement.
