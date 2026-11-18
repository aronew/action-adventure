# Systems Index: Guardbreak (provisional title)

> **Status**: Draft (approved by the project owner 2026-11-18; director gates skipped, review mode lean)
> **Created**: 2026-11-18
> **Last Updated**: 2026-11-18
> **Source Concept**: design/game-brief.md (no game-concept.md; the brief is the design record up to this point)
> **Research**: design/research/metroidvania-world-design.md and research_notes/Metroidvania world design research/

---

## Overview

Guardbreak is a 2D side-scrolling metroidvania built around one move set that does two jobs: it carries the Seeker through a connected, ability-gated world and it breaks the guards of bosses and mini-bosses (normal enemies have health only). The core loop is fight, gain a verb, use it to open the world, then fight again. Stories 001-006 built the foundation: movement, melee, guard-break, three enemy types, one boss and two gated abilities. What remains is the world around them: rooms, doors, saves and a map; the terrain and presentation stack that makes it look natural and lived in; and the level design that makes exploration and curiosity the point.

Notes by area (balanced density):

- **Core**: the controller, camera, rooms and terrain pipeline are the load-bearing systems. Rooms and transitions are the next bottleneck: nothing about the world can be placed until a room is a defined unit with exits, camera limits and an owner for its state.
- **Combat and bosses**: built and tuned. Guard-break applies to bosses and mini-bosses only (owner's rule). Mini-boss support is inferred and not built.
- **Ability gating and level design**: these two depend on each other. The gating GDD owns gate types, dimensions (measured against the Seeker's reach) and their visual language. Level design owns where gates sit, the order abilities arrive in and what each key unlocks. Owner's rules apply to both: abilities come from bosses, found places or a mentor, never in front of their own gate; a gate is seen first and returned to; no "region cleared" screen.
- **World state and saves**: one record of what the player owns and has done (abilities, bosses beaten, shortcuts opened, secrets found), written at save points.
- **Presentation**: the look is a stated goal. Collision is plain black-box geometry with tiles painted on top; parallax, vignette and light give depth. Godot 4.7 is HIGH risk, so this is prototyped early.
- **Later**: bow, spells, elemental palettes and the Dream Seeker state come after the core feels good. Fast travel waits for more than one region.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Player controller and input | Core | MVP | Implemented (no GDD) | — (brief) | — |
| 2 | Camera | Core | MVP | Implemented (follow, look-ahead, shake); room framing not started | — (brief) | Player controller |
| 3 | Rooms and transitions (inferred) | Core | MVP | Not Started | — | Player controller, Camera, Terrain pipeline |
| 4 | Terrain pipeline (inferred) | Core | MVP | Not Started | — | — |
| 5 | Combat | Gameplay | MVP | Implemented (no GDD) | — (brief) | Player controller, Health/damage/death |
| 6 | Guard-break | Gameplay | MVP | Implemented (no GDD) | — (brief) | Combat |
| 7 | Enemies | Gameplay | MVP | Implemented (no GDD) | — (brief) | Combat, Health/damage/death |
| 8 | Bosses (mini-boss support inferred) | Gameplay | MVP | Implemented (boss only, no GDD) | — (brief) | Guard-break, Enemies |
| 9 | Ability gating | Progression | MVP | Implemented (test rooms, no GDD) | — (brief) | Player controller, World state |
| 10 | Health, damage and death (inferred) | Gameplay | MVP | Implemented (no GDD) | — (brief) | Player controller |
| 11 | Bow | Gameplay | Alpha | Not Started | — | Player controller, Combat |
| 12 | Spell casts | Gameplay | Alpha | Not Started | — | Player controller, Combat |
| 13 | Elemental palette power-ups | Gameplay | Alpha | Not Started | — | Spell casts, Ability gating, Level design |
| 14 | Dream Seeker empowered state | Gameplay | Full Vision | Not Started | — | Elemental palette power-ups |
| 15 | Level design and world layout | World | MVP | In Review (fourth design review 2026-11-18: 3 blockers revised (one wall is a ladder: F6, F8; head height and own faces in F2/F3a; chasm far face in F3b; no_cling surface added); awaiting re-review) | design/gdd/level-design.md | Player controller, Rooms and transitions, Terrain pipeline, Ability gating, Bosses, Enemies, World state |
| 16 | Fast travel (inferred) | World | Full Vision | Not Started | — | Rooms and transitions, World state, Level design |
| 17 | World state (inferred) | Persistence | MVP | Not Started | — | Player controller |
| 18 | Save points and save/load | Persistence | MVP | Not Started | — | World state, Rooms and transitions, Level design |
| 19 | Collectible upgrades (inferred) | Progression | Vertical Slice | Not Started | — | World state, Level design |
| 20 | HUD (inferred) | UI | MVP | Implemented (debug HUD only) | — | Health/damage/death, Ability gating |
| 21 | Grid map | UI | MVP | Not Started | — | Rooms and transitions, World state, Level design |
| 22 | Pause and menus, incl. control remapping (inferred) | UI | Vertical Slice | Not Started | — | Player controller (input), Save points |
| 23 | Parallax, lighting and atmosphere (inferred) | Presentation | Vertical Slice | Not Started | — | Terrain pipeline, Camera, Rooms and transitions |
| 24 | Hit feedback and effects (inferred) | Presentation | MVP | Implemented (no GDD) | — (brief) | Combat, Camera |
| 25 | Audio (inferred) | Audio | Vertical Slice | Not Started (dash and idle SFX reported missing) | — | Player controller, Combat |
| 26 | Lore delivery and mentor/hub pact (inferred) | Narrative | Alpha | Not Started (lore not yet provided) | — | Level design, World state, Ability gating |

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
3. World state: depends on Player controller (owns the ability flags today).
4. Rooms and transitions: depends on Player controller, Camera, Terrain pipeline.

### Feature Layer (depends on core)

1. Combat: Player controller, Health/damage/death.
2. Guard-break: Combat.
3. Enemies: Combat, Health/damage/death.
4. Bosses: Guard-break, Enemies.
5. Ability gating: Player controller, World state.
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
| 3 | World state | MVP | Core | game-designer | S |
| 4 | Ability gating (gate types, dimensions, visual language) | MVP | Feature | game-designer, level-designer | S |
| 5 | Level design and world layout | MVP | Feature | level-designer, world-builder | L |
| 6 | Save points and save/load | MVP | Feature | game-designer, gameplay-programmer | S |
| 7 | Grid map | MVP | Presentation | ux-designer | M |
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
| Level design and world layout | Design / Scope | Around 25-35 rooms for the first region; lore has not been provided; exploration must feel natural, not platform-filled | Grey-box every room before art (research rule); use the research metrics; ask for lore before narrative pass |
| Ability gating | Design | Dash-jump (about 165 px) and wall jump leak horizontal and vertical gates; the double-jump gate can be bypassed | Measure in `movement_test_room`, then author gates with those numbers; playtest each gate |
| Rooms and transitions | Technical | Seamless edge transitions, per-room camera limits and persistence of room state | Build one two-room vertical slice first (story 007) |
| Elemental palettes and spells | Design | If an element does not change a fight or open a lock it becomes a passive toggle | Define each element's gate material and combat effect before building |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 26 |
| Design docs started | 1 (level design) |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| Systems already implemented, in whole or part (no GDD) | 10 (1, 2, 5, 6, 7, 8, 9, 10, 20, 24) |
| MVP systems designed | 0/16 |
| Vertical Slice systems designed | 0/4 |

---

## Next Steps

- [x] Review and approve this systems enumeration (owner, 2026-11-18)
- [x] Level design GDD drafted (2026-11-18), awaiting `/design-review` in a fresh session
- [ ] Design the remaining MVP systems in the order above (`/design-system [name]`)
- [ ] Provide the lore, so level design and the mentor/hub pact can use it
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check` when the MVP systems are designed (project.stage still says Concept)
- [ ] Prototype the terrain pipeline and parallax stack in one room (highest technical risk)
