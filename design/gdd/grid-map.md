# Grid map

> **Status**: In Design
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Implements Pillar**: none defined (brief: "Rooms with doors, save points and a grid map that fills in")
> **Creative Director Review (CD-GDD-ALIGN)**: skipped — Lean mode

## Summary

The grid map is a full-screen map on its own button that draws the world as boxes on the world grid, one cell per screen, filling in screen by screen as the Seeker sees it; a region map found in each region outlines that region's rooms not yet entered. It shows where the Seeker is, the save niches it has seen with the respawn niche highlighted, and a marker on every exit to a place not yet seen, but never items or secrets. It exists so the player can hold a world of large rooms and loops in view, and it keeps no state of its own: what has been revealed lives in World state.

> **Quick reference** — Layer: `Presentation` · Priority: `MVP` · Key deps: `Rooms and transitions, World state, Level design`

## Overview

The grid map is the Seeker's picture of the world it has walked. Pressing the map button opens a full screen that freezes play and draws each region as boxes on the world grid: one box per room, sized by its screens, with lines for its exits and marks for its doors (level design rule 23, rooms and transitions rules 2 and 15). A room is drawn screen by screen as the Seeker sees it, so a large room appears as it is crossed and the map fills in from the first step of a new game with nothing to buy and nothing to remember to do (the brief: "a grid map that fills in"). Each region also hides a **region map** somewhere in its rooms, a found object, never sold; picking it up draws that region's unseen screens as faint outlines, so a curious player is rewarded with the shape of what is left without being shown what is in it. An exit whose far side has not been seen shows as a marker, which is how the map points at unfinished business; a secret room or hidden way shows nothing until found. The map shows where the Seeker is (its room highlighted and a mark at its position) and every save niche on a screen it has seen, with the niche it last rested at highlighted, so the player always knows where a death sends them. It never marks items, keys, secrets' contents or bosses (level design rule 23). The map keeps no state of its own: the screens seen and the region maps found are World state's (a new revealed-cells entry; a pickup's `collected` flag), and the boxes, lines and niches come from the room data and the room graph Rooms and transitions derives. Without it, a world of large rooms and loops would be held only in the player's head, the unexplored-exit markers level design relies on would have nowhere to show, and the brief's last unticked feature would stay unticked. **[Owner, 2026-11-20: fills in as the world is seen, Ori-style, screen by screen, with a found region map that outlines the rest; its own button, full screen; the Seeker's room and position shown; save niches marked once seen; secrets nothing until found]**

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Rec]** = recommendation, change freely. `game-designer`, `ux-designer`, `ui-programmer`, `art-director` and `technical-artist` not consulted: Lean mode. Review manually before production.

**What the map draws**

1. **Map cells.** The map draws the world grid (rooms and transitions rule 2): one **map cell** per world-grid cell, that is per 480 x 270 screen, at a fixed scale (Formulas F1). A room is the block of cells it covers; a region is the rooms that name it. All regions share the one grid, so the map is one picture of the whole world, not a page per region. **[Rec]**
2. **Revealed screens.** A cell of a room is **revealed** on the first frame that the Seeker's centre is inside it, or that at least `reveal_cover` of the cell lies inside the camera's view (Formulas F2). A revealed cell stays revealed. World state keeps the revealed cells as a new entry: for each room id, the set of room-local cells (column, row from the room's top-left) revealed so far. Room-local, so a room moved on the world grid keeps them (rooms and transitions rule 3); a cell outside a resized room is kept and not drawn (world state rule 10). It is raised the moment it happens and only grows (world state rules 3, 5). Entering a room reveals at least the cell the Seeker arrives in, so a room visited always has a revealed cell. This field is a change owed by World state (Dependencies). **[Owner, 2026-11-20: screen by screen; Rec: the reveal test]**
3. **Drawing a room.** A revealed cell is drawn filled in its region's map colour. A room's border is drawn along every edge of a revealed cell that lies on the room's bounds; no line is drawn between two revealed cells of the same room, so a room reads as one shape as it is uncovered. An unrevealed cell of an entered room is drawn as a cell of an unentered room is (rule 4). **[Rec]**
4. **The region map.** Each region holds one **region map**: a pickup placed by level design, with an object id (rooms and transitions rule 3) and the `collected` flag every non-key pickup has (world state rule 2). It is a found object, never sold. Once it is collected, every unrevealed cell of every room in its region, except secret rooms (rule 7), is drawn as a faint outline along the room's bounds: the room's shape, no fill, no exits and no niches. Collecting it reveals nothing (rule 2), adds nothing to the record but its flag, and shows the pickup cue (Visual/Audio). Before it is collected, an unentered room is not drawn at all. **[Owner, 2026-11-20: Ori-style, a found region map outlines the rest]**
5. **Exits.** An open edge (rooms and transitions rule 4) is drawn as a short line across the room's border at its world position, once the cell on either side of it is revealed (an open edge is symmetric, rule 6). A door (its rule 7) is drawn as a door mark in its cell once that cell is revealed. A door pair is not joined by a line: doors need not line up on the grid, and a line between them would cross other rooms. An opening that is solid because the region beyond is not built is not an exit (rooms and transitions Edge Cases) and is not drawn. **[Rec; level design rule 23: exits as lines]**
6. **Unexplored markers.** A drawn exit whose **far side** is not revealed carries a marker: for an open edge, the cell on the side of the opening that is not revealed (an open edge is symmetric: it is drawn when either side is revealed and carries a marker while exactly one is); for a door, the cell of its paired door. The marker goes on the frame the far side is revealed. A gate across an exit does not hide the exit or its marker: an exit the Seeker cannot yet cross is unfinished business, which is what the marker is for (level design rules 8 and 23). **[Rec; level design rule 23]**
7. **Secrets are never given away.** A **secret room** (a room whose job is secret, level design rule 18) is never outlined by a region map; it appears only cell by cell as it is revealed. A **hidden exit** is an exit the room data marks hidden: every exit behind a breakable wall or other hidden way, and every exit into a secret room. The mark names the **hiding object**, an object id in the same room (a breakable wall, a door, a shortcut or a secret), or names none when nothing physical hides the exit (an open edge into a secret room). A hidden exit is neither drawn nor marked until its hiding object's `broken`, `open` or `found` is raised, or its far side is revealed; an exit with no hiding object is drawn only when its far side is revealed. **[Owner, 2026-11-20: nothing until found]**
8. **Save niches.** Each save point whose arrival point lies in a revealed cell is drawn as a niche mark at that point. The niche named by the respawn point (Save points rule 4) is highlighted. A niche in an unrevealed cell is not drawn, outlined region or not. **[Owner, 2026-11-20: marked once seen; Save points Open Question 7]**
9. **The Seeker.** The Seeker is drawn as a mark at its world position (room origin plus local position, rooms and transitions rule 2) at the map's scale, and the room it is in is highlighted. The current room comes from Rooms and transitions; World state holds no current room (world state rule 1). **[Owner, 2026-11-20]**
10. **Nothing else.** The map does not mark items, keys, pickups (the region map included), gates' state, bosses, enemies, hazards or what a secret holds (level design rule 23). **[Sourced: level design rule 23]**

**Opening and using the map**

11. **Opening.** Pressing the `map` action while the Seeker is in normal play (Save points States: Playing; not dead, resting, arriving, entering a door or in a transition) opens the map screen. Opening freezes the game with the same freeze as a transition (rooms and transitions rule 9): physics, enemies, hazards, projectiles, timers and the Seeker stop, and so do animations, particles and the camera (a shake included), and no input reaches the Seeker. A hit-pause in progress is held, not ended, and resumes on closing. This system owns that freeze: no pause exists yet (Pause and menus is Vertical Slice), and Pause and menus adopts it, not the reverse. A press while not in normal play does nothing and is not buffered. The map can be opened in a fight; it freezes the fight as a transition does. **[Owner, 2026-11-20: its own button, full screen; Rec: when it can open]**
12. **Closing.** Pressing `map` again, or `cancel`, closes it, and play resumes on the next frame. Presses made while the map was open, the closing press included, are discarded, so closing the map never jumps, attacks or dashes. **[Rec]**
13. **Looking around.** The map opens centred on the Seeker's mark. Move pans it. The **view centre** (the point at the screen's centre) is clamped to the bounding box of the drawn cells (revealed or outlined) grown by one cell on every side; the view's edges may go past that box, so a small map is never scrolled out of sight. Opening centres on the Seeker's mark, which lies in a revealed cell and so is always inside the clamp. The pan moves `pan_speed` cells a second along each axis independently, scaled by the stick's tilt, so a diagonal is faster than a straight pan. There is no zoom in the core build (fixed scale, F1). **[Rec]**
14. **The map writes nothing.** Opening, panning and closing the map change no state. Every fact it draws is read when it opens and while it is open: revealed cells, `collected`, rooms and their exits, save points, the respawn point, the current room. **[Rec]**

### States and Transitions

**The map screen:**

| State | Meaning | Enter when | Leave when |
|---|---|---|---|
| Closed | Play runs; reveals are recorded (rule 2) | The game starts; the map is closed (rule 12) | `map` pressed in normal play (rule 11): to Open |
| Open | Full-screen map; the game frozen; input pans or closes | From Closed (rule 11) | `map` or `cancel` pressed (rule 12): to Closed. Nothing else closes it |

**A map cell:**

| State | Drawn as | Enter when | Leave when |
|---|---|---|---|
| Unknown | Nothing | Start of a new game | Its region map is collected, and its room is not secret: to Outlined. It is revealed (rule 2): to Revealed |
| Outlined | Faint outline along its room's bounds (rule 4) | Its region map is collected | It is revealed: to Revealed |
| Revealed | Filled, with its exits, door marks, markers and niches (rules 3, 5, 6, 8) | The Seeker's centre is in it, or `reveal_cover` of it is on camera (rule 2) | Never: forward only (world state rule 3) |

**An exit:** Hidden (rule 7) → Marked (drawn, far side unrevealed, rule 6) → Drawn (far side revealed). An exit that is not hidden starts at Marked when its cell is revealed; a hidden exit goes from Hidden to Marked when its way is opened, or straight to Drawn when its far side is revealed first. None moves backward.

### Interactions with Other Systems

World state, Rooms and transitions and Level design are Approved; the rest are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|---|---|---|---|
| World state | Both | In: revealed cells per room, `collected` on each region map, the respawn point, `broken` / `open` / `found` on the objects that hide exits (rules 2, 4, 7, 8). Out: a cell revealed (rule 2). **Needs** a new entry, revealed cells per room id (Dependencies) | World state owns the record; this system owns when a cell is revealed |
| Rooms and transitions | In | Each room's id, world position, size in screens and region; its exits and doors with their pairs; its save points; the room graph (rules 2, 3, 4, 7, 15); the current room. **Needs** a hidden mark on an exit in the room data, naming the object that hides it, if any (rule 7) | Rooms and transitions |
| Level design | In | Region maps placed, one per region; each room's job (secret rooms, its rule 18); the colour each region uses on the map. **Needs** one region map per region in the room data and the secret job readable from the data (Dependencies) | Level design |
| Camera | In | The camera's view rectangle each frame, for the reveal test (rule 2, F2) | Camera |
| Save points and save/load | In | Save point positions (arrival points) and the respawn point (rule 8); the Playing state, for when the map may open (rule 11) | Save points |
| Player controller | Both | In: the `map` and `cancel` actions; move, for panning. Out: input withheld while the map is open, presses discarded on close (rules 11, 12) | Player controller owns input; this system owns when it is withheld |
| Pause and menus | Both | Pause and menus does not exist yet: the map's freeze (rule 11) is the first, and Pause and menus adopts it. Later, the map may also be a tab of the pause screen (Open Questions) | This system owns the freeze; Pause and menus owns pause |
| Fast travel (Full Vision) | Out | The niche marks, if fast travel stations are save points | Fast travel |
| Audio | Out | Map open and close cues (Visual/Audio) | Audio |

## Formulas

`systems-designer` lens applied in this session (lean mode spawns no agent): every variable was put at its minimum, its maximum and 0. Two inputs broke a formula and are closed by the data check below: `map_shrink` 0 divides by zero and a value that does not divide 480 and 270 gives fractional cells; `reveal_cover` 0 reveals every cell the view merely touches. No feedback loop: nothing the map draws feeds back into play. The screen size is rooms and transitions' (rule 1, 480 x 270), equal to the viewport (`project.godot`: 480 x 270, integer scaling), so the camera's view is exactly one screen.

### F1. Map position

The map_pos formula is defined as:

`map_pos = round((room_origin x screen + local_pos) / map_shrink) - pan`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| room_origin | int pair (cells) | any world-grid cell | data file (room data) | The room's world position, its top-left cell (rooms and transitions rule 2) |
| screen | int pair (px) | 480 x 270 | constant | One screen, one world-grid cell (rooms and transitions rule 1) |
| local_pos | float pair (px) | 0 to the room's size | calculated | A point in the room: the Seeker, a niche's arrival point, an exit's opening, a cell corner |
| map_shrink | int | 10, 15 or 30; starts at 30 | data file | World pixels per map pixel. Must divide both 480 and 270 (their greatest common divisor is 30) so a cell is a whole number of map pixels: 30 gives 16 x 9 cells, 15 gives 32 x 18, 10 gives 48 x 27 **[Owner, 2026-11-20: 16 x 9 cells]** |
| pan | int pair (px) | such that the screen's centre point lies within the drawn cells' bounding box grown by one cell (rule 13) | calculated | The view's offset; on opening, set so the Seeker's mark is at the screen's centre |

**Output Range:** a map pixel position. One cell is `480 / map_shrink` x `270 / map_shrink` map pixels; the 480 x 270 map screen shows `map_shrink` x `map_shrink` cells at once (30 x 30 at the starting value). A room of up to 20 screens, as the owner expects (Open Questions), is at most 320 x 9 px as a 20 x 1 hall, 16 x 180 as a 1 x 20 shaft, or 64 x 45 as a 4 x 5 cavern: always a readable box and never larger than the map screen. `map_shrink` 0 divides by zero, and a value that does not divide 480 and 270 (e.g. 20: 24 x 13.5) makes cell edges fall between pixels, so both are rejected (data check).
**Example:** the Seeker at local (700, 200) in a room at cell (3, 1): world (3 x 480 + 700, 1 x 270 + 200) = (2140, 470); at `map_shrink` 30 that is (71.3, 15.7), drawn at (71, 16) before the pan.

### F2. Reveal cover

The cover formula is defined as:

`cover(cell) = area(cell ∩ view) / area(cell)`; a cell is revealed when `cover(cell) >= reveal_cover`, or when the Seeker's centre is inside it (rule 2)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cell | rect (px) | one 480 x 270 cell of the current room | calculated | A cell of the room the Seeker is in |
| view | rect (px) | 480 x 270, clamped inside the room (rooms and transitions R4) | calculated | The camera's view this frame (Camera) |
| reveal_cover | float | 0.25-1.0, starts at 0.5 | data file | How much of a cell must be on camera at once to reveal it **[Rec]** |

**Output Range:** `cover` is 0 to 1 per cell. The view is exactly one cell's size, so the covers of the up to four cells it overlaps add up to 1. At 0.5, one cell is revealed, or two when the view sits exactly across their shared edge; at 0.25, up to four (the view centred on a grid corner); at 1.0, a cell only when the view lines up with it exactly, which happens in a one-screen room or against the room's corners, so reveals come almost only from the Seeker's centre. Below 0.25 a cell glimpsed at the edge of the screen is revealed, which tells the player about space they have barely seen; 0 reveals every cell the view touches. The view never leaves the room (R4), so nothing of a neighbour room is ever revealed from inside another.
**Example:** in a 3 x 2 room, the view's top-left at (300, 100): it covers 180 x 170 of cell (0, 0) (cover 0.24), 300 x 170 of (1, 0) (0.39), 180 x 100 of (0, 1) (0.14) and 300 x 100 of (1, 1) (0.23). None reaches 0.5, so only the cell holding the Seeker's centre is revealed this frame; once the view moves to (240, 0), cell (1, 0) reaches 0.5 and is revealed too.

**Data file and check:** `map_shrink`, `reveal_cover` and `pan_speed` (cells a second along each axis while move is held, scaled by the stick's tilt, 15-60, starts at 30: a 30-cell map screen crosses in about 1 s; below 15 a region feels slow to scan, above 60 a tap overshoots a room) live in `src/ui/map/map_config.tres`, a `MapConfig` resource **[Rec]**. Its `validate()` returns the name of every value outside its range (`map_shrink` not 10, 15 or 30; `reveal_cover` below 0.25 or above 1.0; `pan_speed` below 15 or above 60); it runs when the config loads at boot, and a non-empty result stops the game before the title screen and names the values, as Save points does. **[Rec]**

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

**Revealing**
- **If the Seeker's centre lies exactly on the edge between two cells**: it is in the cell to the right, or below; a cell spans its left and top edges, not its right and bottom ones. **[Rec]**
- **If the Seeker crosses more than one cell in a frame** (a fast fall, a launch, a position set by code): every cell its centre passed through between the two frames is revealed, not only the one it ends in, so a shaft never shows a gap. **[Rec]**
- **If the Seeker is dead, resting, arriving or entering a door**: reveals go on while the world runs, since being on camera is seeing, not touching (Save points Edge Cases; level design States). During a transition's freeze nothing moves, so nothing is revealed; the arrival reveals its cell on the first frame of the fade-in (rule 2). **[Rec]**
- **If a save was made before revealed cells existed** (a room is in rooms visited but has no revealed cells): the map draws that room as if every cell were revealed, and opening the map writes nothing. The first time the Seeker reveals a cell in that room, the record is seeded with every cell of the room, so the room never shrinks on the map (forward only, rule 2). **[Rec; world state rule 9]**
- **If a room is resized or cut after release**: revealed cells outside the room's new size, and those of a cut room, are kept in the record and not drawn (world state rule 10). A cell that a bigger room has gained starts unrevealed. **[Rec]**
- **If many cells are revealed in a short time** (a fall down a tall shaft): each is a record change committed at the end of its frame (world state rule 6), at most one commit a frame. The commit count is World state's to measure (its Open Question 2). **[Rec]**

**The region map and secrets**
- **If a region map is collected while rooms of its region are partly revealed**: their revealed cells stay filled and the rest are outlined (rule 4). **[Rec]**
- **If a region has no region map, or more than one**: the room check rejects the region and names it, a requirement on level design (Dependencies). **[Rec]**
- **If a secret room is partly revealed**: its revealed cells are drawn; its unrevealed cells draw nothing, region map or not (rule 7). **[Owner, 2026-11-20]**
- **If a hidden exit's far side is revealed first** (the secret room was reached another way): the exit is drawn with no marker (rule 7), and the hiding wall stays as world state has it. **[Rec]**
- **If the region map lies inside a secret room**: it outlines the region as usual and still never outlines the secret room it was found in; that room shows the cells already revealed. **[Rec]**

**Exits and marks**
- **If only one side of an open edge is revealed**: the exit is drawn from that side with a marker (rule 6). Once both sides are revealed it is drawn once, with no marker. **[Rec]**
- **If a door's pair is in the same room**: its far side is the paired door's cell in that room; the marker goes when that cell is revealed. **[Rec]**
- **If an exit is behind a gate the Seeker cannot cross yet**: it keeps its marker until its far side is revealed (rule 6), so the map keeps pointing at it. **[Rec; level design rule 8]**
- **If the respawn point names a save point that no longer exists, or one in an unrevealed cell**: no niche is highlighted; Save points picks the arrival (its rule 9). **[Rec]**
- **If the Seeker is past the room's bounds** (crossing an exit, rooms and transitions rule 5): its mark is drawn at the nearest point on the room's bounds. **[Rec]**

**Opening and closing**
- **If `map` is pressed on the frame a hit brings health to zero**: the hit is resolved first; the Seeker is dead, not in normal play, and the map does not open (rule 11). **[Rec]**
- **Once Pause and menus exists, if `map` is pressed while paused, or pause is pressed while the map is open**: the press is ignored; pause and the map never stack. Until then there is no pause, and the map's freeze (rule 11) is the only one. **[Rec]**
- **If the game is quit or crashes with the map open**: nothing is lost and nothing is written by the map (rule 14). Cells revealed before it opened were committed in their frames. **[Rec]**
- **If only the start room is drawn**: the view's centre is clamped to that room plus one cell (rule 13), so the map cannot be scrolled out of sight of it. **[Rec]**
- **If a drawn region has no map colour in its data**: the room check rejects it (a requirement on level design). **[Rec]**

## Dependencies

The systems index lists this system as depending on Rooms and transitions, World state and Level design. This GDD also needs Camera, Save points and the Player controller (Camera and the controller are code only, no GDD).

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Rooms and transitions | Hard | Room ids, world positions, sizes in screens and regions; exits and door pairs; the room graph; save points' positions; the current room (its rules 1-4, 7, 15). **Needs** a hidden mark on an exit in the room data, naming the object that hides it (an object id in the same room) or none, set on every exit behind a breakable wall or other hidden way and on every exit into a secret room (rule 7), read by its room check | Yes, Approved (`design/gdd/rooms-and-transitions.md`) |
| World state | Hard | Rooms visited, for saves older than revealed cells (Edge Cases); `collected` on each region map; `broken`, `open` and `found` on objects that hide exits; the respawn point (rules 2, 4, 7, 8). **Needs** a new entry: the revealed cells of each room, by room id, as room-local cells, forward only (rule 2). Its rule 9 already lets a later system add a field without migrating old saves | Yes, Approved (`design/gdd/world-state.md`) |
| Level design | Hard | One region map per region, placed as a pickup; each room's job, so secret rooms can be read from the data (its rule 18); each region's map colour (rules 3, 4, 7). **Needs** all three in the room and region data, with the room check rejecting a region with no region map, more than one, or no map colour (Edge Cases) | Yes, Approved (`design/gdd/level-design.md`) |
| Camera | Hard | The view rectangle each frame, clamped inside the room (rooms and transitions R4), for the reveal test (F2) | No (`src/player/player_camera.gd`) |
| Save points and save/load | Soft | Save point positions and the respawn point, for niche marks and the highlight (rule 8); its Playing state, for when the map may open (rule 11). Without it the map draws no niches | Yes, In Review (`design/gdd/save-points-and-save-load.md`) |
| Player controller | Hard | A new `map` action (none exists in `player_input_bindings.gd`; Rec: M and Tab, the gamepad's Back button), `ui_cancel` to close, move to pan; input withheld while the map is open and presses discarded on close (rules 11-13) | No (`src/player/player_input_bindings.gd`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Fast travel (Full Vision) | Soft | The niche marks, if stations are save points (Save points Open Question 7) |
| Pause and menus | Soft | The map's freeze (rule 11), which it adopts; the map screen, if it becomes a tab of the pause screen later; the rule that the map and pause never stack (Edge Cases) |
| Audio | Soft | The open and close cues (Visual/Audio) |

**Bidirectional check:**

- Rooms and transitions lists Grid map as a hard downstream ("Rooms as world-grid cells, exits as edges, the current room", rules 2, 15). Match. It should add the hidden exit mark (rule 7 here).
- World state lists Grid map as a hard downstream ("Rooms visited and regions entered"). Partial: this GDD also reads `collected`, `broken` / `open` / `found` and the respawn point, and needs the new revealed-cells entry. Its Dependencies and Interactions rows need updating.
- Level design lists Grid map as a hard downstream ("Room graph, exits, unexplored markers") and rule 23 states what the map shows. Match. It should add the region map (one per region), map colours and the secret job in the data, with their room checks. Two rows of its States table also need correcting: Room "Visited ... drives the grid map" (the map reads revealed cells, not the visited flag) and Secret "recorded for the map" (the map reads `found` only on an object that hides an exit).
- Save points hands Open Question 7 (does the map mark save points?) to this system. Answered: yes, once their cell is revealed, with the respawn niche highlighted (rule 8). Its Open Question 7 can close once this GDD is approved.
- The systems index row for Grid map lists Rooms and transitions, World state, Level design, Camera, Save points and the Player controller. Match. Fast travel already lists the systems this map reads, not the map; that is fine, since the map is soft for it.
- Story 007 (Ready) says "a save point saves ... the map's discovered rooms" and "its state is saved". That conflicts with this GDD and with World state: the map has no state of its own (rule 14), and its revealed cells are kept the moment they are revealed, not at a save point (rule 2; world state rules 5, 6). The story needs revising before it is implemented (Save points and World state already flag the same criterion).
- Camera and the Player controller have no GDD. Each needs a matching entry when it is designed.

## Visual/Audio Requirements

`art-director` lens applied in this session (lean mode spawns no agent). There is no art bible yet (`design/art/art-bible.md` does not exist), so this section follows the approved visual direction, `design/narrative/kiln-city-visual-direction.md`; the art bible, once written, owns every look named here. `audio-director` not consulted: Lean mode.

- **Ground and fill.** The map's ground is the world's ground: soot-umber, low value. A revealed cell is filled in its region's map colour at low to mid value, never brighter than the lines on it. **[Rec; visual direction: Palette and light]**
- **Lines are the brightest thing.** Room borders, exit lines and door marks are the brightest values on the map, as play-layer collision edges are in a room; one pixel wide, on whole pixels (F1). **[Rec; visual direction]**
- **No key hues, ever.** Orange, copper-green, chalk-yellow and violet are reserved for the four keys and used for nothing else; the map never marks a key (rule 10), so it never uses them, and no region's map colour may be one of them. **[Sourced: visual direction, reserved hues]**
- **The Seeker's mark** is bone-pale, the lightest matte value on the map, as the Seeker is on screen; its room is lifted one step in value. **[Rec]**
- **Marks read by shape, not colour alone.** The unexplored marker, the door mark, the niche mark and the Seeker's mark each have a distinct shape, so the map reads in greyscale and for colour-blind players. The respawn niche is highlighted by brightness, not by a reserved hue. **[Rec]**
- **Outlines.** A room outlined by the region map (rule 4) is a dithered one-pixel line in the region's colour, with no fill, clearly fainter than a revealed border. On the first opening after the region map is collected, its new outlines draw in over 0.5 s, so the find is noticed. **[Rec]**
- **In play, almost nothing.** A cell revealed in play shows no pop-up, flash or sound; the map simply holds it next time (as transitions are quiet, level design rule 21). The one exception is finding a region map (next). **[Rec]**
- **Finding a region map.** The pickup shows a one-line message, "[Region name] map found", and plays the map's rustle cue; the outlines draw in on the next open (rule 4). Without a cue the pickup changes nothing the player can see, and a player who seldom opens the map would never learn what it did. The line's look and duration belong to HUD / UX (Open Questions). **[Owner, 2026-11-20: short text line plus the rustle]**
- **Audio.** Opening plays a short dry rustle, like ash sifted across a slate; closing plays it reversed. The world's sounds stop with the freeze; music keeps playing. **[Rec]**
- **Mark sizes and stacking.** At 30 world pixels to a map pixel a niche is under one pixel, so each mark is drawn at a fixed size in map pixels, not scaled from the world. Starting sizes: the Seeker's mark 5 x 5, a niche 3 x 3 (filled), a door 3 x 5, an unexplored marker 3 x 3 (hollow), an exit line 3 long across the border. The UX spec and the art bible confirm the shapes and sizes. Marks that overlap stack, top first: the Seeker, the respawn niche, niches, doors, unexplored markers, exit lines. No mark is dropped to make room for another. **[Rec]**

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:grid-map` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

- **It is there the moment you ask.** The map is fully drawn on the first frame after the press and gone on the first frame after closing: no open or close animation, no load (the AC's one-frame budget). The only motion is the outlines' 0.5 s draw-in after a region map is found. **[Rec]**
- **Three answers at a glance.** Opened centred on the Seeker, the map answers where am I, where have I not been (markers) and where would a death send me (the highlighted niche), without panning. **[Owner, 2026-11-20: position and niches shown]**
- **The world fills in as you walk it.** Big rooms are drawn screen by screen, so a cavern half-crossed is half on the map, and the gaps are places to go back to. **[Owner, 2026-11-20: screen by screen, Ori-style]**
- **Panning is quick.** A held direction pans `pan_speed` cells a second, 30 at the start, so a full screen of map crosses in about 1 s. **[Rec]**
- **Playtest question.** Whether finding the region map feels like a reward or like a chore the player must do before the map is useful (Acceptance Criteria, [Play]).

## UI Requirements

- **The map screen.** Full screen, 480 x 270, over the frozen game (not shown behind it). It holds the map (rules 1-10), the name of the region under the screen's centre in the top-left corner (nothing when no drawn cell is under it), and one line of control glyphs at the bottom ("Map / Back: close", "Move: look"). No other text and no legend in the core build; the marks are few enough to learn by use (Open Questions). **[Rec]**
- **Input.** `map` opens and closes; `ui_cancel` closes; move pans. No mouse panning and no zoom in the core build (Open Questions). The map holds no focusable controls, so Godot 4.6's separate mouse and keyboard focus does not apply to it. **[Rec]**
- **No minimap in play.** The HUD shows no map during play in the core build (Open Questions). **[Rec]**
- **Accessibility.** Marks read by shape (Visual/Audio). Whether a screen reader can describe a custom-drawn map is not sourceable from `docs/engine-reference/godot/modules/ui.md`, which covers Control nodes only (Open Questions). **[Rec]**

> **📌 UX Flag — Grid map**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for the map screen **before** writing epics. Stories that reference UI should cite `design/ux/map-screen.md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| Rooms of whole 480 x 270 screens on one world grid; room and object ids; open edges; doors and their pairs; the room graph derived, never authored; rooms rebuilt on entry; an unbuilt region's opening is solid (rules 1-4, 7, 15, Edge Cases); the camera clamped inside the room (R4) | Rooms and transitions | `design/gdd/rooms-and-transitions.md`, Approved |
| Rooms visited; `collected`, `broken`, `open`, `found`; the respawn point; raised the moment it happens, committed at the end of the frame, forward only; absent means false; unknown ids kept, not applied (rules 1-3, 5, 6, 9, 10) | World state | `design/gdd/world-state.md`, Approved |
| The map shows rooms as boxes and exits as lines, unexplored exits as markers, never item locations (rule 23); room jobs, secret included (rule 18); secrets follow a shown pattern (rule 19); gates seen before their keys (rule 8); quiet transitions (rule 21); no room size numbers (rule 1) | Level design | `design/gdd/level-design.md`, Approved |
| Save points' arrival points, the respawn point, the Playing state; Open Question 7 (does the map mark save points), answered here | Save points and save/load | `design/gdd/save-points-and-save-load.md`, In Review |
| Ground palette, brightest edges, the Seeker the lightest matte value, the four reserved key hues | Visual direction | `design/narrative/kiln-city-visual-direction.md`, Approved |
| "Rooms with doors, save points and a grid map that fills in" (Features) | Game brief | `design/game-brief.md` |
| The input actions (no `map` action yet); the camera's view | Player controller, Camera | `src/player/player_input_bindings.gd`, `player_camera.gd`; no GDD |
| "A save point saves ... the map's discovered rooms"; "its state is saved" conflict with rules 2 and 14 (Dependencies) | Story 007 | `production/epics/guardbreak/story-007-rooms-saves-map.md`, Ready |

## Acceptance Criteria

Types: **[Auto]** unit test on the map's draw list (the cells, lines, marks and markers it would draw, as data) with World state, the room data and the camera injected as fakes (no file I/O); **[Auto, engine]** test that runs the game headless; **[UI]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest record. One criterion or more per core rule and per formula; `qa-lead` lens applied in this session (lean mode spawns no agent). All values are at `map_shrink` 30 and `reveal_cover` 0.5 unless a criterion sets them.

**Drawing**
- **GIVEN** a 4 x 5 room at world cell (3, 1) with every cell revealed, **WHEN** the map is drawn, **THEN** its box spans map pixels (48, 9) to (112, 54) before the pan, 64 x 45, with its border along the room's bounds and no line between its own cells. **[Auto]** (rules 1, 3; F1)
- **GIVEN** the Seeker entering a 3 x 2 room at cell (0, 0), **WHEN** the first frame of the fade-in runs, **THEN** cell (0, 0) is in World state's revealed cells for that room, and the other five are not. **GIVEN** the Seeker's centre moving into cell (1, 0), **THEN** (1, 0) is added on that frame and the commit at the end of the frame holds it. **[Auto, engine]** (rule 2; world state rules 5, 6)
- **GIVEN** a room with revealed cells (0, 0) and (1, 0), **WHEN** the room is moved two cells on the world grid and the save is loaded, **THEN** the same two cells of that room are drawn at its new place. **[Auto]** (rule 2; rooms and transitions rule 3)
- **GIVEN** an unentered, non-secret room in region 1 and region 1's map not collected, **THEN** the room is not drawn. **WHEN** the region map is collected, **THEN** it is drawn as an outline with no fill, no exits and no niches, and the record's only change is the map's `collected` flag. **GIVEN** a secret room in region 1, **THEN** it is not outlined. **[Auto]** (rules 4, 7)
- **GIVEN** a revealed cell with an open edge to an unentered room, a door whose pair is unrevealed, and an opening that is solid because the next region is not built, **THEN** the edge has a line and a marker, the door has a door mark and a marker, no line joins the door to its pair, and the solid opening draws nothing. **WHEN** the far sides are revealed, **THEN** both markers are gone. **[Auto]** (rules 5, 6)
- **GIVEN** an exit with a gate across it that the Seeker cannot yet cross and an unrevealed far side, **THEN** it has a marker. **GIVEN** an exit marked hidden, naming a breakable wall as its hiding object, **THEN** it draws no line and no marker until the wall is `broken`, and then both. **GIVEN** a hidden exit into a secret room with no hiding object, **THEN** it draws nothing until its far side is revealed. **GIVEN** a hidden exit whose far side is revealed first, **THEN** it draws a line and no marker. **[Auto]** (rules 6, 7, Edge Cases)
- **GIVEN** save points in a revealed cell and in an unrevealed cell of an entered room, and the respawn point naming the first, **THEN** only the first is drawn, highlighted. **GIVEN** a respawn point naming a save point that no longer exists, **THEN** no niche is highlighted. **[Auto]** (rule 8, Edge Cases)
- **GIVEN** the Seeker at local (700, 200) in a room at cell (3, 1), **WHEN** the map opens, **THEN** its mark is at map pixel (71, 16) before the pan, at the screen's centre after it, and its room is highlighted. **[Auto, engine]** (rules 9, 13; F1)
- **GIVEN** a Seeker's mark, a respawn niche, a door mark and an unexplored marker in one cell, **THEN** all four are in the draw list, in the stacking order of Visual/Audio. **GIVEN** a region map collected, **THEN** the pickup message "[Region name] map found" and the rustle cue fire once, and neither fires again after a save is loaded. **[Auto]** (Visual/Audio)
- **GIVEN** a region with every kind of object placed (keys, pickups, the region map, a gate, a boss trigger, enemies, hazards, a secret's reward), **WHEN** every cell is revealed, **THEN** the draw list holds only room cells, borders, exit lines, door marks, markers, niche marks and the Seeker's mark. **[Auto]** (rule 10; level design rule 23)

**Opening and using**
- **GIVEN** the Seeker in normal play with an enemy moving, **WHEN** `map` is pressed, **THEN** the map opens that frame and the enemy's position, every timer, the Seeker's position, the camera's position and every animation's frame are unchanged over the next 60 frames. **GIVEN** the Seeker dead, resting, arriving, entering a door or in a transition, **WHEN** `map` is pressed, **THEN** the map does not open, and it does not open later without a new press. **[Auto, engine]** (rule 11)
- **GIVEN** the map open, **WHEN** jump, attack and dash are pressed and then `map` closes it, **THEN** on the frames after closing no jump, attack or dash starts without a new press. **GIVEN** the map open, **WHEN** `ui_cancel` is pressed, **THEN** it closes. **[Auto, engine]** (rule 12)
- **GIVEN** only the start room drawn, **WHEN** move is held toward each edge for 120 frames, **THEN** the view's centre stops one cell past the room's bounds on each side. **GIVEN** the Seeker in a room at the world's edge, **WHEN** the map opens, **THEN** the view centre is on the Seeker's mark and inside the clamp. **[Auto]** (rule 13, Edge Cases)
- **GIVEN** the map opened, panned and closed, **THEN** the record is byte-identical to before and no commit followed. **[Auto]** (rule 14)
- **GIVEN** Pause and menus exists and the map is open, **WHEN** pause is pressed, **THEN** nothing happens; **GIVEN** the game paused, **WHEN** `map` is pressed, **THEN** nothing happens (written when Pause and menus is built, not before). **GIVEN** a hit that brings health to zero on the frame `map` is pressed, **THEN** the Seeker dies and the map does not open. **[Auto, engine]** (Edge Cases)

**Formulas**
- **GIVEN** `map_shrink` 30, 15 and 10, **THEN** a cell is 16 x 9, 32 x 18 and 48 x 27 map pixels and the map screen shows 30 x 30, 15 x 15 and 10 x 10 cells. **GIVEN** a `MapConfig` with `map_shrink` 0 or 20, or `reveal_cover` 0.2 or 1.1, or `pan_speed` 10 or 61, **WHEN** `validate()` runs, **THEN** it returns that value's name; **GIVEN** 30, 0.5 and 30, **THEN** it returns nothing; **GIVEN** `pan_speed` 30 and move held for 1.0 s on an open map, **THEN** the view centre has moved 30 cells along that axis, or stopped at the clamp; **GIVEN** move held diagonally for 1.0 s, **THEN** it has moved 30 cells on each axis, or stopped at the clamp; **GIVEN** a non-empty result at boot, **THEN** the title screen does not show and the names are reported. **[Auto]** (F1, F2, data check)
- **GIVEN** a 3 x 2 room and the camera's view with its top-left at (300, 100), **THEN** the covers are 0.24, 0.39, 0.14 and 0.23 for cells (0, 0), (1, 0), (0, 1) and (1, 1) to two places, and only the cell holding the Seeker's centre is revealed. **GIVEN** the view at (240, 0), **THEN** (0, 0) and (1, 0) are both revealed. **GIVEN** `reveal_cover` 0.25 and the view centred on the corner shared by four cells, **THEN** all four are revealed; **GIVEN** 1.0 and the same view, **THEN** only the Seeker's cell. **[Auto]** (F2)

**Edge cases and cross-system**
- **GIVEN** a 1 x 5 room and the Seeker's position set by a test from cell (0, 0) to cell (0, 3) in one frame, **THEN** cells (0, 0), (0, 1), (0, 2) and (0, 3) are all revealed, and (0, 4) is not. **[Auto]** (Edge Cases)
- **GIVEN** a save holding a room in rooms visited and no revealed cells for it, **WHEN** the map is drawn, **THEN** every cell of that room is drawn as revealed and the record is unchanged. **WHEN** the Seeker then reveals one cell in it, **THEN** the record holds every cell of the room and the map still draws all of them. **[Auto]** (Edge Cases; world state rule 9)
- **GIVEN** a region with no region map, one with two, or one with no map colour, **WHEN** the room check runs, **THEN** the region is rejected and named. **[Auto]** (Edge Cases; requirement on level design)
- **GIVEN** cells revealed in three rooms, **WHEN** the game is quit to the title and Continue is chosen, **THEN** the map draws the same cells. **[Auto, engine]** (rule 2; cross-system: world state rule 8)
- **GIVEN** a fixture world of 8 regions of 60 rooms of up to 20 screens, every cell revealed, on the reference machine named in the test record before the first run, **WHEN** the map opens, **THEN** it is drawn within one frame at 60 fps (16.7 ms), and the reveal test adds no more than 0.1 ms to a play frame. **[Auto, engine]** (rules 2, 11; world state's 60 fps target)

**Screens and feel**
- **GIVEN** region 1 with some rooms revealed, some partly revealed, the region map collected, two markers and two niches, one highlighted, **THEN** a screenshot of the map shows each of these. **GIVEN** the start of a new game, **THEN** a screenshot shows only the Waking Niche's cell, its niche highlighted and the Seeker's mark. **[UI]** (rules 3-9)
- **GIVEN** 5 playtesters after 20 minutes of region 1, **WHEN** each is asked to open the map and show where they have not been yet, **THEN** at least 4 point to a marker, and at least 4 can point to where a death would send them. **[Play]** (rules 6, 8; Game Feel)

**Gaps found by the QA lens:**
- The map's look (fill colours, outline, marks) is visual: its screenshots cannot be judged until the art bible gives it one (Visual/Audio).
- The performance criterion's fixture size (8 x 60 rooms) is an estimate; region 1's room count is not known until its grey-box (world state Formulas).
- Screen-reader access to a custom-drawn map is not sourceable (`docs/engine-reference/godot/modules/ui.md` covers Control nodes only), so no criterion is set for it (Open Questions).
- The hidden exit mark, the region map per region, map colours and secret jobs are requirements on Rooms and transitions and Level design; their criteria pass only once those exist (Dependencies).

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **World state: revealed cells.** It is Approved and has no field for them. Wording it needs: "**Revealed cells**: for each room id, the set of room-local cells (column, row) revealed so far, written by the Grid map; forward only", plus Grid map's rows in its Interactions and Dependencies (it reads `collected`, `broken` / `open` / `found` and the respawn point too). Owner: world state (a revision and re-review). Target: before the map story.
2. **Rooms and transitions: hidden exits.** A hidden mark on an exit in the room data, required on every exit behind a breakable wall or other hidden way and on every exit into a secret room, checked by the room check (rule 7). The mark names the hiding object, an object id in the same room, or none for an open edge into a secret room; the room check rejects a name that is not an object of that room. Owner: rooms and transitions. Target: before the map story.
3. **Level design: region maps, colours, secret jobs.** One region map per region, a map colour per region (not a reserved key hue), and each room's job readable from the data, with room checks (rules 3, 4, 7; Edge Cases). Its States rows for Room ("drives the grid map") and Secret ("recorded for the map") are corrected to what the map reads (Dependencies). Owner: level design. Target: region 1's grey-box.
4. **Room size.** The owner expects rooms of up to 20 screens, horizontal, vertical or boxy (2026-11-20). Level design rule 1 says "no size numbers" (owner, eleventh review). The map works at any size (F1); whether 20 becomes a rule, with a room check, is level design's. Owner: level design. Target: region 1's grey-box.
5. **What the region map is.** Its object and look in the world (a chalk tally board, a carrier's route slate?) and where region 1's lies. Owner: narrative, level design. Target: region 1's grey-box.
6. **A minimap in play.** Whether the HUD shows a small map during play. Owner: HUD / UX. Target: region 1 playtest.
7. **More map controls.** The map as a tab of the pause screen, mouse panning, zoom, a legend, and player-placed pins. Owner: Pause and menus, UX. Target: Vertical Slice.
8. **Screen reader.** Whether a custom-drawn map can be described to a screen reader (AccessKit) is not sourceable from `docs/engine-reference/godot/modules/ui.md`. Owner: UX / accessibility. Target: `design/accessibility-requirements.md`.
9. **Story 007.** Its criteria "a save point saves ... the map's discovered rooms" and "its state is saved" conflict with rules 2 and 14; revise it once this GDD is approved. Owner: producer (`/create-stories`). Target: after approval.
10. **Fast travel.** Whether stations are save points, using the niche marks. Owner: Fast travel. Target: its GDD.
11. **The region map's pickup message.** Its look and duration, and the first-time hint to open the map, if any. Owner: HUD / UX. Target: region 1 playtest.
