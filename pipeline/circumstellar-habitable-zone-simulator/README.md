# Circumstellar Habitable Zone Simulator (Accessible HTML5)

An accessible HTML5 rebuild of the NAAP Circumstellar Habitable Zone Simulator,
running on the shared KL‑UNL foundation. Behaviour is a faithful port of the
original Adobe Flash simulation (decompiled ActionScript); the chrome, layout
and accessibility follow the KL‑UNL pipeline and WCAG 2.1 AA.

## It MUST be served over HTTP — it will not run from a double‑clicked file

Opening `index.html` directly from your file system (a `file://` path) shows an
empty or broken masthead and never loads the simulation.

**Why:** the KL‑UNL masthead component (`foundation/kl-unl-masthead.js`) loads
its title / Help / About text with `fetch('foundation/contents.json')`, and the
simulation loads the stellar‑evolution data with `fetch('assets/shzStars.json')`.
Browsers block `fetch()` of local files under the `file://` protocol (the
same‑origin policy), so those requests fail and the page stays blank. Served over
HTTP the fetches succeed and everything loads normally.

## How to run it locally

Serve **from inside this `html5/` folder** so the simulation sits at the server
root, then open the printed URL (e.g. `http://localhost:8123/` — **not**
`.../html5/index.html`).

- **Python** (any OS with Python 3):
  ```
  python3 -m http.server 8123
  ```
  then open <http://localhost:8123/>

- **Node**:
  ```
  npx serve
  ```
  (or `npx http-server`) and open the URL it prints.

- **Windows PowerShell** (no Python/Node needed) — a tiny static server is
  included:
  ```
  powershell -ExecutionPolicy Bypass -File serve.ps1 -Port 8123
  ```
  then open <http://localhost:8123/>

- **VS Code**: the *Live Server* extension (Right‑click `index.html` → *Open with
  Live Server*).

## Production

When deployed to the KL‑UNL cloud host (served over HTTP/HTTPS) it just works —
the `file://` limitation only affects opening the page locally by double‑click.

## What's in here

```
index.html          KL-UNL scaffold: .app-shell + <kl-unl-masthead> + panels
foundation/         shared KL-UNL files, copied in unchanged (kl-unl-masthead.js,
                    kl-unl.css, kl-unl.js, contents.json, mathjax/) — code never
                    edited; only this sim's contents.json entry was adjusted
styles/styles.css   sim-specific styles layered on top of the foundation
simulation.js       all simulation logic (physics port + rendering + a11y)
assets/             reused exported art + data: shzStars.json (decoded stellar
                    tracks), hr-background.jpg (H-R density map), planet-*.png
                    (the planet state frames), Verdana fonts
serve.ps1           optional local static server (dev convenience)
README.md           this file
CONVERSION_NOTES.md behaviour model, AS→HTML5 mapping, the contents.json entry,
                    reused-vs-redrawn assets, and every deviation from the original
ACCESSIBILITY.md    WCAG affordances, ARIA, keyboard map, colour notes, SR wording
```

No build step, no bundler, no framework, no CDN — every file is local.
