# Cinderheart wall-fill add-on

Sixteen 512 × 512 opaque rock-fill tiles add volume to the black wall interiors. The variants mix small scoria clusters, medium rocks, large boulders and overlapping obsidian plates. Their shared textured perimeter makes every upright variant compatible with every other variant on all four sides. There are no black frame borders around the fill tiles.

## Included

- FillTileSet.png: 2048 × 2048 atlas, 4 columns × 4 rows, zero margin/spacing.
- fill-tiles/: 16 individual 512 × 512 PNGs.
- fill-grid.json and fill-tiles.tsx: tile mapping and Tiled import with equal variant probabilities.
- textured-foreground/: an optional ready-filled version of the previous 3584 × 3584 foreground atlas, its 49 individual 512px crops, mapping and Tiled import.
- Preview.html: randomize a wall, inspect seams and compare the textured foreground atlas.
- review/: random wall image, sample tile IDs and atlas comparison images.
- WallArtwork-Native.png and Generation-prompt.json: source artwork and built-in generation prompt.
- Validation.json: export and seam checks.

## Use

Paint these fill variants on the same 512px grid as your foreground. Any variant may be placed beside any other, horizontally or vertically. Use the tiles upright; turn off random rotations and flips so the matching edge profiles and lighting stay aligned. All fills are fully opaque RGBA PNGs because they represent solid interior rock. They are decorative and have no collision shapes.

Keep fill inside the solid wall shape, using an interior mask, or use the included textured-foreground alternative. That version fills only large opaque black core regions, fades the texture into the original dark edges, and preserves the previous atlas's alpha byte-for-byte. Exterior gaps, concave cutouts and holes remain transparent; the visible edge artwork is retained. The previous atlas is still available separately and was not overwritten.

The 16 variants share perimeter detail, so some edge rock features repeat. Their interiors vary in crop, rock scale and arrangement. A periodic rock boundary and minimum-cost patch seams provide compatible joins; a narrow blend softens the patch transition without introducing black grid lines. Native source artwork is 1254px square, normalized into export tiles; export dimensions do not imply extra native detail.

All 256 ordered variant pairs were checked for exact RGBA agreement at both horizontal and vertical joins: 262,144 boundary-pixel comparisons. The randomized preview uses a recorded 8 × 6 layout. No game-engine import or collision behavior has been tested. The original foreground's general autotile rules remain outside this add-on's scope; the new opaque fill variants themselves can mix freely.
