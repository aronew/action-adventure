# Cinderheart close rock background — A / B / C

Three near-background scenery strips sit between the cave wall and playable terrain:

- A: large rounded basalt boulders with smaller scoria rubble.
- B: pitted lava-rock clusters and bulbous porous mounds.
- C: heavy fractured obsidian and basalt slabs with scoria pockets.

Each strip is 2048 × 512, with opaque shaded rock bodies and a transparent exterior above the irregular silhouette. Dark burgundy/charcoal faces, muted highlights and faint ember cracks match Cinderheart. This is a lower scenery band rather than a full-screen opaque wall or black foreground silhouette.

## Files

- Close-Background-A.png, B.png and C.png: individual strips.
- Close-Background-ABC-Loop.png: full 6144 × 512 loop.
- pairs/: AB, BC and CA joins, each 4096 × 512.
- Preview.html: toggle rock scenery, playable terrain and the nearest black foreground; inspect relative parallax and adjust rock height.
- layers.json, Generation-prompts.json and Validation.json: placement, source prompts and checks.
- review/: transparency overview, depth study and review-only assets from the existing scene/terrain packs.

## Placement

Place A, B and C at X = 0, 2048 and 4096, then repeat every 6144px. Alternatively use the joined ABC loop. The pair files are convenience joins, not extra depth layers. All nine ordered pairings share exact RGBA join columns, so other piece orders also connect. Keep pieces upright and on a common baseline.

Draw after the far cave wall and before playable terrain. Suggested camera factors: close rocks 0.75, playable terrain 1.0, nearest black foreground 1.2, using screenX = worldX − cameraX × factor. No collision shapes are included.

For a 1080px screen, bottom-aligned strips start at Y = 568. Raise the band if you want the rock formations to emerge behind the floor. The depth example uses Y = 448 and places the terrain floor at Y = 720. Adjust this to your room rather than relying on a fixed screen-edge placement.

Rock detail is graded darker than the uploaded terrain. Bodies remain solid; the transparent region above lets the cave wall show through. Brightness should be checked under your game's lighting. The visible maximum rock heights are 400px, 440px and 420px within the 512px canvases.

## Export notes

The built-in image tool generated three distinct 2172 × 724 sources. Export processing normalized them into the requested canvases, subdued colour/highlights and matched the ends using a shared low rubble section with geometric height transitions. This avoids transparent crossfade ghosts at joins. The original foreground and terrain assets were not overwritten.

Validation checks dimensions, exact join columns, alpha handling and lower highlight brightness. Review terrain comes from the uploaded Cinderheart pack; the black foreground and cave wall are existing assets used only to show depth. The preview holds terrain fixed and demonstrates the other layers' motion relative to it. No game-engine import is claimed.
