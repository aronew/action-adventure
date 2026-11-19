# Rooms and transitions

> **Status**: Designed 2026-11-19 (lean, standard), pending `/design-review` in a fresh session
> **Creative Director Review (CD-GDD-ALIGN)**: skipped — Lean mode
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-19
> **Last Verified**: 2026-11-19
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room")

## Summary

Rooms and transitions makes the room the unit of the world: a rectangle of whole screens with one biome, placed on a single world grid, with exits that line up by world position. The Seeker crosses an open edge or a door behind a 0.35 s fade and arrives still moving, into a neighbour that was already loaded. Each room is rebuilt fresh on entry from its data and world state, and the camera never shows past its bounds. It exists so that level design, the grid map, save points and fast travel can address the world by room and exit, and so that a run through many rooms is never broken by its seams.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Terrain pipeline, Player controller, Camera`

## Overview

Rooms and transitions makes the room the unit of the world. A room is a bounded area of whole 480 x 270 screens with one biome, its terrain (from the terrain pipeline), its exits, its camera bounds and its place in the world. This system owns the room data format, the room graph that connects rooms through their exits, and the move from one room to the next. The Seeker leaves by running or falling through an **open edge**, with a short fade, or by a **door** where the place has one. It arrives in the next room at the matching place, facing the same way and still moving. The player never operates the system as such. They feel it as a world that holds together: an edge they run off leads exactly where its shape promised, the camera never shows past a room's edge, and a transition is short enough that the run is not broken. Without it there is no world to lay out. Level design, the grid map, save points, fast travel and world state all address the world by room and exit, and the camera needs a room to stay inside. How rooms are stored, loaded and freed in the engine is an ADR, not this document.

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Rec]** = recommendation, change freely; **[Calc]** = computed. Engine details (scene format, background loading, freeing) are not covered by `docs/engine-reference/godot/` (no `core.md`) and belong to the ADR (Open Questions).

`systems-designer`, `gameplay-programmer`, `engine-programmer`, `game-designer` and `ux-designer` not consulted: Lean mode. Review manually before production.

**Rooms and the world grid**

1. **A room.** A room is a rectangle of whole 480 x 270 screens (80 x 45 terrain tiles each), written width x height in screens. It names one region and one biome (terrain rule 14). Its data holds its terrain (terrain pipeline), its exits, its doors, its camera zones, its encounter data (spawn points; terrain rule 10) and the objects other systems place in it (save points, gates, pickups). **[Owner: level design rule 1; terrain rules 2, 14]**
2. **The world grid.** Every room has a **world position**: the world-grid cell, in whole screens, of its top-left corner. All rooms of the game share one world grid. The cells a room covers belong to it alone: two rooms never overlap. A point in a room has one world position, `room origin + local position`, and that is how exits line up (rule 4) and how the grid map draws rooms as boxes (level design rule 23). **[Owner, 2026-11-19: world grid]**
3. **Room ids.** Each room has a stable id, used by world state, save files, the grid map and fast travel. An id never changes and is never reused, even if a room is moved on the world grid or cut. **[Rec]**

**Exits**

4. **Open edges.** An open edge is an opening in a room's solid border: a run of empty tiles, on grid lines, on one side of the room's bounds (terrain: outside its bounds a room is solid except at exits). It leads to the room whose cells border it at the same world position, and that room must have an opening covering exactly the same world span on its facing edge. The room check rejects an opening with no room beyond it, or whose neighbour's opening differs, and names both rooms. Openings on the bottom and top edges are **fall exits** and **rise exits**: a pit or shaft into the room below or above. Level design rule 27 decides where a fall exit may lead. **[Owner: world grid; Rec: exact match]**
5. **Crossing an open edge.** The Seeker crosses an exit when the centre of its collision box passes the room's bounds within the opening. It arrives in the neighbour at the same world position, with the same velocity, facing and state (running, dashing, falling, wall-sliding), and with its timers and air moves (air jump, air dash, coyote time) as they were. Held input carries on. Only the Seeker crosses: enemies, projectiles and pickups stop at a room's bounds (Edge Cases). **[Owner, 2026-11-19: keep momentum]**
6. **No bounce-back.** After arriving through an exit, the Seeker cannot cross back through it until its centre has moved `exit_rearm` px inside the new room or `rearm_time` has passed (R2). A weak jump up a rise exit that falls back down returns through the same exit only after that. **[Rec]**
7. **Doors.** A door is an object on the grid (terrain rule 4) with a paired door, in another room or the same one. Doors need not line up on the world grid. Pressing up while the Seeker stands in a door's area, on the ground and not attacking, plays the EnterDoor animation once, then the transition. The Seeker arrives standing in front of the paired door, facing out of it, with zero velocity. A locked or one-way door reads its state from world state (level design rule 14: shortcut gates open from the far side first). **[Owner: level design rule 1, story 007]**
8. **Arrivals with no exit.** A respawn after death, a load from a save, and fast travel enter a room at a named **arrival point** (a save point, or a room's default point) through the same load path and the same fade, with zero velocity and the Seeker standing. Which point they use is owned by Save points and Fast travel. **[Rec]**

**The transition**

9. **Sequence.** The screen fades out over `fade_out_time`. While it is dark the world is paused: physics, enemies, hazards, timers and the Seeker are all frozen. The rooms are swapped, the Seeker is placed (rules 5, 7, 8), and the camera snaps to the Seeker clamped to the new room's bounds. The world resumes as the fade-in begins, so the player sees the arrival move over `fade_in_time`. Input pressed while the screen is dark is buffered as usual (the controller's jump and dash buffers). **[Rec]**
10. **Waiting for a load.** If the next room has not finished loading when the fade-out ends, the screen stays dark until it has. After `load_wait_notice` (Formulas) a small loading mark shows. The transition never cancels and never shows a half-built room. **[Rec]**

**Loading**

11. **Preload neighbours.** While the Seeker is in a room, every room that one of its exits or doors leads to is loaded in the background, so a transition only swaps rooms. When the Seeker enters a room, rooms that are neither it nor one of its neighbours are freed. At most the current room and its neighbours are resident. A region border holds two biomes' art at once (terrain rule 14). How rooms are loaded and freed in the engine is the ADR. **[Owner, 2026-11-19: preload neighbours]**
12. **Rebuilt on entry.** Each time the Seeker enters a room, the room is built fresh from its data, then world state is applied: opened doors, broken walls, opened shortcuts, beaten bosses and collected pickups stay as world state says. Everything else starts as the data says: enemies are at their spawn points again, unsaved breakables are whole, and dropped items are gone. Preloading loads a room's data and art, not a live room. Exceptions (an enemy that stays dead) belong to the Enemies GDD and are stored in world state. **[Owner, 2026-11-19: rebuilt on entry]**

**Camera**

13. **Bounds.** The camera never shows past the current room's bounds. On an axis where the room is one screen long, the camera does not move. Follow, look-ahead, landing dip and shake (the existing `PlayerCamera`) work inside the bounds. **[Owner: brief "locks per room"; level design rule 1]**
14. **Camera zones.** A room may hold camera zones: rectangles of whole tiles that narrow the camera's bounds while the Seeker's centre is inside them (a boss arena locked to one screen, a framed vista). Each zone's bounds are at least one screen in each dimension and lie inside the room. Entering or leaving a zone eases the bounds over `zone_blend_time` (Formulas). A room with no zone uses its own bounds. **[Rec; level design Open Question 8]**

**The room graph**

15. **Derived, never authored.** The room graph has a node per room and an edge per exit (from the world grid, rule 4) and per door pair (rule 7). It is computed from the room data and never kept by hand. Level design's checks (rule 27, fall exits), the grid map and fast travel read it. An exit is two-way in the graph. Whether the Seeker can climb back up a fall exit is the level design checks' business, read from terrain and the kit, not a property of the exit. **[Rec]**

### States and Transitions

**A transition** (one at a time; the world has no other transition states):

| State | Meaning | Enter when | Leave when |
|---|---|---|---|
| In room | Normal play in the current room | The game starts; or a fade-in ends | The Seeker crosses an exit (rule 5), enters a door (rule 7, after EnterDoor), or a respawn, load or fast travel is requested (rule 8): to Fading out |
| Fading out | Screen fading to dark; world still running until dark | From In room | The fade-out ends: to Swapping |
| Swapping | Screen dark, world paused; rooms swapped, Seeker placed, camera snapped | From Fading out | The next room is loaded and built (rules 10, 12): to Fading in |
| Fading in | Screen fading from dark; world running in the new room | From Swapping | The fade-in ends: to In room |

During Fading out and Fading in, another exit or door does not start a second transition. The Seeker cannot be hurt or killed from the frame it crosses until the fade-in ends (Edge Cases), so no death interrupts a transition.

**A room's residency** (per room):

| State | Meaning | Enter when | Leave when |
|---|---|---|---|
| Unloaded | Nothing of the room is in memory | Start; or freed (rule 11) | It becomes a neighbour of the current room, or the target of an arrival: to Loading |
| Loading | Its data and art are loading in the background | From Unloaded | Load complete: to Loaded |
| Loaded | Data and art resident; no live room | From Loading; or the Seeker leaves it and it is still a neighbour | The Seeker enters it: to Active; it is no longer a neighbour: to Unloaded |
| Active | The live room the Seeker is in, built fresh (rule 12) | From Loaded, at Swapping | The Seeker leaves it: its live room is discarded, to Loaded or Unloaded |

### Interactions with Other Systems

Only terrain pipeline and level design have GDDs; the other interfaces are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|---|---|---|---|
| Terrain pipeline | Both | In: the tile grid inside a room's bounds, whole screens of 80 x 45 tiles, one biome, solid outside the bounds except at exits. Out: room bounds, exit openings on grid lines, the room's biome | Terrain pipeline owns the tiles; this system owns bounds and exits |
| Level design | Both | In: room layouts, sizes, world positions, exits and doors. Out: the room graph (rule 15) for its checks (rule 27) and the room unit (rule 1) | Level design owns where rooms go; this system owns what a room is |
| Player controller | Both | Out: placement on arrival with velocity, facing, state, timers and air moves kept (rule 5); the pause while dark. In: the collision box centre; the door input (up), EnterDoor animation | The controller owns its state; this system owns when it is moved and frozen |
| Camera | Out | The current bounds (room or zone), the snap on arrival, zone blends (rules 13, 14) | Camera owns follow and shake; this system owns the limits |
| World state | Both | Out: room ids and object ids within rooms. In: saved states applied at each build (rule 12) | World state |
| Save points and save/load | Out | Enter room R at arrival point P (rule 8); the current room id | Save points |
| Grid map | Out | Room cells on the world grid, exits as edges, the room the Seeker is in | Grid map |
| Enemies | Both | Out: room bounds (enemies stop there), rebuilt-on-entry respawn (rule 12). In: spawn points, exceptions stored in world state | Enemies |
| Parallax, lighting and atmosphere | Out | The current room's biome and bounds, so layers are placed per room | Parallax, lighting and atmosphere |
| Fast travel (Full Vision) | Out | Arrivals at named points (rule 8), the room graph | Fast travel |

## Formulas

`systems-designer` lens applied in this session (lean mode spawns no agent): every formula was run at its variables' minimum, maximum and 0. Screen size (480 x 270 game px) and `collision_tile` (6 px) are the terrain pipeline's (rules 1, 2).

### R1. Arrival position

The arrival_position formula is defined as:

`local_new = (origin_old - origin_new) x (480, 270) + local_old`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| origin_old, origin_new | int pair (screens) | any world-grid cell | data file (room data) | World positions of the room left and the room entered (rule 2) |
| local_old | float pair (game px) | inside the old room, at its bounds | calculated | The Seeker's position when its centre crosses the exit (rule 5) |
| local_new | float pair (game px) | inside the new room, at its bounds | calculated | Where the Seeker is placed in the new room |

**Output Range:** a point on the new room's facing edge, within its opening; the openings match exactly (rule 4), so it can never fall outside the room or inside solid. Velocity, facing and state are carried unchanged (rule 5).
**Example:** a room at cell (3, 1) whose right edge at local x 1440 (3 screens wide) opens into a room at cell (6, 1): the Seeker crossing at local (1440, 200) arrives at (3 - 6) x 480 + 1440 = 0, so at local (0, 200), still running right.

### R2. Exit re-arm

The exit_rearm formula is defined as:

`may_cross_back = inside_distance >= exit_rearm or time_since_arrival >= rearm_time`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| inside_distance | float (game px) | 0 or more | calculated | How far the Seeker's centre has moved inside the new room from the exit it arrived through, along the exit's normal |
| exit_rearm | float (game px) | 6-48, starts at 12 | data file | Two tiles: about the Seeker's width plus a tile **[Rec]** |
| time_since_arrival | float (s) | 0 or more | calculated | World time since the fade-in began |
| rearm_time | float (s) | 0.2-1.0, starts at 0.5 | data file | Cap, so a large `exit_rearm` never traps the Seeker at an exit **[Rec]** |

**Output Range:** a yes or no for the arrival exit only; other exits are always armed. At `exit_rearm` 0 and `rearm_time` 0, a weak jump up a rise exit that falls back flickers between rooms every frame, which is why both have floors.
**Example:** the Seeker jumps up a rise exit, arrives 2 px inside the room above and falls back at once: `inside_distance` 2 < 12 and 0.1 s < 0.5 s, so it does not cross back; it lands on the room's floor by the opening, or, if there is none, crosses back at 0.5 s.

### R3. Transition time

The transition_time formula is defined as:

`transition_time = fade_out_time + max(0, load_left) + fade_in_time`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| fade_out_time | float (s) | 0.1-0.4, starts at 0.15 | data file | Fade to dark; the world still runs **[Rec]** |
| load_left | float (s) | 0 or more | calculated | Time the next room still needs to finish loading when the fade-out ends; 0 for a preloaded neighbour (rule 11) |
| fade_in_time | float (s) | 0.1-0.4, starts at 0.2 | data file | Fade from dark; the world runs, so the arrival move is seen **[Rec]** |
| load_wait_notice | float (s) | 0.25-1.0, starts at 0.5 | data file | Dark wait after which the loading mark shows (rule 10) **[Rec]** |

**Output Range:** 0.35 s for a preloaded room at the starting values; 0.2-0.8 s across the fade ranges, plus any load wait. Below 0.1 s a fade is a hard cut that shows the swap; above about 0.5 s in total, a run through a chain of small connector rooms reads as broken.
**Example:** running right into a preloaded neighbour: 0.15 + 0 + 0.2 = 0.35 s, of which the world is frozen only while the screen is dark. A respawn into a room that was not resident with a 1.07 s biome load: 0.15 + about 1.07 + 0.2 = about 1.4 s, with the loading mark showing after 0.5 s of dark.

### R4. Camera clamp and zone blend

The camera_clamp formula is defined as:

`cam_x in [L + 240, R - 240]`, `cam_y in [T + 135, B - 135]`, with `(L, R, T, B) = lerp(bounds_from, bounds_to, smoothstep(t / zone_blend_time))` during a zone blend

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L, R, T, B | float (game px) | inside the room | data file (room bounds or a camera zone) | Left, right, top and bottom of the bounds the camera stays inside (rules 13, 14) |
| 240, 135 | constant (game px) | n/a | constant | Half a screen: the view is 480 x 270 game px at every display scale (terrain rule 1) |
| bounds_from, bounds_to | rectangles | n/a | calculated | The bounds before and after entering or leaving a zone |
| t | float (s) | 0 to zone_blend_time | calculated | Time since the zone was entered or left |
| zone_blend_time | float (s) | 0-1.0, starts at 0.4 | data file | How long the bounds ease between room and zone **[Rec]** |

**Output Range:** a non-empty interval on each axis whenever the bounds are at least one screen in that dimension (rule 14); in a room or zone exactly one screen long on an axis, the interval is a point and the camera is fixed there. A zone smaller than a screen would give an empty interval, so the room check rejects it. At `zone_blend_time` 0 the bounds snap.
**Example:** a 3 x 1 screen room: `cam_x` in [240, 1200], `cam_y` fixed at 135. Entering a 1 x 1 boss-arena zone at x 960-1440 eases `cam_x` to the single value 1200 over 0.4 s.

### R5. Preload deadline (advisory)

The preload_deadline formula is defined as:

`t_reach(exit) = d_min(exit) / dash_speed`  ·  listed when `t_reach(exit) < load_time(target of exit)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d_min | float (game px) | 0 or more | calculated (room data) | Shortest straight distance from any arrival point of the room (an exit's opening or a door) to this exit's crossing line, ignoring terrain (a conservative bound) |
| dash_speed | float (px/s) | about 370 | `player_config.tres` | The fastest sustained ground speed; read, never copied |
| load_time | float (s) | measured | measured per biome | How long the target room takes to load when its biome is not already resident: 0.75-1.07 s measured for a biome's first load (level design Open Question 22); near 0 when the biome is resident |

**Output Range:** 0 s upward. The check only lists exits; it never refuses a room. At `d_min` 0 (two exits meeting at a room's corner) any load the neighbour needs shows as a dark wait (rule 10).
**Example:** a 1-screen connector at a region border, arriving at its left edge with the other biome's room beyond its right edge: `d_min` about 480, `t_reach` = 480 / 370 = about 1.3 s, more than 1.07 s, so it is not listed. The same connector with the new biome's exit 120 px from the arrival: 0.32 s, listed.

### R6. Resident set

The resident_set formula is defined as:

`resident(current) = { current } + neighbours(current)`  ·  `biomes(resident) <= 2`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| neighbours(current) | set of rooms | 0 or more | calculated (room graph, rule 15) | Rooms one exit or door away from the current room |
| biomes(resident) | int | 1-2 | calculated | Distinct biomes among resident rooms; 2 only at a region border (terrain rule 14) |

**Output Range:** 1 room (a dead end with no neighbours, which is not possible in a connected world) up to 1 + the room's exit and door count. A room whose neighbours span three biomes breaks the `<= 2` bound; the room check rejects it. **Memory: NOT ASSESSED.** The project's memory ceiling is `[TO BE CONFIGURED]` (terrain Open Question 4), so no resident-memory bound can be checked; a biome costs about 97 MB of texture memory, so two cost about 194 MB.
**Example:** a hub with 5 exits into 5 rooms of the same biome: 6 rooms resident, 1 biome. A border room with neighbours in its own biome and the next: 2 biomes.

**Feedback loops:** none. Transitions do not grow with play.

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

**Crossing**
- **If the Seeker is hit, or touches a hazard or kill plane, while a transition runs**: it cannot be hurt or killed from the frame it crosses an exit or starts EnterDoor until the fade-in ends. Hazards and enemies in the new room act normally after that. **[Rec]**
- **If the Seeker crosses an exit mid-attack**: its state is carried (rule 5), but the attack's hits in the old room are discarded and the attack hits nothing in the new room until the next attack starts.
- **If the Seeker's centre crosses two openings on the same frame** (a room corner where a side opening meets a fall exit): it takes the exit whose bounds line the centre passed farther. On a tie, it takes the side exit, so a run keeps its direction.
- **If a rise exit is reached with too little upward speed** (a jump that only just reaches the opening): the Seeker arrives, falls back, and returns through the same exit only once `exit_rearm` or `rearm_time` allows it (R2). It never flickers between rooms.
- **If an opening is too narrow for the Seeker**: it fails the terrain pipeline's passage check (`pass_w`, `pass_h` tiles) like any other space, so it is rejected before approval. A crack in the border that only reads as an opening is not an exit and stays solid.
- **If a room's opening faces a region not yet built** (the core build has one region, level design rule 2): the opening is solid until that region exists, so the room check sees no exit there and does not reject the room.

**Doors**
- **If up is pressed while the Seeker is in the air, attacking or not on the door's area**: nothing happens (rule 7). A buffered up does not open a door after landing.
- **If a door's pair is missing, or points to a door in a room that does not exist**: the room check rejects both rooms by name.
- **If a one-way or locked door is used from its closed side**: it shows as locked and no transition starts (level design rule 14).

**Loading**
- **If the Seeker turns round and goes straight back through the exit it came in by**: the room it left is a neighbour, so it is still resident and the transition does not wait.
- **If the Seeker reaches an exit before its target has loaded**: the screen stays dark until it has (rule 10). R5 lists the exits where that can happen at a biome change, for level design.
- **If the game is paused or a save is requested during a transition**: the pause opens, or the save runs, only after the fade-in ends.
- **If a respawn, load or fast travel targets the room the Seeker is in**: the room is rebuilt fresh (rule 12) behind the same fade.

**Contents of a room**
- **If an enemy is knocked out of its room** (through an open bottom edge or a pit): it never enters another room. It is removed at the room's bounds and reappears at its spawn point after `enemy_return_delay` (2 s **[Rec]**, data file, range 0.5-5 s; level design Edge Cases asked this GDD and the Enemies GDD to adopt it).
- **If a projectile or dropped item reaches a room's bounds**: it is freed. Nothing but the Seeker crosses.
- **If an enemy's spawn point is within 48 px of an arrival** (an exit's opening or a door): the room check lists it for level design, because the Seeker would arrive into a hit. **[Rec]**

**Camera**
- **If the Seeker leaves a camera zone while the blend into it is still running**: the new blend starts from the bounds the camera holds at that moment, so the camera never jumps.
- **If a camera zone is smaller than a screen or extends outside its room**: the room check rejects it (rule 14, R4).

**World grid**
- **If two rooms would overlap on the world grid**: the room check rejects both by name (rule 2).
- **If a room is moved on the world grid or cut after release**: saves hold room ids and arrival points, never world positions (rule 3), so a save still loads into the right room. A cut room's id stays reserved; a save inside it loads at the region's first save point.

## Dependencies

The systems index places this system in the Core layer, depending on Player controller, Camera and Terrain pipeline. Only the terrain pipeline has a GDD; the controller and camera are built, with no GDD.

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Terrain pipeline | Hard | The tile grid inside a room's bounds in whole 80 x 45-tile screens, solid outside the bounds except at exits, openings on grid lines, one biome per room, the passage check that rejects too-narrow openings (terrain rules 2, 4, 14; Edge Cases) | Yes, In Review (`design/gdd/terrain-pipeline.md`) |
| Player controller | Hard | The Seeker's collision box centre (rule 5), its state, velocity, facing, timers and air moves to carry across (rule 5), a way to freeze it while the screen is dark (rule 9), the door input (up) and EnterDoor (rule 7), `dash_speed` (R5) | No (`player.gd`, `player_config.tres`) |
| Camera | Hard | A camera that takes bounds and a snap (rules 9, 13, 14) | No (`player_camera.gd`: follow, look-ahead, dip, shake; no bounds yet) |
| World state | Soft | Saved states of a room's objects, applied at each build (rule 12). Without it a room still builds, from its data alone | No (Not Started) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Level design and world layout | Hard | The room unit, world positions, exits and doors, and the room graph for its checks (rule 27, fall exits) |
| Save points and save/load | Hard | Arrivals at a named point (rule 8), room ids (rule 3), the current room |
| Grid map | Hard | Rooms as world-grid cells, exits as edges, the current room (rules 2, 15) |
| Fast travel (Full Vision) | Hard | Arrivals at named points, the room graph |
| Parallax, lighting and atmosphere | Hard | The current room's biome and bounds |
| Enemies | Soft | Room bounds, the rebuild on entry (rule 12), `enemy_return_delay` (Edge Cases) |
| World state | Soft | Room ids and object ids to key saved state by |

**Bidirectional check:**

- Terrain pipeline lists Rooms and transitions as a hard downstream dependency (its Dependencies) and its Interactions row says this system owns room bounds and exits. Match.
- Level design lists Rooms and transitions as a hard upstream dependency, "provisional" (Dependencies, Interactions). Its Open Question 8 (room data format, camera zones, edge exits and their fade) is answered by rules 1-14 here, and its Edge Cases line on enemies knocked out of a room is adopted (Edge Cases). Its rows should drop "provisional" and name this GDD once it is approved.
- The systems index lists Save points, Grid map, Fast travel and Parallax as depending on this system. Match. **World state is missing** from this system's "Depends On" column; it is a soft upstream (rule 12) and should be added.
- Player controller, Camera, World state and Enemies have no GDD yet. Each needs a matching entry when it is designed.

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The art bible (not yet written) owns every look named here.

- **Fade.** Edge exits, doors, respawns, loads and fast travel all fade the whole screen to black and back (rules 8, 9). The fade is a plain fade, not a wipe, so its direction never contradicts the Seeker's.
- **EnterDoor.** A door plays the Seeker pack's EnterDoor animation once before the fade-out (rule 7). Arrival through a door shows the Seeker already standing in front of the paired door; no exit animation is specified.
- **Loading mark.** A small mark in a screen corner after `load_wait_notice` of dark (rule 10). Its look comes from the art bible; until then, a plain pale glyph.
- **Room edges.** The play layer ends at a room's bounds; the parallax layers are placed per room from its bounds and biome (Interactions). Nothing of the neighbouring room is drawn.
- **Audio.** Music and ambience continue across a transition within a region; they are not restarted by the fade. A region border's change of music is the audio system's (Open Questions). The fade itself plays no sound. A door plays its own open sound with EnterDoor. **[Rec]**

## Game Feel

These are design targets; the acceptance criteria check the measurable parts.

- **The run is never broken.** A Seeker dashing off an edge arrives dashing, in 0.35 s (R3), and keeps its air moves. A player chaining connector rooms at speed should not feel the seams as stops.
- **Arrivals are safe and readable.** The Seeker is never hurt during a transition (Edge Cases), never arrives into solid (rule 4), and never bounces straight back (R2).
- **The camera tells you where the room ends.** It stops at the room's edge, so a stop of the camera reads as "the room ends here", and an open edge in view reads as a way on.

## UI Requirements

- The loading mark (rule 10, Visual/Audio) is the only element this system shows. It is not interactive.
- No room-name or region-name banner is shown on entering a room (level design rule 21: quiet transitions). A region title card on first entering a region is an open question.
- The editor needs a world-grid view that shows rooms as boxes on their cells, their openings and door pairs, and every room-check rejection (overlaps, unmatched openings, missing door pairs, zones too small). That is a tools story, not a UX spec.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| Room size in whole 480 x 270 screens, large rooms, open edges with a short fade, real doors only (rule 1) | Level design | `design/gdd/level-design.md`, Approved |
| Fall exits never skip a gate (rule 27); shortcut doors open from the far side (rule 14); grid map rooms and exits (rule 23); quiet transitions (rule 21) | Level design | Approved |
| Enemies knocked out of a room reappear at their spawn point (Edge Cases) | Level design | Approved; delay adopted here |
| Tile grid, whole screens of 80 x 45 tiles, solid outside bounds except exits, one biome per room, passage check | Terrain pipeline | `design/gdd/terrain-pipeline.md`, In Review |
| Encounter data is not layout (rule 10) | Terrain pipeline | In Review |
| Biome texture memory about 97 MB, first load 0.75-1.07 s | Level design Open Question 22 | Measured 2026-11-19 in the container (no GPU) |
| `dash_speed` 370, collision box 10 x 22, EnterDoor animation | Player controller | `player_config.tres`, `player.gd`, `seeker_animations.json`; no GDD |
| Camera follow, look-ahead, dip, shake | Camera | `player_camera.gd`; no GDD |
| Rooms as separate scenes, paired doors, camera inside room bounds | Story 007 | `production/epics/guardbreak/story-007-rooms-saves-map.md`, Ready |

## Acceptance Criteria

Types: **[Auto]** automated test on room-data fixtures; **[Auto, engine]** automated test that runs the game headless; **[Play]** playtest or hardware record. `qa-lead` lens applied in this session (lean mode spawns no agent).

**Rooms and the world grid**
- **GIVEN** a room's data, **WHEN** the room check runs, **THEN** it has a whole number of screens in each dimension, one region, one biome and a world position; **GIVEN** a room with no biome, **THEN** it is rejected and named. **[Auto]** (rule 1)
- **GIVEN** two rooms whose world-grid cells overlap by one cell, **WHEN** the room check runs, **THEN** both are rejected and named. **[Auto]** (rule 2)
- **GIVEN** a save made in room X at its save point, **WHEN** room X is moved two cells on the world grid and the save is loaded, **THEN** the Seeker arrives in room X at the same save point. **[Auto, engine]** (rule 3, Edge Cases)

**Exits**
- **GIVEN** two rooms side by side whose facing openings cover the same world span, **THEN** the room check passes; **GIVEN** the neighbour's opening one tile shorter, **THEN** both rooms are rejected and named; **GIVEN** an opening with no room beyond it, **THEN** its room is rejected. **[Auto]** (rule 4)
- **GIVEN** a 3 x 1 screen room at cell (3, 1) whose right edge opens into a room at cell (6, 1), **WHEN** the Seeker runs right at `run_speed` and its centre crosses the edge at local y 200, **THEN** it arrives at local (0, 200) of the new room, running right at `run_speed`. **[Auto, engine]** (rule 5, R1)
- **GIVEN** the same exit, **WHEN** the Seeker crosses mid-dash with its air jump unused, **THEN** it arrives in the dash state with the dash's remaining time unchanged and its air jump still available. **WHEN** instead it falls through a fall exit at `max_fall_speed`, **THEN** it arrives at the top of the room below falling at `max_fall_speed`. **[Auto, engine]** (rule 5)
- **GIVEN** a rise exit, **WHEN** the Seeker arrives through it 2 px inside the room above and falls straight back, **THEN** it does not cross back before 0.5 s, and crosses back at most once in the first second. **GIVEN** `exit_rearm` 12, **WHEN** it has moved exactly 12 px inside, **THEN** it may cross back at once. **[Auto, engine]** (rule 6, R2)
- **GIVEN** the Seeker standing on the ground in a door's area, **WHEN** up is pressed, **THEN** EnterDoor plays once, the transition runs, and the Seeker arrives standing in front of the paired door, facing out of it, with zero velocity. **[Auto, engine]** (rule 7)
- **GIVEN** the Seeker in the air, or attacking, in a door's area, **WHEN** up is pressed, **THEN** no transition starts, and none starts on landing. **GIVEN** a one-way door seen from its closed side, **THEN** pressing up starts no transition. **[Auto, engine]** (rule 7, Edge Cases)
- **GIVEN** the Seeker dies, **WHEN** it respawns, **THEN** it arrives standing at its save point's arrival point with zero velocity, behind the same fade. **[Auto, engine]** (rule 8)

**The transition**
- **GIVEN** a preloaded neighbour and the starting values, **WHEN** the Seeker crosses an exit, **THEN** the time from the crossing frame to the end of the fade-in is 0.35 s, within one frame at 60 Hz. **[Auto, engine]** (rule 9, R3)
- **GIVEN** a transition in progress, **WHEN** the screen is fully dark, **THEN** the Seeker's and every enemy's position, velocity and timers are unchanged from frame to frame; **WHEN** jump is pressed while dark, **THEN** the Seeker jumps on the first frame of the fade-in. **[Auto, engine]** (rule 9)
- **GIVEN** a target room whose load is held back by 1.0 s (test hook), **WHEN** the Seeker crosses into it, **THEN** the screen stays dark until the room is built, the loading mark appears after 0.5 s of dark, and no frame shows a partly built room. **[Auto, engine]** (rule 10, R3)

**Loading and rebuilding**
- **GIVEN** a room with three neighbours, **WHEN** the Seeker enters it, **THEN** the resident rooms are exactly it and its three neighbours, every other room is freed, and the resident set holds at most two biomes. **GIVEN** a room whose neighbours span three biomes, **THEN** the room check rejects it. **[Auto, engine]** for residency, **[Auto]** for the check (rule 11, R6)
- **GIVEN** a room where the Seeker killed an enemy, broke an unsaved breakable and opened a door that world state saves, **WHEN** it leaves and comes back, **THEN** the enemy is alive at its spawn point, the breakable is whole and the door is open. **[Auto, engine]** (rule 12)
- **GIVEN** the Seeker crosses an exit, **WHEN** it turns round and crosses straight back once re-armed, **THEN** the transition does not wait for a load. **[Auto, engine]** (Edge Cases, rule 11)

**Camera**
- **GIVEN** a 3 x 1 screen room, **WHEN** the Seeker runs its whole length and back, **THEN** on every frame the camera's centre x is within [240, 1200] and its centre y is 135, so the view never shows past the room's bounds. **[Auto, engine]** (rule 13, R4)
- **GIVEN** a 1 x 1 screen camera zone at x 960-1440 in that room, **WHEN** the Seeker enters it, **THEN** the camera's centre x reaches 1200 within 0.4 s and stays there while the Seeker is inside; **WHEN** it leaves the zone 0.2 s after entering, **THEN** the camera's bounds on that frame equal the bounds on the frame before. **[Auto, engine]** (rule 14, R4, Edge Cases)
- **GIVEN** a camera zone 0.9 screens wide, or one that extends past its room, **WHEN** the room check runs, **THEN** it is rejected. **[Auto]** (rule 14, Edge Cases)

**The room graph**
- **GIVEN** a fixture of four rooms with three matched openings and one door pair, **WHEN** the room graph is computed, **THEN** it has four nodes and four edges; **WHEN** one more matched opening pair is added to the data, **THEN** the graph has five edges with no other change. **[Auto]** (rule 15)
- **GIVEN** a fall exit whose room below leads past a gate's far side with only the earlier keys, **WHEN** level design's rule 27 check runs on the room graph, **THEN** it fails and names the fall exit. **[Auto]** (rule 15, cross-system: level design rule 27)

**Formulas**
- **GIVEN** a 1-screen connector whose arrival is 120 px from an exit into a room of another biome, **WHEN** the R5 check runs, **THEN** that exit is listed (0.32 s, below 0.75 s); **GIVEN** the arrival 480 px from it, **THEN** it is not listed (1.30 s); **GIVEN** two exits meeting at the room's corner, **THEN** it is listed (0 s). **[Auto]** unit test (R5)
- **GIVEN** R1 with origins (3, 1) and (6, 1) and a crossing at local (1440, 200), **THEN** the arrival is local (0, 200); **GIVEN** origins (2, 0) and (2, 1) and a fall through local (300, 270), **THEN** the arrival is local (300, 0). **[Auto]** unit test (R1)

**Edge cases that could ship broken**
- **GIVEN** a spike hazard at an arrival point and an enemy attacking the Seeker as it crosses, **WHEN** the transition runs, **THEN** the Seeker takes no damage until the fade-in ends. **[Auto, engine]** (Edge Cases)
- **GIVEN** a room corner where a side opening meets a fall exit, **WHEN** the Seeker's centre crosses both lines on one frame, equally far past each, **THEN** it takes the side exit. **[Auto, engine]** (Edge Cases)
- **GIVEN** an enemy knocked through an open bottom edge, **THEN** it is removed at the room's bounds, enters no other room, and reappears at its spawn point after 2 s, within one frame. **GIVEN** a projectile reaching a room's bounds, **THEN** it is freed. **[Auto, engine]** (Edge Cases)
- **GIVEN** an enemy spawn point 40 px from an exit's opening, **WHEN** the room check runs, **THEN** it is listed for level design; at 50 px it is not. **[Auto]** (Edge Cases)
- **GIVEN** a door whose pair is missing, **WHEN** the room check runs, **THEN** both rooms are rejected by name. **GIVEN** pause pressed during a transition, **THEN** the pause opens on the first frame after the fade-in ends. **[Auto]** for the check, **[Auto, engine]** for pause (Edge Cases)

**Feel and cost**
- **GIVEN** the two-room slice of story 007 on the owner's machine, **WHEN** the Seeker crosses between the rooms 20 times at `dash_speed`, **THEN** no frame of any transition exceeds 16.6 ms, and three playtesters asked "did the edge exits interrupt your run?" answer no. **[Play]** (Game Feel, R3)

**Gaps found by the QA lens:**
- Memory (R6) has no criterion: the memory ceiling is not set (Open Question 3). This is NOT ASSESSED, not a pass.
- R5's load times are the container's measurements; the real values must be measured on the owner's machine before the check's listings are trusted.
- Camera bounds at the 4x display (Open Question 2) cannot be tested until the display migration is built; R4's criteria are in game px and hold either way.

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **How rooms are stored, loaded and freed (ADR).** Scene per room or data per room, how neighbours load in the background, how a live room is built from data and world state, and how freed rooms release biome art. **NOT SOURCEABLE**: scene loading, background loading and resource freeing in Godot 4.7 are not covered by `docs/engine-reference/godot/` (there is no `core.md`), so no engine claim is made here. Owner: technical director via `/architecture-decision`. Target: before story 007.
2. **Camera bounds at the 4x display.** R4 is in game px, so it holds at any display scale, but how the camera's limits are set depends on the display migration (terrain Open Question 9) and on who owns the camera zoom. Owner: technical director, with terrain Open Question 9.
3. **Memory ceiling.** R6 cannot be checked until the project's memory ceiling is set (terrain Open Question 4). Owner: technical director.
4. **Region music and a region title card.** Whether crossing a region border changes music with a cross-fade, and whether a first entry shows the region's name. Owner: audio and level design. Target: Vertical Slice.
5. **Enemies that stay dead.** Rule 12 rebuilds every enemy on entry; exceptions are the Enemies GDD's. Owner: `/design-system enemies`.
6. **Starting values to check in play.** `fade_out_time` 0.15 s, `fade_in_time` 0.2 s, `exit_rearm` 12 px, `rearm_time` 0.5 s, `zone_blend_time` 0.4 s, `enemy_return_delay` 2 s and the 48 px spawn clearance are recommendations. Target: the two-room slice of story 007.
7. **World-grid editor view.** The tools story for authoring rooms on the world grid (UI Requirements). Target: before region 1's grey-box.
