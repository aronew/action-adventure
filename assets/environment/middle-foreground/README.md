# Six biome middle foreground kit

New modular non-collidable scenery between playable terrain and the nearest dark foreground. 16 pieces per biome: nine-slice solid terrain masses plus curved column, overhang, mound, concave shapes and arch halves. Each uses its biome material, shaded exposed edges and opaque black interiors; exterior/cutouts use straight alpha.

Open Preview.html locally after extracting the whole archive. Toggle the new layer and nearest foreground, or scrub camera motion. Reviews are composition studies using an approved mockup crop as a playable-terrain reference, not newly delivered terrain or an engine screenshot.

## Import

MiddleForeground.png is 2048 × 2048, four columns and four rows of 512 × 512, no spacing/margin. Individual PNGs are identical atlas crops. middle-foreground.tsx provides the same mapping for Tiled; no collision shapes. This is a new scenery mapping, not the earlier 7 × 7 terrain atlas.

Build solid masses with the 3 × 3 core at indices 0,1,2 / 4,5,6 / 8,9,10. Repeat the straight edges and fill to enlarge. Core mating edges match exactly in RGBA. Extra pieces are hand-placed with overlaps at hidden ends; there is no universal Wang/autotiling scheme.

Suggested draw order: cave wall (factor .85), playable terrain (1), new middle foreground (1.06), nearest dark strips (1.2). Engine conventions vary; factor here means screenX = worldX - cameraX × factor. Existing terrain and 435px nearest strips stay separate. Full modular volumes have no fixed 435px height. Keep the central action area unobstructed.

Coloured rims were graded to 78% of their generated source values. Final brightness relative to your playable assets should be checked in-engine under your project's lighting. Native generated sheets are 1254px square, normalized to the 512px grid; export size does not imply additional native detail.

Validation.json records transparency, exact core seams and atlas/piece equality. Asset exports were checked programmatically; no game engine import or collision behaviour is claimed. Generation-prompts.json preserves built-in image-generation prompts and source provenance.
