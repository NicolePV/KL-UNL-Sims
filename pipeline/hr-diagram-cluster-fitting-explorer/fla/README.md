# `fla/` — original Flash source material

This folder is the **archived source** the HTML5 simulation (in the repository
root) was converted from. Nothing here is loaded or used at runtime; it is kept
for provenance, so the port can be checked against the original.

Contents are the JPEXS/FFDec decompilation of `clusterFittingExplorer.swf`
(`clusterFittingExplorer009`, 12 November 2009):

| Path | What it is |
|------|------------|
| `clusterFittingExplorer.swf` | The original compiled Flash movie. |
| `scripts/` | Decompiled ActionScript 1. The ground truth for behaviour — physics constants, tables and formulas were copied verbatim from here (chiefly `HR Diagram Component 042 Modded.as` and the eight `* Data.as` cluster files). |
| `sprites/`, `shapes/`, `frames/` | Exported symbol art. Almost all of it is Flash UI-component chrome (combo box, check box, scroll bar, panel backgrounds, dialog, grab-hand cursors) that native controls and the KL-UNL foundation replace. |
| `texts/` | Text-field strings extracted from the SWF. |
| `fonts/` | Fonts embedded in the SWF (standard Verdana). |
| `symbolClass/symbols.csv` | Linkage-name ↔ symbol-id mapping. |
| `foundation/` | The **unmodified** KL-UNL foundation as originally supplied. The copy used by the sim lives in the repository root and differs: it adds this sim's `contents.json` entry and repairs pre-existing JSON-validity bugs. See `CONVERSION_NOTES.md`. |
| `Capture.PNG` | Screenshot of the running Flash original, used as the layout reference. |

`images/`, `morphshapes/` and `movies/` were **empty** in the export (the sim has
no bitmaps or morph shapes), so git does not record them here.

See `CONVERSION_NOTES.md` in the repository root for the ActionScript → HTML5
mapping, which assets were reused versus redrawn, and every deviation from the
original.
