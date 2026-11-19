# Cinderheart large rock variations

Three newly drawn feature types give the wall a different structure: a large porous lava-rock cluster, massive rounded basalt boulders and a fractured obsidian outcrop. Colour and highlight strength match the existing dark foreground fill.

## Contents

- 12 NEW freely mixing 512 × 512 fill variants, IDs 16–27.
- The previous 16 variants, IDs 0–15, included unchanged.
- Combined-FillTileSet.png: all 28 variants on a 2048 × 3584 atlas, 4 columns × 7 rows, 512px cells, zero spacing/margin.
- Three 1024 × 1024 large features, each also supplied as four 512px parts with a 2 × 2 layout guide and Tiled import.
- combined-fill.tsx, fill-grid.json, generation prompts and validation results.
- Preview.html: random wall with optional large features and a 512px grid overlay.

## Placement

The 28 regular fill tiles can mix freely with one another and the previous pack, horizontally and vertically, when kept upright. Turn off random rotations and flips. They are opaque wall-interior artwork, intended for masking inside solid terrain or foreground walls, not the transparent outside edges. Use the same foreground layer order and camera factor as your existing wall fill.

For the larger lava cluster, boulders or outcrop, place the complete Feature-1024.png on a 2 × 2 area of the 512px grid. Alternatively assemble its four part PNGs exactly as shown in the feature's layout.json: parts 0 and 1 above parts 2 and 3. The feature's outside edges match all regular fill variants. The four feature parts belong together; they are not independent randomly interchangeable fill tiles. Each feature is also supplied as a four-cell feature-2x2.tsx for importing as a stamp.

The larger pieces let a single rock formation span several cells, breaking up repetition from the small filler stones. Use them as accents between stretches of ordinary fill. Shared perimeter detail keeps joins compatible; some smaller edge rocks consequently recur. Interiors and major rock groupings differ.

All 784 ordered pairs of regular tiles passed exact horizontal and vertical RGBA edge checks (802,816 boundary-pixel comparisons). Large feature outside edges match the same profile; their 512px split parts preserve the complete feature. Exports are opaque PNGs. No engine import or collision behavior is claimed.

Artwork was generated with the built-in image tool, then graded and normalized to export sizes. Minimum-cost patch seams join the new interiors to the existing rock perimeter. The native sources were 1254px square; export size does not imply newly painted extra detail. Earlier files have not been overwritten.
