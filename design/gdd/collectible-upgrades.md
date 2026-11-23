# Collectible upgrades

> **Status**: In Review. Designed 2026-11-21 (`/design-system`, lean, standard, guided); first `/design-review` 2026-11-21 (lean): NEEDS REVISION, 2 blockers (rule 8 against partial builds; F4's guard floor), both revised the same session on the owner's decisions; awaiting a re-review in a fresh session
> **Creative Director Review (CD-GDD-ALIGN)**: skipped, Lean mode
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-21
> **Last Verified**: 2026-11-21
> **Implements Pillar**: none defined (brief: "exploration and curiosity come first"; level design player fantasy: "curiosity is always repaid")

## Summary

Collectible upgrades are optional, hand-hidden fragments of four kinds (health, edge, guard and magic). Every full set of a kind raises one stat a step for good: max health, sword health damage, sword guard drain, and the reserve of the later bow and spells. They reward the player for reading the world closely, without opening any gate. Nothing is bought, crafted or dropped. Each fragment is found once, and every bonus is derived from World state's `collected` flags through one catalogue.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `World state, Level design, Rooms and transitions, Health (code), Combat (code)`

## Overview

Collectible upgrades are the optional, hand-hidden finds that make the Seeker permanently stronger without opening any gate. Each find is a **fragment** of one of four kinds: **health** fragments, which raise max health; **edge** ore, which raises the health damage every sword hit deals; **guard** ore, which raises how much each hit drains an enemy's guard meter, so guards break sooner; and **magic** fragments, which will raise the reserve of the later bow and spells and do nothing until those exist. The player gathers a set number of one kind (a **step size**, set per kind in data) and every full set raises that stat one step, for good. There is nothing to spend, buy or craft and nothing drops from enemies: every fragment is a placed object, found once, and the brief's "loot and shops" stay out of scope.

The player never operates the system. They touch a fragment and it is theirs; the stat change follows when a set completes, and a set always takes more than one find, so the pull is to keep looking. It exists to repay curiosity in a way the movement keys cannot: a key opens the world, a fragment rewards the player for having read it closely, and it gives the sealed alcoves and secret dead ends of level design (rules 2 and 19) something worth wanting. Without it, a player who has the keys has no reason to leave the critical path. A fragment never opens a gate and no key is ever a fragment, so no collectible can be missed in a way that blocks progress.

World state keeps one forward-only `collected` flag per fragment and no totals; the number of fragments held and every stat step are derived from those flags, so a save never stores a bonus that could drift from the finds behind it. Placement (where fragments sit and how many each region holds) belongs to level design, which already provisions a "pickup or a lore item" in each sealed alcove; this system owns what a fragment is, what a full set does, and the numbers.

**Scope.** The systems index sizes this system at S for one upgrade kind; four fragment kinds is a larger system, and the producer should re-estimate it. The magic kind is specified now and left inert, so it cannot be playtested until the bow and spells have GDDs. In the core build (region 1) no set completes (owner, 2026-11-21, rule 12): region 1's health, edge and guard fragments are found and counted (it holds no magic, rule 10), and every first step is earned in a later region.

## Detailed Design

### Core Rules

Tags: **[Owner]** = the owner's stated rule; **[Rec]** = recommendation, change freely; **[Code]** = how the code works today. `game-designer`, `systems-designer` and `economy-designer` not consulted for this section: Lean mode. Review manually before production.

**Fragments**

1. **Four kinds.** A fragment is one of four kinds, each raising one stat: **health** (max health), **edge** (the health damage of sword attacks), **guard** (the guard-meter drain of sword attacks) and **magic** (the reserve of the later bow and spells). **[Owner, 2026-11-21]** No other collectible belongs to this system: lore items belong to Lore delivery, keys to Ability gating.
2. **A placed object, found once.** Every fragment is an object placed in a room, with an object id (rooms and transitions rule 3) and a `kind`. None is spawned, dropped, bought, crafted or rewarded by a timer. **[Owner: no loot, shops or crafting (brief, Out of scope)]**
3. **The catalogue.** Every fragment in the game is listed once in the **fragment catalogue**, a data file giving its room id, object id and kind. The catalogue is how a count reaches fragments in rooms that are not loaded: the save records only that an object was collected, not what it was. The room check rejects a fragment that is missing from the catalogue, a catalogue entry with no fragment in its room (a `retired` entry is exempt: it is placed in no room, Edge Cases), a kind that is not one of the four, and an object id listed twice. **[Rec]**
4. **Touch collects.** When the Seeker touches a fragment, on that frame the fragment's `collected` flag is raised in World state (World state rules 2 and 5), the fragment can no longer be touched, plays its collect flash and frees itself when the flash ends, and the collect note shows (rule 11). A fragment whose `collected` flag is already raised frees itself when its room is built and never appears. A dead Seeker collects nothing (save points rule 6); a fragment touched on the frame the Seeker's health reaches zero is collected (World state Edge Cases). **[Rec; mirrors `AbilityPickup`, Code]**
5. **Nothing depends on a fragment.** A fragment never opens a gate, a door or a route, and no key, boss, save or story beat requires one. Missing every fragment leaves the game completable. **[Owner: keys open the world; Rec for the rule]**

**Sets and steps**

6. **Held is derived, never stored.** The number of fragments of a kind the player holds, `held(kind)`, is the number of catalogue entries of that kind whose `collected` flag is raised. World state stores no count and no stat (World state rule 12: rewards are derived, not stored). **[Rec]**
7. **A full set is one step.** Each kind has a **step size** (`step_size(kind)`, data) and a **step cap** (`steps_max(kind)`, data). The stat steps of a kind are `floor(held / step_size)`, never above the cap (Formulas). A part set does nothing but count. **[Owner: fragments, N per step]**
8. **The catalogue fills the cap exactly, at full release.** In the full game (all 8 regions built), the catalogue holds exactly `steps_max(kind) x step_size(kind)` non-retired fragments of each kind, so every fragment counts and the last one completes the last step. That exact total is a release gate, checked when the full game is built. In every earlier build, the core build included, the check is: no kind holds more than `steps_max x step_size` non-retired entries, and rule 12 holds for region 1. `step_size` and `steps_max` keep their full-game values in every build, so adding a region never changes a step count. **[Rec; the partial-build form is the owner's, 2026-11-21 design review]**
9. **Steps apply at once and at every build.** A completed step takes effect on the frame its last fragment is collected, and the stats are derived again from the record whenever the Seeker is configured (a load, a new game, a respawn), so a stat can never drift from its finds. **[Rec]** On the frame a health step completes, current health is set to the new max health. **[Rec, as in Hollow Knight: a new mask arrives full]** The refill sets `max_health` and `current` and leaves any invulnerability running; `PlayerHealth.configure` also clears invulnerability, so `PlayerHealth` needs a setter that does not (Dependencies). **[Rec]** A load, a new game and a respawn derive max health again and push it into `PlayerHealth` through `configure`; a rest and an arrival only call `reset()` (Save points rule 8), which refills to the `max_health` already held, so the derived value must be in place before they run. Edge and guard steps apply to the next hit; a hit already landed is not recomputed.
10. **Magic is inert.** Magic steps are derived and exposed like the others, but no system reads them until the bow and spells have GDDs. Magic fragments are collected and counted normally once they exist, but none is placed in the core build or before the Spell casts GDD exists: region 1 holds no magic, so no player sees a progress note for a stat that does not exist. Magic enters the catalogue with that GDD. **[Owner, 2026-11-21: specify now, inert; 2026-11-21 design review: place none until spells]**

**Feedback**

11. **The collect note.** On collection a short note names the kind and the progress, for example "Health fragment 2 of 4"; on a fragment that completes a step it names the stat raised instead, for example "Max health raised". The note does not block play and no persistent HUD counter is added. **[Owner, 2026-11-21]** A collection view, if any, belongs to Pause and menus.

**Placement (requirements on level design)**

12. **Region 1 completes no set.** In region 1, each kind holds at most `step_size(kind) - 1` fragments, so no set can complete with region 1 alone and every first step is earned in a later region. **[Owner, 2026-11-21]** In the core build a fragment is therefore found and counted but changes no stat.
13. **Where fragments sit.** A fragment sits in a secret (level design rule 19), a reward room or a sealed alcove (level design rule 2), never on the critical path in plain sight. The map never marks a fragment (level design rule 23). Level design owns how many each region holds, within rules 8 and 12. **[Rec]**

### States and Transitions

| Thing | States | Transition and trigger |
|-------|--------|------------------------|
| Fragment | Present, Collected | Present to Collected on the first touch by a living Seeker: `collected` is raised that frame (rule 4). A fragment whose flag is raised is never Present again: it frees itself at each room build. Never reverts (World state rule 3). |
| Set progress (per kind) | `held` 0 to `steps_max x step_size`; steps 0 to `steps_max` | Derived from the record and the catalogue (rules 6, 7), never stored. Rises by one `held` per collection; a step is gained on the collection that makes `held` a whole multiple of `step_size`. Never falls. |

No state in this table can move backward.

### Interactions with Other Systems

Of these, only World state, Level design, Rooms and transitions and Save points have GDDs; the rest have code or are not designed, and each interface is **provisional** until its owner is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| World state | Both | Out: a fragment's `collected` flag, raised on the touch frame (rules 2, 5). In: the record at each build and on load, from which `held` and the steps are derived (rule 6, World state rule 12) | World state owns storage; this system owns the flag's meaning |
| Level design | Both | In: where each fragment sits and how many each region holds, within rules 8, 12 and 13. Out: the catalogue's totals and rule 12's region 1 bound | Level design owns placement; this system owns the counts and the region 1 rule |
| Rooms and transitions | In | Object ids, room ids and the room build at which a collected fragment frees itself | Rooms and transitions |
| Health, damage and death | Out | Max health from the health steps, and current health set to it when a health step completes (rule 9); applied through `PlayerHealth` (`max_health`, today set once by `configure`, Code) | Health owns the values' use; this system owns the bonus |
| Combat | Out | The edge multiplier on every sword attack's health damage (`attack_data.tres` `damage`) and the guard multiplier on its guard-meter drain (`GuardConfig.guard_damage`), from the edge and guard steps | Combat owns damage; this system owns the multipliers |
| Save points and save/load | In | A rest sets health to max health (save points rule 4), which includes the health steps; a respawn and Continue configure the Seeker, so the steps are derived again (rule 9) | Save points |
| HUD and UI | Out | The collect note (rule 11); the health display's length follows max health | HUD |
| Bow and spell casts (later) | Out | The magic steps, read once those systems exist (rule 10) | Bow, Spell casts |
| Pause and menus (later) | Out | `held` and the steps per kind, for an optional collection view | Pause and menus |
| Grid map | None | The map never marks a fragment (rule 13, level design rule 23) | Grid map |

## Formulas

All values are read from a data file (the catalogue and a collectible config), never from constants in code. The figures they act on come from `player_config.tres` (`max_health` 100), `attack_data.tres` (sword health damage 8-30) and `GuardConfig` (`max_guard` 100, `guard_damage` 8-30 per attack), and the enemy `.tres` files (enemy hits 10-30). Every starting value below was approved by the owner on 2026-11-21. The `systems-designer` lens was applied in-session (lean mode: no agent).

### F1. Steps per kind

The steps formula is defined as:

`steps(kind) = min(steps_max(kind), floor(held(kind) / step_size(kind)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| held(kind) | int | 0 to `steps_max x step_size` | calculated (rule 6) | Catalogue entries of this kind whose `collected` flag is raised |
| step_size(kind) | int | 2-6; health 4, edge 3, guard 3, magic 3 | data file | Fragments per step. At least 2: at 1 every find is a whole step and region 1 could hold none of the kind (rule 12); at 0 the division fails |
| steps_max(kind) | int | 0-6; health 4, edge 3, guard 3, magic 3 | data file | The step cap. 0 means the kind is not used in the game (the catalogue then holds 0 entries of it) |

**Output Range:** 0 to `steps_max(kind)`. Under rule 8, `held` exceeds `steps_max x step_size` only through a retired catalogue entry that the player collected before it was retired (Edge Cases). The `min` caps the steps there. A part set adds nothing.
**Example:** 7 health fragments held at step size 4: `floor(7 / 4)` = 1 step; the 8th makes 2.

**Catalogue totals (rule 8, at full release):** `steps_max x step_size` per kind: health 16, edge 9, guard 9, magic 9, 43 fragments over the full game's 8 regions (about 5 per region); earlier builds hold fewer. **Region 1 bound (rule 12):** at most `step_size - 1` of each kind, so at most 3 health, 2 edge and 2 guard, and no magic (rule 10).

### F2. Max health

The max_health formula is defined as:

`max_health = base_max_health + steps(health) x health_step`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_max_health | float | 100 | data file (`player_config.tres` `max_health`, owned by the player controller) | Max health with no steps |
| steps(health) | int | 0-4 | calculated (F1) | Health steps held |
| health_step | float | 10-30, starts at 20 | data file | Max health added per step. At 0 health fragments do nothing |

**Output Range:** 100 to 180 at the starting values (+80%, the same ratio as Hollow Knight's 5 to 9 masks). Current health is set to `max_health` on the frame a step completes (rule 9).
**Example:** with 4 steps, 180 max health: a grunt hit (15) kills in 12 hits instead of 7, a brute hit (30) in 6 instead of 4.

### F3. Edge multiplier

The edge_mult formula is defined as:

`edge_mult = 1 + steps(edge) x edge_step`, and every sword attack's health damage is `damage x edge_mult`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| steps(edge) | int | 0-3 | calculated (F1) | Edge steps held |
| edge_step | float | 0.05-0.20, starts at 0.10 | data file | Health-damage gain per step |
| damage | float | 8-30 | data file (`attack_data.tres`, owned by Combat) | An attack's base health damage, before the charged, guarded and finisher multipliers |

**Output Range:** x1.0 to x1.3 at the starting values. It multiplies with Combat's own multipliers (charged heavy x2, guarded x0.25, finisher x2), so the order does not matter. It applies to every sword attack, the pogo's down attack included, and to no bow or spell.
**Example:** at 3 steps a charged heavy deals 30 x 2 x 1.3 = 78 instead of 60; a 600-health boss takes about 23% fewer hits of health damage.

### F4. Guard multiplier

The guard_mult formula is defined as:

`guard_mult = 1 + steps(guard) x guard_step`, and every sword attack's guard-meter drain is `guard_damage(attack) x guard_mult`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| steps(guard) | int | 0-3 | calculated (F1) | Guard steps held |
| guard_step | float | 0.05-0.20, starts at 0.10 | data file | Guard-drain gain per step. Bounded with the cap: `steps_max(guard) x guard_step <= 0.60`, compared with a tolerance of 0.001 (`3 x 0.2` is `0.6000000000000001` in floating point), so at full guard steps an uncharged heavy still takes at least 3 hits and a light-only break at least 6 (at 3 steps, `guard_step` 0.20 is the most allowed) |
| guard_damage(attack) | float | 8-30 | data file (`GuardConfig`, owned by Combat) | An attack's drain on the guard meter |
| max_guard | float | 100 | data file (`GuardConfig`) | A full guard meter |

**Output Range:** x1.0 to x1.3 at the starting values, never above x1.6 (the bound `steps_max(guard) x guard_step <= 0.60`, checked when the config loads; revised from 0.75 at the 2026-11-21 design review, because an uncharged heavy drains 30 and would break a full guard in 2 hits at x1.75). Only bosses, mini-bosses and the tutorial foe have a guard (level design rule 20), so guard steps only matter there. A fully charged heavy breaks a guard whatever the meter (Combat), so guard steps shorten the two other routes to a break: the light combo and the uncharged heavy (a heavy released before full charge, drain 30). Inside the safe range no two hits break a full guard: two uncharged heavies drain 60 x 1.6 = 96, under 100.
**Example:** the 3-hit combo drains 10, 10, 20 and an uncharged heavy drains 30. Hits to break a full guard, light-only and uncharged-heavy-only: 0 steps 8 and 4; 1 step (x1.1) 8 and 4; 2 steps (x1.2) 7 and 3; 3 steps (x1.3) 6 and 3; the cap (3 steps of 0.20, x1.6) 6 and 3. The first guard step at 0.10 changes neither count (Game Feel, Open Question 9).

**Magic steps** are F1's output for the magic kind (0-3) and nothing more: turning them into a reserve belongs to the Spell casts GDD (rule 10).

**Feedback loops:** none. The supply is fixed and hand-placed, so a find never yields another find and no stat feeds back into collecting. The one balance consequence is outward: later regions' enemies and bosses are tuned for the steps a player can hold by then (Enemies and Bosses GDDs).

## Edge Cases

`systems-designer` not consulted for this section: Lean mode. Review manually before production.

- **If the Seeker touches two fragments on the same frame**: both `collected` flags are raised that frame and `held` rises by both. One note shows: the step note if either completes a step ("Max health raised"), otherwise the progress note of the last fragment counted. If both are of different kinds and both complete a step, the note names both stats.
- **If a set's last fragment is touched on the frame the Seeker takes damage**: the step applies at once (rule 9), and its refill to the new max health is applied at the end of the frame, after that frame's damage. A Seeker whose health reached zero on that frame stays dead (`PlayerHealth.depleted` has fired), and the fragment stays collected (World state Edge Cases). The outcome does not depend on the order objects are processed in. **[Rec]**
- **If a player saves a set's last fragment as an emergency heal**: possible, and bounded: a fragment is used once, so at most 4 health refills exist in the whole game. No fragment sits inside a boss or mini-boss arena or behind an arena lock, so none can be taken mid-fight. **[Rec]**
- **If a fragment sits in a sealed alcove a player reaches by a leak** (level design rule 12): it is collected and counts like any other. In region 1 it still cannot complete a set (rule 12), because the region-1 bound counts every fragment placed in region 1, reachable or not.
- **If a patch removes a fragment from the game**: its catalogue entry is never deleted; it is marked `retired` and still counts when its flag is raised, so a player who collected it keeps the step. A retired entry is not placed in any room and is left out of rule 8's total, so `held` can exceed the total and F1's `min` caps the steps. **[Rec, as for the entity registry: never delete, deprecate]**
- **If a patch changes a step size or a cap**: after release, `step_size` may only fall and `steps_max` may only rise, so no saved player loses a step. A change that would lower any reachable step count is rejected by the catalogue check, as is a lowered `step_size` that leaves region 1 holding a full set (rule 12). A fragment's `kind` never changes after release. **[Rec]**
- **If a saved flag names a fragment the catalogue does not list**: it is kept in the record (World state rule 10) and counts toward nothing.
- **If the Seeker dies while the collect note is showing**: the note ends with the death; the fragment is already collected and the step, if any, already applied.
- **If a health step completes while health is already full**: max health rises and current health is set to it, so the bar grows full.
- **If an edge or guard step completes mid-combo**: it applies from the next hit (rule 9); a hit already landed is not recomputed, and a guard already broken stays broken.
- **If a magic step completes before the bow and spells exist**: the step is derived and kept like any other, the note says "Magic raised", and it takes effect when those systems read it (rule 10). In the core build this cannot happen (rule 10: no magic is placed before the spells exist).
- **If a fragment overlaps a gate's pogo clearance volume** (level design rule 24, F7): it is not in the `hittable` group, so it is not a pogo target and does not break the gate.
- **If a new game is started**: the record is empty (World state rule 3), so every `held` is 0 and every stat is its base value.

## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| World state | Hard | The forward-only `collected` flag per fragment, raised on the touch frame and committed that frame; the record at each build and on load (rules 4, 6; World state rules 2, 3, 5, 12) | Yes (`design/gdd/world-state.md`, Approved) |
| Level design | Hard | Fragment placement: where each sits and how many each region holds, within rules 8, 12 and 13 (secrets, reward rooms and sealed alcoves; never in an arena; region 1 below a full set) | Yes (`design/gdd/level-design.md`, Approved) |
| Rooms and transitions | Hard | Stable room ids and object ids that are never reused (its rule 3); the room build at which a collected fragment frees itself | Yes (`design/gdd/rooms-and-transitions.md`, In Review) |
| Health, damage and death | Hard | `PlayerHealth` with a `max_health` this system can raise after configure, and a refill to it that leaves invulnerability running (a setter: `configure` clears it, rule 9); `depleted` for the same-frame death case | No (code exists: `src/player/player_health.gd`; `max_health` is set once by `configure` today) |
| Combat | Hard (edge and guard only) | Each sword attack's health `damage` (`attack_data.tres`) and guard drain (`GuardConfig.guard_damage`), with a place to apply the multipliers of F3 and F4 | No (code exists: `attack_data.tres`, `guard_component.gd`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Save points and save/load | Hard | A rest, a respawn and Continue set health to the **derived** max health (F2), not the base `max_health` in `player_config.tres` (adopted: Save points rule 4 reads it) |
| HUD | Soft | The collect note (rule 11) and a health display whose length follows max health |
| Enemies and Bosses | Soft | The steps a player can hold by each region, to tune later regions (Formulas, Feedback loops) |
| Bow and Spell casts (later) | Soft | The magic steps (rule 10) |
| Pause and menus (later) | Soft | `held` and steps per kind for an optional collection view |
| Healing | Soft | Reads the derived max health (F2) when a heal completes; the edge multiplier must not speed the heal meter (`healing.md` Dependencies seam; no edge step can complete in region 1, rule 12) |

**Bidirectional check (2026-11-21):**
- **World state** lists Collectible upgrades as a hard dependent needing "its pickups' `collected` flags". This matches.
- **Level design** lists Collectible upgrades as a soft downstream needing "where reward rooms sit". It should adopt this system's placement rules: the catalogue totals (rule 8), the region 1 bound (rule 12), and no fragment in an arena (Edge Cases). Its row then becomes "where fragments sit and how many, within collectible upgrades rules 8, 12 and 13". Level design rates the dependency Soft and this GDD rates it Hard (no fragment can be placed without it): reconcile when Level design adopts the rules.
- **Save points** adopted the derived max health in its rule 4 (the base plus the health steps, registry `max_health_derived`; confirmed at the 2026-11-21 design review). Its Dependencies table still does not list this system, and it should. Its rule 8 refills on arrival through `PlayerHealth.reset()`, which is why rule 9 here names the entry points.
- **Rooms and transitions** does not list this system. It needs no change beyond naming it as a user of object ids.
- **Health, Combat, HUD, Enemies, Bosses, Bow, Spell casts, Pause and menus** have no GDD yet. Each needs a matching entry when designed.

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode (optional for a Progression system). Review manually before production. The art bible (`design/art/art-bible.md`, sections 1-4) owns the look; this section lists what this system needs from it.

- **A fragment reads as touchable.** It has hard edges and a light value, per the art bible's rule: "Hard edges and light values mark what you can touch or hurt". It still sits below peak brightness, because "reward is an event of maximum light, not a pickup colour" (art bible section 4). Flash White stays reserved for the sword arcs and the guard-break spark.
- **Never a key's look.** A fragment uses no key colour as its main colour and no key's reserved shape (art bible section 3: the bisque pane, the vertical grooves, the kiln shelf on stilts, the iron ring and cord), so a fragment is never mistaken for a key pickup.
- **Four kinds, told apart by shape first.** Each kind has its own silhouette, readable in greyscale, with colour as a reminder, as for keys. Candidates to choose in the art bible's later sections: a heart-shaped shard (health), a sliver of ore (edge), a chip of glaze (guard), a mote of light (magic).
- **Collect:** a short flash on the touch frame, kept dimmer than a guard break, and a short cue distinct for each kind, quieter than a key pickup's cue. A completed step has its own longer cue, the one sound that says a stat rose.
- **No hint in the world.** A fragment gives no audio tell from off screen. It is found by looking, as level design rule 19's secrets are.

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:collectible-upgrades` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

These are design targets, not acceptance criteria: they guide placement and become playtest questions.

- **A find is a small win; a set is a big one.** Each fragment's note lands at once. The step's cue and the health bar growing full mark the larger moment. That is 13 steps in all at the starting values, one or two per region after region 1.
- **Worth a detour, never a chore.** At least 4 of 5 playtesters asked after a region describe the fragments they found as "hidden", and none describes a fragment as "in the way".
- **The upgrade is felt.** After the first edge step, a playtester asked whether their sword got stronger says yes without being told; F3's 10% per step is the starting value to test that against. Computed from the `.tres` values (the combo's 10, 12, 20 repeated; verify when Combat has a GDD), hits to kill at 0, 1, 2 and 3 edge steps: skitter (50) 4, 4, 3, 3; grunt (85) 7, 6, 6, 6; brute (220) 16, 15, 14, 13; the 600-health boss 44, 39, 36, 33. Every edge step moves at least one of them.
- **The guard upgrade is felt.** At the starting 0.10 the first guard step changes no hit count: light-only break 8, 8, 7, 6 and uncharged-heavy break 4, 4, 3, 3 at 0, 1, 2 and 3 steps (F4). A playtester cannot feel it until the second step. Open Question 9.
- **Region 1 plants the hook.** In the core build a playtester asked "what were the fragments for?" can say the stat a set would raise, from the notes alone, though no set completes there (rule 12).

## UI Requirements

- The collect note (rule 11): kind and progress ("Health fragment 2 of 4"), or the stat raised. It is shown for about 2 seconds, does not pause play, and stacks with nothing else. Its text comes with the lore (Lore delivery) and is localizable.
- The health display grows with max health (F2). Its look belongs to the HUD, and per the art bible it uses no key colour.
- No persistent HUD counter, and no map marker for a fragment (rule 13). A collection view, if any, belongs to Pause and menus and reads `held` and the steps per kind.

📌 **UX Flag — Collectible upgrades**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to (the collect note, the health display's growth) **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner (system) | Status |
|---------------|----------------|--------|
| `collected` flag, forward-only record, raised on the touch frame, death undoes nothing, rewards derived not stored (rules 4, 6; World state rules 2, 3, 4, 5, 10, 12) | World state | `design/gdd/world-state.md`, Approved |
| Secrets in dead ends (rule 19), sealed alcoves holding "a pickup or a lore item" (rule 2), leaks (rule 12), no item marked on the map (rule 23), guards only on bosses, mini-bosses and the tutorial foe (rule 20), the pogo target set (rule 24) | Level design | `design/gdd/level-design.md`, Approved |
| Room ids and object ids, never reused (rule 3); the room build | Rooms and transitions | `design/gdd/rooms-and-transitions.md`, In Review |
| A rest sets health to max health (rule 4); a dead Seeker triggers no pickup (rule 6) | Save points and save/load | `design/gdd/save-points-and-save-load.md`, Approved; rule 4 reads the derived max health (F2); its Dependencies table does not list this system yet |
| `max_health` 100, `PlayerHealth.configure`, `reset`, `depleted` | Health, damage and death | Code (`player_config.tres`, `player_health.gd`); no GDD |
| Sword health `damage` per attack, charged x2 (`attack_data.tres`); `guard_damage` per attack, `max_guard` 100, guarded x0.25, finisher x2, a charged heavy breaks a guard (`GuardConfig`, `guard_component.gd`) | Combat | Code; no GDD |
| Enemy hits 10, 15 and 30 (skitter, grunt, brute; the enemy `.tres` files) | Enemies | Code; no GDD |
| The touch-and-free pickup pattern (`AbilityPickup`); keys are never fragments | Ability gating | `design/gdd/ability-gating.md`, Approved |
| Touchable reads hard and light; peak brightness is the reward event; key colours and reserved shapes belong to keys (sections 1, 3, 4) | Art bible | `design/art/art-bible.md`, sections 1-4 |

## Acceptance Criteria

Types: **[Auto]** automated test (unit test, or a check on the catalogue and room data); **[Shot]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest record. At standard rigor, Logic and Integration need a test or a playtest record; Visual and UI need a screenshot. The `qa-lead` lens was applied in-session (lean mode: no agent).

**Fragments (rules 1-5)**
- **GIVEN** a catalogue with one entry of each of the four kinds and one of kind `lore`, **WHEN** the catalogue check runs, **THEN** the four pass and the `lore` entry is rejected by name. **[Auto]** (rule 1)
- **GIVEN** the room data of every room, **WHEN** the catalogue check runs, **THEN** a fragment in a room but not in the catalogue is rejected, a catalogue entry whose room holds no such object is rejected unless it is `retired`, and an object id listed twice is rejected; a catalogue and rooms that match pass. **[Auto]** (rules 2, 3)
- **GIVEN** a fragment not yet collected and a living Seeker, **WHEN** the Seeker touches it on frame N, **THEN** on frame N its `collected` flag is in the record, the fragment can no longer be touched (not monitorable), it frees itself when its collect flash ends, and the collect note is showing. **[Auto]** for the flag, the touch and the freeing; **[Shot]** of the note (rule 4)
- **GIVEN** a record in which a fragment's `collected` flag is raised, **WHEN** its room is built, **THEN** the fragment is not in the room on the first frame. **[Auto]** (rule 4)
- **GIVEN** a dead Seeker whose body slides into a fragment, **THEN** its flag stays unraised. **GIVEN** a fragment touched on the frame the Seeker's health reaches zero, **THEN** its flag is raised and still raised after the respawn. **[Auto]** (rule 4, Edge Cases)
- **GIVEN** the region's room graph with every fragment removed, **WHEN** the level design route checks run, **THEN** every key, boss and save is still reachable and the region goal can be reached. **[Auto]** (rule 5)

**Sets and steps (rules 6-10, F1)**
- **GIVEN** any record, **WHEN** it is saved, **THEN** the save holds no fragment count and no stat bonus, only `collected` flags. **[Auto]** (rule 6)
- **GIVEN** health `step_size` 4 and `steps_max` 4, **WHEN** `held(health)` is 0, 3, 4, 7, 16 and 17, **THEN** `steps(health)` is 0, 0, 1, 1, 4 and 4. **GIVEN** a config with `step_size` 1 or 0, **WHEN** it is validated, **THEN** it is rejected by name. **[Auto]** (rule 7, F1, boundary)
- **GIVEN** the full-game catalogue, **WHEN** the release-gate check counts entries per kind (retired entries excluded), **THEN** health has 16, edge 9, guard 9 and magic 9 at the starting values; a catalogue with 15 health entries is rejected. **GIVEN** the core build's catalogue (region 1 only), **THEN** the exact-total check is not run, a catalogue with 17 health entries is rejected, and one with 3 passes. **[Auto]** (rule 8, F1)
- **GIVEN** 3 health fragments held and current health 40 of 100, **WHEN** the 4th is collected on frame N, **THEN** max health is 120 from frame N and current health is 120 at the end of frame N. **GIVEN** the same record saved and reloaded, **THEN** max health is 120 on the first frame after the load. **[Auto]** (rule 9, F2)
- **GIVEN** 3 edge steps and 3 guard steps in the record, **WHEN** the game is loaded, and again **WHEN** the Seeker respawns, **THEN** from the first frame a light hit deals 1.3 times its base health damage and drains 1.3 times its base guard. **GIVEN** an edge step completing between hit 1 and hit 2 of a combo, **THEN** hit 1 is not recomputed and hit 2 deals the new value. **GIVEN** a health step completing while the Seeker is invulnerable, **THEN** the invulnerability time left is unchanged. **[Auto]** (rule 9)
- **GIVEN** a magic step held, **WHEN** max health, sword damage and guard drain are measured, **THEN** each equals its value without the magic step, and `steps(magic)` reads 1. **[Auto]** (rule 10)

**Formulas (F2-F4)**
- **GIVEN** 0, 1 and 4 health steps at `health_step` 20, **THEN** max health is 100, 120 and 180. **[Auto]** (F2, boundary)
- **GIVEN** 0 and 3 edge steps at `edge_step` 0.10, **WHEN** a fully charged heavy (damage 30, charged x2) hits an unguarded target, **THEN** it deals 60 and 78. **GIVEN** 3 edge steps, **WHEN** a down attack and the 3-hit combo land, **THEN** each deals 1.3 times its `attack_data.tres` damage. **[Auto]** (F3, boundary)
- **GIVEN** a full guard of 100 and light attacks only (the combo's drains 10, 10, 20 repeated, each hit landing within `regen_delay` of the last), **WHEN** 0 and 3 guard steps at 0.10, and 3 steps at 0.20 are tested, **THEN** the guard breaks on hit 8, 6 and 6. **GIVEN** uncharged heavies only (drain 30), **THEN** it breaks on hit 4, 3 and 3. **GIVEN** a config with `steps_max(guard)` 3 and `guard_step` 0.21, or `steps_max(guard)` 4 and `guard_step` 0.16, **THEN** it is rejected (`steps_max x guard_step` over 0.60); 3 and 0.20, and 4 and 0.15, pass (the check uses a 0.001 tolerance). **GIVEN** 3 guard steps, **WHEN** a fully charged heavy hits a full guard, **THEN** the guard breaks as it does with 0 steps. **[Auto]** (F4, boundary)

**Feedback and placement (rules 11-13)**
- **GIVEN** 1 health fragment held, **WHEN** a second is collected, **THEN** the note reads "Health fragment 2 of 4"; **WHEN** the fragment that completes a step is collected, **THEN** the note reads "Max health raised"; play is not paused while it shows, and no HUD counter appears. **[Auto]** for the text and no pause; **[Shot]** of each note (rule 11)
- **GIVEN** region 1's room data, **WHEN** the catalogue check counts its fragments per kind (reachable or not), **THEN** no kind reaches its `step_size`: at most 3 health, 2 edge, 2 guard, 2 magic, and the core build places no magic (rule 10); a region 1 with 4 health fragments is rejected. **[Auto]** (rule 12)
- **GIVEN** every fragment, **WHEN** the room check runs, **THEN** none lies inside a boss or mini-boss arena or behind an arena lock, and the grid map shows no marker for any fragment. **[Auto]** (rule 13, Edge Cases)
- **GIVEN** the four fragment kinds on a test background, **WHEN** a screenshot is taken in greyscale, **THEN** the four silhouettes are told apart and none matches a key's reserved shape (art bible section 3). **GIVEN** a collect on a lit background, **THEN** the flash's peak brightness is below the guard-break spark's in the same scene. **[Shot]** in `production/qa/evidence/`, with art director sign-off (Visual/Audio Requirements)
- **GIVEN** a collect note, **WHEN** it is timed from the touch frame, **THEN** it is gone between 1.8 and 2.2 seconds later and play was never paused. **[Auto]** (rule 11, UI Requirements)

**Edge cases and cross-system**
- **GIVEN** two fragments, one completing a health step, touched on the same frame, **THEN** both flags are raised, `held` rises by 2, and one note shows, "Max health raised". **[Auto]** (Edge Cases)
- **GIVEN** a set's last health fragment touched on the frame a hit brings current health to 0, **THEN** the Seeker dies, the fragment stays collected, and after the respawn max health includes the step. **[Auto]** (Edge Cases)
- **GIVEN** a catalogue change that would lower the steps of a saved player (a `step_size` raised, a `steps_max` lowered or an entry deleted rather than retired), **WHEN** the catalogue check compares it with the last shipped catalogue, **THEN** it is rejected. **GIVEN** a retired entry whose flag is raised, **THEN** it still counts. **[Auto]** (Edge Cases)
- **GIVEN** 4 health steps and current health 50, **WHEN** the Seeker rests at a save point, **THEN** current health is 180, not 100. **GIVEN** a respawn and a Continue, **THEN** the Seeker arrives with 180. **[Auto]** (cross-system: Save points rule 4, which reads the derived max health)

**Gaps found by the QA lens:**
- Rule 5's criterion needs the level design route checks on the room graph, which are not built yet.
- The note criteria assume a note element the HUD has not designed; their **[Shot]** evidence waits for the HUD UX spec.
- Rule 10 can only be tested as "inert". Its real effect is untestable until the Spell casts GDD exists.
- The save-point criterion is testable now, since Save points rule 4 reads the derived max health. It still needs Health code that can raise `max_health` after configure (Dependencies).

## Open Questions

Owner is the project owner unless stated. Each has a target step instead of a date.

1. **Region 1's fragments.** How many of each kind region 1 holds, within rule 12 (at most 3 health and 2 each of edge and guard; no magic, rule 10), and where they sit. Candidates in the narrative draft are the Tray Store reward room (room 15) and the sealed alcoves A1-A6. Owner: level design with the narrative side. Target: before region 1's grey-box.
2. **Magic before spells.** Resolved 2026-11-21 (owner, design review): none is placed until the Spell casts GDD exists (rule 10). Turning magic steps into a reserve, and the magic note text, belong to that GDD.
3. **The fragments' look.** The four silhouettes and their cues. Target: the art bible's later sections, then `/asset-spec`.
4. **Note text.** The four kind names and the step lines come from Lore delivery and must be localizable. Target: the Lore delivery GDD.
5. **Where the multipliers apply in code.** F3 and F4 act on Combat's values. Whether the multiplier sits in the attack, the hit or the guard component is a technical choice. Target: an ADR once Combat has a GDD.
6. **Owed changes in other GDDs.**
   - Save points: rule 4 already heals to the derived max health; add this system to its Dependencies table.
   - The registry: the `max_health_derived` note still says Save points must add itself to `referenced_by` (it is there); `edge_step`, `guard_step`, `edge_mult` and `guard_mult` are not registered, and its `health_steps` variable is `steps(health)` here.
   - Level design must adopt rules 8, 12 and 13 and the no-arena rule.
   - Rooms and transitions should name this system as a user of object ids.

   Target: the next revision of each.
7. **Scope.** The systems index sizes this system at S for one kind. Four kinds is larger. Owner: producer. Target: before sprint planning.
8. **Tuning later regions.** How many steps a player is expected to hold entering each region, so Enemies and Bosses can tune for it. Target: the Enemies and Bosses GDDs.
9. **The first guard step changes nothing.** At `guard_step` 0.10 the first step leaves the light-only (8 hits) and uncharged-heavy (4 hits) breaks unchanged (F4, Game Feel). A `guard_step` of 0.12 to 0.15 changes both at step 1 (to 7 and 3) and sits inside the 0.60 bound. Owner: game-designer with the owner. Target: before the first guard fragment is placed (a later region).
