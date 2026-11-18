# Six Biome Environment Pack — Rebuilt Terrain v2

Unzip the complete folder, then open **Preview.html** for the interactive parallax review. Each biome folder also contains a static LayerPreview.png.

## Included biomes

- Drowned Bell Sanctum
- Amber Hive Catacombs
- Ashen Root Ossuary
- Cinderheart Caldera
- Marrow Vault
- Amethyst Echo Grotto

## Per-biome contents

| Folder | Contents |
|---|---|
| terrain | 3584 × 3584 RGBA atlas, native terrain artwork, 49 individual 512 × 512 cells, grid.json and Tiled tileset.tsx |
| assets | Transparent artwork sheet, 16 separately cropped PNG sprites, sprites.json with exact crop rectangles |
| parallax | Separate background, midground and foreground PNGs on a common 1920 × 1080 canvas; layers.json with camera factors |

Props comprise short/medium/long platforms, a terrain block, left and right walls, a corner, a ceiling overhang, two rock clusters, two decorations, a hanging decoration, a ruin and two hazards. These freeform pieces retain their native artwork dimensions; they do not use the terrain's fixed tile grid.

## Rebuilt terrain artwork

All six terrain atlases now use newly drawn biome-specific materials from their approved mock-ups: damp slate and sparse teal moss, stone and honey wax, root-wrapped mauve rock and sparse ivory lichen, cracked lava basalt, bone-plated fossil rock, and crystal-studded indigo slate. These replace the earlier Mossy recolors.

The file grid is retained: 3584 × 3584 atlas, 7 × 7 cells, each 512 × 512, top-left origin, zero margin and zero spacing. Tile file names, rectangle coordinates and Tiled import dimensions are unchanged. The painted silhouettes and edge details have changed. These are not pixel-identical copies of the source geometry, and source collision contours and autotile joins must be reviewed against the new art.

TerrainArtwork-Native.png retains the native generated artwork. sections.json records each native crop and its target rectangle. TileSet.png fits each of the eight major terrain groups separately into the corresponding original section rectangle before slicing; the export size does not imply extra painted detail. This pass addresses visual fidelity to the approved designs, not verified engine-specific autotiling or collision authoring.

## Parallax assembly

Draw the distant background first, then the midground, then gameplay terrain and props, and finally the foreground. The backgrounds are opaque; midground and foreground have real alpha transparency. They are separate scenery layers, not a flattened mock-up with invented depth metadata.

| Layer | Example camera-motion factor | Relative draw order |
|---|---:|---:|
| Distant background | 0.15 | -30 |
| Midground | 0.50 | -20 |
| Gameplay | 1.00 | 0 |
| Foreground | 1.20 | 10 |

Use **screen position = world anchor − camera delta × factor**. At a camera movement of +100 pixels, the sample background moves -15 pixels, the midground -50, gameplay -100, and foreground -120. These numbers are tuning defaults; map the formula to your engine's camera system rather than assuming that an engine-specific scroll-scale field has the same meaning.

Layers are finite room illustrations, not seamless horizontal or vertical repeats. The preview uses 20% overscan for modest camera movement. For a larger level, resize/place layers to cover your room or extend the scenery; do not simply enable texture wrapping. Keep scenery non-collidable. Water, lava and light effects in this version are static art.

All scenery layers are normalized to 1920 × 1080 for a common coordinate system. Native generated dimensions are recorded in validation.json; normalization is a display-size export, not a claim of extra painted detail. All PNGs use straight alpha. Choose linear filtering for the smooth illustrated art and avoid importing it with pixel-art snapping or nearest-neighbor scaling unless intentionally desired.

## Verification and source files

validation.json records atlas dimensions, checks of all 294 terrain crops, sprite counts and scenery alpha statistics. Each sprite export adds 8 transparent pixels around its stored source rectangle. Adjust sprite pivots and collision geometry to your gameplay; suggested pivots are included as starting values.

The approved room mock-up is included in each biome's ConceptReference.png for visual reference only. LayerPreview.png is a small scenery composite for review; it is not the full-resolution export. Generation-prompts.json records the art directions. The terrain art directions and exact crop coordinates are recorded alongside the new exports. Rebuilt-Terrain-Preview.png gives a six-biome overview.
