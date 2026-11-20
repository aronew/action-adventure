# Save points and save/load

> **Status**: In Design
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Creative Director Review (CD-GDD-ALIGN)**: skipped — Lean mode
> **Implements Pillar**: none defined (brief: "Fail: health reaches zero; respawn at the last save point")

## Summary

Save points are cooling niches where the Seeker sits to rest: pressing up sets the respawn point and heals to full, and nothing else, because World state already keeps everything earned the moment it happens. A death sends the Seeker back to the last niche it sat in, seated and at full health, about 3 s after the killing hit, costing only the walk back; Continue and New game on the title screen use the same arrival. It exists so the brief's fail state ("respawn at the last save point") has a place to send the player and the save file has a way back into play.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `World state, Rooms and transitions, Level design, Player controller, Health`

## Overview

Save points and save/load is the part of the world the Seeker comes back to. A save point is a cooling niche in a kiln wall (region 1 lore): standing in it on the ground and pressing up makes the Seeker sit, and sitting sets the **respawn point** to that niche and heals the Seeker to full before it stands again. Sitting saves nothing else, because everything earned is already kept by World state the moment it happens (world state rules 5 and 6): a save point only moves where the Seeker comes back. When health reaches zero, the Seeker returns to the last niche it sat in, with full health, through the same fade as any arrival (rooms and transitions rule 8). Everything earned stays (world state rule 4), so a death costs the walk back and nothing else. At the title screen this system offers **Continue**, which builds the world from the save and puts the Seeker at that niche, and **New game**, which asks before it replaces a save. The player feels it as a warm place to rest before a hard stretch, never as a chore of remembering to save. Without it, a death would have nowhere to send the Seeker, a save file would have no way back into play, and level design's saves by role (rules 15 and 16) would be scenery. How the file is written belongs to World state and its storage ADR; this system owns the niche, the respawn, Continue and the title prompts. **[Owner, 2026-11-20: press up to sit; sitting heals to full; a rest moment with no "saved" text]**

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Rec]** = recommendation, change freely. `systems-designer`, `gameplay-programmer` and `engine-programmer` not consulted: Lean mode. Review manually before production.

**The save point**

1. **A save point.** A save point is an object placed in a room, with an object id (rooms and transitions rule 3), a **rest area** the Seeker stands in to use it, an **arrival point** in front of it (rooms and transitions rule 8), a facing (the way the niche opens) and a role from level design rule 15 (boss, hub or reward) in its room data. It has no state of its own in World state: it raises no flag, and whether it was ever used is not recorded. Only the respawn point names it. **[Rec]**
2. **Sitting.** Pressing `interact` (up) while the Seeker's collision box centre is in the rest area, on the ground, not attacking and not in hurt lock, the same conditions as entering a door (rooms and transitions rule 7), starts a **rest**. Nothing else starts one: walking, falling or dashing through the rest area does nothing. **[Owner, 2026-11-20: press up to sit]**
3. **A rest.** The Seeker stops, turns to the save point's facing, sits (`sit_time`), holds still for `rest_hold_time` while the rest moment plays (Visual/Audio), then stands (`stand_time`). All input but pause is ignored for the whole rest, and pause freezes it. The Seeker cannot be hurt or killed from the accepted up press until the stand-up ends, as during EnterDoor (rooms and transitions rule 7); enemies and hazards keep running, and their contact does nothing. Control returns on the frame the stand-up ends (Formulas F1). Because a rest is an invulnerable full heal, no fight may reach a rest area: no enemy's leash bound (level design rule 24, F7) overlaps a rest area, and no save point sits inside an arena (level design rule 15). That is a placement requirement on Level design, checked on the room data, not a rule at the niche. **[Owner, 2026-11-20: safe while seated; rely on placement]**
4. **What a rest does.** On the frame the up press is accepted, two things happen and nothing else: the respawn point is written to World state as (room id, save point object id), and health is set to `max_health` (`player_config.tres`, read, never copied). Both happen at the start of the rest, so a quit or crash during it loses neither (world state rule 6 commits at the end of that frame). Sitting again at the save point already held is not a change to the record (world state rule 5) but still heals. No flag is raised, no enemy is reset and the room is not rebuilt. **[Owner, 2026-11-20: heals to full; Rec: at the start of the rest]**
5. **No manual save.** There is no save command and no save menu. World state keeps every change the moment it happens (world state rules 5 and 6); a save point only moves where the Seeker comes back. **[Owner, 2026-11-20: world state owns the durable write]**

**Death and respawn**

6. **Death.** On the frame `PlayerHealth.depleted` fires, controls lock, the Seeker plays its death clip and from then on it cannot be hit and triggers nothing it touches: no pickup, pass line, exit, door or rest area (Edge Cases). When the death clip ends (`died`) and `death_hold_time` has passed (Formulas F2), a respawn is requested from Rooms and transitions (rule 8 there) to the respawn point's room and arrival point. **[Rec; Owner, 2026-11-20: `death_hold_time` starts at 0]**
7. **What a death costs.** Only the walk back. Death changes nothing in World state (world state rule 4), and the respawn point is not rewritten. The arrival room is built fresh (rooms and transitions rule 12), so its enemies are back and an unbeaten boss is unbeaten; every other room rebuilds its enemies when it is next entered. **[Owner, 2026-11-20: only the walk back]**
8. **Arrival.** After a death, a Continue or a new game, the Seeker arrives at the save point's arrival point **seated**, with zero velocity, full health and the save point's facing, then stands up (`stand_time`); control returns when the stand-up ends (Formulas F2). It cannot be hurt or killed from the death, or the load, until the stand-up ends. Rooms and transitions rule 8 says an arrival is "standing", so it needs revising to allow a seated arrival at a save point (Dependencies). **[Owner, 2026-11-20: seated, then stands up]**
9. **Where the respawn point comes from.** The respawn point is the one in World state. A new game writes the region's **start save point** (region 1: the Waking Niche, the start room's save point in the lore) as the respawn point once World state has committed its empty record, so in normal play the record always holds one. Each region's data names its start save point. If the record holds no respawn point (a save from before this rule, or a damaged one), the Seeker arrives at the start save point of region 1. If it names a room that was cut, or a save point no longer in its room, the Seeker arrives at the start save point of that room's region, the "region's first save point" of rooms and transitions Edge Cases. **[Owner, 2026-11-20: respawn set to the Waking Niche; Rec: the fallbacks]**

**Continue and new game**

10. **The title screen's two choices.** Continue is offered when World state reports a save it can load (its file table: Current, Older, or Unreadable with a readable last good copy). When it cannot, Continue is shown unavailable with World state's message (the save needs a newer version; the save cannot be read), and when there is no save at all it is not shown. Both choices wait until World state's commit chain is idle (world state rule 8). **[Rec]**
11. **Continue.** World state loads the record before the first room is built (world state rule 8), then the Seeker arrives at the respawn point (rules 8 and 9) with full health: health is not in the record (world state rule 1), so every Continue starts full. **[Rec]**
12. **New game.** When a save exists (any file state but None), New game first asks whether to replace it, with No selected. For a newer or unreadable save it shows World state's warning instead and World state makes its kept copy first (world state Edge Cases). Once confirmed, World state starts and commits the empty record, this system writes the start save point as the respawn point (rule 9), and the Seeker arrives there seated (rule 8). With no save, New game starts at once. **[Rec; world state rule 7: Save points owns the prompt]**

### States and Transitions

The Seeker, as this system sees it:

| State | Meaning | Enter when | Leave when |
|---|---|---|---|
| Playing | Normal control | The game starts play; a rest's stand-up ends; an arrival's stand-up ends | `interact` accepted in a rest area (rule 2): to Resting. `depleted` fires: to Dead |
| Resting | Sitting, holding, standing; input locked but pause; cannot be hurt | From Playing (rule 2). The respawn point and the heal are applied on entry (rule 4) | The stand-up ends: to Playing. Nothing else leaves it: a rest is never cut short |
| Dead | Death clip, then the hold; input locked; cannot be hit; triggers nothing it touches | From Playing (`depleted`) | The death clip ends (`died`) and `death_hold_time` has passed (F2): the respawn is requested and Rooms and transitions runs the transition (its rule 9): to Arriving |
| Arriving | The transition, then seated at the arrival point, then the stand-up; cannot be hurt | From Dead; or Continue or a confirmed new game starts play | The stand-up ends: to Playing |

Resting cannot be entered from Dead or Arriving, and Dead cannot be entered from Resting or Arriving, because the Seeker cannot be hurt in either (rules 3 and 8).

### Interactions with Other Systems

World state and Rooms and transitions are Approved; Level design is Approved. The other interfaces are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|---|---|---|---|
| World state | Both | Out: the respawn point (rule 4, rule 12), Continue and new game chosen. In: the respawn point; whether a save exists, its file state and version, the commit chain idle (rules 10-12); the record loaded | World state owns the record and the file; this system owns the respawn, the heal, Continue and the prompts (world state Interactions) |
| Rooms and transitions | Both | Out: a respawn or load arrival requested at (room id, arrival point) (rules 6, 8, 11, 12). In: the arrival room built fresh (its rule 12), the transition (its rule 9), the region's first save point for a cut room. Needs: a seated arrival at a save point (its rule 8 says standing) | Rooms owns the transition; this system owns which point and the pose |
| Level design | In | Save point placement and role (its rules 15, 16); each region's start save point (rule 9) | Level design |
| Player controller | Both | In: `interact`, on the ground, attacking, hurt lock (rule 2). Out: a rest and an arrival that lock input and block damage, the save point's facing, sit and stand poses (rules 3, 8) | Player controller owns the states and clips; this system owns when they run |
| Health, damage and death | Both | In: `PlayerHealth.depleted` (rule 6). Out: health set to `max_health` on a rest and on every arrival (rules 4, 8) | Health owns the values; this system owns when they refill |
| Pause and menus | Both | Out: the title screen's Continue and New game, their messages and the replace prompt (rules 10-12). In: pause during a rest (rule 3). The quit flow is World state's and Pause and menus' | Pause and menus owns the screens; this system owns what Continue and New game do |
| Bosses | In | An unbeaten boss is reset by the arrival room's rebuild (rule 7); `boss_arena.gd`'s reload after `RELOAD_DELAY` is the stand-in this replaces | Bosses |
| Enemies | In | Rebuilt on room entry (rooms and transitions rule 12); nothing extra on a rest or death (rules 4, 7) | Enemies |
| Grid map | Out | Save point positions, if the map shows them | Grid map |
| Fast travel (Full Vision) | Out | Save points as candidate stations, if Fast travel uses them | Fast travel |

## Formulas

`systems-designer` lens applied in this session (lean mode spawns no agent): every variable was put at its minimum, its maximum and 0; nothing divides, nothing goes negative and no input makes another inert. No feedback loop: nothing accumulates, so resting or dying never feeds back into anything. The one degenerate use found, an invulnerable full heal next to a fight, is closed by placement (rule 3, owner). Clip times are measured from `src/player/seeker_animations.json`, never copied into data.

### F1. Rest time

The rest_time formula is defined as:

`rest_time = sit_time + rest_hold_time + stand_time`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| sit_time | float (s) | 0.20 today | calculated (sit clip length) | The sit clip; `crouch_down` (4 frames, 200 ms) stands in until a sit pose exists (Visual/Audio) |
| rest_hold_time | float (s) | 0.5-2.0, starts at 1.0 | data file | The rest moment: ash settles, the Seeker's shade warms a half-step **[Rec]** |
| stand_time | float (s) | 0.10 today | calculated (stand clip length) | The stand clip; `crouch_stand` (1 frame, 100 ms) stands in. Also ends every arrival (F2, rule 8) |

**Output Range:** 1.30 s at the starting values; 0.80-2.30 s across the `rest_hold_time` range. Below 0.5 s of hold the rest moment cannot be seen; above 2.0 s it is a wait the player notices, against "saving is invisible" (Game Feel). The Seeker cannot be hurt for all of `rest_time` (rule 3).
**Example:** the Seeker presses up in the Waking Niche: 0.20 s sitting, 1.0 s resting, 0.10 s standing; control returns 1.30 s after the press, with the respawn point and the heal applied on the press frame (rule 4).

### F2. Death to control

The death_to_control formula is defined as:

`death_to_control = death_clip_time + death_hold_time + transition_time + stand_time`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| death_clip_time | float (s) | 2.41 today | calculated (death clip length) | The `death` clip, 20 frames ending in a 0.90 s held frame; the Player controller emits `died` when it ends |
| death_hold_time | float (s) | 0-1.0, starts at 0 | data file | Pause after the clip before the respawn is requested. Starts at 0 because the clip's last frame already holds 0.90 s; the code's stand-in `RELOAD_DELAY` is 1.0 **[Owner, 2026-11-20: starts at 0]** |
| transition_time | float (s) | 0.2 or more; 0.45 at R3's starting values | rooms and transitions R3 (registry `transition_time`) | The fade out, any load still needed, the build and the fade in |
| stand_time | float (s) | 0.10 today | as F1 | The arrival's stand-up (rule 8) |

**Output Range:** 2.96 s into a resident room (2.41 + 0 + 0.45 + 0.10) at the starting values; about 3.88 s into a room that must load first (R3's example, 1.37 s). At `death_hold_time` 1.0 these become 3.96 and 4.88 s. The Seeker cannot be hurt for all of it (rules 6, 8). The same arrival, without the death clip and hold, ends a Continue and a new game: `transition_time + stand_time`.
**Data check:** `rest_hold_time` and `death_hold_time` are checked when the data file loads; a value outside its range rejects the file and names the value, so a bad number never reaches play. **[Owner, 2026-11-20: rejected at load]**

**Example:** the Seeker dies in a hub two rooms from its last niche, whose biome is resident: the death clip plays for 2.41 s, the respawn is requested at once, the transition takes 0.45 s, the Seeker appears seated at the niche and stands in 0.10 s; it moves again 2.96 s after the killing hit.

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

**Sitting**
- **If up is pressed in a rest area while airborne, attacking or in hurt lock**: nothing happens and nothing is buffered; a press once the conditions hold starts the rest (rule 2). **[Rec]**
- **If a hit lands on the same frame as the up press**: the hit is resolved first. If it starts hurt lock the press is refused; if it brings health to zero the Seeker dies and no rest starts, so the respawn point is not written. The Seeker is safe only from the accepted press on (rule 3). **[Rec]**
- **If a rest area overlaps a door's area or an exit**: up would mean two things, so the room check rejects the room and names it. A requirement on the rooms and transitions room check. **[Rec]**
- **If the game is paused, quit or crashes during a rest**: the respawn point and the heal were applied on the press frame (rule 4) and the respawn point is committed at the end of that frame (world state rule 6), so a Continue arrives at that niche. Pause freezes the rest where it is. **[Rec]**
- **If the Seeker sits at the save point already held**: the record does not change (world state rule 5), health is set to full and the rest plays in full. **[Rec]**

**Death and respawn**
- **If the dead Seeker's body slides into a pickup, a gate's pass line, an exit, a door or a rest area** (death knockback, a moving platform): none of them trigger (rule 6), so nothing is raised by a dead body. What is on screen while it dies still counts as seen (level design States), because seeing is not touching. **[Rec]**
- **If the Seeker dies on the frame a flag is raised**: the flag stays raised (world state rule 4 and Edge Cases); this system adds nothing. **[Rec]**
- **If the Seeker falls onto a kill plane or a hazard brings health to zero**: it is a death like any other (rule 6). **[Rec]**
- **If the Seeker dies in a locked boss arena**: it arrives at its last niche (level design rule 15 puts one before the arena). The arena room is built fresh when it is next entered, so an unbeaten boss is unbeaten and the arena unlocked (rule 7; level design: "a locked arena never traps without a respawn"). **[Rec]**
- **If the Seeker dies in the room that holds its respawn point**: the room is rebuilt fresh on arrival, the same as any other (rooms and transitions rules 8, 12), so its enemies are back and unsaved breakables are whole. **[Rec]**
- **If the respawn room's biome is not resident**: the transition waits for the load behind the dark screen, with the loading mark after `load_wait_notice` (rooms and transitions R3, rule 10); F2 grows by the wait. **[Rec]**
- **If the Seeker dies before any rest in a new game**: the respawn point is the start save point (rule 9), so it arrives in the Waking Niche. **[Owner, 2026-11-20]**
- **If the respawn point names a save point that no longer exists, a room that was cut, or nothing at all**: rule 9's fallbacks apply (the region's start save point; region 1's for an empty one). The record is not rewritten by the fallback; the next rest writes a valid point. **[Rec]**
- **If the Seeker would die during a transition or an arrival**: it cannot; it cannot be hurt from the death or the load until the stand-up ends (rule 8), and Rooms and transitions blocks damage through every transition. **[Rec]**

**Continue and new game**
- **If there is no save at all**: Continue is not shown and New game starts at once, with no prompt (rules 10, 12). **[Rec]**
- **If New game is chosen while a save exists and the prompt is declined**: the title screen returns with nothing changed. **[Rec]**
- **If New game is confirmed over a newer or unreadable save and World state cannot make its kept copy**: World state does not start the new game and says why (world state Edge Cases); the title screen stays, and no respawn point is written. **[Rec]**
- **If the new game's first commit fails**: World state's failure handling runs (retry cadence, "not saved" mark); this system still writes the start save point as the respawn point, which waits as pending with the empty record (world state rule 6). **[Rec]**
- **If Continue loads the last good copy** (the main file was unreadable): the Seeker arrives at that record's respawn point, which may be an earlier niche than the one last used; nothing else differs (world state States). **[Rec]**
- **If Continue or New game is chosen right after a quit to the title**: both wait, with the loading mark, until World state's commit chain is idle (world state rule 8). **[Rec]**

## Dependencies

The systems index lists this system as depending on World state, Rooms and transitions and Level design. This GDD also needs the Player controller and Health, damage and death (code only, no GDD).

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| World state | Hard | The respawn point field and its write; the record loaded before the first room; whether a save exists, its file state and version; whether the commit chain is idle; a new game's empty record (rules 4, 9-12) | Yes, Approved (`design/gdd/world-state.md`) |
| Rooms and transitions | Hard | Save point object ids (its rule 3); an arrival at a named point (its rule 8) through the transition (its rule 9, R3); the arrival room built fresh (its rule 12); the region's first save point for a cut room. **Needs two changes**: its rule 8 to allow a seated arrival at a save point (rule 8 here; it says "standing"), and its room check to reject a rest area overlapping a door's area or an exit (Edge Cases) | Yes, Approved (`design/gdd/rooms-and-transitions.md`) |
| Level design | Hard | Save points placed by role (its rules 15, 16), with the role in the room data; each region's start save point (rule 9). **Needs**: a placement rule that no enemy's leash bound (its rule 24, F7) overlaps a rest area (rule 3) | Yes, Approved (`design/gdd/level-design.md`) |
| Player controller | Hard | `interact`, and the on-ground, attacking and hurt-lock conditions (rule 2); Resting and Arriving states that lock input and block damage; the save point's facing; sit and stand clips; `died` at the end of the death clip (rules 3, 6, 8) | No (`src/player/player.gd`) |
| Health, damage and death | Hard | `PlayerHealth.depleted`; `max_health`; a way to set health to full (rules 4, 6, 8) | No (`src/player/player_health.gd`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Pause and menus | Hard | What Continue and New game do, when each is offered, the replace prompt and the messages to show (rules 10-12, UI Requirements) |
| Bosses | Soft | The respawn that replaces `boss_arena.gd`'s reload stand-in; an unbeaten boss reset by the rebuild (rule 7) |
| Enemies | Soft | Nothing beyond the rebuild on entry (rule 7); a rest resets no enemy (rule 4) |
| Grid map | Soft | Save point positions, if the map shows them |
| Fast travel (Full Vision) | Soft | Save points as candidate stations, if it uses them |

**Bidirectional check:**

- World state lists Save points as a hard downstream (the record, the file, the respawn point, whether a save exists and its version) and hands it the respawn, the heal, Continue and the prompts. Match: rules 4 and 9-12.
- Rooms and transitions lists Save points in its Interactions ("Enter room R at arrival point P; the current room id") and leaves "which point" to Save points (its rule 8). Match, except the seated arrival and the rest-area overlap check above, which its owner needs to adopt.
- Level design lists Save points as a hard downstream ("Save locations and their roles, rules 15-16"). Match. It should add each region's start save point and the leash-bound placement rule (rules 3, 9).
- The systems index row for Save points lists World state, Rooms and transitions and Level design; it should add Player controller and Health, damage and death (hard). Pause and menus already lists Save points as a dependency. Match.
- Player controller, Health, Pause and menus, Bosses, Enemies, Grid map and Fast travel have no GDD yet. Each needs a matching entry when it is designed.
- Story 007 (Ready) says "a save point saves the room, the owned abilities, the boss-defeated flag and the map's discovered rooms". That conflicts with rules 4 and 5 here (a rest writes only the respawn point and heals; World state keeps the rest at the moment of change). The story needs revising before it is implemented.

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. The art bible (not yet written) owns every look named here.

- **The niche.** A cooling niche in a kiln wall, brick warm at the back (region 1 lore, "Save point: the cooling niche"). It must read at a glance as a place to rest and stand apart from doors, so up is never ambiguous. **[Rec]**
- **The rest moment.** The lore's beat, in `rest_hold_time`: ash settles, the Seeker's pale shade warms a half-step, and the nearest glazed figure's highlight slowly dims; the Seeker stands up the same as it sat down. A soft settle of ash and a low warm note; no chime and no "saved" text. **[Owner, 2026-11-20: a rest moment, no text]**
- **Sit and stand poses.** The Seeker pack has no sit clip; `crouch_down` and `crouch_stand` stand in (Formulas). A sit pose and a stand-up are needed, used by every rest and every arrival (rules 3, 8). **[Rec]**
- **Seated arrival.** After a death, a Continue or a new game the Seeker is already seated when the fade-in starts, then stands (rule 8). The new game's first arrival in the Waking Niche reads as waking. **[Owner, 2026-11-20]**
- **Death.** The existing `death` clip, ending on its held frame; nothing is added. **[Rec]**

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:save-points-and-save-load` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

- **Resting is a breath, not a menu.** About 1.3 s (F1), one button, no prompt and no text. The player rests because it is warm and safe, not to protect progress, which is already kept. **[Owner, 2026-11-20]**
- **A death costs the walk back, quickly.** Control returns about 3 s after the killing hit into a resident room (F2); the Seeker is back on its feet at a place it chose, with everything it earned. **[Owner, 2026-11-20: only the walk back; `death_hold_time` starts at 0]**
- **Coming back looks like waking.** Every arrival is the same stand-up from the niche, so a death, a Continue and the very first moment of a new game feel like one place. **[Owner, 2026-11-20]**
- **Playtest question.** Whether players still look for a save button or a "saved" message (Acceptance Criteria, Feel; world state Game Feel).

## UI Requirements

- **In play: nothing.** There is no save prompt, no "saved" text and no save menu (rules 3, 5). Whether a rest area shows an up glyph the first time it is seen is a HUD question, not decided here (Open Questions). **[Rec]**
- **Title screen**, laid out by Pause and menus: Continue (offered, unavailable with a message, or not shown, rule 10) and New game; the replace prompt with No selected (rule 12); World state's messages (needs a newer version; cannot be read; a newer save would be replaced; a kept copy could not be made). This system owns what each choice does; the screens are Pause and menus'. **[Rec]**

> **📌 UX Flag — Save points and save/load**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to (the title screen's Continue and New game, the replace prompt) **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| The respawn point is the one replaced field; world state owns the write and commits at the end of the frame; a repeat write is not a change (rules 1, 3, 5, 6) | World state | `design/gdd/world-state.md`, Approved |
| Death undoes nothing; health and position are not in the record (rules 1, 4) | World state | Approved |
| The file table (None, Current, Older, Newer, Unreadable), the commit chain idle, the kept copy, the new-game empty record (rules 7, 8, States, Edge Cases) | World state | Approved |
| Save points have object ids (rule 3); arrivals at a named point, "standing" (rule 8, needs revising); the transition and its time (rule 9, R3); rooms rebuilt on entry (rule 12); a cut room loads at the region's first save point (Edge Cases); door conditions and EnterDoor's protection (rule 7) | Rooms and transitions | `design/gdd/rooms-and-transitions.md`, Approved |
| Saves placed by role, near every boss, at hubs, as rewards; no spacing rule (rules 15, 16); a locked arena never traps without a respawn (Edge Cases); leash bounds (rule 24, F7); `seen` is set by being on screen (States) | Level design | `design/gdd/level-design.md`, Approved |
| The Waking Niche is the start and a save; the cooling niche and its rest beat (lore) | Narrative | `design/narrative/lore/region-1-cooling-yards.md`, canon provisional |
| Fail: health reaches zero; respawn at the last save point (Goal & fail state) | Game brief | `design/game-brief.md` |
| `interact`, `death`, `crouch_down`, `crouch_stand`, `died`; `PlayerHealth.depleted`, `max_health`; `RELOAD_DELAY` 1.0 s as the boss arena's stand-in | Player controller, Health, Bosses | `src/player/player.gd`, `player_health.gd`, `seeker_animations.json`, `src/enemies/boss/boss_arena.gd`; no GDD |
| "A save point saves the room, the owned abilities, the boss-defeated flag and the map's discovered rooms" conflicts with rules 4 and 5 (Dependencies) | Story 007 | `production/epics/guardbreak/story-007-rooms-saves-map.md`, Ready |

## Acceptance Criteria

Types: **[Auto]** unit test with World state, Health and Rooms and transitions injected as fakes (no file I/O); **[Auto, engine]** test that runs the game headless; **[UI]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest record. One criterion or more per core rule (C) and per formula (D); `qa-lead` lens applied in this session (lean mode spawns no agent). Times are checked to within one physics tick.

**The save point and sitting**
- **GIVEN** a room whose save point has no object id, **WHEN** the room check runs, **THEN** the room is rejected and named. **GIVEN** a rest at save point `sp1` in room `r1`, **THEN** World state holds no flag for `(r1, sp1)`. **[Auto]** (rule 1; rooms and transitions rule 3)
- **GIVEN** the Seeker standing in a rest area, **WHEN** `interact` is pressed, **THEN** it enters Resting on that frame. **GIVEN** the Seeker airborne, attacking or in hurt lock in the rest area, **WHEN** `interact` is pressed, **THEN** no rest starts and none starts later without a new press. **GIVEN** a dash through the rest area, **THEN** no rest starts. **[Auto, engine]** (rule 2, Edge Cases)
- **GIVEN** a rest started at time 0 at the default values, **WHEN** an enemy's contact and a hazard overlap the Seeker during it, **THEN** health is unchanged, every input but pause is ignored, and control returns at 1.30 s. **GIVEN** pause pressed at 0.5 s for 3 s, **THEN** control returns at 4.30 s. **[Auto, engine]** (rule 3, F1)
- **GIVEN** room data with an enemy whose leash bound overlaps a rest area, **WHEN** level design's room check runs, **THEN** the room is rejected and named. **GIVEN** a save point inside a boss arena, **THEN** the same. **[Auto]** (rule 3; requirement on level design)
- **GIVEN** health at 10 of `max_health`, respawn point `(r1, sp1)`, **WHEN** the Seeker rests at `(r2, sp2)`, **THEN** on the press frame health is `max_health` and the record's respawn point is `(r2, sp2)`, the commit at the end of that frame holds it, and no other entry of the record changed. **GIVEN** the respawn point already `(r2, sp2)` and health at 10, **WHEN** it rests there again, **THEN** health is `max_health` and no commit follows. **[Auto]** (rule 4; world state rule 5)
- **GIVEN** the input map and the pause menu, **THEN** neither has a save action. **[Auto]** (rule 5)

**Death and respawn**
- **GIVEN** `death_hold_time` 0, **WHEN** health reaches zero at time 0, **THEN** controls lock at 0, the death clip plays, and the respawn is requested at 2.41 s. **GIVEN** `death_hold_time` 1.0, **THEN** it is requested at 3.41 s. **[Auto, engine]** (rule 6, F2)
- **GIVEN** the Seeker dead with death knockback carrying its body into a key pickup, a gate's pass line and a rest area, **THEN** the key stays unowned, `passed` stays unraised, no rest starts and no commit follows from them. **[Auto, engine]** (rule 6, Edge Cases)
- **GIVEN** shortcut `s1` open, the dash owned, an enemy killed in the death room and respawn point `(r1, sp1)`, **WHEN** the Seeker dies and arrives, **THEN** the record's entries are identical to before the death, the respawn point is still `(r1, sp1)`, and on re-entering the death room the enemy is alive at its spawn point. **[Auto, engine]** (rule 7; world state rule 4; rooms and transitions rule 12)
- **GIVEN** a respawn into a resident room, **WHEN** the fade-in ends, **THEN** the Seeker is at the save point's arrival point in the sit pose, with zero velocity, `max_health` and the save point's facing; it stands and control returns 0.10 s after the fade-in ends (2.96 s after the killing hit at the default values); an enemy's contact during the stand-up does no damage. **[Auto, engine]** for the position, timing and damage, **[UI]** for the seated pose (rule 8, F2)
- **GIVEN** a boss arena with an unbeaten boss and a save point in the room before it, **WHEN** the Seeker dies in the arena, **THEN** it arrives at that save point, and on re-entering the arena the boss is at full health and guard, undefeated, and the arena is not locked. **[Auto, engine]** (rule 7, Edge Cases; cross-system: bosses, level design rule 15)

**Respawn point**
- **GIVEN** a new game confirmed, **WHEN** World state's empty record is committed, **THEN** the next commit holds the respawn point as region 1's start save point (the Waking Niche), and a death before any rest arrives there. **[Auto]** for the record, **[Auto, engine]** for the arrival (rule 9)
- **GIVEN** a record with no respawn point, **THEN** the Seeker arrives at region 1's start save point. **GIVEN** one naming a cut room in region 2, **THEN** it arrives at region 2's start save point. **GIVEN** one naming a save point no longer in its room, **THEN** it arrives at that room's region's start save point. **GIVEN** any of these, **THEN** the record's respawn point is unchanged until the next rest. **[Auto]** (rule 9, Edge Cases)

**Continue and new game**
- **GIVEN** each file state from World state's table, **WHEN** the title screen shows, **THEN** Continue is offered for Current, Older, and Unreadable with a readable last good copy; shown unavailable with "needs a newer version" for Newer and with "cannot be read" for an unreadable pair; and not shown for None. **[Auto]** for the choice, **[UI]** for each message (rule 10)
- **GIVEN** a save with respawn point `(r3, sp4)` and health absent from the record, **WHEN** Continue is chosen, **THEN** the Seeker arrives seated at `sp4` in `r3` with `max_health`. **[Auto, engine]** (rule 11; cross-system: world state rule 8)
- **GIVEN** a save exists, **WHEN** New game is chosen, **THEN** the replace prompt shows with No selected; **WHEN** it is declined, **THEN** the title returns and the file is unchanged byte for byte; **WHEN** it is confirmed, **THEN** the record is empty but for the start save point as respawn point and the Seeker arrives seated in the Waking Niche. **GIVEN** no save, **WHEN** New game is chosen, **THEN** no prompt shows. **[Auto, engine]** for the flow, **[UI]** for the prompt (rule 12)
- **GIVEN** a quit during a rest, after the press frame's commit, **WHEN** Continue is chosen, **THEN** the Seeker arrives at that rest's save point. **[Auto, engine]** (Edge Cases)
- **GIVEN** a rest area overlapping a door's area, **WHEN** the room check runs, **THEN** the room is rejected and named. **[Auto]** (Edge Cases; requirement on rooms and transitions)
- **GIVEN** a hit that brings health to zero on the frame `interact` is pressed in a rest area, **THEN** the Seeker dies, no rest starts and the respawn point is unchanged. **[Auto, engine]** (Edge Cases)

**Formulas**
- **GIVEN** `rest_hold_time` at 0.5, 1.0 and 2.0 and today's stand-in clips, **WHEN** a rest runs, **THEN** control returns at 0.80, 1.30 and 2.30 s. **[Auto, engine]** (F1)
- **GIVEN** a death into a resident room with `transition_time` 0.45 s, **THEN** control returns at 2.96 s with `death_hold_time` 0 and 3.96 s with 1.0. **GIVEN** a room whose biome must load, **THEN** control returns later by exactly the load wait R3 reports. **[Auto, engine]** (F2; cross-system: rooms and transitions R3)
- **GIVEN** a data file with `rest_hold_time` 0.3 or `death_hold_time` 1.5, **WHEN** it loads, **THEN** it is rejected and the value is named; **GIVEN** 0.5 and 1.0, **THEN** it loads. **[Auto]** (Formulas, data check)

**Feel**
- **GIVEN** 5 playtesters who reach region 1's mini-boss, **WHEN** asked after the session, **THEN** at least 4 can say where they would come back after a death, and no more than 1 says they looked for a save button or a "saved" message. **[Play]** (Overview; Game Feel)

**Gaps found by the QA lens:**
- No sit clip exists. F1's `sit_time` and `stand_time` use `crouch_down` and `crouch_stand`, so the F1 and F2 numbers change when the sit pose is made; the criteria read the clips, not fixed numbers, except where noted.
- The seated pose and the rest moment are visual, so their screenshots cannot be judged until the art bible gives them a look (Visual/Audio).
- Out-of-range data values: resolved by the owner (rejected at load, Formulas); covered by the data-check criterion above.
- The leash-bound and rest-area checks are requirements on Level design and Rooms and transitions; their criteria pass only once those checks exist.
- This system has no frame-time cost of its own: a rest is one World state commit (covered by world state's cost criterion) and an arrival is a Rooms and transitions transition (R3).

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **Seated arrival in rooms and transitions.** Its rule 8 says every arrival is "standing"; rule 8 here needs a seated arrival at a save point, then the stand-up. Owner: rooms and transitions (a revision and re-review). Target: before story 007.
2. **Room checks this GDD relies on.** A rest area overlapping a door's area or an exit is rejected (rooms and transitions room check); no enemy's leash bound overlaps a rest area and no save point sits in an arena (level design check, rule 3). Owner: rooms and transitions, level design. Target: before story 007.
3. **Each region's start save point.** Rule 9 needs every region's data to name one; region 1's is the Waking Niche. Owner: level design. Target: region 1's grey-box.
4. **Sit pose.** The Seeker pack has no sit clip; F1 and F2 use crouch stand-ins until one exists. Owner: art (art bible, `/asset-spec`). Target: Vertical Slice.
5. **A first-time hint at a rest area.** Whether the first niche the player sees shows an up glyph, or whether starting seated in the Waking Niche teaches it. Owner: HUD / UX. Target: region 1 playtest.
6. **Story 007.** Its save-point criterion conflicts with rules 4 and 5; revise it once this GDD is approved. Owner: producer (`/create-stories`). Target: after approval.
7. **Grid map and Fast travel.** Whether the map marks save points and whether fast travel stations are save points. Owner: Grid map, Fast travel. Target: their GDDs.
