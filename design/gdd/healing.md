# Healing (hit-fed heal meter)

> **Status**: Designed 2026-11-22 (`/design-system`, lean, standard, guided, balanced density); awaiting `/design-review` in a fresh session
> **Author**: owner + Claude
> **Last Updated**: 2026-11-22
> **Last Verified**: 2026-11-22
> **Implements Pillar**: P1 Movement Is the Mastery, P4 Two Jobs, Not One

## Summary

Healing is the Seeker's way to win health back mid-fight: every hit lands into a single heal meter, and a full meter can be spent on a 1.0 s planted channel that restores 30% of max health. A hit cancels the channel but keeps the meter, so the risk is time and damage, never the work of earning it. It exists because recovery should be earned by fighting well (pillar 1, anti-pillar 2: no consumables), and because the three-stage boss needs a player who can recover between stages.

> **Quick reference** — Layer: `Gameplay` · Priority: `MVP` · Key deps: `Combat, Player controller, Health (code); touches Guard-break, Collectible upgrades, Bosses, HUD`
> Engine feasibility: no engine reference for `Scripting` under `docs/engine-reference/godot/modules/`; feasibility not checked against the pinned engine (rule-only logic, no post-cutoff API expected).

## Overview

Healing lets the Seeker recover health in the middle of a fight, and it is earned by fighting. Every hit the Seeker lands fills a **heal meter**; once the meter is full enough the Seeker can spend it to restore health, as Hollow Knight's Focus does (owner, 2026-11-22). The player pays for a heal with good play (landing hits) and with the moment it takes to heal, never with an item, a currency or a trip to a save point. It is a system the player operates directly: they watch the meter fill, choose a safe moment and commit to the heal. The feeling to aim for is a breath won back by pressing the attack, and a gamble when the heal is started in a bad spot **[Rec]**. Without it, health is a one-way budget until the next rest, and a long boss fight punishes a single early mistake for the whole fight.

**Design intent**
- **Owner, 2026-11-22:** a meter filled by landing hits; the Seeker can heal when it is full, as in Hollow Knight. The exact rules (meter size, gain per hit, heal amount, channel time and the risk while healing, whether hits on a guarded foe count, whether it fills in a boss fight, whether it empties on death) were undecided and are settled in Detailed Design below.
- **Owner, 2026-11-22 (first boss playtest):** the boss was beaten and found "super easy"; the owner wants a three-stage boss with no health bar and a heal meter, and the boss is to be tuned together with healing (`bosses.md`, "Planned: three stages").
- **From the concept (anti-pillar 2):** no loot grind or crafting, so a heal is never a consumable, a purchase or a drop. A meter filled by combat fits that.
- **[Rec]** Pillar 1 (Movement Is the Mastery): the meter rewards landing hits while moving, so recovery comes from playing the fight well, not from retreating to farm it.

**Scope**: in: the heal meter (capacity, how it fills, whether it keeps or empties), the heal action (input, channel, cost, interruption), how it restores health, and the rules for foes and bosses. Out: the health pool, damage and death (R6, code in `player_health.gd`), the meter and health display (HUD, R9), the heal effect and sound (Hit feedback, R8), the max-health upgrades (Collectible upgrades), and the boss's stage tuning (Bosses).

## Detailed Design

### Core Rules

Tags: **[Owner]** = the owner's stated rule; **[Rec]** = recommendation, change freely; **[Code]** = how the code works today. `game-designer`, `systems-designer` and `gameplay-programmer` not consulted for this section: Lean mode. Review manually before production. Values named in `code font` are data, set in Formulas.

**The meter**

1. **One bar.** The heal meter is one number, `heal_meter`, from 0 to `meter_capacity`. It is a single bar, not segments: one full bar is one heal. **[Owner, 2026-11-22: a bar, a heal spends it all]**
2. **What fills it.** Every hit the Seeker lands on a foe adds `damage` to the meter (the meter is counted in damage units, so `meter_capacity` is the one number that sets how many hits a heal takes), where `damage` is the value Combat reports in `hit_landed` for that hit (the attack's base damage, with the charged heavy's x2 already in it, before the guarded, finisher and edge multipliers). A hit on a guarded foe or boss fills as much as any other: the guard multiplier does not reduce it. The killing blow counts. **[Owner, 2026-11-22: each hit fills by its attack's base damage; Rec: the charged heavy fills double]**
3. **Only foes feed it.** A hit counts only on a foe's hurtbox (the `hittable` areas of `EnemyBase`, bosses and the training dummy). A hit on anything else, such as a pogo on a hazard, a breakable or a pane, adds nothing. A hit on a foe that is already dead adds nothing. **[Rec]**
4. **The meter caps and keeps.** The meter never exceeds `meter_capacity`; the excess of a hit that crosses the cap is lost. It does not decay with time, and it keeps filling while health is full, so a player can arrive at a fight with a heal ready. **[Rec]**
5. **Resets.** The meter is 0 at a new game, after a Continue and after a death (the `revive` call). A rest at a save point and a room change leave it as it is. It is not saved: like health, it is not in the world-state record (world state rule 1). **[Owner, 2026-11-22: starts empty after a death, a Continue or a new game; a rest leaves it]**

**The heal**

6. **Input.** A new action, `heal`, held to heal. It starts a heal only when all of these hold: the meter is at `meter_capacity`, health is below max health, the Seeker is on the ground (the controller's GROUND state, not crouching), not attacking, not in hurt lock and not dead. If the meter is not full, or health is full, the press does nothing and starts nothing, and the player gets a "not ready" cue (UI Requirements). **[Rec: ground only, so a heal is a planted commitment and pillar 1's movement is not blocked mid-air]**
7. **The channel.** A started heal is a channel of `channel_time` (1.0 s). The Seeker is planted: it skids to a stop as it does while charging a heavy, and cannot attack, jump, dash or grapple except to cancel (rule 9). The channel runs on game time, so hit-stop stretches it (Edge Cases). **[Owner, 2026-11-22: 1.0 s channel, planted]**
8. **Completion.** When the channel timer reaches `channel_time` with the heal input still held **and health below max health**, the meter is spent in full (set to 0) and health rises by the heal amount (Formulas F2), never above max health. If health is already at max health at that moment (a health step refilled it mid-channel, Edge Cases), nothing is spent and nothing is healed: the meter is kept. Nothing is spent before that moment. **[Owner, 2026-11-22: the meter is spent only when the channel completes]**
9. **Cancelling.** The channel ends with nothing spent and no heal when any of these happens: the heal input is released; the Seeker presses jump, dash, grapple or attack; the Seeker takes a hit that lands (a hit in the invulnerability window does not land, so it does not cancel); the Seeker dies; a door, an exit or a rest takes over. The meter is kept in every case. The time already channelled is lost: there is no partial heal and no progress is kept. **[Owner, 2026-11-22: a hit cancels, meter kept; Rec: release and the movement presses cancel so the player is never stuck for 1.0 s]**
10. **No protection.** The channel gives no invulnerability, no damage reduction and no armour. A hit that lands cancels it and deals its full damage, and starts the controller's hurt lock and invulnerability as any hit does. **[Rec: the risk is the point; the hit cancels so it cannot be tanked through]**
11. **Fills do not happen during a heal.** The Seeker cannot attack while channelling, so nothing fills the meter then. A hit landed by a delayed source (none exist today) would still count. **[Rec]**

**Boss fights**

12. **The meter fills in a boss fight like anywhere else** (rule 2). A boss fight is where it matters most, so the boss's stages are tuned with the heal in mind. The starting values are **not** tuned to a heals-per-cycle target: Formulas F3 estimates that a skilled player can earn up to about 2 heals per guard-break cycle (one spent in the stagger, one banked), and whether that is fair is **decided in play** (AC-26); the boss's damage is tuned against what the playtests show. **[Owner, 2026-11-22: tune the boss together with healing; the numbers cannot say whether it feels balanced or fair, so some of these values are determined by play]**
13. **A stage change neither fills nor empties the meter.** What the stage transition does to the player's heal is not decided here; see Open Questions.

### States and Transitions

The meter has no states of its own: it is a number, and "full" means `heal_meter >= meter_capacity`. The heal action has these states, run by the player controller (Dependencies):

| State | Meaning | Enters when | Leaves when |
|-------|---------|-------------|-------------|
| `IDLE` | No heal in progress | Start of play; a heal completes or is cancelled | The heal input is pressed and rule 6 holds: to `CHANNEL` |
| `CHANNEL` | Planted, timer running from 0 to `channel_time` | Rule 6 holds on a press | The timer reaches `channel_time` with the input held: to `IDLE` after the heal and the spend, or with nothing spent when health is already at max (rule 8). Any cancel (rule 9): to `IDLE`, nothing spent |

Meter and health outcomes of `CHANNEL`'s exits:

| Exit | Meter | Health | Player state after |
|------|-------|--------|--------------------|
| Completes (health below max) | 0 | + heal amount (capped) | GROUND, control returns |
| Completes with health already at max | kept | unchanged | GROUND, control returns |
| Released early | kept | unchanged | GROUND |
| Jump, dash, grapple or attack pressed | kept | unchanged | the pressed action starts |
| A hit lands | kept | - the hit's damage | HURT (or DEAD) |
| Death | 0 on revive | 0 | DEAD |

### Interactions with Other Systems

Of these, only Combat, Guard-break, Player controller, Bosses and Collectible upgrades have GDDs; Health, damage and death (R6), Hit feedback (R8) and the HUD (R9) have code or nothing, and each interface to them is **provisional** until its owner is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Combat | In | `hit_landed(target, attack, damage)`: `damage` feeds rule 2. Combat's charged x2 is inside it | Combat owns the signal; this system owns what a hit adds to the meter |
| Guard-break | None directly | Healing reads no guard state: a guarded hit fills at full (rule 2). A guard-break stagger is simply a window in which the player can heal or punish | Guard-break; this system owns the fill |
| Player controller | Both | In: the `heal` input, the state (ground, attacking, hurt lock, dead), the landed-hit and death signals. Out: a `CHANNEL` state that plants the Seeker and the cancel rules | Controller owns states and input; this system owns when a heal may start, run and end |
| Health, damage and death | Out | The heal amount, applied to `PlayerHealth.current` without touching invulnerability (a new method, Dependencies) | Health owns the values; this system owns the amount and when it applies |
| Collectible upgrades | In | Max health (derived, 100 to 180): the heal amount is a share of it (F2) so it keeps its meaning as max health grows | Collectible upgrades owns max health; this system owns the heal share |
| Enemies, Bosses | In | Every foe hit, via `hit_landed`. Bosses are tuned against what the playtests show of heals per guard-break cycle (F3 estimates about 2 for skilled play) | Bosses owns the boss's tuning; this system owns the heal values |
| Save points | None | A rest leaves the meter alone (rule 5) while it heals health to full | Save points |
| HUD | Out | `heal_meter`, `meter_capacity`, ready and not-ready cues, the channel progress | HUD (R9) owns the display; provisional |
| Hit feedback and effects | Out | A fill pulse, a ready cue and the heal effect | Hit feedback (R8); provisional |

## Formulas

Values are data (a `HealingConfig` resource, e.g. `src/player/healing_config.tres` **[Rec]**), never constants in code. The figures they act on come from `attack_data.tres` (damage 8-30, charged heavy x2), `player_config.tres` (`max_health` 100, up to 180 with collectible upgrades) and the enemy and boss `.tres` files. Starting values approved by the owner on 2026-11-22. The `systems-designer` lens was applied in-session (lean mode spawns no agent); every variable was worked at its minimum, its maximum and 0.

### F1. Meter fill

The meter_fill formula is defined as:

`heal_meter' = min(heal_meter + max(damage, 0), meter_capacity)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| heal_meter | float | 0 to `meter_capacity` | calculated | The meter before the hit; 0 at a new game, a Continue and a death |
| damage | float | 8-60 | calculated (Combat `hit_landed`) | The hit's base damage: `attack_data.tres` damage, with the charged heavy's x2, before the guarded, finisher and edge multipliers |
| meter_capacity | float | 40-300, starts at 120 | data file | The meter value at which a heal is ready. At 0 every heal would be free; below 40 a heal is under one combo of hits. Above about 300 a boss cycle never fills it |

**Output Range:** 0 to `meter_capacity`. The excess of a hit that crosses the cap is lost.
**Example:** meter at 100, a charged heavy lands (30 x 2 = 60): `min(100 + 60, 120)` = 120, and 40 is lost. A first combo from empty: 10 → 22 → 42.

### F2. Heal amount

The heal_amount formula is defined as:

`health' = min(health + heal_share x max_health, max_health)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| health | float | above 0 up to `max_health` | calculated (`PlayerHealth.current`) | Health when the channel completes; a heal never starts at 0 (dead) or at full (rule 6) |
| max_health | float | 100-180 | calculated (collectible upgrades F2, registry `max_health_derived`) | The current derived max health, read at completion, never copied |
| heal_share | float | 0.10-0.50, starts at 0.30 | data file | The share of max health one heal restores. At 0 a heal only spends the meter; at 1.0 a heal is a full refill and the health pool stops mattering |

**Output Range:** the amount restored is `heal_share x max_health`: 30 at 100 max health, 54 at 180 (at the starting share); the cap makes the effective gain smaller near full health.
**Example:** health 70 of 100: `min(70 + 30, 100)` = 100. Health 80 of 100: capped at 100, 10 of the 30 is unused (the meter is spent in full, rule 8). At 180 max and health 90: `min(90 + 54, 180)` = 144.

### F3. Hits per heal and the boss-cycle check

This is a tuning check, not a runtime calculation. The hits_per_heal and cycle_heals formulas are defined as:

`hits_per_heal = meter_capacity / mean_hit_damage`
`cycle_fill = guard_fill + fill_rate x stagger_window`, where `guard_fill` is the damage of the hits that break the guard and `stagger_window = stagger_time` (or `stagger_time - channel_time` when the player heals inside the stagger, since nothing fills during a channel)
`cycle_heals = cycle_fill / meter_capacity` before the cap; the effective count is lower, because the meter holds at most one heal (rule 4) and surplus is lost

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| meter_capacity | float | 40-300, starts at 120 | data file | As in F1 |
| mean_hit_damage | float | 8-60 | calculated | The average damage of the hits the player uses; 14 for light combos (10, 12, 20 repeating: mean 14), 30 for uncharged heavies |
| guard_fill | float | 0 upward | calculated | Damage of the hits from a full guard to the breaking hit: 106 for steady light combos (`guard-break.md` F2: 8 hits) |
| fill_rate | float | 0 upward | estimated | Fill per second while landing combos. About 49 for light combos: a 3-hit combo (42) takes about 0.86 s, from the clip durations in `seeker_animations.json` (attack1 chains at frame 5, about 0.18 s; attack2 at frame 4, about 0.16 s; attack3 plays out 0.52 s). **An estimate to be measured**, not a tested figure |
| stagger_time | float | 2.5 s default, 4.0 s boss | data file (`guard_config.tres`) | The window in which every hit lands at full damage. Hits do not extend it (`guard-break.md` rule 3) |
| cycle_fill | float | 0 upward | calculated | Damage landed from a full guard to the end of the stagger |
| cycle_heals | float | 0 upward | calculated | Heals earned in one cycle before the cap. **Not a target**: see Core Rules 12 and AC-26 |

**Output Range:** `hits_per_heal` is 2 (two charged heavies) to 15 (pogo hits at 8) at the defaults, and 0.67 to 37.5 across the whole capacity and damage ranges. `cycle_heals` has no target band: it is a number the playtests read (AC-26), not a pass-fail check **[Owner, 2026-11-22: determined by play]**.
**Example (boss, light combos, estimate):** the guard breaks on the 8th hit (attack1, 2, 3, 1, 2, 3, 1, 2: `guard-break.md` F2), `guard_fill` = 10+12+20+10+12+20+10+12 = 106. The stagger is 4.0 s, so landing combos for all of it gives `fill_rate x 4.0` = about 195, `cycle_fill` about 300 and `cycle_heals` about 2.5 before the cap. The meter is full about 0.3 s into the stagger (14 more fill). A player who then heals for 1.0 s refills in the remaining 2.7 s (about 132, capped at 120): one heal spent in the stagger and one banked, so about **2 heals per cycle** for skilled play, and 1 for a player who only punishes. This replaces the earlier two-swing count, which ignored that a 4.0 s stagger holds about 4.6 combos. Two charged heavies alone: 120, one heal.

### Values (`HealingConfig`)

| Value | Starts at | Range | Used by |
|-------|----------:|-------|---------|
| `meter_capacity` | 120 | 40-300 | F1, F3 |
| `heal_share` | 0.30 | 0.10-0.50 | F2 |
| `channel_time` | 1.0 s | 0.5-2.0 s | Core Rules 7, 8. Below 0.5 s a heal can be squeezed into any gap and boss wind-ups stop punishing it; above 2.0 s it outlasts every boss recovery (1.0-1.3 s) and a heal is only safe in a stagger |

`HealingConfig.validate()` returns the name of every value outside its range; it runs when the config loads and a non-empty result stops the game and names the values, as the save-point config does **[Rec]**.

**Feedback loops:** one positive loop, intended: a heal keeps the player alive longer, so they land more hits and earn more heals. It is damped three ways: the cap (at most one heal per `meter_capacity` of damage), the 1.0 s planted channel (a heal costs a boss recovery window, and the boss's attacks cancel it), and the heal share (30% of max, so a player needs to keep fighting well to stay ahead of a boss's 40-damage slam). It is not damped against farming: see Edge Cases. **Seam:** collectible upgrades F3 raises sword health damage by up to x1.3; this system reads the damage **before** that multiplier, so edge steps do not make heals faster (Dependencies).

## Edge Cases

`systems-designer` not consulted for this section: Lean mode. Review manually before production. Every case below is a **[Rec]** unless tagged otherwise, and the system is not built, so none is "handled in the code".

**Starting and ending a heal**
- **If `heal` is pressed with the meter full and health full**: nothing starts, nothing is spent, and the "not ready" cue plays. The meter stays full for the next fight.
- **If `heal` is pressed with the meter below capacity**: nothing starts and the "not ready" cue plays. There is no buffering: a press that fails is gone, and a press 0.1 s before the meter fills does not start a heal later.
- **If `heal` was already held when the conditions began to hold** (for example held through an attack or the end of hurt lock): it does not start a heal. The player must release and press again, so mashing the button during a fight never starts a 1.0 s plant by accident.
- **If `heal` is pressed in the air, crouched, in an attack's lock window, during hurt lock, on a ladder, grappling or on a wall**: nothing starts (rule 6), the cue plays and nothing is buffered.
- **If `heal` is pressed during a door transition or a rest**: the controller has locked input (`save-points-and-save-load.md`, Resting), so the press never reaches the heal logic: nothing starts and **no cue plays**.
- **If the Seeker is inside its invulnerability window (after a landed hit) and hurt lock is over**: a heal may start. The remaining window protects the first part of the channel; this is accepted, not a bug.
- **If `interact` is pressed in a door or rest area while channelling**: the door or rest takes over and the channel is cancelled with the meter kept (rule 9). Movement cannot carry the Seeker through an exit during a channel because the Seeker is planted.

**During the channel**
- **If a hit lands on the same physics tick the timer reaches `channel_time`**: the hit is resolved first, the channel is cancelled and no heal happens. The order is fixed so tests are deterministic.
- **If a hit arrives in the invulnerability window** (`take_hit` returns false): the channel is not cancelled, since no damage was dealt (rule 9).
- **If max health changes during the channel** (a collectible upgrade completes a health step, which also sets health to the new max): F2 reads max health at completion, so the heal uses the new value.
- **If health is already at max when the channel completes** (a health step refilled it mid-channel): the heal is not applied and the meter is **kept**; nothing is wasted. The channel ends without a cue of success.
- **If the Seeker dies during the channel**: the channel is cancelled, the meter is zeroed on `revive` (rule 5).
- **If the game is paused or the time scale drops** (pause freezes physics; hit-stop and slow-motion scale game time): the channel timer runs on game time, so a pause freezes it and hit-stop stretches it; it neither completes nor cancels while paused.
- **If a foe the Seeker cannot see lands a hit**: it cancels like any hit; there is no "safe" cancel.

**Filling**
- **If one swing hits two foes**: each foe's hit adds its own `damage` (Combat reports one `hit_landed` per target per swing).
- **If the killing blow lands**: its damage counts, once.
- **If a pogo (down attack) hits a foe**: it adds 8 per hit, the lowest fill of any attack. A pogo on a hazard, a breakable or a pane adds nothing (rule 3).
- **If the meter is full and more hits land**: the excess is lost and no cue plays.
- **If the Seeker dies in the same tick it lands a hit**: the meter is zeroed on `revive` regardless, so the fill does not survive.
- **If damage is 0 or negative** (a bad attack entry): it adds nothing (F1's `max(damage, 0)`); the meter never falls from a hit.
- **If `HealingConfig.validate()` finds a value out of range**: the game stops at load and names the value; no heal runs with a bad number.

**Boss and balance**
- **If the player heals during a guard-break stagger** (4.0 s for the boss): allowed, and it costs the punish damage for that 1.0 s. Healing inside a stagger is a choice, not an exploit.
- **If the Seeker dies to the boss and the fight resets**: the meter is 0 on revive (rule 5); the player starts the next attempt with no heal.
- **If a boss stage change happens mid-channel**: the stage change is a boss event and cancels nothing here; a hit that lands as part of it cancels as usual. What a stage change does for the player's heal is an open question.
- **Farming (known loop, accepted for now):** a foe that is rebuilt on room re-entry (rooms and transitions rule 12) can be killed again and again to fill the meter, so a player can top up health between rests. Hollow Knight has the same loop. Level design already keeps every enemy's leash bound away from a rest area (save points rule 3a), so a rest itself is never farmed. Whether to cap it (a diminishing fill on the same room's foes) is an Open Question.

## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Combat | Hard | `hit_landed(target, attack, damage)` once per target per swing, with `damage` as the attack's base damage including the charged x2 and before the guarded, finisher and edge multipliers (F1) | Yes (`combat.md`, In Review) |
| Player controller | Hard | A new `heal` input action; a `CHANNEL` state (or sub-state) that plants the Seeker and ends on the cancels of rule 9; the signals for a landed hit, death and `revive` | Yes (`player-controller.md`) |
| Health, damage and death (R6) | Hard | A heal method on `PlayerHealth` that raises `current` up to `max_health` and **does not** clear invulnerability (`configure()` and `reset()` both do, `player_health.gd`); `take_damage` returning true for a landed hit | No (code: `src/player/player_health.gd`) |
| Collectible upgrades | Soft | The derived max health (F2) read at completion; the pre-edge damage seam below | Yes (`collectible-upgrades.md`, Approved) |
| Enemies | Hard | Foe hurtboxes in the `hittable` group on layer 8 that report `hit_landed`; a dead foe's hurtbox stops reporting | Yes (`enemies.md`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Bosses | Hard | The meter values and F3's estimate of heals per guard-break cycle (about 2 for skilled play, decided in play, not a target) to tune the three stages against; its planned stages say the boss "must be tuned together with" healing |
| HUD (R9) | Hard | `heal_meter`, `meter_capacity`, the ready and not-ready cues and the channel progress |
| Hit feedback and effects (R8) | Soft | The fill pulse, the ready cue and the heal effect |
| Pause and menus | Soft | The `heal` action on the read-only controls page (controls are fixed, `pause-and-menus.md` rule 17), a default binding that avoids its reserved inputs (Escape, Start and gamepad B, rule 19), and its flash limit (registry `flash_limit`, 3 per second) for the heal's light effects |

**Provisional interfaces.** Health (R6), the HUD (R9) and Hit feedback (R8) have no GDD, so every row naming them is provisional until those GDDs exist.

**Seam to resolve (collectible upgrades F3 against Combat).** Collectible upgrades multiplies sword health damage by up to x1.3 "on every sword attack's health damage". If that multiplier is applied before Combat emits `hit_landed`, edge steps would raise the fill by up to 30% and quicken heals with an unrelated upgrade. This GDD says the fill reads the damage before the edge multiplier; Combat or Collectible upgrades must keep the pre-edge value available on the signal (or apply the edge multiplier at the target). Resolve when either is next revised; recorded in Open Questions.

**Bidirectional check (2026-11-22, updated after the first design review):**
- **Bosses** names Healing (its planned-stages section and Open Questions). This matches.
- **Combat, Guard-break, Player controller, Enemies, Collectible upgrades, Save points and Pause and menus** each gained one Healing row in their Dependencies tables on 2026-11-22 (owner go-ahead). Combat's and Collectible upgrades' rows record the edge-multiplier seam; Player controller's records the `heal` action and the `CHANNEL` state, but its Values table and states list are not yet updated (a follow-up for its next revision).
- **Systems index** row 27 lists Combat and Player controller and notes Guard-break and Collectible upgrades as touched; it should add Enemies, Bosses (downstream), HUD and Hit feedback.

## Visual/Audio Requirements

`art-director` lens applied in-session (the heal's cues are what the player reads to play, so Lean mode runs it) against `design/art/art-bible.md` sections 1-4. `audio-director` and `sound-designer` not consulted: Lean mode, and no audio direction or asset exists yet (Audio is index #25, Not Started). Review manually before production.

**Art bible principles that apply.** *Principle 3, Combat owns the light:* the sword arc and the guard-break spark are the brightest events on screen, so no heal effect may out-shine them. *Principle 2, the greyscale order:* the Seeker is the lightest thing in the room, and the heal glow raises the Seeker, never anything around it. *Principle 1, crisp means contact:* effects on the Seeker are pixel art at 4x with nearest filtering. *Section 4, what colour means:* warm and pale is "you" (Bone Pale), steady Kiln Amber is "safe" (the rest pool), cool ice-white is "an enemy attack to dodge", and the four key colours (orange, chalk-yellow, copper-green, violet) belong to the abilities. The heal uses none of the last three.

| Event | Visual | Audio (direction only) | Limits |
|-------|--------|------------------------|--------|
| A hit fills the meter | On the meter only: it brightens at the new fill edge and settles in about 0.15 s. Nothing in the world | None; the hit's own sound carries the moment **[Rec]** | Combat owns the light: no spark or glow in the room for a fill |
| The meter becomes full (ready) | One soft pulse on the Seeker: its pale shade warms a half-step and eases back, as in the rest moment (art bible, Resting), plus the meter's full state | A short, quiet, rising tone | Eased over at least 0.5 s, once per fill; never a flicker. Peak no brighter than Bone Pale (luma 0.64) |
| `heal` refused (not ready, or health full) | The meter dims and shudders for about 0.2 s; no world effect | A dull, short tick | Never red; shown by brightness and motion |
| Channel (1.0 s) | The Seeker plays a planted heal pose; its own warm light grows steadily over `channel_time` and a few crisp pixel motes rise into it | A soft rising swell that follows the channel's progress | **Bone Pale, never Kiln Amber** (steady amber means safe, and the channel is the one vulnerable moment), never cool ice-white, never a key colour. The glow is steady, nothing flickers |
| Completion | One soft bloom on the Seeker as health refills, easing out over about 0.4 s; the HUD health fills | A warm, low swell that settles | Peak no brighter than Bone Pale and never at Flash White (0.93), which belongs to the sword arcs and the guard-break spark |
| Cancelled (release, a hit, a movement press) | The glow drops out in 0.1 s or less, with no flash; a hit's own hurt effect plays over it | A short cut-off | Not a flash: a fall of 10% luminance or more counts toward the flash limit |

**Flash limit.** The pulse, the bloom and the glow count toward registry `flash_limit` (3 per second, WCAG 2.3.1); with Flash reduction On they must read as steady glows. With the atmosphere set to Reduced (parallax rule 14) the heal still reads through the Seeker's pose and the meter, not through bloom.

**Animation.** `seeker_animations.json` has no heal clip today (clips: idle, run, jump, dash, crouch, attack1-3, heavy, hurt, death and others). A new `heal` clip is needed: a planted pose that loops for the channel and an end pose. Frame counts are the animator's. The heavy's charge hold is the nearest existing pose to match for weight.

**HUD colours** (for the HUD GDD): the meter and its full state must not use a key colour or rely on red against green (art bible, UI palette), and the full state needs a shape or brightness cue, not a hue change alone (colourblind rule).

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:healing` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

**Feel reference.** Hollow Knight's Focus: a held, planted commitment that a hit breaks. The difference here is that the meter is kept on a cancel, so a mistake costs time and damage, not the work of earning the meter.

| Target | Value | Why |
|--------|-------|-----|
| Press to `CHANNEL` | the same physics tick (no start-up) | A heal the player has chosen must start when pressed; the wait is the channel, not input lag |
| First visible response | within 1 tick (the pose and the glow start) | The player sees the commitment begin |
| Cancel to control | 0 s: control returns on the cancel tick, with no recovery frames | A heal is a gamble; being stuck for the rest of 1.0 s after a release would turn a choice into a trap |
| Completion to control | 0 s (control on the completion tick) | The heal is the reward; no extra lock after it |
| Refusal cue | within 1 tick of the press | A press that did nothing must be seen to do nothing |
| Ready cue | the tick the meter reaches capacity | The player learns the heal is available without looking away from the fight |

**Weight.** The channel is a planted 1.0 s with no armour: it is meant to be risky, and safe only in a boss's stagger or recovery window (1.0-1.3 s for the boss's patterns; 4.0 s in a stagger). **Hit-stop and screen shake:** a heal adds none. These targets are checked in the owner's playtest, not by an automated test (AC-26); "feels earned" is not a threshold.

## UI Requirements

- **A heal meter in the HUD**, near the health display, showing the fill as a bar (no number shown by default **[Rec]**), a clear full state, and the not-ready cue (Visual/Audio). The full state is a brightness and shape change, not a hue alone.
- **Channel progress** shown on the Seeker (the growing glow and pose), not as a second bar, so the player's eyes stay on the fight.
- **Health display** length follows max health (collectible upgrades), unchanged by this system.
- **The controls page** (Pause and menus, read-only) lists `heal` with its keyboard and gamepad bindings; the default bindings are an open question (Open Questions) because B, Escape and Start are reserved and the common keys are taken.
- The HUD's look waits for the art bible's section 7 (UI/HUD visual direction, still "to be designed") and the HUD GDD (R9).

> **📌 UX Flag — Healing**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This document references | Target | Fact or rule referenced | Used for |
|--------------------------|--------|-------------------------|----------|
| `design/gdd/combat.md` | Combat | `hit_landed(target, attack, damage)`; attack damages 8-30; charged heavy x2; the pogo is the down attack (8) | F1, rules 2, 3 |
| `design/gdd/guard-break.md` | Guard-break | Guarded hits deal x0.25 (boss x0.2); a steady 3-hit combo breaks the guard on the 8th hit (F2); stagger 4.0 s | Rule 2, F3, AC-3, AC-23 |
| `design/gdd/player-controller.md` | Player controller | `take_hit`, hurt lock 0.35 s, invulnerability 1.0 s, GROUND/ATTACK/HURT/DEAD states, `revive`, no dash i-frames, max health 100 | Rules 6, 9, 10, F2, Edge Cases |
| `design/gdd/bosses.md` | Bosses | Planned three stages, "tuned together with healing", pattern recoveries 1.0-1.3 s | Rule 12, F3, Open Questions |
| `design/gdd/enemies.md` | Enemies | `hittable` hurtboxes, hit damage 10-30, no contact damage, rebuilt on room entry | Rule 3, farming edge case |
| `design/gdd/collectible-upgrades.md` | Collectible upgrades | Derived max health 100-180 (F2), health step refills health (rule 9), the edge multiplier (F3) | F2, Edge Cases, Dependencies seam |
| `design/gdd/save-points-and-save-load.md` | Save points | A rest heals to full (rule 4); arrival and Continue start full (rules 8, 11); no enemy near a rest area (rule 3) | Rule 5, farming |
| `design/gdd/world-state.md` | World state | Rule 1: health is not in the record (so the meter is not either) | Rule 5 |
| `design/gdd/pause-and-menus.md` | Pause and menus | Fixed controls (rule 17), reserved inputs (rule 19), registry `flash_limit` | Dependencies, Visual/Audio |
| `design/art/art-bible.md` | Art bible | Principles 1-3, Section 4 colour meanings, the Resting state | Visual/Audio |
| `design/gdd/game-concept.md` | Game concept | Core mechanic 6, anti-pillar 2, the Healing open questions | Overview |

## Acceptance Criteria

The `qa-lead` lens was applied in-session (lean mode spawns no agent). Defaults are the starting values: `meter_capacity` 120, `heal_share` 0.30, `channel_time` 1.0 s, player `max_health` 100. Tags: **[Logic]** automated unit test, **[Integration]** automated integration test with the real nodes, **[UI]** retained screenshot in `production/qa/evidence/`, **[Playtest]** owner playtest. A physics tick is 1/60 s.

**The meter**
- **AC-1 Fill [Logic].** GIVEN the meter is 0, WHEN attack1, attack2 and attack3 land on a foe in turn (damage 10, 12, 20), THEN the meter reads 10, 22 and 42.
- **AC-2 Cap [Logic].** GIVEN the meter is 100, WHEN a charged heavy lands (damage 60), THEN the meter is 120 (not 160); a further hit leaves it at 120.
- **AC-3 Guarded hits fill in full [Integration].** GIVEN the boss is GUARDED and the meter is 0, WHEN attack1 lands, THEN the meter is 10 and the boss's health fell by 2.0 (damage x 0.2): the fill ignores the guard multiplier.
- **AC-4 Only foes feed it [Integration].** GIVEN the meter is 30, WHEN the down attack hits a hazard, a breakable and a pane, and a foe that is already dead, THEN the meter stays 30.
- **AC-5 Killing blow [Integration].** GIVEN a foe has 5 health and the meter is 0, WHEN attack1 (damage 10) kills it, THEN the meter is 10, added once.
- **AC-6 One swing, two foes [Integration].** GIVEN two foes overlap one attack1 swing and the meter is 0, THEN the meter is 20 after the swing.
- **AC-7 Bad damage [Logic].** GIVEN the meter is 50, WHEN a hit reports damage 0 and then -5, THEN the meter stays 50.
- **AC-8 No decay, fills at full health [Integration].** GIVEN health is 100 of 100 and the meter is 60, WHEN 60 s pass with no hit, THEN the meter is 60; WHEN a hit lands, THEN the meter rises.
- **AC-9 Resets [Integration].** GIVEN the meter is 80, THEN a death and `revive`, a Continue and a new game each leave it 0, and a rest at a save point and a room change each leave it 80.

**Starting a heal**
- **AC-10 Not ready [Logic].** GIVEN each of: the meter at 119 (not full), health at max with a full meter, the Seeker in the air, crouched, inside an attack's lock window, in hurt lock, on a ladder, on a wall; WHEN `heal` is pressed, THEN no `CHANNEL` starts, nothing is spent and the refusal cue (`heal_refused`) is emitted. One case per condition. (A press during a door transition or a rest never reaches the heal logic because input is locked; that case is covered by AC-20.)
- **AC-11 Fresh press only [Logic].** GIVEN `heal` was already held when hurt lock ended and the meter is full, THEN no heal starts; WHEN it is released and pressed again, THEN `CHANNEL` starts. A press that failed is not buffered: a press 0.1 s before the meter fills starts nothing.

**The channel**
- **AC-12 Planted [Integration].** GIVEN the Seeker runs at 140 px/s with a full meter and health below max, WHEN `heal` is pressed, THEN its horizontal speed is 0 within 0.1 s (`charge_deceleration` 2000 px/s² stops 140 px/s in about 0.07 s and about 5 px), and from then until the channel ends its position does not change.
- **AC-13 Completion [Logic].** GIVEN the meter is 120 and health 70 of 100, WHEN `heal` is held for 1.0 s, THEN health is 100, the meter is 0 and the Seeker is back in GROUND. With health 50: 80. With max health 180 and health 90: 144.
- **AC-14 Not before time [Logic].** GIVEN a channel started, THEN at 0.95 s the meter is still 120 and health is unchanged; the heal is applied no earlier than 1.0 s and no later than 1.0 s plus one physics tick.
- **AC-15 Released early [Logic].** GIVEN a channel at 0.5 s, WHEN `heal` is released, THEN health is unchanged, the meter is 120 and `IDLE` returns.
- **AC-16 Movement cancels [Integration].** GIVEN a channel at 0.5 s, WHEN jump, dash, grapple (owned) or attack is pressed, THEN the channel ends with the meter kept at 120, health unchanged, and the pressed action starts.
- **AC-17 A hit cancels, no protection [Integration].** GIVEN a channel at 0.5 s and a foe attack of 15 damage, WHEN it lands, THEN health falls by the full 15, the meter stays 120, no heal occurs and the Seeker is in HURT. WHEN instead the hit arrives inside the invulnerability window (`take_hit` false), THEN the channel continues.
- **AC-18 Hit and completion on one tick [Logic].** GIVEN a channel reaching 1.0 s on the same physics tick a hit lands, THEN the hit is resolved first: the channel is cancelled and no heal occurs.
- **AC-19 Death mid-channel [Integration].** GIVEN a channel and a killing hit, THEN the channel is cancelled and, after `revive`, the meter is 0.
- **AC-20 Interact takes over [Integration].** GIVEN a channel in a rest area, WHEN `interact` is pressed, THEN the rest starts, the channel is cancelled and the meter is kept.
- **AC-21 Max health changes mid-channel [Logic].** GIVEN a channel and a health step completes (max 100 to 120, health set to 120), WHEN the channel completes, THEN no heal is applied and the meter is kept at 120.
- **AC-22 Pause [Integration].** GIVEN a channel at 0.6 s, WHEN the game is paused for 5 s and resumed, THEN the heal completes 0.4 s after the resume.

**Balance and config**
- **AC-23 Boss cycle arithmetic [Integration].** GIVEN the default config and a full-guard boss, WHEN the Seeker lands attack1, 2, 3, 1, 2, 3, 1, 2 on it, THEN the guard breaks on the 8th hit with the meter at 106; WHEN attack3 follows in the stagger, THEN the meter is 120 (126 capped) and stays 120 for further hits. This checks the fill and the cap only; how many heals a cycle gives is AC-26.
- **AC-24 Config validation [Logic].** GIVEN `meter_capacity` 0, `heal_share` 0.6 and `channel_time` 3.0, WHEN `HealingConfig.validate()` runs, THEN it returns all three names; the game does not start with them.

**Presentation**
- **AC-25 Meter display [UI].** GIVEN the HUD, THEN a retained screenshot in `production/qa/evidence/` shows the meter at 0, about half and full, and the refusal cue. Blocking: needs the HUD GDD first.
- **AC-26 Heals per cycle and feel [Playtest, deferred].** GIVEN the boss fight is built (the current one-stage boss is enough to start) and the build logs each `heal_meter` full event, each completed heal and each guard-break per attempt, WHEN the owner plays three attempts, THEN the log gives the heals earned and spent per guard-break cycle (F3 estimates about 2 for skilled play), and the owner records whether the heal felt earned, risky and fair. The owner decides from the log and the feel whether `meter_capacity`, `heal_share` or the boss's damage changes; no number is a pass-fail threshold **[Owner, 2026-11-22]**. Stage-specific checks wait for the three stages (`bosses.md`).

**Gaps found by the lens (not blocking):**
- Rule 11 (no fill during a heal) cannot be tested today, since no delayed damage source exists. It is a design note, with no criterion.
- Rule 13 (a stage change neither fills nor empties the meter) cannot be tested until the stages are built; covered by AC-26's playtest.
- The Overview's "a breath won back by pressing the attack" is a feeling, not a threshold: it is a playtest question (AC-26), not a pass-fail criterion.
- AC-9, AC-19 and AC-20 need the save, revive and rest flows to exist in the test scene.

## Open Questions

| # | Question | Owner | Resolve by |
|---|----------|-------|------------|
| 1 | **Default bindings for `heal`.** Keyboard keys free today: R, G, H; the gamepad has no free face button (A jump, X attack, Y rapid fire, B interact and reserved for `cancel`, bumpers dash and grapple, triggers bow and cast). Suggested: keyboard R, gamepad right stick click (R3). Needs an owner pick. | Owner | Before the controller story |
| 2 | **What a boss stage change does for the heal** (a refill, a cue, nothing): rule 13 says it does not touch the meter; the three-stage design (`bosses.md`) may want otherwise. | Owner | When the boss stages are built |
| 3 | **Farming.** A rebuilt foe is a heal source (Edge Cases). Accepted for now; a diminishing fill for repeat kills in one room is the option if playtests show abuse. | Owner | After the first playtest of the heal |
| 4 | **Pre-edge damage on `hit_landed`** (Dependencies seam): Combat or Collectible upgrades must keep the pre-edge value available. | `/design-review` of Combat and Collectible upgrades | Next revision of either |
| 5 | **Heal in the air** is not allowed (rule 6, a recommendation). Whether a planted ground-only heal is right for the movement-first pillar is a playtest question. | Owner | First playtest |
| 6 | **Meter upgrades.** Whether a collectible raises capacity or heal share, or a second bar is added later. Not part of Collectible upgrades today (four kinds: health, edge, guard, magic). | Owner | Alpha |
| 7 | **Channel time against the boss's recoveries** (1.0 s against 1.0-1.3 s): tuned in play. | Owner, with the boss stages | Boss tuning round |
| 8 | **A heal clip and audio** do not exist; the Seeker needs a `heal` clip and the heal's sounds need a sound designer (Audio GDD not started). | Art and Audio | Before the heal is built |
| 9 | **Numeric display** of the meter (rule: none by default). The HUD GDD decides. | HUD (R9) | HUD design |
| 10 | **Heals per guard-break cycle.** F3 estimates about 2 for skilled play (one spent in the 4.0 s stagger, one banked) from an estimated fill rate. Whether that is fair, and whether `meter_capacity`, `heal_share` or the boss's damage should move, is decided in play (AC-26). | Owner | First boss playtest with the meter logged |
| 11 | **Safe heal window against the boss.** The gap between one boss strike and the next is at least 2.4 s (recovery 1.0 + `attack_cooldown` 0.6 + shortest wind-up 0.8), longer than the 1.0-1.3 s recovery the `channel_time` range note cites; stages 2 and 3 shorten it. Whether a heal is meant to be this safe at range is a playtest question. | Owner, with the boss stages | Boss tuning round |
