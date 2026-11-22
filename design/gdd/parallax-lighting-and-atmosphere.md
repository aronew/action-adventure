# Parallax, lighting and atmosphere

> **Status**: Approved (eleventh design review, 2026-11-22: APPROVED, 0 blockers, 6 recommended open). Earlier: Needs Revision at the ninth and tenth reviews, revised the same day. Designed 2026-11-20 (`/design-system`, lean, standard). First `/design-review` 2026-11-20 (lean): NEEDS REVISION, 3 blockers revised (draw order with the Seeker and the lip, rule 13; a ground fog alpha cap; section A and T from a travel range, blend centred on the edge). Second `/design-review` 2026-11-20 (lean): NEEDS REVISION, 2 blockers revised (close band values and placement, new P7; sections are strips along one axis with one spacing rule). Third `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (the close band minimum is tested on the stretch after the drop pull-in, so a 108 px platform between two drops gets none). Fourth `/design-review` 2026-11-20 (lean): NEEDS REVISION, 2 blockers revised (P6 update order stated and the silhouette AC re-derived to 34.7 px at 60 fps; the silhouette band's rise over the play space in a fall accepted by the owner and written into rules 7 and 13, with a fall AC and a playtest check); 9 recommended not applied (one applied: close band AC preconditions). Fifth `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (the reference does not bound the silhouette's lag, so after a long fall the foliage stayed at its cap about 0.9 s and took about 2.3 s to settle, not the 0.45 s and 1.35 s the rules and the AC said; owner chose to bound `lag_y` to `max_drift / sway`, so it eases back as soon as the camera stops, P6); 2 recommended applied (close band AC fixtures moved onto the 6 px grid; grid map obligation in Open Question 2) plus the P2 section scale 1.324; 9 recommended open. Sixth `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (the fall AC and P6 Example said the drift is −40 for the whole fall; the lag winds up first, so the cap is reached about 0.07 s in, −12.3 px on the first frame at 60 fps); 14 recommended open (5 new: the cap binds at 74 px/s of camera speed, so an ordinary full jump lifts the foliage about 23 px; P1 and P2 tables vs rule 8 for the room's own set; Pause and Grid map missing from the upstream table; section fog scale blend; rule 16 and 17 AC coverage). Seventh `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (room-end pieces draw in front of the Seeker but were missing from rule 13's closed list and had no width limit; owner chose an inset cap, `room_end_inset_max` 38 px, slid past the bound as the reference's left border is; rules 1, 5, 13, Edge Cases, AC); 14 recommended open (1 new: the blend curve's shape). Eighth `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (the foreground strips draw in front of the Seeker and sit in rule 13's list "each with its limit", but had none; owner chose a cap on their art's reach from the screen's edge, `foreground_reach_max`, set at 0.41 rather than the 0.40 picked because the shipped top strips measure 0.403; rules 1, 5, 13, P3, Edge Cases, AC); 15 recommended open (1 new: the grade has almost no numbers in the GDD); revised in a fresh session. Ninth `/design-review` 2026-11-22 (lean): NEEDS REVISION, 2 blockers revised, both the reference moving after owner decisions: (1) the screen bloom and radiance around the Seeker became a backlight drawn behind his sprite, because the bloom washed out his painted art (rules 1, 12, 14, Overview, Interactions, Edge Cases, Game Feel, AC; the player light lift is 0.03, not 0.1); (2) the close band runs on behind a wall at full height and fades only at a ledge drop, so `close_wall_extend` (72 px) is new and the minimum run is tested after the extension (rule 6, P7, Edge Cases, AC). Also applied: the reference's blur, fog and tint numbers (blur 7, 3.2 and a new close blur 1.2, the passes compound; P5 alphas and ramps; band tints), the ember size defined, the art bible and Terrain pipeline status corrected, the long-room bench result (draw calls max 287). Tenth `/design-review` 2026-11-22 (lean): NEEDS REVISION, 1 blocker revised (the radiance was stated 34 px wide; the reference's 34 px is its radius, 68 px across; rule 12 and the AC), 7 recommended open (P7's `x0, x1` range, the wall-end Edge Case, rule 14's blur wording, the P4 mask list, ranges for the new knobs, the rule 1 wording, the stale and carried items). The seven recommended items were then applied (P7's range, the wall-end Edge Case, rule 14's blur wording, the P4 mask list and a Reduced run, a new Tuning Knobs section with ranges, rule 1's wording, and the carried items: linear blend and fog blend, the P1 and P2 range, rules 16 and 17 criteria, the ground fog cap's home, the flicker unit, the section term, `build_time`) and the silhouette lag bound was added to the reference. Still open: the P4 example is stale (Open Question 10); awaiting re-review
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-22
> **Last Verified**: 2026-11-22
> **Creative Director Review (CD-GDD-ALIGN)**: skipped — Lean mode
> **Implements Pillar**: none defined (brief, Look: "2D pixel side view ... Sword FX on their own layer, sparks and glow on hits"; systems index: "parallax, vignette and light give depth")
> **Reference scene**: `src/test_rooms/art_style_test_room.tscn` with `src/test_rooms/room_atmosphere.gd` (owner, 2026-11-20: "lands pretty close to what I'm aiming for")

## Summary

Parallax, lighting and atmosphere draws everything in a room except the playable ground: painted back layers that drift slower than the camera, a close band of rocks and plants behind the floor, foreground framing that sweeps past faster, fog, dust, embers, warm glows and a screen grade that lights the Seeker. It gives each room depth and mood from a per-biome preset, matching the owner's reference scene, while keeping the floor edges and the Seeker the clearest things on screen. A Full / Reduced option keeps it comfortable on slow machines and for players sensitive to haze or motion.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Terrain pipeline, Rooms and transitions, Camera`

## Overview

Parallax, lighting and atmosphere is everything a room shows that is not the play layer. Around the terrain pipeline's play layer (collision, black fill, trim and dressing at draw order 0) it builds a room's depth: painted back layers that move slower than the camera (the far city, the midground ruins, the close rocks and plants just behind the floor), foreground framing that moves faster (the foreground strips and the black silhouette band), fog banks between those layers, drifting dust and rising embers, warm glows on lit props, and a screen grade over it all (an ambient gradient, a soft light around the Seeker, contrast and split tone, a vignette) and a warm backlight behind the Seeker's sprite. A room chooses its layers and their settings from its biome and its own data; this system places, moves and draws them every frame from the camera. The player never operates it: they feel it as a deep, warm, hazy world in which the pale Seeker and the bright floor edges are always the clearest things on screen. It owns no collision and changes no rule of play, but it must never mislead: nothing it draws may read as ground, a ledge or a gate (terrain rule 5; level design, Readability). Without it a room is black masses on a flat colour, and the look the brief and the owner's reference scene set (`art_style_test_room.tscn` with `room_atmosphere.gd`) is lost. How the pass is built (shaders, node layout, a scene per biome) is an ADR, not this document. **[Owner, 2026-11-20: the reference scene lands close to the aim]**

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Rec]** = recommendation, change freely; **[Ref]** = what the reference scene does today (`src/test_rooms/art_style_test_room.gd`, `room_atmosphere.gd`), kept as the starting design. `game-designer`, `art-director`, `technical-artist` and `systems-designer` not consulted: Lean mode. Review manually before production. Every number below is a starting value read from the reference scene; the data lives in the biome preset (rule 3), never in code.

**The layer stack**

1. **Bands.** A room draws in this order, back to front. Draw order is relative to the play layer at 0, which the terrain pipeline owns (terrain rule 5, Visual/Audio: draw order); this system owns every other band. **[Ref; Owner, 2026-11-20: the reference scene is the aim]**

   | Order | Band | Moves with the camera (x, y) | Notes |
   |---|---|---|---|
   | −30 | Far layer (distant city, sky) | 0.15, 0.15 | Opaque; blurred `far_blur` (7 screen px) |
   | −22 | Deep fog | 0.2 | Between far and mid |
   | −20 | Mid layer (ruins, kilns) | 0.5, 0.5 | Alpha; blurred `mid_blur` (3.2 screen px); repeats mirrored |
   | −14 | Far fog | 0.4 | Between mid and the close band |
   | −13 | Dust | in the world | Drifting motes behind the play layer |
   | −10 | Near wall (corridor sections only, rule 8) | 0.85, 0.85 | Replaces the far and mid layers inside the section |
   | −9 | Close band: rocks, then plants in front | 0.85 / 0.92 sideways; 1 up and down (with the world) | Fixed to each floor run (rule 6); tinted `close_band_tint` and blurred `close_blur` (1.2 screen px) |
   | −6 | Near-back fog | 0.8 | Thin, so the close band sits back without hiding |
   | 0 | **Play layer** (terrain pipeline) and **the Seeker** | 1.0 | Collision, black fill, dressing and any trim not drawn as the lip (the lip is the terrain's trim at 4-6, below); the Seeker draws at 0 in front of them (tree order: the player controller's and the terrain pipeline's, Open Question 1). Nothing this system adds is at 0 |
   | −1 | **Seeker backlight** | follows the Seeker | Rule 12; additive, a child of the Seeker one z step below his sprite: behind the play layer and the Seeker, in front of the near-back fog (−6). Part of the Seeker's tree, not a room band |
   | 1 | Prop glows | 1.0 | Rule 11; additive, in front of the Seeker and behind the lip |
   | 4-6 | **The cobbled lip** (terrain pipeline) | 1.0 | The reference scene's middle rim: its tiles at 5 (`MIDDLE_Z`), its corner and patch pieces at 4 and 6. Drawn in front of the Seeker and of the glows **[Owner, 2026-11-20: the lip is the terrain pipeline's]** |
   | 7 | Ground fog | 1.15 | Thin (alpha capped, rule 9, P5), in front of the lip |
   | 8 | Embers | in the world | Rising sparks, in front of the lip and the Seeker, smaller than any projectile (rule 13) |
   | 10+ | Foreground strips (top and bottom) and room-end pieces | Strips 1.2, 1.1; room-end pieces 1.0 (fixed in the world) | Rule 5; a strip's art reaches at most `foreground_reach_max` (0.41 of the screen's height) in from its edge, and a room-end piece at most `room_end_inset_max` (38 px) into the room (rule 13). The reference draws its left border at 5 and its right at 12 |
   | 20 | Silhouette band | 1.2 sideways; screen-bottom vertically | Rule 7 |
   | screen | Grade | — | Rule 12; drawn over every band, under the HUD |

   **Blur.** The three blur passes (`far_blur` 7, `mid_blur` 3.2, `close_blur` 1.2, in screen px) each blur everything drawn behind them, fog banks included, so they compound: the far layer is blurred by all three, the mid layer by two, the close band by one. The combined radius is at most the sum (11.4 px for the far layer); the look is judged by eye. **[Ref; Owner, 2026-11-21: the background darker and blurrier]**
2. **Motion.** Each band's screen position follows the camera by its factor on each axis: a factor below 1 moves slower than the play layer (further away), above 1 faster (nearer), 1 with the world (Formulas P1). Bands are placed every rendered frame from the camera's final position for that frame, after the camera has moved and before anything is drawn, so no band lags the play layer by a frame. **[Ref]** Whether this uses the engine's `Parallax2D` or manual placement is an ADR; the reference places manually because `Parallax2D` misplaced layers under the 4x camera zoom (terrain Open Question 9).
3. **Biome preset and room overrides.** Each biome has one **atmosphere preset**: the art of every band, the factors and draw orders above, the blur radii, each fog bank's colour, density, noise scale, drift and screen-height ramp, the dust and ember settings, the glow colour and flicker, the grade values and the silhouette band on or off. A room uses its biome's preset (terrain rule 14: one biome per room) and may override only: each fog bank's density (a scale: 0-2 for the banks behind the play layer, 0-1 for the ground fog, Formulas P5), the glow spots (rule 11), its sections (rule 8), the room-end pieces (rule 5), and the close band and silhouette band off. Any other change is a new preset. The reference scene's values are Cinderheart Caldera's preset, which also holds `back_tint`, the tint of the far and mid layers (0.74, 0.66, 0.66), and the close band's tint `close_band_tint` (0.72, 0.68, 0.70), both multiplied. **[Owner, 2026-11-20: biome preset plus room overrides]**
4. **Never an edge in view.** No band ever shows its own edge, a seam or empty space inside the view, anywhere the camera can go in the room (Formulas P2). An opaque far layer is scaled to cover the view across the camera's whole travel; a mid layer repeats side by side, every other copy mirrored so a non-looping painting's seams meet; strips made to loop repeat plainly. A painting is never wrapped as a texture (`assets/environment/PACK-README.md`: "do not simply enable texture wrapping"). **[Ref]**
5. **Foreground strips and room ends.** The top strip's canvas meets the screen's top when the camera is at the room's top, and the bottom strip's meets the screen's bottom when the camera is at the room's floor (Formulas P3); between those heights they move at the foreground factor. A strip is drawn in front of the Seeker, so its art reaches at most `foreground_reach_max` (0.41 of the screen's height, data file, range 0.2-0.45) in from the screen's top (the top strip) or bottom (the bottom strip): the distance from that edge to the farthest row of the canvas holding any pixel at alpha 0.5 or more, over the canvas height (a canvas is one screen tall). The six shipped biome packs reach 0.403 at most (top strips 0.402-0.403, bottom strips 0.33-0.40; measured 2026-11-20 over all 36 files), about 109 px of the 270, which leaves about 53 px (0.2 of the screen height) of the middle clear when both strips show at full reach, as in a one-screen room; at the cap itself 49 px stay clear. The preset check rejects strip art that reaches further (Edge Cases). Art fainter than alpha 0.5 may reach further in. A room may place a room-end piece at a left or right bound that has no exit, fixed in the world and scaled to the room's height (to one screen, top-aligned, in a section less than a screen tall). It is drawn in front of the Seeker, so it is slid outward past its bound until its **opaque reach** (from the bound to the innermost column of the scaled art holding any pixel at alpha 0.5 or more) is at most `room_end_inset_max` (38 px, data file; range 0-60): `slide = max(0, opaque_width - room_end_inset_max)`, where `opaque_width` is measured from the art's outer edge. Art fainter than alpha 0.5 may reach further in. The reference's left border is a solid column 100 px wide slid 62 px past the room's left edge, which leaves 38 px inside, "to frame the wall without covering the spawn point" (`art_style_test_room.gd`, `BORDERS`). Its scale grows with the room's height (the pack's 512 x 1080 canvas is about 170 px wide in a 360 px room and 512 px in a room four screens tall), so the cap, not the art, bounds what it covers. **[Ref; Owner, 2026-11-20: inset cap, seventh design review]**
6. **The close band.** Every straight run of floor gets its own stretch of close pieces, provided the stretch is at least `close_min_run` (108 px: three of the reference scene's 36 px art cells, 18 collision tiles of 6 px, registry `collision_tile`) wide **after the pull-in and the extension below** (the reference tests `x1 - x0` once both are applied): a whole number of pieces (at least one) stretched slightly to fit, sunk `close_sink` (12 px) below the floor line. **At a drop** (open air beside the floor) the end is pulled in `close_edge_inset` (54 px) and faded over `close_end_fade` (40 px). **At a wall** the end is not pulled in and is not faded: the stretch runs on `close_wall_extend` (72 px, a cell for the drift and a cell of cover) behind the wall at full height, so it meets the wall instead of tapering. So a stretch is the run's width, less 54 px at each drop and plus 72 px at each wall, and needs at least 108 px: any run between two walls gets one, a run with a drop at one end and a wall at the other needs 90 px, and a run with a drop at both ends needs 216 px; a narrower run gets none. **[Owner, 2026-11-21: rocks run into a wall and fade only at a ledge]** Sideways the stretch moves at its factor around its own centre, kept within `close_drop_drift` (18 px) of its resting place toward a drop and `close_wall_drift` (36 px, one art cell) toward a wall (Formulas P7); up and down it stays on its floor. `close_sink` is not scaled down with small pieces: the art's flat bottom must always sit under the lip. Where the headroom over a run is low, the pieces scale down to fill at most `close_headroom` (0.55) of it. Plants are laid out the same way in front of the rocks. The terrain pipeline supplies the floor runs and their headroom from the collision (Interactions). **[Ref]**
7. **The silhouette band.** A band of black foliage pieces, shared by every biome, along the bottom of the screen. Sideways it moves at the foreground factor. Up and down it sits on the screen's bottom edge; when the camera moves vertically it first drifts the way near foliage would (`silhouette_sway` times the camera's move, at most `silhouette_max_drift`, 40 px), then eases back with time constant `silhouette_lag` (0.45 s). The lag behind the camera is held to `silhouette_max_drift / silhouette_sway` (33.3 px), so a drift at its cap starts easing back the moment the camera stops: 40 px to under 2 px in about 1.35 s (P6). A black base under it covers any gap. At rest its top is never higher than `silhouette_top` (0.53 of the screen height, the pack's reference placement), so it frames the bottom and a Seeker standing in the middle of the screen is clear of it. In motion the drift can lift the top by up to `silhouette_max_drift` (40 px), to about 0.38 of the screen height, so during a sustained fall black foliage passes in front of the play layer and the Seeker's level before it settles back (P6); this is the one case where a band shows over the play space, as near plants and pillars do in Hollow Knight. **[Ref; Owner, 2026-11-20: foreground may sometimes come into view over the scene; Rec: the rest-height cap; Rec: the lag bound, fifth design review]**
8. **Sections.** A room may hold **sections** (backdrop sections: this system's term, not level design's room sections or the save sections), rectangles of whole tiles that each use their own back set: their own far and mid art, or a near wall at −10 in place of both (the reference corridor), and their own fog densities. A long room may change its background from section to section, as Hollow Knight does within one region, rather than stretching one painting across the whole room. **[Ref; Owner, 2026-11-20: any scale is accepted, and long rooms use different backgrounds in different sections]** The geometry, which P1 and P2 read:
   - **Strips along one axis [Owner, 2026-11-20: keep sections simple; backgrounds carry little detail, so larger blurred art or several backgrounds blended into one piece do the rest].** A room's sections are all side by side (each spanning the room's full height) or all stacked (each spanning its full width), never both. Their shared edges are parallel, so the blend is one-dimensional and at most two sets ever mix. Sections need not cover the room: where none does, the room's own set shows and is the neighbour of the sections it touches.
   - **Spacing.** Two distinct section edges are at least `layer_blend` (72 px) apart, so no camera position is inside two blend zones. Sections that touch share one edge and one blend, by design: that is not an overlap. A section narrower than `layer_blend` is rejected by the room check.
   - **A set fills the whole view.** It is not masked to its section's rectangle: which set shows is decided by where the camera's centre is, so the view may show a neighbouring section's area in this section's art.
   - **The blend is centred on the shared edge.** Over `layer_blend` (72 px) of camera-centre travel, from `layer_blend / 2` before the edge to `layer_blend / 2` after it, the incoming set's weight rises from 0 to 1 (0.5 at the edge) and the outgoing set's falls from 1 to 0. It follows the camera's position, never time, never a cut. The weight is linear in the camera's travel (0.25 at a quarter of the blend before the edge, 0.75 at a quarter after), as the reference's mask interpolates across two quads. A section's fog density scale blends with the same weight, linearly. **[Ref: the reference corridor's mask is centred on its mouth; Rec: linear, fog scale blended]**
   - **A set's travel range**, per axis, is every camera-centre position at which its weight is above 0: the section's rectangle widened by `layer_blend / 2` on each side, cut to the camera's centre bounds (the room's bounds inset half a screen, rooms and transitions R4). A set with no neighbour has the room's whole range. The room's own set, where sections do not cover the room, is shown wherever no section is: its range is the hull (first to last position with weight above 0) of the uncovered area widened by `layer_blend / 2`, cut the same way, so a section in the middle of a room leaves it one range covering both sides. A range that comes out empty is rejected by the room check. **A** (P1) is the midpoint of that range and **T** (P2) its length, so the camera's centre is never more than `T / 2` from `A` while the set shows.

**Atmosphere**

9. **Fog banks.** Each fog bank is a soft, noise-shaped haze in one colour that drifts slowly and moves at its own factor. Its density ramps with screen height between two values (from nothing to full, top to bottom) so it gathers low. The ground fog in front of the play layer stays thin: its alpha (`a x density x room_scale x setting_scale`, P5) never exceeds `ground_fog_alpha_max` (0.3, the reference's value, a constant of this system and not a field of the biome preset, so no preset can raise its own cap), so it cannot hide a floor edge (rule 13). The preset check rejects a ground fog whose `a x density` is above that cap, and the room's scale for it is capped at 1 (rule 3). **[Ref; Rec: the cap, after the first design review]**
10. **Particles.** Dust (behind the play layer) and embers (in front of it) are spawned over the view (an ember's size is its core diameter, at most `ember_size_max` 2.8 px; its soft sprite is drawn twice that wide, 5.6 px), drift or rise at the preset's speeds and live for the preset's lifetime. They are already at their steady density on a room's first shown frame (rule 15), never fade in from empty. They have no collision and no effect on play. **[Ref; Rec: pre-warmed]**
11. **Glows.** A prop the prop catalogue marks as carrying light (terrain Open Question 6, the catalogue format) gets a soft warm glow of its listed radius, additive, flickering by the preset's flicker. A room may add glow spots (a point and a radius) for light painted into its art. Glows light nothing and cast no shadow: there are no engine light nodes. Light in this game is painted into the art, added by glows and shaped by the grade. **[Ref; Rec: no light nodes]**

**The grade and the Seeker**

12. **The grade.** Over every band, under the HUD and every menu, one screen pass applies, in order: contrast, split tone (shadows cooler, highlights warmer) and saturation, the ambient gradient (multiplied: the top a little cooler and darker, the bottom warmer, light coming from below as in the region 1 lore), a soft light around the Seeker (its body brightened by `player_light_lift`, 0.03, the rest of the screen dimmed by `player_light_dim`, 0.16), and a vignette towards the screen's corners. The light centres on the Seeker's body, `player_centre` (13 px) above its feet. **[Ref]**
    **The Seeker's backlight** is not part of the screen pass: it is drawn in the world behind his sprite (rule 1's −1 row), so his painted pixels are never lightened or blurred by it. It is two additive sprites that follow him: a blurred, warm copy of his current frame (its texture, offset, facing, scale and rotation, blurred `backlight_blur` (3.5 world px) at `backlight_strength` (0.4), so it hugs his silhouette and rims his edges) and a soft round radiance of radius `backlight_radius` (34 world px, so 68 px across) at `backlight_radiance` (0.14), both tinted `backlight_tint` (1.0, 0.78, 0.62). A screen bloom and a screen radiance drawn over him were tried first and dropped: over his sprite they washed out the painted art. **[Ref; Owner, 2026-11-21: the glow comes from behind him]**
13. **Readability first.** The look must never mislead or hide play (level design, Readability; terrain rule 5):
    - Nothing this system draws has collision, and nothing is shaped like a floor, a ledge, a wall to cling to or a gate.
    - Every band behind the play layer, after fog and grade, is darker than the play layer's lit edges and than the Seeker (Formulas P4).
    - Only these are drawn in front of the Seeker, each with its limit, and nothing else is: the prop glows (order 1; additive, and behind the lip, so a glow can never cover a floor edge); the cobbled lip (terrain's, at the floor edges); the ground fog (order 7; alpha at most `ground_fog_alpha_max`, 0.3, rule 9 and P5, so the lip stays readable through it); embers (order 8; no larger than `ember_size_max`, 2.8 px); the foreground strips (order 10+; art reaches at most `foreground_reach_max`, 0.41 of the screen's height, in from the screen's top or bottom edge, so they frame the screen and leave its middle clear, rule 5); the room-end pieces (order 10+; only at a bound with no exit, opaque reach into the room at most `room_end_inset_max`, 38 px, rule 5); and the silhouette band, which rests at the bottom and rises over the play space only while the camera moves fast and for about 1.35 s after it stops, easing back from its cap (rule 7, P6; owner-accepted, checked in the playtest).
    - No ambient element reproduces a gate's or the `no_cling` face's signature (ability gating rules 10, 14).
    - Embers only rise and dust only drifts with the preset's wind; neither follows anything, and both stay smaller than any projectile (Edge Cases).
    **[Rec; ability gating, level design and terrain constraints]**
14. **Atmosphere setting: Full or Reduced.** A player option, Full by default. Reduced turns off the three background blur passes (the backlight's own 3.5 px softening stays), the dust and embers, and the silhouette sway (the band sits still on the bottom), and scales every fog bank's density by `reduced_fog_scale` (0.5). Parallax, the glows, the light around the Seeker, his backlight, the ambient gradient, contrast, split tone and vignette stay, so Reduced keeps the room's depth and its brightness order. A change applies on the next frame, with no reload. The reference scene's V key stays a debug-only switch for the whole pass. **[Owner, 2026-11-20: Full / Reduced player option; Rec: what Reduced drops; Owner, 2026-11-22: Reduced keeps the backlight, the Seeker's readability aid and one small sprite]**

**Rooms and time**

15. **Built with the room.** A room's bands are built with the room, while the screen is dark (rooms and transitions rules 9, 12), placed from the camera's snapped arrival position, with particles at steady density and the silhouette band at rest, so the first frame of the fade-in shows the finished look. Nothing of the previous room's bands stays. The band build, the particle pre-warm and the first use of each shader count toward the room's `build_time` (rooms and transitions R3, budget 0.10 s). The long room's whole build, terrain art included, measured 1.4 s warm and 1.6 s cold in the container's software renderer (art-room bench, 2026-11-22); this system's share is not yet measured, and the build may have to be split or deferred (Open Question 3). **[Rec]**
16. **World time.** Fog drift, particles, glow flicker and the silhouette sway run on the world's clock: they stop whenever the world is frozen (a transition's freeze, the pause menu, the grid map) and resume where they were. The reference drifts its fog on the engine's `TIME`, which pausing does not stop, so the build feeds the fog a world-clock uniform instead; a hit-pause that stops the world clock holds them too. **[Rec]**
17. **Camera shake.** Shake moves the whole picture by the same screen offset; bands are placed from the camera's follow position without the shake, so a far layer shakes as much as the play layer instead of hardly at all. **[Rec]** Zoom stays fixed in play (terrain Open Question 9 owns the zoom).

### States and Transitions

The look of a room, as this system sees it:

| State | Meaning | Enter when | Leave when |
|---|---|---|---|
| Unbuilt | No bands for this room | The room is unloaded or freed | Rooms and transitions builds the room: to Built |
| Built | Bands built and placed for the arrival camera, particles at steady density, not yet shown | The room is built while the screen is dark (rule 15) | The fade-in starts: to Showing |
| Showing | Bands placed every frame; drift, particles, flicker and sway advancing | From Built; from Frozen when the world resumes | The world freezes: to Frozen. The room is freed: to Unbuilt |
| Frozen | Bands still drawn and placed, nothing advancing (rule 16) | A transition's freeze, pause or the map opens | The world resumes: to Showing. The room is freed during a transition's swap: to Unbuilt |

The atmosphere setting (rule 14) is not a state of the room: it changes which parts draw in any state, on the next frame.

### Interactions with Other Systems

Rooms and transitions is Approved; Terrain pipeline is Approved (eighth review, 2026-11-22) but does not yet hold the lip or the floor-run fields (Open Question 1); Camera has no GDD (code only). Every interface with them is **provisional** until their owners adopt it.

| System | Direction | Data flowing | Owner of the interface |
|---|---|---|---|
| Terrain pipeline | In | The play layer at draw order 0 with its trim, and the cobbled lip at 4-6 in front of the Seeker (owner, 2026-11-20); the floor runs and their headroom from the collision (rule 6); props marked as carrying light, with a glow radius (rule 11, prop catalogue); rule 5 (nothing imitates the play layer) | Terrain owns the play layer, the lip (at 4-6, in front of the Seeker) and the catalogue; this system owns every other band |
| Rooms and transitions | In | The current room's biome and bounds (its Interactions); when a room is built and freed; the transition's freeze and fade (its rules 9, 12); the room's sections and glow spots in the room data | Rooms owns the room data and the sequence; this system owns the bands built from it |
| Camera | In | The camera's follow position each frame, after it moves (rule 2); its arrival snap (rule 15); the shake offset (rule 17); the zoom | Camera owns follow, shake and zoom; this system owns placement from them |
| Level design | In | Section rectangles, glow spots, fog density scales and room-end pieces per room (rule 3); the Readability rule shared (rule 13) | Level design places them; this system defines what they do |
| Player controller | In | The Seeker's position and current animation frame (texture, offset, facing, scale; the reference reads `body_sprite()`), for the light and the backlight (rule 12) | Player controller |
| Pause and menus | Both | Out: the atmosphere setting, Full or Reduced (rule 14). In: pause freezes the world (rule 16); menus draw above the grade | Pause and menus owns the options screen; this system owns what each value does |
| Grid map | In | The map freezes the world (rule 16); the map screen is drawn above the grade, ungraded | Grid map |
| Combat (hit effects) | In | Sparks and glow on hits are combat's, on the play layer; nothing blooms them | Combat |
| Ability gating | In | Gate and `no_cling` signatures that no ambient element may reproduce (rule 13) | Ability gating |
| Art bible | In | The look of each biome's preset: palettes, fog colours, grade (Draft, `design/art/art-bible.md`: sections 1-4 written 2026-11-20, 5-9 not yet) | Art director |

## Formulas

`systems-designer` lens applied in this session (lean mode spawns no agent): every variable was put at its minimum, its maximum and 0. One input is unbounded by design (P2 grows with the room, owner: accepted) and one override could hide the floor (P5, bounded below). No feedback loop: nothing this system draws feeds back into play. Lengths are world px (a screen is 480 x 270), per axis unless stated. Every `data file` value lives in the biome's atmosphere preset (rule 3) **[Rec]**; the starting values are the reference scene's (Cinderheart Caldera).

### P1. Band placement

The band_position formula is defined as:

`band_position = c * (1 - f) + A * f - S / 2`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | float (world px) | inside the camera's travel | calculated (Camera) | The camera's follow centre this frame, without shake (rule 17) |
| f | float | 0-2 | data file | The band's factor on this axis (rule 1): 0 fixed to the screen, 1 fixed to the world, above 1 nearer than the play layer |
| A | float (world px) | inside the room | calculated | The midpoint of the camera-centre travel range of the band's set: for any set, the midpoint of its travel range (rule 8): for a room with no sections the room's centre, and for a section's set not always the section's centre |
| S | float (world px) | > 0 | calculated (P2) | The band's drawn size on this axis |
| band_position | float (world px) | any | calculated | The band's top-left on this axis |

**Output Range:** when the camera is centred on A the band is centred there too; each world px the camera moves moves the band `f` px on screen the other way (`1 - f` in the world). At f = 0 the band never moves on screen; at f = 1 it never moves in the world. A negative f would move a band the wrong way and is rejected by the preset check; above 2 a band crosses the screen faster than the eye can follow (no use found). Placement is per axis, so a band may use different x and y factors (the foreground strips: 1.2 and 1.1).
**Example:** the far layer (f 0.15) in the reference room (2520 x 360, so A = 1260 on x) with S = 792 (P2): with the camera at the room's left (c = 240), band_position = 240 x 0.85 + 1260 x 0.15 - 396 = −3, so its left edge sits 3 px past the screen's left edge, the shake margin and the tightest point P2 allows.

### P2. Cover

The band_cover formula is defined as:

`cover = V + f * T + 2 * m`  ·  `scale = max(cover_x / W, cover_y / H)` (a band that does not repeat)  ·  `scale = cover_y / H` and `copies = ceil(cover_x / (W * scale)) + 1` (a band that repeats sideways)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| V | float (world px) | 480 (x), 270 (y) | constant | The view: one screen |
| f | float | 0-2 | data file | The band's factor on this axis (P1) |
| T | float (world px) | 0 or more | calculated | The length of the band's set's camera-centre travel range on this axis: for any set, the length of its travel range (rule 8): for a room with no sections the room's size minus one screen (camera zones are ignored, Edge Cases). It is measured between camera centres, so the view's half screens are already in V and are not added again |
| m | float (world px) | 0 or more; 3 today | calculated (attack data) | The largest camera shake any attack requests (`shake_size`, `attack_data.tres`: the heavy, 3 px). Shake moves the picture past the camera's limits (rule 17, `player_camera.gd`), so each side needs this margin |
| W, H | float (world px) | > 0 | calculated (art) | The band's art at its native scale: a 1920 x 1080 pack canvas is 480 x 270 |
| cover | float (world px) | V + 2m to V + 2T + 2m | calculated | The size the band must cover so no edge shows anywhere the camera can go (rule 4) |
| scale | float | 1 or more in practice | calculated | How much the art is enlarged |
| copies | int | 2 or more | calculated | Side-by-side copies of a repeating band (mirrored every other one, rule 4) |

**Output Range:** in a one-screen room or section (T = 0) every band covers the view plus the shake margin, at scale just over 1. `cover` grows with the camera's travel, and so does `scale` for a band that does not repeat. Nothing divides by a value that can be 0 (W and H are art sizes). There is no upper bound: **any scale is accepted (owner, 2026-11-20)**, and a room that would stretch a painting too far uses sections with their own art instead (rule 8).
**Example:** the reference room (2520 x 360; T = 2040 x 90): far layer (f 0.15, no repeat, m = 3): cover = 792 x 289.5, scale = max(1.65, 1.07) = **1.65**. A room 20 screens wide (T = 9120): cover_x = 1854, scale **3.86**. Mid layer (f 0.5, repeats sideways) in a room 4 screens tall (T_y = 810): cover_y = 681, scale **2.52**.
**Example (sections):** a room 5 screens x 1 (2400 x 270) with two sections, x 0-1200 and 1200-2400 (`layer_blend` 72). The camera's centre runs 240-2160. The first section's travel range is [-36, 1236] cut to [240, 1236]: A = 738, T = 996; the second's is [1164, 2436] cut to [1164, 2160]: A = 1662, T = 996. Far layer (f 0.15): cover_x = 480 + 0.15 x 996 + 6 = 635.4, scale **1.324** (635.4 / 480). Check at the section's far end (c = 1236): the band's centre is 1236 x 0.85 + 738 x 0.15 = 1161.3 and its right edge 1161.3 + 317.7 = 1479.0, exactly the view's right edge plus the shake margin (1236 + 240 + 3). Taking A as the section's centre (600) would leave about 21 px of the view uncovered there (its right edge at 1458.3).

### P3. Foreground strip height

The strip_top formula is defined as:

`strip_top = f_y * (c_ref - c_y)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| f_y | float | 1.0-1.5, starts at 1.1 | data file | The foreground strips' vertical factor (rule 1) |
| c_y | float (world px) | the camera's vertical travel | calculated (Camera) | The camera's follow centre on y |
| c_ref | float (world px) | the top or bottom of that travel | calculated | The camera's highest centre for the top strip, its lowest for the bottom strip (rule 5) |
| strip_top | float (screen px, world scale) | −f_y x T_y to f_y x T_y | calculated | Where the strip's screen-tall canvas starts, from the screen's top |

**Output Range:** the top strip sits at 0 (art at the screen's top) with the camera at its highest and rises off screen as the camera goes down; the bottom strip sits at 0 (its canvas fills the screen, art at the bottom) with the camera at its lowest and sinks off as the camera rises. In a room one screen tall (T_y = 0) both always sit at 0, so both show. How far the art reaches from the screen's edge is bounded separately by `foreground_reach_max` (rule 5, 0.41 of the screen's height, about 111 px of the 270): this formula only places the canvas.
**Example:** a room two screens tall (T_y = 270), camera at its highest: top strip at 0; bottom strip at 1.1 x 270 = 297, below the screen's 270, so unseen.

### P4. Value order (readability check)

The value_margin formula is defined as:

`value_margin = min(L_edge95, L_seeker50) - L_back95`  ·  passes when `value_margin >= value_margin_min`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | float | 0-1 | calculated | Luma of a pixel of the final, graded frame: 0.299 R + 0.587 G + 0.114 B, each 0-1 |
| L_back95 | float | 0-1 | calculated | 95th percentile of L over the pixels where only bands behind the play layer show (no terrain, prop, glow, Seeker or effect) |
| L_edge95 | float | 0-1 | calculated | 95th percentile of L over the play layer's floor-top pixels (the lip, terrain's) |
| L_seeker50 | float | 0-1 | calculated | Median L over the Seeker's pixels |
| value_margin_min | float | 0.05-0.20, starts at 0.10 | data file | The smallest gap allowed **[Owner, 2026-11-20: 0.10, and judged by eye]** |

**Output Range:** −1 to 1; negative means the background is brighter than where the player stands. The check is a **warning**, not a gate: it flags a frame for review, and the verdict on a look is the screenshot judged by eye (rule 13; Acceptance Criteria). Percentiles, not maxima, so a single ember or glow pixel cannot fail a frame.
**Example (measured 2026-11-20 on the earlier reference scene, before the darker, blurrier background and the backlight; stale, re-measure on the current one):** start frame: back 0.34, floor edge 0.55, Seeker 0.53, margin **0.19**; island over the pit: back 0.34, edge 0.49, Seeker 0.61, margin **0.15**; corridor: back 0.38, edge 0.70, margin **0.32**. All pass at 0.10.

### P5. Fog density

The fog_alpha formula is defined as:

`fog_alpha = a * density * room_scale * setting_scale * smoothstep(0.25, 0.72, noise) * smoothstep(y0, y1, y_screen)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| a | float | 0-1 | data file | The bank's colour alpha: deep 0.55, far 0.58, near-back 0.22, ground 0.3 |
| density | float | 0-1, starts at 1 | data file | The bank's density in the preset |
| ground_fog_alpha_max | float | 0.1-0.4, starts at 0.3 | system constant (not the biome preset) | The most `a x density` the ground fog's preset may carry (rules 9, 13); the preset check rejects a higher value. The ground fog is the only bank drawn in front of the lip, so it is the only one capped **[Rec, first design review]** |
| room_scale | float | 0-2 for banks behind the play layer; 0-1 for the ground fog | data file (room override, rule 3) | A room's density scale |
| setting_scale | float | 1 (Full) or `reduced_fog_scale` (0.5, Reduced) | data file | Rule 14 |
| noise | float | 0-1 | calculated | Two layers of drifting noise (scale and drift per bank) |
| y0, y1 | float | 0-1 of the screen height, y0 < y1 | data file | Where the bank starts and where it is full: deep 0-0.85, far 0.15-0.9, near-back 0.35-0.95, ground 0.55-1.0 |

**Output Range:** 0 to a x room_scale; at most 1 (clamped). Boundaries found: a ground fog override of 2 would give 0.6 over the floor, enough to hide a floor edge (rule 13), so the ground fog's room scale is capped at 1 (the preset's own value); and the preset's own `a x density` was free up to 1, so it is capped at `ground_fog_alpha_max`. Together the ground fog's alpha never exceeds 0.3 at the starting values, in Full or Reduced. The banks behind the play layer may go to 2, where the deep and far banks reach 1.0 (clamped) and simply hide more background, which is allowed. At y0 = y1 the smoothstep is a hard line, which the preset check rejects.
**Example:** the ground fog at the screen's bottom (y = 1), Full setting, room scale 1, noise at its peak: 0.3 x 1 x 1 x 1 x 1 x 1 = 0.3; in Reduced, 0.15.

### P6. Silhouette drift

The silhouette_drift formula is defined as:

`lag_y += (c_y - lag_y) * (1 - exp(-dt / tau))`  ·  `lag_y = clamp(lag_y, c_y - max_drift / sway, c_y + max_drift / sway)`  ·  `drift = (lag_y - c_y) * sway` (at sway 0 the bound is not used and the drift is 0)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c_y | float (world px) | the camera's vertical travel | calculated (Camera) | The camera's follow centre on y this frame |
| lag_y | float (world px) | within `max_drift / sway` of c_y (33.3 px at the starting values) | calculated | A lagging copy of c_y, bounded as above; set to c_y when a room is built (rule 15) |
| dt | float (s) | 0 or more | calculated | World time this frame; 0 while the world is frozen (rule 16) |
| tau | float (s) | 0.1-1.0, starts at 0.45 | data file (`silhouette_lag`) | How long the band takes to settle (63% of the way per `tau`) |
| sway | float | 0-2, starts at 1.2 | data file (`silhouette_sway`) | How far it drifts per px of camera move |
| max_drift | float (world px) | 0-60, starts at 40 | data file (`silhouette_max_drift`) | The cap, kept by bounding `lag_y`; a black base under the band covers the gap |

**Update order:** each frame `lag_y` is advanced first, then the drift is read from the advanced `lag_y` (as the reference does, `art_style_test_room.gd`). So a one-frame camera move of D px gives a first-frame drift of `D x sway x exp(-dt / tau)`: the settle curve is the same at any frame rate, but the first frame's size depends slightly on `dt` (D = 30: 34.7 px at 60 fps, 35.4 at 144, 33.4 at 30). Then `lag_y` is bounded. **The reference did not bound it** until 2026-11-22 (it clamped only the drift, `art_style_test_room.gd`, and now clamps `lag_y` too): in a 1 s fall at 640 px/s its lag winds up to about 256 px, so the drift stays at its cap for about 0.9 s after the fall and takes about 2.3 s to get under 2 px (simulated at 30, 60 and 144 fps, fifth design review). The bound was a deliberate change from the reference, made in it on 2026-11-22 **[Owner, 2026-11-20: bound the lag]**; it changes nothing for a move of up to about 34 px in one frame.
**Output Range:** −40 to 40 px at the starting values; −40 (up) in any sustained fall, which puts the band's top at 143 − 40 = 103 px, about 0.38 of the screen height (rule 7). After the fall stops the drift eases back from its cap: 20 px after 0.31 s, 14.7 px after 0.45 s, about 2 px after 1.35 s, under 1.5 px after 1.5 s. At dt = 0 nothing moves; tau must be above 0 (at 0 the band would snap and never drift, so the preset check rejects it); at sway 0 or in the Reduced setting the band sits still on the bottom.
**Example:** the camera rises 30 px in one frame of 1/60 s: drift = 30 x 1.2 x exp(-0.0167 / 0.45) = 34.7 px down; 0.45 s of world time later about 37% remains (12.8 px), after 1.35 s under 2 px. A fall at 640 px/s winds the lag up to its 33.3 px bound in about 0.07 s (at 60 fps the first four frames read −12.3, −24.2, −35.7 and −40 px; the cap is reached at 0.067 s at 30 and 60 fps and 0.062 s at 144) and holds it there for the rest of the fall, so the drift sits at −40 from then on; 0.45 s after the fall stops it is 14.7 px, and after 1.35 s about 2 px (without the bound the lag would wind up to about 256 px and the cap would hold for about 0.9 s after the fall).

### P7. Close band placement

The close_placement formula is defined as:

`shift = clamp((c - ref) * (1 - f), -drift_left, drift_right)`  ·  the stretch spans `x0 + shift` to `x1 + shift`  ·  `ref = clamp((x0 + x1) / 2, c_min, c_max)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | float (world px) | inside the camera's travel | calculated (Camera) | The camera's follow centre on x this frame, without shake (P1) |
| f | float | 0-1 | data file | The stretch's sideways factor: rocks 0.85, plants 0.92 (rule 1) |
| x0, x1 | float (world px) | inside the floor run, except a wall end, which lies `close_wall_extend` (72 px) behind the wall; `x1 - x0` at least `close_min_run` (108) | calculated (terrain pipeline) | The stretch's ends at rest: the run's ends, with an end at a drop pulled in `close_edge_inset` (54 px); an end at a wall is pushed out `close_wall_extend` (72 px) behind the wall, at full height. A run whose `x1 - x0` comes out under 108 gets no stretch (rule 6), so P7 never sees a zero or negative width |
| c_min, c_max | float (world px) | inside the room | calculated (rooms and transitions R4) | The camera centre's bounds: the room's bounds inset half a screen |
| ref | float (world px) | c_min to c_max | calculated | The camera centre at which the stretch sits at rest: the run's centre, held inside the camera's travel so a run near a room edge still rests |
| drift_left, drift_right | float (world px) | 0-60 | data file | The most the stretch may move toward each end: `close_drop_drift` (18) if that end is at a drop, `close_wall_drift` (36) if at a wall |
| shift | float (world px) | -drift_left to drift_right | calculated | How far the stretch is from its resting place |

**Output Range:** the stretch sits at rest (shift 0) when the camera is centred on `ref`, and drifts `1 - f` px per px of camera move, behind the play layer. Once the clamp binds it stops sliding and moves with the world (factor 1). At a drop the end is never nearer the edge than `close_edge_inset - close_drop_drift` = 36 px, one art cell, where the ledge's rounded corner would show the rock's flat bottom. At f = 1 the shift is 0. A wall end sits 72 px behind the wall at rest and, at the far end's drift limit (at most 36 px), still 36 px behind it, so it never leaves the wall; only a drop end is faded. Up and down the stretch is fixed to its floor line plus `close_sink`. The clamp binds at `drift / (1 - f)` from `ref`: 120 px at a drop and 240 px at a wall for rocks, 225 and 450 for plants.
**Example:** a rock stretch with its left end at a wall and its right end at a drop; at rest `x0` = 1000 (the wall is at 1072) and `x1` = 1500 (the edge is at 1554), so `ref` = 1250. Camera at c = 1400: (1400 - 1250) x 0.15 = 22.5, clamped to `drift_right` = 18, so the right end sits at 1518, 36 px from the edge. Camera at c = 1250: shift 0, the right end 54 px from the edge. Camera at c = 900: (900 - 1250) x 0.15 = -52.5, clamped to `-drift_left` = -36 (the wall end).

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

**Motion and cover**
- **If a room or section is one screen long on an axis** (T = 0): no band moves on that axis, and every band covers the view plus the shake margin (P2). **[Rec]**
- **If a camera zone narrows the camera's bounds** (a boss arena locked to one screen, rooms and transitions rule 14): cover is still worked out from the room's or section's full travel, so nothing changes when the zone engages or releases; the bands just move less while it holds. **[Rec]**
- **If a section is smaller than a screen, or the camera's view reaches into it from outside its rectangle**: a set always fills the whole view and is chosen by the camera's centre (rule 8), so a view that overlaps a section while the centre is outside it simply shows the neighbour's art there. A section's A and T come from its travel range (rule 8), so a section smaller than a screen has a short range, a scale just over 1, and never shows an edge while it is visible. **[Rec]**
- **If the camera stops or turns back inside a section's blend**: the blend follows the camera's position, not time, so it holds or reverses smoothly and never pops. **[Rec]**
- **If a room's sections are not strips along one axis, or two distinct section edges are closer than `layer_blend`** (72 px): the room check rejects the room and names the sections. Sections that touch share one edge and one blend, which is allowed. No camera position is then inside two blend zones, so at most two sets ever mix. **[Rec; Owner, 2026-11-20: strips only]**
- **If the camera shakes at a room's edge**: the shake may carry the view up to `m` (3 px today) past the camera's limits, and every band covers that margin (P2), so no edge or clear colour shows. A larger shake added to the attack data enlarges the margin by itself, because `m` is read from it. **[Rec]**
- **If the window is not 16:9**: the view stays 480 x 270 with bars, as the project's stretch settings keep it (`project.godot`: viewport stretch, aspect keep); no band draws into the bars. The display migration is terrain Open Question 9's. **[Rec]**
- **If the frame rate drops or varies**: placement is per rendered frame from the camera (rule 2), the silhouette drift settles at the same speed at any frame rate (P6), and drift, particles and flicker advance by world time (rule 16), so the look moves at the same speed at 30 and 144 fps. **[Rec]**

**Close band, room ends and silhouettes**
- **If a floor run's stretch, after the pull-in at each drop end and the extension at each wall end (rule 6), is narrower than `close_min_run` (108 px), or a room has no floor runs** (a vertical shaft): that run gets no close band; nothing replaces it. A run between two walls always has one (its stretch is 144 px wider than the run); a drop at one end and a wall at the other needs 90 px; a 108 px platform between two drops would leave a 0 px stretch, so it gets none (the stretch, never the run, is tested). **[Ref; fixed at the third design review; walls: Owner, 2026-11-21]**
- **If a wall is thinner than `close_wall_extend`** (a one-tile, 6 px wall with open air behind it): the extension would show beyond it. The reference has no such wall and this GDD has no rule yet; Open Question 9.
- **If the headroom over a floor run is so low that the close band would be shorter than `close_min_height`** (12 px at full scale): that run gets no close band, rather than a sliver. **[Rec]**
- **If a floor run ends at a wall**: no inset at that end, the stretch runs on `close_wall_extend` (72 px) behind the wall at full height with no fade, and it may drift `close_wall_drift` (36 px) toward the wall, which hides it. At a drop the end is pulled in `close_edge_inset` (54 px) and may drift at most `close_drop_drift` (18 px) toward it, so it stays at least one full art cell (36 px) from the edge, where the ledge's rounded corner would show the rock's flat bottom (P7). **[Ref]**
- **If the collision changes while the Seeker is in the room** (a breakable wall or pane breaks, a shortcut opens): the close band keeps the floor runs it was built from; the next build of the room uses the new collision. A break never moves scenery under the player. **[Rec]**
- **If a room-end piece is placed on a bound that holds an exit**: the room check rejects it and names it; a room-end piece goes only on a left or right bound with no exit, so it never hides an opening. **[Rec]**
- **If a room-end piece's opaque art is wider than `room_end_inset_max`** (38 px), at any room height: it is slid outward past its bound until its opaque reach is 38 px (rule 5); the slid-out part draws outside the room's bounds, where the camera's view can show it only as framing. The cap is measured from the bound, not from the end wall's face: where the solid wall at that bound is at least 38 px thick the piece covers only wall, and where it is thinner the piece also covers the open strip beside the wall, including a Seeker clinging there. Level design keeps a room-end piece on a bound whose wall is at least `room_end_inset_max` thick, or accepts that strip as covered (not yet a room-check item). **[Owner, 2026-11-20: inset cap]**
- **If a foreground strip's art reaches further from the screen's edge than `foreground_reach_max`** (0.41 of the screen's height, measured at alpha 0.5 or more, rule 5): the preset check rejects the biome's preset and names the file, so a stalactite or plant hanging lower than the cap never reaches play. A strip is in front of the Seeker, and with the camera clamped at a room's top the Seeker can stand or jump under the top strip's tips. Art fainter than alpha 0.5 is not measured. **[Owner, 2026-11-20: cap the strips' reach, eighth design review; Rec: 0.41 rather than 0.40, because the shipped top strips measure 0.403]**
- **If the camera falls or rises many screens fast**: the silhouette drift stays within `max_drift` (P6) and the black base under the band covers the gap; the band never leaves the screen's bottom. **[Ref]**

**Light, grade and readability**
- **If the Seeker is in a screen corner** (the camera clamped at a room's corner): the vignette darkens that corner by nearly half at the starting values (strength 0.5, about 0.48 at the very corner), and the light around the Seeker lifts it by 3%. Accepted; the value check (P4) runs on a corner frame in the criteria, and a failure there is a tuning note for `vignette`, not a rule change. **[Rec]**
- **If the Seeker is off screen** (a death fall below the room's camera limit): the light stays centred on its body, and the backlight, a child of the Seeker, stays on it, even off screen, so the screen dims as usual and nothing jumps when it reappears. **[Rec]**
- **If the Seeker is hidden by a transition's dark screen**: the grade still runs; nothing to see. On the first frame of the fade-in the light is already on the arrival point (rule 15). **[Rec]**
- **If an enemy projectile could be mistaken for an ember**: a requirement on Combat and Enemies, not checked here: a projectile is at least twice an ember's largest size (the 2.8 px core today, so 6 px or more; the soft sprite is 5.6 px wide, Open Question 8), and never ember-coloured without an outline or a trail. Embers only rise. **[Rec]**
- **If glows overlap**: they add up; overlapping glows are allowed, and the value check (P4) flags a frame they push too bright. **[Rec]**
- **If a glow's flicker or any ambient pulse could trouble photosensitive players**: no ambient element changes brightness more than `glow_flicker` amplitude 0.2 or faster than 3 cycles per second (the reference's rate of 2.3 is radians per second, about 0.37 cycles); the preset check rejects faster or stronger flicker. The heavy attack's strobing blade is Combat's, not this system's. **[Rec]**

**Settings, data and rooms**
- **If the atmosphere setting changes mid-room**: it applies on the next frame (rule 14). Turning dust and embers back on spawns them at steady density at once, as on a room build, never filling in over their lifetime. **[Rec]**
- **If the next room is in another biome** (a region border): its preset and art load with the biome (rooms and transitions R5, terrain rule 14); the two biomes' atmosphere art is part of the about 97 MB a biome costs, already measured with its parallax layers (level design Open Question 22). **[Rec]**
- **If a preset value is out of range or names missing art**: the preset check runs when a biome's preset loads; a failure (a ground fog `a x density` above `ground_fog_alpha_max` among them) stops the game before the title screen and names every bad value and file, so a broken look never reaches play (the same rule the owner chose for Save points' data). **[Rec]**
- **If a room overrides a field the preset does not allow** (rule 3): the room check rejects it and names the field; a new look is a new preset. **[Rec]**

## Dependencies

The systems index lists this system as depending on Terrain pipeline, Camera and Rooms and transitions. This GDD also reads Level design, the Player controller, Ability gating and Pause and menus, and places a requirement on Combat and Enemies.

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Terrain pipeline | Hard | The play layer at draw order 0 and rule 5 (nothing imitates it); the cobbled lip, which it owns and draws in front of the Seeker (owner, 2026-11-20); the floor runs and their headroom, read from the collision (rule 6); props marked as carrying light, with a glow radius, in the prop catalogue (rule 11; terrain Open Question 6). **Needs** (Open Question 1): to adopt the lip as its trim, and the floor-run and catalogue fields | Yes, Approved (eighth review, 2026-11-22; `design/gdd/terrain-pipeline.md`); interface provisional until it adopts the lip and the floor-run fields |
| Rooms and transitions | Hard | The current room's biome and bounds; the build while dark and the freeze (its rules 9, 12); the room data that holds this system's overrides (rule 3: fog scales, glow spots, sections, room-end pieces, bands off). **Needs** (Open Question 2): those fields in the room data, and two room-check items (sections not in strips along one axis, or two distinct section edges closer than `layer_blend`; a room-end piece on a bound with an exit) | Yes, Approved (`design/gdd/rooms-and-transitions.md`) |
| Camera | Hard | The follow centre each frame after it moves, without shake (rule 2); the shake offset and the largest shake (rule 17, P2); the snap on arrival (rule 15); a fixed zoom | No GDD (`src/player/player_camera.gd`); zoom and display are terrain Open Question 9's |
| Level design | Soft | Which rooms have sections, glow spots and room-end pieces; the Readability rule this system shares (rule 13) | Yes, Approved (`design/gdd/level-design.md`) |
| Player controller | Soft | The Seeker's position and current animation frame (texture, offset, facing, scale; the reference reads `body_sprite()`), for the light and the backlight (rule 12) | No (`src/player/player.gd`) |
| Ability gating | Soft | The gate and `no_cling` signatures no ambient element may reproduce (rule 13) | Yes, Approved (`design/gdd/ability-gating.md`) |
| Art bible | Soft | Each biome preset's look (palette, fog colours, grade); the region 1 Cooling Yards palette against the Cinderheart reference | Draft (`design/art/art-bible.md`, sections 1-4 written 2026-11-20) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Pause and menus | Soft | The Atmosphere option, Full or Reduced, and what each does (rule 14); menus drawn above the grade |
| Level design | Soft | Section rules and the blend spacing (rule 8, Edge Cases); the preset override list (rule 3); the value check (P4) for the rooms it lays out |
| Combat and Enemies | Soft | A projectile at least twice an ember's size and never ember-coloured without an outline or a trail (Edge Cases); hit effects on the play layer are not bloomed (Interactions) |
| Grid map | Soft | Nothing; the map is drawn above the grade, ungraded, and freezes the world (rule 16) |

**Bidirectional check:**

- Terrain pipeline lists this system in its Interactions ("Which layer is the play layer and its draw order ... the rule that other layers never imitate it") and as a hard downstream in its Dependencies. Match. It does not yet say it owns the cobbled lip (the reference scene's "middle rim"), the floor runs or the light-carrying flag; Open Question 1.
- Rooms and transitions lists this system in its Interactions ("The current room's biome and bounds, so layers are placed per room"). Match. The room-data fields and room-check items are new; Open Question 2.
- Level design says the look "is owned by the terrain pipeline and the parallax, lighting and atmosphere systems" and states the Readability rule this GDD uses (rule 13). Match; it should name sections and glow spots when it next revises (Open Question 2).
- The systems index row lists Terrain pipeline, Camera and Rooms and transitions. Match; Level design, Ability gating, the Player controller and the art bible are soft and need no index change.
- Ability gating's signatures (its rules 10, 14) are read, not changed. It does not need to list this system.
- Grid map (Approved) states that the map freezes play (its rule 11) but not that the map screen draws above the grade, and does not list this system. Not a match yet; Open Question 2.
- Camera, Player controller, Pause and menus, Combat, Enemies have no GDD yet (the art bible is a Draft). Each needs a matching entry when it is written.

## Tuning Knobs

Every value is the reference scene's starting value, held in the biome's atmosphere preset (rule 3) unless it says constant. The preset check (Edge Cases) rejects a value outside its safe range. Ranges are recommendations **[Rec]**; the owner may change them.

| Knob | Value | Safe range | What it changes |
|---|---|---|---|
| `far_blur`, `mid_blur`, `close_blur` | 7, 3.2, 1.2 screen px | 3-12, 1-6, 0-3 | How soft the three back groups are; the passes compound (rule 1) |
| `back_tint`, `close_band_tint` | (0.74, 0.66, 0.66), (0.72, 0.68, 0.70) | each channel 0.5-1.0 | How dark the far and mid layers and the close band sit (P4) |
| Fog `a`: deep, far, near-back | 0.55, 0.58, 0.22 | 0-1 each | How much haze each bank adds (P5) |
| Fog ramps `y0`-`y1` | deep 0-0.85, far 0.15-0.9, near-back 0.35-0.95, ground 0.55-1.0 | `y0` < `y1`, within 0-1 | Where each bank gathers (P5) |
| `ground_fog_alpha_max` (constant) | 0.3 | 0.1-0.4 | The most the fog in front of the lip may hide (rule 9, P5) |
| `reduced_fog_scale` | 0.5 | 0.25-1 | How thin every fog is in Reduced (rule 14) |
| Dust, embers: count | 90, 90 | 0-150 each | How busy the air is |
| Ember size | 1.4-2.8 px core | at most `ember_size_max` 2.8 | How large a spark reads (rule 13) |
| `glow_flicker` | amplitude 0.12, 2.3 rad/s | amplitude at most 0.2, at most 3 cycles/s | How much a prop glow pulses (Edge Cases) |
| `close_min_run` | 108 px | 72-216 | The smallest stretch that gets a close band (rule 6) |
| `close_sink` | 12 px | 6-24 | How far the rocks sit below the floor line |
| `close_edge_inset`, `close_drop_drift` | 54, 18 px | `inset - drift` at least 36 | How far a drop end stays from the edge (P7) |
| `close_wall_drift`, `close_wall_extend` | 36, 72 px | `extend` at least `drift` + 36 | How far a wall end may drift and how far it runs behind the wall (P7) |
| `close_end_fade` | 40 px | 20-60 | How a drop end trails off |
| `close_headroom`, `close_min_height` | 0.55, 12 px | 0.3-0.7, 6-24 | How much of a low ceiling the band fills; the smallest band shown |
| `backlight_strength`, `backlight_blur` | 0.4, 3.5 world px | 0-0.8, 1-8 | The Seeker's silhouette glow (rule 12) |
| `backlight_radiance`, `backlight_radius` | 0.14, 34 world px | 0-0.3, 16-64 | The soft round glow behind him; radius, 68 px across at 34 |
| `backlight_tint` | (1.0, 0.78, 0.62) | each channel 0.5-1.0 | The backlight's colour |
| `player_light_lift`, `player_light_dim` | 0.03, 0.16 | 0-0.1, 0-0.3 | How much the Seeker is lifted and the rest dimmed (rule 12) |
| Contrast, saturation, split tone | 1.1, 1.0, 0.7 | 0.9-1.3, 0.7-1.2, 0-1 | The grade's colour (rule 12) |
| Vignette | strength 0.5, from 0.5 to 1.1 screen heights | 0-0.7 | How much the corners darken (Edge Cases) |
| `silhouette_sway`, `silhouette_max_drift`, `silhouette_lag`, `silhouette_top` | 1.2, 40 px, 0.45 s, 0.53 | 0-2, 0-60, 0.1-1.0, 0.45-0.6 | How the foliage band moves (rule 7, P6) |
| `foreground_reach_max`, `room_end_inset_max` | 0.41, 38 px | 0.2-0.45, 0-60 | How far foreground art may reach into the play space (rule 5) |
| `layer_blend` | 72 px | 36-144 | How wide a section change blends (rule 8) |
| `value_margin_min` | 0.10 | 0.05-0.20 | The warning level of the value check (P4) |

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. The art bible is a Draft (`design/art/art-bible.md`, sections 1-4 written 2026-11-20); this section is drafted from the owner's reference scene and the region 1 visual direction (`design/narrative/kiln-city-visual-direction.md`), and the art bible owns every look named here.

- **Per biome (the preset's art):** a far layer (opaque, distant skyline or cavern); a mid layer (alpha, made to repeat mirrored); for corridor-like sections, a near wall that loops; close-band pieces A, B and C (rocks) and A, B and C (plants), each starting and ending in low rubble so a stretch tapers on its own; top and bottom foreground strips made to loop; left and right room-end pieces; extra far and mid art for any long room that changes background by section (rule 8). The six biome packs (`assets/environment/`) and their cave-corridor sets supply most of these today. **[Ref]**
- **Shared by every biome:** the silhouette band's black foliage pieces A-F (`assets/environment/foreground-silhouettes/`); the ember, dust and glow sprites (soft radial). **[Ref]**
- **Filtering:** all painted bands use smooth, mipmapped filtering, as the terrain's painted art does (terrain Visual/Audio); the Seeker's own filtering is the Player controller's. **[Ref]**
- **Light is painted.** Lava seams, kiln windows and lit props are painted into the art; glows only add a soft warm halo on top (rule 11). No band carries a shadow cast by the Seeker or anything else. **[Rec]**
- **Value plan:** the bright end of every back band, after fog and grade, sits below the floor's lit edge and the Seeker (rule 13, P4); the silhouette band and foreground framing are near-black. Region 1's lore asks the same ("background and foreground framing stay darker than both"). **[Ref]**
- **Region 1:** the lore's four parallax planes (cold chimney skyline; domed kilns with firebox windows; yard walls, trays and saggar columns; dark rail and stack silhouettes) map onto the far layer, the mid layer, the close band and the foreground strips. Whether region 1 uses the Cinderheart pack or its own Cooling Yards art is the art bible's (Open Question 5). **[Rec]**
- **Audio:** this system makes no sound. Biome ambience (lava rumble, wind through the yards) belongs to the Audio system; if it wants to follow the look, it can read the biome and the section in view. **[Rec]**

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:parallax-lighting-and-atmosphere` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

- **Depth you feel by moving.** The far city barely drifts while the close rocks slide past and the foreground sweeps by faster than the Seeker: running reads as travelling through a deep place, not along a wall. **[Ref]**
- **The Seeker is the light.** A soft light follows the pale Seeker and a warm backlight glows from behind him, so wherever it goes it is the clearest thing on screen and the room seems to brighten around it. **[Ref]**
- **Calm, not busy.** Fog drifts slowly, embers rise and dust floats; nothing ambient pulses fast, flashes or crosses the play space quickly, so a fight's motion always stands out against it. **[Rec]**
- **Comfort.** The Reduced setting keeps the depth and the light and drops the blur, particles and sway and keeps the backlight, for slower machines and players who find haze or motion tiring (rule 14). **[Owner, 2026-11-20]**
- **Playtest question:** whether the silhouette band's sway after a big jump reads as near foliage brushing past, or as the screen wobbling, and whether the foliage rising to about 0.38 of the screen height in a fall ever hides the Seeker or the landing floor for long enough to cost a player a hit or a missed landing.

## UI Requirements

- **In play: nothing.** This system adds no HUD element; the HUD and every menu draw above the grade, ungraded (rule 12). **[Rec]**
- **Options:** an **Atmosphere** option, **Full** (default) or **Reduced**, with one line saying what Reduced does ("Less haze, no particles or glow blur: for slower machines or motion comfort"). It applies at once, with no restart (rule 14). The screen is Pause and menus'. **[Owner, 2026-11-20: Full / Reduced]**

> **📌 UX Flag — Parallax, lighting and atmosphere**: This system adds one option to the options screen. In Phase 4 (Pre-Production), include it when `/ux-design` specifies the options screen (Pause and menus) **before** writing epics. Stories that reference it should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| The play layer at draw order 0; other layers never imitate it (rule 5); draw order of the biome packs; painted filtering; one biome per room (rule 14); the prop catalogue (Open Question 6); display migration and camera zoom (Open Question 9) | Terrain pipeline | `design/gdd/terrain-pipeline.md`, Approved (eighth review, 2026-11-22) |
| A room's biome and bounds; the build while dark and the freeze (rules 9, 12); camera bounds and zones (rules 13, 14, R4); biome loads at a region border (R5) | Rooms and transitions | `design/gdd/rooms-and-transitions.md`, Approved |
| Readability: play-layer edges brightest, the room reads in greyscale, backgrounds and framing never imitate a platform or gate (Visual/Audio); terrain look over fogged parallax (Owner, 2026-11-18); large painted rooms and biome memory (Open Question 22) | Level design | `design/gdd/level-design.md`, Approved |
| One signature per key; the `no_cling` signature (rules 10, 14) | Ability gating | `design/gdd/ability-gating.md`, Approved |
| The map freezes play and draws its own screen (rule 11) | Grid map | `design/gdd/grid-map.md`, Approved |
| Region 1's palette, light from below, four parallax planes, value order | Narrative | `design/narrative/kiln-city-visual-direction.md`, approved 2026-11-18 |
| Layer order, camera factors, the placement formula, no texture wrapping | Art assets | `assets/environment/PACK-README.md` |
| The reference look: bands, factors, fog, particles, glows, grade, silhouettes, close band, sections | Reference scene | `src/test_rooms/art_style_test_room.gd`, `src/test_rooms/room_atmosphere.gd` |
| The follow camera, its shake as an offset past the limits, `shake_size` 3 px on the heavy | Camera, Combat | `src/player/player_camera.gd`, `src/player/attack_data.tres`; no GDD |
| The 500 draw-call budget; the art-room bench | Technical preferences, tests | `.claude/docs/technical-preferences.md`, `tests/performance/art_room_bench.gd` |

## Acceptance Criteria

Types: **[Auto]** unit test on the placement, cover, blend and check functions with the camera and room data injected (no rendering); **[Auto, engine]** test that runs the game headless (scene tree, positions, timing; no pixels); **[Auto, render]** test that runs the game with a renderer (lavapipe in the container, as the art-room bench does) and reads the frame; **[Visual]** retained screenshot in `production/qa/evidence/` judged by the owner; **[Play]** playtest record. One criterion or more per core rule (C) and per formula (P); `qa-lead` lens applied in this session (lean mode spawns no agent). Positions are checked to within 0.5 world px.

**Layer stack and motion**
- **GIVEN** the reference room built from the Cinderheart preset, **WHEN** its scene is inspected, **THEN** every band exists, and the Seeker's backlight in the Seeker's tree, with the draw order of rule 1's table, no node this system adds is at 0 (only the play layer's and the Seeker's), the Seeker draws in front of the play layer's fill and dressing, the lip's nodes sit at 4-6 above the Seeker, and nothing else is above the Seeker but the glows (1), ground fog (7), embers (8), foreground strips, room-end pieces and silhouette band (10+); no node this system adds has a collision shape or is in a physics layer. **[Auto, engine]** (rules 1, 13)
- **GIVEN** the camera moved 100 px right and 40 px down in one frame, **WHEN** that frame is drawn, **THEN** on screen the far layer moved 15 and 6 px the other way, the mid layer 50 and 20, the close band's rocks 85 sideways (its plants 92), while the stretch's clamp (P7) is not binding, and 40 vertically (it moves with its floor), the foreground strips 120 and 44, the play layer 100 and 40, all on that same frame. **[Auto, engine]** (rule 2, P1)
- **GIVEN** a room with no overrides and a room overriding the far fog's density to 1.5 and adding a glow spot, **WHEN** both are built, **THEN** the first matches the preset exactly and the second differs only in those two fields. **GIVEN** a room overriding the mid layer's factor, **WHEN** the room check runs, **THEN** it is rejected and the field named. **[Auto]** (rule 3, Edge Cases)

**Cover and edges**
- **GIVEN** the reference room (2520 x 360) and a test room 20 screens wide, **WHEN** P2 runs for the far layer, **THEN** it returns scale 1.65 and 3.86; **GIVEN** a one-screen room, **THEN** cover = 486 x 276 (the view plus twice the 3 px shake). **[Auto]** (P2)
- **GIVEN** the reference room, its 10-screen long room and a 5 x 1 screen room with two sections at x 0-1200 and 1200-2400, **WHEN** the camera sweeps every edge of its travel, and each section's travel range (rule 8), with a 3 px shake at each corner, **THEN** on every frame each band's rectangle (P1, P2) contains the view: no band edge and no clear colour in view. **[Auto]** for the rectangles; **[Auto, render]** for one swept frame per corner, checking no pixel of the clear colour (`0.08, 0.05, 0.06`) shows outside the play layer (rules 4, 17, Edge Cases)
- **GIVEN** that 5 x 1 screen room, **WHEN** P1 and P2 run for the far layer (f 0.15) of each section, **THEN** the travel ranges are [240, 1236] and [1164, 2160] (A 738 and 1662, T 996), the scale is 1.324 (within 0.001), and at c = 1236 the first section's band spans exactly to 1479.0. **GIVEN** a section whose range is empty after the cut, **THEN** the room check rejects it. **[Auto]** (rule 8, P1, P2)
- **GIVEN** a room two screens tall, **WHEN** the camera is at its highest, **THEN** the top strip's canvas top is at screen y 0 and the bottom strip's at 297 (off screen); at its lowest, 0 for the bottom strip. **GIVEN** a one-screen room, **THEN** both are at 0 wherever the camera is. **[Auto]** (rule 5, P3)
- **GIVEN** a room-end piece on a left bound that holds an exit, **WHEN** the room check runs, **THEN** it is rejected and named. **[Auto]** (rule 5, Edge Cases)
- **GIVEN** the reference left border (a solid column 100 px wide at room height) on the left bound of a 360 px tall room and the same art on the right bound of a room four screens tall, **WHEN** each room is built, **THEN** the left one is slid 62 px past the bound, and in both no pixel of the scaled art at alpha 0.5 or more lies more than `room_end_inset_max` (38 px) inside the room; **GIVEN** a fixture piece with no opaque column (all alpha under 0.5), **THEN** its slide is 0. **[Auto]** for the slide, **[Auto, engine]** for the scene (rules 5, 13)
- **GIVEN** the 36 foreground strip files of the six biome packs (open-cave, corridor and brighter-corridor sets, top and bottom), **WHEN** the preset check measures each one's reach (the distance from the screen's edge to the farthest row holding a pixel at alpha 0.5 or more, over the canvas height), **THEN** every one is at most `foreground_reach_max` (0.41; the measured maximum is 0.403). **GIVEN** a fixture strip with an opaque pixel (alpha 0.5) 0.45 of the canvas height from its edge, **THEN** the check rejects it and names the file; **GIVEN** a fixture whose only pixels past 0.41 are below alpha 0.5, **THEN** it passes. **[Auto]** (rules 5, 13, Edge Cases)

**Close band, silhouettes and sections**
- **GIVEN** floor runs: a 6 px run with a wall at both ends, an 84 px and a 90 px run with a drop at one end and a wall at the other, a 210 px and a 216 px run with a drop at both ends (every width a whole number of 6 px tiles, so a room can be authored with them), and a run whose headroom gives a band under 12 px, **WHEN** the room is built, **THEN** only the wall-to-wall run, the 90 px run and the 216 px run have a close band (the stretch, after the pull-in and the extension, is at least `close_min_run`: 6 + 144 = 150, 90 − 54 + 72 = 108, 216 − 108 = 108; the 84 px and 210 px runs give 102), and none has a stretch narrower than 108 px. **GIVEN** a stretch's end at a wall, **THEN** at `ref` it lies `close_wall_extend` (72 px) behind the wall, anywhere in the camera's travel never less than 36 px behind it, and its pieces there are at full alpha with no fade; **GIVEN** an end at a drop, **WHEN** the camera is centred on the stretch's `ref`, **THEN** the end is `close_edge_inset` (54 px) in from the drop and its last `close_end_fade` (40 px) fades to nothing, and **WHEN** the camera is moved anywhere in its travel, **THEN** it is never nearer than `close_edge_inset - close_drop_drift` (36 px) to the drop. **GIVEN** the P7 example (`x0` 1000, `x1` 1500, edge at 1554), **THEN** the shift is 18 at c = 1400, 0 at c = 1250 and -36 at c = 900, and a wall end never drifts more than `close_wall_drift` (36 px) toward the wall; **WHEN** the camera moves 50 px vertically, **THEN** each stretch's bottom stays at its floor line plus `close_sink` (12 px). **[Auto]** for P7, **[Auto, engine]** for the scene (rule 6, P7, Edge Cases)
- **GIVEN** the silhouette band at rest, **THEN** its art's top is at or below 0.53 of the screen height. **GIVEN** a 30 px camera rise in one frame of 1/60 s, **THEN** the band drifts 34.7 px down (within 0.5), and 0.45 s of world time later it is about 12.8 px (within 1 px) from rest; in a frame of 1/144 s the first drift is 35.4 px. **GIVEN** a 200 px rise, **THEN** the drift is 40 px. **GIVEN** a 1 s fall at 640 px/s, **THEN** the first frame's drift is −12.3 px at 60 fps (within 0.5), the drift reaches −40 (up) by 0.1 s into the fall and stays at −40 until the fall stops, `lag_y` is never more than 33.3 px from `c_y`, the band's top is at 103 px (within 1) and no higher; 0.45 s after the fall stops the drift is 14.7 px (within 1 px), and 1.5 s after it is within 2 px of rest, at 30, 60 and 144 fps. **GIVEN** `tau` 0 in a preset, **THEN** the preset check rejects it. **[Auto]** (rule 7, P6)
- **GIVEN** a room with a corridor section and the camera's centre moving through its edge, **WHEN** it is 36 px before the edge, at the edge and 36 px past it (`layer_blend` 72, centred on the edge), **THEN** the corridor set's weight is 0, 0.5 and 1, and 0.25 and 0.75 at 18 px before and after (linear), and the section's fog density scale follows the same weight; **WHEN** the camera stops at the edge and turns back, **THEN** the weight follows its position back down with no jump. **GIVEN** section edges 60 px apart, **WHEN** the room check runs, **THEN** it is rejected and named; at 72 px it passes; two sections that share one edge (the 5 x 1 room) pass; a section 60 px wide is rejected; sections laid out both side by side and stacked are rejected. **[Auto]** (rule 8, Edge Cases)

**Atmosphere, light and grade**
- **GIVEN** the ground fog with room scale 1, Full, at the screen's bottom with noise at its peak, **THEN** its alpha is 0.3; in Reduced, 0.15. **GIVEN** a ground fog override of 1.5, **WHEN** the room check runs, **THEN** it is rejected; a far fog override of 2 passes. **GIVEN** a preset whose ground fog has `a x density` 0.35, **WHEN** the preset check runs, **THEN** it is rejected and the field named; at 0.3 it passes. **[Auto]** (rule 9, P5)
- **GIVEN** a room just built, **WHEN** the first frame of its fade-in is drawn, **THEN** the live dust and ember counts are each at least 90% of their preset counts, and the bands are placed for the arrival camera; no node of the previous room's bands remains. **[Auto, engine]** (rules 10, 15)
- **GIVEN** a prop the catalogue marks as carrying light, **WHEN** the room is built, **THEN** it has a glow of its listed radius; **GIVEN** the room's scene, **THEN** it holds no `PointLight2D`, `DirectionalLight2D` or `LightOccluder2D`. **GIVEN** a preset with glow flicker amplitude 0.3 or a rate above 3 cycles per second, **THEN** the preset check rejects it. **[Auto, engine]** for the scene, **[Auto]** for the check (rule 11, Edge Cases)
- **GIVEN** the same frame of the reference room drawn with the grade on and with it off, **WHEN** both are read, **THEN** the HUD help text's fully opaque pixels are identical in both: the grade never touches the HUD or a menu. **[Auto, render]** (rule 12)
- **GIVEN** the reference room, mood on, **WHEN** a screenshot is taken at the start, over the pit, in the corridor and with the Seeker in a corner of the room, **THEN** each is retained and signed off by the owner as matching the reference look, and the Seeker and the floor edges are the clearest things in each. **[Visual]** (rules 1, 12, 13)

**Readability and setting**
- **GIVEN** each of the four frames above, **WHEN** P4 runs with the play layer, props, glows (the backlight's two sprites among them) and Seeker identified by mask (excluded from the back pixels, read as the lip and Seeker pixels), **THEN** the value margin is reported; a margin under 0.10 is logged as a warning naming the frame, and it does not fail the build; it runs in Full and again in Reduced, which keeps the brightness order (rule 14). **GIVEN** a fixture frame whose back pixels are brighter than its floor edge, **THEN** the margin is negative and the warning names it. **[Auto, render]** for the report, **[Auto]** for the fixture (rule 13, P4)
- **GIVEN** the Atmosphere option set to Reduced, **WHEN** the next frame is drawn, **THEN** the blur, dust and embers are not drawn, the silhouette band sits at rest, the Seeker's backlight is still drawn, each fog's alpha is half, and every band's position except the silhouette band's equals its position in Full for the same camera (the silhouette band sits at rest in Reduced and drifts in Full). **WHEN** it is set back to Full, **THEN** dust and embers are at steady density on that frame. **[Auto, engine]** (rule 14, Edge Cases)
- **GIVEN** the reference scene with the Seeker in any animation frame, **WHEN** a frame is drawn with the backlight shown and again with it hidden, **THEN** every Seeker pixel at alpha 1 is identical in the two; the backlight's nodes are at order −1 in the Seeker's tree and carry the sprite's current frame texture, offset, facing, scale and rotation, and the radiance's sprite is `2 x backlight_radius` (68 world px) across at strength 0.14. **GIVEN** the grade, **THEN** it draws no bloom or radiance (absent, or strength 0) and its light lift at the Seeker's centre is `player_light_lift` (0.03). **[Auto, engine]** (rule 12)
- **GIVEN** the pause menu or the grid map opened for 3 s, or a transition's freeze of 0.25 s, **WHEN** it ends, **THEN** every particle, fog offset, glow phase and the silhouette drift are where they were when it opened. **[Auto, engine]** (rule 16)
- **GIVEN** a camera shake of 3 px, **WHEN** the frame is drawn, **THEN** every band is offset on screen by the same amount as the play layer, because bands are placed from the follow position without the shake. **[Auto, engine]** (rule 17)
- **GIVEN** a death into another biome's room (cross-system: rooms and transitions R5), **WHEN** it is built, **THEN** its bands use that biome's preset and no art from the first biome is drawn. **[Auto, engine]** (rule 3, Edge Cases)

**Performance and feel**
- **GIVEN** the reference room and the long room, mood on, **WHEN** the art-room bench sweeps them, **THEN** draw calls per frame stay under the 500 budget (`technical-preferences.md`) and the bench reports the pass's frame-time cost, Full against Reduced (`sweep.draw_calls.max` and `sweep.render_cpu_ms` in the bench's output). Measured 2026-11-22 on the long room, Full, 600 frames at 1920 x 1080 in software GL: draw calls max 287, p95 273, mean 131; frame time about 222 ms, not comparable to hardware; Reduced not yet run. **[Auto, render]** (performance; the target-hardware budget is Open Question 4)
- **GIVEN** 5 playtesters who each fall at least 5 times from a height of two screens or more in region 1, **WHEN** asked after the session, **THEN** none says the foreground foliage hid the Seeker or the landing floor in a way that made them miss a landing or take a hit, and none is seen to mistake it for something to stand on. **[Play]** (rule 7, P6)
- **GIVEN** 5 playtesters in region 1's first rooms, **WHEN** asked after the session, **THEN** none says they tried to stand on, or grapple to, something in the background or foreground, and at least 4 call the look "deep" or "atmospheric" unprompted or when asked to describe it. **[Play]** (Overview, rule 13)
- **GIVEN** a preset with `backlight_radius` 100, `close_wall_extend` 60 (under `close_wall_drift` + 36), `close_edge_inset` 50 (so `inset - drift` is 32) or a value outside any other range in Tuning Knobs, **WHEN** the preset check runs, **THEN** it is rejected and names the field. **[Auto]** (Tuning Knobs, Edge Cases)
- **GIVEN** the preset check with a negative factor, a missing art file, a fog with `y0 = y1` or an out-of-range override, **WHEN** a biome's preset loads at boot, **THEN** the title screen does not show and every bad value and file is named. **[Auto]** (Edge Cases)

**Gaps found by the QA lens:**
- Rule 12's grade is judged by eye; only its effect on the HUD and the value margin are automated. Visual fidelity is not automated, by the coding standards.
- P4 needs masks (the play layer, props, glows and Seeker drawn as flat ids in a second pass); the method belongs with the test helpers, not this GDD.
- The frame-time budget on target hardware has no number: the target platform and its GPU are not set (`technical-preferences.md`), and the container renders in software.
- The sections, room-end and blend room checks are requirements on Rooms and transitions (Open Question 2); their criteria pass only once those checks exist.

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **Terrain pipeline changes.** It is Approved (eighth review, 2026-11-22) but does not yet hold what this GDD reads from it. Wording it needs: "the cobbled lip (the reference scene's middle rim, the modular foreground tiles tracing every exposed edge, set a few px inside the solid) is the terrain's trim, drawn at order 4-6 in front of the Seeker, which draws at 0 in front of the play layer's fill and dressing" (owner, 2026-11-20; draw order added at the first design review); "the pipeline reports each straight floor run, its width, whether each end is a wall or a drop, and the headroom above it" (rule 6); "the prop catalogue marks a prop as carrying light, with a glow radius" (rule 11, its Open Question 6). Owner: terrain pipeline (its revision). Target: its next revision.
2. **Rooms and transitions and level design.** The room data needs this system's override fields (fog density scales, glow spots, sections with their back sets, room-end pieces, close band and silhouette band off, rule 3) and the room check two items (sections not in strips along one axis, or two distinct section edges closer than `layer_blend`; a room-end piece on a bound with an exit). Level design names sections and glow spots among what it lays out. Grid map (Approved) states the freeze only (its rule 11) and does not list this system: it needs one line that the map screen draws above the grade, ungraded (rule 12), or this GDD's Interactions row changes. Owner: rooms and transitions, level design, grid map. Target: before the first story that builds a room with this look.
3. **Implementation ADR.** How the bands are placed (the engine's `Parallax2D`, which misplaced layers under the 4x zoom in the reference, or manual placement as the reference does), how the grade and fog are drawn, and the preset resource's format. **NOT SOURCEABLE:** 2D canvas screen-reading shaders (`hint_screen_texture`) and their 4.5-4.7 behaviour are not covered by `docs/engine-reference/godot/modules/rendering.md`, whose post-processing pattern (`Compositor`) is for 3D (`WorldEnvironment`, `Camera3D`). The reference runs on Godot 4.7.2 (owner, 2026-11-20), which `docs/engine-reference/godot/VERSION.md` still lists as not determined. Owner: technical director (`/architecture-decision`), with terrain Open Question 9 (display and zoom). Target: before the first story.
4. **Frame-time budget.** The target platform and its GPU are not set (`technical-preferences.md`), so the pass has no millisecond budget; the container renders in software, so its numbers only compare Full with Reduced. Owner: technical director. Target: before Vertical Slice.
5. **Region 1's look.** The reference preset is Cinderheart Caldera; region 1's lore (the Cooling Yards) asks for soot-umber ground, dim amber light from below and kiln silhouettes. Whether region 1 uses a Cinderheart preset or its own art, and how the painted reference meets the lore's pixel-art target, is the art bible's (level design Open Question 17). Owner: art director. Target: the art bible.
6. **The other five presets.** Each biome pack needs its preset (bands, fog colours, particles, glow colour, grade) tuned by eye like the reference. Owner: art, level design. Target: when each biome's first room is built.
7. **Accessibility.** Reduced covers haze and motion; whether players also need a separate screen-shake switch (the Camera's) or a higher-contrast option belongs in the project's accessibility requirements (`design/accessibility-requirements.md`, not yet written). Owner: UX. Target: `/ux-design` accessibility.
8. **Ember footprint against the projectile rule.** An ember's core is 2.8 px (`ember_size_max`) but its soft sprite is 5.6 px wide, so a 6 px projectile is barely larger than the footprint. Decide whether the Combat and Enemies requirement (twice the ember size) applies to the core or to the footprint. Owner: the owner, with Combat. Target: when projectiles are designed.
9. **A wall thinner than the extension.** The close band runs `close_wall_extend` (72 px) behind a wall; behind a wall thinner than that (a one-tile wall with open air behind) it would show. Decide a rule (extend only as far as the wall is thick, or reject such walls near a band) and test it in the prototype room. Owner: level design with terrain. Target: before region 1's rooms.
10. **Reference numbers against the art bible.** The grade, fog and tint values here are the reference scene's, tuned by eye on 2026-11-21 and 22; reconcile them with the art bible's Mood and Color sections (2 and 4) and re-measure P4 on the current scene. Owner: art director. Target: the art bible's next pass.
