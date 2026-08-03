# Gravity Algebra — Conversion Notes

## Behavior model (one paragraph)

*Gravity Algebra* displays Newton's law of universal gravitation,
`F = G·M₁·M₂ / R²`, and a second, editable copy of the same formula in which each
of the two masses and the distance carries a **coefficient** (a multiplier) chosen
by the user from the set `{1/3, 1/2, 1, 2, 3}` (all default to `1`). The modified
force is `F' = G·(c₁M₁)·(c₂M₂) / (c_r R)² = (c₁·c₂ / c_r²)·F`. The sim shows that
multiplying factor either as a whole number or as a reduced fraction. Because every
coefficient is a product of powers of 2 and 3 only, the factor is always an exact
rational number; the original ActionScript tracks the integer exponents of 2 and 3
(`choice.p2`, `choice.p3`) and assembles the numerator/denominator from them, which
is reproduced here verbatim. There is no animation, timing, randomness, or drag —
the only interaction is picking coefficients (and the About dialog).

## Source of ground truth

Decompiled with JPEXS/FFDec from `gravAlgebra006.swf` into `../decompiled/`. Stage
size 550×400. Behavior comes from the ActionScript (AS1); chrome/layout/accessibility
come from the KL-UNL foundation and the accessibility rules.

## AS → HTML5 mapping

| ActionScript source | HTML5 port |
|---|---|
| `frame_1/DoAction.as` `onChange()` — exponent arithmetic on `p2`/`p3`, builds whole number vs `numerator/denominator` | `computeResult()` in `simulation.js` — ported line-for-line (`e2`, `e3`, `num`, `den`) |
| `Multiplier Selector.as` `choicesList` = `[{value,p2,p3,link}]` for `1/3, 1/2, 1, 2, 3`; `setSelected(2)` default | `CHOICES` array + `DEFAULT_INDEX = 2` (values/`p2`/`p3` copied verbatim) |
| `Multiplier Selector` / `Multiplier Choice` — a custom expanding dropdown of the five choices | Custom accessible dropdown `Coef` (button + `role="listbox"`), one per coefficient |
| `fraction` / `wholeNumber` display fields (numerator over denominator, or a whole number) | `#eq-result`, rendered as MathJax `\dfrac{num}{den}\,F` or `num\,F` |
| Static stage text: `F = G M₁ M₂ / R²` and `F' = G (·)M₁ (·)M₂ / (·R)²` (texts 65,66,68,69,72–79) | MathJax LaTeX (reference equation + the static glyphs around the coefficient controls) |
| Instruction text 70: "click the coefficients to change their values" | `.sim-hint` (verbatim) |
| `Title Bar` init: `title="Gravity Algebra"`, `aboutLinkageName="About"`, `helpLinkageName=""`, `resetHandlerFunc=""` | `<kl-unl-masthead sim-id="gravalgebra">` renders the title + About (+ Reset/Help, see deviations) |
| About dialog content (texts 3,5,8,9,15) | Already present in `foundation/contents.json` under `gravalgebra` (see below) |
| `Constellations Menu*`, `Tab Group`, `Mini About Link`, `Mini Link` symbols | **Unused** by the main frame (leftover template symbols); not ported |

## contents.json entry

The shared `foundation/contents.json` **already contains** the `gravalgebra` entry
(sim-id `gravalgebra`, title "Gravity Algebra", version 2.0, with Help and About
content derived from the original). No edit was required; the foundation folder was
copied in byte-for-byte unchanged (verified with `cmp`).

## Assets reused vs code-drawn

- **No exported bitmaps or photos were reused.** This sim contains no photographic or
  logo art. Every exported sprite is a rasterized UI glyph — the digits/fractions in
  the dropdown (`One`, `Two`, `Three`, `One Third`, `One Half`) and the equation
  letters (`F`, `G`, `M`, `R`). Per rule 8 these are *math text*, which must be
  MathJax-typeset, **not** re-used as raster images. They are therefore reproduced as
  MathJax LaTeX rather than by copying the PNGs.
- **No `<canvas>` is used.** The original "code-drawn" geometry is only the dropdown's
  background/arrow chrome and rectangular hit areas; those are reproduced with CSS
  (border, caret) around native/ARIA controls, which is the accessible equivalent.

## Deviations from the original (and why)

1. **Reset and Help buttons added by the masthead.** The original had only an "about"
   link. The shared `<kl-unl-masthead>` always renders **Reset** and **About**, and
   renders **Help** whenever the sim's `contents.json` help text is non-empty (it is,
   for `gravalgebra`). These are kept per Goal B (use the component as-is; do not build
   a competing masthead). Reset returns the sim to its exact initial state (all three
   coefficients = 1). This is an additive accessibility improvement, not a behavior
   change to the physics.
2. **Coefficient control is a keyboard/AT-accessible dropdown, not a mouse-only Flash
   dropdown.** The original expanded on click and auto-collapsed 500 ms after the mouse
   left it. Auto-collapse-on-hover-out is a hover-only affordance (fails touch and is
   disorienting for AT users), so it was dropped; the menu instead closes on selection,
   on `Escape`, on `Tab`/focus-out, and on an outside pointer press. Same set of five
   choices, same default, same effect on the result.
3. **Layout follows the KL-UNL shell, not the original pixel coordinates.** The panel
   arrangement, grouping, and reading order match the screenshot (reference equation on
   top, editable equation with inline red coefficients below, italic hint at the
   bottom), expressed with KL-UNL classes and a responsive/zoomable CSS layout rather
   than the 550×400 fixed stage.

## Self-verify summary

- Arithmetic checked against the AS for whole-number and fraction cases
  (e.g. `2·2/1² = 4`, `3·1/2² = 3/4`, `⅓·1/1² = ⅓`, all-ones `= 1`).
- Every symbol is MathJax (28 `mjx-container` SVG nodes; no raw TeX left on the page);
  right-clicking any symbol opens the MathJax "Show Math As…" menu (not overridden).
- Keyboard: coefficients reachable by Tab and by click; arrows/Home/End/Enter/Escape
  operate the menu; focus ring visible; Tab escapes normally.
- Reset (via `sim-reset`) returns to all-ones / `1 F`.
- No horizontal scroll at 375 px; equation reflows and stays legible at 200% zoom.
- No console errors served over HTTP; only local fetches (`contents.json`, MathJax).

Human screen-reader QA (NVDA + VoiceOver) is still recommended before release.
