# Cinderheart modular foreground

A foreground redraw using the uploaded Cinderheart terrain atlas's construction: eight separated terrain sections on a 3584 × 3584 atlas, sliced into a 7 × 7 grid of 512 × 512 tiles. The material is rounded porous scoria with broad overlapping obsidian plates, dark burgundy shading, faint ember cracks and opaque black cutaway interiors. Exteriors and openings are transparent.

## Files

- ForegroundTileSet.png: full straight-alpha atlas.
- tiles/tile-00.png through tile-48.png: 49 exact atlas crops.
- grid.json: the uploaded grid's coordinates and tile IDs, pointing to the new atlas.
- foreground.tsx: Tiled import, with no collision shapes or Wang sets.
- sections/: eight complete section PNGs, usable as an alternative to the individual tiles.
- sections.json: full-section placement bounds and source registration details.
- layer-settings.json: decorative foreground order and suggested camera factor.
- Preview.html and review/: atlas and room composition study.
- ForegroundArtwork-Native.png and Generation-prompt.json: generated source and prompt provenance.
- Validation.json: export checks.

Open Preview.html after extracting the entire archive. The room study assembles actual exported tiles against your supplied scene image. Its placement.json records positions and flips; it is not a game-engine capture. The scene reference already contains foreground art, so toggle the new assembly to compare what was added.

## Placement

Use 512px cells, zero atlas margin and zero spacing. Tile IDs, row/column positions and the eight major section bounds match the uploaded terrain. The redrawn exposed contours and hole outlines are new: this is not a pixel-identical silhouette replacement. Adjacent crops within each complete section remain coherent; arbitrary tile combinations, repetition seams and the original terrain's automatic tiling rules are not claimed or supplied. Assemble compatible parts or use whole section PNGs, concealing cut ends inside opaque fill.

Draw after playable terrain. Suggested camera motion factor 1.2 with screenX = worldX − cameraX × factor; terrain typically uses 1.0. Disable collision for the foreground layer. These are room-space modular pieces, not repeating panoramic strips. Keep the central action area clear by composing masses along the ceiling, bottom and room boundaries.

The foreground's RGB values are graded to 55% of the generated source, with near-black solid interiors cleaned to pure black. Source artwork was generated at 1254 × 1254 and registered by section into the requested 3584px atlas; larger export size does not imply extra native painted detail. Final brightness should be checked under your game's lighting.

Validation checks the grid, all 49 exact tile crops, alpha transparency, opaque black interiors, eight separate major groups and absence of overlapping sections. No engine import, collision or general autotile behavior has been tested.
