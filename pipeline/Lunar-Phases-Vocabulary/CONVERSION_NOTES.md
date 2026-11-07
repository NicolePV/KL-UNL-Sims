# Conversion Notes — Lunar Phase Vocabulary

`lunar_phaser.swf` (Flash 6 / ActionScript 1, 300×450 stage) → self-contained
accessible HTML5 on the KL-UNL foundation.

---

## Behaviour model

A photograph of the full moon sits on screen with a translucent black shape
drawn over the unlit part of the disc. Eight buttons — New Moon, Waxing
Crescent, First Quarter, Waxing Gibbous, Full Moon, Waning Gibbous, Last
Quarter, Waning Crescent — jump the moon to that phase (0°, 45°, 90°, 135°,
180°, 225°, 270°, 315° of phase angle respectively) by redrawing the shadow. A
Run Animation button sweeps the phase continuously at one full synodic month
(29.5 days) per 29.5 seconds of wall clock, i.e. one day per second, while a
readout counts the elapsed time in days to one decimal; Stop Animation freezes
both. The shadow's boundary is a four-segment quadratic approximation of a
half-ellipse whose horizontal semi-axis is `101 · cos(phase)`, flipped to the
other side of the disc as the moon passes full — which is what makes the
terminator sweep across as a crescent, quarter, and gibbous in turn. That is the
whole simulation: it teaches the vocabulary by tying each name to a picture.

---

## Source was decompiled as part of this conversion

The folder contained only `lunar_phaser.swf`, `lunar_phaser.jpg` (a screenshot of
the running original), `lunar_phaser.html` (the Ruffle wrapper), and
`foundation/`. There was no decompiled export, so one was produced with the
JPEXS/FFDec already installed on this machine:

```
"C:\Program Files (x86)\FFDec\ffdec.bat" -export all <sim folder> <sim folder>\lunar_phaser.swf
```

That created `scripts/`, `shapes/`, `sprites/`, `images/`, `texts/`, `frames/`,
`buttons/`, `fonts/`, `symbolClass/` beside the SWF. Those are **source**
artefacts and were not modified.

Ground truth for behaviour:

| File | Contents |
| --- | --- |
| `scripts/moonPhaseSymbol.as` | the `moonPhaseClass` prototype class |
| `scripts/frame_1/DoAction.as` | button wiring, speed/alpha setup, elapsed-time text |
| `scripts/frame_1/PlaceObject2_2_moonPhaseSymbol_3/CLIPACTIONRECORD on(initialize).as` | `init_anim`, `init_period`, `init_phase` |
| `texts/*.txt` | all on-screen strings |
| `symbolClass/symbols.csv` | `moonPhaseSymbol`, `moonPhaseImage` linkages |

---

## Constants, verbatim

| AS name | Value | Where used |
| --- | --- | --- |
| `_SYNODIC` | `29.5` | synodic month, days |
| `_MARGIN` | `10` | shadow box overhang beyond the disc |
| `_RADIUS` | `101` | moon disc radius, stage units |
| `_N` | `5` | terminator anchor points |
| `init_anim` | `false` | starts stopped |
| `init_period` | `10` | superseded on frame 1 |
| `init_phase` | `"Full Moon"` | initial phase = 180° |
| `setSpeed("period", 29.5)` | `_speed = 0.001` | one day of phase per second |
| `darkAlpha` | `60` | shadow opacity 0.60 |
| `setPhaseTolerance(12)` | `6.1017°` | `12 · 360 / (29.5 · 24)` |

Verified numerically: initial phase 180°, `_speed` exactly `0.001`, tolerance
`6.1017°`, rate `360/29.5 = 12.203°` per second, and a full 29.5 s run returns
to 180°.

---

## ActionScript → HTML5 mapping

| AS1 idiom | Port |
| --- | --- |
| `Object.registerClass("moonPhaseSymbol", moonPhaseClass)` + `prototype = new MovieClip()` | plain JS constructor + prototype, same method names |
| `attachMovie("moonPhaseImage", "_moon_mc", 1)` | `ctx.drawImage()` of the exported bitmap |
| `createEmptyMovieClip("_mask_mc", 2)` + `beginFill/moveTo/lineTo/curveTo/endFill` | one canvas 2D path with the same coordinates |
| `curveTo` | `ctx.quadraticCurveTo` (same control/anchor points) |
| `beginFill(0, this._dark_alpha)` | `rgba(0,0,0,0.60)` — AS alpha is 0–100 |
| `onEnterFrame` + `getTimer()` | `requestAnimationFrame` + `performance.now()`, elapsed wall clock |
| `_root.myMoon.*` | explicit references on a single `state` object |
| `FPushButton`-style stage buttons | native `<button>` elements |
| `trace()` | dropped |

### Assets: reused, not redrawn

* **`images/3.jpg` → `assets/moon.jpg`** — the moon photograph, a 220×220
  exported bitmap. Drawn with `ctx.drawImage` at its original size and position.
  Never traced or recreated.
* **Code-drawn only:** the terminator shadow. It has no exported file — the
  ActionScript builds it at runtime — so it is the one thing reproduced with
  canvas drawing calls.
* **Not used:** `shapes/42.svg`–`shapes/103.svg` are the *ClassAction* wordmark
  that sat in the original's bottom-right corner. That is site chrome, and the
  KL-UNL masthead supplies the chrome now, so it is omitted (see deviations).
* Button faces were baked `DefineText` outlines in Trebuchet MS/Arial; they are
  real HTML text here, so no fonts were copied.

### Coordinate system

The canvas backing store is the symbol's own 220×220 box with the origin
translated to the disc centre, so every ported expression uses the original
stage units unchanged. CSS scales the element; the drawing and phase maths never
see the on-screen size. Backing resolution is multiplied by
`devicePixelRatio` and re-derived on resize.

---

## contents.json — no edit was required

`foundation/contents.json` **already contains a `lunar_phaser` entry** (title
"Lunar Phase Vocabulary", version 2.0, Help and About text). It matches this
simulation, so the foundation folder was copied in completely unchanged and
nothing was added. All seven foundation files were hash-compared after copying
and are byte-identical to the originals.

If your workflow treats `contents.json` as a single shared file rather than a
per-sim copy, no action is needed either way — there is nothing new to paste.

---

## Faithful reproductions of source quirks

These look like bugs. They are in the original, and the port matches the
original's *observable* behaviour.

1. **`temp.indexof(".")`** in `frame_1/DoAction.as` is spelled lower-case. The
   SWF is version 6, and Flash Player 6 and earlier resolved member names
   **case-insensitively**, so this really did run as `String.indexOf` and the
   zero-padding branch really did execute. Whole days therefore display as
   `"5.0 days"`, not `"5 days"`. Reproduced, and confirmed by test.

2. **`runtime.text = ""`** on frame 1 targets an instance named `runtime`, but
   the text field on stage is `run_time` (with the underscore). Under-scores are
   not folded by the case-insensitive lookup, so this line was a no-op. The
   field starts empty regardless, so the visible result is identical.

3. **`_term_cP[0]` is `null`** but `updateMask()`'s loop starts at `i = 0` and
   dereferences it, producing a `NaN` control point. The matching anchor
   `_term_aP[0]` lands exactly on the pen's current position, so that first
   curve is zero-length and encloses no area either way. The port starts the
   loop at `i = 1`, which is geometrically equivalent.

4. **`getNameFromAngle()` returns `"Third Quarter"`** for 270°, while the stage
   button reads **`"Last Quarter"`**. Both strings are kept verbatim — the
   button label where the button is drawn, the function's own string where the
   simulation names the current phase. They are standard synonyms. See
   `ACCESSIBILITY.md` for how this is handled in speech.

5. **`animateTo()` / `animateFor()` / `_stop_at`** are never called by this
   simulation. The branch is ported anyway so the class matches its source.

---

## Deviations from the original

| # | Deviation | Why |
| --- | --- | --- |
| 1 | Flash pixel layout, palette, fonts and masthead are **not** reproduced | Required: the sim renders in the KL-UNL shell with its classes and palette (Goal B outranks Goal C) |
| 2 | Run Animation and Stop Animation are **one button whose label changes**, not two buttons swapped by `_visible` | Swapping visibility destroys the focused element, dropping keyboard focus to the top of the page mid-interaction. Both labels are verbatim; behaviour is identical |
| 3 | Panel headings "Moon", "Phase Names", "Animation" added | The original had no headings; a non-skipping heading hierarchy is required. They are `<h2>` under the masthead's `<h1>` |
| 4 | *ClassAction* wordmark omitted | Site chrome, replaced by the KL-UNL masthead |
| 5 | Canvas clipped to the bitmap's 220×220 bounds | The shadow box extends to ±111 while the photo spans ±110, so in Flash a 1-pixel 60 %-black hairline fell on the stage background. Clipping removes a stray artefact; nothing inside the disc changes |
| 6 | `requestAnimationFrame` runs **only while animating** | `onEnterFrame` ran always but did nothing when stopped. Equivalent, and leaves the page idle otherwise |
| 7 | Elapsed-time readout is typeset by MathJax | Required: all mathematical content goes through MathJax. The string is unchanged (`5.0 days`) |
| 8 | Illuminated percentage and lit side are stated in the screen-reader description | Additive, screen-reader-only, derived from ported state. Nothing new is shown on screen. See `ACCESSIBILITY.md` |

---

## Foundation issue found (fix belongs upstream)

`kl-unl-masthead.js` lays out its title and its Reset / Help / About buttons with
`display:flex; justify-content:space-between` and no wrapping. Below roughly
360 px the button group runs past the viewport — measured at 320 px, its right
edge reached **354 px against a 320 px viewport** — which dragged the **whole
page** into horizontal scrolling and fails WCAG 1.4.10 (Reflow).

None of this simulation's own content overflows. Since the masthead is copied in
unchanged and its internals live in a shadow root, the containment was applied
from the host side in `styles/styles.css`:

```css
kl-unl-masthead { display: block; max-width: 100%; overflow-x: auto; }
```

The page no longer scrolls horizontally at 320 px. **This affects every sim
using this foundation**, and the proper fix is upstream — letting
`.controls-group` wrap, e.g. `flex-wrap: wrap` on `.masthead-container`. Worth
raising with whoever owns the foundation rather than repeating this patch in
each sim.

---

## MathJax provenance — please confirm

`foundation/` contains **no MathJax include**, so `assets/mathjax/` was copied
from a previously converted sibling sim (`Small Angle Demo v2 - claude`), which
is the established pattern in this collection. It is vendored locally, so there
is no CDN dependency. If the pipeline has since standardised on a particular
MathJax build or moved it into `foundation/`, swap this copy for that one — it
is referenced only from `index.html`.

---

## Verification performed

* **28 automated parity checks** against the shipped `simulation.js` (initial
  state, all six constants, elapsed-time formatting including the `.0` pad, the
  animation rate, a full-period return to 180°, freeze-on-stop, and all eight
  phase-name tolerance boundaries) — all pass.
* **Canvas pixel probe** of all eight phases: the terminator lands at
  `101·cos(phase)` every time (±71 for the 45°/135° family, 0 at the quarters),
  the correct limb is lit, New Moon is fully dark and Full Moon fully lit.
* **Layout measured** at 1280, 768, 640 (≈200 % zoom), 360 and 320 px: no
  horizontal scrolling, nothing clipped or overflowing, all eight phase buttons
  identical in size, tap targets ≥44 px, panels stacking in the original's
  portrait reading order.
* **Served over HTTP** with no console errors; the only requests are
  `foundation/contents.json`, `assets/moon.jpg`, the vendored MathJax and the
  sim's own files.

Not verified by machine, and still needing a human: real screen-reader passes
(NVDA and VoiceOver), and a visual review on Safari/iOS. The preview pane in
this environment could not produce screenshots, so the layout evidence above is
measured geometry rather than a rendered image — worth a quick eyeball before
sign-off.
