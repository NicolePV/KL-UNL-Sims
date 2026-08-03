# Galactic Redshift Simulator

An accessible HTML5 port of the NAAP *Galactic Redshift* Flash simulation, built on the
shared KL-UNL foundation.

**▶ Live: https://sy-xia.github.io/galactic-redshift-simulator/**

Move the redshift slider and the galaxy's spectrum stretches toward longer wavelengths;
the visible-light strip dims and reddens, and *show filter details* reveals the U, B, V
and R bandpasses together with a bar chart of the brightness measured through each.

## Layout

| Path | Contents |
| --- | --- |
| `html5/` | The simulation. This folder is what GitHub Pages publishes, so it is served at the site root. |
| `fla/` | The decompiled Flash original: ActionScript sources, exported shapes and sprites, fonts, text assets, the original `.swf`, and a screenshot of the running Flash version. |
| `.github/workflows/pages.yml` | Publishes `html5/` to Pages on every push to `main`. |

Inside `html5/`:

* `index.html`, `simulation.js`, `styles/styles.css` — the sim
* `foundation/` — the shared KL-UNL masthead, stylesheet, MathJax helper and self-hosted
  MathJax build, copied in unchanged apart from this sim's `contents.json` entry
* `assets/spectrum-data.js` — the galaxy spectrum and U/B/V/R filter transmission tables,
  extracted digit-for-digit from the ActionScript
* `README.md` — how to run it locally
* `CONVERSION_NOTES.md` — behaviour model, ActionScript → HTML5 mapping, and every
  deviation from the original
* `ACCESSIBILITY.md` — WCAG 2.1 AA affordances, keyboard map, screen-reader notes

## Running it locally

It must be served over HTTP — the masthead fetches `foundation/contents.json`, and
browsers block `fetch()` over `file://`, so double-clicking `index.html` will not work.
From inside `html5/`:

```bash
python3 -m http.server 8180
```

then open <http://localhost:8180/>. See [`html5/README.md`](html5/README.md) for details
and alternatives.

## Credits and licence

Original simulation from the [Nebraska Astronomy Applet Project](https://astro.unl.edu/),
University of Nebraska-Lincoln. Initial funding was provided by NSF grants #0231270
and/or #0404988.

Copyright 2026 The Board of Regents of the University of Nebraska. Licensed under the
Apache License, Version 2.0; you may not use these files except in compliance with the
License. You may obtain a copy at <http://www.apache.org/licenses/LICENSE-2.0>.
