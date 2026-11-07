# Galactic Redshift Simulator — accessibility notes

Target: **WCAG 2.1 AA**, with AAA where it came cheaply (44 px targets, ≥1.125 rem body
text).

## Structure

* One `<h1>` — rendered by `<kl-unl-masthead>` from `contents.json`. The simulation adds
  no competing `h1`.
* `<main class="app-layout">` with four `<section aria-labelledby>` regions, each headed
  by an `<h2>`: **About Redshift**, **Redshift Control**, **Filters**, **Galaxy
  Spectrum**. No skipped levels.
* `<html lang="en">`.
* The masthead supplies the `<nav>` landmark and owns the About/Help dialog, its focus
  trap and its Escape handling; the simulation does not interfere with it.

## Keyboard map

| Key | Where | Effect |
| --- | --- | --- |
| `Tab` / `Shift+Tab` | everywhere | Reset → Help → About → `z` field → `z` slider → show/hide filters |
| `←` `↓` | `z` slider | decrease `z` by 0.01 |
| `→` `↑` | `z` slider | increase `z` by 0.01 |
| `Page Down` / `Page Up` | `z` slider | larger step |
| `Home` / `End` | `z` slider | `z` = 0.00 / 1.00 |
| type + `Enter` | `z` field | commit a typed redshift (also commits on blur) |
| `Space` / `Enter` | show/hide filters | toggle the filter details |
| `Esc` | About dialog | close (handled by the masthead) |

The slider is a native `<input type="range">`, so every one of those keys works without
custom code and cannot get "stuck" — this was the specific failure mode called out for
this pipeline. Pointer and keyboard both write to the same `state.z` and go through the
same `render()`, so the canvas, the number field, the slider and the live region can
never disagree.

**The original has no draggable canvas objects** (`Spectrum`'s only mouse handler
computes a local variable and discards it), so no focusable drag proxy was needed. The
sole controls are the slider, the number field and one button.

### Tab order contains only interactive controls

Verified in the browser: the document's tab stops are exactly `#zInput`, `#zSlider`,
`#showHideFiltersButton`, plus the three masthead buttons. There are **no**
`tabindex="0"` attributes anywhere. All 16 `mjx-container` elements carry
`tabindex="-1"`, applied both by the MathJax `pageReady` hook in `index.html` and by a
`MutationObserver` in `simulation.js` that catches any container typeset later (the
equation). Static content — typeset maths, readouts, the axis titles, the tick strip and
both canvases — is never a tab stop.

## Mathematics

Every mathematical symbol in the UI is typeset by MathJax from LaTeX; none is painted on
the canvas, drawn as an image, or faked with HTML sub/sup:

* the redshift definition
  \[ z = (\lambda_{\text{observed}} - \lambda_{\text{emitted}}) / \lambda_{\text{emitted}} \],
  set through the foundation's `klunlShowEquation()` with a paired spoken description in
  `#eqnRedshiftSR`;
* the variable `z` in the panel text and in the control's label;
* all seven wavelength tick labels — `\(300\,\mathrm{nm}\)` … `\(900\,\mathrm{nm}\)`;
* the axis title words `\(\textsf{Flux}\)` and `\(\textsf{Wavelength}\)`;
* the filter labels `\(U\)`, `\(B\)`, `\(V\)`, `\(R\)`.

**Exception: the two axis direction arrows are inline SVG, not typeset.** The
original draws thick solid arrows, and MathJax cannot reproduce that weight with
the self-hosted font set: TeX bolding does not apply to arrow glyphs
(`\mathbf{\uparrow}` measures byte-identically to `\uparrow`), and `\boldsymbol`
lives in `input/tex/extensions/boldsymbol.js`, which is not part of the bundle —
requesting it 404s and *rejects MathJax's startup promise, silently killing the
entire page typeset*. Drawing them also removes any reliance on OS dingbat fonts,
which the cross-OS rule forbids. They are ornament rather than notation: both sit
inside `aria-hidden` containers, are marked `focusable="false"`, and the axis
directions are stated in words in the canvas description ("The horizontal axis
runs from 250 nanometers to 950 nanometers…"), so nothing is lost to assistive
technology. Every actual symbol, variable and unit remains MathJax-typeset.

The MathJax contextual menu is **not** disabled and `contextmenu` is never trapped:
right-clicking any of the above opens *Show Math As → TeX / MathML*.

MathJax is self-hosted at `foundation/mathjax/` — no CDN.

**Known limitation.** The editable `z` value is a native `<input type="text">`, so its
*value* ("0.00") is plain text and cannot be typeset — a form control has to remain a
form control. Its label (`z (redshift):`) is typeset. This is the only number in the UI
that MathJax does not own.

## Text alternatives for the two canvases

Neither canvas is the accessibility layer. Both are `role="img"` with a short
`aria-label` and a continuously-updated `aria-describedby` description, refreshed from
the same `render()` that draws them:

* **Graph** — states the axis ranges with units, the current `z`, the stretch factor,
  where the 400 nm break now appears, the observed span of the spectrum, and whether the
  filter bandpasses are shown. Example at `z = 0.35`: *"…the sharp rise emitted at 400
  nanometers now appears at 540.3 nanometers…"*
* **Visible-spectrum strip** — states the band it covers and which wavelength is
  currently brightest, naming both the number **and** the colour region.
* **Filter bar chart** — `role="img"` labelled by a description giving each bar as a
  percentage of full scale, so the chart is readable without seeing it. When the filter
  details are hidden the chart is also `aria-hidden="true"`, so hidden bars are not
  announced.

## Live region and units

`#liveStatus` is an `aria-live="polite"` `role="status"` region. It announces **on
commit**, never on every tick: a slider drag fires many `input` events but only the
final `change` speaks, so audio is not flooded. (An early build gated this on "did the
value change", which meant drags were never announced at all, because `input` had
already committed the value by the time `change` fired — fixed by tracking the last
*spoken* value.)

**Every number is announced with its quantity name and its unit, spelled as a word.**
Examples actually produced by the build:

> Redshift z equals 0.35. Light emitted at 400 nanometers is now observed at 540.3
> nanometers.

> Filter details shown. Relative brightness through the filters, as a percentage of full
> scale: U 62 percent, B 81 percent, V 89 percent, R 105 percent.

> Simulation reset. Redshift z equals 0.00. Filter details hidden.

The slider's `aria-valuetext` is kept in step (`"Redshift z equals 0.35"`) so arrowing
through values reads the quantity, not a bare number. `z` is dimensionless, so it is
named rather than given a unit; every wavelength is given in *nanometers*, and the bar
readings in *percent of full scale*.

### Accessible names

`#zInput` uses an explicit `aria-labelledby` pointing at a `.sr-only` plain-text twin of
the label. The visible label is the MathJax version and is `aria-hidden`. Without this,
name computation concatenated both spans and the field announced its label twice. The
plain-text name (`z (redshift):`) matches the visible text, satisfying *Label in Name*.

## Colour and contrast

* All chrome colours come from the foundation's custom properties, so contrast is
  whatever the audited KL-UNL palette provides. Body text is `--foreground-color`
  (#1a1a1a) on `--background-color` (#ffffff) — 17.4:1.
* Filter colours were **not** remapped; they are the original `#B43FFA`, `#200074`,
  `#24AA00`, `#E36D00` at 30% alpha, and the bar fills are the original pastels. These
  are decorative-ish rather than text, and crucially **colour never carries meaning on
  its own**:
  * each bar is labelled `U`, `B`, `V`, `R` directly beneath it, and the same four
    letters name the values in the live region and the chart description;
  * the visible-spectrum strip is physically meaningful (it *is* the colour of the
    light), and its description gives the brightest wavelength as a **number** as well
    as a colour name;
  * the filter overlays are additionally distinguished by position on the wavelength
    axis, which is what the exercise is actually about.
* Bar fills are pale by design (they are a background for the letters). They are not
  used to convey any state that is not also given in text.

## Motion

The only animation is the 200 ms cubic fade of the filter details. That is far under the
5 s threshold, nothing flashes, and there is nothing to pause — so no Pause control was
added. `prefers-reduced-motion: reduce` is honoured in `simulation.js`: the transition is
skipped and the end state applied immediately (and it is re-checked if the user changes
the setting mid-session). Reset comes from the masthead's `sim-reset` event; the
simulation adds no second Reset button.

## Zoom, reflow and touch

Measured in-browser rather than assumed:

* **200% text zoom** at 1280 px: no horizontal scrolling, nothing clipped, nothing
  overlapping, no tick-label collisions.
* **320 CSS px wide** (WCAG 1.4.10 reflow): single column, panels stacked in reading
  order, `window.scrollX` stays 0 — no horizontal scrolling.
* Checked at 1280, 1024, 768, 390 and 320 px. The canvases keep their original internal
  coordinate system (the drawing and physics maths is untouched) and are scaled by CSS
  with the aspect ratio preserved — measured at 2.325 (= 702∶302) at every width.
* Every interactive target is ≥44 px in both dimensions at every tested width.
* Nothing depends on `:hover`.
* All sizing is in `rem`/`%`/`fr`, so it tracks the browser font setting.

One fix was needed here: MathJax's visually-clipped assistive-MathML copy, sitting inside
the *rotated* Flux axis title, had its absolute origin flipped by the rotation and landed
at a negative x, dragging a horizontal scrollbar onto narrow screens. Since that subtree
is `aria-hidden` anyway, `[aria-hidden="true"] mjx-assistive-mml { display: none }` in
`styles/styles.css` removes it with no loss to assistive technology. MathJax's own files
are untouched.

## Foundation integrity

`foundation/kl-unl.css`, `foundation/kl-unl.js` and `foundation/kl-unl-masthead.js` are
byte-for-byte as shipped. No sim styling was added to them and there is no override
`<style>` block in `index.html` — all sim-specific styling is in `styles/styles.css`.
`foundation/contents.json` carries this sim's About text plus the pre-existing JSON
syntax repairs documented in `CONVERSION_NOTES.md` (without them the masthead does not
load at all).

## Still required: human QA

Everything above was verified programmatically — accessibility tree, computed names,
tab-stop enumeration, geometry at five viewport widths and at 200% zoom, live-region
text, and absence of console errors. That is **not** a substitute for testing with real
assistive technology. Before release, please confirm with:

* **NVDA** on Windows (Chrome and Firefox) — browse vs. focus mode on the slider,
  and that the live-region announcements arrive once, in order, and are not truncated;
* **VoiceOver** on macOS (Safari and Chrome) and on iOS — rotor navigation of the
  headings and regions, the About dialog's focus handling, and that the canvas
  descriptions are reachable;
* a real touch device for the slider and the show/hide button.
