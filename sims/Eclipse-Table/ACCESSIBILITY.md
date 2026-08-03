# Accessibility notes &mdash; Eclipse Table

Target: **WCAG 2.1 AA** (AAA where reasonable). Tested mentally against **NVDA**
(Windows / Chrome + Firefox) and **VoiceOver** (macOS / Safari + Chrome). Human
screen-reader QA is still required before release.

## Structure & landmarks

* The masthead component renders the single `<h1>` ("Eclipse Table"). Panels use
  `<h2>` in order (Eclipse plot &rarr; Key &rarr; Eclipse list); no heading levels are
  skipped and there is no competing `h1`.
* `<main>` landmark; each panel is a `<section>` labelled by its heading. The table is
  in a labelled scrollable `region`. `<html lang="en">`.
* A **skip link** ("Skip past the eclipse plot points") lets keyboard users bypass the
  138 plot buttons (WCAG 2.4.1).

## Text alternatives (1.1.1)

* The `<canvas>` has `role="img"` with a label and is tied to the visible description
  paragraph via `aria-describedby`. That paragraph states what the plot shows (counts,
  what the axes mean, how to interact).
* Every eclipse dot is a real `<button>` whose **accessible name is a complete,
  units-spelled sentence**, e.g. *"Solar eclipse. Total type. March 20, 2015. Saros
  series 120. Duration 2 minutes 47 seconds. Visible from Iceland, Europe, &hellip;"*
* The ClassAction logo `<img>` has `alt="ClassAction"`; decorative axis labels are
  `aria-hidden` (their content is fully available via the buttons and the data table).

## Colour & contrast (1.4.1 / 1.4.3 / 1.4.11)

* State is **never encoded by colour alone.** Solar vs lunar is given as the word
  "Solar"/"Lunar" in every button name and every table row, plus a "Category" column
  and a text legend. Eclipse type is always a word.
* The **eclipse dot colours are kept physically meaningful** (orange = solar,
  grey = lunar, matching the original and the printed NASA tables) and are supplemented
  with text, so no colour remap was needed for the dots. Body/label/heading text uses
  the KL-UNL palette variables and meets &ge;4.5:1 on the white background. The
  low-contrast dot fills are decorative markers, not text, and each carries a text
  label; the legend swatches are paired with words.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)

* Everything is operable by keyboard in a logical order: masthead (Reset / Help /
  About) &rarr; skip link &rarr; the 138 eclipse buttons **in date order** &rarr; the
  scrollable table region. Visible `:focus-visible` ring (from the foundation, plus a
  clear ring on the small dot buttons). No keyboard traps; the masthead dialog manages
  its own focus and is not fought.
* **Each eclipse point is both Tab-focusable (i) and click/tap-focusable (ii):**
  focusing it (by Tab, or by pointer &mdash; `pointerdown` calls `.focus()`) shows the
  highlight glow and the info panel and voices the point's name. This is the
  keyboard/AT equivalent of the original mouse-hover. (The original has no drag or
  rotation, so there are no arrow-key move semantics to reproduce.)
* There are **no sliders** in this sim.

## Screen-reader narration &mdash; units always spoken (supervisor requirement)

* **Every number is announced with its quantity and unit.** Durations are expanded for
  speech ("04m57s" &rarr; "Duration 2 minutes 47 seconds"; "03h24m (01h18m)" &rarr;
  "Duration 3 hours 24 minutes ( 1 hour 18 minutes)"); Saros as "Saros series 120";
  dates spoken in full ("March 20, 2015"); "-" as "no central duration listed". No bare
  numbers are exposed as a control's value.
* A polite `aria-live` region (`#et-live`) announces the eclipse under the **pointer**
  (for AT users who also use a mouse, and when pointing at a table row). Keyboard focus
  does **not** also push to the live region, to avoid a double read &mdash; the button's
  own accessible name is voiced on focus. Announcements fire on hover/focus commit, not
  on a per-pixel basis, so the region is not flooded.
* The info panel is `aria-hidden` (it is a visual duplicate of the focused button's
  spoken name), so the same content is never read twice from two elements.
* The **Eclipse list `<table>`** gives an audio-only user a comprehensive, ordered way
  to read all 138 eclipses with proper `<th scope="col">` headers, adding **no extra
  tab stops** (it is read with table-navigation commands).

## Timing / motion (2.2.2 / 2.3.3)

* The sim has **no animation, no motion, and nothing that flashes** &mdash; so no Pause
  control is needed. `prefers-reduced-motion` is still honoured (any UA hover
  transitions are disabled).

## Zoom, reflow & responsiveness (1.4.4 / 1.4.10)

* Body copy is &ge;1.125rem and sized in rem/em; the layout is a single column of
  full-width panels that reflows from desktop through iPad to phone portrait
  (verified: no horizontal scrolling at 375px width). The plot keeps its original
  internal coordinates and is scaled by CSS with a preserved 700&times;550 aspect
  ratio; pointer coordinates are handled in that scaled space. Axis labels are HTML
  sized in container units so they stay proportional to the plot yet remain crisp when
  zoomed.

## Touch (2.5.x)

* Pointer Events give mouse and touch one code path; draggable-style scroll hijacking is
  avoided (`touch-action` on the points). The masthead controls and table meet the
  &ge;44px target size.
* **Known target-size limitation (WCAG 2.5.8, AA):** the plot is an intentionally dense
  scatter of ~138 markers only ~15px apart, so the per-dot buttons cannot be enlarged to
  44px without overlapping and mis-targeting. Under 2.5.8 this is the *"essential"*
  spacing-constrained exception, and a fully large-target **equivalent is provided**:
  the Eclipse list table (large rows) lets any user read/inspect every eclipse
  comfortably. This is the recommended path on small touch screens.

## Canvas-baked content

* No text or math is painted on the canvas &mdash; only the reused grid image and the
  dot/glow art. All labels, the logo and the credit live in HTML overlays that zoom and
  are exposed to assistive tech, so nothing legible is trapped in the raster.

## Still requires human QA

Automated/manual DOM checks pass, but real NVDA and VoiceOver passes on actual hardware
are still recommended, especially for reading order through the 138 points and the
table, and for the live-region cadence.
