# Bone standalone painted FX

All 23 effects / 148 frames from Bone.zip are included. Open Preview.html locally after extracting the complete pack. Select each effect and compare it with its original at the same anchor. The PNGs use straight alpha.

All effects use the source 20 fps / 50 ms frame timing and original loop flags. Frame canvases and anchors are scaled by eight to match the character exports. Use 1/8 display scale to keep the original world size. Set origin to the provided normalized anchor; do not auto-center each trimmed frame. Projectiles, muzzle flashes and dash dust face right; flip the sprite and its anchor when facing left. Integration.json gives original Bow and Cast spawn events and offsets; projectile travel and collision remain game-controlled.

Generated internal shapes and particle paths approximate the source artwork. Source timing, canvas dimensions, frame count/order, peak opacity and anchor coordinates are verified. Not tested inside your engine.

## Checked v5

The FX pass corrected RGB fade envelopes in 37 frames across 14 effects. All 148 alpha masks and all geometry/timing/anchor metadata are unchanged. Seven loop sequences and all atlas/frame cells were checked. See FX-Pass-Report.json and Fade-Corrections.json for scope and limits.
