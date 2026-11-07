# Kepler's Third Law — Conversion Notes

## Behavior model

Kepler's Third Law is a two-field calculator, not an animated simulation. The
stage holds a title, the equation *P*² = *a*³, two text-entry boxes joined by an
equals sign (the left one carrying a superscript 2, the right a superscript 3),
and the caption "where P is in years and a is in AUs". Typing in either box
immediately recomputes the other from Kepler's third law — enter an orbital
period in years and the semimajor axis in astronomical units appears, or the
reverse — with the result rounded to three decimals. Non-positive or unparseable
input clears the other box; exactly zero puts a literal `0` in it. There is no
animation, no timer, no dragging, and no randomization: one frame, one script,
two event handlers.

## Source situation (important)

**This sim folder contained no JPEXS/FFDec export** — no `scripts/`, `shapes/`,
`images/`, `sprites/`, `symbolClass/`, `texts/`, or `frames/`, and no `.fla`.
Only `keplers_third.swf` (4,737 bytes), the Ruffle wrapper `keplers_third.html`,
and a 105×73 thumbnail `keplers_third.jpg` were present.

The behavior was therefore recovered by decompiling the SWF directly:
decompressing the `CWS` zlib body, walking the tag table, and disassembling the
AS1 bytecode of the single `DoAction` tag. The recovered source is reproduced
verbatim in the header comment of `simulation.js`. The tag inventory is:

| Tag | Count | Content |
| --- | --- | --- |
| `SetBackgroundColor` (9) | 1 | stage background |
| `DoAction` (12) | 1 | the entire script — 576 bytes |
| `DefineShape` (2) | 1 | the two box outlines |
| `DefineFont2` (48) | 6 | Arial / Verdana glyph subsets |
| `DefineText` (11) | 8 | the static title, equation, and caption |
| `DefineEditText` (37) | 2 | `p_txt` (char 16) and `a_txt` (char 17) |

Stage: 250×175 px, 12 fps, **1 frame**.

Because the whole script, both edit-field definitions, and the layout were
recovered, nothing about the port is guesswork. The thumbnail served as the
layout reference (Goal C).

### Constants recovered verbatim

| Constant | Value | Where |
| --- | --- | --- |
| P → a exponent | `0.6666666666666666` | `Push` operand (the nearest double to 2/3) |
| a → P exponent | `1.5` | `Push` operand |
| Rounding scale | `1000` | `Push` operand (3 decimals) |
| `restrict` | `"0-9.e"` | constant pool |
| `MaxLength` | `7` | both `DefineEditText` tags |
| Text alignment | centre (`Align = 2`) | both `DefineEditText` tags |
| Initial text | none (`HasText = 0`) | both `DefineEditText` tags — boxes start empty |
| Font height | 240 twips (12 pt), black | both `DefineEditText` tags |
| Box bounds | 1299 × 347 twips ≈ 65 × 17 px | both `DefineEditText` tags (identical) |

## ActionScript → HTML5 mapping

| Original (AS1) | Port |
| --- | --- |
| `p_txt` / `a_txt` `TextField` | `<input type="text" inputmode="decimal" maxlength="7">` |
| `p_txt.onChanged` | `periodToAxis()` + `setPeriod()` in `simulation.js` |
| `a_txt.onChanged` | `axisToPeriod()` + `setAxis()` in `simulation.js` |
| `restrict = "0-9.e"` | `applyRestrict()` — strips disallowed characters, preserves the caret |
| `Math.round(1000 * Math.pow(p, 2/3)) / 1000` | same expression, same literals |
| Assigning a Number to `.text` | `String(n)` — ECMAScript number-to-string, identical in both |
| `DefineText` static title | rendered by `<kl-unl-masthead>` as the `<h1>` |
| `DefineText` equation / caption | MathJax-typeset HTML |
| `DefineShape` box outlines | CSS borders on the two inputs |
| Flash stage layout | KL-UNL `.app-shell` / `.panel`, centred single column |

### The feedback-loop subtlety

In ActionScript, assigning to a `TextField.text` does **not** fire that field's
own `onChanged` handler — only user edits do. That is what stops the two handlers
from ping-ponging. In the port, `render()` writes `input.value` directly, which
likewise does not fire an `input` event. The match is deliberate; adding a
`dispatchEvent` would introduce an infinite loop that the original never had.

### Verified parity

Checked in-browser against the recovered handlers:

| Input | Result | Expected |
| --- | --- | --- |
| `P = 1` | `a = 1` | 1^(2/3) = 1 ✔ |
| `P = 8` | `a = 4` | 8^(2/3) = 4 ✔ |
| `P = 2.5` | `a = 1.842` | 2.5^(2/3) = 1.84202… ✔ |
| `P = 1e2` | `a = 21.544` | 100^(2/3) = 21.5443… ✔ (`e` is an allowed character) |
| `P = 0` | `a = 0` | zero branch ✔ |
| `P = ""` or `"."` | `a = ""` | NaN branch ✔ |
| `P = "-5"` | typed as `5`, `a = 2.924` | `restrict` drops the minus, as in Flash ✔ |
| `P = "abc9"` | typed as `9`, `a = 4.327` | `restrict` drops the letters ✔ |
| `a = 4` | `P = 8` | 4^1.5 = 8 ✔ |
| `a = 2.25` | `P = 3.375` | 2.25^1.5 = 3.375 ✔ |

## Foundation and contents.json

`foundation/` was copied into `html5/foundation/` **byte-for-byte unchanged**
(verified by MD5 against the source folder — all seven files match).

**No `contents.json` edit was needed.** The file already contained a complete
`keplers_third` entry (`meta.title` "Kepler's Third Law", `meta.version` "2.0",
plus Help and About content). It is used as-is. Since `help.content` is
non-empty, the masthead shows the "Review Help Guide" button, which relabels
itself to "Help" after first use.

## Assets

**No exported assets were reused, because the sim has none to reuse.** Every
visual element is either static text (now MathJax or HTML), a box outline (now a
CSS border), or a font (now the foundation's own stack). The only file copied
into `assets/` is the shared local MathJax build `tex-svg.js`, taken from a
sibling sim and verified by MD5 against every other sim's copy.

Nothing was traced or redrawn from a bitmap or vector export, since none exist.

## Rendering architecture — no `<canvas>`

The hybrid architecture described in the pipeline expects a `<canvas>` for
code-drawn, animated stage art. **This sim has none**: there is no
`createEmptyMovieClip`, `drawArc`, `beginFill`, `lineTo`, `curveTo`,
`attachMovie`, `onEnterFrame`, or `getTimer` anywhere in the SWF. Introducing a
canvas would have meant painting the equation onto a bitmap surface, which
directly violates the MathJax rule (canvas-baked math cannot expose the MathJax
context menu) and would have made the text non-zoomable. The sim is therefore
pure accessible HTML, which is the better outcome here rather than a shortcut.

## Deviations from the original

1. **Added a hint line** — "Type a value in either box and the other is computed.
   With a box focused, the up and down arrow keys or the mouse wheel adjust its
   value." The Flash original has no such text, but the arrow-key and wheel
   stepping (required for keyboard operability) is not otherwise discoverable.
2. **Added a panel heading** — "Period and Semimajor Axis Calculator" (`<h2>`).
   The original has only its title, which the masthead now renders as the `<h1>`;
   the KL-UNL panel structure wants a heading of its own.
3. **Arrow-key / mouse-wheel stepping** — not in the original, required by the
   accessibility rules. Step 0.1, Page 1, Home 0. Stepping re-rounds to the sim's
   own 3-decimal precision so repeated steps cannot accumulate floating-point
   dust (verified: 20 × ArrowUp from 0 gives exactly `2`, not `1.9999999999999998`),
   clamps at 0 (the original accepts no minus sign), and is skipped if the result
   would exceed the field's 7-character limit.
4. **`restrict` case sensitivity** — the port allows only `0-9`, `.` and
   lowercase `e`; an uppercase `E` is stripped. This is the plain reading of
   `restrict = "0-9.e"`.
5. **Layout is not the Flash pixel layout** — as the pipeline requires. The
   panel arrangement, grouping, reading order, and visual impression follow the
   thumbnail (title → equation → input row → caption), expressed with KL-UNL
   classes rather than the original's 250×175 coordinates, palette, or fonts.

## Foundation-level observations (not changed — foundation is never edited)

1. **Stray character in `kl-unl.css`.** Line 101 contains a lone `u` between the
   `.app-layout__left` and `.app-layout__right` rules, which turns the latter
   into the descendant selector `u .app-layout__right` and silently disables it.
   This sim does not rely on `.app-layout__right`, so it is unaffected — but the
   typo is worth fixing at the foundation level, where it would benefit every sim.
2. **Masthead overflows below ~360 px.** At a 320 px viewport the masthead's own
   shadow-DOM flex row (title + three buttons + 20 px side padding) needs 323 px,
   producing 3 px of horizontal scroll. This is inherent to the foundation
   component and identical across all sims; the sim's own panel measures exactly
   320 px with no overflow. At the 375 px phone-portrait target and at the WCAG
   reflow condition (1280 px at 200 % zoom = 640 px) there is no horizontal
   scrolling at all.

## Cross-browser notes

Nothing here is Chromium-specific: plain HTML inputs, flexbox, `clamp()`, CSS
custom properties, Pointer/Wheel events, and MathJax's SVG output. There are no
vendor-prefixed declarations and no Chrome-only APIs. The `<dialog>` element and
`::backdrop` used by the masthead have been supported in Safari since 15.4.
`display: contents` was deliberately **avoided** on the input labels — some WebKit
versions dropped such elements from the accessibility tree, which would have
broken the labels' accessible names; the labels use the foundation's `.sr-only`
class instead, which takes them out of flow with `position: absolute`.
