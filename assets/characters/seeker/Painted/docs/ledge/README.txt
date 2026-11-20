SEEKER LEDGE ANIMATIONS - V2

New painted extension of the character in the supplied Spritesheets.zip.
18 frames per direction: 4 ledge catch, 4 looping one-hand hang, 10 pull-up.
Right and mirrored-left horizontal sheets and individual transparent PNGs.
All frames: 480 x 480, no atlas gutters. Imported wall-slide frames are 240 x 240.
Expanded canvas accommodates the upward movement. All new poses were redrawn
together to restore the source character compact proportions and scarf coverage.
ONE uniform 0.90 scale is used for every new drawing; no per-frame scale factors.
Original idle is unscaled. New artwork is not pixel-identical to source artwork.
The pull-up ends using the actual first idle frame from the uploaded archive.

PLAYBACK
LedgeGrab once -> LedgeHang loop -> LedgePullUp once -> existing Idle.
LedgePullUp starts from the first LedgeHang pose. If changing out of a hang loop,
crossfade or enter at that pose. Durations and slice rectangles: animation.json.
One hand grips while hanging; the second reaches up in pull-up frame 2.

PLACEMENT
The fixed ledge corner is pixel (330,240) on right-facing 480-square frames.
For mirrored-left use (149,240). Align this canvas point with the world corner.
Do not apply the existing 240-square sprite pivot to these larger frames.
Keep the animation canvas fixed through the climb. Translation is in the images;
do not also animate the entity upward. After the last frame, move the controller
to its standing location, then switch to the existing idle and original pivot.
Final right-facing idle frame equals original Idle frame 1 translated by (260,16).
Preserving that world image position during the controller/pivot switch prevents a snap.
Collider changes and ledge detection are game logic, not supplied by these images.

Preview GIF and JPG show a guide ledge. Actual PNGs contain character only.
These are generated animation drawings aligned to grip/support landmarks;
visual pose transitions should be reviewed in-engine before final production use.
Original uploaded files are unmodified. No extra FX are needed for these clips.
