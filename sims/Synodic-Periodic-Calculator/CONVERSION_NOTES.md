# Conversion Notes — Synodic Period Calculator

## Behaviour model (one paragraph)

The Synodic Period Calculator relates a planet's **sidereal period P**, Earth's
**fixed sidereal period E**, and the **synodic period S**. The user picks a
planet class (**Superior** or **Inferior**) and the working **Units** (**Years**
or **Days**). Earth's period is fixed by the units — `1.00` years or `365.25`
days — and is display-only. The two period fields P and S are **interlinked**:
typing a value in one immediately computes the other from the synodic relation.
For a **superior** planet `1/S = 1/E − 1/P` (requires `P > E`); for an
**inferior** planet `1/S = 1/P − 1/E` (requires `P < E`). Out-of-range or
degenerate inputs display the literal string **`Ouch!`** in the computed field;
an empty/invalid entry blanks the computed field. Switching planet class or units
clears both period fields (Earth is reset to its unit default).

## Source of truth

The original folder contained no decompiled `scripts/` — only `synodiccalculator.swf`
(a compressed Flash 6 / AS1 movie), a Ruffle loader HTML, and a screenshot
(`synodiccalculator.jpg`). Behaviour was recovered by decompressing the SWF and
**disassembling the ActionScript bytecode** from the main `DoAction` tag (the
`changePlanets`, `changeUnits`, and the three `onChanged` handlers on the
`s_txt`, `p1_txt`, `p2_txt` fields). The component framework tags
(`FUIComponent`, `FRadioButton`, `FLabel`) were **not** ported — only their
observable behaviour, reproduced with native accessible controls, per the prompt.

### Recovered constants (verbatim from the AS bytecode)

| AS operand (as stored)            | Real value      | Role                                    |
|-----------------------------------|-----------------|-----------------------------------------|
| `"1.00"`                          | 1.00            | Earth period E, Years (display + math)  |
| `"365.25"`                        | 365.25          | Earth period E, Days (display + compare)|
| `5.34346494e-315` *(word-swapped)*| **365.25**      | comparison threshold in Days mode       |
| `4.959190903750138e+245` *(same)* | **1/365.25**    | reciprocal `1/E` used in Days arithmetic|
| `restrict "0-9.e"`                | —               | field input filter (digits, `.`, `e`)   |
| textColor `1579263` / `16253183`  | valid / "Ouch!" | Flash colours (remapped — see below)    |

*Flash stores `push` doubles with the two 32-bit words swapped; decoded straight
they read as the nonsense magnitudes shown, which is why the Days branch uses the
literal precomputed `1/365.25` for `1/E` and compares against `365.25`.*

## AS → HTML5 mapping

| Original ActionScript                                   | HTML5 port (`simulation.js`)                        |
|---------------------------------------------------------|-----------------------------------------------------|
| `pmode` 1/2 (Superior/Inferior) radio group `Planets`   | `state.pmode`, native `<input type="radio">` group  |
| `umode` 1/2 (Years/Days) radio group `Units`            | `state.umode`, native radio group                   |
| `changePlanets(obj)` — set pmode, clear P & S, swap eq  | `changePlanets(mode)`                               |
| `changeUnits(obj)` — set umode, set E text, clear P & S | `changeUnits(mode)`                                |
| `e1_txt`/`e2_txt` (Earth, display-only, no `onChanged`) | single read-only `<output id="e-output">`           |
| `p1_txt`/`p2_txt` (planet, per mode) `onChanged`        | single `<input id="p-input">`, `onPInput()`         |
| `s_txt` (synodic) `onChanged`                           | `<input id="s-input">`, `onSInput()`                |
| `Math.round(x*100)/100`                                 | `round2(x)` — identical                              |
| Superior S: `1/(1/E − 1/P)`; guard `P > E` else `Ouch!` | `computeSfromP()` superior branch                   |
| Inferior S: `1/(1/P − 1/E)`; guard `P < E` else `Ouch!` | `computeSfromP()` inferior branch                   |
| Superior P: `1/(1/E − 1/S)`; guard `>0` else `Ouch!`    | `computePfromS()` superior branch                   |
| Inferior P: `1/(1/S + 1/E)`; guard `>0` else `Ouch!`    | `computePfromS()` inferior branch                   |
| invalid entry → computed field `""`                     | `{kind:'blank'}` → empty string                     |
| eq1 `1/S = 1/E - 1/P` / eq2 `1/S = 1/P - 1/E` graphics  | MathJax LaTeX via `klunlShowEquation`               |
| `trace()`, `_root`/`_parent`, FUIComponent framework    | dropped / replaced by native controls               |

### Verified value checks (computed in-browser against known planets)

* Superior / Years: `P = 1.88` → `S = 2.14` (Mars, ✓ ≈ 2.14 yr); round-trips back to `1.88`.
* Inferior / Years: `P = 0.615` → `S = 1.6` (Venus, ✓ ≈ 1.6 yr).
* Superior / Days: `P = 686.98` → `S = 779.91` (Mars, ✓ ≈ 779.9 d).
* Guards: Superior `P ≤ E` → `Ouch!`; Inferior `P ≥ E` → `Ouch!`; empty → blank.

## Deviations from the original (all presentation-only; physics unchanged)

1. **Field type.** The original planet/synodic fields were Flash *text* fields
   (`restrict "0-9.e"`). They are ported as `<input type="text" inputmode="decimal"
   pattern="[0-9.e]*">` with the same character filter — **not** `type="number"`,
   because a number input silently discards the literal `Ouch!` string the sim
   must be able to display.
2. **Arrow-key / mouse-wheel stepping** was added to the P and S fields (Years
   step `0.01`, Days step `1`; Page = ×10; Home = 0). This is required by the
   accessibility rules for numeric value fields and was not in the Flash text
   fields; it only feeds the same compute path and changes no physics.
3. **Colours.** Flash used `#1818FF` for valid results and `#F800FF` for `Ouch!`.
   These are replaced by the KL-UNL palette: normal foreground for valid values
   and `--alert-color-r` **plus** a thicker border and the literal word `Ouch!`
   for errors (never colour alone). See `ACCESSIBILITY.md`.
4. **Layout** follows the KL-UNL shell (two stacked panels: *Configuration* with
   the Planets/Units radio groups, *Calculation* with the equation and the S/E/P
   value cells in fraction order). This mirrors the screenshot's grouping and
   reading order rather than the original 300×300 pixel coordinates.
5. **Edge case** `S = E` in Superior mode divides by zero and shows `Infinity`,
   exactly as the Flash `100/(1/E − 1/S)` arithmetic does. Preserved for parity.

## contents.json

`foundation/contents.json` already contained a `synodiccalculator` entry
(`meta.title` "Synodic Period Calculator", `version` "2.0", Help + About). It is a
single shared file, so **no entry was added or edited** — the foundation folder is
byte-for-byte identical to the source (verified with `diff`). The Help text
("compute the sidereal period of the planet (P) from the synodic period (S), and
vice versa") drives the masthead Help button; About is the standard KL-UNL boilerplate.
