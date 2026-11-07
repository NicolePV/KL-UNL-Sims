# Accessibility — Lunar Phase Vocabulary

Target: WCAG 2.1 AA (ADA Title II), AAA where reasonable.

**Human screen-reader QA is still required.** Everything below was verified by
inspecting the live DOM, computed styles and measured geometry. No automated
check substitutes for listening to the simulation on NVDA and VoiceOver, and
that pass has not happened yet.

---

## Structure and semantics

* `<html lang="en">`.
* Exactly one `<h1>` — rendered by `<kl-unl-masthead>` from `contents.json`. The
  sim adds no competing `<h1>`.
* `<h2>` per panel: **Moon**, **Phase Names**, **Animation**. No skipped levels.
  (The original had no headings; these were added for structure.)
* Landmarks: `<main>` wrapping the panels, `<section aria-labelledby>` per panel,
  the masthead's own `<nav>`.
* The eight phase buttons are grouped in a `<fieldset>` with a screen-reader
  `<legend>` "Choose a lunar phase".
* A skip link ("Skip to phase controls") is the first focusable element.

## Text alternatives (1.1.1)

The canvas is informative, so it carries `role="img"`, an `aria-label`, and an
`aria-describedby` pointing at a visually hidden paragraph that is rewritten from
`state` on every `render()`. It always states the phase name, how much of the
disc is sunlit, and which limb:

> "Waxing Gibbous, 85 percent of the disc sunlit, on the right side."
> "New Moon, none of the disc sunlit."
> "Full Moon, the whole disc sunlit."

The percentage is the standard illuminated fraction `k = (1 − cos φ) / 2`,
derived from the ported phase — not a new constant. It is **screen-reader only**;
nothing new appears on screen. Without it an audio-only user would hear a phase
name but have no idea what the picture actually looks like.

## The "Third Quarter" / "Last Quarter" wording

The source names 270° two different ways: the on-stage button says **Last
Quarter**, `getNameFromAngle()` returns **Third Quarter**. Both are kept verbatim.
To keep a single utterance internally consistent, pressing a button echoes **that
button's own label**:

> "Last Quarter selected. Third Quarter, 50 percent of the disc sunlit, on the
> left side."

Reads slightly oddly, but it confirms the user's action in their own words while
the standing description stays consistent with the rest of the sim. Both terms
are standard astronomy synonyms. Flagged here in case the pipeline would rather
normalise on one.

## Colour and contrast (1.4.1 / 1.4.3 / 1.4.11)

* Button text `#ffffff` on `#005a9c` (foundation `--button-*` variables) —
  **7.1:1**, exceeds AA.
* Body text `#1a1a1a` on `#ffffff` — well past AA.
* All colours come from the foundation's custom properties. No original Flash
  colours are hardcoded, and no foundation file was edited.
* **No state is signalled by colour.** The moon's phase is conveyed by shape on
  screen and by name plus percentage in text. The shadow overlay keeps the
  source's `rgba(0,0,0,0.60)` because it is the physical subject matter, not a
  status colour.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)

Everything is a native `<button>`, so keyboard support is inherent: Tab / Shift+Tab
to move, Enter or Space to activate. There are no drag or rotate interactions in
this simulation — the original moon is not interactive — so no arrow-key
manipulation path is needed, and none was invented.

Verified tab order (only operable controls, in visual order):

```
masthead: Reset → Review Help Guide → About
skip link
New Moon → Full Moon → Waxing Crescent → Waning Gibbous
First Quarter → Last Quarter → Waxing Gibbous → Waning Crescent
Run / Stop Animation
```

Confirmed **not** tab stops: the canvas, the hidden description, the status
region, and the typeset elapsed-time readout.

* Visible focus ring from the foundation's `:focus-visible` rule; not suppressed
  anywhere.
* No keyboard traps. The masthead dialog manages its own focus and Escape — not
  interfered with.
* Run/Stop is **one button that relabels itself** rather than the original's two
  buttons swapped by `_visible`. Swapping would destroy the focused element and
  dump focus to the top of the page every time it was pressed.

### MathJax kept out of the tab order (rule 8b)

MathJax v3's SVG output puts `tabindex="0"` on every `mjx-container` it builds,
which would add a bogus tab stop **and** place a focusable node inside an
`aria-hidden` subtree — an ARIA conflict axe flags. A `MutationObserver` on the
readout resets it to `tabindex="-1"` on every re-typeset. Verified across
repeated typesets: `tabindex="-1"`, zero focusable descendants.

The MathJax context menu is **not** disabled and `contextmenu` is not trapped, so
right-clicking the readout still opens *Show Math As → TeX / MathML*.

## Mathematics

The elapsed-time readout is the only mathematical content, and it is typeset by
MathJax through the foundation's `klunlShowEquation()` as
`\(12.3\ \text{days}\)` — never plain text, never painted onto the canvas, never
an image. It is paired with a screen-reader string carrying the full spoken form
with its unit. The displayed string is unchanged from the original (`5.0 days`).

Nothing else in this simulation is math notation: the phase names are words, and
the buttons carry no symbols, so there is no canvas-baked math to move into HTML.

## Units are always spoken (explicit requirement)

Every number is announced with its quantity and its unit as a full word — never a
bare number:

* Elapsed time → "Elapsed time 12.3 days"
* Illumination → "85 percent of the disc sunlit"
* Animation rate → "one synodic month, 29.5 days, every 29.5 seconds"

## Live region and narration

A `role="status" aria-live="polite"` region announces **committed changes only**,
never per animation frame:

| Event | Announcement |
| --- | --- |
| Phase button | "Full Moon selected. Full Moon, the whole disc sunlit." |
| Run Animation | "Animation started. The moon advances through one synodic month, 29.5 days, every 29.5 seconds." |
| Stop Animation | "Animation stopped at 12.4 days. Waxing Gibbous, 85 percent of the disc sunlit, on the right side." |
| Masthead Reset | "Simulation reset. Full Moon, the whole disc sunlit." |
| During animation | one announcement each time the moon **enters a new named phase** |

That last one matters: a continuously sweeping moon would otherwise be silent for
29.5 seconds. Announcing on phase-name boundaries gives eight announcements per
cycle — roughly one every 3.7 s — which is the pedagogically useful cadence for a
vocabulary simulation and nowhere near a flood. The text is cleared briefly before
being set so that an identical repeated message is still spoken.

`aria-live="assertive"` is not used; nothing here is urgent.

## Motion (2.2.2 / 2.3.3)

* The moon only ever moves after the user presses Run Animation. Nothing moves on
  load, and nothing flashes.
* **Stop Animation is always available**, satisfying 2.2.2 (pause/stop). This is
  the original's own control, not an added one, so no second Reset or Pause was
  introduced — Reset comes from the masthead's `sim-reset` event.
* Nothing flashes more than three times per second — the shadow sweeps smoothly.
* `prefers-reduced-motion: reduce` collapses incidental transitions. The moon's
  own motion is **not** suppressed, because it is the simulation's subject matter
  — an *essential* animation under 2.3.3, and removing it would remove the
  feature the user deliberately started. It is user-initiated and stoppable at
  any moment. Noted here as a considered decision rather than an oversight.

## Zoom, reflow and responsiveness (1.4.4 / 1.4.10)

* Body text **1.125rem (18px)** — the foundation's pipeline default is 0.9rem;
  this sim raises it per the brief. All sizing is in `rem`/`em`/`%`, so it tracks
  the browser font setting.
* Measured with real viewport resizes: **1280, 768, 640 (≈200 % zoom on a 1280
  screen), 360 and 320 px**. At every width — no horizontal page scrolling,
  nothing clipped, nothing overlapping, all eight phase buttons identical in size.
* Layout collapses to a single column at the foundation's own 56rem breakpoint,
  producing exactly the original Flash portrait order: Moon → Phase Names →
  Animation. Sim-specific breakpoints (30rem, 22rem) carry it down to phone
  portrait; the foundation was not edited.
* `grid-auto-rows: 1fr` keeps the phase grid uniform when a long label would
  otherwise wrap and leave the grid ragged.
* The canvas keeps its original internal coordinates and scales via CSS with a
  preserved 1:1 aspect ratio; the drawing and physics maths are untouched.

## Touch (2.5.5)

* All controls are ≥44 px tall — measured 44 px at every tested width.
* No hover-only affordances; nothing is revealed by `:hover`.
* Buttons are native, so pointer, touch and pen all work through one path. No
  custom drag handling exists in this simulation, so no `touch-action` overrides
  were needed.

## Forms and labels

Every control is a native `<button>` with a real text label. There are no inputs,
sliders or selects in this simulation — none were added, since the original has
none.

---

## Known gaps / for human review

1. **Screen-reader QA on NVDA and VoiceOver has not been done.** The wording
   above is designed against both but has not been heard on either.
2. **The preview pane in this environment could not produce screenshots**, so all
   layout evidence is measured geometry rather than a rendered image. A visual
   eyeball is worth doing before sign-off.
3. **Safari / iOS** has not been exercised. The code avoids Chrome-only APIs and
   prefix-only CSS; `aspect-ratio` (Safari 15+) is a progressive enhancement, as
   the canvas's intrinsic size already keeps it square.
4. **The "Third Quarter" / "Last Quarter" split** described above may warrant a
   pipeline-level decision.
5. **The foundation masthead overflows below ~360 px** and is contained from the
   host side here. The real fix is upstream and affects every sim — see
   `CONVERSION_NOTES.md`.
