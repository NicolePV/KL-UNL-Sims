# Accessibility Notes — Big Dipper Clock

Target: WCAG 2.1 AA (AAA where reasonable). Human screen-reader QA is still required
(VoiceOver/NVDA/JAWS) — automated review and code review do not replace it.

## Structure & landmarks
- Single `<h1>` is rendered by the `<kl-unl-masthead>` component (sim title). The sim
  does not add a competing `h1`.
- `<main class="app-layout">` wraps the content. Each panel is a `<section>` with an
  `<h2>` (`Northern Sky Diagram` — visually hidden, since the original sky panel has no
  visible title; `Time and Date Controls` — visible). Heading order is h1 → h2, no skips.
- The masthead's Reset / Help / About live in its own `<nav>` (Shadow DOM); the modal
  dialog there manages its own focus trap and Escape — the sim does not fight it. Reset
  is wired via the bubbling `sim-reset` event (no second Reset button is added).

## Text alternatives (1.1.1)
- Both canvases use `role="img"` + `aria-describedby`.
- The **sky** canvas has a polite live region (`#sky-desc`) describing the current view,
  e.g. *"Northern sky looking due north on March 19 at 1:17 PM. The Big Dipper, Little
  Dipper and Cassiopeia circle the North Star. It is currently daytime (sky bright)."*
- The **clock** canvas has a description (`#clock-desc`), e.g. *"Clock reads 06:27 AM.
  Daylight saving time is in effect."* using the original 12-hour "traditional time"
  string from `Time Of Day Panel.as`.
- Descriptions update on every committed state change, not on every drag tick.

## Color & contrast (1.4.1 / 1.4.3 / 1.4.11)
- All chrome uses the KL-UNL palette custom properties. Body text ≥ 4.5:1.
- **No state is encoded by color alone.** Day/twilight/night is always also stated in
  words in the live region ("daytime (sky bright)" / "twilight" / "night"). The DST state
  is shown as the **text** placard "daylight saving time in effect" (not a color), and is
  also spoken in the clock description. Constellations are labeled by name (when "show
  details" is on) and named in the description regardless.
- The sky/star/ground colors reproduce the original exported gradients (educational
  day/night cue); no original color was repurposed as the sole signal, so no color
  remap was required.

## Keyboard (2.1.1 / 2.1.2 / 2.4.7)
- Everything is operable by keyboard in a logical tab order; focus rings come from
  `kl-unl.css` `:focus-visible` (plus a custom ring on the day-of-year slider). No traps.
- **Time of day:** hour and minute `<input>` fields (digits only, like the AS `restrict
  = "0-9"`). Commit on Enter or blur; invalid input restores the previous display
  (matches `setTimeByTextFields`). Each field has an associated (visually hidden) label.
  **Up/Down arrows step the value** (hour ±1 wrapping 0–23; minute ±1 crossing the hour),
  and the field updates live while focused.
- **The clock is itself a keyboard-operable control** (`role="slider"`, `tabindex="0"`,
  `aria-valuemin=0`, `aria-valuemax=1439` minutes-since-midnight, `aria-valuenow`, and
  `aria-valuetext` = the spoken clock time, e.g. "1:12 AM"). Focus it and use: Left/Down
  −1 minute, Right/Up +1 minute, PageDown/PageUp ∓1 hour, Home → 12:00 AM, End → 11:59
  PM (time wraps within the day). The hands remain pointer-draggable (mouse + touch);
  both paths mutate the same state.
- **Day of year:** a day `<input>` + a real `<select>` for the month (both labeled). The
  day field's **Up/Down arrows step the day of year ±1** (crossing month boundaries and
  updating the month `<select>`). Plus a **fully keyboard-operable** day-of-year slider
  strip:
  - `role="slider"`, `tabindex="0"`, `aria-valuemin=0`, `aria-valuemax=364`,
    `aria-valuenow`, and `aria-valuetext` (e.g. "March 21 (day 80 of 365)").
  - Left/Down −1 day, Right/Up +1 day, PageDown/PageUp ∓7 days, Home → Jan 1,
    End → Dec 31. Tab moves away normally; the slider is never a focus trap and is not
    blocked by canvas pointer handlers.
- **set to system clock** and **show details** are a native `<button>` and
  `<input type="checkbox">`.
- The clock slider and day-of-year slider announce their own `aria-valuetext` on keyboard
  change (so the screen reader speaks the new value); the text-field steppers instead
  announce through `#sim-status` (text inputs don't expose `aria-valuetext`). Neither
  path double-announces.

## Pointer / touch (works without hover)
- All dragging uses Pointer Events, so mouse and touch share one path. Draggable surfaces
  (`#clock-canvas`, `#doy-slider`) set `touch-action: none` so dragging doesn't scroll the
  page. Pointer coordinates are mapped back through the canvas's current display scale, so
  the drag/snapping math operates in the original Flash stage coordinates at any size.
- No information is hover-only. Interactive targets meet the ≥44 px minimum (`.button`
  min-height 2.75rem; checkbox row min-height; slider 2.4rem tall with a generous hit
  area).

## Timing / motion (2.2.2 / 2.3.3)
- There is **no continuous animation** in this sim (see CONVERSION_NOTES.md), so there is
  nothing that moves > 5 s and nothing that flashes. `prefers-reduced-motion` is still
  detected and honored (no motion is introduced under it).

## Text size & zoom (1.4.4 / 1.4.10)
- Body copy is ≥ 1.05rem (headings/labels scale up), sized in rem/em so it tracks the
  browser font setting. The layout uses relative units and CSS grid/flex; it reflows
  without clipping at 200% zoom and down to phone-portrait widths (single column).
- The canvases keep their original internal coordinate systems and are scaled by CSS
  (`width:100%; height:auto`), preserving aspect ratio. Canvas-painted text (clock hour
  numbers, cardinal labels, constellation labels) scales with the canvas; the spoken
  equivalents live in the HTML live regions, which zoom independently. Clock hour labels
  and constellation names that are baked into the canvas cannot expose per-glyph
  semantics, which is why the live-region descriptions exist.

## Forms & language
- `<html lang="en">`. Every input has a real `<label>` (or is inside a
  `<fieldset>`/`<legend>`: "the time of day:", "the day of year:").

## Known limitations / QA still needed
- Canvas-rendered glyphs are not individually selectable; the live regions are the
  accessible equivalent. Confirm with a real screen reader that the descriptions are
  announced at a comfortable cadence and that the slider value text reads well.
- DST detection depends on the viewer's OS/browser time zone (as in the original).

---

## AUDIO / SCREEN-READER PASS

A dedicated pass to make the sim fully usable by audio alone (NVDA on Windows,
VoiceOver on macOS). Behavior, layout, visuals, physics, and on-screen text were
**not** changed; only screen-reader semantics were added. **Final confirmation still
requires a human listening test on NVDA (Windows) and VoiceOver (macOS)** — screen-
reader compatibility is not claimed as verified.

### Values made units-complete (quantity + number + unit, spoken as words)
- **Time of day** — committed value is announced as, e.g.,
  `"... time of day 13 hours 17 minutes (1:17 PM) ..."` (units "hours"/"minutes" as
  words, plus the natural 12-hour clock form). Singular/plural handled (1 hour, 1
  minute). The hour/minute `<input>`s sit in a `<fieldset>` whose `<legend>` is
  "the time of day:", and each has an `.sr-only` `<label>` ("hour (0 to 23)",
  "minute (0 to 59)").
- **Day of year** — the strip slider exposes `aria-valuetext`, e.g.
  `"June 17 (day 168 of 365)"` (month name + day of month + day number out of 365),
  updated on every change; `aria-label="Day of year"`. The day `<input>` + month
  `<select>` sit in the "the day of year:" `<fieldset>`.
- **Daylight saving** — spoken as the words "Daylight saving time in effect." in both
  the status announcement and the clock description (never by color/visual only).
- **Sky state** — spoken as words: "daytime, sky bright" / "twilight" /
  "night, sky dark and stars prominent".

This sim contains **no scientific-unit values** (no degrees/eV/nm/kelvin, no negative
numbers, no coordinate pairs), so the only unit words needed are **hours / minutes**
and the day-of-year count; there are no skipped unit symbols or "minus/negative"
cases to handle. (Mapping rule applied where relevant: h/m → "hours"/"minutes".)

### Live-region status announcements (commit-time, debounced)
- A single dedicated polite live region `#sim-status` (`role="status"`,
  `aria-live="polite"`, `.sr-only`) carries "what changed" sentences. It is driven
  from `announce()` in `simulation.js` and fires **only on commit/release**, never per
  drag tick (verified: the status text does not change during a clock/strip drag and
  updates exactly once on pointer-up). Wording examples:
  - `"Time changed. June 17, time of day 13 hours 17 minutes (1:17 PM). The sky is daytime, sky bright. Daylight saving time in effect."`
  - `"Date changed. ..."`, `"Set to system clock. ..."`, `"Simulation reset. ..."`
  - `"Constellation labels and pointer line shown."` / `"... hidden."`
  - Invalid time/date entries: `"Invalid time entry ignored. ..."` / `"Invalid date entry ignored. ..."`
- It is **empty at page load** (so nothing is auto-announced on load).
- The day-of-year slider's value change from the keyboard is announced by the slider
  itself (its `aria-valuetext`), so `#sim-status` is intentionally **not** also fired
  on slider keypress — this avoids double-announcement. Pointer drags of the slider
  (which the slider does not auto-announce) do fire `#sim-status` on release.

### Canvas descriptions (read on demand, not live)
- Both canvases are `role="img"` with a static `aria-label` ("Northern sky diagram" /
  "Time of day clock") plus an `aria-describedby` block updated every render from
  state:
  - `#sky-desc`: "Northern sky looking due north on June 17 at 1:17 PM. The Big Dipper,
    Little Dipper and Cassiopeia circle the North Star. It is currently daytime (sky
    bright)."
  - `#clock-desc`: "Clock reads 1:17 PM. Daylight saving time is in effect."
- These description elements are **not** `aria-live` (so navigating the page does not
  flood); the previous `aria-live` on `#sky-desc` was removed and that role handed to
  `#sim-status`. Decorative canvas content carries no extra ARIA noise.

### Controls
- Every control is keyboard-reachable in reading order and announces name + value:
  hour/minute inputs, day input, month `<select>`, "show details" checkbox,
  "set to system clock" button (descriptive name), masthead Reset/Help/About, and the
  day-of-year slider (arrows / PageUp-Down / Home / End; `aria-valuetext` with units).

### Files touched (foundation untouched)
- `index.html` — added `#sim-status`; added `aria-label`s to the two canvases;
  removed `aria-live` from `#sky-desc`.
- `simulation.js` — added `announce()` / `currentStateSpoken()` / `skyPhaseWords()`
  and wired commit-time calls; no behavior/physics/number changes.
- No CSS needed (existing `.sr-only` reused). Foundation files unchanged.
