# Black silhouette bottom foreground — A / B / C

Three distinct black foreground strips follow the bottom foliage in your reference: a dense low base with scattered curved blades, long fronds, rounded leaf tufts and small buds. The upper portion of each canvas is transparent, with quiet low stretches between taller clusters.

## Game assets

- Foreground-Bottom-A.png, B.png and C.png: each 2048 × 512, straight-alpha RGBA PNG.
- Foreground-Bottom-ABC-Loop.png: all three joined, 6144 × 512.
- pairs/: AB, BC and CA convenience joins, each 4096 × 512.
- screen-templates/: individual strips padded to a transparent 2048 × 1080 canvas, already bottom-aligned.
- layers.json: placement, loop period and suggested parallax factor.

Visible artwork is pure black #000000. Bodies are opaque, with antialiased boundaries and transparent gaps between plants. The visible silhouette height varies by piece: A 339px, B 320px and C 311px; the remainder of the 512px canvas stays clear.

## Placement

For a 1920 × 1080 screen, anchor the 512px-high strip at Y = 568. Place A at X = 0, B at X = 2048 and C at X = 4096, then repeat the sequence every 6144px. Alternatively, use the single ABC loop. The pair files are convenience combinations, not additional layers to stack on top.

All pieces share a low 48px-high silhouette profile at both ends. Every A/B/C ordered pairing matches exactly in RGBA, so A → B → C → A loops without a step. Other piece orders also connect. Keep strips upright and bottom-aligned.

Draw this as the nearest decorative foreground above the play layer. Suggested camera factor: 1.2, where screenX = worldX − cameraX × factor and playable terrain uses 1.0. No collision shapes are included. Side borders and ceiling pieces are not part of this bottom-only set.

Extract the complete archive and open Preview.html to scroll or play through the loop, inspect joins or compare against the reference scene. Review images use a light background to reveal the black silhouettes; that background is not baked into the game assets.

Generation-prompts.json records built-in image-generation prompts and source paths. Native sources were 2172 × 724, uniformly resized to width 2048 and cropped from the bottom to a 512px canvas. End geometry was normalized to a common low base; artwork RGB was set to black while preserving alpha. Export dimensions are exact. Validation.json records pure-black values, transparency, dimensions and seam checks. No game-engine import has been tested.
