# Conversion Notes — Small-Angle Approximation Demonstrator

## Behavior model (one paragraph)

An observer (a person looking through a sextant) stands at a fixed origin on the
left. A ball of adjustable **linear diameter** sits at an adjustable **distance**
to the right. The sim draws the two tangent lines from the observer's eye to the
edges of the ball and an arc marking the angle **α** that the ball subtends, and
it displays the **small-angle approximation** for that angle:
`α (arcsec) = 206,265 × (linear diameter / distance)`. The user changes distance
and diameter three ways — dragging the ball, the two sliders, or preset buttons
(distance 20/30/40/50/60, diameter 1/2/3). The slider/drag paths set the value
instantly; the preset buttons *ease* smoothly to the target over 300 ms via a
natural-cubic-spline easer. The whole point is pedagogical: as the ball gets
small/far the true geometric angle (the drawn arc) and the small-angle formula
(the readout) agree.

## Source → ground truth

Decompiled AS-1 (JPEXS). The behavior-bearing scripts:

| Source | Role | Ported to |
|---|---|---|
| `SmallAngleDemo.as` | main controller: state, drag, refresh geometry | §2/§6/§7 of `simulation.js` |
| `Cubic Easing Class.as` | natural cubic spline easer (preset eases) | `CubicEasingClass` (verbatim) |
| `drawArc.as` | tessellated arc via quadratic curves | `drawArc()` (verbatim) |
| `toFixed.as` | number formatting | `toFixed()` (verbatim) |
| `Slider Logic Class v6.as` | value clamp + snap to fixed digits | `snap()` (clamp then round to 0.1) |
| `...frame_1/DoAction.as` = `onReset()` | initial state | `onReset()` / boot |
| `PlaceObject ... on(initialize)` | slider ranges + preset ids + handlers | constants + HTML controls |

### Constants copied verbatim
`centerY = 193`, `originX = 42`, `arcRadius = 200`, `rInPixels = 14.73`,
`distanceEaseTime = diameterEaseTime = 300` ms, formula constant `206,265`.
Distance slider `20…60`, diameter slider `1…3`, both "fixed digits" precision 1
→ values snap to 0.1. Initial state (from `onReset`): **distance 40, diameter 2**.

### Geometry (verbatim from `SmallAngleDemo.refresh`)
```
distPx = rInPixels * distance
pr     = rInPixels * diameter / 2          // ball radius, px
ballX  = originX + distPx
theta  = asin(pr / distPx)                 // half-angle subtended
a      = sqrt(distPx^2 - pr^2)
ax     = originX + a*cos(theta);  ay = a*sin(theta)
tangents: (ax, centerY+ay) -> (originX, centerY) -> (ax, centerY-ay)
arc:      drawArc(originX, centerY, 200, -theta, theta)
alpha label at (originX + 200*cos theta, centerY - 200*sin theta)
ball image diameter (px) = 2*pr        // original ballMC._xscale = 2*pr, base art = 100px
arcsec readout = (206265 * diameter / distance).toFixed(1) + " arcsec"
```
The original draws everything in screen-Y-down coordinates with `sin` negated
(`y - r*sin`); that is preserved exactly so orientation/motion match.

### Drag (verbatim offset + snapping)
`onBallPressFunc`: `xOffset = _xmouse - ballX`.
`onBallMouseMoveFunc`: `setDistance((_xmouse - xOffset - originX) / rInPixels)`,
which clamps to 20…60 and snaps to 0.1. Reproduced with Pointer Events, mapping
the pointer back through the canvas scale into the original stage coordinates.

## Reused exported assets (not redrawn)
- **`assets/person.png`** = `sprites/DefineSprite_66/1.png` — the composited
  observer (the original `personMC`). Drawn with `ctx.drawImage`, scaled and
  positioned so the eye/sextant lands at the origin `(originX, centerY)` where
  the tangent rays converge. **Drawn flipped horizontally** so the observer faces
  the ball (the export, like the original runtime, faces away from it).
- **`assets/ball.png`** = `sprites/DefineSprite_53/1.png` — the beach ball (the
  original `ballMC`). Drawn at displayed diameter `2*pr`, centered at the ball
  position.

Only the genuinely code-drawn art — the tangent lines and the angle arc — is
recreated on the canvas (there is no exported file for it). The formula and the
α label are real HTML typeset by MathJax (see ACCESSIBILITY.md).

## Foundation: one masthead path fix (otherwise byte-for-byte)
`foundation/kl-unl.css` and `kl-unl.js` are copied in byte-for-byte (SHA-256
verified). `kl-unl-masthead.js` has **one deliberate one-line fix** (everything
else identical): its shadow-DOM stylesheet link was
`<link href="../foundation/kl-unl.css">` → changed to `<link href="foundation/kl-unl.css">`.
The `../` only resolves correctly when `index.html` is served at the site root;
on any sub-path host (e.g. a GitHub **project** page at `user.github.io/<repo>/`)
it climbs above the repo and 404s, so the masthead's shadow DOM loses the
`.sr-only` rule and the screen-reader-only copy of the About text becomes
**visible — i.e. the About text appears duplicated.** Because `foundation/` is
always a child of `index.html` in this layout, dropping the `../` makes the path
correct in every deployment (verified: stylesheet loads, the duplicate copy is
hidden again). **Apply this same one-line change to your shared foundation master**
so all sims get it and re-syncing doesn't revert it.

## contents.json  (IMPORTANT — shared master is currently invalid JSON)
**The supplied shared `contents.json` master is
not valid JSON** and the masthead's `JSON.parse` fails on it, breaking the title /
Reset / About for *every* sim. Defects found:
- Raw newline/tab characters inside string literals at **lines 201, 440, 917,
  1156, 1224** (JSON strings may not contain literal control characters).
- **Unescaped double-quotes** in HTML attributes, e.g. the Venus-phases entry has
  `href="../venusphases"` where it must be `href=\"../venusphases\"` (the bare `"`
  closes the JSON string early). Likely more than one.

So `html5/foundation/contents.json` here is a **valid per-sim copy containing only
the `smallAngleDemo` entry** (the prompt's per-sim model), so the build works.
`help.content = ""` → no Help button (the original Title Bar had
`helpLinkageName = ""`). **Replace this file with the shared master once that file
parses as valid JSON.** (The *About duplication* on the hosted site was the
masthead-path bug fixed above, not a data problem.)

## Animation / timing / smoothing
`onEnterFrame` → a single `requestAnimationFrame` loop that runs **only while an
ease is in progress** (`animating` flag), using `performance.now()` for
`getTimer()` and the original 300 ms cubic-ease constants. The original eased only
the preset transitions; **per request the easing now also applies to slider and
ball-drag changes.** It is implemented so the eased value (`disp`) drives **only
the canvas** (ball/rays/arc/α glide), while the slider, its ARIA, and the readouts
use the immediate value (`state`) — so the picture smooths without the slider thumb
fighting the user or the screen reader announcing lagging values.

## Deviations from the original (Goal B over Goal A)
1. **Chrome replaced by the KL-UNL shell.** The original canvas-drawn Title Bar,
   Panel Background, slider widgets, preset buttons, and About dialog are not
   reproduced pixel-for-pixel; the masthead + foundation classes + native
   controls stand in. Behavior is unchanged.
2. **Tangent-line color remapped** from `0xA0A0A0` (fails ≥3:1 on white) to
   `#5f5f5f`; arc `0x000000` → `--foreground-color` `#1a1a1a`. Geometry, widths,
   and meaning unchanged. (See ACCESSIBILITY.md.)
3. **Formula & α moved off the canvas into HTML/MathJax** so every math symbol is
   selectable, zoomable, and exposes the MathJax context menu (prompt rule 8/8a).
   The original baked them as Symbol-font text fields/shapes.
4. **Layout is panel-structured, not the Flash pixel layout.** The Diagram is a
   full-width box on top (so the wide/short diagram and its ball stay legible);
   Distance and Diameter sit below in the foundation `.app-layout`, which places
   them **side by side on PC and collapses them to stacked at the foundation's own
   56rem breakpoint**. The multi-column responsiveness is therefore the template's —
   **there are no sim-specific breakpoints in `styles/styles.css`**, so updating the
   shared template updates every sim. The only sim CSS is cosmetic: equal gaps
   between the three boxes (and zeroing `.app-layout`'s 0.25rem top padding so the
   Diagram→controls gap equals the Distance↔Diameter gap). Note the two control
   boxes inherit the template's `25rem | 1fr` columns, so they are not equal width.
5. **Observer faces the ball** (export/original faced away) and **the angle is
   marked by a small arc at the vertex** at display radius `ANGLE_MARK_R = 54` px
   instead of the source's `arcRadius = 200` (which, for these small angles,
   rendered as a near-vertical line floating mid-diagram). The arc still spans the
   true half-angle ±θ — only the *marker's display radius* and the α label's
   placement (now just outside the arc, clear of the rays) are presentational.

No physics, constant, formula, number format, or educational text was changed.
