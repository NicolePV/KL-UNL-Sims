# Phase Positions Demonstrator (HTML5)

An accessible HTML5 port of the Flash *Phase Positions Demonstrator*, built on the
shared KL-UNL foundation. A star sits at the centre of an overhead view with two
draggable planets; each planet's phase, as seen from the other, is drawn in the
right-hand **Disc Appearances** column.

## It must be served over HTTP

**This simulation will not run from a double-clicked `index.html` (a `file://`
path).** The KL-UNL masthead loads its title / Help / About text with
`fetch('foundation/contents.json')`, and browsers block `fetch()` of local files
over `file://` for security (the same-origin policy). Opened directly, the page
shows an empty or broken masthead. Served over HTTP the fetch succeeds and the sim
loads normally.

## Run it locally

From **inside this `html5/` folder**, start any static web server, then open the
URL it prints. Because you are serving from inside `html5/`, the sim is at the
server root — the URL is `http://localhost:8123/`, not `.../html5/index.html`.

Python:

```bash
python3 -m http.server 8123
```

Node:

```bash
npx serve
```

(or `npx http-server`)

VS Code: the **Live Server** extension ("Go Live").

Then browse to <http://localhost:8123/> (or whatever port the tool reports).

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works; the
`file://` limitation only affects local double-clicking.

## What's in here

```
index.html            KL-UNL scaffold + <kl-unl-masthead> + panels
foundation/           KL-UNL shared files, copied in UNCHANGED
                        (contents.json already contains this sim's entry,
                         keyed "phaseDemonstrator")
styles/styles.css     sim-specific styles only
simulation.js         all sim logic (faithful port of the ActionScript)
assets/mathjax/       MathJax, vendored locally (no CDN)
CONVERSION_NOTES.md   behaviour model + AS -> HTML5 mapping
ACCESSIBILITY.md      WCAG affordances, keyboard map, colour notes
```

No build step, no bundler, no framework, no CDN. The only runtime fetches are
local (`foundation/contents.json` and the vendored MathJax). Nothing leaves the
host.
