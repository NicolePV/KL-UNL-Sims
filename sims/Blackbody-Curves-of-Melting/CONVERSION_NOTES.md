# Conversion Notes — Melted Nail Demonstration

## Behavior model (one paragraph)

The sim shows a classic physics demonstration: a nail held under tension is heated
by a large electric current until the iron melts and the nail breaks. A single
**animation** (frames 1–849, 20 fps) plays the recorded footage of the nail heating,
glowing, and melting. The user drives it with one toggle button
(**start → pause → resume → restart**) and a **scrub slider** over the 849 frames.
The nail's **temperature** is a fixed function of the frame number: 300 K at frame 1,
rising linearly to a peak of **1800 K at frame 429** (`snapFrame`), then falling back
toward 800 K, and snapping to 300 K on the final frame (the nail has broken and
cooled). Two **blackbody-curve plots** update live from that temperature using the
Planck function: a main plot over **300–800 nm** (the visible range, locked vertical
scale) and a small **0–10 µm inset** (custom vertical scale whose curve height grows
with `(T − 800)/1000`). The visible-spectrum rainbow band sits on the main plot's
axis. The point of the demo is Wien's law (peak wavelength shifts blueward as T rises)
and the Stefan–Boltzmann law (brightness grows steeply with T) — visible as the
nail's color/brightness and as the growing curves.

## Source → ground truth

Decompiled from `meltednail.swf` with JPEXS/FFDec. Key sources:
- `frame_1/DoAction.as` — main controller: state machine, `update()`,
  temperature-vs-frame formula, `peakHeight`, plot wiring.
- `Simple Blackbody.as` — the blackbody plot component: Planck curve `redraw`,
  `updateScale` (locked/autoscale/custom), visible-spectrum gradient, axes.
- `Title Bar.as`, `Standard Slider v6.as` — Flash UI framework (behavior reproduced
  with native accessible controls; the framework itself is not ported).

## Physics constants (copied verbatim)

| Constant | Value | Source |
|---|---|---|
| Planck numerator `A` | `1.1910425859324616e-16` | `Simple Blackbody.redraw` |
| `B` = hc/k (m·K) | `0.014387750559248378` | `Simple Blackbody.redraw` |
| Wien constant (m·K) | `0.0028977682864295084` | `getPeakWavelength` |
| Locked `maxBrightness` (main plot) | `183955504.96` | `init()` (`bbPlot.maxBrightness`) |
| `snapFrame` | `429` | `frame_1` |
| `maxValue` (frames) | `849` (`nailMovie._totalframes`) | `init()` |
| Frame rate | `20` fps | SWF header |

Planck form used by the sim: `f(w) = A / ( w^5 · (e^(B/(w·T)) − 1) )`.

Temperature(frame) — verbatim from `update()`:
```
frame == 1            -> 300
frame <= snapFrame    -> 800 + 1000/snapFrame * frame
frame <  maxValue     -> 1800 - 1000/(maxValue - snapFrame) * (frame - snapFrame)
frame == maxValue     -> 300
displayed as Math.floor(T) + " K"
peakHeight = (T <= 800) ? 0 : (T - 800)/1000
```

Verified in-browser: T(1)=300, T(429)=1800, T(848)=802.38, T(849)=300; peakHeight(429)=1.

## Plot configuration (from the two `Simple Blackbody` instances)

| | `bbPlot` (main) | `bbPlotInset` (inset) |
|---|---|---|
| Wavelength range | 300–800 nm (3e-7–8e-7 m) | 0–10 µm (0–1e-5 m) |
| Vertical scaling | **locked** (`maxBrightness` 183955504.96) | **custom** (peak = `peakHeight`·height) |
| Y axis shown | no | no |
| Visible spectrum band | yes (`minorTickmarkExtent` 7) | no (`minorTickmarkExtent` 0) |
| Fill | 20% gray (`fillColor` 0xC0C0C0) | 20% gray |
| Curve | black, 1 px | black, 1 px |
| X labels | 300–800 nm | 0 / 5 / 10 µm (static text) |

Visible-spectrum gradient (verbatim, spanning 400–700 nm):
colors `[0,255,65535,65280,16776960,16711680,0]`, alphas(0–100) `[0,90,90,90,90,90,0]`,
ratios(0–255) `[0,48,96,128,160,207,255]`.

## AS idiom → HTML5 mapping

| Flash / ActionScript | HTML5 port |
|---|---|
| `onEnterFrame` @ 20 fps advancing `frameSlider.value` | native `<video>` playback; frame derived from `video.currentTime` (elapsed-time source, matches 20 fps) via `requestAnimationFrame` **and** the video `timeupdate` event |
| `nailMovie.gotoAndStop(frame)` | seek `<video>.currentTime = (frame−1)/20` when paused/scrubbing |
| `frameSlider` (Standard Slider v6) | native `<input type="range" min=1 max=849>` (full keyboard + wheel) |
| `animationButton` (FPushButton) | native `<button>` with start/pause/resume/restart label |
| Title Bar + About/Help/Reset | shared `<kl-unl-masthead sim-id="meltednail">`; Reset via the `sim-reset` event |
| `Simple Blackbody.redraw` (adaptive bézier tessellation of Planck) | per-pixel-column sampling of the same Planck function on `<canvas>` (visually identical, resolution-independent) |
| `beginGradientFill` visible spectrum | `ctx.createLinearGradient` with the same colors/ratios/alphas |
| color ints / alpha 0–100 | `intToRgb` / `intToRgba(..., a/100)` |
| Wien's law readout (added) | `klunlShowEquation()` via the foundation MathJax helper |

## The nail animation is a reused exported asset (not code-drawn)

The nail's heating/melting is an **embedded VP6 video** inside the SWF
(`DefineVideoStream` chid 58, 847 frames, 240×192, 20 fps) — real footage, not
vector art. Per the asset-reuse rule it is **reused as-is**, not redrawn: extracted
with FFDec (`58.flv`) and transcoded with ffmpeg to `assets/nail.mp4` (H.264) and
`assets/nail.webm` (VP9) for cross-browser playback. Both are encoded **all-keyframe**
(`-g 1`) so scrubbing to any frame seeks exactly. The slider/temperature/curves are
the authoritative state; the video is displayed in sync (verified: frame 1 near-black
cold nail; frame 429 seeks to t=21.4 s, glowing orange).

## contents.json

No edit was needed: the shared `foundation/contents.json` already contains a
`"meltednail"` entry (meta.title "Melted Nail Demonstration", Help = the apparatus
description verbatim from the original `texts/12.txt`, About = standard KL-UNL
boilerplate). The foundation folder was copied in **byte-for-byte unchanged**.

## Deviations from the original (all presentation-only; behavior unchanged)

1. **KL-UNL shell, not the Flash pixel layout** (required by the pipeline). Panels,
   palette, fonts, masthead follow KL-UNL; panel structure and reading order mirror
   the original (nail demo left, Blackbody Curve right; temperature above the nail,
   controls below; inset in the plot's upper-left).
2. **Inset background.** The Flash inset was transparent and overlapped the main plot;
   for legibility/contrast over the main curve it now has a light (92%) background and
   a faint frame. Physics and geometry are unchanged.
3. **Spectrum band position.** Drawn as an 8 px strip along the bottom of the main plot
   (the Flash strip was 7 px just below the axis). Same colors/range (400–700 nm).
3a. **Y-axis (intensity) line drawn.** The Flash `bbPlot` had `showYAxis=false` (no y-axis
   line or ticks). A plain vertical intensity axis line is drawn on the main plot for
   clarity, matching the labelled "intensity" axis. No numeric y-ticks are added (the
   locked scale has no meaningful absolute units to label), so this is line-only.
4. **Added Wien's-law readout.** A live `λ_max = b/T = … nm` line (MathJax) was added
   to give audio users the peak wavelength with units and to satisfy the "all math via
   MathJax" rule. It reports the same Wien constant already in the source; it does not
   change any original behavior or text.
5. **Curve rendering** uses dense per-pixel sampling instead of the AS adaptive-bézier
   tessellation — same Planck function, visually identical curve.

## Remaining QA

Automated checks (in-browser) confirmed parity, rendering, keyboard, tab order, live
region, and video sync. Final **human** visual QA and screen-reader QA (NVDA +
VoiceOver) in real browsers is still recommended, as always.
