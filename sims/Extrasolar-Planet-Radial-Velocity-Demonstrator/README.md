# Radial Velocity Demonstrator (HTML5)

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The shared KL-UNL masthead (`foundation/kl-unl-masthead.js`) loads the simulation
title and the Help / About text with `fetch('foundation/contents.json')`. Browsers
block `fetch()` of local files under the `file://` protocol for security reasons
(same-origin policy), so opening `index.html` directly gives you a page with an
empty or broken masthead and a console error. Served over HTTP the fetch succeeds
and the simulation loads normally.

## How to run it locally

Open a terminal **inside this `html5/` folder** and use any one of these:

```bash
python3 -m http.server 8123
```

```bash
npx serve
```

```bash
npx http-server
```

Then open <http://localhost:8123/> (or whichever port the tool prints).

Because the server root is this folder, the simulation is at the site root —
`http://localhost:8123/`, **not** `.../html5/index.html`.

On Windows, `python` is usually the right command instead of `python3`:

```bash
python -m http.server 8123
```

In VS Code you can instead right-click `index.html` and choose **Open with Live
Server** (the "Live Server" extension).

## Production

Once deployed to the cloud host and served over HTTP or HTTPS it simply works.
The `file://` limitation only affects opening the file locally by double-clicking.

## What is in here

| Path | What it is |
| --- | --- |
| `index.html` | The page: KL-UNL shell, the simulation stage, the control panels. |
| `simulation.js` | All simulation logic, ported from the original ActionScript. |
| `styles/styles.css` | Sim-specific styles only. Shared style comes from the foundation. |
| `foundation/` | The shared KL-UNL files, copied in unchanged. Do not edit these here. |
| `assets/` | The vector art exported from the original SWF, reused as-is, plus a local copy of MathJax. |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript mapping, and every deviation from the original. |
| `ACCESSIBILITY.md` | Keyboard map, ARIA and live-region wording, colour changes, and what still needs human QA. |

There is no build step and no bundler. Everything is plain HTML, CSS and
JavaScript, and every file it loads is local — nothing leaves the host.
