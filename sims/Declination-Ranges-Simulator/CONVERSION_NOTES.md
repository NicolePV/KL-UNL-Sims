# Conversion Notes — Declination Ranges Simulator

Source: `latsim.swf` (Adobe Flash, ActionScript 1), decompiled with JPEXS/FFDec
into `../decompiled/`. Target: a self-contained, accessible HTML5 simulation on
the KL-UNL foundation.

## Behaviour model

The simulator shows an edge-on view of the celestial sphere for an observer at a
chosen latitude. Declination is marked around the rim of a dial — +90° at the
north celestial pole (top), 0° at the celestial equator (both the left and right
edges), −90° at the south celestial pole (bottom) — and the observer, drawn as a
small figure standing on the Earth at the centre, carries a horizon line that is
tilted to `90 − latitude` degrees. From that latitude the code computes a single
quantity, `span = 90 − |latitude|`, and uses it to split the whole sky into three
declination bands, which it shades around the rim and lists as text: stars
**circumpolar** (never set), stars that **rise and set**, and stars that
**never rise**. Changing the latitude — with the slider, or by dragging the
horizon line — moves the boundaries continuously; an "Enlarge Earth" checkbox
scales the Earth from 20% to 100% and dims it and the tick dial to 50% opacity so
you can see where on the Earth's surface the observer is standing.

## Source files read

| File | What it provided |
| --- | --- |
| `scripts/simulator.as` | `latClass`, `calcRanges`, `radian`/`degree`, `findControlRadius`, the `lat` property |
| `scripts/DefineSprite_90_simulator/frame_1/DoAction.as` | the `pers_tan` press/release/move drag handlers |
| `scripts/SliderV3forLat.as` | latitude slider range, precision and value formatting |
| `scripts/enlargeBox.as` + the `FCheckBox` `on(initialize)` block | the "Enlarge Earth" checkbox label and handler |
| `symbolClass/symbols.csv`, the SWF placement matrices | symbol linkage names, positions, scales and z-order |
| `texts/*.txt` | every on-screen string |
| `latsim.jpg` | screenshot of the running original, used as the layout reference |

## ActionScript → HTML5 mapping

| ActionScript | HTML5 |
| --- | --- |
| `Object.registerClass("simulator", latClass)` + `prototype` methods | plain functions over one `state` object in `simulation.js` |
| `onEnterFrame` | event-driven `render()`; nothing in this sim animates on its own, so a frame loop would only redraw identical output (see "Deviations") |
| `createEmptyMovieClip` + `beginFill`/`lineTo`/`curveTo`/`endFill` | canvas 2D paths (`drawBand`) |
| `p.radian` / `p.degree` | same functions, same constants (`0.017453292519943295`, `57.29577951308232`) |
| `_rotation` (degrees) | `ctx.rotate(radian(90 - lat))` about the symbol's registration point |
| `_xscale`/`_yscale = 20 | 100` | a `scale` factor of `0.20` / `1.00` applied to the drawn size |
| `_alpha = 50 | 100` | `ctx.globalAlpha` of `0.5` / `1` |
| `beginFill(color, 90)` | `ctx.globalAlpha = 0.9` |
| `attachMovie` + depth list | fixed draw order in `drawStage()` |
| `updateAfterEvent()` | dropped (no-op) |
| `FUIComponent` / `FCheckBox` / the `SliderV3` component framework | **not** ported; the observable behaviour is reproduced with native `<input type="range">`, `<input type="number">` and `<input type="checkbox">` |
| `_root` / `_parent` chains, `trace()` | explicit references; `trace()` dropped |

### Constants carried over verbatim

* Dial centre `(225, 225)`; band radii `165` and `178`; fill alpha `90`.
* Slider: min `−90`, max `90`, initial value `41`, precision `1`
  (so `_minIncrement = 0.1`).
* Earth scales `20` / `100`; enlarged offset `25`; `np_text` `_y` `192 → 182` and
  `sp_text` `_y` `237 → 247`.
* Band colours, read by `calcRanges` from the three range labels' `textColor`:
  circumpolar `#ff9900`, rise and set `#33ccff`, never rise `#33cc66`.
* Stage background `#333333`.

### `calcRanges`

Ported statement for statement, including the two conditional swaps for southern
latitudes and the fact that the printed number is re-derived from `|lat|` rather
than from the (possibly swapped) interval endpoints. The `−0` behaviour at the
poles is preserved: at `|lat| = 90` the rise-and-set range compares `0` against
`−0`, which is equal, so it correctly reads "None".

Verified against the original screenshot and at the boundary cases:

| Latitude | Circumpolar | Rise and set | Never rise |
| --- | --- | --- | --- |
| 41° N | `+49° to +90°` | `+49° to −49°` | `−49° to −90°` |
| 0° | None | `+90° to −90°` | None |
| 90° N | `0° to +90°` | None | `0° to −90°` |
| 41° S | `−49° to −90°` | `+49° to −49°` | `+49° to +90°` |
| 90° S | `0° to −90°` | None | `0° to +90°` |

The 41° N row reproduces the original screenshot exactly.

### Latitude value formatting

`SliderV3forLat.setValue` builds its label as
`Math.abs(toFixed(_value)) + "°" + (" N" | " S" | "")`. Calling `Math.abs()` on
the *fixed-point string* is what drops a trailing `.0`, so 41 displayed as
"41° N" and 41.5 as "41.5° N".

That split into magnitude and hemisphere is preserved in `latParts()` and is what
the **spoken** value is built from ("41 degrees north"). It is no longer the
on-screen format: the latitude is now displayed in the editable box as signed
degrees (see deviation 8). The end labels are unchanged from the original —
`Math.abs(min) + "° S"` and `max + "° N"`, i.e. "90° S" and "90° N" — so the
sign convention stays visible beside the track.

### The drag

`pers_tan.onMouseMove` is ported verbatim:

```
x   = mouseX - pers_tan._x
y   = mouseY - pers_tan._y
lat = -degree(atan2(y, x)) - 90
if (lat > 90) lat -= 90; else if (lat < -90) lat = 180 + lat
```

(The `lat > 90` branch is unreachable — `-degree(atan2(...)) - 90` spans
−270…90 — but it is kept so the port matches the source.) Pointer coordinates
are mapped back through the current CSS scale first, so the arithmetic always
runs in original stage coordinates whatever size the canvas is displayed at.
Confirmed: dragging straight up gives 0°, up-left +45°, up-right −45°.

## Assets: reused vs. redrawn

**Reused as-is** (copied from the JPEXS export into `assets/`, drawn with
`ctx.drawImage` at their original position, size and z-order):

| Asset | Source | Role |
| --- | --- | --- |
| `assets/sphere.svg` | `shapes/72.svg` | the celestial sphere's graded ball (`mySphere`) |
| `assets/ticks.svg` | `shapes/65.svg` | the declination tick dial (`myGrid`) |
| `assets/earth.svg` | `shapes/74.svg` | the Earth (`myEarth`) |
| `assets/observer.svg` | `shapes/88.svg` | the horizon line with the standing figure (`pers_tan`) |

**Redrawn** — only the three shaded bands, because the ActionScript builds them
at runtime with `createEmptyMovieClip` / `beginFill` / `curveTo` and there is no
exported file for them.

Not carried over: `shapes/53/54/55/56/57.svg`, which are the original Flash
window chrome (black and `#333333` panel rectangles, borders, the heading rule).
Goal B replaces that chrome with the KL-UNL shell.

## Deviations from the original

1. **Arcs instead of quadratic Bézier approximations.** `calcRanges` draws each
   band as `curveTo` segments whose control point comes from
   `findControlRadius`, and splits every band at ±45° because one quadratic
   curve cannot approximate an arc wider than about 90°. `ctx.arc` draws the
   same arcs exactly, so the split and the control-radius helper are unnecessary;
   the geometry (centre, radii, start and end angles) is unchanged and the result
   is marginally *more* accurate than the original. Both halves of a band are put
   in one path so the 90% fill alpha is applied once and no seam appears where
   they meet at the pole.

2. **Band z-order follows the running original.** In the SWF the bands are
   created at depths 1–17 while `mySphere` sits at depth 148, which by Flash's
   normal depth rules would hide all but a 3-pixel sliver of each band. The
   deployed simulation (the reference screenshot, rendered through Ruffle) clearly
   draws the bands *over* the sphere, and sampling its pixels confirms the exact
   composite: `0.9 × band colour + 0.1 × sphere colour`. The port reproduces the
   running behaviour, which is also the only reading that makes the simulation
   teach anything.

3. **No frame loop.** `onEnterFrame` ran `calcRanges` and redrew every frame.
   Nothing here animates independently of user input, so `render()` is called
   from the input handlers instead. The output is identical and the page does no
   work while idle. One consequence: the original's one-frame lag between
   `pers_tan._rotation` and the recomputed `pers_tan._x`/`_y` when the Earth is
   enlarged does not occur — the port uses the current latitude for both, which
   is what the original was converging to anyway.

4. **Text moved off the canvas.** The declination tick labels, `NCP`/`SCP`/
   `NP`/`SP`/`CE`, and all three range readouts are HTML positioned over the
   canvas rather than baked into it, so they are typeset by MathJax where they
   are mathematical, scale with the browser font size, and are reachable by
   screen readers (rules 8a and 10). The tick marks themselves are still the
   original exported vector art.

5. **Tick label placement is computed, not copied.** The original's static text
   labels sit at hand-placed offsets that are close to, but not exactly on, a
   circle. The port places all 20 labels on a single radius (198 px) at their
   true declination angles. This is within a few pixels of the original and
   gives the even, symmetric spacing rule 12 asks for.

6. **Grab tolerance on the horizon line.** The Flash hit area was the drawn
   shape, i.e. a stroke a few pixels wide. The port allows 10 stage pixels either
   side of the line so it can be grabbed with a finger on a touch screen. The
   resulting latitude is computed with the original formula and is unchanged.

7. **Layout is KL-UNL, not the Flash pixel layout.** The original's single
   660 × 450 stage becomes three panels — the diagram, the latitude control, and
   the declination ranges — arranged to mirror the screenshot (square diagram on
   the left; latitude above the ranges on the right) using the foundation's
   classes, and collapsing to one column on narrow screens.

8. **The latitude readout is now an editable number field.** The original had a
   slider with a read-only "41° N" label beside it. That label is replaced by an
   `<input type="number">` on the same line, so the latitude can be read, typed
   and stepped from one place.

   The consequence for parity: the value is shown as **signed** degrees (−24.7),
   not in the original's magnitude-plus-hemisphere form (24.7° S). Signed degrees
   are what a number input needs in order to span −90…90 with its arrow keys, and
   showing both forms at once was redundant. The convention stays visible in the
   slider's unchanged end labels ("90° S" … "90° N"), and screen readers still
   hear the original form — `aria-valuetext` says "24.7 degrees south".

   All three controls echo each other: whichever one you use, the others update.
   The only exception is that the field you are actively typing in is not
   rewritten underneath your caret — that is keyed on which control raised the
   event, not on which has focus, so wheel, Page/Home/End, the slider and the
   canvas drag all still update the box while it holds focus. Committing an empty
   or malformed entry reverts to the latitude in effect rather than snapping to
   zero (`Number("") === 0`).

10. **The right-hand column is height-matched to the diagram.** The latitude and
    declination-ranges panels together span exactly the height of the square
    diagram panel, with the ranges panel absorbing the slack and its three rows
    spread evenly down it. This matches the original, where the three range
    blocks are spaced down the full height of the right-hand side. (The
    foundation's `.app-layout` sets `align-items: start`, so `stretch` has to be
    restated in `styles.css` for this to take effect.) In the collapsed
    single-column layout the panels return to their natural heights.

9. **Range colours are not used as text colour in the panels.** See
   `ACCESSIBILITY.md` — the three colours are kept exactly as in the original on
   the dark canvas, but in the white KL-UNL panels they appear as swatches beside
   dark label text rather than as coloured text, which would fail contrast.

## The `contents.json` entry

`foundation/contents.json` already contained a `latsim` key, so no new key was
added; the file is otherwise byte-for-byte the copy from the linked folder. The
only content change is to `latsim.masthead.help.content`, which was expanded
from its one-sentence placeholder to describe the diagram and the three
controls. The original SWF contains **no** Help or About text of any kind — there
are no help strings in `texts/*.txt` or in the ActionScript — so there was no
original wording to carry over verbatim; the added text is factual description of
the simulator's own behaviour, in the same voice as the sibling entries.
`meta` and `masthead.about` are untouched.

`kl-unl-masthead.js`, `kl-unl.css` and `kl-unl.js` are copied in unchanged.

## Note on the source

The linked folder contained `latsim.swf` and the screenshot but no decompiled
export, so the SWF was decompiled with the locally installed JPEXS/FFDec into
`../decompiled/` (scripts, shapes, sprites, texts, frames, `symbolClass`). Exact
text colours and placement matrices were read from an XML dump of the SWF, since
those are not part of the normal FFDec export.
