# Parallax, lighting and atmosphere

> **Status**: In Review. Designed 2026-11-20 (`/design-system`, lean, standard). First `/design-review` 2026-11-20 (lean): NEEDS REVISION, 3 blockers revised (draw order with the Seeker and the lip, rule 13; a ground fog alpha cap; section A and T from a travel range, blend centred on the edge); 7 recommended not applied; awaiting re-review in a fresh session
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Creative Director Review (CD-GDD-ALIGN)**: skipped — Lean mode
> **Implements Pillar**: none defined (brief, Look: "2D pixel side view ... Sword FX on their own layer, sparks and glow on hits"; systems index: "parallax, vignette and light give depth")
> **Reference scene**: `src/test_rooms/art_style_test_room.tscn` with `src/test_rooms/room_atmosphere.gd` (owner, 2026-11-20: "lands pretty close to what I'm aiming for")

## Summary

Parallax, lighting and atmosphere draws everything in a room except the playable ground: painted back layers that drift slower than the camera, a close band of rocks and plants behind the floor, foreground framing that sweeps past faster, fog, dust, embers, warm glows and a screen grade that lights the Seeker. It gives each room depth and mood from a per-biome preset, matching the owner's reference scene, while keeping the floor edges and the Seeker the clearest things on screen. A Full / Reduced option keeps it comfortable on slow machines and for players sensitive to haze or motion.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Terrain pipeline, Rooms and transitions, Camera`

## Overview

Parallax, lighting and atmosphere is everything a room shows that is not the play layer. Around the terrain pipeline's play layer (collision, black fill, trim and dressing at draw order 0) it builds a room's depth: painted back layers that move slower than the camera (the far city, the midground ruins, the close rocks and plants just behind the floor), foreground framing that moves faster (the foreground strips and the black silhouette band), fog banks between those layers, drifting dust and rising embers, warm glows on lit props, and a screen grade over it all (an ambient gradient, a soft light and bloom around the Seeker, contrast and split tone, a vignette). A room chooses its layers and their settings from its biome and its own data; this system places, moves and draws them every frame from the camera. The player never operates it: they feel it as a deep, warm, hazy world in which the pale Seeker and the bright floor edges are always the clearest things on screen. It owns no collision and changes no rule of play, but it must never mislead: nothing it draws may read as ground, a ledge or a gate (terrain rule 5; level design, Readability). Without it a room is black masses on a flat colour, and the look the brief and the owner's reference scene set (`art_style_test_room.tscn` with `room_atmosphere.gd`) is lost. How the pass is built (shaders, node layout, a scene per biome) is an ADR, not this document. **[Owner, 2026-11-20: the reference scene lands close to the aim]**

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Rec]** = recommendation, change freely; **[Ref]** = what the reference scene does today (`src/test_rooms/art_style_test_room.gd`, `room_atmosphere.gd`), kept as the starting design. `game-designer`, `art-director`, `technical-artist` and `systems-designer` not consulted: Lean mode. Review manually before production. Every number below is a starting value read from the reference scene; the data lives in the biome preset (rule 3), never in code.

**The layer stack**

1. **Bands.** A room draws in this order, back to front. Draw order is relative to the play layer at 0, which the terrain pipeline owns (terrain rule 5, Visual/Audio: draw order); this system owns every other band. **[Ref; Owner, 2026-11-20: the reference scene is the aim]**

   | Order | Band | Moves with the camera (x, y) | Notes |
   |---|---|---|---|
   | −30 | Far layer (distant city, sky) | 0.15, 0.15 | Opaque; blurred `far_blur` (5 screen px) |
   | −22 | Deep fog | 0.2 | Between far and mid |
   | −20 | Mid layer (ruins, kilns) | 0.5, 0.5 | Alpha; blurred `mid_blur` (2 screen px); repeats mirrored |
   | −14 | Far fog | 0.4 | Between mid and the close band |
   | −13 | Dust | in the world | Drifting motes behind the play layer |
   | −10 | Near wall (corridor sections only, rule 8) | 0.85, 0.85 | Replaces the far and mid layers inside the section |
   | −9 | Close band: rocks, then plants in front | 0.85 / 0.92 sideways; 1 up and down (with the world) | Fixed to each floor run (rule 6) |
   | −6 | Near-back fog | 0.8 | Thin, so the close band sits back without hiding |
   | 0 | **Play layer** (terrain pipeline) and **the Seeker** | 1.0 | Collision, black fill, baked trim and dressing; the Seeker draws at 0 in front of them (tree order: the player controller's and the terrain pipeline's, Open Question 1). Nothing this system adds is at 0 |
   | 1 | Prop glows | 1.0 | Rule 11; additive, in front of the Seeker and behind the lip |
   | 4-6 | **The cobbled lip** (terrain pipeline) | 1.0 | The reference scene's middle rim: its tiles at 5 (`MIDDLE_Z`), its corner and patch pieces at 4 and 6. Drawn in front of the Seeker and of the glows **[Owner, 2026-11-20: the lip is the terrain pipeline's]** |
   | 7 | Ground fog | 1.15 | Thin (alpha capped, rule 9, P5), in front of the lip |
   | 8 | Embers | in the world | Rising sparks, in front of the lip and the Seeker, smaller than any projectile (rule 13) |
   | 10+ | Foreground strips (top and bottom) and room-end pieces | 1.2, 1.1 | Rule 5 |
   | 20 | Silhouette band | 1.2 sideways; screen-bottom vertically | Rule 7 |
   | screen | Grade | — | Rule 12; drawn over every band, under the HUD |

2. **Motion.** Each band's screen position follows the camera by its factor on each axis: a factor below 1 moves slower than the play layer (further away), above 1 faster (nearer), 1 with the world (Formulas P1). Bands are placed every rendered frame from the camera's final position for that frame, after the camera has moved and before anything is drawn, so no band lags the play layer by a frame. **[Ref]** Whether this uses the engine's `Parallax2D` or manual placement is an ADR; the reference places manually because `Parallax2D` misplaced layers under the 4x camera zoom (terrain Open Question 9).
3. **Biome preset and room overrides.** Each biome has one **atmosphere preset**: the art of every band, the factors and draw orders above, the blur radii, each fog bank's colour, density, noise scale, drift and screen-height ramp, the dust and ember settings, the glow colour and flicker, the grade values and the silhouette band on or off. A room uses its biome's preset (terrain rule 14: one biome per room) and may override only: each fog bank's density (a scale: 0-2 for the banks behind the play layer, 0-1 for the ground fog, Formulas P5), the glow spots (rule 11), its sections (rule 8), the room-end pieces (rule 5), and the close band and silhouette band off. Any other change is a new preset. The reference scene's values are Cinderheart Caldera's preset. **[Owner, 2026-11-20: biome preset plus room overrides]**
4. **Never an edge in view.** No band ever shows its own edge, a seam or empty space inside the view, anywhere the camera can go in the room (Formulas P2). An opaque far layer is scaled to cover the view across the camera's whole travel; a mid layer repeats side by side, every other copy mirrored so a non-looping painting's seams meet; strips made to loop repeat plainly. A painting is never wrapped as a texture (`assets/environment/PACK-README.md`: "do not simply enable texture wrapping"). **[Ref]**
5. **Foreground strips and room ends.** The top strip's canvas meets the screen's top when the camera is at the room's top, and the bottom strip's meets the screen's bottom when the camera is at the room's floor (Formulas P3); between those heights they move at the foreground factor. A room may place a room-end piece at a left or right bound that has no exit, fixed in the world and scaled to the room's height (to one screen, top-aligned, in a section less than a screen tall). **[Ref]**
6. **The close band.** Every straight run of floor at least `close_min_run` (108 px: three of the reference scene's 36 px art cells, 18 collision tiles of 6 px, registry `collision_tile`) wide gets its own stretch of close pieces: a whole number of pieces stretched slightly to fit the run, sunk `close_sink` below the floor line, ends pulled in `close_edge_inset` from a drop and faded over `close_end_fade`. Sideways the stretch moves at its factor around its own centre; up and down it stays on its floor. Where the headroom over a run is low, the pieces scale down to fill at most `close_headroom` (0.55) of it. Plants are laid out the same way in front of the rocks. The terrain pipeline supplies the floor runs and their headroom from the collision (Interactions). **[Ref]**
7. **The silhouette band.** A band of black foliage pieces, shared by every biome, along the bottom of the screen. Sideways it moves at the foreground factor. Up and down it sits on the screen's bottom edge; when the camera moves vertically it first drifts the way near foliage would (`silhouette_sway` times the camera's move, at most `silhouette_max_drift`, 40 px), then eases back over `silhouette_lag` (0.45 s). A black base under it covers any gap. Its top never rises above `silhouette_top` (0.53 of the screen height, the pack's reference placement) at rest, so it frames the bottom and never covers a floor the Seeker stands on in the middle of the screen. **[Ref; Rec: the height cap]**
8. **Sections.** A room may hold **sections**, rectangles of whole tiles that each use their own back set: their own far and mid art, or a near wall at −10 in place of both (the reference corridor), and their own fog densities. A long room may change its background from section to section, as Hollow Knight does within one region, rather than stretching one painting across the whole room. **[Ref; Owner, 2026-11-20: any scale is accepted, and long rooms use different backgrounds in different sections]** The geometry, which P1 and P2 read:
   - **A set fills the whole view.** It is not masked to its section's rectangle: which set shows is decided by where the camera's centre is, so the view may show a neighbouring section's area in this section's art.
   - **The blend is centred on the shared edge.** Over `layer_blend` (72 px) of camera-centre travel, from `layer_blend / 2` before the edge to `layer_blend / 2` after it, the incoming set's weight rises from 0 to 1 (0.5 at the edge) and the outgoing set's falls from 1 to 0. It follows the camera's position, never time, never a cut. **[Ref: the reference corridor's mask is centred on its mouth]**
   - **A set's travel range**, per axis, is every camera-centre position at which its weight is above 0: the section's rectangle widened by `layer_blend / 2` on each side, cut to the camera's centre bounds (the room's bounds inset half a screen, rooms and transitions R4). A set with no neighbour has the room's whole range. A range that comes out empty is rejected by the room check. **A** (P1) is the midpoint of that range and **T** (P2) its length, so the camera's centre is never more than `T / 2` from `A` while the set shows.

**Atmosphere**

9. **Fog banks.** Each fog bank is a soft, noise-shaped haze in one colour that drifts slowly and moves at its own factor. Its density ramps with screen height between two values (from nothing to full, top to bottom) so it gathers low. The ground fog in front of the play layer stays thin: its alpha (`a x density x room_scale x setting_scale`, P5) never exceeds `ground_fog_alpha_max` (0.3, the reference's value), so it cannot hide a floor edge (rule 13). The preset check rejects a ground fog whose `a x density` is above that cap, and the room's scale for it is capped at 1 (rule 3). **[Ref; Rec: the cap, after the first design review]**
10. **Particles.** Dust (behind the play layer) and embers (in front of it) are spawned over the view, drift or rise at the preset's speeds and live for the preset's lifetime. They are already at their steady density on a room's first shown frame (rule 15), never fade in from empty. They have no collision and no effect on play. **[Ref; Rec: pre-warmed]**
11. **Glows.** A prop the prop catalogue marks as carrying light (terrain Open Question 6, the catalogue format) gets a soft warm glow of its listed radius, additive, flickering by the preset's flicker. A room may add glow spots (a point and a radius) for light painted into its art. Glows light nothing and cast no shadow: there are no engine light nodes. Light in this game is painted into the art, added by glows and shaped by the grade. **[Ref; Rec: no light nodes]**

**The grade and the Seeker**

12. **The grade.** Over every band, under the HUD and every menu, one screen pass applies, in order: a bloom on the bright parts within `bloom_area` of the Seeker (full near its body, fading to nothing, so there is no ring), a warm radiance at the body (squared falloff), contrast, split tone (shadows cooler, highlights warmer) and saturation, the ambient gradient (multiplied: the top a little cooler and darker, the bottom warmer, light coming from below as in the region 1 lore), a soft light around the Seeker (its body brightened by `player_light_lift`, 0.1, the rest of the screen dimmed by `player_light_dim`, 0.16), and a vignette towards the screen's corners. The light, bloom and radiance centre on the Seeker's body, `player_centre` (13 px) above its feet. **[Ref]**
13. **Readability first.** The look must never mislead or hide play (level design, Readability; terrain rule 5):
    - Nothing this system draws has collision, and nothing is shaped like a floor, a ledge, a wall to cling to or a gate.
    - Every band behind the play layer, after fog and grade, is darker than the play layer's lit edges and than the Seeker (Formulas P4).
    - Only these are drawn in front of the Seeker, each with its limit, and nothing else is: the prop glows (order 1; additive, and behind the lip, so a glow can never cover a floor edge); the cobbled lip (terrain's, at the floor edges); the ground fog (order 7; alpha at most `ground_fog_alpha_max`, 0.3, rule 9 and P5, so the lip stays readable through it); embers (order 8; no larger than `ember_size_max`, 2.8 px); and the foreground strips and the silhouette band, which stay near the screen's top and bottom (rules 5, 7).
    - No ambient element reproduces a gate's or the `no_cling` face's signature (ability gating rules 10, 14).
    - Embers only rise and dust only drifts with the preset's wind; neither follows anything, and both stay smaller than any projectile (Edge Cases).
    **[Rec; ability gating, level design and terrain constraints]**
14. **Atmosphere setting: Full or Reduced.** A player option, Full by default. Reduced turns off the blur, the dust and embers, the bloom and radiance, and the silhouette sway (the band sits still on the bottom), and scales every fog bank's density by `reduced_fog_scale` (0.5). Parallax, the glows, the light around the Seeker, the ambient gradient, contrast, split tone and vignette stay, so Reduced keeps the room's depth and its brightness order. A change applies on the next frame, with no reload. The reference scene's V key stays a debug-only switch for the whole pass. **[Owner, 2026-11-20: Full / Reduced player option; Rec: what Reduced drops]**

**Rooms and time**

15. **Built with the room.** A room's bands are built with the room, while the screen is dark (rooms and transitions rules 9, 12), placed from the camera's snapped arrival position, with particles at steady density and the silhouette band at rest, so the first frame of the fade-in shows the finished look. Nothing of the previous room's bands stays. **[Rec]**
16. **World time.** Fog drift, particles, glow flicker and the silhouette sway run on the world's clock: they stop whenever the world is frozen (a transition's freeze, the pause menu, the grid map) and resume where they were. **[Rec]**
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

Rooms and transitions is Approved; Terrain pipeline is In Review (sixth review, MAJOR REVISION NEEDED); Camera has no GDD (code only). Every interface with them is **provisional** until their owners adopt it.

| System | Direction | Data flowing | Owner of the interface |
|---|---|---|---|
| Terrain pipeline | In | The play layer at draw order 0 with its trim, and the cobbled lip at 4-6 in front of the Seeker (owner, 2026-11-20); the floor runs and their headroom from the collision (rule 6); props marked as carrying light, with a glow radius (rule 11, prop catalogue); rule 5 (nothing imitates the play layer) | Terrain owns the play layer, the lip (at 4-6, in front of the Seeker) and the catalogue; this system owns every other band |
| Rooms and transitions | In | The current room's biome and bounds (its Interactions); when a room is built and freed; the transition's freeze and fade (its rules 9, 12); the room's sections and glow spots in the room data | Rooms owns the room data and the sequence; this system owns the bands built from it |
| Camera | In | The camera's follow position each frame, after it moves (rule 2); its arrival snap (rule 15); the shake offset (rule 17); the zoom | Camera owns follow, shake and zoom; this system owns placement from them |
| Level design | In | Section rectangles, glow spots, fog density scales and room-end pieces per room (rule 3); the Readability rule shared (rule 13) | Level design places them; this system defines what they do |
| Player controller | In | The Seeker's position, for the light, bloom and radiance (rule 12) | Player controller |
| Pause and menus | Both | Out: the atmosphere setting, Full or Reduced (rule 14). In: pause freezes the world (rule 16); menus draw above the grade | Pause and menus owns the options screen; this system owns what each value does |
| Grid map | In | The map freezes the world (rule 16); the map screen is drawn above the grade, ungraded | Grid map |
| Combat (hit effects) | In | Sparks and glow on hits are combat's, on the play layer; inside `bloom_area` they bloom with the Seeker | Combat |
| Ability gating | In | Gate and `no_cling` signatures that no ambient element may reproduce (rule 13) | Ability gating |
| Art bible | In | The look of each biome's preset: palettes, fog colours, grade (not yet written) | Art director |

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
| A | float (world px) | inside the room | calculated | The midpoint of the camera-centre travel range of the band's set: for a room's own set, the room's centre; for a section's set, the midpoint of its travel range (rule 8), which is not always the section's centre |
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
| T | float (world px) | 0 or more | calculated | The length of the band's set's camera-centre travel range on this axis: for a room's own set, the room's size minus one screen (camera zones are ignored, Edge Cases); for a section's set, the length of its travel range (rule 8). It is measured between camera centres, so the view's half screens are already in V and are not added again |
| m | float (world px) | 0 or more; 3 today | calculated (attack data) | The largest camera shake any attack requests (`shake_size`, `attack_data.tres`: the heavy, 3 px). Shake moves the picture past the camera's limits (rule 17, `player_camera.gd`), so each side needs this margin |
| W, H | float (world px) | > 0 | calculated (art) | The band's art at its native scale: a 1920 x 1080 pack canvas is 480 x 270 |
| cover | float (world px) | V + 2m to V + 2T + 2m | calculated | The size the band must cover so no edge shows anywhere the camera can go (rule 4) |
| scale | float | 1 or more in practice | calculated | How much the art is enlarged |
| copies | int | 2 or more | calculated | Side-by-side copies of a repeating band (mirrored every other one, rule 4) |

**Output Range:** in a one-screen room or section (T = 0) every band covers the view plus the shake margin, at scale just over 1. `cover` grows with the camera's travel, and so does `scale` for a band that does not repeat. Nothing divides by a value that can be 0 (W and H are art sizes). There is no upper bound: **any scale is accepted (owner, 2026-11-20)**, and a room that would stretch a painting too far uses sections with their own art instead (rule 8).
**Example:** the reference room (2520 x 360; T = 2040 x 90): far layer (f 0.15, no repeat, m = 3): cover = 792 x 289.5, scale = max(1.65, 1.07) = **1.65**. A room 20 screens wide (T = 9120): cover_x = 1854, scale **3.86**. Mid layer (f 0.5, repeats sideways) in a room 4 screens tall (T_y = 810): cover_y = 681, scale **2.52**.
**Example (sections):** a room 5 screens x 1 (2400 x 270) with two sections, x 0-1200 and 1200-2400 (`layer_blend` 72). The camera's centre runs 240-2160. The first section's travel range is [-36, 1236] cut to [240, 1236]: A = 738, T = 996; the second's is [1164, 2436] cut to [1164, 2160]: A = 1662, T = 996. Far layer (f 0.15): cover_x = 480 + 0.15 x 996 + 6 = 635.4, scale **1.32**. Check at the section's far end (c = 1236): the band's centre is 1236 x 0.85 + 738 x 0.15 = 1161.3 and its right edge 1161.3 + 317.7 = 1479.0, exactly the view's right edge plus the shake margin (1236 + 240 + 3). Taking A as the section's centre (600) would leave about 21 px of the view uncovered there (its right edge at 1458.3).

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

**Output Range:** the top strip sits at 0 (art at the screen's top) with the camera at its highest and rises off screen as the camera goes down; the bottom strip sits at 0 (its canvas fills the screen, art at the bottom) with the camera at its lowest and sinks off as the camera rises. In a room one screen tall (T_y = 0) both always sit at 0, so both show.
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
**Example (measured 2026-11-20, reference scene, Godot 4.7.2, mood on):** start frame: back 0.34, floor edge 0.55, Seeker 0.53, margin **0.19**; island over the pit: back 0.34, edge 0.49, Seeker 0.61, margin **0.15**; corridor: back 0.38, edge 0.70, margin **0.32**. All pass at 0.10.

### P5. Fog density

The fog_alpha formula is defined as:

`fog_alpha = a * density * room_scale * setting_scale * smoothstep(0.25, 0.72, noise) * smoothstep(y0, y1, y_screen)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| a | float | 0-1 | data file | The bank's colour alpha: deep 0.38, far 0.5, near-back 0.22, ground 0.3 |
| density | float | 0-1, starts at 1 | data file | The bank's density in the preset |
| ground_fog_alpha_max | float | 0.1-0.4, starts at 0.3 | data file | The most `a x density` the ground fog's preset may carry (rules 9, 13); the preset check rejects a higher value. The ground fog is the only bank drawn in front of the lip, so it is the only one capped **[Rec, first design review]** |
| room_scale | float | 0-2 for banks behind the play layer; 0-1 for the ground fog | data file (room override, rule 3) | A room's density scale |
| setting_scale | float | 1 (Full) or `reduced_fog_scale` (0.5, Reduced) | data file | Rule 14 |
| noise | float | 0-1 | calculated | Two layers of drifting noise (scale and drift per bank) |
| y0, y1 | float | 0-1 of the screen height, y0 < y1 | data file | Where the bank starts and where it is full: deep 0-0.75, far 0.2-0.9, near-back 0.35-0.95, ground 0.55-1.0 |

**Output Range:** 0 to a x room_scale; at most 1 (clamped). Boundaries found: a ground fog override of 2 would give 0.6 over the floor, enough to hide a floor edge (rule 13), so the ground fog's room scale is capped at 1 (the preset's own value); and the preset's own `a x density` was free up to 1, so it is capped at `ground_fog_alpha_max`. Together the ground fog's alpha never exceeds 0.3 at the starting values, in Full or Reduced. The banks behind the play layer may go to 2, where the deep and far banks reach 0.76 and 1.0 and simply hide more background, which is allowed. At y0 = y1 the smoothstep is a hard line, which the preset check rejects.
**Example:** the ground fog at the screen's bottom (y = 1), Full setting, room scale 1, noise at its peak: 0.3 x 1 x 1 x 1 x 1 x 1 = 0.3; in Reduced, 0.15.

### P6. Silhouette drift

The silhouette_drift formula is defined as:

`lag_y += (c_y - lag_y) * (1 - exp(-dt / tau))`  ·  `drift = clamp((lag_y - c_y) * sway, -max_drift, max_drift)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c_y | float (world px) | the camera's vertical travel | calculated (Camera) | The camera's follow centre on y this frame |
| lag_y | float (world px) | near c_y | calculated | A lagging copy of c_y; set to c_y when a room is built (rule 15) |
| dt | float (s) | 0 or more | calculated | World time this frame; 0 while the world is frozen (rule 16) |
| tau | float (s) | 0.1-1.0, starts at 0.45 | data file (`silhouette_lag`) | How long the band takes to settle (63% of the way per `tau`) |
| sway | float | 0-2, starts at 1.2 | data file (`silhouette_sway`) | How far it drifts per px of camera move |
| max_drift | float (world px) | 0-60, starts at 40 | data file (`silhouette_max_drift`) | The cap; a black base under the band covers the gap |

**Output Range:** −40 to 40 px at the starting values. The exponential form gives the same motion at any frame rate. At dt = 0 nothing moves; tau must be above 0 (at 0 the band would snap and never drift, so the preset check rejects it); at sway 0 or in the Reduced setting the band sits still on the bottom.
**Example:** the camera rises 30 px in one frame: drift = 30 x 1.2 = 36 px down; after 0.45 s about 37% remains (13 px), after 1.35 s under 2 px.

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

**Motion and cover**
- **If a room or section is one screen long on an axis** (T = 0): no band moves on that axis, and every band covers the view plus the shake margin (P2). **[Rec]**
- **If a camera zone narrows the camera's bounds** (a boss arena locked to one screen, rooms and transitions rule 14): cover is still worked out from the room's or section's full travel, so nothing changes when the zone engages or releases; the bands just move less while it holds. **[Rec]**
- **If a section is smaller than a screen, or the camera's view reaches into it from outside its rectangle**: a set always fills the whole view and is chosen by the camera's centre (rule 8), so a view that overlaps a section while the centre is outside it simply shows the neighbour's art there. A section's A and T come from its travel range (rule 8), so a section smaller than a screen has a short range, a scale just over 1, and never shows an edge while it is visible. **[Rec]**
- **If the camera stops or turns back inside a section's blend**: the blend follows the camera's position, not time, so it holds or reverses smoothly and never pops. **[Rec]**
- **If two sections' blend zones would overlap**: the room check rejects the room and names it; sections stay at least `2 x layer_blend` apart so at most two sets ever mix. **[Rec]**
- **If the camera shakes at a room's edge**: the shake may carry the view up to `m` (3 px today) past the camera's limits, and every band covers that margin (P2), so no edge or clear colour shows. A larger shake added to the attack data enlarges the margin by itself, because `m` is read from it. **[Rec]**
- **If the window is not 16:9**: the view stays 480 x 270 with bars, as the project's stretch settings keep it (`project.godot`: viewport stretch, aspect keep); no band draws into the bars. The display migration is terrain Open Question 9's. **[Rec]**
- **If the frame rate drops or varies**: placement is per rendered frame from the camera (rule 2), the silhouette drift is frame-rate independent (P6), and drift, particles and flicker advance by world time (rule 16), so the look moves at the same speed at 30 and 144 fps. **[Rec]**

**Close band, room ends and silhouettes**
- **If a floor run is narrower than `close_min_run` (108 px), or a room has no floor runs** (a vertical shaft): that run gets no close band; nothing replaces it. **[Ref]**
- **If the headroom over a floor run is so low that the close band would be shorter than `close_min_height`** (12 px at full scale): that run gets no close band, rather than a sliver. **[Rec]**
- **If a floor run ends at a wall**: no inset at that end; at a drop, the stretch's end is pulled in `close_edge_inset` and may drift at most `close_drop_drift` toward it, staying a full art cell from the edge, where the ledge's rounded corner would show the rock's flat bottom. **[Ref]**
- **If the collision changes while the Seeker is in the room** (a breakable wall or pane breaks, a shortcut opens): the close band keeps the floor runs it was built from; the next build of the room uses the new collision. A break never moves scenery under the player. **[Rec]**
- **If a room-end piece is placed on a bound that holds an exit**: the room check rejects it and names it; a room-end piece goes only on a left or right bound with no exit, so it never hides an opening. **[Rec]**
- **If the camera falls or rises many screens fast**: the silhouette drift stays within `max_drift` (P6) and the black base under the band covers the gap; the band never leaves the screen's bottom. **[Ref]**

**Light, grade and readability**
- **If the Seeker is in a screen corner** (the camera clamped at a room's corner): the vignette darkens that corner by nearly half at the starting values (strength 0.5, about 0.48 at the very corner), and the light around the Seeker lifts it by 10%. Accepted; the value check (P4) runs on a corner frame in the criteria, and a failure there is a tuning note for `vignette`, not a rule change. **[Rec]**
- **If the Seeker is off screen** (a death fall below the room's camera limit): the light, bloom and radiance stay centred on its body even off screen, so the screen dims as usual and nothing jumps when it reappears. **[Rec]**
- **If the Seeker is hidden by a transition's dark screen**: the grade still runs; nothing to see. On the first frame of the fade-in the light is already on the arrival point (rule 15). **[Rec]**
- **If an enemy projectile could be mistaken for an ember**: a requirement on Combat and Enemies, not checked here: a projectile is at least twice an ember's largest size (2.8 px today, so 6 px or more), and never ember-coloured without an outline or a trail. Embers only rise. **[Rec]**
- **If glows overlap**: they add up; overlapping glows are allowed, and the value check (P4) flags a frame they push too bright. **[Rec]**
- **If a glow's flicker or any ambient pulse could trouble photosensitive players**: no ambient element changes brightness more than `glow_flicker` amplitude 0.2 or faster than 3 times a second; the preset check rejects faster or stronger flicker. The heavy attack's strobing blade is Combat's, not this system's. **[Rec]**

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
| Terrain pipeline | Hard | The play layer at draw order 0 and rule 5 (nothing imitates it); the cobbled lip, which it owns and draws in front of the Seeker (owner, 2026-11-20); the floor runs and their headroom, read from the collision (rule 6); props marked as carrying light, with a glow radius, in the prop catalogue (rule 11; terrain Open Question 6). **Needs** (Open Question 1): to adopt the lip as its trim, and the floor-run and catalogue fields | Yes, In Review: sixth review MAJOR REVISION NEEDED (`design/gdd/terrain-pipeline.md`); interface provisional |
| Rooms and transitions | Hard | The current room's biome and bounds; the build while dark and the freeze (its rules 9, 12); the room data that holds this system's overrides (rule 3: fog scales, glow spots, sections, room-end pieces, bands off). **Needs** (Open Question 2): those fields in the room data, and two room-check items (blend zones that overlap; a room-end piece on a bound with an exit) | Yes, Approved (`design/gdd/rooms-and-transitions.md`) |
| Camera | Hard | The follow centre each frame after it moves, without shake (rule 2); the shake offset and the largest shake (rule 17, P2); the snap on arrival (rule 15); a fixed zoom | No GDD (`src/player/player_camera.gd`); zoom and display are terrain Open Question 9's |
| Level design | Soft | Which rooms have sections, glow spots and room-end pieces; the Readability rule this system shares (rule 13) | Yes, Approved (`design/gdd/level-design.md`) |
| Player controller | Soft | The Seeker's position, for the light, bloom and radiance (rule 12) | No (`src/player/player.gd`) |
| Ability gating | Soft | The gate and `no_cling` signatures no ambient element may reproduce (rule 13) | Yes, Approved (`design/gdd/ability-gating.md`) |
| Art bible | Soft | Each biome preset's look (palette, fog colours, grade); the region 1 Cooling Yards palette against the Cinderheart reference | No (not yet written) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Pause and menus | Soft | The Atmosphere option, Full or Reduced, and what each does (rule 14); menus drawn above the grade |
| Level design | Soft | Section rules and the blend spacing (rule 8, Edge Cases); the preset override list (rule 3); the value check (P4) for the rooms it lays out |
| Combat and Enemies | Soft | A projectile at least twice an ember's size and never ember-coloured without an outline or a trail (Edge Cases); hit effects on the play layer bloom only near the Seeker (Interactions) |
| Grid map | Soft | Nothing; the map is drawn above the grade, ungraded, and freezes the world (rule 16) |

**Bidirectional check:**

- Terrain pipeline lists this system in its Interactions ("Which layer is the play layer and its draw order ... the rule that other layers never imitate it") and as a hard downstream in its Dependencies. Match. It does not yet say it owns the cobbled lip (the reference scene's "middle rim"), the floor runs or the light-carrying flag; Open Question 1.
- Rooms and transitions lists this system in its Interactions ("The current room's biome and bounds, so layers are placed per room"). Match. The room-data fields and room-check items are new; Open Question 2.
- Level design says the look "is owned by the terrain pipeline and the parallax, lighting and atmosphere systems" and states the Readability rule this GDD uses (rule 13). Match; it should name sections and glow spots when it next revises (Open Question 2).
- The systems index row lists Terrain pipeline, Camera and Rooms and transitions. Match; Level design, Ability gating, the Player controller and the art bible are soft and need no index change.
- Ability gating's signatures (its rules 10, 14) are read, not changed. It does not need to list this system.
- Camera, Player controller, Pause and menus, Combat, Enemies and the art bible have no GDD yet. Each needs a matching entry when it is written.

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. No art bible exists yet (`design/art/art-bible.md`); this section is drafted from the owner's reference scene and the region 1 visual direction (`design/narrative/kiln-city-visual-direction.md`), and the art bible owns every look named here.

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
- **The Seeker is the light.** A soft light, bloom and radiance follow the pale Seeker, so wherever it goes it is the clearest thing on screen and the room seems to brighten around it. **[Ref]**
- **Calm, not busy.** Fog drifts slowly, embers rise and dust floats; nothing ambient pulses fast, flashes or crosses the play space quickly, so a fight's motion always stands out against it. **[Rec]**
- **Comfort.** The Reduced setting keeps the depth and the light and drops the blur, particles, bloom and sway, for slower machines and players who find haze or motion tiring (rule 14). **[Owner, 2026-11-20]**
- **Playtest question:** whether the silhouette band's sway after a big jump reads as near foliage brushing past, or as the screen wobbling.

## UI Requirements

- **In play: nothing.** This system adds no HUD element; the HUD and every menu draw above the grade, ungraded (rule 12). **[Rec]**
- **Options:** an **Atmosphere** option, **Full** (default) or **Reduced**, with one line saying what Reduced does ("Less haze, no particles or glow blur: for slower machines or motion comfort"). It applies at once, with no restart (rule 14). The screen is Pause and menus'. **[Owner, 2026-11-20: Full / Reduced]**

> **📌 UX Flag — Parallax, lighting and atmosphere**: This system adds one option to the options screen. In Phase 4 (Pre-Production), include it when `/ux-design` specifies the options screen (Pause and menus) **before** writing epics. Stories that reference it should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| The play layer at draw order 0; other layers never imitate it (rule 5); draw order of the biome packs; painted filtering; one biome per room (rule 14); the prop catalogue (Open Question 6); display migration and camera zoom (Open Question 9) | Terrain pipeline | `design/gdd/terrain-pipeline.md`, In Review (MAJOR REVISION NEEDED) |
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
- **GIVEN** the reference room built from the Cinderheart preset, **WHEN** its scene is inspected, **THEN** every band exists with the draw order of rule 1's table, no node this system adds is at 0 (only the play layer's and the Seeker's), the Seeker draws in front of the play layer's fill and dressing, the lip's nodes sit at 4-6 above the Seeker, and nothing else is above the Seeker but the glows (1), ground fog (7), embers (8), foreground strips and silhouette band (10+); no node this system adds has a collision shape or is in a physics layer. **[Auto, engine]** (rules 1, 13)
- **GIVEN** the camera moved 100 px right and 40 px down in one frame, **WHEN** that frame is drawn, **THEN** on screen the far layer moved 15 and 6 px the other way, the mid layer 50 and 20, the close band 85 sideways and 40 vertically (it stays on its floor), the foreground strips 120 and 44, the play layer 100 and 40, all on that same frame. **[Auto, engine]** (rule 2, P1)
- **GIVEN** a room with no overrides and a room overriding the far fog's density to 1.5 and adding a glow spot, **WHEN** both are built, **THEN** the first matches the preset exactly and the second differs only in those two fields. **GIVEN** a room overriding the mid layer's factor, **WHEN** the room check runs, **THEN** it is rejected and the field named. **[Auto]** (rule 3, Edge Cases)

**Cover and edges**
- **GIVEN** the reference room (2520 x 360) and a test room 20 screens wide, **WHEN** P2 runs for the far layer, **THEN** it returns scale 1.65 and 3.86; **GIVEN** a one-screen room, **THEN** cover = 486 x 276 (the view plus twice the 3 px shake). **[Auto]** (P2)
- **GIVEN** the reference room, its 10-screen long room and a 5 x 1 screen room with two sections at x 0-1200 and 1200-2400, **WHEN** the camera sweeps every edge of its travel, and each section's travel range (rule 8), with a 3 px shake at each corner, **THEN** on every frame each band's rectangle (P1, P2) contains the view: no band edge and no clear colour in view. **[Auto]** for the rectangles; **[Auto, render]** for one swept frame per corner, checking no pixel of the clear colour (`0.08, 0.05, 0.06`) shows outside the play layer (rules 4, 17, Edge Cases)
- **GIVEN** that 5 x 1 screen room, **WHEN** P1 and P2 run for the far layer (f 0.15) of each section, **THEN** the travel ranges are [240, 1236] and [1164, 2160] (A 738 and 1662, T 996), the scale is 1.32, and at c = 1236 the first section's band spans exactly to 1479.0. **GIVEN** a section whose range is empty after the cut, **THEN** the room check rejects it. **[Auto]** (rule 8, P1, P2)
- **GIVEN** a room two screens tall, **WHEN** the camera is at its highest, **THEN** the top strip's canvas top is at screen y 0 and the bottom strip's at 297 (off screen); at its lowest, 0 for the bottom strip. **GIVEN** a one-screen room, **THEN** both are at 0 wherever the camera is. **[Auto]** (rule 5, P3)
- **GIVEN** a room-end piece on a left bound that holds an exit, **WHEN** the room check runs, **THEN** it is rejected and named. **[Auto]** (rule 5, Edge Cases)

**Close band, silhouettes and sections**
- **GIVEN** floor runs 100 px and 108 px wide and a run whose headroom gives a band under 12 px, **WHEN** the room is built, **THEN** only the 108 px run has a close band; **GIVEN** a run that ends at a drop, **THEN** the band's end is at least `close_edge_inset` in from the drop; **WHEN** the camera moves 50 px vertically, **THEN** each stretch's bottom stays at its floor line plus `close_sink`. **[Auto, engine]** (rule 6, Edge Cases)
- **GIVEN** the silhouette band at rest, **THEN** its art's top is at or below 0.53 of the screen height. **GIVEN** a 30 px camera rise in one frame, **THEN** the band drifts 36 px down, and 0.45 s of world time later it is 13 px (within 1 px) from rest. **GIVEN** a 200 px rise, **THEN** the drift is 40 px. **GIVEN** `tau` 0 in a preset, **THEN** the preset check rejects it. **[Auto]** (rule 7, P6)
- **GIVEN** a room with a corridor section and the camera's centre moving through its edge, **WHEN** it is 36 px before the edge, at the edge and 36 px past it (`layer_blend` 72, centred on the edge), **THEN** the corridor set's weight is 0, 0.5 and 1; **WHEN** the camera stops at the edge and turns back, **THEN** the weight follows its position back down with no jump. **GIVEN** two sections whose blend zones overlap, **WHEN** the room check runs, **THEN** it is rejected and named. **[Auto]** (rule 8, Edge Cases)

**Atmosphere, light and grade**
- **GIVEN** the ground fog with room scale 1, Full, at the screen's bottom with noise at its peak, **THEN** its alpha is 0.3; in Reduced, 0.15. **GIVEN** a ground fog override of 1.5, **WHEN** the room check runs, **THEN** it is rejected; a far fog override of 2 passes. **GIVEN** a preset whose ground fog has `a x density` 0.35, **WHEN** the preset check runs, **THEN** it is rejected and the field named; at 0.3 it passes. **[Auto]** (rule 9, P5)
- **GIVEN** a room just built, **WHEN** the first frame of its fade-in is drawn, **THEN** the live dust and ember counts are each at least 90% of their preset counts, and the bands are placed for the arrival camera; no node of the previous room's bands remains. **[Auto, engine]** (rules 10, 15)
- **GIVEN** a prop the catalogue marks as carrying light, **WHEN** the room is built, **THEN** it has a glow of its listed radius; **GIVEN** the room's scene, **THEN** it holds no `PointLight2D`, `DirectionalLight2D` or `LightOccluder2D`. **GIVEN** a preset with glow flicker amplitude 0.3 or a rate above 3 per second, **THEN** the preset check rejects it. **[Auto, engine]** for the scene, **[Auto]** for the check (rule 11, Edge Cases)
- **GIVEN** the same frame of the reference room drawn with the grade on and with it off, **WHEN** both are read, **THEN** the HUD help text's fully opaque pixels are identical in both: the grade never touches the HUD or a menu. **[Auto, render]** (rule 12)
- **GIVEN** the reference room, mood on, **WHEN** a screenshot is taken at the start, over the pit, in the corridor and with the Seeker in a corner of the room, **THEN** each is retained and signed off by the owner as matching the reference look, and the Seeker and the floor edges are the clearest things in each. **[Visual]** (rules 1, 12, 13)

**Readability and setting**
- **GIVEN** each of the four frames above, **WHEN** P4 runs with the play layer, props, glows and Seeker masked, **THEN** the value margin is reported; a margin under 0.10 is logged as a warning naming the frame, and it does not fail the build. **GIVEN** a fixture frame whose back pixels are brighter than its floor edge, **THEN** the margin is negative and the warning names it. **[Auto, render]** for the report, **[Auto]** for the fixture (rule 13, P4)
- **GIVEN** the Atmosphere option set to Reduced, **WHEN** the next frame is drawn, **THEN** the blur, dust, embers, bloom and radiance are not drawn, the silhouette band sits at rest, each fog's alpha is half, and every band's position equals its position in Full for the same camera. **WHEN** it is set back to Full, **THEN** dust and embers are at steady density on that frame. **[Auto, engine]** (rule 14, Edge Cases)
- **GIVEN** the pause menu opened for 3 s, **WHEN** it closes, **THEN** every particle, fog offset, glow phase and the silhouette drift are where they were when it opened. **[Auto, engine]** (rule 16)
- **GIVEN** a death into another biome's room (cross-system: rooms and transitions R5), **WHEN** it is built, **THEN** its bands use that biome's preset and no art from the first biome is drawn. **[Auto, engine]** (rule 3, Edge Cases)

**Performance and feel**
- **GIVEN** the reference room and the long room, mood on, **WHEN** the art-room bench sweeps them, **THEN** draw calls per frame stay under the 500 budget (`technical-preferences.md`) and the bench reports the pass's frame-time cost, Full against Reduced. **[Auto, render]** (performance; the target-hardware budget is Open Question 4)
- **GIVEN** 5 playtesters in region 1's first rooms, **WHEN** asked after the session, **THEN** none says they tried to stand on, or grapple to, something in the background or foreground, and at least 4 call the look "deep" or "atmospheric" unprompted or when asked to describe it. **[Play]** (Overview, rule 13)
- **GIVEN** the preset check with a negative factor, a missing art file, a fog with `y0 = y1` or an out-of-range override, **WHEN** a biome's preset loads at boot, **THEN** the title screen does not show and every bad value and file is named. **[Auto]** (Edge Cases)

**Gaps found by the QA lens:**
- Rule 12's grade is judged by eye; only its effect on the HUD and the value margin are automated. Visual fidelity is not automated, by the coding standards.
- P4 needs masks (the play layer, props, glows and Seeker drawn as flat ids in a second pass); the method belongs with the test helpers, not this GDD.
- The frame-time budget on target hardware has no number: the target platform and its GPU are not set (`technical-preferences.md`), and the container renders in software.
- The sections, room-end and blend room checks are requirements on Rooms and transitions (Open Question 2); their criteria pass only once those checks exist.

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **Terrain pipeline changes.** It is In Review and does not yet hold what this GDD reads from it. Wording it needs: "the cobbled lip (the reference scene's middle rim, the modular foreground tiles tracing every exposed edge, set a few px inside the solid) is the terrain's trim, drawn at order 4-6 in front of the Seeker, which draws at 0 in front of the play layer's fill and dressing" (owner, 2026-11-20; draw order added at the first design review); "the pipeline reports each straight floor run, its width and the headroom above it" (rule 6); "the prop catalogue marks a prop as carrying light, with a glow radius" (rule 11, its Open Question 6). Owner: terrain pipeline (its revision). Target: its next revision.
2. **Rooms and transitions and level design.** The room data needs this system's override fields (fog density scales, glow spots, sections with their back sets, room-end pieces, close band and silhouette band off, rule 3) and the room check two items (blend zones that overlap; a room-end piece on a bound with an exit). Level design names sections and glow spots among what it lays out. Owner: rooms and transitions, level design. Target: before the first story that builds a room with this look.
3. **Implementation ADR.** How the bands are placed (the engine's `Parallax2D`, which misplaced layers under the 4x zoom in the reference, or manual placement as the reference does), how the grade and fog are drawn, and the preset resource's format. **NOT SOURCEABLE:** 2D canvas screen-reading shaders (`hint_screen_texture`) and their 4.5-4.7 behaviour are not covered by `docs/engine-reference/godot/modules/rendering.md`, whose post-processing pattern (`Compositor`) is for 3D (`WorldEnvironment`, `Camera3D`). The reference runs on Godot 4.7.2 (owner, 2026-11-20), which `docs/engine-reference/godot/VERSION.md` still lists as not determined. Owner: technical director (`/architecture-decision`), with terrain Open Question 9 (display and zoom). Target: before the first story.
4. **Frame-time budget.** The target platform and its GPU are not set (`technical-preferences.md`), so the pass has no millisecond budget; the container renders in software, so its numbers only compare Full with Reduced. Owner: technical director. Target: before Vertical Slice.
5. **Region 1's look.** The reference preset is Cinderheart Caldera; region 1's lore (the Cooling Yards) asks for soot-umber ground, dim amber light from below and kiln silhouettes. Whether region 1 uses a Cinderheart preset or its own art, and how the painted reference meets the lore's pixel-art target, is the art bible's (level design Open Question 17). Owner: art director. Target: the art bible.
6. **The other five presets.** Each biome pack needs its preset (bands, fog colours, particles, glow colour, grade) tuned by eye like the reference. Owner: art, level design. Target: when each biome's first room is built.
7. **Accessibility.** Reduced covers haze and motion; whether players also need a separate screen-shake switch (the Camera's) or a higher-contrast option belongs in the project's accessibility requirements (`design/accessibility-requirements.md`, not yet written). Owner: UX. Target: `/ux-design` accessibility.
