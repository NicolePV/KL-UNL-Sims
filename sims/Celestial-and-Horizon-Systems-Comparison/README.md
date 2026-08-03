# Celestial and Horizon Systems Comparison — HTML5

**This simulation must be served over HTTP. It will not run from a double-clicked
`index.html` (a `file://` path).**

## Why

The KL-UNL masthead component (`foundation/kl-unl-masthead.js`) loads the
simulation's title and its Help / About text with
`fetch('foundation/contents.json')`. Browsers block `fetch()` of local files
under the `file://` protocol for security (the same-origin policy), so opening
`index.html` directly gives you an empty or broken masthead and a console error.
Served over HTTP the fetch succeeds and the simulation loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**:

```
python3 -m http.server 8123
```
then open <http://localhost:8123/>

```
npx serve
```
(or `npx http-server`) — the command prints the URL to open.

**VS Code:** install the *Live Server* extension, then right-click `index.html`
and choose “Open with Live Server”.

Because you are serving from inside `html5/`, the simulation sits at the server
root — the URL is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

Deployed to the cloud host over HTTP/HTTPS it just works. The `file://`
limitation only affects local double-clicking.

## What is in this folder

| Path | Contents |
| --- | --- |
| `index.html` | The page: KL-UNL shell, masthead, diagram panel, controls panel |
| `simulation.js` | All simulation logic, ported from the decompiled ActionScript |
| `styles/styles.css` | Simulation-specific styles only |
| `foundation/` | KL-UNL foundation files, copied byte-for-byte unchanged |
| `assets/` | Exported Flash artwork, reused as-is (not redrawn) |
| `CONVERSION_NOTES.md` | Behaviour model, ActionScript → HTML5 mapping, deviations |
| `ACCESSIBILITY.md` | WCAG affordances, keyboard map, colour remaps, testing notes |

There is no build step, no bundler and no framework. Every file is local; the
only runtime requests are for the files listed above.
