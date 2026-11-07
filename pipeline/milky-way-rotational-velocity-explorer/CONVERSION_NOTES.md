# Conversion Notes — Milky Way Rotational Velocity Explorer

Source: `milkyWayRotationalVelocity005.swf` (Flash / ActionScript 1, 10 June 2009),
decompiled with JPEXS. Target: self-contained, accessible HTML5 on the KL-UNL
foundation.

---

## Behaviour model

The explorer shows the Milky Way's rotation curve — the orbital speed of material
as a function of distance from the galactic centre — and lets the reader read the
enclosed mass off it. A single draggable cursor is constrained to the curve: drag it
and it snaps to the nearest point on the curve, green dotted guide lines drop to both
axes, and an equation box recomputes the mass contained inside that radius from
`M = V²R/G`, using the speed and distance at the cursor. At the same time a red shaded
circle on the face-on view of the galaxy grows or shrinks to show exactly which part
of the galaxy that mass belongs to. The point of the exercise is that the curve stays
flat (and even rises) far beyond the visible disc, so the enclosed mass keeps climbing
with radius — the classic dark-matter argument. There is no animation, no timer and no
randomness anywhere in the original: the entire simulation is a pure function of where
the cursor sits.

---

## Source files read

| File | What was taken from it |
| --- | --- |
| `scripts/Milky Way Rotational Velocity.as` | plot scales, the Bezier rotation-curve table, `snapPointToCurve`, `updateDashedLines`, `drawCurve`, `updateEquation`, `G` |
| `scripts/MWRV Draggable Point.as` | the drag: press-offset capture, move, release, roll-over frame swap |
| `scripts/Milky Way Component.as` | `scale = 8.36` px/kpc, `precomputePoints(12)`, `drawDisc`, the 350×350 mask |
| `scripts/Scientific Notation Number.as` | `getCoefficientAndExponent` (the mass formatting, 3 sig figs) |
| `scripts/Number Formatting Functions.as` | `Math.toSigDigits`, the custom `Number.prototype.toFixed` |
| `scripts/DefineSprite_85/frame_1/DoAction.as` | `onPointDragged → milkyWayMC.setRadius(distance)` wiring |
| `scripts/Title Bar.as` + its `on(initialize)` | title text; `helpLinkageName = ""`, `resetHandlerFunc = ""` |
| `scripts/Panel Background.as` + its `on(initialize)` | panel title "Rotational Velocity Plot" |
| `texts/*.txt` | axis titles, "Sun", "NASA/JPL-Caltech", equation field templates |
| `shapes/*.svg`, `images/38.jpg` | all exported art (see *Assets* below) |
| `Capture.PNG`, `frames/1.png` | layout reference (Goal C) |

---

## ActionScript → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `Object.registerClass("Milky Way Rotational Velocity", …)` | plain state object + a single `render()` in `simulation.js` |
| `pointMC._x / ._y` | `state.pointX / state.pointY`, still in **original plot coordinates** |
| `p.snapPointToCurve()` | `snapPointToCurve()` — same clamps, same branch order, same quadratic solve |
| `p.drawCurve()` (`lineStyle` / `curveTo`) | `ctx.quadraticCurveTo` over the same control/anchor table |
| `p.updateDashedLines()` + two mask clips | dots drawn along the same pitch, cut at the same mask boundaries |
| `MilkyWayComponentClass.drawDisc()` | same 12-segment quadratic circle, same fill/alpha, canvas bounds as the mask |
| `attachMovie("MWRV Draggable Point", …, {_x:100})` | initial `state.pointX = 100`, then `snapPointToCurve()` |
| `onPress` / `onMouseMove` / `onRelease` | Pointer Events with the identical `xOffset`/`yOffset` grab maths |
| `onRollOver` → frame 2 (bigger, darker ring) | CSS `:hover` / `.is-active` / `:focus-visible` swapping the two exported SVGs |
| `Number.prototype.toFixed` polyfill | `asToFixed()` — ported verbatim (it is **not** the native `toFixed`; see below) |
| `Math.toSigDigits` | `asToSigDigits()` — ported verbatim |
| `getCoefficientAndExponent` | `asCoefficientAndExponent()` — ported verbatim |
| `equationMC` text fields + fraction-bar shapes | one MathJax `\begin{aligned}` block |
| Title Bar / Dialog Window v2 / Mini About Link | dropped; replaced by `<kl-unl-masthead>` |
| `trace()`, `updateAfterEvent()`, FUIComponent | dropped / no-ops |

### Constants carried over verbatim

```
G                = 0.000004298675311966532      kpc (km/s)^2 / M_sun
plotWidth        = 500     plotHeight   = 250
maxDistance      = 40 kpc  maxVelocity  = 300 km/s
xScale           = 40/500        yScale        = -300/250
pointsXScale     = 0.055031446540880505 / xScale
pointsYScale     = -1.1070110701107012 / yScale
startPoint       = {x: 7.75, y: 0}
pointsList       = the full 17-entry {cx,cy,ax,ay} table, unrounded
Milky Way scale  = 8.36 px per kpc,  12-point quadratic circle
```

### Two faithful oddities worth flagging

1. **`toFixed` is not the native one.** The AS overrides `Number.prototype.toFixed`
   with `Math.round(x * 10^d)`, which disagrees with the native implementation at some
   binary-representation boundaries (e.g. `0.15`). `asToFixed()` reproduces the
   AS version, so the distance readout matches the Flash original digit for digit.

2. **A latent bug in the root-selection fallback is preserved.** In
   `snapPointToCurve`, when neither Bezier root lands in `[0, 1]` the source runs
   `d1 -= 1` / `d2 -= 1` on variables that were never assigned. Both evaluate to `NaN`,
   `d1 < d2` is therefore false, and the second root is always chosen (then clamped to
   `[0, 1]`). The port reproduces this exactly rather than "fixing" it, because the
   fix would move the cursor to a different point than the Flash version does.

3. **One branch of the original is dead code.** `if (x <= leftmostX)` can never be
   true, because the preceding `if (x < 10) x = 10` clamp already exceeds
   `leftmostX ≈ 5.33`. It is ported anyway, unchanged.

### Parity spot-checks (all match the original screenshot / hand-worked AS)

| Input | Result |
| --- | --- |
| initial state (`_x = 100`) | 8.0 kpc, 233 km/s, 1.01 × 10¹¹ M☉ — identical to `Capture.PNG` |
| drag to plot (250, −150) | 20.0 kpc, 249 km/s (matches the AS quadratic solve by hand) |
| grab 30 px off-centre, drag +200 px | cursor lands at plot x = 300 → 24.0 kpc (grab offset preserved) |
| drag below the velocity clamp | pinned to 0.8 kpc / 120 km/s (the `_y > -100` clamp) |
| drag past the right end | pinned to 39.1 kpc / 292 km/s (`rightmostX` / `rightmostY`) |
| Reset | returns to exactly the initial state |

---

## Assets: reused vs. code-drawn

**Reused as-is** (copied into `assets/`):

| Asset | Source | How it is used |
| --- | --- | --- |
| `milkyway-nasa-jpl-caltech.jpg` | `images/38.jpg` | positioned `<img>` with alt text (a standalone photo/illustration) |
| `point-normal.svg` / `point-hover.svg` | `shapes/12.svg` / `13.svg` | the cursor's idle and roll-over markers |
| `sun-marker.svg` | `shapes/42.svg` | the white Sun dot |
| `plot-axes.svg`, `plot-ticks.svg`, `axis-arrowhead.svg`, `dashed-line.svg` | `shapes/64, 65, 79, 15` | geometry source for the canvas axes, ticks, arrowheads and dot pitch |

**Code-drawn on canvas** (no exported file exists — the ActionScript builds these at
runtime with `createEmptyMovieClip` / `beginFill` / `curveTo`): the rotation curve, the
red galactic-radius disc and its mask, and the masked dotted guide lines.

Two notes on how the reused vector art is embedded:

* `point-normal.svg`, `point-hover.svg` and `sun-marker.svg` are **inlined** into
  `index.html` rather than referenced with `<img src>`. The FFDec export writes
  `width`/`height` but no `viewBox`, and an SVG without a `viewBox` used as an image
  does not scale when CSS resizes it — the marker would stay a fixed 10 px no matter
  the display size. The path data is copied verbatim; only a `viewBox` matching the
  exported dimensions is added on the inline element. The untouched exported files
  remain in `assets/` for provenance.
* The axes, ticks and arrowheads must composite (and rotate) with the canvas art, so
  their exported path coordinates are replayed on the 2D context instead of being
  drawn from the SVG file. No geometry was re-derived by hand; the numbers come
  straight out of `shapes/64.svg`, `65.svg` and `79.svg`.

The Verdana faces in `fonts/` were not copied: no sim-specific typography survives
the move to the KL-UNL shell, which supplies its own font stack.

---

## contents.json

The shared file **already contained** a `milkywayrotationalvelocity` entry, so no new
key was added. Two edits were made to the copy in `html5/foundation/contents.json`:

1. **About** — the sentence *"Permission is granted to use these files for
   noncommercial purposes as long as they remain unmodified."* was replaced with the
   Apache License 2.0 block, as instructed. The astro.unl.edu link and the NSF
   #0231270 / #0404988 funding line are kept, and a NASA/JPL-Caltech image credit was
   added.
2. **Help** — the existing one-paragraph description was kept and extended with
   interaction instructions (including the keyboard path) and a description of the two
   panels.

> **Deviation, flagged deliberately:** the Flash original had *no* Help button
> (`helpLinkageName = ""` in the Title Bar's `on(initialize)`). The shared pipeline
> file nevertheless ships curated Help copy for this sim id, and Help text is an
> accessibility benefit, so it was kept and expanded rather than blanked. If the
> project wants the Flash behaviour instead, set `help.content` to `""`.

### ⚠ Pre-existing JSON defects in the shared contents.json — please fix upstream

**The shared `foundation/contents.json` is not valid JSON.** `JSON.parse` rejects it
outright, which means the masthead fails for *every* simulation that uses this file,
not just this one. The console shows
`kl-unl-masthead: Failed to load sim-specific data. SyntaxError: …`.

Seven defects were found and repaired **in this sim's copy only**; the shared master
still has them:

| Line (original file) | Defect |
| --- | --- |
| 1207 (`renaissancePtolemaic`) | unescaped `"` in `<a href="../venusphases">` |
| 1802 (`venusphases`) | unescaped `"` in `<a href="../ptolemaic">` |
| 200–201 (`ce_hc`) | raw newline inside a string literal |
| 439–440 (`eclipsingbinarysim`) | raw newline inside a string literal |
| 916–917 (`meltednail`) | raw newline inside a string literal |
| 1155–1156 (`positionsdemonstrator`) | raw newline inside a string literal |
| 1224 (`pulsarPeriodSim001`) | raw tab character inside a string literal |

The fixes were minimal and mechanical: `"` → `\"`, and the raw newline/tab characters
removed. **These are the only changes made to any foundation file beyond this sim's own
entry**, and they were necessary for the deliverable to run at all. Please apply the
same fixes to the shared master.

Separately, the key `moonphases` appears **twice** in the shared file (once as "Three
Views Simulator"), so the earlier entry is silently discarded. That is legal JSON, so
it was left alone — but it is very unlikely to be intended.

---

## Layout (Goal C) and where it diverges

The panel structure follows `Capture.PNG`: the face-on galaxy view on the left, the
rotation-velocity plot on the right, the equation box floating in the plot's empty
lower-right corner, the axis titles outside the axes. The KL-UNL two-column grid
(`25rem 1fr`, tuned to `24rem 1fr`) lands very close to the original's 350 px + 600 px
split.

Deliberate divergences:

* **The equation box moves.** On wide viewports it is absolutely positioned inside the
  plot, as in Flash. Below the foundation's 56rem breakpoint it becomes a normal block
  under the plot, because an overlay at phone width would either clip or be unreadable
  (WCAG 1.4.10). It also switches from the original's 2-line layout to a narrower
  3-line layout when it would otherwise have to scroll — triggered by a phone-width
  media query *or* by a measured overflow, which is what catches readers who have
  enlarged their browser's default font.
* **Axis numbers and titles are HTML, not canvas paint.** They have to be MathJax-typeset
  (so right-click gives the MathJax menu) and they have to grow with the reader's font
  settings, neither of which canvas text can do. They are positioned from the same
  internal stage geometry the canvas uses, so they stay pinned to their tick marks at
  any size (measured alignment error: ≤ 0.01 px).
* **The galaxy panel gained a heading** ("Milky Way Disc"). The original image panel had
  no title; a heading is needed for a non-skipping heading hierarchy.
* **A one-line usage hint** was added under the plot. The original had no on-screen
  instructions, but the keyboard path needs to be discoverable.
* **Flash chrome is gone** — title bar, `Dialog Window v2`, the "about" link and the
  "astro.unl.edu" mini-link are all replaced by `<kl-unl-masthead>`, per the pipeline
  rules. The version string `milkyWayRotationalVelocity005, 10 June 2009` and the
  player-version readout from the About sprite are not reproduced; the masthead's
  About dialog carries `version: "2.0"` from `contents.json` instead.
* **Reset now exists.** The original set `resetHandlerFunc = ""`, so it had no Reset.
  The masthead always renders one, so it is wired to restore the exact constructor
  state (cursor back to `_x = 100` → 8.0 kpc / 233 km/s).
* **MathJax is self-hosted** at `foundation/mathjax/`. The linked `foundation/` folder
  ships the four required files but no MathJax bundle and no demo page; this follows the
  convention already used by the other converted sims in this pipeline (MathJax 3.2.2,
  `tex-mml-chtml.js` plus its woff fonts), keeping the page free of CDN requests.

## Behavioural additions (nothing removed)

* **The red radius ring is now draggable** (requested; not in the Flash original, where
  the ring was a pure readout). Grabbing the ring — anywhere along it, within 12 px —
  or its grip resizes the measured region, which moves the plot cursor. It is the same
  underlying curve position, reached through `setDistanceKpc()`, so the two controls
  cannot disagree and the physics is untouched: the cursor still lands exactly on the
  curve, and the reachable range is identical (0.8 – 39.1 kpc). The grab offset is
  preserved on press, matching how the plot cursor behaves.
  * A press on the picture *away* from the ring does nothing, so clicking the galaxy
    never yanks the value somewhere unintended.
  * The ring outgrows the 350 × 350 view at about 21 kpc and leaves it entirely at about
    28 kpc. The drag is never clamped — it reads raw pointer distance from the centre, so
    the full range is reachable by dragging outside the panel. The *grip* slides around
    the ring toward the top-right corner to stay on the visible part, and rests in the
    corner once no part of the ring is on screen.

* **Keyboard control of the cursor** — see ACCESSIBILITY.md. Arrow keys walk the curve
  by arc length rather than by x, so the steep inner rise (where a step in x barely
  moves the cursor but the speed changes by tens of km/s) is reachable from the
  keyboard exactly as it is with the mouse. Both input paths write to the same state.
* **A larger hit area.** The visible marker is still the original 10 px ring, but its
  hit/tap target is 44 px (WCAG 2.5.5). A consequence: a click *near* the cursor now
  starts a drag where Flash would have ignored it. The grab-offset maths is unchanged,
  so the cursor keeps its offset from the pointer exactly as before.

## Cross-browser notes

Standards-only: Pointer Events, `aspect-ratio` (with a `padding-top` fallback for
Safari < 15), `ResizeObserver`, `matchMedia` (with the `addListener` fallback for
Safari < 14), canvas 2D, `MutationObserver`. No vendor-prefixed-only declarations and no
Chromium-only APIs. Verified in the Chromium-based in-app browser; Firefox, Safari
(desktop and iOS) and Android Chrome still need a human pass — see ACCESSIBILITY.md.
