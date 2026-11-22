# Healing (hit-fed heal meter)

> **Status**: Designed 2026-11-22 (`/design-system`, lean, standard, guided, balanced density). First `/design-review` (lean): NEEDS REVISION, 4 blockers, revised. Second `/design-review` (full): NEEDS REVISION, 7 blockers, revised 2026-11-22; awaiting a re-review in a fresh session
> **Author**: owner + Claude
> **Last Updated**: 2026-11-22
> **Last Verified**: 2026-11-22
> **Implements Pillar**: P1 Movement Is the Mastery (with a tension kept on purpose: the heal channel is planted, see Overview). Anti-pillar 2 (no consumables) shapes the meter. Not P4: a heal meter is not an ability that opens a route.

## Summary

Healing is the Seeker's way to win health back mid-fight: every hit lands into a single heal meter, and a full meter can be spent on a 1.0 s planted channel that restores 30% of max health. A hit cancels the channel but keeps the meter, so the risk is time and damage, never the work of earning it; letting go of the heal on purpose costs a short recovery. It exists because recovery should be earned by fighting well (pillar 1, anti-pillar 2: no consumables), and because the three-stage boss needs a player who can recover between stages.

> **Quick reference** — Layer: `Gameplay` · Priority: `MVP` · Key deps: `Combat, Player controller, Health (code); touches Guard-break, Collectible upgrades, Bosses, HUD`
> Engine feasibility: no engine reference for `Scripting` under `docs/engine-reference/godot/modules/`; feasibility not checked against the pinned engine (rule-only logic, no post-cutoff API expected).

## Overview

Healing lets the Seeker recover health in the middle of a fight, and it is earned by fighting. Every hit the Seeker lands fills a **heal meter**; once the meter is full enough the Seeker can spend it to restore health, as Hollow Knight's Focus does (owner, 2026-11-22). The player pays for a heal with good play (landing hits) and with the moment it takes to heal, never with an item, a currency or a trip to a save point. It is a system the player operates directly: they watch the meter fill, choose a safe moment and commit to the heal. The feeling to aim for is a breath won back by pressing the attack, and a gamble when the heal is started in a bad spot **[Rec]**. The gamble is real only if planting for a full second can be punished, so it rests on three things: a hit that lands breaks the channel and loses the second already spent, letting go of the heal on purpose costs a short recovery (rule 9), and the boss's patterns are expected to punish a planted Seeker (Open Question 12, owed to Bosses). Escaping by a jump, dash or grapple press stays free of that recovery so the movement pillar's escape always works. Without it, health is a one-way budget until the next rest, and a long boss fight punishes a single early mistake for the whole fight.

**Design intent**
- **Owner, 2026-11-22:** a meter filled by landing hits; the Seeker can heal when it is full, as in Hollow Knight. The exact rules (meter size, gain per hit, heal amount, channel time and the risk while healing, whether hits on a guarded foe count, whether it fills in a boss fight, whether it empties on death) were undecided and are settled in Detailed Design below.
- **Owner, 2026-11-22 (first boss playtest):** the boss was beaten and found "super easy"; the owner wants a three-stage boss with no health bar and a heal meter, and the boss is to be tuned together with healing (`bosses.md`, "Planned: three stages").
- **From the concept (anti-pillar 2):** no loot grind or crafting, so a heal is never a consumable, a purchase or a drop. A meter filled by combat fits that.
- **[Rec]** Pillar 1 (Movement Is the Mastery): recovery is earned by fighting, not by retreating to a save point, which fits the pillar. **A tension kept on purpose:** the meter is fed by any hit (a pogo fills 8, a charged heavy 60), so it does not reward moving through the fight, and the heal itself is a planted second, the opposite of flowing momentum. The planted channel is what makes a heal a decision; the pillar's answer is that every cancel by movement is free (rule 9), so movement is always the way out.

**Scope**: in: the heal meter (capacity, how it fills, whether it keeps or empties), the heal action (input, channel, cost, interruption), how it restores health, and the rules for foes and bosses. Out: the health pool, damage and death (R6, code in `player_health.gd`), the meter and health display (HUD, R9), the heal effect and sound (Hit feedback, R8), the max-health upgrades (Collectible upgrades), and the boss's stage tuning (Bosses).

## Detailed Design

### Core Rules

Tags: **[Owner]** = the owner's stated rule; **[Rec]** = recommendation, change freely; **[Code]** = how the code works today. `game-designer`, `systems-designer` and `gameplay-programmer` not consulted for this section: Lean mode. Review manually before production. Values named in `code font` are data, set in Formulas.

**The meter**

1. **One bar.** The heal meter is one number, `heal_meter`, from 0 to `meter_capacity`. It is a single bar, not segments: one full bar is one heal. **[Owner, 2026-11-22: a bar, a heal spends it all]**
2. **What fills it.** Every hit the Seeker lands on a foe adds `damage` to the meter (the meter is counted in damage units, so `meter_capacity` is the one number that sets how many hits a heal takes), where `damage` is the value Combat reports in `hit_landed` for that hit (the attack's base damage, with the charged heavy's x2 already in it, before the guarded, finisher and edge multipliers). A hit on a guarded foe or boss fills as much as any other: the guard multiplier does not reduce it. The killing blow counts. **[Owner, 2026-11-22: each hit fills by its attack's base damage; Rec: the charged heavy fills double]**
3. **Only foes feed it.** A hit counts only on a foe's hurtbox. `hit_landed` carries only the `Area2D` and fires for anything in the `hittable` group (the `TrainingDummy` and `HitTarget` test nodes included), so a foe is marked explicitly: the hurtboxes of `EnemyBase` (bosses included) and of the `TrainingDummy` join a new group `foe`, and `HitTarget` does not. The player's `hit_landed` handler fills the meter only when the target is in `foe` (Dependencies). A hit on anything else, such as a pogo on a hazard, a breakable or a pane, adds nothing. A dead foe's hurtbox leaves `hittable` when it dies (enemies rule 7), so it reports nothing. The training dummy feeds the meter on purpose, so the meter can be tried in the test room. **[Rec]**
4. **The meter caps and keeps.** The meter never exceeds `meter_capacity`; the excess of a hit that crosses the cap is lost. It does not decay with time, and it keeps filling while health is full, so a player can arrive at a fight with a heal ready. **[Rec]**
5. **Resets.** The meter is 0 at a new game, after a Continue and after a death (the `revive` call). A rest at a save point and a room change leave it as it is. It is not saved: like health, it is not in the world-state record (world state rule 1). **[Owner, 2026-11-22: starts empty after a death, a Continue or a new game; a rest leaves it]**

**The heal**

6. **Input.** A new action, `heal`, held to heal (or toggled, rule 14). It starts a heal only when all of these hold on the press: the meter is at `meter_capacity`; **missing health (max health minus health) is at least `start_deficit`**, which is `start_deficit_share` x the heal amount (F2), 15 at the defaults; and the Seeker's state is `GROUND` (the controller states `ATTACK`, `CROUCH`, `HURT` and `DEAD` are separate states, so "on the ground, not attacking, not crouching, not in hurt lock and not dead" is exactly `state == GROUND`). The meter is still spent whole when the heal completes (rule 8), so `start_deficit` only stops a whole bar being burned for a few points of health. If the press fails, nothing starts and the player gets a refusal cue by reason (UI Requirements). **[Rec: ground only, so a heal is a planted commitment and pillar 1's movement is not blocked mid-air; Owner, 2026-11-22: one bar spent whole, kept]**
7. **The channel.** A started heal is a channel of `channel_time` (1.0 s), run as the new top-level controller state `Player.State.HEAL` (this document's `CHANNEL`, Dependencies). The Seeker is planted: it skids to a stop on a `heal_deceleration` of its own (data, defaults to the charge skid's 2000 px/s², so Healing does not read the combat config) and cannot attack, jump, dash or grapple except to cancel (rule 9). If it slides off an edge during the skid, the channel is cancelled as an involuntary cancel (rule 9). The timer accumulates the `delta` of the Seeker's own `_physics_process` (it is pausable and game-time: a pause freezes it, hit-stop stretches it); no scene-tree timer and no real-time clock may drive it, because those keep running while paused. The glow and pose read `timer / channel_time`, not a separate tween. **[Owner, 2026-11-22: 1.0 s channel, planted]**
8. **Completion.** When the channel timer reaches `channel_time` (tested as `timer >= channel_time - 0.0001`, so it completes on physics tick 60 and never before it) with the heal still held (in toggle mode: not cancelled) **and health below max health**, the meter is spent in full (set to 0) and health rises by the heal amount (Formulas F2), never above max health. If health is already at max health at that moment (a health step refilled it mid-channel, Edge Cases), nothing is spent and nothing is healed: the meter is kept. Nothing is spent before that moment. The completion step runs after every foe has acted on that tick (rule 15), and re-tests that the state is still `HEAL`. **[Owner, 2026-11-22: the meter is spent only when the channel completes]**
9. **Cancelling.** The channel ends with nothing spent and no heal, the meter kept in every case, and the time already channelled is lost (no partial heal, no progress kept). There are two kinds.
    - **Involuntary** (no recovery; control goes where the event sends it): the Seeker takes a hit that lands (a hit in the invulnerability window does not land, so it does not cancel) and goes to HURT or DEAD; the Seeker dies; a door, an exit or a rest takes over (`interact` with a door or rest area overlapped); the Seeker slides off an edge (rule 7) and goes to AIR.
    - **Voluntary, by a movement or attack press** (free: no recovery, so the movement pillar's escape always works): the Seeker presses jump, dash, grapple (once owned) or attack. The channel ends on that tick and the pressed action starts on the same tick, as if the Seeker had been in GROUND.
    - **Voluntary, by letting go** (costs `cancel_recovery`, 0.25 s): the heal input is released (hold mode) or pressed a second time (toggle mode, rule 14). The Seeker stays planted for `cancel_recovery` with control withheld, no protection and no armour, and any hit that lands in it goes to HURT as usual. This is the price of changing your mind in place. A release on the very tick the timer completes does not cancel: the heal completes (rule 8).
    - **Everything else is ignored and not buffered:** crouch, `interact` with no door or rest area, bow, cast, rapid fire, map, a second `heal` press in hold mode, movement input. The controller's jump buffer is cleared on every exit from the channel, so a press made during it never fires afterwards.
    **[Owner, 2026-11-22: a hit cancels, meter kept; Rec: the movement presses cancel so the player is never stuck for 1.0 s; Rec, second design review: letting go costs a recovery so the commitment is real]**
10. **No protection.** The channel gives no invulnerability, no damage reduction and no armour. A hit that lands cancels it and deals its full damage, and starts the controller's hurt lock and invulnerability as any hit does. **[Rec: the risk is the point; the hit cancels so it cannot be tanked through]**
11. **Fills do not happen during a heal.** The Seeker cannot attack while channelling, so nothing fills the meter then. A hit landed by a delayed source (none exist today) would still count. **[Rec]**

**Boss fights**

12. **The meter fills in a boss fight like anywhere else** (rule 2). A boss fight is where it matters most, so the boss's stages are tuned with the heal in mind. The starting values are **not** tuned to a heals-per-cycle target. Formulas F3 bounds what a skilled player can earn per guard-break cycle (1 heal spent in the stagger; up to about 2 when a banked heal is also spent in the guard phase; about 1.7 on the charged-heavy break path), and whether that is fair is **decided in play** from a log of HP healed against boss damage taken per cycle (AC-26); the boss's damage is tuned against what the playtests show. **The windows a heal fits in:** the gap between one boss strike and the next is at least 2.4 s (lunge 2.4 s, shockwave 2.6 s, slam 3.3 s, each recovery plus `attack_cooldown` 0.6 s plus the next wind-up; 1.0 s more after a stagger), so a 1.0 s channel started right after a strike fits every gap, and that safety is the boss's to take away (Open Question 12). **In a stagger (4.0 s)** a heal costs 1.0 s of punish damage on the boss's health, but the planned stages end on a guard-break count (`bosses.md`), so until the last stage that damage is not what progress needs, and a heal in a stagger is nearly free. **[Owner, 2026-11-22: tune the boss together with healing; the numbers cannot say whether it feels balanced or fair, so some of these values are determined by play]**
13. **A stage change neither fills nor empties the meter.** What the stage transition does to the player's heal is not decided here; see Open Questions.
14. **Input options: press buffer and hold or toggle.** *Press buffer:* a `heal` press that fails only because the Seeker is in `ATTACK`, `HURT`, `AIR` or landing (a state that ends on its own) is remembered for `press_buffer` (0.12 s). If every start condition of rule 6 holds within that window and the input is still held, the heal starts on that tick. A press that fails on the meter or the health (rule 6) is never buffered, so a press just before the meter fills starts nothing. *Hold or toggle:* an accessibility option `heal_mode` in the options (Pause and menus owns the page, Open Question 14): in `hold` mode (default) the channel needs the input held and releasing cancels (rule 9); in `toggle` mode a press starts the channel, it runs without being held, and a second press cancels it as a release does. Every other cancel and the completion are the same in both modes. **[Rec, second design review]**
15. **Order within a physics tick.** The foes act first, then the Seeker: the Seeker's physics priority is later than every `EnemyBase` and boss, so a foe's `take_hit` on that tick has already landed (or been refused) when the Seeker's heal logic runs. The heal logic then runs in this order: (a) a landed hit this tick has already cancelled the channel (rule 9), so a channel found in `HEAL` has not been hit; (b) a cancel press or release is applied, except that a release on the completion tick does not cancel (rule 9); (c) the timer advances by `delta`; (d) completion is tested (rule 8). The result: a hit on the tick the timer would complete wins and no heal happens. If the priority change is not wanted for other reasons, the same result needs the completion step to re-test that the state is still `HEAL` after the foes have run. **[Rec, second design review]**

### States and Transitions

The meter has no states of its own: it is a number, and "full" means `heal_meter >= meter_capacity`. The heal action has these phases. The controller implements them as one new top-level state, `Player.State.HEAL`, appended to the `Player.State` enum with its own `_state_heal` (the existing `GROUND` handler polls grapple, dash, interact, combat, climb, the jump buffer and crouch before it moves, so a sub-state of `GROUND` would need a guard on every one of them). `CHANNEL` and `RECOVER` below are the two phases inside `HEAL`; `IDLE` means the Seeker is not in `HEAL`. All cleanup (timer reset, effects off, jump buffer cleared) runs in `_set_state` on any exit from `HEAL`. (Dependencies)

| Phase | Meaning | Enters when | Leaves when |
|-------|---------|-------------|-------------|
| `IDLE` | No heal in progress (the Seeker is not in `HEAL`) | Start of play; a heal completes or is cancelled | The heal input is pressed (or a buffered press, rule 14) and rule 6 holds: to `CHANNEL` |
| `CHANNEL` | Planted, timer running from 0 to `channel_time` | Rule 6 holds on a press | The timer reaches `channel_time` with the heal held: to `IDLE` after the heal and the spend, or with nothing spent when health is already at max (rule 8). A movement or attack press: to `IDLE` and the pressed action starts. Letting go: to `RECOVER`. A hit, death, door or rest, or a slide off an edge: to `IDLE` and the event's state (rule 9) |
| `RECOVER` | Planted, control withheld, timer running from 0 to `cancel_recovery`; no protection | The heal input is released or pressed a second time during `CHANNEL` (rule 9) | The timer reaches `cancel_recovery`: to `IDLE`. A hit that lands: to `IDLE` and HURT or DEAD |

Meter and health outcomes of the exits:

| Exit | Meter | Health | Player state after |
|------|-------|--------|--------------------|
| Completes (health below max) | 0 | + heal amount (capped) | GROUND, control returns the same tick |
| Completes with health already at max | kept | unchanged | GROUND, control returns the same tick |
| Letting go (release, or second press in toggle mode) | kept | unchanged | `RECOVER` for `cancel_recovery` (0.25 s), then GROUND |
| Jump, dash, grapple or attack pressed | kept | unchanged | the pressed action starts the same tick, no recovery |
| A hit lands (in `CHANNEL` or `RECOVER`) | kept | - the hit's damage | HURT (or DEAD) |
| Slide off an edge | kept | unchanged | AIR |
| Door or rest takes over | kept | unchanged | ENTER_DOOR or the rest |
| Death | 0 on revive | 0 | DEAD |

### Interactions with Other Systems

Of these, only Combat, Guard-break, Player controller, Bosses, Enemies and Collectible upgrades have GDDs; Health, damage and death (R6), Hit feedback (R8) and the HUD (R9) have code or nothing, and each interface to them is **provisional** until its owner is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Combat | In | `hit_landed(target, attack, damage)`: `damage` feeds rule 2 when the target is in group `foe` (rule 3). Combat's charged x2 is inside it | Combat owns the signal; this system owns what a hit adds to the meter |
| Guard-break | None directly | Healing reads no guard state: a guarded hit fills at full (rule 2). A guard-break stagger is simply a window in which the player can heal or punish | Guard-break; this system owns the fill |
| Player controller | Both | In: the `heal` input (and the `heal_mode` option), the state, the landed-hit, death and `revive` signals. Out: the `HEAL` state that plants the Seeker, the cancel rules, the jump-buffer clear on exit and the later physics priority (rule 15) | Controller owns states and input; this system owns when a heal may start, run and end |
| Health, damage and death | Out | The heal amount, applied to `PlayerHealth.current` without touching invulnerability (a new `heal` method and a `healed` signal, Dependencies) | Health owns the values; this system owns the amount and when it applies |
| Collectible upgrades | In | Max health (derived, 100 to 180): the heal amount is a share of it (F2) so it keeps its meaning as max health grows | Collectible upgrades owns max health; this system owns the heal share |
| Enemies, Bosses | In | Every foe hit, via `hit_landed`; the `foe` group on their hurtboxes (rule 3). Bosses are tuned against the log of HP healed and boss damage taken per cycle (F3, AC-26) and are expected to punish a planted Seeker (Open Question 12) | Bosses owns the boss's tuning; this system owns the heal values |
| Save points | None | A rest leaves the meter alone (rule 5) while it heals health to full | Save points |
| Pause and menus | Out | The `heal_mode` option (hold or toggle), the `heal` row on the controls page | Pause and menus owns the options page; provisional until Open Question 14 |
| HUD | Out | `heal_meter`, `meter_capacity`, the refusal and ready cues, the channel progress | HUD (R9) owns the display; provisional |
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
| heal_share | float | 0.20-0.40, starts at 0.30 | data file | The share of max health one heal restores. Below 0.20 a heal is too small to be worth a planted second; above 0.40 on 180 max health it is more than two slams and the health pool stops mattering |

**Output Range:** the amount restored is `heal_share x max_health`: 30 at 100 max health, 54 at 180 (at the starting share), 20 to 72 across the share's range and the max health range; the cap makes the effective gain smaller near full health. The heal is 30 HP of a 40-damage slam at the start, 54 HP at full upgrades: its worth in boss hits grows by 1.8 times while the meter cost stays the same, which Open Question 6 asks the owner to watch.
**Example:** health 70 of 100: `min(70 + 30, 100)` = 100. Health 80 of 100: capped at 100, 10 of the 30 is unused (the meter is spent in full, rule 8). At 180 max and health 90: `min(90 + 54, 180)` = 144.

### F3. Hits per heal and the boss-cycle check

This is a tuning check, not a runtime calculation. The hits_per_heal, cycle_fill and heal_ratio formulas are defined as:

`hits_per_heal = meter_capacity / mean_hit_damage`
`meter_at_stagger = min(carry_in + guard_fill, meter_capacity)`: the meter the instant the guard breaks. Anything above `meter_capacity` is lost, so a meter carried in full wastes the whole guard phase's fill
`cycle_fill = guard_fill + fill_rate x (stagger_time - channel_time)`: the fill a cycle can bank when a heal is spent inside the stagger (nothing fills during a channel)
`cycle_heals_max = cycle_fill / meter_capacity`: an **upper bound**, reached only when the heal carried in is spent in the guard phase (it needs a safe 1.0 s there) so the meter has room to fill. A player who spends only the stagger heal gets 1 per cycle
`heal_ratio = hp_healed_per_cycle / boss_damage_taken_per_cycle`: **logged, never a target** (AC-26). Above 1, a player who takes the cycle's damage still gains health

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| meter_capacity | float | 40-300, starts at 120 | data file | As in F1 |
| mean_hit_damage | float | 8-60 | calculated | The average damage of the hits the player uses; 14 for light combos (10, 12, 20 repeating: mean 14), 30 for uncharged heavies |
| carry_in | float | 0 to `meter_capacity` | calculated | The meter at the start of the guard phase. The meter keeps across fights (rule 4), so in steady play it starts at 0 (the carried heal was spent) or full (it was not) |
| guard_fill | float | 60-106 | calculated | Damage of the hits from a full guard to the breaking hit. **Two paths:** 106 for steady light combos (`guard-break.md` F2: 8 hits), and 60 for a charged heavy, which breaks the guard in one hit (30 x 2) and is the path the first boss playtest used |
| fill_rate | float | 0 upward | estimated | Fill per second while landing combos. About 49 for light combos: a 3-hit combo (42) takes about 0.86 s, from the clip durations in `seeker_animations.json` (attack1 chains at frame 5, about 0.18 s; attack2 at frame 4, about 0.16 s; attack3 plays out 0.52 s). **An estimate to be measured**, not a tested figure; the charged heavy's fill rate (0.55 s of hold plus the swing) is not estimated at all |
| stagger_time | float | 2.5 s default, 4.0 s boss | data file (`guard_config.tres`) | The window in which every hit lands at full damage. Hits do not extend it (`guard-break.md` rule 3) |
| cycle_fill | float | 0 upward | calculated | Fill a cycle can bank: the guard phase plus the stagger minus the channel |
| cycle_heals_max | float | 0 upward | calculated | The upper bound above. **Not a target**: see Core Rules 12 and AC-26 |
| heal_ratio | float | 0 upward | measured | HP actually healed (after the cap) per guard-break cycle, divided by the boss damage the Seeker took in it. The number the owner reads in the playtest log |

**Output Range:** `hits_per_heal` is 2 (two charged heavies) to 15 (pogo hits at 8) at the defaults, and 0.67 to 37.5 across the whole capacity and damage ranges. `cycle_heals_max` has no target band, and neither has `heal_ratio`: they are numbers the playtests read (AC-26), not pass-fail checks **[Owner, 2026-11-22: determined by play]**.

**Example 1, boss, light-combo break, estimate.** The guard breaks on the 8th hit (attack1, 2, 3, 1, 2, 3, 1, 2), `guard_fill` = 106. Stagger 4.0 s.
- *Banked heal not spent (carry_in 120):* the meter is already full, the whole 106 is lost, the player heals at once in the stagger and refills (3.0 s x 49 = about 147, capped at 120): **1 heal per cycle**, a full meter carried on.
- *Banked heal spent in the guard phase (carry_in 0):* the meter is 106 at the break and full 0.3 s into the stagger (14 more at 49 per second). The player heals 1.0 s, then refills in the remaining 2.7 s (about 132, capped at 120). `cycle_fill` = 106 + 3.0 x 49 = about 253, `cycle_heals_max` about 2.1: **2 heals per cycle** (one in the guard phase, one in the stagger) with a full meter carried on.
- *HP:* two heals are 60 HP at 100 max and 108 at 180 max (the cap on the deficit applies). The boss's slam is 40, its lunge 25, its shockwave 20, so a player who takes one slam a cycle has `heal_ratio` about 1.5 on this path. Whether that is too generous for a boss the owner found "super easy" is the playtest's question (Open Question 10).

**Example 2, boss, charged-heavy break, estimate.** One charged heavy breaks the guard: `guard_fill` = 60 (the heavy needs 0.55 s of hold first). The meter is 60 at the break and full 1.2 s into the stagger (60 more at 49 per second). The player heals from 1.2 s to 2.2 s, then fills for the remaining 1.8 s: about 88, which is 0.73 of a heal, carried on. `cycle_fill` = 60 + 3.0 x 49 = 207, `cycle_heals_max` about 1.7: **1 heal in the stagger and 0.7 carried**. A player who does not heal in this stagger fills the meter full by 1.2 s and loses the other 2.8 s of fill (about 137). The route the owner found easiest to break the guard gives the smaller meter, and the first playtest's boss was beaten by it.

### Values (`HealingConfig`)

| Value | Starts at | Range | Used by |
|-------|----------:|-------|---------|
| `meter_capacity` | 120 | 40-300 | F1, F3 |
| `heal_share` | 0.30 | 0.20-0.40 | F2. Narrowed from 0.10-0.50 in the second design review: at 0.10 a heal is 10 HP, a quarter of one slam, for 120 damage of fill; at 0.50 on 180 max health it is 90 HP, 2.25 slams |
| `channel_time` | 1.0 s | 0.5-2.0 s | Core Rules 7, 8. Below 0.5 s a heal can be squeezed into any gap and is never punished. At 1.0 s a heal started right after a strike fits every gap between boss strikes (lunge 2.4 s, shockwave 2.6 s, slam 3.3 s, Core Rules 12). Above about 2.0 s it no longer fits the shortest gap (lunge 2.4 s) once the Seeker has read the next wind-up, so a heal is only safe in a stagger. If playtests find the heal too safe, raise it toward 1.5 s before changing the boss (Open Question 7) |
| `cancel_recovery` | 0.25 s | 0-0.5 s | Core Rules 9. The planted recovery after letting go of the heal. At 0 a heal can be started and dropped for free; above 0.5 s a change of mind costs more than a hit's hurt lock (0.35 s) |
| `start_deficit_share` | 0.5 | 0-1.0 | Core Rules 6. `start_deficit` = this x the heal amount: 15 at the defaults. At 0 a heal can start at 1 HP missing and spend the whole bar for it; at 1.0 it only starts when a whole heal fits |
| `press_buffer` | 0.12 s | 0-0.2 s | Core Rules 14. The same as the controller's jump buffer (0.12 s). At 0 a press that lands a frame early is lost; above 0.2 s a press can start a heal the player no longer wants |
| `heal_deceleration` | 2000 px/s2 | 500-3000 | Core Rules 7. The planted skid; the same as the charge skid (`charge_deceleration`) so it feels like it |

`HealingConfig.validate()` returns a `PackedStringArray` with the name of every value outside its range. It runs when the Player is configured; a non-empty result is reported with `push_error` naming the values and each value is clamped into its range, so a data typo never closes the game **[Rec, second design review; the Save points GDD specifies a `validate()` for its config too, but neither exists in the code yet]**. `@export_range` on each value gives the editor the same limits.

**Feedback loops:** one positive loop, intended: a heal keeps the player alive longer, so they land more hits and earn more heals. It is damped three ways: the cap (at most one heal per `meter_capacity` of damage), the planted channel (a hit breaks it, so a heal needs a gap), and the heal share (30% of max, so a player needs to keep fighting well to stay ahead of a boss's 40-damage slam). It is **not** damped by the channel's risk alone, since a heal started after a strike fits every gap (Core Rules 12), and it is not damped against farming: see Edge Cases. **Seam:** collectible upgrades F3 raises sword health damage by up to x1.3; this system reads the damage **before** that multiplier, so edge steps do not make heals faster (Dependencies).

## Edge Cases

`systems-designer` not consulted for this section: Lean mode (the second review's full-mode specialists then checked it). Every case below is a **[Rec]** unless tagged otherwise, and the system is not built, so none is "handled in the code".

**Starting and ending a heal**
- **If `heal` is pressed with the meter full and health full**: nothing starts, nothing is spent, and the health refusal cue plays (missing health is below `start_deficit`). The meter stays full for the next fight.
- **If `heal` is pressed with the meter below capacity**: nothing starts and the meter-not-full refusal cue plays. A press that fails on the meter or the health is never buffered: a press 0.1 s before the meter fills does not start a heal later.
- **If `heal` is pressed with missing health below `start_deficit`** (15 at the defaults, so health 86 to 100 of 100): nothing starts, nothing is spent and the health refusal cue plays. A heal at 85 of 100 or lower starts.
- **If `heal` is pressed while the Seeker is in `ATTACK`, `HURT` or `AIR`, or landing** (a state that ends within `press_buffer`, 0.12 s): the press is remembered for `press_buffer`; if every condition of rule 6 holds in that window and the input is still held, the heal starts on that tick (rule 14). A press that is released before the state ends starts nothing.
- **If `heal` was already held for longer than `press_buffer` when the conditions began to hold** (for example held through an attack or the end of hurt lock): it does not start a heal. The player must release and press again, so holding the button through a fight never starts a 1.0 s plant by accident.
- **If `heal` is pressed crouched, on a ladder, grappling, on a wall, dashing, on a ledge or dead**: nothing starts (rule 6: the state is not `GROUND`), nothing is buffered and no cue plays in a state where the reason is already visible (movement-state refusals are silent, UI Requirements).
- **If `heal` is pressed during a door transition or a rest**: the controller has locked input (`save-points-and-save-load.md`, Resting), so the press never reaches the heal logic: nothing starts and **no cue plays**.
- **If the Seeker is inside its invulnerability window (after a landed hit) and hurt lock is over**: a heal may start. The 1.0 s window leaves 0.65 s of protection after the 0.35 s hurt lock, so the first 0.65 s of such a channel is safe; this is accepted for now and is part of what Open Question 10's playtest reads, not a bug.
- **If `interact` is pressed in a door or rest area while channelling**: the door or rest takes over and the channel is cancelled with the meter kept (rule 9). Movement cannot carry the Seeker through an exit during a channel because the Seeker is planted.

**During the channel**
- **If a hit lands on the same physics tick the timer reaches `channel_time`**: the hit is resolved first, the channel is cancelled and no heal happens. The mechanism is rule 15 (the Seeker runs after every foe on a tick, and the completion step re-tests the state), so tests are deterministic and do not depend on scene-tree order.
- **If `heal` is released on the same tick the timer reaches `channel_time`**: the heal completes (rule 9).
- **If the Seeker lets go of the heal (release, or a second press in toggle mode)**: it is planted for `cancel_recovery` (0.25 s), the meter is kept, a hit in that time lands as usual, and a heal cannot start again until the recovery ends.
- **If a jump, dash, grapple or attack is pressed during `CHANNEL`**: the channel ends, the action starts on the same tick with no recovery, and the controller's jump buffer is cleared so the press does not fire a second time after the action ends.
- **If the Seeker slides off an edge during the planting skid**: the channel is cancelled (involuntary, no recovery) and the Seeker is in AIR.
- **If a hit arrives in the invulnerability window** (`take_hit` returns false): the channel is not cancelled, since no damage was dealt (rule 9).
- **If max health changes during the channel** (a collectible upgrade completes a health step, which also sets health to the new max): F2 reads max health at completion, so the heal uses the new value.
- **If health is already at max when the channel completes** (a health step refilled it mid-channel): the heal is not applied and the meter is **kept**; nothing is wasted. The channel ends without a cue of success.
- **If the Seeker dies during the channel**: the channel is cancelled, the meter is zeroed on `revive` (rule 5).
- **If the game is paused or the time scale drops** (pause stops the pausable Seeker; hit-stop and slow-motion lower the physics ticks per real second): the channel timer accumulates the physics `delta` (rule 7), so a pause freezes it and hit-stop stretches it; it neither completes nor cancels while paused. Hit-stop today fires only on a foe's death (`enemy_base.gd`), so this matters little; tests drive `delta` directly and never touch `Engine.time_scale`.
- **If a foe the Seeker cannot see lands a hit**: it cancels like any hit; there is no "safe" cancel.
- **If `heal_mode` is `toggle`**: a press starts the channel and it runs without the input held; a second press is a release (rule 9). A press of the heal input after `RECOVER` ends needs a new press.

**Filling**
- **If one swing hits two foes**: each foe's hit adds its own `damage` (Combat reports one `hit_landed` per target per swing).
- **If the killing blow lands**: its damage counts, once.
- **If a pogo (down attack) hits a foe**: it adds 8 per hit, the lowest fill of any attack. A pogo on a hazard, a breakable or a pane adds nothing (rule 3).
- **If the meter is full and more hits land**: the excess is lost and no cue plays.
- **If the Seeker dies in the same tick it lands a hit**: the meter is zeroed on `revive` regardless, so the fill does not survive.
- **If damage is 0 or negative** (a bad attack entry): it adds nothing (F1's `max(damage, 0)`); the meter never falls from a hit.
- **If `HealingConfig.validate()` finds a value out of range**: it is reported with `push_error` naming the value and clamped into its range; no heal runs with a bad number and the game keeps running.

**Boss and balance**
- **If the player heals during a guard-break stagger** (4.0 s for the boss): allowed, and it costs 1.0 s of punish damage on the boss's health. Because the planned stages end on a guard-break count, not on the boss's health, that damage is not what progress needs until the last stage, so the cost is close to nothing (Core Rules 12). Healing inside a stagger is a choice, not an exploit; whether it is too cheap is what the heal-ratio log reads (F3, AC-26).
- **If the Seeker dies to the boss and the fight resets**: the meter is 0 on revive (rule 5); the player starts the next attempt with no heal.
- **If a boss stage change happens mid-channel**: the stage change is a boss event and cancels nothing here; a hit that lands as part of it cancels as usual. What a stage change does for the player's heal is an open question.
- **Farming (known loop, accepted for now):** a foe that is rebuilt on room re-entry (rooms and transitions rule 12) can be killed again and again to fill the meter, so a player can top up health between rests. Hollow Knight has the same loop. Level design already keeps every enemy's leash bound away from a rest area (save points rule 3a), so a rest itself is never farmed. Whether to cap it (a diminishing fill on the same room's foes) is an Open Question.

## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Combat | Hard | `hit_landed(target, attack, damage)` once per target per swing, with `damage` as the attack's base damage including the charged x2 and before the guarded, finisher and edge multipliers (F1) | Yes (`combat.md`, In Review) |
| Player controller | Hard | A new `heal` input action (added to `PlayerInputBindings.BINDINGS`; `register()` skips an action that already exists, so the code is the one place the default lives and `project.godot` must not also define it); a new top-level `Player.State.HEAL` with its own `_state_heal` (rule 7), cleanup in `_set_state`, the jump-buffer clear on exit and a physics priority later than the foes (rule 15); the signals for a landed hit, death and `revive`; the `heal_mode` option | Yes (`player-controller.md`) |
| Health, damage and death (R6) | Hard | `PlayerHealth.heal(amount)` that raises `current` by at most `max_health - current`, returns the amount applied, does nothing at 0 (a heal never revives) and **does not** clear invulnerability (`configure()` and `reset()` both do, `player_health.gd`); a `healed` signal (the arena's HUD listens only to `damaged` today); `set_max_health(new_max, refill)` so a health step needs no `configure()`; `take_damage` returning true for a landed hit. The meter itself is a pure `RefCounted` component (fill, spend, capacity, reset, no input and no nodes) owned by `Player` beside `health`, forwarded from the player's existing `hit_landed` handler, never held in `PlayerState` (an exported Resource that may be saved); `revive` resets it, and Continue and new game need an explicit reset call because `revive` has no callers yet | No (code: `src/player/player_health.gd`) |
| Collectible upgrades | Soft | The derived max health (F2) read at completion; the pre-edge damage seam below | Yes (`collectible-upgrades.md`, Approved) |
| Enemies | Hard | Foe hurtboxes in the `hittable` group on layer 8 that report `hit_landed`, and a new group `foe` on `EnemyBase` and boss hurtboxes (and on the `TrainingDummy`, not on `HitTarget`) so Healing can tell a foe from other hittables (rule 3); a dead foe's hurtbox leaves `hittable` and stops reporting; foes act before the Seeker on a tick (rule 15) | Yes (`enemies.md`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Bosses | Hard | The meter values and F3's bounds on heals per guard-break cycle (1 to about 2, decided in play, not a target) to tune the three stages against; a pattern or stage element that punishes a planted Seeker (Open Question 12); the stage-change and stagger rule (Open Question 2); its planned stages say the boss "must be tuned together with" healing |
| HUD (R9) | Hard | `heal_meter`, `meter_capacity`, the ready cue and the refusal cues by reason, and the channel progress |
| Hit feedback and effects (R8) | Soft | The fill pulse, the ready cue and the heal effect |
| Pause and menus | Soft | The `heal` action on the read-only controls page (controls are fixed, `pause-and-menus.md` rule 17), a default binding that avoids its reserved inputs (Escape, Start and gamepad B, rule 19), the `heal_mode` hold or toggle option on an options page (Open Question 14), and its flash limit (registry `flash_limit`, 3 per second) for the heal's light effects |

**Provisional interfaces.** Health (R6), the HUD (R9) and Hit feedback (R8) have no GDD, so every row naming them is provisional until those GDDs exist.

**Seam to resolve (collectible upgrades F3 against Combat).** Collectible upgrades multiplies sword health damage by up to x1.3 "on every sword attack's health damage". If that multiplier is applied before Combat emits `hit_landed`, edge steps would raise the fill by up to 30% and quicken heals with an unrelated upgrade. This GDD says the fill reads the damage before the edge multiplier; Combat or Collectible upgrades must keep the pre-edge value available on the signal (or apply the edge multiplier at the target). Resolve when either is next revised; recorded in Open Questions.

**Bidirectional check (2026-11-22, updated after the first design review):**
- **Bosses** names Healing (its planned-stages section and Open Questions). This matches.
- **Combat, Guard-break, Player controller, Enemies, Collectible upgrades, Save points and Pause and menus** each gained one Healing row in their Dependencies tables on 2026-11-22 (owner go-ahead). Combat's and Collectible upgrades' rows record the edge-multiplier seam; Player controller's records the `heal` action and a `CHANNEL` heal state (now named `Player.State.HEAL` here, so its row needs the new name), but its Values table, states list and input table are not yet updated (a follow-up for its next revision).
- **Systems index** row 27 was updated after the second design review: Combat, Player controller, Health and Enemies as dependencies, Guard-break, Collectible upgrades, Save points and Pause and menus as touched, Bosses, HUD and Hit feedback as fed.
- **Owed by other GDDs (second design review, not yet written):** Player controller's states list, Values table and input table (the `HEAL` state, `heal`, `heal_deceleration`, the `foe` group is Enemies'); Enemies (the `foe` group); Bosses (a Dependencies row naming Healing, the punishing pattern and the stage rule); Pause and menus (the `heal_mode` option and the `heal` row); `design/accessibility-requirements.md` (hold or toggle). Each is an Open Question below.

## Visual/Audio Requirements

`art-director` lens applied in-session (the heal's cues are what the player reads to play, so Lean mode runs it) against `design/art/art-bible.md` sections 1-4. `audio-director` and `sound-designer` not consulted: Lean mode, and no audio direction or asset exists yet (Audio is index #25, Not Started). Review manually before production.

**Art bible principles that apply.** *Principle 3, Combat owns the light:* the sword arc and the guard-break spark are the brightest events on screen, so no heal effect may out-shine them. *Principle 2, the greyscale order:* the Seeker is the lightest thing in the room, and the heal glow raises the Seeker, never anything around it. *Principle 1, crisp means contact:* effects on the Seeker are pixel art at 4x with nearest filtering. *Section 4, what colour means:* warm and pale is "you" (Bone Pale), steady Kiln Amber is "safe" (the rest pool), cool ice-white is "an enemy attack to dodge", and the four key colours (orange, chalk-yellow, copper-green, violet) belong to the abilities. The heal uses none of the last three.

| Event | Visual | Audio (direction only) | Limits |
|-------|--------|------------------------|--------|
| A hit fills the meter | On the meter only: it brightens at the new fill edge and settles in about 0.15 s. Nothing in the world | None; the hit's own sound carries the moment **[Rec]** | Combat owns the light: no spark or glow in the room for a fill |
| The meter becomes full (ready) | One soft pulse on the Seeker: its pale shade warms a half-step and eases back, as in the rest moment (art bible, Resting), plus the meter's full state. **While the meter stays full** the Seeker carries one small, steady, non-colour marker (a thin rim or a silhouette notch in Bone Pale, no animation) until the meter is spent, so the player can see "a heal is ready" mid-fight without looking at the HUD and without relying on colour | A short rising tone with a timbre of its own, not a variant of the refusal tick. It must be audible over boss music: a requirement for the sound designer | Eased over at least 0.5 s, once per fill (not on overflow); never a flicker. Peak no brighter than Bone Pale (luma 0.64); the marker is steady and never counts as a flash |
| `heal` refused, by reason (three families, told apart by place and motion, never by hue or text) | **(a) Meter not full:** the meter dims and shudders for about 0.2 s. **(b) Missing health below `start_deficit` (health near full):** the health display brightens once and eases back over about 0.3 s, and the meter does not move. **(c) A movement or combat state** (air, crouch, attack, hurt lock, dash, grapple, climb, wall, ledge): no cue, because the reason is visible on the Seeker and a cue would be noise | (a) A dull, short tick. (b) A soft, short tick, higher than (a). (c) None | Never red. **Rate limit: at most one refusal cue per 0.5 s**, so mashing the input gives at most 2 cue flashes a second, inside the registry `flash_limit` of 3 with room for the other heal lights. Never played during a door transition, a rest or death (input is locked or the Seeker is dead) |
| Channel (1.0 s) | The Seeker plays a planted heal pose; its own warm light grows steadily over `channel_time` (driven by `timer / channel_time`) and a few crisp pixel motes rise into it | A soft rising swell that follows the channel's progress, with a discrete pip at 0.5 s so the second can be read by ear | **Bone Pale, never Kiln Amber** (steady amber means safe, and the channel is the one vulnerable moment), never cool ice-white, never a key colour. The glow is steady, nothing flickers. It is a **sprite effect** on the Seeker (the project has no Environment glow, and the Seeker's aura is additive), with its colour capped at Bone Pale (luma 0.64) by a clamped `self_modulate` or shader uniform, because additive blending over the lightest sprite can otherwise reach Flash White |
| Completion | One soft bloom on the Seeker as health refills, easing out over about 0.4 s; the HUD health fills | A warm, low swell that settles | Peak no brighter than Bone Pale and never at Flash White (0.93), which belongs to the sword arcs and the guard-break spark |
| Cancelled (release, a hit, a movement press, a slide off an edge) | The glow fades out over at least 0.3 s with no flash while control returns at once (or, after letting go, when `RECOVER` ends); a hit's own hurt effect plays over it. In `RECOVER` the Seeker eases out of the planted pose | A short cut-off | Not a flash: a fall of 10% luminance or more counts toward the flash limit, so the fade is never faster than the limit allows. Tapping start and cancel five times in a second must still stay at or under 3 luminance events (AC-27) |

**Flash limit.** The pulse, the bloom, the refusal cues, the cancel fade and the glow count toward registry `flash_limit` (3 per second, WCAG 2.3.1) **together**, not one by one; with Flash reduction On they must read as steady glows and the refusal cue reads as a still change of brightness. AC-27 measures the combined result on a retained capture. With the atmosphere set to Reduced (parallax rule 14) the heal still reads through the Seeker's pose, the persistent full marker and the meter, not through bloom.

**Animation.** `seeker_animations.json` has no heal clip today (clips: idle, run, jump, dash, crouch, attack1-3, heavy, hurt, death and others), and its schema takes a `sheet`, `from`, `to` and `loop` per clip. New clips: `heal_loop` (a planted pose, `loop` true, for the channel) and `heal_end` (not looping, for the completion and the settle out of `RECOVER`; its end needs its own case in the player's `_on_animation_finished`, since a looping clip never finishes). Frame counts are the animator's and must not be tied to `channel_time`. The heavy's charge hold is the nearest existing pose to match for weight.

**HUD colours** (for the HUD GDD): the meter and its full state must not use a key colour or rely on red against green (art bible, UI palette), and the full state needs a shape or brightness cue, not a hue change alone (colourblind rule).

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:healing` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

**Feel reference.** Hollow Knight's Focus: a held, planted commitment that a hit breaks. The difference here is that the meter is kept on a cancel, so a mistake costs time and damage, not the work of earning the meter.

| Target | Value | Why |
|--------|-------|-----|
| Press to `CHANNEL` | the same physics tick (no start-up) | A heal the player has chosen must start when pressed; the wait is the channel, not input lag |
| First visible response | within 1 tick (the pose and the glow start) | The player sees the commitment begin |
| Cancel to control | By a jump, dash, grapple or attack press: 0 s, the action starts on the same tick. After letting go of the heal: `cancel_recovery` (0.25 s) planted, then control. After a hit: the controller's hurt lock as usual | A movement press must always be the free way out (pillar 1). Letting go in place is the one cancel that costs something, so a started heal is a commitment, not a toggle to flick on and off |
| Completion to control | 0 s (control on the completion tick) | The heal is the reward; no extra lock after it |
| Refusal cue | within 1 tick of the press | A press that did nothing must be seen to do nothing |
| Ready cue | the tick the meter reaches capacity | The player learns the heal is available without looking away from the fight |
| Press buffer | a press up to `press_buffer` (0.12 s) before the Seeker can heal starts the heal on the first tick it can, if still held | After a hit or a swing the first instinct is to press heal; losing that press silently feels like a bug |

**Weight.** The channel is a planted 1.0 s with no armour. A heal started right after a boss strike fits every gap between strikes (2.4 s or more, Core Rules 12), so the risk it carries comes from a hit that lands (it loses the second spent), from the 0.25 s cost of letting go, and from boss patterns that punish a planted Seeker (Open Question 12), not from the length of the channel alone; in a stagger (4.0 s) it is nearly free. **Hit-stop and screen shake:** a heal adds none. These targets are checked in the owner's playtest, not by an automated test (AC-26); "feels earned" is not a threshold.

## UI Requirements

- **A heal meter in the HUD**, near the health display, showing the fill as a bar (no number shown by default **[Rec]**; a tick or percentage option for low-vision players is for the HUD GDD to decide, Open Question 9), high-contrast tick marks at the empty, half and full points, a clear full state and the refusal cues by reason (Visual/Audio). The full state is a brightness and shape change, not a hue alone, and is echoed by the persistent marker on the Seeker. In a guard-break stagger the full state is the whole signal that a heal is available; no extra stagger readout is added **[Rec]**.
- **Hold or toggle (accessibility).** An option `heal_mode` (hold, the default, or toggle) on an options page (Open Question 14), recorded in `design/accessibility-requirements.md`. Controls cannot be remapped in the first scope (`pause-and-menus.md` rule 17), so the toggle is the accommodation for players who cannot hold an input for a full second.
- **Channel progress** shown on the Seeker (the growing glow and pose), not as a second bar, so the player's eyes stay on the fight.
- **Health display** length follows max health (collectible upgrades), unchanged by this system.
- **The controls page** (Pause and menus, read-only) lists `heal` with its keyboard and gamepad bindings; the default bindings are an open question (Open Question 1) because B, Escape and Start are reserved and the common keys are taken.
- The HUD's look waits for the art bible's section 7 (UI/HUD visual direction, still "to be designed") and the HUD GDD (R9).

> **📌 UX Flag — Healing**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This document references | Target | Fact or rule referenced | Used for |
|--------------------------|--------|-------------------------|----------|
| `design/gdd/combat.md` | Combat | `hit_landed(target, attack, damage)`; attack damages 8-30; charged heavy x2; the pogo is the down attack (8) | F1, rules 2, 3 |
| `design/gdd/guard-break.md` | Guard-break | Guarded hits deal x0.25 (boss x0.2); a steady 3-hit combo breaks the guard on the 8th hit (F2); stagger 4.0 s | Rule 2, F3, AC-3, AC-23 |
| `design/gdd/player-controller.md` | Player controller | `take_hit`, hurt lock 0.35 s, invulnerability 1.0 s, GROUND/ATTACK/HURT/DEAD states, `revive`, no dash i-frames, max health 100 | Rules 6, 9, 10, F2, Edge Cases |
| `design/gdd/bosses.md` | Bosses | Planned three stages, "tuned together with healing", pattern recoveries 1.0-1.3 s and gaps between strikes 2.4-3.3 s | Rule 12, F3, Open Questions |
| `design/gdd/enemies.md` | Enemies | `hittable` hurtboxes, hit damage 10-30, no contact damage, rebuilt on room entry | Rule 3, farming edge case |
| `design/gdd/collectible-upgrades.md` | Collectible upgrades | Derived max health 100-180 (F2), health step refills health (rule 9), the edge multiplier (F3) | F2, Edge Cases, Dependencies seam |
| `design/gdd/save-points-and-save-load.md` | Save points | A rest heals to full (rule 4); arrival and Continue start full (rules 8, 11); no enemy near a rest area (rule 3) | Rule 5, farming |
| `design/gdd/world-state.md` | World state | Rule 1: health is not in the record (so the meter is not either) | Rule 5 |
| `design/gdd/pause-and-menus.md` | Pause and menus | Fixed controls (rule 17), reserved inputs (rule 19), registry `flash_limit` | Dependencies, Visual/Audio |
| `design/art/art-bible.md` | Art bible | Principles 1-3, Section 4 colour meanings, the Resting state | Visual/Audio |
| `design/gdd/game-concept.md` | Game concept | Core mechanic 6, anti-pillar 2, the Healing open questions | Overview |

## Acceptance Criteria

The `qa-lead` lens was applied in-session in the first review and by a specialist in the second. Defaults are the starting values: `meter_capacity` 120, `heal_share` 0.30, `channel_time` 1.0 s, `cancel_recovery` 0.25 s, `start_deficit_share` 0.5 (`start_deficit` 15), `press_buffer` 0.12 s, player `max_health` 100 and `run_speed` 140 (read from `player_config.tres`, not typed into the test). Tags: **[Logic]** automated unit test, **[Integration]** automated integration test with the real nodes, **[UI]** retained screenshot or capture in `production/qa/evidence/`, **[Playtest]** owner playtest. A physics tick is 1/60 s and every timing below is counted in ticks: tests drive the physics `delta` directly and never touch `Engine.time_scale`. The meter is a pure component (`HealMeter`) and the heal is `Player.State.HEAL`; until the save, rest and revive flows exist, AC-9 to AC-20 that need them are written against the component's contract (`reset()`, `on_rest()`, `on_room_change()`) and become integration tests when the flows exist.

**The meter**
- **AC-1 Fill [Logic].** GIVEN the meter is 0, WHEN attack1, attack2 and attack3 land on a foe in turn (damage 10, 12, 20), THEN the meter reads 10, 22 and 42. **AC-1b:** a pogo (down attack, damage 8) on a foe adds 8.
- **AC-2 Cap [Logic].** GIVEN the meter is 100, WHEN a charged heavy lands (damage 60), THEN the meter is 120 (not 160); WHEN a further hit lands, THEN it stays 120 and no ready cue plays a second time.
- **AC-3 Guarded hits fill in full [Integration].** GIVEN the boss is GUARDED and the meter is 0, WHEN attack1 lands, THEN the meter is 10 and the boss's health fell by 2.0 (damage x 0.2): the fill ignores the guard multiplier.
- **AC-4 Only foes feed it [Integration].** One test per target. GIVEN the meter is 30, WHEN the down attack hits (a) a hazard, (b) a breakable, (c) a pane, (d) a `HitTarget`, THEN the meter stays 30. **AC-4b:** WHEN it hits an `EnemyBase`, a boss hurtbox or the `TrainingDummy` (all in group `foe`), THEN the meter rises by the hit's damage.
- **AC-5 Killing blow [Integration].** GIVEN a foe has 5 health and the meter is 0, WHEN attack1 (damage 10) kills it, THEN the meter is 10, added once.
- **AC-6 One swing, two foes [Integration].** GIVEN two foes overlap one attack1 swing and the meter is 0, WHEN the swing lands, THEN the meter is 20.
- **AC-7 Bad damage [Logic].** GIVEN the meter is 50, WHEN a hit reports damage 0, and then another reports -5, THEN the meter stays 50 after each.
- **AC-8 No decay, fills at full health [Integration].** GIVEN health is 100 of 100 and the meter is 60, WHEN 3600 physics ticks pass with no hit, THEN the meter is 60; **AC-8b:** WHEN a hit then lands, THEN the meter rises.
- **AC-9 Resets [Logic until the flows exist].** GIVEN the meter is 80: **AC-9a** a death and `revive` leave 0; **AC-9b** a Continue and a new game each leave 0; **AC-9c** a rest and a room change each leave 80; **AC-9d** the meter is not part of the saved record (World state rule 1).

**Starting a heal**
- **AC-10 Not ready [Logic].** One test per case, each with the meter full unless stated. WHEN `heal` is pressed: **10a** meter 119: no `HEAL`, nothing spent, the meter-not-full refusal cue; **10b** health 86 of 100 (missing 14, below `start_deficit` 15): no `HEAL`, nothing spent, the health refusal cue; **10c** health 85 of 100: `HEAL` starts (the boundary); **10d** one test for each state `AIR`, `CROUCH`, `ATTACK`, `HURT`, `CLIMB`, `WALL_SLIDE`, `DASH`, `GRAPPLE`, `LEDGE` and `DEAD`: no `HEAL`, nothing spent and **no cue** (movement-state refusals are silent). A press during a door transition or a rest is AC-32.
- **AC-11 Fresh press and buffer [Logic].** **11a** GIVEN `heal` was held for 30 ticks through an attack and the meter is full, WHEN the attack ends, THEN no heal starts; WHEN the input is released and pressed again, THEN `HEAL` starts. **11b** GIVEN `heal` is pressed 5 ticks (0.083 s) before an attack's lock ends and is still held, THEN the heal starts on the first tick the Seeker is `GROUND`; if it is released first, nothing starts; if it was pressed 8 or more ticks before, nothing starts. **11c** GIVEN the meter reaches capacity 3 ticks after a press, THEN no heal starts (a press that fails on the meter is never buffered).

**The channel**
- **AC-12 Planted [Integration].** GIVEN the Seeker runs at `run_speed` with a full meter and health 70 of 100, WHEN `heal` is pressed, THEN horizontal speed is 0 by tick 5, the total displacement from the press is at most 6.5 px, and from then until the channel ends the position does not change (the skid stops 140 px/s on a 2000 px/s2 deceleration in about 4.2 ticks and about 5 px; the bound allows the order of movement and deceleration within a tick).
- **AC-13 Completion [Logic].** GIVEN the meter is 120: **13a** health 70 of 100, WHEN `heal` is held for the channel, THEN health is 100, the meter is 0 and the Seeker is back in GROUND on that tick; **13b** health 50: 80; **13c** max health 180 and health 90: 144; **13d** health 85 of 100: 100, meter 0 (15 of the 30 is unused).
- **AC-14 Not before time [Logic].** GIVEN a channel started on tick 0, THEN on tick 57 (0.95 s) the meter is still 120 and health is unchanged; the heal is applied on tick 60 and never before it, and no later than tick 61.
- **AC-15 Letting go [Logic].** GIVEN a channel at tick 30, WHEN `heal` is released, THEN health is unchanged, the meter is 120, the Seeker is planted in `RECOVER` and presses of attack, jump and heal do nothing for 15 ticks (+-1); on tick 15 control returns in GROUND. **15b (toggle mode):** WHEN a second press of `heal` replaces the release, THEN the same result.
- **AC-16 Movement cancels [Integration].** One test per action. GIVEN a channel at tick 30, WHEN **16a** jump, **16b** dash, **16c** grapple (owned) or **16d** attack is pressed, THEN the channel ends that tick, the pressed action starts that tick with no recovery, the meter is 120 and health is unchanged.
- **AC-17 A hit cancels, no protection [Integration].** **17a** GIVEN a channel at tick 30 and a foe attack of 15 damage, WHEN it lands, THEN health falls by the full 15, the meter stays 120, no heal occurs and the Seeker is in HURT. **17b** GIVEN a first hit, 22 ticks (past the 21-tick hurt lock), a fresh `heal` press and a second hit at tick 40 of the channel (inside the 60-tick invulnerability window), THEN `take_hit` returns false and the channel continues.
- **AC-18 Hit and completion on one tick [Integration].** GIVEN a channel on tick 59 and a foe whose `take_hit` runs in the same physics step, tested once with the foe before the Seeker in the tree and once after it, THEN in both orders the hit lands first, the channel is cancelled, no heal occurs, the meter is 120 and the Seeker is in HURT (Core Rules 15).
- **AC-19 Death mid-channel [Logic].** GIVEN a channel and a killing hit, THEN the channel is cancelled; after `revive`, the meter is 0.
- **AC-20 Interact takes over [Integration].** GIVEN a channel in a rest area, WHEN `interact` is pressed, THEN the rest starts, the channel is cancelled and the meter is kept. **20b:** WHEN `interact` is pressed with no door or rest area overlapped, THEN it is ignored and the channel continues.
- **AC-21 Max health changes mid-channel [Logic].** GIVEN a channel and a health step completes (max 100 to 120, health set to 120), WHEN the channel completes, THEN no heal is applied and the meter is kept at 120.
- **AC-22 Pause [Integration].** GIVEN a channel at tick 36 (0.6 s), WHEN the game is paused for 300 ticks of wall time and resumed, THEN the heal completes 24 ticks (+-1) after the resume, and no scene-tree timer drives the channel.
- **AC-23 Boss cycle arithmetic [Integration].** GIVEN the default config and a full-guard boss, WHEN the Seeker lands attack1, 2, 3, 1, 2, 3, 1, 2 on it, THEN the guard breaks on the 8th hit with the meter at 106; WHEN attack3 follows in the stagger, THEN the meter is 120 (126 capped) and stays 120 for further hits. **23b:** GIVEN the meter is 0 and a full-guard boss, WHEN a charged heavy lands, THEN the guard breaks and the meter is 60. This checks the fill and the cap only; how many heals a cycle gives is AC-26.
- **AC-24 Config validation [Logic].** GIVEN `meter_capacity` 0, `heal_share` 0.6 and `channel_time` 3.0, WHEN `HealingConfig.validate()` runs, THEN it returns those three names; WHEN the Player is configured, THEN each is clamped into its range, `push_error` names it and the game keeps running. **24b:** the boundary values `meter_capacity` 40 and 300, `heal_share` 0.20 and 0.40, `channel_time` 0.5 and 2.0, `cancel_recovery` 0 and 0.5, `start_deficit_share` 0 and 1.0, `press_buffer` 0 and 0.2 return an empty list.

**Cancels and input**
- **AC-28 Catch-all and the jump buffer [Integration].** GIVEN a channel at tick 30, WHEN crouch, bow, cast, rapid fire, map or a second `heal` press (hold mode) is pressed, THEN the channel continues. WHEN jump is pressed and the Seeker lands again, THEN exactly one jump has happened (the jump buffer was cleared on the exit).
- **AC-29 Hit during recovery [Integration].** GIVEN the Seeker in `RECOVER`, WHEN a foe's attack lands, THEN health falls by the damage and the Seeker is in HURT; a heal cannot start before `RECOVER` ends.
- **AC-30 Edge slide [Integration].** GIVEN the Seeker skidding at a ledge so the skid carries it off, WHEN it loses the floor, THEN the channel is cancelled, the Seeker is in AIR and the meter is kept.
- **AC-32 Locked input [Integration].** GIVEN a door transition or a rest in progress, WHEN `heal` is pressed, THEN no `HEAL` starts, the meter is unchanged and no refusal cue plays.

**Presentation**
- **AC-25 Meter display [UI].** GIVEN the HUD, THEN a retained screenshot in `production/qa/evidence/` shows the meter at 0, about half and full, and each refusal family. Blocking, and it belongs to the HUD story: it needs the HUD GDD first. A still cannot show a 0.2 s shudder, so the refusal cue's motion is covered by AC-27's capture.
- **AC-27 Flash limit [UI, retained capture].** GIVEN a scripted 1 s with 10 refused presses (meter not full), and a second scripted 1 s with 5 start-and-cancel cycles, WHEN each is captured at 60 fps, THEN in any 1 s window at most 3 luminance events of 10% or more occur counting the refusal cue, glow, pulse, bloom and fade together, and 0 with Flash reduction On; the pulse and bloom peak at luma 0.64 or less and never reach 0.93; the glow is never Kiln Amber, ice-white or a key colour. The refusal cue is limited to one per 0.5 s. Sign-off by the lead.
- **AC-31 Heal visuals [UI].** GIVEN the heal clip and the HUD exist, THEN retained screenshots in `production/qa/evidence/` show the ready pulse and the persistent full marker, the channel glow at 0.0, 0.5 and 1.0 s, the completion bloom and the `RECOVER` pose, each at the art bible's colour limits, with a lead sign-off. Needs the heal clip (Open Question 8).
- **AC-26 Boss-cycle log and playtest [Integration for the log, advisory for the playtest].** **26a, the log [Integration]:** GIVEN a scripted run of a boss attempt, THEN the build logs `heal_meter_full`, `heal_started`, `heal_completed` or `heal_cancelled`, `guard_broken` and (when the stages exist) `stage_changed`, in that order for the run, each with the meter value, the health and the time, and it logs the measured `fill_rate` per attack path (light combos, charged heavy). **26b, the playtest [advisory, a milestone, never a story gate]:** GIVEN the boss fight is built (the current one-stage boss is enough to start), WHEN the owner plays three attempts, THEN a report exists in `production/qa/evidence/` with the log, the heals earned and spent per guard-break cycle, `heal_ratio` (F3), a yes or no on "felt earned", "felt risky" and "felt fair", and the owner's recorded decision: "no change" or "change `meter_capacity`, `heal_share`, `channel_time` or the boss's damage". No number is a pass-fail threshold **[Owner, 2026-11-22]**. Stage-specific checks wait for the three stages (`bosses.md`).

**Gaps found by the lens (not blocking):**
- Rule 11 (no fill during a heal) is testable at the component level (a fill is refused while the state is `HEAL`) but has no source today; it is a design note.
- Rule 13 (a stage change neither fills nor empties the meter) cannot be tested until the stages are built and Open Question 2 is settled; the AC-26a log records the meter at a stage change.
- The Overview's "a breath won back by pressing the attack" is a feeling, not a threshold: it is AC-26b's question.
- AC-9, AC-19 and AC-20 become integration tests when the save, revive and rest flows exist.
- The pre-edge damage seam (Open Question 4) has no criterion until an edge step can complete.

## Open Questions

| # | Question | Owner | Resolve by |
|---|----------|-------|------------|
| 1 | **Default bindings for `heal`.** Keyboard keys free today: R, G, H; the gamepad has no free face button (A jump, X attack, Y rapid fire, B interact now and reserved for `cancel`, bumpers dash and grapple, triggers bow and cast). Suggested: keyboard R, gamepad right stick click (R3). The second review found R3 awkward to hold for a second in a fight and suggested Y for `heal` with `rapid_fire` (no GDD) moved to R3. Needs an owner pick; the toggle option (rule 14) takes some of the sting out of a hard-to-hold button. The code owns the default (`PlayerInputBindings.BINDINGS`). | Owner | Before the controller story |
| 2 | **What a boss stage change does for the heal and the stagger.** Rule 13 says it does not touch the meter. The second review adds: stage 1 ends at the first guard-break, so the stagger is the transition. Recommended default: the stage change keeps the full 4.0 s stagger and gives no refill. If a roar animation ate the stagger the heal window would vanish; if it did not, the player gets a free heal at each change. | Owner | When the boss stages are built |
| 3 | **Farming.** A rebuilt foe is a heal source (Edge Cases), and because the meter is 0 after a death, a retry with a banked heal needs farming. Accepted for now; the second review recommends a diminishing fill for repeat kills in one room in the first version, not after abuse is seen. | Owner | After the first playtest of the heal |
| 4 | **Pre-edge damage on `hit_landed`** (Dependencies seam): Combat or Collectible upgrades must keep the pre-edge value available; no edge step can complete in region 1, so it can wait. | `/design-review` of Combat and Collectible upgrades | Next revision of either |
| 5 | **Heal in the air** is not allowed (rule 6, a recommendation). Whether a planted ground-only heal is right for the movement-first pillar is a playtest question. | Owner | First playtest |
| 6 | **Meter upgrades.** Whether a collectible raises capacity or heal share, or a second bar is added later; the heal's worth in boss hits grows 1.8 times from 100 to 180 max health while its meter cost stays the same (F2). | Owner | Alpha |
| 7 | **Channel time against the boss's gaps.** 1.0 s against gaps of 2.4 s or more: tuned in play; raise toward 1.5 s if the heal is too safe, before changing the boss. | Owner, with the boss stages | Boss tuning round |
| 8 | **A heal clip and audio** do not exist: the Seeker needs `heal_loop` and `heal_end` clips and the sounds need a sound designer (Audio GDD not started). The first built story retains AC-31's screenshots and AC-27's capture as its evidence. | Art and Audio | Before the heal is built |
| 9 | **Numeric display** of the meter (rule: none by default) and an optional tick or percentage for low-vision players. The HUD GDD decides. | HUD (R9) | HUD design |
| 10 | **Heals per cycle and the heal ratio.** F3 bounds a skilled player at 1 to about 2 heals per guard-break cycle on the light path and about 1.7 on the charged-heavy path, from an estimated fill rate that is not measured. Whether that is fair, and whether `meter_capacity`, `heal_share` or the boss's damage should move, is decided in play from the `heal_ratio` log (AC-26). Include in the read: a heal started inside the invulnerability window is protected for 0.65 s, and a heal in a stagger is nearly free before the last stage. | Owner | First boss playtest with the meter logged |
| 11 | **Guarded hits fill at full.** The second review found this the largest source of easy heals in a stagger (the meter is 106 of 120 when a light-combo break lands). Kept as the owner decided; revisit with the log. Options: half fill for guarded hits, or fill from health damage dealt. | Owner | After the first heal-ratio log |
| 12 | **A boss pattern that punishes a planted Seeker.** Rule 9 and the cancel recovery are part of making the heal a gamble, but a heal started right after a strike fits every gap, so the boss has to take that safety away (for example a short-wind-up strike, a tracking projectile or a delayed second strike). Not written in `bosses.md`. | Owner, with Bosses | Boss tuning round |
| 13 | **Fill consistency.** Overkill adds up to one hit's damage per kill; a guarded boss hit fills 5 times the health it removes. Cap each hit's fill at the target's remaining health? `EnemyBase.take_hit` returns nothing today, so it cannot report a refused hit. | Owner | With Open Question 11 |
| 14 | **The `heal_mode` hold or toggle option** needs an options page in Pause and menus and a line in `design/accessibility-requirements.md`; neither is written. | Pause and menus, accessibility | Before the controller story |
| 15 | **Other GDDs owe Healing rows.** Player controller (the `HEAL` state, `heal`, `heal_deceleration`, input table), Enemies (the `foe` group), Bosses (a Dependencies row, Open Question 12). | Each GDD's next revision | Next revision of each |
| 16 | **Advisory sections.** Player Fantasy and Tuning Knobs (advisory at `standard`): the Overview and the Values table carry them for now. | Owner | Optional |
