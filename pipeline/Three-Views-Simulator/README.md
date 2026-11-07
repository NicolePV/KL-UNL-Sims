# Three Views Simulator (HTML5)

An accessible HTML5 rebuild of the ClassAction / NAAP **Three Views Simulator**
(originally `moonphases.swf`), built on the shared KL-UNL foundation files.

## ⚠️ It must be served over HTTP — double-clicking `index.html` will not work

The KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the page title and
the Help / About text with `fetch('foundation/contents.json')`. Browsers block
`fetch()` of local files opened under the `file://` protocol (same-origin
policy), so opening `index.html` directly shows an empty / broken masthead and
the simulation will not initialize correctly.

Serve the folder over HTTP instead and everything works.

## How to run locally

Run one of these **from inside this `html5/` folder**, then open the URL it
prints:

```bash
python3 -m http.server 8123
```
then open <http://localhost:8123/>

Other options:

```bash
npx serve
```
```bash
npx http-server
```

Or, in VS Code, use the **Live Server** extension ("Go Live").

Because you are serving from *inside* `html5/`, the simulation is at the server
root — the URL is `http://localhost:8123/`, **not** `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## Folder layout

```
html5/
  index.html            KL-UNL shell: masthead + orbit / moon-view / controls panels
  foundation/           shared KL-UNL files, copied in UNCHANGED
  styles/styles.css     sim-specific styles only
  simulation.js         all simulation logic (ported from the ActionScript)
  assets/               reused bitmaps exported from the SWF (Sun, Earth, Moon,
                        arrow, the Moon photograph, and the 59-frame Moon sequence)
  README.md             this file
  CONVERSION_NOTES.md   behavior model + AS→HTML5 mapping + deviations
  ACCESSIBILITY.md      WCAG affordances, ARIA, keyboard map, color notes
```

No build step, no bundler, no framework, no CDN. The only runtime network
request is the local `foundation/contents.json` fetch made by the masthead.
