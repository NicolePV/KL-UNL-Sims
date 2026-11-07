# `fla/` — decompiled Flash source

This folder is the original Adobe Flash simulation
(`milkyWayRotationalVelocity005.swf`, 10 June 2009), decompiled with
[JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler).
It is kept for provenance: it is the ground truth the HTML5 version at the
repository root was ported from.

Nothing here is served by the live site, and none of it is loaded at runtime.

| Path | Contents |
| --- | --- |
| `milkyWayRotationalVelocity005.swf` | the original compiled Flash movie |
| `scripts/` | decompiled ActionScript 1 — the behavioural ground truth |
| `shapes/`, `sprites/`, `images/`, `fonts/` | exported art and typography |
| `texts/` | exported on-screen strings |
| `frames/`, `Capture.PNG` | renders of the running original, used as the layout reference |
| `symbolClass/symbols.csv` | linkage name ↔ symbol id map |
| `foundation/` | the KL-UNL foundation files as supplied with this sim |

`../CONVERSION_NOTES.md` documents which of these files were read, how each
ActionScript construct was mapped to the HTML5 port, and every place the port
deviates from the original.
