# World state

> **Status**: In Review
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Creative Director Review (CD-GDD-ALIGN)**: skipped — Lean mode
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room")

## Summary

World state is the game's one record of what the player owns and what the world has become: keys, opened shortcuts, broken walls, beaten bosses, found secrets, visited rooms. Every change is kept the moment it happens and written to the single save file at the end of that frame, and nothing earned ever moves backward, so dying never takes back what was earned. It exists so that rooms can be rebuilt as the player left them, gates and the grid map can read progress, and a quit or a crash costs almost nothing while writes succeed: a quit loses nothing, and a crash loses at most the changes made since the last commit began (one frame when a write finishes within its frame).

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Player controller`

## Overview

World state is the game's one record of what the player owns and what the world has become: the movement keys owned, the gates seen and passed, the shortcuts opened, the walls and panes broken, the bosses beaten, the regions entered, the secrets and sealed alcoves found and the rooms visited. Each entry is keyed by a stable id: a room id and an object id for anything placed in a room (rooms and transitions rule 3), a key id for the movement keys. It only moves forward: no key, flag, room or region is ever taken back, and death undoes none of it (the respawn point alone is replaced, rule 3). A change is kept the moment it happens and written to the single save file at the end of the frame it happened in (or with the next commit, if one is still being written), so a key picked up and the pickup gone always land together. Death only sends the Seeker back to the last save point with full health (Save points). The player never operates this system. They feel it as a world that remembers: a shortcut opened stays open, a beaten boss stays beaten, and dying never takes back what was earned. Without it, rooms could not be rebuilt as the player left them, gates could not be read, the grid map could not fill in, and nothing would survive a quit. The record's format on disk and how it is written are an ADR, not this document. **[Owner, 2026-11-20: death undoes nothing; world state owns the durable write; one save slot; commit at the end of the frame]**

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Rec]** = recommendation, change freely. Engine details (file format, the write path, atomic replace) are not covered by `docs/engine-reference/godot/` (no `core.md`) and belong to the ADR (Open Questions).

`systems-designer`, `gameplay-programmer` and `engine-programmer` not consulted: Lean mode. Review manually before production.

**What the record holds**

1. **One record.** World state is a single record per save. It holds:
   - **Keys**: the set of movement keys owned (dash, wall cling, double jump, grapple; ability gating rule 1).
   - **Object flags**: for each object placed in a room, keyed by (room id, object id) (rooms and transitions rule 3), the set of its **flags** that have been raised.
   - **Rooms visited**: the set of room ids the Seeker has entered.
   - **Regions entered**: the set of region ids the Seeker has entered.
   - **Respawn point**: the (room id, object id) of the last save point used, written by Save points.

   Nothing else is in it. Not terrain (terrain rule 4), the Seeker's position, velocity or health, live enemies, the room the Seeker is standing in, or settings and key bindings (Pause and menus keeps those in a file of its own). **[Rec]**
2. **Flags.** A flag is a named fact about one object that starts false and can only become true: `open` (a shortcut or door), `broken` (a breakable wall or bisque pane), `defeated` (a boss trigger), `found` (a secret or sealed alcove), `collected` (a pickup that is not a key pickup: a key pickup has no flag of its own, since the key owned is its record and a pickup whose key is owned frees itself, ability gating rule 5; owner, 2026-11-20), `seen` and `passed` (a gate; level design States). The system that owns an object type names its flags. This system stores them without knowing what they mean, and does not check a raised flag name or key id against its owner's list: a name no system knows (a typo) is stored like any other and kept (rule 10), so each owner's own tests have to catch it (owner, 2026-11-20). A gate holds two flags because Seen and Passed are set independently. Passable is derived from the keys and never stored (level design States). **[Rec; the flag set: level design States, ability gating rule 17]**
3. **Forward only.** Keys, flags, rooms visited and regions entered can only be added, never removed. The record offers no way to lower a flag or drop a key, so no system can move a state backward (level design States: "No state in this table can move backward"). The respawn point is the one field that is replaced, not only added to. Only a **new game** starts an empty record. **[Owner, 2026-11-20: death undoes nothing]**
4. **Death undoes nothing.** Dying does not touch the record. Everything raised before the death stays raised, whether or not a save point was used since. Death moves the Seeker to the respawn point with full health; Save points owns that move and the heal. **[Owner, 2026-11-20]**

**Writing it down**

5. **Raised the moment it happens.** A system changes the record on the frame its event happens: a key on the frame its pickup is touched (ability gating rule 5), `broken` on the frame a pane breaks, `defeated` on the frame the boss dies, `seen` on the first frame a gate is on screen, a room and its region on the frame the room becomes Active (rooms and transitions, States). A change made twice is one change, on one frame or across frames: raising an entry the record already holds is **not a change**, and neither is writing the respawn point the record already holds. It marks nothing Dirty and commits nothing. This covers the echo of a load (setting the keys into `PlayerState` emits `abilities_changed`, which would raise each key again, rule 8) and a flag a system re-raises every frame, such as `seen` while a gate stays on screen. **[Rec; ability gating rule 5]**
6. **Committed at the end of the frame.** Every change made during a frame is written to the save file together, once, after that frame's gameplay has run. A frame here is one rendered frame: every physics step and every process call in it, so a frame that runs two physics steps still commits once. A frame with no change writes nothing. While a commit is failing, the end-of-frame commit gives way to the retry cadence (Edge Cases). The file on disk always holds a whole record: the one committed before or the one committed now, never a mix. A commit writes a **snapshot** of the record taken at the end of its frame, never the live record, so whatever writes it, on whichever thread, holds exactly that frame's changes and nothing a later frame adds. So everything raised on one frame lands together or not at all: a key with any flag raised on its frame, and the key on disk always means its pickup gone (ability gating Edge Cases). Each commit keeps the file it replaces as the **last good copy**, but only a file that was read back as valid (loaded at start, or written by an earlier commit of this run) takes that place: an unreadable file never replaces the last good copy (Edge Cases). Commits never overlap: one still being written is finished before the next starts, and changes made meanwhile wait as pending and go out together in the next commit, whose snapshot is taken at the end of the first frame in which the one before has finished; one in flight when the game quits is finished first, and then one more commit writes whatever is pending, so a quit loses nothing while writes succeed (while one is failing: Edge Cases). A crash is different: it loses everything changed since the snapshot of the commit then being written was taken, which is that frame and any frame whose changes wait as pending behind it: one frame when a commit finishes within its frame, more when it does not (Edge Cases). Whatever does the committing outlives scene changes, so a death reload or a room swap never drops a pending commit. How, and on which thread, is the ADR's (Open Questions 1). **[Owner, 2026-11-20: end of the frame]**
7. **One save file.** The game has one save. A new game asks before it replaces an existing save (Save points owns the prompt). More slots can be added later without changing the record. **[Owner, 2026-11-20: one slot]**

**Reading it back**

8. **Loaded once, read by everyone.** The file is read only while the **commit chain is idle**: no commit in flight and nothing pending. After a quit to the title, the title screen shows at once but offers Continue and new game only once the dropped record's in-flight commit has finished and its last pending commit has been attempted, with the loading mark shown until then, so Continue never reads a file older than the record just dropped, and no late commit can land over a record loaded before it (owner, 2026-11-20). On Continue, the record is read from the file before the first room is built. `PlayerState` is first reset to owning nothing (a new game and a Continue both start from nothing, so keys from an earlier record in the same run never carry over), then the keys are set into it (ability gating rule 1), and each room build applies its objects' flags (rooms and transitions rule 12). During play every system reads the record in memory, never the file. **[Rec]**
9. **Absent means false.** An object, room, region or key the record does not mention has no flag raised: unopened, unbroken, unseen, unvisited, unowned. So a new object added to a room, or a new field added by a later system, reads as untouched on an old save without any migration step. **[Rec; story 007: later systems add fields without breaking old saves]**
10. **Unknown ids are kept, not applied.** An entry whose room, object, flag or key the current game no longer has is ignored at build (rooms and transitions rule 3, Edge Cases) and kept in the record, written back unchanged. Because ids are never reused, it can never be applied to the wrong object. Rooms and transitions rule 3 guarantees that for room and object ids only. **Region ids** and **key ids** are keyed the same way and need the same never-changed, never-reused rule: a requirement on Level design (region ids) and Ability gating (key ids), neither of which states it yet (Dependencies). **[Rec]**
11. **Versioned.** The record carries a format version, a whole number. Loading an older version upgrades it in steps, one version at a time, before anything reads it. A record of a newer version than the game knows is not loaded and not overwritten (Edge Cases). **[Rec; story 007: versioned save file]**
12. **Rewards are derived, not stored.** A reward tied to a flag is not a fact of its own in the record. The event raises the flag (`defeated`), and the system that gives the reward then derives it from the record with one function: present while the flag is raised and the reward is not yet taken (a key reward: the key unowned, ability gating rule 5; any other: its `collected` flag unraised). That function runs on the frame the flag is raised, so a boss beaten in the live room drops its reward at once, and again at each room build, so a quit, a crash or a death between a boss's `defeated` and the pickup leaves the reward waiting on reload, and a key can never be lost to that window. Bosses and Level design own the reward objects; this system owns that both facts are durable. **[Rec; level design rule 12: no soft-lock, no missed boss trigger]**

### States and Transitions

**The record in memory** (one per running game):

| State | Meaning | Enter when | Leave when |
|---|---|---|---|
| Empty | No record: title screen, before a new game or Continue | The game starts; or the Seeker quits to the title screen (Pause and menus), which drops the record (a Dirty one after its in-flight commit finishes and one last attempt writes what is pending, Edge Cases) and resets `PlayerState` to owning nothing (rule 8) | Only once the commit chain is idle (rule 8): a new game is started: to Dirty (the empty record, committed at once); Continue loads the main file: to Clean, or the last good copy: to Dirty (the file table below) |
| Clean | The record in memory equals the save file in what it holds (an older file upgraded in memory counts: it loads the same way again, and the first commit writes the new version) | A load of the main file, or a commit that succeeded with no change made while it was being written | Any change is made (not a re-raise of an entry already held, rule 5): to Dirty |
| Dirty | Changes made this frame, a new game's empty record, or a record recovered from the last good copy, are not yet in the main file | From Clean; a new game; a commit failed; a commit succeeded while changes made during its write were still pending; or a load from the last good copy | The frame ends: commit (while a commit is failing, the next retry instead; while one is being written, the next commit at the end of the first frame in which it has finished, holding every change made meanwhile: Edge Cases). Success: to Clean. Failure: stays Dirty; the next attempt comes after `commit_retry_interval`, with every change still pending (Edge Cases) |

**The save file**, as found when the game starts:

| Found | Meaning | What happens |
|---|---|---|
| None | No save yet: neither the main file nor a last good copy exists | Continue is not offered; a new game commits its empty record at once, which creates the file (Edge Cases) |
| Current | Same version as the game | Loads |
| Older | A version below the game's | Upgraded in memory, step by step (rule 11), then loads; the next commit writes the new version |
| Newer | A version above the game's (an older build opening a newer save) | Not loaded, not overwritten; Continue says it needs a newer version of the game |
| Unreadable | Cut short, corrupted or not a save; or missing while a last good copy exists (owner, 2026-11-20: missing counts as unreadable) | The last good copy is loaded instead and the record starts Dirty, so the first commit rewrites the main file. If there is no readable last good copy (it is unreadable too, or there is none), Continue says the save cannot be read (Edge Cases) |

### Interactions with Other Systems

Ability gating, level design and rooms and transitions have GDDs. The other interfaces are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|---|---|---|---|
| Player controller (`PlayerState`) | Both | In: key granted (`abilities_changed`). Out: owned keys set on load | `PlayerState` holds the live keys (ability gating rule 1); this system stores them |
| Ability gating | In | Keys granted; `broken` on panes (rules 5, 17). Reads the keys for Passable | Ability gating owns what is stored; this system owns storage |
| Level design | Both | In: the flag set and what raises each flag (States table). Out: the forward-only guarantee (rule 3) | Level design owns what a state means; this system owns that it holds |
| Rooms and transitions | Both | In: room ids and object ids (rule 3); a room and its region entered when the room becomes Active. Out: each room's object flags, applied at each build (rule 12) | Rooms owns the ids; this system owns the flags |
| Save points and save/load | Both | In: the respawn point; the new-game prompt. Out: the respawn point on death and on Continue; whether a save exists and its version | Save points owns the respawn, the heal, Continue and the prompts; this system owns the record and the file |
| Grid map | Out | Rooms visited, regions entered | Grid map |
| Bosses | Both | In: `defeated` on the boss trigger (existing `boss_defeated` signal). Out: the record, read at each build, so the boss's reward is present while `defeated` is raised and the reward not taken, derived on the frame `defeated` is raised and again at each build (rule 12) | Bosses owns the reward object; this system owns that both facts are durable |
| Enemies | In | `defeated` on an enemy that stays dead, where the Enemies GDD makes one (rooms and transitions Open Question 5); region 1's Half-glazed Waster is the first (Open Questions 3) | Enemies |
| Fast travel, Collectible upgrades, Lore delivery | In | Their own flags on their own objects (a station reached, an upgrade collected, a pact made) | Each system names its flags |
| Pause and menus | Both | In: quit chosen (an immediate write attempt, then the confirmation while a commit is failing), quit to the title screen (the record is dropped and `PlayerState` reset, States). Out: whether a commit is failing, whether the commit chain is idle (the title offers Continue and new game only then, rule 8), and the title screen's messages (UI Requirements). Settings and bindings are not in this record: they are kept in a separate file | Pause and menus owns the screens and the quit flow; this system owns the facts they report |

## Formulas

None. World state defines no rate, curve, threshold or cost: it stores facts raised by other systems and writes them down, and no value in it is tuned in a balance pass. The quantities it names are counts and identities, not tuning: one save file (rule 7), at most one commit a frame (rule 6), a whole-number format version (rule 11). The one timing, `commit_retry_interval` (Tuning Knobs), sets how often a failing write is retried, and the 4 ms commit budget is a cost target (Acceptance Criteria); neither is a balance value. `systems-designer` lens applied in this session (lean mode spawns no agent): no formula to run at its boundaries, and no feedback loop, since the record grows only with what the player does and never feeds back into it. Its size is bounded by the world's content (every key, object flag, room and region in the game, plus any ids from older releases that rule 10 keeps), not by play time.

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

**Writing**
- **If the game crashes or loses power while a commit is being written**: the file still holds the whole record committed before (rule 6). Lost is everything changed since that commit's snapshot was taken: the frame being written, plus every frame whose changes were waiting as pending behind it. That is one frame when a commit finishes within its frame, and as many frames as a write lasts when it does not (whether it does is the ADR's, Open Questions 1). Changes of one frame are lost together: a key and any flag raised on its frame are both kept or both lost, and the key's pickup is gone exactly when the key is kept (ability gating Edge Cases). **If the game is quit while a commit is being written**: the commit is finished first, then one more commit writes whatever is pending (rule 6), so nothing is lost while writes succeed. **[Rec]**
- **If the Seeker quits to the title screen while a commit is in flight or changes are pending**: the in-flight commit is finished, then one last attempt writes what is pending, as for a quit to the desktop. The title screen shows at once, but Continue and new game wait, with the loading mark, until that is done (rule 8). Otherwise Continue could read the file before the commit lands, load an older record as Clean, and the next commit would write it over the newer one, moving a `defeated` or a key backward (rule 3). While a commit is failing, the quit is confirmed first and the one last attempt is the one the next bullet describes. **[Owner, 2026-11-20: the title waits]**
- **If a commit fails** (disk full, no permission): the record stays Dirty in memory and play goes on. The end-of-frame commit gives way to a **retry cadence**: the next attempt comes `commit_retry_interval` (Tuning Knobs) after the failed one, or at once on a room change and when quit is chosen. A change made in the meantime is not written at its own frame end: it waits as pending and goes out with the next attempt, so a full disk costs one write attempt per interval, never one per frame. Every attempt holds every change still pending, so nothing is dropped while the game runs. A failed commit leaves the file on disk whole (rule 6). From the first failure until a commit succeeds, a small "not saved" mark shows (UI Requirements), and quitting asks for confirmation because recent progress would be lost. If the Seeker confirms, one last attempt is made, and whatever it does not write is lost, with the record when the quit is to the title screen (owner, 2026-11-20: a confirmed quit drops it; no retry runs on the title screen). Once a commit succeeds the record is Clean and the end-of-frame commit resumes. **[Owner, 2026-11-20: a new change waits for the next retry]**
- **If two systems raise the same flag, or one system raises it twice, on one frame**: it is one change (rule 5). **If an entry the record already holds is raised again on a later frame** (`seen` every frame, the echo of a load): it is not a change, and a frame with only such raises commits nothing (rule 5). **[Rec]**
- **If the Seeker dies on the frame a flag is raised** (a pickup touched as a hit lands, a boss beaten by a trade): the flag stays raised (rule 4) and is committed at the end of that frame. **[Owner, 2026-11-20: death undoes nothing]**
- **If the game quits, crashes or the Seeker dies between a boss's `defeated` and the reward being taken**: `defeated` is already committed (rule 6) and the reward is built from the record at the next build (rule 12), so it waits where it dropped: a key reward with the key still unowned and the pickup present. It is never lost, and touching it then grants the key once. **[Rec]**
- **If a system tries to raise a flag on an object with no object id**: the change is refused and logged as a defect, and nothing is written for it. The room check already rejects such an object (rooms and transitions rule 3), so this only happens in a broken build. A flag name or key id nobody registered is not refused (rule 2). **[Rec]**
- **If a gate is passed without its key** (a leak, level design rule 12): `passed` is raised like any other flag, and the key stays unowned. Level design logs the case for playtest review; this system does not refuse it. **[Rec]**

**Reading**
- **If the save file is unreadable** (cut short, corrupted, not a save): the last good copy is loaded instead and the record starts Dirty, so the first commit, at the end of that frame, rewrites the main file. That commit does not turn the unreadable file into the last good copy (rule 6): the good copy keeps its bytes until a file read back as valid can replace it, so an interrupted repair still leaves a loadable file. Each commit keeps the file it replaces as the last good copy, so at most one commit's changes are lost. A main file that is missing while a last good copy exists is treated the same way: the copy loads and the record starts Dirty (owner, 2026-11-20). If the last good copy is unreadable too, or there is none, Continue says the save cannot be read and offers a new game; neither file is deleted, and a new game over them keeps both aside as kept copies (below), so they can still be recovered by hand. **[Rec; Owner, 2026-11-20: keep unreadable saves aside]**
- **If the save file is of a newer version than the game** (an older build opening a newer save): it is not loaded and not overwritten (rule 11). Continue says the save needs a newer version of the game. A new game in this build warns that it would replace a newer save before it does. Once confirmed, the newer save is not deleted: it is copied aside as a **kept copy** that no commit rotates or overwrites, so a player can restore it by hand. The game never offers it: no build reads a kept copy by itself (owner, 2026-11-20). It is not the last good copy, which the next commit would replace within seconds. The copy is made first, and the new game goes ahead, and the empty record is committed, only once the copy exists; if copying fails, the new game does not start and says why. A second confirmed new game over another newer or unreadable save replaces the kept copy. **[Owner, 2026-11-20: keep it]**
- **If the record names a room, object, flag or key the game no longer has**: it is kept and not applied (rule 10). If the respawn point names a save point that no longer exists, Save points picks the arrival (rooms and transitions Edge Cases: the region's first save point). **[Rec]**
- **If an object is moved to a different room in the data after release**: it gets the new room's id pair, so to an old save it is a new object, unopened and unbroken, while the old entry is kept and not applied. Moving an object within its room keeps its id (rooms and transitions rule 3). The room check cannot see across releases, so this is a release rule for level design: once released, an object that keeps its state stays in its room. **[Rec]**

**New game and slots**
- **If a new game is started while a save exists**: Save points asks first (rule 7). Once confirmed, the empty record is committed at once, so the old save is replaced even if the player quits before anything happens. The record is Dirty until that commit succeeds (States). If it fails, it is handled like any failed commit: the new game goes on, the retry cadence runs, the "not saved" mark shows and quitting asks first; until a commit succeeds the old save is still the file, so a confirmed quit leaves it there (owner, 2026-11-20). The old save becomes the last good copy until the next commit replaces it, provided it was read back as valid; if it was not, the existing last good copy stays (rule 6). A newer-version save, or an unreadable pair of files, is the exception: it is kept aside instead (above). **[Rec]**
- **If Continue is chosen and the save holds no respawn point** (a new game quit before its first save point): the game starts at the new game's start point, with every flag the save holds still raised. **[Rec]**

## Dependencies

The systems index places this system in the Core layer, depending on Player controller. Ability gating, level design and rooms and transitions have GDDs; the rest are not designed.

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Player controller (`PlayerState`) | Hard | The live keys and a signal when one is granted (`abilities_changed`); a way to set them on load (rule 8). `player_state.gd` holds two of the four keys today (double jump, grapple); dash and wall cling are ability gating's code change. Before story 007, `PlayerState` needs all four keys, a reset to owning nothing and a way to set the owned keys on load (rule 8); no GDD states that interface yet | No (`src/player/player_state.gd`) |
| Rooms and transitions | Soft | Room ids and object ids that never change and are never reused (its rule 3). Without them the record still holds keys, but no object flag can be keyed. The id rule is already set by an approved GDD, so this is an interface, not a design-order dependency | Yes, Approved (`design/gdd/rooms-and-transitions.md`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Ability gating | Hard | Keys and broken panes kept the moment they change and restored on load (its rules 1, 5, 17) |
| Level design and world layout | Hard | Every flag in its States table kept, forward only (rule 3) |
| Save points and save/load | Hard | The record, the file, the respawn point, whether a save exists and its version (rules 1, 7, 11) |
| Grid map | Hard | Rooms visited and regions entered |
| Fast travel (Full Vision) | Hard | Its stations' flags |
| Collectible upgrades | Hard | Its pickups' `collected` flags |
| Lore delivery and mentor pact | Hard | Its flags (a pact made, a line heard) |
| Rooms and transitions | Soft | Each room's object flags, applied at each build (its rule 12); without them a room builds from its data alone |
| Bosses | Soft | `defeated` kept (today `boss_arena.gd` holds `is_boss_defeated` in memory only), and its reward built from the record (rule 12) |
| Enemies | Soft | `defeated` on an enemy that stays dead, if the Enemies GDD makes one |
| Pause and menus | Soft | The quit flow: one last write attempt and a confirmation while a commit is failing, and the record dropped on quit to the title (States); Continue and new game offered only once the commit chain is idle (rule 8); the title screen's Continue and new-game messages (UI Requirements) |

**Bidirectional check:**

- Ability gating lists World state as a hard upstream dependency ("Storage of keys owned and panes broken, written at the moment of change and restored on load"). Match: rules 1, 5 and 6 here.
- Level design lists World state as a hard upstream dependency, "provisional", and its Interactions row lists every flag in its States table. Match: rule 2 here. Its rows should drop "provisional" and name this GDD once it is approved.
- Rooms and transitions lists World state as a soft upstream (its rule 12), keyed by (room id, object id). Match.
- The systems index lists Save points, Grid map, Fast travel, Collectible upgrades and Lore delivery as depending on World state. Match. Bosses and Enemies do not list it; each should add it (soft) when designed.
- The index's Overview line already reads "written the moment it changes; save points set the respawn point". Match with rule 6 here and ability gating rule 5.
- Rooms and transitions rule 3 fixes room and object ids only. **Region ids** (Level design) and **key ids** (Ability gating) need the same never-changed, never-reused rule (rule 10); neither GDD states it yet.
- Level design should name the release rule from Edge Cases (an object that keeps its state stays in its room once released), and, with Bosses, that a boss's reward is built from the record (rule 12). The room check cannot see across releases (Open Questions 6).
- Ability gating, Level design and Rooms and transitions still list this dependency as "provisional" or "Not Started"; each should name this GDD once it is approved.
- Story 007 (Ready, written from the brief) says "a save point saves the room, the owned abilities, the boss-defeated flag and the map's discovered rooms". That conflicts with rules 1, 4 and 6 (every change is committed at the end of the frame, and no current room is stored, only the respawn point). The story needs revising before it is implemented, once World state and Save points are approved.
- Player controller, Save points, Grid map, Fast travel, Collectible upgrades, Lore delivery, Bosses and Enemies have no GDD yet. Each needs a matching entry when it is designed. Enemies also needs an object id on an enemy that stays dead (rooms and transitions rule 3 lists none for enemies).

## Tuning Knobs

One value, kept in a data file, not in code. It is not a balance value; the format version and the single slot (rules 7, 11) are not knobs. There is no batching delay: the commit is at the end of the frame (rule 6, owner). If Open Questions 2 shows writes are too frequent, a delay is designed then, with its own rules, and not before (owner, 2026-11-20).

| Knob | Default | Safe range | What it affects |
|---|---|---|---|
| `commit_retry_interval` | 1 s | 0.25-5 s | How soon a failed commit is tried again (Edge Cases). Below 0.25 s a full disk stalls frames; above 5 s the "not saved" mark stays up longer and a quit is more likely to lose progress. **[Rec]** |

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. The art bible (not yet written) owns every look named here.

- **No save effect.** A commit shows and plays nothing: the record is written many times a play session, so a flash or sound on each write would be noise. A save point's own effect when used belongs to Save points. **[Rec]**
- **"Not saved" mark.** Only while a commit is failing (Edge Cases): a small mark in a screen corner. Until the art bible gives it a look, a plain pale glyph, like the loading mark of rooms and transitions. **[Rec]**

## Game Feel

- **Nothing earned is lost.** The player should never have to replay to get back a key, a shortcut or a boss, and should never wonder whether something "counted". Dying costs the walk back from the save point, not progress. **[Owner, 2026-11-20: death undoes nothing]**
- **Saving is invisible.** The player never waits on a save and never chooses to save to keep what they did; using a save point only moves where they come back. Whether players still look for a "saved" confirmation at save points is a playtest question for Save points.

## UI Requirements

- The "not saved" mark (Edge Cases, Visual/Audio) is the only in-play element this system shows. It is not interactive.
- Messages this system supplies to the title screen and menus, which Save points and Pause and menus show: the save needs a newer version of the game; the save cannot be read; a new game will replace the existing save (or a newer one); quitting now loses recent progress.
- These are screens other systems own, so their layout is theirs. This system owns the facts the messages report.

> **📌 UX Flag — World state**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to (the "not saved" mark, the title screen's Continue messages) **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| `PlayerState` is the one place key ownership lives; four keys; a key recorded at pickup; a quit on the pickup frame leaves both or neither (rules 1, 5, Edge Cases) | Ability gating | `design/gdd/ability-gating.md`, Approved |
| Panes stay broken, recorded by id (rule 17) | Ability gating | Approved |
| The flag set: keys, gate Seen and Passed (Passable derived), shortcuts, bosses, regions, secrets, sealed alcoves, rooms; no state moves backward (States) | Level design | `design/gdd/level-design.md`, Approved |
| Leaks set Passed without the key and are logged (rule 12, States) | Level design | Approved |
| Room ids and object ids, never changed or reused; ignored when the object is gone (rule 3, Edge Cases) | Rooms and transitions | `design/gdd/rooms-and-transitions.md`, Approved |
| Saved states applied at each build; everything else rebuilt from data (rule 12) | Rooms and transitions | Approved |
| A cut room's save loads at the region's first save point (Edge Cases) | Rooms and transitions | Approved |
| Terrain never changes at runtime, so world state stores no terrain (rule 4) | Terrain pipeline | `design/gdd/terrain-pipeline.md`, In Review |
| A versioned save file built as data, so later systems add fields (kept). Its criterion "a save point saves the room, the owned abilities, the boss-defeated flag" conflicts with rules 1, 4 and 6 (Dependencies) | Story 007 | `production/epics/guardbreak/story-007-rooms-saves-map.md`, Ready |
| Death respawns at the last save point (Goal & fail state) | Game brief | `design/game-brief.md` |
| `has_double_jump`, `has_grapple`, `abilities_changed`; `boss_defeated` | Player controller, Bosses | `src/player/player_state.gd`, `src/enemies/boss/boss_arena.gd`; no GDD |

## Acceptance Criteria

Types: **[Auto]** unit test on the record with an in-memory store injected in place of the file (no file I/O); **[Auto, file]** integration test writing a real file in a temporary folder; **[Auto, engine]** test that runs the game headless; **[UI]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest or hardware record. Formulas defines no formula, so every criterion comes from Detailed Design and Edge Cases. `qa-lead` lens applied in this session (lean mode spawns no agent).

**What the record holds**
- **GIVEN** a new game, **WHEN** the record is inspected, **THEN** it holds an empty key set, no object flags, no rooms visited, no regions entered and no respawn point. **GIVEN** the Seeker at 40 health in room R after a commit, **THEN** the record holds no position, velocity, health or current room. **[Auto]** (rule 1)
- **GIVEN** gate `g1` in room `r1`, **WHEN** only `passed` is raised on it, **THEN** `(r1, g1)` holds `passed` and not `seen`, and no `passable` flag exists in the record. **[Auto]** (rule 2)
- **GIVEN** a fixture list of 50 raise calls (keys, flags, rooms and regions, not the respawn point, which rule 3 replaces) applied in order, **WHEN** the record is inspected after each call, **THEN** every entry present before the call is still present after it. **GIVEN** the record's public interface, **THEN** it has no call that removes a key, flag, room or region. **[Auto]** (rule 3)
- **GIVEN** shortcut `s1` opened, the double jump owned and no save point used since, **WHEN** the Seeker dies and respawns, **THEN** `s1` is still open, the double jump still owned, and the record's entries are the same as before the death. **[Auto, engine]** (rule 4)

**Writing it down**
- **GIVEN** a double jump pickup, **WHEN** the Seeker touches it on frame N, **THEN** on frame N the record holds the key, the pickup is gone, and the record holds no `collected` flag for that pickup. **[Auto, engine]** (rules 2, 5)
- **GIVEN** three changes on frame N and none on frame N + 1, **WHEN** both frames end, **THEN** the store receives exactly one commit, after frame N, holding all three changes, and none after frame N + 1. **GIVEN** the same flag raised twice on frame N, **THEN** the commit holds it once. **[Auto]** (rules 5, 6, Edge Cases)
- **GIVEN** a save loaded with the double jump owned, **WHEN** the keys are set into `PlayerState`, `abilities_changed` fires and one idle frame passes, **THEN** the store receives no commit. **GIVEN** a gate on screen for 600 frames, **THEN** the record holds `seen` and the store received one commit for it. **[Auto]** (rule 5, Edge Cases)
- **GIVEN** a commit interrupted part-way by a test hook, **WHEN** the file is read back, **THEN** it is the whole record committed before, byte for byte. **[Auto, file]** (rule 6, Edge Cases)
- **GIVEN** a key touched on frame N and the commit for frame N either completed or not started, **WHEN** the game is reloaded, **THEN** the key is owned and the pickup gone, or the key is unowned and the pickup present, never one without the other, whichever of the two the commit left on disk. **[Auto, file]** (rule 6; cross-system: ability gating Edge Cases)
- **GIVEN** a pickup touched on the frame the Seeker's health reaches zero, **THEN** its entry (the key for a key pickup, else its `collected` flag) is raised, committed at the end of that frame, and still raised after the respawn. **[Auto, engine]** (Edge Cases, rule 4)
- **GIVEN** an existing save, **WHEN** a new game is confirmed, **THEN** an empty record is committed on that frame and the old save becomes the last good copy. **[Auto, file]** (rule 7, Edge Cases)
- **GIVEN** an existing save and a store that fails every write, **WHEN** a new game is confirmed, **THEN** the new game starts, the record is Dirty, the retry cadence runs, the main file still holds the old save byte for byte, and after a confirmed quit Continue loads that old save. **[Auto, file]** (States, Edge Cases)

**Reading it back**
- **GIVEN** a save with the double jump owned and shortcut `s1` open in room R, **WHEN** Continue is chosen, **THEN** `PlayerState.owns(double_jump)` is true before the first room is built, and room R is built with `s1` open. **[Auto, engine]** (rule 8; cross-system: rooms and transitions rule 12)
- **GIVEN** a loaded record and a store that fails every read after the load, **WHEN** play runs through a room change and a pickup, **THEN** no read reaches the store. **[Auto]** (rule 8)
- **GIVEN** a run that Continued a save with the dash owned, **WHEN** the Seeker quits to the title and starts a new game, **THEN** `PlayerState` owns no key and the record is empty. **[Auto, engine]**, once Pause and menus exists (rule 8, States)
- **GIVEN** a boss in the live room with a key reward not yet owned, **WHEN** the boss dies on frame N, **THEN** `defeated` is in the record on frame N and the key pickup is present on frame N without the room being left, and it is the same pickup a rebuild of that room would make. **[Auto, engine]** (rule 12)
- **GIVEN** a boss defeated on frame N whose key reward has not been touched, **WHEN** the game is quit after frame N and reloaded, **THEN** the room builds with the boss defeated, the key unowned and the key pickup present, and touching it grants the key once. **[Auto, engine]** (rule 12, Edge Cases)
- **GIVEN** a save that does not mention object `s2`, **WHEN** it is loaded and `s2` is in room R's data, **THEN** `s2` builds closed. **[Auto]** (rule 9)
- **GIVEN** a save holding `(r9, x1)` for a room the game no longer has, **WHEN** it is loaded and a later change is committed, **THEN** the file still holds `(r9, x1)` unchanged, and no room applies it. **GIVEN** a save holding a flag the game has no name for on a known object and a key id the game has no key for, **THEN** both are kept and written back unchanged and nothing applies them. **GIVEN** a version 1 fixture holding an unknown entry, **THEN** the entry survives every upgrade step. **[Auto]** (rule 10, Edge Cases)
- **GIVEN** a version 1 fixture and a game at version 3, **WHEN** it is loaded, **THEN** the upgrade steps 1 to 2 and 2 to 3 run in that order before anything reads it, and the next commit writes version 3. **GIVEN** a version 4 file, **THEN** it is not loaded, its bytes are unchanged, and Continue shows the "needs a newer version" message. **[Auto]** for the record, **[UI]** for the message (rule 11, States)

**Edge cases that could ship broken**
- **GIVEN** a store that fails its next 3 write attempts and a test clock, **WHEN** a change is made on frame 1 (that frame's commit is attempt 1 and fails) and further changes on frames 2, 3 and 4, **THEN** no write attempt is made on frames 2, 3 or 4. **WHEN** the clock advances by `commit_retry_interval`, attempt 2 fails, and then after each further interval attempt 3 fails and attempt 4 succeeds, **THEN** attempt 4 holds every change from all 4 frames, the record is Clean, and the end-of-frame commit resumes. **[Auto]** (rule 6, Edge Cases)
- **GIVEN** a failing store with pending changes, **WHEN** the Seeker changes room, **THEN** an attempt is made on that frame, ahead of the interval. **[Auto, engine]** (Edge Cases)
- **GIVEN** a failing store with pending changes, **WHEN** quit is chosen, **THEN** an attempt is made at once and, if it fails, the game asks for confirmation; once confirmed, one last attempt is made and the process exits. **[Auto, engine]** for the attempt and the order, **[UI]** for the prompt (Edge Cases)
- **GIVEN** a failing store, **THEN** the "not saved" mark shows from the first failure until a commit succeeds and not before or after. **[UI]** (Edge Cases)
- **GIVEN** a failing store with pending changes, **WHEN** quit to the title screen is confirmed, **THEN** one last attempt is made, the record is dropped, no retry runs on the title screen, and Continue then loads the file as last committed. **[Auto, engine]**, once Pause and menus exists (States, Edge Cases)
- **GIVEN** a commit held in flight by a test hook and changes made on the next two frames, **THEN** no second write starts until the first is finished, the in-flight commit holds none of the later changes (a snapshot, rule 6), and the next commit holds both frames' changes. **GIVEN** quit chosen while one is in flight, **THEN** it is finished before the process exits and the file holds it. **[Auto, file]** (rule 6, Edge Cases)
- **GIVEN** a commit held in flight by a test hook and a key touched on the next frame, **WHEN** the in-flight commit succeeds, **THEN** the record is Dirty, the next commit holds the key, and only after that commit succeeds is the record Clean. **WHEN** quit is chosen instead while that commit is in flight, **THEN** the in-flight commit finishes, one more commit writes the key, and only then does the process exit. **[Auto, file]** (rule 6, States, Edge Cases)
- **GIVEN** a boss defeated on frame N, its commit held in flight by a test hook and a change made on frame N + 1, **WHEN** the Seeker quits to the title and Continue is pressed at once, **THEN** Continue is not available until the in-flight commit has finished and one more commit has written frame N + 1's change, the loaded record holds `defeated` and that change, and no later commit lands over the loaded record. **[Auto, file]**, once Pause and menus exists (rule 8, States, Edge Cases)
- **GIVEN** a commit held in flight by a test hook and changes made on the next two frames, **WHEN** the process is killed before it finishes, **THEN** the file holds the record committed before the in-flight one, byte for byte, and the changes lost are exactly the in-flight frame's and the two pending frames', never a part of one frame. **[Auto, file]** (rule 6, Edge Cases)
- **GIVEN** a save file cut short and a readable last good copy, **WHEN** the game starts, **THEN** the last good copy is loaded. **GIVEN** that load, **THEN** the record starts Dirty, the first commit rewrites the main file, and the last good copy's bytes are unchanged by it; **GIVEN** that commit interrupted by a test hook, **THEN** the last good copy still loads. **GIVEN** both unreadable, **THEN** Continue says the save cannot be read, and both files are still on disk. **[Auto, file]** (States, Edge Cases, rule 6)
- **GIVEN** no main file and a readable last good copy, **WHEN** the game starts, **THEN** the last good copy is loaded and the record starts Dirty. **GIVEN** an unreadable main file and no last good copy, **THEN** Continue says the save cannot be read and the main file is still on disk. **GIVEN** neither file, **THEN** Continue is not offered. **[Auto, file]** (States, Edge Cases)
- **GIVEN** both files unreadable, **WHEN** a new game is confirmed, **THEN** both are on disk as kept copies, byte for byte, before the empty record is committed, and unchanged after 3 further commits. **GIVEN** copying a kept copy fails, **THEN** the new game does not start, the existing files are untouched and the game says why. **[Auto, file]** for the files, **[UI]** for the message (Edge Cases)
- **GIVEN** a system raising a flag on an object with no object id, **THEN** the change is refused, a defect is logged, and the next commit does not hold it. **GIVEN** a raise of a flag name no system registered, on a known object, **THEN** it is stored, committed and still present after a reload. **[Auto]** (Edge Cases, rule 2)
- **GIVEN** a respawn point `(r1, sp1)` in the record, **WHEN** Save points writes `(r2, sp2)`, **THEN** the record holds `(r2, sp2)` only, every other entry is unchanged, and a commit follows. **[Auto]** (rule 3)
- **GIVEN** a version 4 file and a game at version 3, **WHEN** a new game is confirmed, **THEN** the main file holds the empty record at version 3, the version 4 bytes are on disk as the kept copy, made before the empty record was committed, and they are unchanged after 3 further commits. **GIVEN** the same case before confirming, **THEN** the game warns that a newer save would be replaced. **[Auto, file]** for the files, **[UI]** for the warning (Edge Cases)
- **GIVEN** a save holding no respawn point, **WHEN** Continue is chosen, **THEN** the Seeker starts at the new game's start point with every flag in the save still raised. **[Auto, engine]** (Edge Cases)

**Cost**
- **GIVEN** region 1 with every key, flag, room and region of the region raised, on the reference machine named in the test record, **WHEN** a scripted route through region 1 produces at least 20 commits, **THEN** each commit's own duration (end of gameplay to write completion, or to hand-off if the ADR moves it off the main thread) is at most 4 ms, and no frame in play (not the dark Swapping frame, which is measured and exempt, rooms and transitions R3) that holds a commit exceeds 16.6 ms. The 4 ms is a proposed quarter of a 60 fps frame, to be confirmed against region 1's grey-box. **[Play]** (rule 6)

**Gaps found by the QA lens:**
- Record size has no number: it is bounded by the world's content (Formulas), and region 1's object count is not known until its grey-box. The cost criterion is set against region 1 for that reason.
- `project.yaml` sets no frame-rate target; 16.6 ms assumes 60 fps. The criterion changes with the target, and the reference machine has to be named when the test is first run.
- Whether a commit must be written off the main thread to meet 16.6 ms is the ADR's question (Open Questions), so the cost criterion is a [Play] record until it is answered.
- The "not saved" mark and the Continue messages are UI and need a UX spec before their screenshots can be judged (UI Requirements).

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **How the record is stored and written (ADR).** The file format (a resource or a data dictionary), where it lives, how a commit replaces the file whole and keeps the last good copy, and whether a commit runs off the main thread to meet the 16.6 ms frame (Acceptance Criteria); how many frames a write may span, which sets how much a crash can lose (Edge Cases); and where kept copies live and what they are called (Edge Cases). **NOT SOURCEABLE**: file writing, atomic replace and background threads in Godot 4.7 are not covered by `docs/engine-reference/godot/` (there is no `core.md`). The one sourced fact is that `FileAccess.store_*` returns `bool` from 4.4 (`breaking-changes.md`), so a failed write can be detected. Owner: technical director via `/architecture-decision`. Target: before story 007.
2. **How many commits a busy frame costs.** Rule 6 writes at most once a frame, but a run that sees several gates and enters a room raises many flags in a few seconds. Measure the commit count and frame time in region 1's grey-box. If writes are too frequent, batching over a short delay is the fallback, designed then with its own rules and no knob until then (the owner chose end of frame, 2026-11-20). Target: region 1's grey-box.
3. **Enemies that stay dead.** Rooms and transitions rebuilds every enemy on entry; an exception is a `defeated` flag on that enemy (Interactions). Which enemies qualify is the Enemies GDD's. Region 1 already has one: the lore says the Half-glazed Waster, the tutorial foe, "appears once and never returns" (`design/narrative/lore/region-1-cooling-yards.md`, canon provisional), so the MVP needs this flag before the Enemies GDD is written, and that enemy needs an object id (rooms and transitions rule 3 lists none for enemies). Owner: `/design-system enemies`.
4. **Save slots.** One slot in the MVP (rule 7). Whether the full game offers more is a menus decision. Owner: Pause and menus. Target: Vertical Slice.
5. **Dev tools.** A debug way to raise or clear flags, or to start from a prepared record, would speed up testing gates out of order. It must never ship in a release build, since clearing a flag breaks rule 3. Owner: tools. Target: region 1's grey-box.
6. **Release id manifest.** The room check cannot see an object moved to another room between releases (Edge Cases), and a moved boss trigger or gate silently resets for existing saves. A manifest of released room, object, region and key ids, checked at build, would catch it. Owner: tools. Target: before the first release.
