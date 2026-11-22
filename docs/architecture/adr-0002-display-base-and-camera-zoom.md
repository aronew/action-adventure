# ADR-0002: Display base 1920 x 1080 with the camera at zoom 4

## Status
Accepted

## Date
2026-11-22

## Last Verified
2026-11-22 (spike and specialist probes run in this container on Godot 4.7.2 under a virtual display with the `gl_compatibility` renderer; the project uses `forward_plus`, and the owner's local editor version was not checked)

## Decision Makers
Project owner (chose fractional scaling, 2026-11-22); Claude (author); `godot-specialist` (validation, 2026-11-22: no blocking findings; its minor findings are folded in).

## Summary
`project.godot` still holds a 480 x 270 viewport stretch while the painted art, HUD and menus want 1920 x 1080, and only the art-style test room switches at runtime. Decision: the project's base resolution becomes 1920 x 1080 with `canvas_items` stretch, `keep` aspect and `fractional` scaling, and the camera zooms 4x so one screen stays 480 x 270 world px; the camera script owns the zoom.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Rendering (2D), Core (window and stretch settings), UI |
| **Layer** | Foundation |
| **Knowledge Risk** | HIGH (post-cutoff version; the reference sources only that 4.7 changed the stretch defaults for NEW projects to `canvas_items` and `expand`, existing projects keeping theirs) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/rendering.md`, `modules/ui.md`, `breaking-changes.md`, `current-best-practices.md` |
| **Post-Cutoff APIs Used** | None. `Window.content_scale_*` and `Camera2D.zoom` are pre-4.3 |
| **Verification Required** | The stretch, zoom and snapping behaviour claimed here rests on the spike, the specialist's probes and the art-style room, not the reference (NOT SOURCEABLE). Re-run the pixel and font probes under `forward_plus` (they ran under `gl_compatibility`), and check HiDPI, `window_*_override` and the letterbox colour on real hardware. Re-run after any engine upgrade |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | Pause and menus' display options (its F1); the parallax implementation ADR (placement under zoom 4); the HUD |
| **Blocks** | The first terrain story (terrain GDD rule 1 criterion, "the window renders at 1920 x 1080 with the camera at zoom 4") |
| **Ordering Note** | Independent of ADR-0001. The camera zoom scales the view only; collision stays 6 px and unscaled |

## Context

### Problem Statement
Every GDD states lengths in game px: a screen is 480 x 270 and the Seeker is 10 x 22. The painted art is drawn 4x larger, at 1920 x 1080, and is scaled to the game, never the game to the art (terrain rule 1). The project settings still say 480 x 270 with `viewport` stretch and integer scaling, which renders the whole world into a 480 x 270 buffer and upscales it; painted art would be downsampled to a quarter of its resolution. Only the art-style room works around it with a runtime content-scale override and `Camera2D.zoom = 4`. The terrain, rooms, parallax and pause GDDs all wait on the decision.

### Constraints
- World units stay game px (480 x 270 per screen, 80 x 45 collision tiles per screen).
- The project's default texture filter is nearest (`textures/canvas_textures/default_texture_filter=0`). The Seeker's pixel-art variant (`painted = false`) uses nearest; the painted Seeker (`painted = true`, the current default) and painted terrain set `LINEAR_WITH_MIPMAPS` explicitly on their nodes.
- Pause and menus offers whole-number game-pixel scales (2x, 3x default, 4x).
- The camera is the player's `Camera2D` (`player_camera.gd`), with smoothing, look-ahead, shake and limits.
- HUD and menus draw in `CanvasLayer`s.

### Requirements
- A 16:9 window shows exactly one 480 x 270 screen of world at any size.
- Painted art renders at the window's resolution, not a downsampled buffer.
- Whole-number game-pixel scales give the Seeker's pixel art a whole-number screen scale.
- One place owns the zoom.

## Decision

1. **Project settings.** `display/window/size/viewport_width` 1920 and `viewport_height` 1080; `display/window/stretch/mode` `canvas_items`; `aspect` `keep`; `scale_mode` `fractional`. The default window stays 1440 x 810 (`window_width_override` / `window_height_override`), the 3x default Pause and menus names. Also `rendering/2d/snap/snap_2d_transforms_to_pixel` and `snap_2d_vertices_to_pixel` on **[Rec]**: without them a sprite at a fractional game-pixel position wobbles by one screen pixel per texel even at a whole-number scale (stripes of 4, 3, 3, 3, 2 screen px at 3x), and at a fractional scale a 2 px stripe moves frame to frame. With them the 3x pattern is uniform and the fractional pattern stable (specialist probes). Snapping is in window pixels, so painted art and slow parallax layers step in whole window pixels, which is invisible from 3x up.
2. **The camera owns the zoom, and derives it.** `PlayerCamera` sets `zoom` in `setup()` (where it already reads its target's config; `_ready()` runs before the config exists) to the base canvas height divided by the game screen height: `1080 / 270 = 4`. It is derived, not a tunable, because the art-style room, the grade shader's `view_size` and every GDD length assume one screen is 480 x 270 game px; a mismatch is a `push_error`. The zoom is fixed during play. No other node sets a camera zoom or a content scale. The art-style room's runtime content-scale override is removed.
3. **World units stay game px.** Collision, gate figures, room bounds and every GDD length are unchanged; nothing in the world is scaled by 4.
4. **UI is authored on the 1920 x 1080 canvas.** HUD and menus live in `CanvasLayer`s, which the camera does not move or zoom (specialist probe), with positions and font sizes in 1920 x 1080 canvas px (the base). The existing test-room debug HUDs (8 px labels placed for a 480 x 270 canvas) get their positions and font sizes multiplied by 4 at layer scale 1, as the art-style room already does (22 px). A `CanvasLayer.scale` of 4 also works but rasterises the 8 px text and magnifies it: blocky at 1920, badly mangled at fractional scales, while larger fonts stay crisp under the stretch's oversampling.
5. **Fractional scaling for any other window size**, as chosen. Windows that are whole multiples of 480 x 270 (960 x 540, 1440 x 810, 1920 x 1080, 2400 x 1350) give whole-number screen scales for the Seeker's pixel-art variant; other sizes scale fractionally and the pixel art is slightly uneven, painted art unaffected (at 1366 x 768 the x and y scales differ in the sixth decimal and a one-pixel bar appears; inherent to fractional scaling).
6. **Parallax placement stays manual** per frame from the camera's final position, as the art-style room does. `Parallax2D` misplaced layers under zoom 4 there; the specialist diagnosed it: it computes its screen offset from half the base viewport (960 px), not the zoomed view (120 world px), giving a constant offset (the layer scrolls at the right rate and sits in the wrong place). A constant `scroll_offset` correction may exist and is untested. The rest of that decision belongs to the parallax implementation ADR.
7. **Bars, not stretch, for other aspect ratios.** `keep` letterboxes any window that is not 16:9 (a 1600 x 1000 window gets 50 px bars top and bottom and the world view stays exactly 480 x 270); no band draws into the bars. Whether the bars take the project's clear colour (the art-style room sets a dark red-brown) or black is not verified and is checked on real hardware.

### Architecture Diagram
```
project.godot: base 1920 x 1080, canvas_items, keep, fractional
        |
   Window (any size) --> total scale s = window / 1920 (fit)
        |
   World canvas: Camera2D zoom 4  -> 480 x 270 world px fill the base      (PlayerCamera owns zoom)
   UI canvases : CanvasLayer, 1920 x 1080 canvas px, not zoomed             (HUD, menus)
   Collision, gate figures, room bounds: game px, never scaled
```

### Key Interfaces
```gdscript
# PlayerCamera (Camera2D): zoom is derived from the base canvas, not configured.
const GAME_SCREEN_HEIGHT := 270.0

func setup(target: Player) -> void:
    var base_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
    var z := base_height / GAME_SCREEN_HEIGHT           # 4 at a 1080 base
    zoom = Vector2(z, z)
    # ... existing setup that reads target.config
```

### Implementation Guidelines
- The base resolution and stretch settings **must** live in `project.godot` only; no script **may** set `content_scale_size`, `content_scale_mode` or `content_scale_stretch`.
- Only `PlayerCamera` **may** set a camera's `zoom`, in `setup()`, derived from the base height; zoom **must not** change during play and **must never** be a tunable.
- World nodes **must** be authored in game px and **must never** be scaled to match the display.
- UI **must** be authored in 1920 x 1080 canvas px in a `CanvasLayer` at scale 1; it **must never** read or compensate for the camera zoom, and **must never** magnify small fonts with a layer scale.
- Painted art nodes **must** set their texture filter explicitly (`LINEAR_WITH_MIPMAPS`); the project default stays nearest.
- The two 2D snap settings **must** stay on unless a later ADR replaces them.
- Camera limits, shake and look-ahead **must** stay in game px (world units); check shake and offsets under zoom before shipping a change.
- Window size options **must** be whole multiples of 480 x 270 unless the player resizes freely.

## Alternatives Considered

### Alternative 1: Keep the 480 x 270 viewport stretch
- **Description**: leave `viewport` stretch, integer scaling.
- **Pros**: crisp pixel art at integer scales; no migration.
- **Cons**: the painted terrain, Seeker art (painted version) and parallax layers are downsampled to a quarter of their resolution; the HUD and menus are limited to a 480 x 270 grid.
- **Rejection Reason**: it defeats the painted look the project is built around.

### Alternative 2: 1920 x 1080 base and scale the world nodes by 4
- **Description**: base resolution as chosen, but with no camera zoom: scale the world root node or each layer by 4.
- **Pros**: no zoom in the camera.
- **Cons**: every position, collision shape and physics value would be 4x unless the scale is on a parent only, which then misleads the physics server and breaks the "collision stays 6 px" guarantee; camera limits, parallax and shake all need conversions.
- **Rejection Reason**: collision and GDD lengths must stay game px; a camera zoom does that without scaling nodes.

### Alternative 3: Integer scale only
- **Description**: as chosen but `scale_mode` `integer`.
- **Pros**: pixel art always crisp.
- **Cons**: a window smaller than the base stays at scale 1 and crops the canvas (1440 x 810 would show only 360 x 202 world px, 960 x 540 only 240 x 135), and larger windows get bars at in-between sizes.
- **Rejection Reason**: owner chose fractional; Pause and menus' whole-number options already give crisp scales.

## Consequences

### Positive
- Painted art renders at full resolution; one source of truth for the zoom.
- GDD lengths, collision and room bounds are unaffected.
- UI authors work on a plain 1920 x 1080 canvas.

### Negative
- Test-room debug HUDs need their positions and font sizes multiplied by 4 until replaced.
- At non-whole window scales the pixel-art Seeker is slightly uneven even with snapping.
- Snapping steps painted art and slow parallax layers in whole window pixels.
- Fill rate: the world renders at window resolution, so the full-screen grade, blur and fog passes scale with window pixels (a 480 x 270 buffer is gone, the cost moved).
- Anything that assumed a 480 x 270 canvas (the grade shader's view size is already in world px, and its screen ratios survive) must be rechecked.

## Risks
- **Pixel-art shimmer.** Snapping (Decision 1) fixed the probes, but only for a nearest-filtered 10 x 22 stripe sprite under `gl_compatibility`; rotated or scaled sprites were not tested. The painted Seeker (the current default) uses mipmapped filtering and is less exposed. Mitigation: check both Seeker variants in play at 1440 x 810 and at a fractional size under `forward_plus`.
- **Camera jitter from the update split.** Camera smoothing runs in `_process` while the Seeker moves in `_physics_process`, and no physics interpolation setting exists; a separate jitter source from sub-pixel snapping, not probed. Mitigation: check in play; decide interpolation in the camera's own design.
- **Camera shake and offset under zoom.** `offset` is in world px (specialist probe: an offset of 3 moved the marker 12 base-canvas px, 3 game px), so a 3 px shake reads as 3 game px and parallax cover holds. Mitigation: a test in world or base units, not window pixels.
- **GPU fill rate.** The grade and blur passes scale with window pixels. Mitigation: run the art-room bench at 2560 x 1440 before this ADR is Accepted; the target GPU is not set (parallax Open Question 4).
- **Unverified on hardware.** HiDPI (`allow_hidpi`), `window_*_override` and the letterbox colour could not be tested here; the pixel and font probes ran under `gl_compatibility` only. Mitigation: re-run under `forward_plus` and on the owner's machine.
- **`Parallax2D` offset.** Diagnosed above, workaround untested. Mitigation: manual placement.
- **Behaviour not in the reference.** Stretch, zoom and snapping behaviour rests on probes and one test room. Mitigation: the spike is kept and re-run after engine upgrades.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| terrain-pipeline.md | Rule 1, Open Question 9: window renders 1920 x 1080 with the camera at zoom 4, 480 x 270 game px fill the screen | The base resolution and the camera zoom |
| rooms-and-transitions.md | R4: camera bounds in game px hold at any display scale | World units and camera limits stay game px |
| pause-and-menus.md | F1: whole-number display scales, 3x default | Windows at whole multiples of 480 x 270 give whole-number scales; 1440 x 810 default |
| parallax-lighting-and-atmosphere.md | Rule 2, Open Question 3: placement under the 4x zoom | Manual placement from the camera's final position; the rest is its own ADR |

## Performance Implications
- **CPU**: none beyond the existing manual parallax placement.
- **GPU**: the world and the full-screen grade, blur and fog passes render at window resolution, so fill rate scales with window pixels (no 480 x 270 buffer any more); not yet measured at 2560 x 1440.
- **Memory**: no 480 x 270 render buffer; the world renders at the window's resolution.
- **Load Time**: none.
- **Network**: not applicable.

## Migration Plan
1. Change the settings in `project.godot`: base 1920 x 1080, `canvas_items`, `keep`, `fractional`, and the two 2D snap settings; keep the 1440 x 810 default window.
2. Set the zoom in `PlayerCamera.setup()`, derived from the base height; the attached cameras in `boss_arena.gd`, `enemy_test_room.gd`, `movement_test_room.gd` and `gate_test_rooms.gd` get it by using `PlayerCamera`.
3. Remove the runtime content-scale override (`art_style_test_room.gd`, `_ready`) and its camera-zoom code; keep its clear-colour call.
4. Multiply the positions and font sizes of each test room's debug HUD `CanvasLayer` by 4 (`boss_arena.gd`, `enemy_test_room.gd`, `gate_test_rooms.gd`, `movement_test_room.gd`); the art-style room's HUD is already at 22 px.
5. Check the existing rooms and both Seeker variants in play at 1920 x 1080, 1440 x 810 and a fractional size; capture screenshots.

**Done 2026-11-22.** Steps 1-4 are applied: the settings and snap settings in `project.godot`, the derived zoom in `PlayerCamera.setup()`, the art-style room's runtime override removed, and the four test-room debug HUDs scaled through `src/test_rooms/debug_hud.gd` (`DebugHud.SCALE` 4, `DebugHud.FONT_SIZE` 32) at CanvasLayer scale 1. Step 5 is partly done: screenshots of all five rooms at 1920 x 1080 and 1440 x 810 are in `production/qa/evidence/display-migration/` (`gl_compatibility` under a virtual display; the Seeker and shimmer checks at a fractional size under `forward_plus` are still open). `tests/integration/display/framing.gd` asserts the framing (watched to fail on the old 480 x 270 settings). The art-style ledge, corner and wall-slide runs still pass.

## Validation Criteria
- A 16:9 window at 1920, 1440, 960 and 2560 wide shows exactly 480 x 270 world px (the spike; repeated in the test suite).
- The terrain GDD's display criterion: the window renders at 1920 x 1080 with the camera at zoom 4, and the Seeker's collision box measures 10 x 22 game px.
- A 3 px camera shake displaces the picture by 3 game px, which is 12 base-canvas px at any window size (12 window px only at 1920).
- At 1440 x 810 a nearest-filtered stripe sprite at fractional positions shows a uniform 3 px stripe with snapping on.
- The art-room bench at 2560 x 1440 stays within the 500 draw-call budget and records frame time (target GPU not set).
- Screenshots of the existing rooms before and after the migration show the same world framing.

## Open verification items at acceptance
Accepted 2026-11-22 by the project owner, after the migration was built and its framing test passed, before these ran:
- The Seeker (both the painted and the pixel-art variant) and the snap settings in play at 1440 x 810 and a fractional size under `forward_plus`; the probes so far ran under `gl_compatibility`.
- The art-room bench at 2560 x 1440 against the 500 draw-call budget, with frame time recorded.
- HiDPI, `window_*_override` and the letterbox colour on the owner's machine.
- Camera smoothing in `_process` against the Seeker's physics motion (jitter), and a 3 px shake measured as 12 base-canvas px.
- The follow-up edits to Pause and menus F1 and terrain Open Question 9, which still say 480 x 270.

## Related
- `design/gdd/terrain-pipeline.md` (rule 1, Open Question 9)
- `design/gdd/rooms-and-transitions.md` (R4)
- `design/gdd/pause-and-menus.md` (F1)
- `design/gdd/parallax-lighting-and-atmosphere.md` (rule 2, rule 17, Open Question 3)
- ADR-0001 (terrain collision): collision stays 6 px and unscaled
- Spike (Godot 4.7.2, this container, xvfb, `gl_compatibility`): base 1920 x 1080, `canvas_items`, `keep`, `fractional`, `Camera2D.zoom` 4: total scale 4.0 at a 1920 x 1080 window, 3.0 at 1440 x 810, 2.0 at 960 x 540, 5.33 at 2560 x 1440, and 2.84 at 1366 x 768; 480 x 270 world px across the window at every 16:9 size. The specialist re-ran these and added: `get_visible_rect()` stays 1920 x 1080; a 1600 x 1000 window gets 50 px bars; `Camera2D.offset` is in world px; limits and `limit_smoothed` work in world px; a `CanvasLayer` ignores camera zoom; the snap settings fix the stripe wobble; `Parallax2D` uses half the base viewport for its offset; `integer` scale crops windows smaller than the base
