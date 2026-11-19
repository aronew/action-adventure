# Taller black silhouette foreground expansion

Three NEW bottom strips add longer, taller silhouettes:

- D: extra-long slender curved blades and sweeping tips — 480px visible height.
- E: tall broad wavy fronds and spear leaves — 468px visible height.
- F: sparse upright reed-like shoots and long ribbon blades — 492px visible height.

All three use 2048 × 512 transparent straight-alpha canvases, pure black RGB and opaque bodies with antialiased outlines. Negative spaces between plants stay transparent. They share the same low 48px end profile as the original A/B/C strips, which are included unchanged.

## Files

- Foreground-Bottom-A.png through F.png: six interchangeable 2048 × 512 pieces.
- Foreground-Bottom-DEF-Loop.png: tall-only D → E → F loop, 6144 × 512.
- Foreground-Bottom-ABCDEF-Loop.png: all six in order, 12288 × 512.
- Foreground-Bottom-ADBECF-Loop.png: alternating lower and taller pieces, 12288 × 512.
- pairs/: DE, EF, FD, CD and FA convenience joins, each 4096 × 512.
- Preview.html: scrolling tall-only and mixed sequences.
- review/: taller variations and all-six comparison images on a light field.
- layers.json, Validation.json and Generation-prompts.json: placement, checks and built-in image-generation prompts for the new pieces.

## Use

Bottom-align all 512px strips. At 1080px screen height, the strip canvas starts at Y = 568. Individual pieces are 2048px wide; place them side-by-side in any order. All 36 ordered pairings among A–F match exactly in RGBA at their joins. Keep the art upright. Use either individual pieces or a prejoined loop, not both simultaneously.

The new foliage rises farther into the screen; place tall pieces as accents between lower pieces to retain open sightlines. Suggested nearest-foreground camera factor: 1.2 with screenX = worldX − cameraX × factor; draw above playable terrain and use no collision. These are bottom-only foreground bands, with no ceiling or room borders.

The lighter field in review images is not baked into the assets. Open Preview.html after extracting the complete archive; choose tall-only or mixed ordering, scroll the loop or show the join markers.

The new source artwork was generated at 2172 × 724, trimmed to its silhouette bounds and normalized to the stated visible heights within the requested 2048 × 512 canvas. Low endpoints were geometrically matched to A/B/C. All PNG artwork pixels have black RGB, with alpha carrying the silhouettes. Original A/B/C files are byte-for-byte copies. Export checks cover join equality, dimensions, alpha and loop crops; no engine import has been tested.
