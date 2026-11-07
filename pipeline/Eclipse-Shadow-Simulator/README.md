# Eclipse Shadow Simulator (Accessible HTML5)

Draggable Earth and Moon discs cast **umbra** (total) and **penumbra** (partial)
shadows away from a fixed Sun, illustrating how the two kinds of shadow give rise
to different types of eclipse. This is an accessible HTML5 rebuild of the original
Adobe Flash simulation (`shadows003.swf`), built on the shared KL-UNL foundation.

## ⚠️ It must be served over HTTP — double-clicking `index.html` will NOT work

The KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads its title, Help, and
About text with `fetch('foundation/contents.json')`. Browsers **block `fetch()` of
local files over the `file://` protocol** (same-origin security policy), so opening
`index.html` directly from your file manager shows an empty / broken masthead and a
console error. Serve the folder over HTTP instead and everything loads normally.

## How to run locally

Run one of these **from inside this `html5/` folder**, then open the printed URL:

```sh
# Python 3
python3 -m http.server 8123
#   then open  http://localhost:8123/

# Node
npx serve
#   (or)  npx http-server

# VS Code
#   Install the "Live Server" extension and click "Go Live".
```

Because you are serving from *inside* `html5/`, the simulation is at the server
**root** — the URL is `http://localhost:8123/`, not `http://localhost:8123/html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works — the
`file://` limitation only affects double-clicking a local copy.

## Files

```
index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/         shared KL-UNL files, copied in unchanged
                      (kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json)
styles/styles.css   sim-specific styles only (layered on the foundation)
simulation.js       all sim logic (verbatim port of the ActionScript)
assets/             exported disc art reused as-is (sun.png, earth.png, moon.png)
README.md           this file
CONVERSION_NOTES.md behavior model, AS→HTML5 mapping, deviations
ACCESSIBILITY.md    WCAG affordances, ARIA, keyboard map, color notes
```

No build step, no bundler, no framework, no CDN. Everything is local; the only
runtime fetch is `foundation/contents.json` (same origin).
