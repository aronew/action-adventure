# Systems Index: Guardbreak (provisional title)

> **Status**: Draft (approved by the project owner 2026-11-18; director gates skipped, review mode lean)
> **Created**: 2026-11-18
> **Last Updated**: 2026-11-19
> **Source Concept**: design/game-brief.md (no game-concept.md; the brief is the design record up to this point)
> **Research**: design/research/metroidvania-world-design.md and research_notes/Metroidvania world design research/

---

## Overview

Guardbreak is a 2D side-scrolling metroidvania built around one move set that does two jobs: it carries the Seeker through a connected, ability-gated world and it breaks the guards of bosses and mini-bosses (normal enemies have health only). The core loop is fight, gain a verb, use it to open the world, then fight again. Stories 001-006 built the foundation: movement, melee, guard-break, three enemy types, one boss and two gated abilities. What remains is the world around them: rooms, doors, saves and a map; the terrain and presentation stack that makes it look natural and lived in; and the level design that makes exploration and curiosity the point.

Notes by area (balanced density):

- **Core**: the controller, camera, rooms and terrain pipeline are the load-bearing systems. Rooms and transitions are the next bottleneck: nothing about the world can be placed until a room is a defined unit with exits, camera limits and an owner for its state.
- **Combat and bosses**: built and tuned. Guard-break applies to bosses and mini-bosses only (owner's rule). Mini-boss support is inferred and not built.
- **Ability gating and level design**: these two depend on each other. The gating GDD owns gate types, dimensions (measured against the Seeker's reach) and their visual language. Level design owns where gates sit, the order abilities arrive in and what each key unlocks. Owner's rules apply to both: abilities come from bosses, found places or a mentor, never in front of their own gate; a gate is seen first and returned to; no "region cleared" screen.
- **World state and saves**: one record of what the player owns and has done (abilities, bosses beaten, shortcuts opened, secrets found), written the moment it changes; save points set the respawn point.
- **Presentation**: the look is a stated goal. Collision is plain black-box geometry with tiles painted on top; parallax, vignette and light give depth. Godot 4.7 is HIGH risk, so this is prototyped early.
- **Later**: bow, spells, elemental palettes and the Dream Seeker state come after the core feels good. Fast travel waits for more than one region.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Player controller and input | Core | MVP | Implemented (no GDD) | — (brief) | — |
| 2 | Camera | Core | MVP | Implemented (follow, look-ahead, shake); room framing not started | — (brief) | Player controller |
| 3 | Rooms and transitions (inferred) | Core | MVP | Approved (fifth design review 2026-11-19, lean: APPROVED, 0 blockers; the exit lip holds against player.gd; 13 recommended revisions open (4 new: box centre vs the feet origin, unreachable corner tie, door `interact` action and ENTER_DOOR invulnerability as a controller need, shut-line landing refreshes air moves; 9 carried from the fourth review). Fourth design review 2026-11-19, lean: NEEDS REVISION, 1 blocker revised (the minimal overhang made the crossing frame hit solid, so a dash ended, a fall exit refilled the air moves and a jump lost its upward speed; owner: exit lip one frame of travel deeper, 12 px side and 24 px fall/rise, carved by the room build; carried state re-derived from contact; invulnerable and input locked during EnterDoor, 2.07 s door trip); 16 recommended revisions (7 fixed this session, 9 open: retired-id records, corner tie, perpendicular shut openings, residency cancel path and three-biome wording, arrival safety, graph edge attributes, camera zone ACs and R5 save-point arrivals, Tuning Knobs, compound ACs; plus registry referenced_by and terrain naming the lip). Third design review 2026-11-19, lean: NEEDS REVISION, 2 blockers revised (owner: exit overhang beyond the bounds per axis, 6 px side and 12 px fall/rise, so the centre-at-the-line crossing can fire; the transition-freeze AC scoped around the swap); prior blockers held; 14 recommended revisions open (11 carried, 3 new: AC holds build_time, R2 range and EnterDoor 1.62 s timing, same-room door rebuild). Second design review 2026-11-19, lean: NEEDS REVISION, 2 blockers revised (owner: apron reaches the arrived box's far edge, per axis, 18 px side and 24 px fall/rise; two ACs scoped to the fade-in); prior 4 blockers held; 7 recommended revisions open (retired-id records, corner tie, shut openings in the fade-in, carried-over residency/arrival safety/graph/camera/death-state items, R5 save-point arrivals, stale World state line, Tuning Knobs). First design review 2026-11-19, lean: NEEDS REVISION, 4 blockers revised (owner: freeze the world at the crossing frame, arrive `exit_rearm` px inside, openings shut until the fade-in ends; `build_time` in R3, budget 0.10 s, 0.45 s total; authored object ids, unique per room; R5 bounds falls by `fast_fall_speed` 640); 8 recommended revisions open (residency cancel path and free-before-load, arrival safety, graph edge attributes, camera zones and shake, death-state crossing, weak ACs, fade-sum cap and Tuning Knobs, stale line on World state)) | `design/gdd/rooms-and-transitions.md` | Player controller, Camera, Terrain pipeline, World state (soft) |
| 4 | Terrain pipeline (inferred) | Core | MVP | In Review (sixth design review 2026-11-19, full: MAJOR REVISION NEEDED, 6 blockers (T3 failed at concave corners; T5 "mass" undefined so attached ledges never moved; a one-tile move flagged props and stranded records; `dressed` deadlocked on the stored flag; T3 units undefined; spawn points fingerprinted but not in rule 13), all revised the same day by restructuring: guarantees stay in the GDD, mechanics moved to `docs/architecture/terrain-tools-spec.md`. GDD frozen until the prototype room runs its fixtures; re-review after that) | design/gdd/terrain-pipeline.md | — |
| 5 | Combat | Gameplay | MVP | Implemented (no GDD) | — (brief) | Player controller, Health/damage/death |
| 6 | Guard-break | Gameplay | MVP | Implemented (no GDD) | — (brief) | Combat |
| 7 | Enemies | Gameplay | MVP | Implemented (no GDD) | — (brief) | Combat, Health/damage/death |
| 8 | Bosses (mini-boss support inferred) | Gameplay | MVP | Implemented (boss only, no GDD) | — (brief) | Guard-break, Enemies |
| 9 | Ability gating | Progression | MVP | Approved (fourth design review 2026-11-19, lean: APPROVED, 0 blockers, 7 recommended revisions open (F11 skip bound to add `far_face_extra`; F3a arrival pose and swept-box pull check; split the sweep AC; release-time AC to state 141 ± 10 px; grapple chain one-way, say so; `grapple_margin` start value; dash bisque vs reserved orange); F11 reach table independently re-simulated from `player.gd` and reproduced within about 1.5 px. Third design review 2026-11-19: NEEDS REVISION, 1 blocker revised (F11 reach table re-simulated from the code: the release ends after `grapple_release_time` 0.08 s, then ordinary air physics; reaches about 40% shorter, example chain now 140/310 px); owner decisions: last flight lands with no input, release time a config knob, F3a adds `ledge_nudge` (126 px); awaiting re-review. Second design review 2026-11-19: NEEDS REVISION, 3 blockers revised (pogoable spikes: F1 hazard floor at hazard_pit_depth_min 84, F3b kill plane only; climb restores air moves, no climbable in a grapple gate's flight envelope; F11 reaches by anchor height, old example chain rejected); awaiting re-review; code: double jump and grapple only) | design/gdd/ability-gating.md | Player controller, World state, Combat; supplies Terrain pipeline its `no_cling` and pane materials |
| 10 | Health, damage and death (inferred) | Gameplay | MVP | Implemented (no GDD) | — (brief) | Player controller |
| 11 | Bow | Gameplay | Alpha | Not Started | — | Player controller, Combat |
| 12 | Spell casts | Gameplay | Alpha | Not Started | — | Player controller, Combat |
| 13 | Elemental palette power-ups | Gameplay | Alpha | Not Started | — | Spell casts, Ability gating, Level design |
| 14 | Dream Seeker empowered state | Gameplay | Full Vision | Not Started | — | Elemental palette power-ups |
| 15 | Level design and world layout | World | MVP | Approved (sixteenth design review 2026-11-19, lean: 0 blockers, 6 recommended revisions open (knob safe ranges below derived minimums, pogoable wall/ceiling hazards undefined, stranded-enemy patrol range, respawn-delay AC, near-side shortcut AC, compound ACs); the fifteenth review's revisions held. Fifteenth design review 2026-11-19, lean: 1 blocker revised (climb walls, F6b, had no pogo gate volume; now a column gate at pogo_clearance_px); owner: strict vertical strip kept, a stranded enemy walks toward its spawn x else patrols in place, an enemy knocked out of its room reappears at its spawn point; awaiting re-review. Fourteenth design review 2026-11-19, lean: 1 blocker revised (the leash bound had no vertical extent: the hurt state has no floor-edge check, so a knockback off a ledge could drop a ground enemy into a gate volume; owner decision: a ground enemy's bound is a vertical strip and the F7 check rejects any x-overlap with a gate volume at any height); rule 24 and F7 say the hit area is held inside the bound, rule 9's "visible" defined, dash-gate knob starts at 420 s; awaiting re-review. Thirteenth design review 2026-11-19, lean: 1 blocker revised (an attack's lunge, about 126 px for the skitter with its slide-out, could carry an enemy past its leash bound; owner decision: the hard clamp covers every source of horizontal motion, lunge included); dash-gate knob capped at rule 8's 10 minutes, rule 24 volume height wording and Open Question 18 tidied; awaiting re-review. Twelfth design review 2026-11-19, lean: 1 blocker revised (chained hits could push an enemy past its leash bound; the bound is now a hard clamp, knockback included, `knockback_travel` out of it: grunt ±103, skitter ±118, brute ±59 px); ability gating status and rule 27 wording aligned; awaiting re-review. Eleventh design review 2026-11-19: 1 blocker revised (save spacing could not be counted in large rooms); owner decisions: saves placed by role with no distance rule (F4 withdrawn, `save_spacing_max` deprecated), room sizes unnumbered, key distance judged in playtest, fall exits never skip a gate (rule 27); awaiting re-review. Tenth design review 2026-11-19: 1 blocker revised (chasing enemies leashed to their spawn point; rule 24 and F7 measure each enemy by its leash bound, `chase_leash` 48 px); owner decision: leash the chase; Tuning Knobs and Player Fantasy added; awaiting re-review. Ninth design review 2026-11-19: 1 blocker revised (F7 column clearance per earlier kit, since a pogo refreshes the air dash and air jump: `pogo_clearance_px` 250, `pogo_clearance_f3a_px` 320); owner decision: widen per kit, keep the refresh; awaiting re-review. Eighth design review 2026-11-19: 1 blocker revised (F7 pogo reach from the down attack's hitbox and the target's hit area; `pogo_clearance_px` 140, `pogo_far_ext` 14); owner decisions: alcove return in the gate room, `save_spacing_max` 7-10 with saves in optional branches, Passed has a pass-line trigger; Open Question 20 resolved; awaiting re-review) | design/gdd/level-design.md | Player controller, Combat, Rooms and transitions, Terrain pipeline, Ability gating, Bosses, Enemies, World state |
| 16 | Fast travel (inferred) | World | Full Vision | Not Started | — | Rooms and transitions, World state, Level design |
| 17 | World state (inferred) | Persistence | MVP | Approved (sixth design review 2026-11-20, lean: APPROVED, 0 blockers; the fifth review's blocker held (rule 11: the version is readable from any format, a newer file is never fallen back from); 7 recommended revisions open (quit-to-title failure path has no state in the States table: Try again vs the dropped record; death with no respawn point in a new game; "quit" for window close and OS shutdown; last-good-copy read-back for a new game without Continue; carry rule 11's version-placement constraint to the storage ADR; split compound ACs; record the 60 fps target in `project.yaml`). Fifth design review 2026-11-20, lean: NEEDS REVISION, 1 blocker (a newer save could be overwritten: the version was not required to be readable from an unknown format, so an older build could fall back to an older-format last good copy and rewrite the newer main file), revised the same session with 4 recommended (owner: a first commit failure during a quit holds the quit for confirmation; 60 fps is the commit cost target; Empty refuses raises; ACs added); awaiting re-review in a fresh session. Fourth design review 2026-11-20, lean: NEEDS REVISION, 1 blocker (quit to title and Continue not ordered against in-flight or pending commits), revised the same session with 5 recommended (owner: the title waits for the commit chain to be idle; a new game's failed first commit is like any failure; key pickups have no `collected` flag; a missing main file counts as unreadable); awaiting re-review in a fresh session. Third review 2026-11-20: NEEDS REVISION, 1 blocker (crash-loss bound vs coalescing), revised. Second review 2026-11-20: NEEDS REVISION, 2 blockers, revised. First review 2026-11-20: NEEDS REVISION, 3 blockers, revised. Designed 2026-11-20, `/design-system`, lean, standard; owner: death undoes nothing, world state owns the durable write, one save slot, commit at the end of the frame) | `design/gdd/world-state.md` | Player controller, Rooms and transitions (soft: ids) |
| 18 | Save points and save/load | Persistence | MVP | Approved (fifth design review 2026-11-20, lean: APPROVED, 0 blockers, 5 recommended not yet applied: duplicate Open Question 7, rule 6 trigger criteria (exit, door, arena-lock, shortcut), step-below criteria, name the state guard for rest and arrival protection (`PlayerHealth.reset()` clears the invulnerability window), same-frame ordering with dash and grapple. Fourth design review 2026-11-20, lean: NEEDS REVISION, 1 blocker revised the same session: the seat ignored the Seeker's 10 by 22 px body (owner: a rest sets x and y, the standing hitbox while seated, pause freezes every timer; rest area at least as wide as the hitbox, a clear seat box, a press only within a tile of the seat's floor, knob range 2-4); 4 recommended applied: stick up, Open Question 7 for Grid map, pause, reward saves. Third design review 2026-11-20, lean: NEEDS REVISION, 1 blocker revised the same session: the snap-to-seat bound ignored the sensor's overlap, now the area's width plus half the hitbox (owner: restate the bound); 5 recommended applied: stays-dead enemy exception, Grid map interface, region 1 grey-box checks, `interact` bindings (gamepad B), `rest_area_max_width` registered; review log started. First and second reviews 2026-11-20, lean: NEEDS REVISION, 2 blockers each, revised the same session: seat and rest-area geometry undefined (owner: snap to the seat, the arrival point inside the rest area); rooms and transitions and level design owe changes, set out as wording in the GDD's Open Questions 1-2 (owner: revise each in its own session); owner: no enemy spawn or hazard on a rest area's screens, the Carrier's Kiln niche is scenery; 9 recommended applied; awaiting re-review in a fresh session. Designed 2026-11-20, `/design-system`, lean, standard; owner: press up to sit, a rest sets the respawn point and heals to full, safe while seated, no "saved" text; death costs only the walk back, seated arrival (needs rooms and transitions rule 8 revised); new game respawn at the Waking Niche; owes: rooms and transitions and level design revisions, Open Questions 1-2) | `design/gdd/save-points-and-save-load.md` | World state, Rooms and transitions, Level design, Player controller, Health, damage and death |
| 19 | Collectible upgrades (inferred) | Progression | Vertical Slice | Not Started | — | World state, Level design |
| 20 | HUD (inferred) | UI | MVP | Implemented (debug HUD only) | — | Health/damage/death, Ability gating |
| 21 | Grid map | UI | MVP | Approved (fourth design review 2026-11-20, lean: APPROVED, 0 blockers, 6 recommended revisions not yet applied: the arrival cell revealed on the frame the room becomes Active so one commit holds both; a button pressed while the map is open reads as not held until released; marker placement so a door mark does not hide its marker; region name in the data; press ordering on a crossing frame; missing criteria. Third design review 2026-11-20, lean: NEEDS REVISION, 2 blockers revised the same session: the reveal sweep covers movement inside one room only and a teleport reveals just its arrival cell; an exit side is seen when any cell its opening touches is revealed, so crossing away from the anchor clears the marker; owner also: a region map outlines a room's full rectangle with no notch at a secret section, a hollow Seeker mark so the respawn niche shows through; room index required of Rooms and transitions. Second design review 2026-11-20: NEEDS REVISION, 3 blockers revised the same session: hidden exits marked on one side, a marker once drawn (owner); exits placed by an anchor point; a hit-pause may run out while the map is open and the freeze never uses `Engine.time_scale` (owner); owner also: secret cells marked in the data, shipped rooms grow only right or bottom. First review 2026-11-20: 3 blockers revised, unlogged. Log: `design/gdd/reviews/grid-map-review-log.md`). Designed 2026-11-20 (`/design-system`, lean, standard). Owner: Ori-style fill-in, screen by screen, a found region map (never sold) outlines the rest; its own button, full screen, freezes play; the Seeker's room and position shown; save niches marked once seen, respawn niche highlighted (answers Save points OQ7); secrets and hidden exits nothing until found; 16 x 9 cells. Owes: World state revealed-cells field, Rooms hidden exit mark, Level design region map per region + map colours + secret job in data; story 007 conflict. UX flag: `/ux-design` map screen before epics) | `design/gdd/grid-map.md` | Rooms and transitions, World state, Level design, Camera, Save points, Player controller |
| 22 | Pause and menus, incl. control remapping (inferred) | UI | Vertical Slice | Not Started | — | Player controller (input), Save points |
| 23 | Parallax, lighting and atmosphere (inferred) | Presentation | Vertical Slice | In Review. Designed 2026-11-20 (`/design-system`, lean, standard). First `/design-review` 2026-11-20 (lean): NEEDS REVISION, 3 blockers revised (draw order with the Seeker and the lip at 4-6, rule 13; ground fog alpha cap `ground_fog_alpha_max` 0.3; section A and T from a travel range, blend centred on the edge). Second `/design-review` 2026-11-20 (lean): NEEDS REVISION, 2 blockers revised (close band values and placement, new P7; sections are strips along one axis, one spacing rule `layer_blend` between distinct edges). Third `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (close band minimum `close_min_run` tested on the stretch after the drop pull-in: 108 / 162 / 216 px runs; AC and P7 updated); 10 recommended open. Fourth `/design-review` 2026-11-20 (lean): NEEDS REVISION, 2 blockers revised (P6 update order stated, silhouette AC re-derived to 34.7 px at 60 fps; the silhouette band's rise over the play space in a fall accepted by the owner and written into rules 7 and 13, with a fall AC and a playtest check); 9 recommended open. Fifth `/design-review` 2026-11-20 (lean): NEEDS REVISION, 1 blocker revised (the reference does not bound the silhouette's lag, so after a long fall the foliage stayed at its cap about 0.9 s and settled in about 2.3 s; owner chose to bound `lag_y` to `max_drift / sway`, so it eases back as soon as the camera stops); 2 recommended applied (close band AC fixtures on the 6 px grid; grid map obligation in Open Question 2); 9 recommended open; awaiting re-review in a fresh session. Owner: the art-style test room with `room_atmosphere.gd` is the reference look; sections stay simple (strips along one axis); the cobbled lip (middle rim) is the terrain pipeline's; biome preset plus room overrides; Full / Reduced player option; any background scale accepted, long rooms change background by section; value margin 0.10 as a warning, judged by eye. Owes: Terrain pipeline (lip, floor runs, light-carrying props), Rooms and transitions + Level design (override fields, two room checks), implementation ADR (placement under zoom, 2D screen shaders not in the engine reference), frame-time budget. UX flag: Atmosphere option on the options screen | `design/gdd/parallax-lighting-and-atmosphere.md` | Terrain pipeline, Camera, Rooms and transitions |
| 24 | Hit feedback and effects (inferred) | Presentation | MVP | Implemented (no GDD) | — (brief) | Combat, Camera |
| 25 | Audio (inferred) | Audio | Vertical Slice | Not Started (dash and idle SFX reported missing) | — | Player controller, Combat |
| 26 | Lore delivery and mentor/hub pact (inferred) | Narrative | Alpha | Not Started (lore provided 2026-11-18: The Kiln City, in design/narrative/) | — | Level design, World state, Ability gating |

---

## Categories

| Category | Description | Systems |
|----------|-------------|---------|
| **Core** | Foundation systems everything depends on | 1, 2, 3, 4 |
| **Gameplay** | Combat, enemies, bosses, later abilities | 5, 6, 7, 8, 10, 11, 12, 13, 14 |
| **Progression** | How the player grows | 9, 19 |
| **World** | The map as a designed space (custom category) | 15, 16 |
| **Persistence** | Save state and continuity | 17, 18 |
| **UI** | Player-facing displays | 20, 21, 22 |
| **Presentation** | Look and feel of the image (custom category) | 23, 24 |
| **Audio** | Sound and music | 25 |
| **Narrative** | Lore and mentor delivery | 26 |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core loop to function. Without these, you can't test "is this fun?" | First playable prototype | Design FIRST |
| **Vertical Slice** | Required for one complete, polished area. Demonstrates the full experience. | Vertical slice / demo | Design SECOND |
| **Alpha** | All features present in rough form. Complete mechanical scope, placeholder content OK. | Alpha milestone | Design THIRD |
| **Full Vision** | Polish, edge cases, nice-to-haves, and content-complete features. | Beta / Release | Design as needed |

Counts: MVP 16, Vertical Slice 4, Alpha 4, Full Vision 2 (26 total).

Why these tiers: the brief's last unticked feature (rooms, doors, saves, grid map) and the owner's world rules make rooms, world state, saves, the map, level design and the terrain pipeline MVP. Bow, spells, elemental palettes and the Dream Seeker are "after the core feels good" in the brief. Fast travel needs more than one region and the brief keeps the game to one. The look systems (parallax, lighting, audio, menus, collectibles) make one region polished rather than playable, so they are Vertical Slice.

---

## Dependency Map

### Foundation Layer (no dependencies)

1. Player controller and input: every other system reads or drives it.
2. Terrain pipeline: black-box collision geometry with painted tiles; rooms and parallax are built on it.

### Core Layer (depends on foundation)

1. Camera: depends on Player controller.
2. Health, damage and death: depends on Player controller.
3. World state: depends on Player controller (owns the ability flags today); Rooms and transitions (soft: room and object ids).
4. Rooms and transitions: depends on Player controller, Camera, Terrain pipeline; World state (soft: saved object states applied when a room is rebuilt).

### Feature Layer (depends on core)

1. Combat: Player controller, Health/damage/death.
2. Guard-break: Combat.
3. Enemies: Combat, Health/damage/death.
4. Bosses: Guard-break, Enemies.
5. Ability gating: Player controller, World state, Combat (hard: the pogo and the `hittable` group decide which gates leak; it said soft before the third design review, 2026-11-19). Terrain pipeline builds the `no_cling` and bisque pane materials it defines (a contract, not a design-order dependency: the pipeline stays Foundation).
6. Level design and world layout: Player controller, Rooms and transitions, Terrain pipeline, Ability gating, Bosses, Enemies, World state.
7. Save points and save/load: World state, Rooms and transitions.
8. Collectible upgrades: World state, Level design.
9. Fast travel: Rooms and transitions, World state, Level design.
10. Bow, Spell casts, Elemental palettes, Dream Seeker (in that chain).

### Presentation Layer (depends on features)

1. HUD: Health/damage/death, Ability gating.
2. Grid map: Rooms and transitions, World state.
3. Pause and menus: Player controller (input), Save points.
4. Parallax, lighting and atmosphere: Terrain pipeline, Camera, Rooms and transitions.
5. Hit feedback and effects: Combat, Camera.
6. Audio: Player controller, Combat.

### Polish Layer (depends on everything)

1. Lore delivery and mentor/hub pact: Level design, World state, Ability gating.

---

## Recommended Design Order

Systems that are already implemented but have no GDD (1, 2, 5-8, 9, 10, 20, 24; the camera's room framing is covered by order 2) are not in this order: they work and were played; write GDDs for them later with `/reverse-document` if wanted.

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Terrain pipeline | MVP | Foundation | technical-artist, level-designer | M |
| 2 | Rooms and transitions (incl. camera framing) | MVP | Core | level-designer, gameplay-programmer | M |
| 3 | World state | MVP | Core | game-designer | L (scope signal from the fifth design review; producer to verify) |
| 4 | Ability gating (gate types, dimensions, visual language) | MVP | Feature | game-designer, level-designer | S |
| 5 | Level design and world layout | MVP | Feature | level-designer, world-builder | L |
| 6 | Save points and save/load | MVP | Feature | game-designer, gameplay-programmer | L |
| 7 | Grid map | MVP | Presentation | ux-designer | L |
| 8 | Parallax, lighting and atmosphere | Vertical Slice | Presentation | technical-artist, art-director | M |
| 9 | Collectible upgrades | Vertical Slice | Feature | game-designer | S |
| 10 | Pause and menus | Vertical Slice | Presentation | ux-designer | S |
| 11 | Audio | Vertical Slice | Presentation | audio-director, sound-designer | M |
| 12 | Bow | Alpha | Feature | game-designer | M |
| 13 | Spell casts | Alpha | Feature | game-designer | M |
| 14 | Elemental palette power-ups | Alpha | Feature | game-designer, level-designer | M |
| 15 | Lore delivery and mentor/hub pact | Alpha | Polish | narrative-director, writer | M |
| 16 | Dream Seeker empowered state | Full Vision | Feature | game-designer | S |
| 17 | Fast travel | Full Vision | Feature | level-designer | S |

Level design (5) may start earlier than its order if the owner wants: its inputs (rooms, terrain, gating, world state) are small. The research report already supplies its metrics and key order.

---

## Circular Dependencies

- **Ability gating <-> Level design**: gate sizes come from the Seeker's reach, while the order abilities arrive in and which locks each key opens come from the world layout. Resolution: a contract. The gating GDD owns gate types, dimensions and visual language; level design owns placement, order and what each key unlocks. Neither redefines the other's half.
- **Bosses <-> Ability gating** (smaller): a boss can grant an ability, and gating needs somewhere for a pickup to come from. Resolution: a pickup names its source (boss, shrine or mentor) and gating does not care which.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| Terrain pipeline | Technical | Godot 4.7 is HIGH risk (TileMapLayer physics layers, terrain sets); the reference docs may not cover 4.5-4.7 changes | Prototype one painted room before the GDD is final; check `docs/engine-reference/godot/` |
| Parallax, lighting and atmosphere | Technical | Parallax2D, 2D lights and HDR glow have 4.x pitfalls; smooth camera plus pixel snapping can jitter; Compatibility renderer reduces glow | Prototype early in one room; confirm the editor version supports 4.7-only features |
| Level design and world layout | Design / Scope | Around 25-35 rooms for the first region; lore provided 2026-11-18 (The Kiln City, in design/narrative/); exploration must feel natural, not platform-filled | Grey-box every room before art (research rule); use the research metrics; ask for lore before narrative pass |
| Ability gating | Design | Dash-jump (about 165 px) and wall jump leak horizontal and vertical gates; the double-jump gate can be bypassed | Measure in `movement_test_room`, then author gates with those numbers; playtest each gate |
| Rooms and transitions | Technical | Seamless edge transitions, per-room camera limits and persistence of room state | Build one two-room vertical slice first (story 007) |
| Elemental palettes and spells | Design | If an element does not change a fight or open a lock it becomes a passive toggle | Define each element's gate material and combat effect before building |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 26 |
| Design docs started | 8 (level design, ability gating, terrain pipeline, rooms and transitions, world state, save points, grid map, parallax lighting and atmosphere) |
| Design docs reviewed | 8 (level design, ability gating, terrain pipeline, rooms and transitions, world state, save points, grid map, parallax lighting and atmosphere) |
| Design docs approved | 6 (level design, ability gating, rooms and transitions, world state, grid map, save points) |
| Systems already implemented, in whole or part (no GDD) | 10 (1, 2, 5, 6, 7, 8, 9, 10, 20, 24) |
| MVP systems designed | 7/16 (terrain pipeline in review; ability gating, level design, rooms and transitions, world state, grid map, save points approved) |
| Vertical Slice systems designed | 1/4 (parallax, lighting and atmosphere; in review, fifth review revised) |

---

## Next Steps

- [x] Review and approve this systems enumeration (owner, 2026-11-18)
- [x] Level design GDD drafted (2026-11-18), awaiting `/design-review` in a fresh session
- [ ] Design the remaining MVP systems in the order above (`/design-system [name]`)
- [x] Provide the lore, so level design and the mentor/hub pact can use it (done 2026-11-18: The Kiln City, in design/narrative/)
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check` when the MVP systems are designed (project.stage still says Concept)
- [ ] Prototype the terrain pipeline and parallax stack in one room (highest technical risk)
