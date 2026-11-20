# Cinderheart close-background plants — A / B / C

Three 2048 × 512 plant strips add a thin, tall scenery layer behind the playable terrain. They match the volcanic area's charcoal/burgundy palette, wiry ember-tip plants and small scoria bases.

- A: slender arching stalks with small subdued copper seed tips.
- B: tapered curling fronds and hanging oval pods.
- C: thin branching tendrils, long spear fronds and sparse buds.

The plants retain shaded dark colour rather than flat black. Bodies are opaque, with antialiased edges and genuine transparent gaps between stems. Visible heights are 460px, 480px and 472px within the 512px canvases. Sparse groups and quiet stretches keep the layer open.

## Files

- Close-Plants-A.png, Close-Plants-B.png and Close-Plants-C.png: individual straight-alpha PNGs.
- Close-Plants-ABC-Loop.png: joined 6144 × 512 loop.
- pairs/: AB, BC and CA convenience joins, each 4096 × 512.
- Preview.html: layer toggles, plant height and relative parallax review.
- layers.json, Validation.json and Generation-prompts.json: settings, checks and built-in generation prompts.
- review/: transparency overview and existing scene assets used only for the depth demonstration.

## Placement

Place A at X = 0, B at X = 2048 and C at X = 4096, repeating every 6144px. Alternatively use the full ABC image. Pair images are joined alternatives, not additional layers. All nine ordered plant pairings have exact RGBA agreement at their shared join columns; other orders also work. Keep strips upright and on a common baseline.

Draw after the far cave wall and before the playable terrain. The example places plants behind the close rock bands, with suggested camera factors of 0.7 for plants, 0.75 for rocks, 1.0 for terrain and 1.2 for the nearest black foreground. Here screenX = worldX − cameraX × factor. These are decorative layers without collision.

For a 1080px screen, bottom-aligned 512px bands begin at Y = 568. Raise them to sit visibly behind your floor as needed. The supplied example uses plant Y = 380, rocks Y = 448 and terrain-floor Y = 720. The plant strips loop with one another; the previous rock strips remain a separate layer.

Extract the whole archive and open Preview.html. The terrain stays fixed to make relative parallax easy to assess. Review scenery comes from the prior scene packs and is not newly delivered terrain. The light field in the overview is only for review, not baked into the transparent assets.

Native generated sources were 2172 × 724. Their visible plant bounds were normalized to the requested export canvases, graded to subdued highlights and joined with a common low rubble end section. Geometric transitions keep the end bodies solid. All game PNGs preserve alpha and zero RGB outside the art. Earlier assets were not overwritten. No game-engine import has been tested.
