# Bone painted animations and FX — checked v5

Includes all 22 animations (252 character frames), 17 Body/FX/BladeGlow sheets, individual character PNGs, timing/pivot metadata and original source sheets.

Extract the entire ZIP and open Preview.html. It supports source-versus-painted playback, frame stepping, a source ghost overlay, separate Body/FX layers and all four HeavyAttack BladeGlow states. BladeGlow uses 150 ms intervals for inspection only; use the charge cycle in the source guide in-game. Animation-Review.mp4 plays every animation twice, side by side. review/frame-comparisons contains source/painted comparisons for every unique body/effect pose.

## Changes

The latest pass restores the later grapple sparkle pulses to the source opacity of 175/255 and makes the doorway fade follow the original brightness progression. All body alpha silhouettes remain unchanged from v2. Split-sheet timing arrays are explicit in Animations.json, and FX-Timing-Check.json records their active frames.

54 layer-frame files differ from the initial painted export. The third pass corrected 10 additional frames: four grapple FX pulses and six doorway fade frames. Pose artwork was not regenerated or moved in the third pass.

- Removed the invented cloak buttons in Attack2.
- Restored the missing eyes and shoulder hilt in HeavyAttack frame 2.
- Restored the second eye in Attack2 frame 0 and the half-blink states in JumpFall frame 1, Idle frame 23 and Death frame 1.
- Removed rectangular white/gray haze from HeavyAttack FX.
- Reused identical painted artwork wherever cropped source pixels are exactly identical across animation states, preserving each source frame's original placement.
- Corrected double-applied death fading; all 20 death-frame peak alpha values now match their originals.
- Corrected seven composite frames to put Body above FX where that better matches the original combined sheet. Other composite frames retain FX above Body.

All frame indices in reports are zero-based. Cleanup-Changes.json records individual changes; Cleanup-Generation-Provenance.json contains the cleanup prompts.

## Position and split-sheet checks

322 body/effect frame slots were checked. All 29 source-empty FX slots remain empty. The source canvas, frame count, frame order, durations and pivot coordinates are retained at 8x export scale. All painted content stays within the reference registration rectangle for its frame (defined by source alpha greater than 8). Soft-edge shapes within those rectangles are newly painted, so the exact silhouette is different.

All 136 cells across the 17 split sheets match their processed frame files. All 66 Body/FX compositions reproduce the corresponding painted combined-frame exports. Split sheets now include explicit source/scaled pivot metadata. Repeated original frames retain identical painted artwork. The 30x30 WallSlide source frames were confirmed pixel-identical to the PRO Body sheet cropped at (4,8), validating the adjusted (14,28) pivot.

Use composite_order_per_frame in Animations.json when assembling split layers: body_over_fx means FX below Body, and fx_over_body means Body below FX. Both use normal straight-alpha blending. For the optional charging BladeGlow, draw its states above HeavyAttack frame 4 according to the source guide.

## Remaining limits

This cleanup does not certify pixel-exact internal poses. Eyes, hands, sword tips and the silhouette can still differ from the original pixel art. Bounding-box registration and pivot checks verify placement conventions, not a matching rig or matching weapon trajectories. Alignment-Audit.json includes the per-frame registration rectangles and diagnostic red-feature positions; those colour centroids are not certified anatomical landmarks. No game-engine playback test was performed.

Three supplied original combined frames cannot be reconstructed exactly by compositing their supplied original Body/FX pairs in either whole-layer order: Attack1 frame 3, HeavyAttack frames 4 and 5. The exported composite uses the order with the lower premultiplied colour/alpha error against the original combined sheet. Source-Layer-Order-Audit.json records both comparisons. These exceptions originate in the supplied source layers, and are not described as resolved.

## Import

A 30x30 source frame becomes 240x240; all other frame canvases are also scaled by exactly eight. Set display/world scale to 1/8 to replace the original at its previous world size, or use the normalized pivots in the metadata. Keep each full frame canvas; do not independently auto-center or trim frames when importing. Filenames state the exported frame dimensions.

The plain Cast animation from Archive.zip is included. All 23 standalone FX supplied in Bone.zip are included under VFX. Additional PRO-only character cast animations were not supplied in those two archives. Source-Animation-Guide.txt and Source-LICENSE.txt retain the earlier source-pack instructions and license. Validation.json records the checks and remaining limits.

## Standalone FX added from Bone.zip

All 23 standalone FX sheets (148 frames) are now included under VFX/Bone, with individual frames under Frames/VFX/Bone. Open VFX/Preview.html to compare every effect with its source. Includes charges, auras, power burst, Basic/Rapid/Big projectiles and impacts, arrow release/projectile/impact, movement dust and double-jump ring. Source 20 fps timing, loop flags and anchors are retained at 8x export scale. See VFX/Integration.json for the existing Bow and plain Cast spawn events and offsets, and VFX/Validation.json for checks and limitations. The existing 22 character animations and 17 split layers are carried forward from v3. Painted internal particle paths remain approximate.

## FX check pass

All 23 standalone FX animations (148 frames) were checked. RGB-only fade corrections were applied to 37 frames across 14 effects to stop late highlights remaining white-hot after the source has faded to red. Alpha masks, frame placement, anchors, timing and loop artwork remain unchanged. See VFX/FX-Pass-Report.json, VFX/Fade-Corrections.json and VFX/Review/Loop-Seams.png. The FX comparison player, contact sheets and review video show this version. Internal particle paths and painted silhouettes remain approximations; no game-engine test was performed.
