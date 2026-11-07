# Sun's Rays Simulator — conversion notes

## Behaviour model

The simulation shows the Earth drawn face-on with its rotation axis vertical, lit by a
bundle of thirteen horizontal yellow rays arriving from the left; the half of the globe
turned away from the rays is covered by a translucent black "night" rectangle. Pressing
**Start** runs one simulated year in thirty real seconds: a phase angle `theta` advances
with elapsed wall-clock time, the ray bundle and the night rectangle are both rotated by
`rotangle = 23.5 * sin(theta)` about the centre of the globe, and the calendar date is
advanced through a fixed 365-day month table. Two readouts follow along — the latitude
where the rays strike most directly (`at latitude: <value>° N/S`, truncated rather than
rounded, and pinned to `23.5` within a day of either solstice) and the current date, with
a caption naming the equinox or solstice that fades in and out over a ±8-day window
around days 80, 172, 264 and 355. **Stop** freezes everything in place. The simulation
has no other controls: nothing is draggable, there are no sliders, and the original had
no equation display.

## Source of truth

The delivered folder contained only `sunsrays.swf`, `sunsrays.html` and `sunsrays.jpg`
(no pre-made decompilation). The SWF was decompiled locally with JPEXS/FFDec and the
port was written from that export; the decompiled files were kept outside the project
folder and nothing in the original folder was modified.

All of the simulation's behaviour lives in one script, the main-timeline
`scripts/frame_1/DoAction.as`. The export also contains a complete set of Flash UI
component classes and a `simulator` class (`SliderV3*`, `FRadioButtonSymbol`,
`FUIComponentSymbol`, `lock_radio`, `helpWindow`, and the `simClass` distance-modulus
logic, plus the text strings `Distance Modulus Explorer` and its Help paragraphs). None
of those symbols is placed on this SWF's stage and none of that code ever runs — they are
leftovers from the Distance Modulus Explorer that shared the source `.fla`. They were
deliberately **not** ported; the port carries no sliders, radio buttons or in-sim help
window, because the Sun's Rays Simulator never had them.

## ActionScript → HTML5 mapping

| Original (AS1) | Port |
| --- | --- |
| `monthArray` (12 × `[name, days, cumulative]`) | `MONTH_ARRAY`, copied verbatim including the space-padded month names |
| `month = 2; day = 21; totaldays = 80; theta = 0` | `INITIAL`, the exact state that Reset restores |
| `_root.onEnterFrame` + `getTimer()` | one `requestAnimationFrame` loop; `performance.now()` supplies the same elapsed-millisecond deltas |
| `period = 30` | `PERIOD = 30`; `theta_inc = dt * 2π / (period * 1000)` unchanged |
| `theta > 6.283185307179586` wrap, `totaldays = 80 + theta*365/2π` | ported line for line, including the fact that `totaldays` is re-seeded *before* the increment |
| month roll-over (`day = totaldays - monthArray[month][2]`, `month += 1`, December wrap) | ported line for line |
| `date_string = monthArray[month][0] + "  " + Math.ceil(day)` | same expression; whitespace collapsed at display time (see deviations) |
| `tol = 8`, `inc = 100/tol`, four season tests | `SEASON_TOL`, `SEASON_INC`, `SEASONS` table; the caption's alpha becomes CSS `opacity` |
| `rotangle = 23.5 * Math.sin(theta)` | `state.rotangle`, drives both the canvas transform and the HTML label rotor |
| `LineGroup._rotation = rotangle` | `ctx.translate(349.95, 208); ctx.rotate(rad); ctx.scale(1.2857208, 1)` — the same `rotate ∘ scale` matrix Flash builds — plus `transform: rotate(…)` on the HTML label layer |
| `ShadowBox._rotation = rotangle` | same transform with the shadow's own placement matrix and scale `(1.3512421, 0.75772095)` |
| `String(Math.abs(rotangle))` + `substr(0,3)` / `substr(0,4)` truncation, `lat1 > 10` string/number comparison | ported exactly; JavaScript coerces the string operand the same way AS1 does |
| solstice pin: `Math.abs(totaldays - 172) < 1 \|\| Math.abs(totaldays - 355) < 1 → "23.5"` | ported exactly |
| `degsym = unescape("%ba")` | `DEG_SYM`; the visible readout is typeset as `^{\circ}` by MathJax (see deviations) |
| `Start` / `Stop` buttons swapping `_visible` | one `<button>` whose label toggles between `Start` and `Stop` |
| `Math.radian` / `Math.degree` helpers | unused by this sim; dropped |
| `stop()` on frame 1 | not needed; only frame 1 ever ran |

## Assets: reused vs. code-drawn

| Element | Source | Treatment |
| --- | --- | --- |
| Earth globe | `images/167.png` (438 × 438 bitmap with a transparent surround, used as the fill of shape 168) | **Reused as-is**, copied to `assets/earth.png` and drawn with `ctx.drawImage` at its original placement (centre 350, 258; radius 219 × 0.6986389 = 153.0) |
| 13 sun rays (shape 150) | code-placed line shape, rotated at runtime | Redrawn on canvas with the original coordinates (`x` −349.95 → 0.05, `y` −150 → +150 step 25) |
| Latitude lines (shape 170) | static line shape | Redrawn on canvas with the exact path coordinates |
| Earth's axis (shape 157) | static line shape | Redrawn on canvas, kept at its original z-order **beneath** the globe (where the original also left it effectively hidden) |
| Night shadow (shape 171 + colour transform) | black rectangle at alpha 179/256 | Redrawn on canvas with the same rectangle, transform and alpha |
| `NP`, `SP`, `EQ`, `Arctic Circle`, `Tropic of Cancer`, `Tropic of Capricorn`, `Antarctic Circle` | Flash `DefineEditText` fields | Moved into HTML at the original stage positions (see below) |
| `Least Direct` ×2, `Most Direct` (DefineText 152/154) | text inside the rotating `LineGroup` | Moved into an HTML layer that rotates with the same angle |
| Two yellow readout boxes (shape 190, `#fcca04` with a 3 px black border) | static shape | Rebuilt as HTML `<output>` boxes with the same fill and border |
| Title, masthead, Help/About | Flash title text and the unused `helpWindow` symbol | Provided by `<kl-unl-masthead>` |
| Panel backgrounds (shapes 147/148/149) | static shapes | Replaced by KL-UNL `.panel`; the diagram's `#f3f3f3` fill is kept as the canvas background |

Two further `Arctic Circle` text fields (characters 161 and 162) sit at the same stage
position underneath the globe and are invisible in the original. They were not ported.

## `contents.json`

**No edit was required.** The shared `foundation/contents.json` already contains a
`sunsrays` entry with the correct title, version, Help text and About boilerplate, so the
foundation folder was copied in completely unchanged (verified byte-for-byte with
`diff -r`). For reference, the existing entry is:

```json
"sunsrays": {
  "meta": { "title": "Sun's Rays Simulator", "version": "2.0" },
  "masthead": {
    "help":  { "title": "Help and Instructions", "content": "<p>This simulator shows how the sun's most direct rays hit different parts of the earth as the seasons change.</p>" },
    "about": { "title": "About this Simulator",  "content": "…standard KL-UNL About boilerplate…" }
  }
}
```

The original SWF contained no Help or About text of its own for this simulation (the only
Help strings in the export belong to the unused Distance Modulus Explorer symbols), so
there was nothing to fold in.

## Layout

The original Flash stage was 600 × 550, split into three horizontal bands: a title bar
(y 0–50), the diagram (y 50–450) and a readout strip (y 450–550). The port keeps that
reading order inside the KL-UNL shell — masthead, diagram panel, readout panel — with the
diagram on a canvas whose internal coordinate system is the original stage, offset by
−50 in y so it covers exactly the diagram band. All ported drawing and physics maths is
in original Flash stage units; only the canvas backing-store scale changes with the
display size, and pointer geometry is not used at all (nothing in this simulation is
draggable).

The readout strip becomes a three-column grid — latitude box, date box, run button —
matching the original arrangement, and collapses to a single stacked column below 40 rem.

## Deviations from the original

1. **Whitespace in the readouts.** The original padded its strings (`"    March"`,
   `"  Vernal Equinox"`, `"Tropic of \r Cancer"`) with spaces to centre them inside
   fixed-width Flash text fields. The strings are stored verbatim in `simulation.js` and
   only collapsed at display time, because the HTML boxes centre their own content. No
   wording changed.
2. **Degree symbol.** The original used `unescape("%ba")` — the masculine ordinal
   indicator `º` — as a degree sign. The readout is typeset by MathJax as a true degree
   symbol (`^{\circ}`), which is both the correct glyph and the accessible one.
3. **Ray colour.** Pure `0xFFFF00` on the `0xF3F3F3` panel is about 1.07:1. Each ray is
   drawn as a `#ffe000` core inside a `#6b5200` casing (7.4:1 against the panel), so the
   rays still read as yellow sunbeams but meet WCAG 1.4.11. The rays are consequently
   6 units wide instead of 4. See `ACCESSIBILITY.md`.
4. **Diagram label plates.** The original painted black label text straight onto the
   rotating dark shadow, where it is close to unreadable. The HTML labels carry an 88%
   white plate so they hold contrast whichever side of the terminator they fall on.
5. **Rotating labels are not horizontally stretched.** `LineGroup` carried `scaleX =
   1.2857`, which stretched "Least Direct" / "Most Direct" horizontally. The HTML labels
   are positioned at the same stretched *coordinates* and rotate with the same angle, but
   the glyphs themselves are not stretched.
6. **Panel chrome.** The original bevelled Flash panels are replaced by KL-UNL `.panel`,
   as required; the diagram keeps the original `#f3f3f3` field colour inside it.
7. **Start/Stop.** Two overlapping Flash buttons become one toggle button. Behaviour is
   identical; only one of the two was ever visible at a time in the original.
8. **Hidden-tab timing.** `requestAnimationFrame` stops while the tab is hidden. On
   return the port discards the intervening wall-clock time rather than crediting it in
   one frame, which would have jumped the calendar past a month boundary. While the page
   is visible the timing is exactly the original's elapsed-time integration.
9. **Reduced motion.** With `prefers-reduced-motion: reduce`, the diagram repaints at
   4 Hz instead of every frame, so it steps rather than sweeps. The model, the timing
   constants and the readouts are unchanged.
10. **Date is not typeset by MathJax.** A calendar date is not mathematical notation, so
    "March 21" is plain text. Every piece of genuine maths in the interface — the
    latitude value, its degree symbol and its hemisphere letter — is MathJax-typeset and
    exposes the MathJax context menu.

## Verification performed

* Canvas output sampled pixel-by-pixel against the FFDec render of the original frame at
  matched points: globe ocean `4,150,252`, shaded ocean `1,45,76`, shaded landmass
  `76,61,1` and panel field all match exactly; the shadow's composite grey matches to
  within the panel's own shade.
* The ported year loop was run independently over 62 simulated seconds: the calendar
  cycles correctly (March 21 → … → January 8 → March 22 at t = 30 s), the latitude peaks
  at ±23.5° at the solstices, and the hemisphere flips north in June and south in
  December.
* Served over HTTP: no console errors, and no network request other than
  `foundation/contents.json`, `assets/earth.png` and the vendored MathJax bundle.
* `diff -r foundation html5/foundation` reports no differences.

## Still to do by a human

Screen-reader QA with NVDA (Windows) and VoiceOver (macOS/iOS), and a visual pass in
Safari, remain necessary; see `ACCESSIBILITY.md`.
