# Spectroscopic Parallax Simulator (HTML5)

**This simulation must be served over HTTP. It will not run from a
double-clicked `index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (the same-origin policy), so opening
`index.html` directly gives an empty or broken masthead and no title. Served
over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside the `html5/` folder**, then open the URL it
prints.

Python:

```bash
python3 -m http.server 8123
```

then open <http://localhost:8123/>

Node:

```bash
npx serve
```

or:

```bash
npx http-server
```

VS Code: install the **Live Server** extension, right-click `index.html`, and
choose *Open with Live Server*.

Because the server root is the `html5/` folder itself, the simulation is at
`http://localhost:8123/` — not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP or HTTPS) it just works. The
`file://` limitation only affects local double-clicking.

## What is in here

| Path                  | Contents                                                        |
| --------------------- | --------------------------------------------------------------- |
| `index.html`          | Page scaffold: `.app-shell`, `<kl-unl-masthead>`, five panels     |
| `foundation/`         | The shared KL-UNL files, copied in byte-for-byte unchanged        |
| `styles/styles.css`   | Sim-specific styles only; shared style comes from `kl-unl.css`    |
| `simulation.js`       | All simulation logic, ported from the decompiled ActionScript     |
| `assets/`             | Exported Flash artwork reused as-is, plus the local MathJax build |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations         |
| `ACCESSIBILITY.md`    | WCAG affordances, keyboard map, colour remaps, live-region wording |

Nothing is fetched from the network at run time except `foundation/contents.json`
and the local MathJax bundle in `assets/mathjax/`. There is no build step and no
external dependency.
