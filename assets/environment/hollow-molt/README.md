# The Hollow Molt — complete biome pack

Approved monochrome organic cavern: shed chitin plates, curled molts, ribbed shell-fans, cocoon fibers and black trailing growth. All exported PNG artwork has identical R/G/B channels: true grayscale.

## Terrain and depth terrain

`terrain/` contains the gameplay atlas; `middle-foreground/` contains a separately drawn darker decorative version. Each has a 3584 × 3584 RGBA atlas, 49 separate 512 × 512 tiles, 7 × 7 grid, zero margin/spacing, top-left origin, Tiled tileset, exact grid and eight section target rectangles matching the supplied pack. Native artwork is 1254 × 1254; normalization does not add native painted detail. Black cores are opaque; exterior gaps and lined tunnel openings transparent.

These are new painted contours, not original pixel-identical collision shapes. Review tile joins and author collisions/autotile rules in your engine. The darker set is non-collidable depth scenery; it uses the terrain method rather than a flat strip. Its contours are newly drawn and may differ slightly from gameplay pieces.

## Props

16 native-size PNGs with 8px transparent padding: three platform widths, block, two walls, corner, ceiling, small rubble, large molt, low shell clump, tall fan, hanging cocoon fibers, collapsed shell arch, straight and curved hazards. Exact extraction rectangles and suggested pivots are in `assets/sprites.json`. No behavior or collision scripts included.

## Backgrounds and depth

Separate 1920 × 1080 opaque distant background and transparent close-background/midground. Draw background → midground → gameplay → decorative middle foreground → near foreground. Suggested camera factors: 0.15 / 0.50 / 1.00 / 1.08 / 1.20. These background layers are finite room illustrations, not seamless repeats.

## Seamless foreground

Both `foreground/bottom/` and `foreground/top/` contain **three 2048 × 512 base bands: A, B, C**. Place A then B then C then A at 2048px x steps; cycle width 6144px. Do not repeat A alone.

Bottom bands: place matching `-upper-extension.png` at the SAME x and y minus 512. Or use the 2048 × 1024 `-tall.png`, bottom aligned. Top bands: matching `-lower-extension.png` is at SAME x and y plus 512; combined tall version is top aligned. Extensions and bases must have identical scroll factors and offsets. Taller peaks are sparse. Each cycle is also included as one 6144 × 1024 image. Exact peak heights and placement are in `parallax/layers.json`.

Separate left/right **512 × 1080 room boundary pieces** are in `foreground/borders/`. These do not scroll as part of the horizontal bands. Keep them at room edges. Use top and bottom base bands for a clear middle; enable long extensions selectively where they fit the room's play space.

## Verification and preview

All 98 gameplay/depth tile crops and 16 prop extractions were verified against their atlases/source rectangles. Wall cores, tunnel holes, canvas sizes, strict grayscale, darker depth values, base-plus-extension reconstruction and A→B/B→C/C→A matching edge pixels were checked. No game engine or collision map was available for testing. PNGs use straight alpha; smooth filtering recommended.

Open **Preview.html** after extracting the full archive. The scene uses actual exported assets. `ConceptReference.png` is the approved art target; `LayerPreview.jpg` is an assembled sample, not a collision map.
