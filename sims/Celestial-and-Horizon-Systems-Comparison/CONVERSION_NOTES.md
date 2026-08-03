# Conversion Notes — Celestial and Horizon Systems Comparison

Source: `celestialHorizon004.swf` (Adobe Flash, ActionScript 1), decompiled with
JPEXS/FFDec. Target: self-contained HTML5 on the KL-UNL foundation.

---

## Behaviour model

The demonstrator shows a single celestial sphere, drawn in orthographic
projection, that the user can rotate freely by dragging. At the centre sits a
small Earth globe carrying an observer's dot, a latitude circle and a longitude
circle; around it are the celestial equator and zero-hours circle (pale yellow),
the observer's horizon and two meridian circles (faint white), and the rotation
axis through the celestial poles (pale blue). A **switch** button runs a
three-second morph between two ways of picturing the same sky: in the
*celestial sphere* view the Earth globe is full size and the observer's tangent
(horizon) plane is shrunk to nothing; in the *horizon diagram* view the globe
shrinks away to the centre while the green horizon plane — marked N, S, E and W
— grows until its rim coincides with the observer's horizon circle on the
sphere, and a stick-figure observer appears standing at the centre. A
latitude slider and text field (−90 to +90, one decimal place, initially 41.0)
move the observer, which re-tilts the horizon and meridian circles and moves the
dot and latitude circle on the globe. A double-headed arrow between the two
labels shades from dark to light to show which view is currently dominant.

---

## Source files read

`CelestialSphere.as`, `2 CS Getter Setter.as`, `3 CS Geometry.as`,
`4 CS Mouse.as`, `5 CS Horizon Plane.as`, `6 CS Shading.as`, `7 CS Objects.as`,
`8 CS Circles.as`, `9 CS Lines.as`, `GlobeComponent.as`, `CSGradientDisk.as`,
`Tangent Plane.as`, `Transition Arrow.as`, `sliderV5Component.as`,
`sliderV5DefaultBar.as`, `FPushButtonSymbol.as`, `symbolClass/symbols.csv`,
`texts/*.txt`, `shapes/*.svg`, and the controller in
`DefineSprite_97/frame_1/DoAction.as` plus its three `on(initialize)` clips.

The decompiled export was produced from the supplied `.swf` with the FFDec CLI
(`-export script,shape,image,text,sprite,frame,symbolClass`); the linked folder
contained only the `.swf`, the reference screenshot and `foundation/`.

---

## ActionScript → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `Object.registerClass` + `prototype = new MovieClip()` | plain JS constructor functions with the same methods |
| `createEmptyMovieClip` / `lineStyle` / `moveTo` / `lineTo` / `curveTo` | `Path2D` + canvas 2D stroking, same coordinates and tessellation |
| the custom `drawArc` closure (quadratic tessellation, `_minStep = π/4`) | identical loop using `quadraticCurveTo` |
| `beginGradientFill("radial", …)` (`CSGradientDisk`) | `ctx.createRadialGradient`, same colours and 0–100 alphas |
| AS colour ints (`16769909`) and 0–100 alpha | `cssColor()` splits the int into RGB and divides alpha by 100 |
| the 22-layer depth stack (`_bEL`, `_bOSB`, … `_fEL`) | a fixed render order in `CelestialSphere.render()` |
| `setMask` with duplicated mask clips `M0`–`M4` | `ctx.save()` + `ctx.clip(path)` + `ctx.restore()`, same mask geometry |
| object `swapDepths` into bands of `_N = 10000` | six sorted arrays (`bE`, `bS`, `bI`, `aI`, `fS`, `fE`) drawn in band order |
| `_x`, `_y`, `_rotation` (degrees), `_xscale`, `_yscale`, `_alpha` (0–100) | an `Instance` object whose `draw()` applies the same transform chain |
| `attachMovie("Linkage", …, initObj)` | direct construction of the matching JS instance |
| `onEnterFrame` + `getTimer()` | one `requestAnimationFrame` loop + `performance.now()`, same 3000 ms constant and elapsed-wall-clock logic |
| `updateAfterEvent()` | dropped (no-op) |
| `onPress`/`onMouseMove`/`onRelease` drag on `_mouseArea` | Pointer Events with the same offset maths, plus a keyboard path |
| `FPushButtonSymbol`, `sliderV5Component`, `FUIComponent` | not ported as a framework; only the observable behaviour, using native `<button>`, `<input type="number">` and `<input type="range">` |
| `Number.prototype.toFixed` polyfill in `sliderV5Component.as` | reproduced verbatim as `sliderToFixed()` so displayed text matches exactly |
| `trace()`, `_root`/`_parent` chains | dropped / replaced by explicit references |

Constants carried over unchanged: `transitionTime = 3000`, `maxGlobeSize = 80`,
sphere radius `150` (size 300), globe sphere size `80`, globe `_radius = 40`,
obliquity terms `0.91706` / `0.39875`, initial view `setThetaAndPhi(90, 30)`,
initial latitude `41`, slider range `−90 … +90` with `initPrecision = 1` in
`"fixed decimal places"` mode, and every circle/line colour and alpha.

---

## contents.json

**No edit was required and none was made.** `foundation/contents.json` already
contains an entry keyed `celestialhorizon` whose `meta.title` is exactly
*Celestial and Horizon Systems Comparison*, with Help and About text following
the shared boilerplate. `index.html` uses
`sim-id="celestialhorizon" json-url="foundation/contents.json"`, and the file was
copied byte-for-byte unchanged along with `kl-unl.css`, `kl-unl.js`,
`kl-unl-masthead.js` and the two favicons (verified by SHA-256).

The original SWF contains no Help or About text of its own — its only text
assets are the strings `N`, `S`, `E`, `W`, `celestial sphere`,
`horizon diagram`, `latitude:` and the field placeholder `88888`. Because the
existing Help entry is brief, the operating instructions (drag to rotate,
keyboard equivalents) are given in the on-page `.panel__help` paragraph rather
than by editing the shared JSON.

---

## Assets: reused vs code-drawn

Copied into `assets/` from the export and used as-is, never redrawn:

| File | Flash symbol | Used for |
| --- | --- | --- |
| `sphere-shading.svg` | `Sphere Shading` (shape 37) | the sphere's inner shading, front and back |
| `horizon-plane-above.svg` | `CSAboveHorizonPlane` (shape 39) | the lit face of the tangent plane |
| `horizon-plane-below.svg` | `CSBelowHorizonPlane` (shape 47) | the dark face of the tangent plane |
| `globe-water.svg` | `GlobeComponentWater` (shape 55) | the Earth's oceans |
| `globe-land.svg` | `GlobeComponentLand` (shape 58) | the Earth's land, clipped by the shoreline mask |
| `observer-dot.svg` | `Observer Dot` (shape 71) | the observer's position on the globe |
| `stickfigure.svg` | `Stickfigure` (shape 1) | the observer in the horizon diagram |
| `arrow-head.svg` | `Arrow Head` (shape 69) | the transition arrow heads |

Each is drawn at its original registration point (recorded in the `ART` table in
`simulation.js`). `arrow-head.svg` is the one asset that is *also* inlined —
its exported path data is placed directly in `index.html` so the arrowheads can
be recoloured as the transition runs, which an `<img>` cannot do; the file is
kept in `assets/` as the source of that geometry.

Reproduced with canvas 2D because the ActionScript builds them at runtime and no
file exists for them: the great and small circles, the polar axis lines, the
five mask shapes, the `CSGradientDisk` radial gradient, and the Earth's
shoreline mask (the 22 coastline polygons from `GlobeComponent.as p._shoreData`
are copied verbatim into `SHORE_DATA`).

There are no bitmaps in this SWF and no sim-specific fonts (the direction labels
are 12 px device text).

---

## Deviations from the original

1. **Chrome, palette, layout and fonts** follow the KL-UNL foundation and the
   accessibility rules rather than the Flash pixel layout. The control box sits
   to the **right** of the diagram on desktop and tablet, and moves **below** it
   below the foundation's own 56 rem breakpoint. This departs from the
   original's single stacked column (the screenshot puts the controls directly
   under the diagram) in order to use the two-column KL-UNL grid on wide
   screens; the panel grouping, the contents of each panel and the reading
   order are unchanged — DOM order is still diagram → controls, so the stacked
   mobile layout reproduces the original arrangement exactly. Within the
   controls panel the order is still the `celestial sphere ← switch → horizon
   diagram` row followed by the latitude row.

2. **Transition-arrow colours remapped.** The original fades the labels and
   arrow between `#e0e0e0` and `#000000`. `#e0e0e0` on white is about 1.3:1 and
   fails WCAG 1.4.3, so the endpoints are `#767676` (4.54:1) and `#1a1a1a`. The
   interpolation formula from `Transition Arrow.as` is unchanged. The active
   view is additionally shown in bold and named in hidden text, so state is
   never signalled by colour alone.

3. **Direction labels placed symmetrically.** In the original the N/S/E/W
   glyphs sit at slightly asymmetric offsets (a side effect of their text
   bounding boxes). They are drawn centred at a radius of 88 in the plane's own
   coordinates, which reads as the same layout but is visually even.

4. **Keyboard rotation added.** The original rotates the sphere by mouse drag
   only. The canvas is now focusable and rotates with the arrow keys (5°),
   Page Up/Down (15° in altitude) and Home/End (altitude limits). Both paths
   drive the same `setThetaAndPhi` state, so results are identical.

5. **Reduced motion.** With `prefers-reduced-motion: reduce`, pressing
   **switch** jumps straight to the equivalent end state instead of animating
   for three seconds. The physics and end state are unchanged.

6. **Reset** is provided by the masthead's `sim-reset` event (no second Reset
   button). It restores latitude 41.0, transition parameter 1, direction 1 and
   the initial view (θ 90°, φ 30°) — verified to reproduce the first frame
   pixel-for-pixel.

7. **Latitude entry** uses a native number input plus a native range slider in
   place of the Flash `sliderV5Component`. Clamping to ±90, rounding to the
   nearest 0.1, and the displayed text formatting all follow the original
   `setValue`/`toFixed` code exactly. The original's "hold on the bar to
   auto-repeat" behaviour is replaced by the native slider's own key and drag
   handling.

8. **`updateCircles(notHorizon)`** — the ActionScript guards its
   "skip horizon-system circles" branch with `if (!circle._sys == 0)`, which is
   true for both `_sys` values, so every circle is redrawn either way. The port
   reproduces the observed behaviour (always redraw) rather than the apparent
   intent.

9. **Masthead overflow below ~361 px.** The foundation masthead's title/button
   bar is a non-wrapping flex row and needs about 361 px. Its code must not be
   edited, so `styles/styles.css` confines the overflow to the bar itself
   (`kl-unl-masthead { overflow-x: auto }`) and the page body never scrolls
   horizontally. The upstream fix would be `flex-wrap: wrap` on
   `.masthead-container`.

10. **Pre-existing foundation typo.** `foundation/kl-unl.css` contains a stray
    `u` on its own line just before `.app-layout__right`, which turns that rule
    into `u .app-layout__right { … }`. It is left untouched (foundation files
    are copied unchanged) and has no effect on this simulation, which does not
    use `.app-layout__right`.

---

## Open question for the maintainers: MathJax

The `foundation/` folder supplied with this simulation contains
`kl-unl-masthead.js`, `contents.json`, `kl-unl.css`, `kl-unl.js` and the two
favicons — **but no MathJax include**, and there is no `demo_01.html` to show
which include the pipeline expects. `kl-unl.js` calls
`MathJax.typesetPromise()` only when `window.MathJax` exists, and the
no-CDN rule forbids fetching MathJax from the network.

The only mathematical content in this demonstrator is the observer's latitude,
which the original shows as a plain number in a text field. It is routed through
`klunlShowEquation()` as `\( \phi = 41.0^{\circ} \)` with a paired screen-reader
message. Because printing raw LaTeX would be worse than printing nothing, the
equation container is hidden while `window.MathJax` is absent; the value and its
unit are still announced through the control's `aria-valuetext` and the
`sr-only` message.

**Dropping a local MathJax into `foundation/` and adding its `<script>` to
`index.html` (one line) makes the typeset equation appear with no other change.**
Please confirm which MathJax build the pipeline standardises on.
