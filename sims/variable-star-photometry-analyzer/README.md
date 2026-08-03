# Variable Star Photometry Analyzer

An accessible HTML5 conversion of the NAAP *Variable Star Photometry Analyzer*
Flash simulation, rebuilt on the KL-UNL foundation and targeting WCAG 2.1 AA.

**▶ Run it: <https://sy-xia.github.io/variable-star-photometry-analyzer/>**

The simulation presents a simulated CCD star field containing constant stars,
pulsating stars (Cepheid / RR Lyrae Fourier presets) and eclipsing binaries.
Choose a comparison star and a star of interest, and the analyzer plots their
differential magnitude against time or phase, then finds the period with a
phase dispersion minimization (PDM) sweep.

## Repository layout

| Path | Contents |
| --- | --- |
| `html5/` | The converted simulation — this folder is what GitHub Pages serves. |
| `fla/` | The original decompiled Flash export (ActionScript, shapes, sprites, texts, the `.swf`) kept for reference. |
| `.github/workflows/pages.yml` | Publishes `html5/` to GitHub Pages on every push to `main`. |

## Running locally

The sim must be served over HTTP — opening `index.html` from the file system
does not work, because the masthead fetches `foundation/contents.json` and
browsers block `fetch()` over `file://`. From inside `html5/`:

```bash
python3 -m http.server 8123
```

then open <http://localhost:8123/>. See [`html5/README.md`](html5/README.md)
for details and alternatives.

## Documentation

- [`html5/CONVERSION_NOTES.md`](html5/CONVERSION_NOTES.md) — behavior model,
  ActionScript → HTML5 mapping, and every deviation from the original.
- [`html5/ACCESSIBILITY.md`](html5/ACCESSIBILITY.md) — keyboard map, ARIA and
  screen-reader behavior, colour/contrast notes, and remaining QA needs.

## Licensing note

The simulation code in `html5/` is licensed under the Apache License 2.0
(Copyright 2026 The Board of Regents of the University of Nebraska).

`fla/` is a decompiled export of the original SWF and is included only for
reference. It contains third-party material that is **not** covered by that
license — Adobe's `fl.*` component framework source under `fla/scripts/fl/`
and subset Verdana font files under `fla/fonts/`. Remove those paths before
any redistribution where that matters.
