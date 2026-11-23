# Healing (hit-fed heal meter)

> **Status**: Designed 2026-11-22 (`/design-system`, lean, standard, guided). Seven design reviews, all NEEDS REVISION or worse. **Eighth-review revision 2026-11-23:** the presentation detail moved to `design/ux/healing-presentation.md`, Core Rules were rewritten to state outcomes (mechanisms are in `docs/architecture/adr-0003-heal-tick-order.md` and `docs/architecture/healing-implementation-notes.md`), and the carried blockers were fixed. Awaiting a re-review in a fresh session, after `/clear`.
> **Author**: owner + Claude
> **Last Updated**: 2026-11-23
> **Last Verified**: 2026-11-23
> **Implements Pillar**: P1 Movement Is the Mastery (with a tension kept on purpose: the heal channel is planted). Anti-pillar 2 (no consumables) shapes the meter. Not P4: a heal meter is not an ability that opens a route.

**Tags used below:** **[Owner]** the owner's stated decision (with its date); **[Rec]** a recommendation, change freely; **[Code]** how the code works today. Values in `code font` are data, set in Formulas.

## Summary

Every hit the Seeker lands fills one heal meter; a full meter can be spent on a 1.0 s planted channel that restores 30% of max health. Letting go and every voluntary cancel is free; a hit that lands during the channel stops it, empties the meter and deals its damage, as in Hollow Knight [Owner, 2026-11-23]. Recovery is earned by fighting (pillar 1, anti-pillar 2: no consumables), and the three-stage boss needs a player who can recover between stages.

> **Quick reference** — Layer: `Gameplay` · Priority: `MVP` · Key deps: `Combat, Player controller, Health (code); touches Guard-break, Collectible upgrades, Bosses, HUD`
> Engine feasibility: every engine claim is unverified and listed for story 1 in ADR-0003 and the implementation notes; this GDD states outcomes only.

## Overview

Healing lets the Seeker recover health in the middle of a fight, and it is earned by fighting. Every hit the Seeker lands fills a **heal meter**; when it is full the Seeker can spend it on a 1.0 s planted channel that restores health, as Hollow Knight's Focus does **[Owner, 2026-11-22]**. The player pays with good play (landing hits) and with the second a heal takes, never with an item, a currency or a trip to a save point. The meter is sized from the heal itself (about 4 fill points per HP restored), so a heal costs the same fighting at every max health.

**Where the risk lives (stated once; every other section points here).** Letting go and every voluntary cancel are free and keep the meter; **a hit that lands during the channel cancels it, empties the meter and deals its damage** [Owner, 2026-11-23]. At today's boss timings a heal started right after a strike ends 0.6 to 0.9 s before the next wind-up, so **against the current boss nothing lands inside the channel window and the cost of a hit never applies**. **[Owner, 2026-11-23]: the stake belongs to the boss, not to the meter.** Healing **requires** the boss to take that safety away with a pattern or stage element that strikes inside the channel window (Open Question 12, owed to Bosses). **Until it exists, stage 1 of the boss is risk-free by design, nothing in this document may call a heal a gamble, and AC-26's "felt risky" and "felt fair" questions apply only once the boss supplies the risk.** Without Healing, health is a one-way budget until the next rest, and a long boss fight punishes one early mistake for the whole fight.

**Design intent.** **[Owner, 2026-11-22]** a meter filled by landing hits and spent when full, as in Hollow Knight; after the first boss playtest ("super easy") the owner wants a three-stage boss with no health bar and a heal meter, tuned together (`bosses.md`). Anti-pillar 2: a heal is never a consumable, a purchase or a drop. **[Rec]** pillar 1: recovery is earned by fighting. **A tension kept on purpose:** any hit fills the meter (a pogo 8, a charged heavy 60), so it does not reward moving through the fight, and the heal is a planted second, the opposite of flowing momentum; the answer is that letting go is always free (rule 9).

**Scope**: in: the meter (capacity, fill, keep or empty), the heal action (input, channel, cost, interruption), how health is restored, and the rules for foes and bosses. Out: the health pool, damage and death (R6), the meter and health display (HUD, R9), the heal effect and sound (Hit feedback, R8; `design/ux/healing-presentation.md`), max-health upgrades (Collectible upgrades) and the boss's stage tuning (Bosses).

## Player Fantasy

*Advisory at `standard`. It holds in full once the boss supplies the risk (Overview).*

- **Ready.** The player is fighting well and feels the bar fill under their hits. When a heal is usable the Seeker carries a quiet mark: *a breath is banked, and I can take it when I choose.*
- **Committing.** Pressing heal is a decision: the Seeker plants and the light gathers for one second, and the player is reading the boss, not the button. Backing out is always allowed and free (jump, dash, grapple, attack, letting go, and in toggle mode a stick push), so the player is never trapped; only a hit costs the bar.
- **Being hit.** The light breaks, the hit hurts in full and the banked bar is gone [Owner, 2026-11-23]. That is the cost of a misread, and it is the boss's timing that must create it (Overview); the player should blame their read of the telegraph, never the rules, which is why every voluntary cancel stays free.
- **Never.** A consumable (anti-pillar 2), a lock (the player can always leave the channel), or a free refill (the health pool must still matter).
- **Test.** AC-26's playtest asks "felt earned", "felt risky" and "felt fair" in these terms.

## Detailed Design

### Core Rules

**The meter**

1. **One bar.** The heal meter is one number, `heal_meter`, from 0 to `meter_capacity`; a full bar is one heal. **[Owner, 2026-11-22: a bar, a heal spends it all]**
2. **What fills it.** Every hit the Seeker lands on a foe adds `damage` to the meter: the value Combat reports for that hit, the attack's base damage with the charged heavy's x2 already in it, **before** the guarded, finisher and edge multipliers. A hit on a guarded foe or boss fills as much as any other; the killing blow counts; one swing that hits two foes adds each foe's own `damage`. **[Owner, 2026-11-22: fill by base damage; 2026-11-23: guarded hits keep their full fill]**
3. **Only foes feed it.** The hurtboxes of enemies, bosses and the `TrainingDummy` join a new group `foe`; test targets such as `HitTarget` do not. A pogo on a hazard, breakable or pane adds nothing, and a dead foe reports nothing. **The `TrainingDummy` stays out of shipped rooms** (AC-42). Whether stage-3 small enemies feed the meter is owed to Bosses; the recommendation is that they do not (Open Question 17). **[Rec]**
4. **The meter caps and keeps.** It never exceeds `meter_capacity` (the excess is lost), does not decay, and keeps filling at full health, so a player can arrive at a fight with a heal ready. When max health changes the meter keeps its fraction (F1). "Full" is `heal_meter >= meter_capacity` within a small tolerance. **[Rec]**
5. **Resets.** The meter is 0 at a new game, after a Continue and after a death. A rest and a room change leave it as it is. It is not saved, like health (world state rule 1). **[Owner, 2026-11-22]**

**The heal**

6. **Input and start.** A new action `heal`, held to heal (or toggled, rule 14). A heal starts on a press only when the meter is full, missing health is at least `start_deficit` (F2; so a heal never starts at full health) and the Seeker is in `GROUND`, which includes the landing animation. `CROUCH` (the stand-up included), `CLIMB`, `WALL_SLIDE`, `DASH`, `GRAPPLE`, `LEDGE` and `DEAD` start nothing and are not buffered. **If another action would start on the press tick (grapple, dash, a door `interact`, attack, jump) it wins and no heal starts**, and a heal cannot start on a tick on which one ended (rule 9). **Refusal cue, by priority:** (1) meter not full: the **meter** cue; (2) otherwise missing health below `start_deficit`: the **health** cue; (3) otherwise a blocked state: **no cue**, deliberately, though it is not self-explanatory for a ladder, wall, ledge or crouch (Open Question 20). `AIR`, `ATTACK` and `HURT` buffer the press (rule 14), so a press in the air with an empty meter plays the meter cue. **[Rec: ground only, a planted commitment; Owner, 2026-11-23: an empty meter is always announced]**
7. **The channel.** A started heal is a channel of `channel_time` (1.0 s), the new top-level controller state `Player.State.HEAL`. The Seeker is planted: it skids to a stop at `heal_deceleration` and cannot attack, jump, dash or grapple except to cancel (rule 9). If the skid carries it off an edge the channel is cancelled and the Seeker is in `AIR`; a coyote jump still works. The timer counts game time: a pause freezes it, and hit-stop stretches it in real time but not in game time (mechanism: ADR-0003). **[Owner, 2026-11-22: 1.0 s channel, planted]**
8. **Completion.** When the timer reaches `channel_time` (tick 60 at 60 Hz, tick 0 being the press tick) uncancelled and **health below max**, the meter is spent in full and health rises by the heal amount (F2), never above max. If health is already at max (a health step refilled it mid-channel) nothing is healed, the meter is **kept**, and the channel ends as `heal_cancelled(&"full_health")`, silent. Nothing is spent before completion. **[Owner, 2026-11-22]**
9. **Cancelling.** A cancel ends the channel with the time channelled lost (no partial heal) and the meter kept, with one exception: **a hit that lands empties the meter to 0** **[Owner, 2026-11-23]**. No other cancel spends it. **Every voluntary cancel is free, with no recovery: letting go is always free** **[Owner, 2026-11-23: the late-release recovery is cut for the first build; Open Question 22]**.
    - **Involuntary:** a hit lands and the Seeker goes to `HURT` or `DEAD`, meter emptied (a hit inside the invulnerability window does not land, so it neither cancels nor empties); the Seeker dies; a door, exit or rest takes over (`interact` with a door or rest area overlapped); the skid carries the Seeker off an edge.
    - **By an action press** (free): jump, dash, grapple (once owned) or attack ends the channel on that tick and the action starts as it would in `GROUND`; attack arms Combat's own tap or hold resolution that tick. **A press cancels only if the action would start**: a dash on cooldown or a grapple with no anchor or not owned is ignored and the channel continues. With several presses on one tick this order wins: grapple, dash, door or rest `interact`, attack, jump. Climb is not polled during a channel. A jump press cancels and jumps exactly once; a jump buffered before the heal started never cancels it.
    - **By letting go:** the heal input is released (hold mode) or pressed a second time (toggle mode). On the completion tick neither cancels: the heal completes (rule 15).
    - **By a stick push (toggle mode only):** a fresh horizontal push of the stick, D-pad or arrow keys past `stick_cancel_deadzone` cancels free, so a player with no "let go" reflex is never trapped. A direction already held at the press does not cancel until it has returned inside the deadzone. Up never cancels (`interact` shares it). On the completion tick a stick push, like a second press, lets the heal complete. In hold mode the stick is ignored. **[Owner, 2026-11-23: toggle mode only]**
    - **Everything else is ignored and not buffered:** crouch, climb, bow, cast, rapid fire, map, and `interact` with no door or rest area.
    - **A press is spent once:** a `heal` press that starts a heal or cancels one is consumed, and a button still held after an action cancel does not restart a heal.
10. **No protection of its own.** The channel gives no invulnerability, damage reduction or armour: a hit that lands cancels it, empties the meter and deals its full damage. **One accepted exception [Owner, 2026-11-23]:** a heal that starts while the invulnerability window of an earlier hit still runs is protected until it ends. The window (1.0 s) outlasts the hurt lock (0.35 s) by 0.65 s, so such a heal is protected for about 0.63 to 0.65 s of its first second; it is kept because the press buffer after `HURT` makes right after a hit the natural moment to heal. A boss pattern must strike after the window to punish such a heal (Open Question 12), and `channel_time` may not go below 0.7 s (Values).
11. **Fills during a heal.** The Seeker cannot attack while planted, so nothing fills the meter then; a hit from a delayed source (none today) would still count (AC-34). **[Rec]**

**Boss fights**

12. **The meter fills in a boss fight like anywhere else** (rule 2), and the boss's stages are tuned with the heal in mind. F3 bounds what a skilled player earns per guard-break cycle (1 heal in the stagger, 2 when a banked heal is also spent in the guard phase, about 1.5 sustained on the charged-heavy path); whether that is fair is **decided in play** from the AC-26 log. **The windows a heal fits in** (`bosses.md`): the gap from the end of a strike to the next wind-up is 1.9 s after a slam and 1.6 s after a lunge or shockwave, and the next strike is at least 2.4 s away. A 1.0 s channel started the moment a strike ends ends 0.9 s (slam) or 0.6 s (lunge, shockwave) before the next wind-up; a heal after a hit starts after the 0.35 s hurt lock and ends 0.55 s or 0.25 s before it. After a stagger the next wind-up waits 0.4 s longer. **The boss cannot punish a heal at the current timings; that safety is the boss's to take away (Open Question 12).** One exception: a shockwave already in flight (3.5 s at 150 px/s) reaches a Seeker planted at distance d after d / 150 s. In a stagger (4.0 s) a heal costs 1.0 s of punish damage, but the planned stages end on a guard-break count, so it is nearly free (owner-accepted, watched in the log). **[Owner, 2026-11-22: tune the boss together with healing]**
13. **A stage change neither fills nor empties the meter.** What the transition does for the player's heal is Open Question 2.

**Input and timing**

14. **Press buffer and hold or toggle.** *Buffer:* a `heal` press that fails only because the Seeker is in `ATTACK`, `HURT` or `AIR` is remembered for `press_buffer` (0.12 s) and starts the heal on the first tick every start condition holds (`press age <= press_buffer`). In hold mode the input must still be held; in toggle mode it need not be. A press that fails on the meter or health is never buffered, and a press held longer than the buffer when conditions begin to hold starts nothing: release and press again. *Hold or toggle:* an accessibility option `heal_mode` (Open Question 14). In `hold` mode (default) the channel needs the input held and releasing cancels; in `toggle` mode a press starts the channel, it runs without being held, and a second press cancels as a release does. A press that fails to start does not arm the toggle. **Toggle mode must ship with the heal** (no remapping in the first scope, `pause-and-menus.md` rule 17). *Pause:* a release during a pause cancels on the first tick after the resume, and a `heal` press on that tick is not a heal press. **[Rec; Owner, 2026-11-23: buffer fixed for toggle mode]**
15. **Order within a physics tick (outcomes).** Hitters act first, then the Seeker, so **a hit that lands on a tick always wins over a heal that would complete on that tick, and empties the meter** (AC-18). Each tick after the press tick: a cancel press is applied; a release or toggle second press is applied **unless this is the completion tick**; the timer advances; completion is tested. **The tick-60 asymmetry is on purpose:** a release, second press or stick push on the completion tick completes the heal, and a jump, dash, grapple or attack press on it cancels and the heal is lost. How the order is guaranteed: ADR-0003 (the owner chose a priority-10 helper node on 2026-11-23, so Combat and Enemies are not changed).

### States and Transitions

The meter has no states: "full" means `heal_meter >= meter_capacity`. The heal is one new top-level controller state, `Player.State.HEAL`, with one phase (the channel): it is entered when rule 6 holds on a press and left by one of the exits below. Cleanup (timer, effects, the pending-completion flag) runs on every exit.

| Exit | Meter | Health | Player state after |
|------|-------|--------|--------------------|
| Completes (health below max) | 0 | + heal amount (capped) | GROUND at the end of tick 60, control from tick 61 (the completion node runs after the Seeker, ADR-0003) |
| Completes with health at max | kept | unchanged | GROUND, `heal_cancelled(&"full_health")` |
| Release, toggle second press, toggle stick push | kept | unchanged | GROUND, control the same tick |
| Jump, dash, grapple or attack that would start | kept | unchanged | the action starts the same tick |
| A hit lands | 0 (emptied, owner 2026-11-23) | - the hit's damage | HURT (or DEAD) |
| Slide off an edge | kept | unchanged | AIR |
| Door or rest takes over | kept | unchanged | ENTER_DOOR or the rest |
| Death | 0 on revive | 0 | DEAD |

### Interactions with Other Systems

Only Combat, Guard-break, Player controller, Bosses, Enemies, Collectible upgrades, Save points and Pause and menus have GDDs. Health (R6), Hit feedback (R8) and the HUD (R9) have code or nothing, and each interface to them is **provisional**.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Combat | In | `hit_landed(target, attack, damage)`: `damage` feeds rule 2 when the target is in group `foe`; Combat's charged x2 is inside it | Combat owns the signal; Healing owns what a hit adds |
| Guard-break | None | A guarded hit fills at full; a stagger is a window to heal or punish | Guard-break; Healing owns the fill |
| Player controller | Both | In: the `heal` input, `heal_mode`, state, landed-hit, death and `revive` signals. Out: the `HEAL` state, the cancel rules, the jump-buffer rule, the completion node (ADR-0003) | Controller owns states and input; Healing owns when a heal may start, run and end |
| Health, damage and death | Out | The heal amount, applied without touching invulnerability; a `healed` signal (**neither exists in code today**, see Dependencies) | Health owns the values; Healing owns the amount and when |
| Collectible upgrades | In | Max health (100 to 180): the heal is a share of it (F2) and the capacity is derived from it (F1) | Collectible upgrades owns max health; Healing owns the share |
| Enemies, Bosses | In | Every foe hit via `hit_landed`; the `foe` group; bosses tuned against the AC-26 log and expected to punish a planted Seeker (Open Question 12) | Bosses owns the boss's tuning; Healing owns the heal values |
| Save points | None | A rest leaves the meter alone (rule 5) while it heals health to full; `interact` in a rest area cancels a channel (rule 9) | Save points |
| Rooms and transitions | None | A door or exit taking over cancels a channel, meter kept (rule 9); a room change leaves the meter alone | Rooms and transitions |
| Pause and menus | Out | The `heal_mode` option, the `heal` controls row | Pause and menus (Open Question 14) |
| HUD | Out | The data contract in `design/ux/healing-presentation.md`: `heal_meter`, `meter_capacity`, `heal_progress`, `usable`, the signals and the meter-change cause | HUD (R9); provisional |
| Hit feedback and effects | Out | A fill pulse, a ready cue, the heal effect | Hit feedback (R8); provisional |

## Formulas

Values are data (a `HealingConfig` resource), never constants in code. The figures they act on come from the attack data (damage 8-30, charged heavy x2), the player config (`max_health` 100, up to 180 with collectible upgrades) and the enemy and boss data. Starting values approved by the owner on 2026-11-22. Every variable below was worked at its minimum, maximum and 0 in the fifth review.

### F1. Meter fill and capacity

`heal_meter' = min(heal_meter + max(damage, 0), meter_capacity)`, with a non-finite `damage` adding nothing

`meter_capacity = max(capacity_floor, meter_cost_ratio x heal_share x max_health)`

When max health changes (a collectible step completes) the meter keeps its fraction: `heal_meter' = heal_meter x new_capacity / old_capacity`, so a full bar stays full and a half bar stays half (a step is skipped if `old_capacity` is 0). **[Rec; Owner, 2026-11-23, for the derived capacity]**

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| heal_meter | float | 0 to `meter_capacity` | calculated | The meter before the hit; 0 at a new game, a Continue and a death |
| damage | float | 8-60 | Combat `hit_landed` | The hit's base damage, with the charged heavy's x2, before the guarded, finisher and edge multipliers |
| meter_capacity | float | 84 to 720 | calculated | 120 at 100 max health and the defaults, 216 at 180 |
| meter_cost_ratio | float | 2.8-10, starts at 4.0 | data | Fill points per HP restored (0.25 HP per fill point at 4.0, the same at every max health). The lower bound is the capacity floor at the defaults (below 2.8 the floor applies). The upper bound is about 6 s of perfect light combos per heal at the defaults (300 / 49), the longest a heal should cost in a boss fight **[Rec]** |
| capacity_floor | float | 60-120, starts at 84 | data (validated) | The lowest capacity: two combos (84), above a charged heavy (60). At 0 or below "full" would always be true and fraction-keeping would divide by zero, so `validate()` covers it |
| max_health, heal_share | float | 100-180, 0.20-0.40 | F2 | Read as in F2 at the moment the meter fills or its capacity is shown |

**Output range:** 0 to `meter_capacity`. **Example:** meter 100, a charged heavy (30 x 2 = 60): `min(100 + 60, 120)` = 120, 40 lost. At 180 max health the capacity is 216. A first combo from empty: 10, 22, 42.

### F2. Heal amount and start deficit

`health' = min(health + heal_share x max_health, max_health)`

`start_deficit = max(1, min(start_deficit_share x heal_share x max_health, start_deficit_cap))`

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| health | float | above 0 up to `max_health` | Health | Health when the channel completes; a heal never starts at 0 or at full |
| max_health | float | 100-180 | collectible upgrades F2, registry `max_health_derived` | Read at completion, never copied |
| heal_share | float | 0.20-0.40, starts at 0.30 | data | Below 0.20 a heal is too small to be worth a planted second; at 0.40 on 180 max health it is 72, just under two slams (80); above about 0.44 it is more than two slams |

**Output range:** `heal_share x max_health`: 30 at 100 max health, 54 at 180, 20 to 72 across the ranges; the cap makes the gain smaller near full health. A heal is 30 HP of a 40-damage slam at the start and 54 HP at full upgrades (Open Question 6). **A minimum-deficit heal wastes more:** at the 15 HP threshold a 30 HP heal restores 15 (50% wasted) and burns 120 fill (8.0 per HP); at 180 max health the threshold is 20 of 54 (63% wasted). The same cost per HP at every max health holds for full heals only. **Example:** health 70 of 100: 100; health 80: capped at 100; at 180 max and health 90: 144.

### F3. Hits per heal and the boss-cycle check

A tuning check, not a runtime calculation.

`hits_per_heal = ceil(meter_capacity / mean_hit_damage)`
`meter_at_stagger = min(start_meter + guard_fill, meter_capacity)`, where `start_meter` is 0 if the banked heal was spent in the guard phase (it needs a full meter and a safe 1.0 s), else `carry_in`; a bar carried in full and not spent wastes the whole guard phase's fill
`t_full = max(0, (meter_capacity - meter_at_stagger) / fill_rate)`
`stagger_heals = max(0, floor((stagger_time - t_full + meter_capacity / fill_rate) / (channel_time + meter_capacity / fill_rate)))` (channels are serial and each needs a full refill; at `fill_rate` 0: 1 heal if the bar is already full and `stagger_time >= channel_time`, else 0)
`cycle_heals = guard_heals + stagger_heals`, with `guard_heals` 1 when the meter is full at the start of the guard phase and is spent in a safe 1.0 s there. **Not a target**
`heal_nominal = heal_share x max_health`; `heal_wasted = heal_nominal - heal_effective`; `heal_ratio = heal_effective_per_cycle / boss_damage_taken_per_cycle` is logged, never a target. Health cannot exceed max, so `heal_ratio` is at most about 1 and **cannot detect a heal that is too strong**; the playtest reads `heal_wasted`, how often a full bar sits unusable, the heal's timing, and heal income against the boss's damage budget (Open Question 24).

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| mean_hit_damage | float | 8-60 | calculated | 14 for light combos (10, 12, 20), 30 for uncharged heavies |
| carry_in | float | 0 to capacity | calculated | The meter at the start of the guard phase: 0 (spent) or full (not) in steady play |
| guard_fill | float | 60-120 | calculated | Fill from a full guard to the breaking hit. **Three paths:** 106 for steady light combos (8 hits, `guard-break.md` F2); 120 for four uncharged heavies; 60 for a charged heavy, which breaks the guard in one hit |
| fill_rate | float | 0 upward | estimated | About 49 per second for light combos (a 3-hit combo of 42 in about 0.86 s). **An estimate, not measured**; pogo about 20/s |
| stagger_time | float | 2.5 s default, 4.0 s boss | guard config | Hits do not extend it |

**Output range:** `hits_per_heal` is 2 (two charged heavies) to 15 (pogo at 8) at the defaults, up to 90 across the whole capacity range (720 / 8). `cycle_heals` and `heal_ratio` have no target band **[Owner, 2026-11-22: determined by play]**.

**Example 1, light-combo break** (guard breaks on the 8th hit, `guard_fill` 106, stagger 4.0 s, 100 max health). *Banked heal not spent (carry_in 120):* the 106 is lost, `stagger_heals` = floor((4.0 + 2.45) / 3.45) = 1: **1 heal per cycle**. *Spent in the guard phase (carry_in 0):* full 0.29 s into the stagger, the first channel ends at 1.29 s, leaving 2.71 s, less than the 3.45 s a second needs: with `guard_heals` 1, **2 heals per cycle**. But after one slam (40) the guard-phase heal takes health 60 to 90, and the stagger heal then has 10 missing, below `start_deficit` (15), so it cannot start.

**Example 2, charged-heavy break:** `guard_fill` 60, full 1.22 s in; the player heals and refills about 88 in the remaining stagger; next cycle the meter is min(88 + 60, 120) = 120 (28 lost): the path alternates 1 and 2 heals, **about 1.5 sustained**.

**Supported max health is 100 to 180 (Open Question 18).** At 180 (capacity 216) a stagger heal from empty runs from 2.2 to 3.2 s of 4.0 s on the light path; on the charged path it fits only while capacity is at most 207 (max health at most 172 at a 4.0 s stagger, at most 111 at 2.5 s). Collectible upgrades owes a cap at 180; a higher max health breaks F1 to F3 and registry `heal_amount`.

### Values (`HealingConfig`)

| Value | Starts at | Range | Used by |
|-------|----------:|-------|---------|
| `meter_cost_ratio` | 4.0 | 2.8-10 | F1 |
| `capacity_floor` | 84 | 60-120 | F1. Two combos (84), above a charged heavy (60); at 40 one combo filled the bar |
| `heal_share` | 0.30 | 0.20-0.40 | F2. Below 0.20 a heal is not worth a planted second; at 0.40 on 180 max health it is 72, just under two slams |
| `channel_time` | 1.0 s | **0.7-2.0 s** | Rules 7, 8. **At or below about 0.65 s a heal started inside the invulnerability window completes entirely inside it (rule 10) and can never be punished, so the floor is 0.7 s.** At 1.0 s a heal after a strike ends 0.6 to 0.9 s before the next wind-up (rule 12); it reaches the next wind-up above about 1.6 s and the next strike above about 2.4 s. If the heal is too safe, raise it toward 1.5 s before changing the boss (Open Question 7) |
| `start_deficit_share` | 0.5 | 0-1.0 | Rule 6. At 0 a heal starts at 1 HP missing and spends the whole bar for it; at 1.0 it starts only when a whole heal fits, up to the cap |
| `start_deficit_cap` | 20 | 5-40 | Rule 6. 20 is the smallest boss hit, so any boss hit enables a heal; above 40 the cap does nothing at the default share |
| `press_buffer` | 0.12 s | 0-0.2 s | Rule 14. Equal to the jump buffer; above 0.2 s a press can start a heal the player no longer wants |
| `heal_deceleration` | 2000 px/s² | 500-3000 | Rule 7. The charge skid's value |
| `stick_cancel_deadzone` | 0.5 | **0.5-0.9** | Rule 9, toggle mode. The floor is the project's input deadzone: a lower value would cancel on drift the input layer already ignores |

`HealingConfig.validate()` returns the name of every value outside its range (all nine above). The caller reports a non-empty result through an injected callable and clamps each value on a copy of the loaded config, never on the shared one (AC-24; the build notes). **[Rec]**

**Feedback loops:** one positive loop, intended: a heal keeps the player alive longer, so they land more hits and earn more heals. Its dampers are that a heal restores at most the missing health and a boss's health is finite, but **neither damps heal strength**: effective healing cannot exceed damage taken by construction. On paper heal income while attacking is about 12 HP/s (0.25 HP per fill point x 49 fill/s), about 9 to 10 with channels, against about 34 HP of unavoidable boss damage per 7.7 s guard-break cycle that does not scale with max health: **an owner decision for Bosses (Open Question 24), not a Healing number.** A heal at 180 max health costs 216 fill against 120 at 100. **Seam:** collectible upgrades F3 raises sword health damage by up to x1.3; this system reads the damage **before** it, so edge steps do not make a swing fill faster, though fill per kill falls by up to about 23%.

## Edge Cases

Rules 6 to 15 state the main outcomes; this section lists only what they leave open. Every case is a **[Rec]**; nothing is built yet.

**Starting and ending a heal**
- **Refusals (rule 6):** a press with the meter low plays the meter cue, with health too high the health cue, in a blocked state nothing; never buffered unless the state ends on its own.
- **Pressed during a door transition or a rest:** the controller has locked input, so the press never reaches the heal: no start, no cue.
- **Inside the invulnerability window with the hurt lock over:** a heal may start; its first 0.63 to 0.65 s are protected (rule 10).

**During the channel**
- **A hit lands on the completion tick:** the hit resolves first, no heal, meter 0 (rule 15).
- **Max health changes mid-channel:** F2 reads max health at completion; the capacity is recomputed and the meter keeps its fraction. If the step refilled health to max, completion heals nothing, spends nothing and ends as `heal_cancelled(&"full_health")`.
- **The Seeker dies mid-channel:** cancelled; the meter is zeroed on `revive`. **Dies on the tick it lands a hit:** the meter is zeroed on `revive` regardless.
- **Paused, or hit-stop:** the timer counts game time, so a pause freezes it and neither completes nor cancels it; the Player stays pausable (mechanism: ADR-0003).

**Filling**
- **A pogo on a foe** adds 8, the lowest fill of any attack; on a hazard, breakable or pane it adds nothing.
- **The meter is full and more hits land:** the excess is lost, no cue.
- **`damage` is 0, negative or not finite:** it adds nothing; the meter never falls from a hit.
- **`validate()` finds a value out of range:** it is reported and clamped; the game keeps running.

**Boss and balance**
- **Healing in a stagger (4.0 s):** allowed and nearly free until the last stage (rule 12); the log reads it.
- **The fight resets after a death:** the next attempt starts with an empty meter.
- **A boss stage change mid-channel:** it cancels nothing here (Open Question 2).
- **Farming (known loop, accepted for now):** a foe rebuilt on room re-entry (rooms rule 12) can be killed again to fill the meter, as in Hollow Knight; a rest area is never farmed (save points rule 3a). On paper one rebuilt foe yields 6 to 12 bars a minute, but health gained is bounded by the missing HP (about 3.3 heals from empty), so it is a rest-point substitute, not unbounded income. Trigger: Open Question 3.

## Dependencies

**Upstream (Healing needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Combat | Hard | `hit_landed(target, attack, damage)` once per target per swing, `damage` as in F1; a test accessor for a pending attack (AC-16d) | Yes (`combat.md`) |
| Player controller | Hard | A `heal` action (keyboard A, gamepad B; Open Question 1), `Player.State.HEAL` with its own handler and cleanup, the jump-buffer rule, coyote refresh in `HEAL`, a completion node that runs after every hitter (ADR-0003), `revive` resetting the heal, the landed-hit, death and `revive` signals, the `heal_mode` option | Yes (`player-controller.md`) |
| Health, damage and death (R6) | Hard | **Not in code today:** `PlayerHealth` has `configure()`, `take_damage()`, `tick()`, `reset()` and the `damaged` and `depleted` signals only. Needed: `heal(amount)` raising `current` by at most `max_health - current`, returning the amount applied, doing nothing at 0 and **not** clearing invulnerability (`configure()` and `reset()` do); a `healed` signal; `set_max_health(new_max, refill)`. The meter is a pure component beside `health`, never in `PlayerState`; Continue and new game need an explicit reset because `revive` has no callers yet | No (`src/player/player_health.gd`) |
| Collectible upgrades | Soft | The derived max health, **capped at 180** (Open Question 18); the pre-edge damage seam below | Yes (`collectible-upgrades.md`) |
| Enemies | Hard | Foe hurtboxes reporting `hit_landed`; the new group `foe` on enemy and boss hurtboxes and on the `TrainingDummy`, not on `HitTarget`; a dead foe reports nothing; every `take_hit` caller acts at priority 0 or lower (ADR-0003) | Yes (`enemies.md`) |
| Rooms and transitions | Soft | A door or exit takes over and cancels a channel (rule 9); `interact` is shared with doors | Yes (`rooms-and-transitions.md`) |

**Downstream (these need Healing):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Bosses | Hard | The meter values and F3's bounds; **a pattern or stage element that punishes a planted Seeker** (Open Question 12); a damage budget (24); the stage-change rule (2); a telegraph sound (25); whether stage-3 adds feed the meter (17) |
| HUD (R9) | Hard | The data contract in `design/ux/healing-presentation.md` |
| Hit feedback and effects (R8) | Soft | The fill pulse, the ready cue and the heal effect |
| Pause and menus | Soft | The `heal` row on the controls page, a default binding that avoids Escape and Start, the `heal_mode` option, and `flash_limit` (3 per second) |

**Provisional interfaces.** Health (R6), the HUD (R9) and Hit feedback (R8) have no GDD.

**Seam (collectible upgrades F3 against Combat).** If the x1.3 edge multiplier is applied before Combat emits `hit_landed`, edge steps would raise the fill by up to 30%. This GDD reads the damage before it; Combat or Collectible upgrades must keep the pre-edge value available on the signal (Open Question 4).

**Bidirectional check (2026-11-23).** Bosses, Combat, Guard-break, Player controller, Enemies, Collectible upgrades, Save points and Pause and menus name Healing. **Owed (Open Question 15):** Player controller (states, Values, inputs), Pause and menus (`heal_mode`), Enemies (`foe`), Bosses (pattern, budget, stages), Rooms and transitions (a Healing row for the door take-over), `design/accessibility-requirements.md`, which does not exist.

## Visual/Audio Requirements

The full table (events, visuals, audio direction, limits), the flash-limit rules, the animation clips and the **HUD data contract** are in `design/ux/healing-presentation.md`. Gameplay fixes only this: the ready cue fires only on a 0-to-full crossing caused by a landed hit; the swell and glow follow `heal_progress` (a pause freezes them) and stop within 80 ms of every exit except completion, which hands over to the completion swell; every audio cue has a visual twin; the heal uses Bone Pale only; its light effects count toward registry `flash_limit` together with the invulnerability blink and the hurt effect. Open: a boss telegraph sound outside the swell's band (Bosses), mix and loudness (Audio GDD, Open Question 19).

> 📌 **Asset Spec** — after the art bible is approved, run `/asset-spec system:healing` for per-asset descriptions, dimensions and generation prompts.

## Game Feel

**Feel reference.** Hollow Knight's Focus: a held, planted commitment that a hit breaks, losing what was built up (here the whole meter). Letting go is free, so a player who reads a telegraph and backs out loses only the second.

| Target | Value | Why |
|--------|-------|-----|
| Press to `HEAL` | the same physics tick | The wait is the channel, not input lag |
| First visible response | within 1 tick | The player sees the commitment begin |
| Cancel to control | By an action press, letting go, a toggle second press or stick push: 0 s. After a hit: the hurt lock | Letting go is always free; a hit costs the bar |
| Completion to control | the next physics tick | The heal is the reward; no extra lock |
| Ready cue | the tick the meter reaches capacity | The player learns a heal is banked without looking away |
| Press buffer | up to `press_buffer` before the Seeker can heal | After a hit or a swing the first instinct is to press heal; losing it feels like a bug |

**Weight.** A planted 1.0 s with no armour. Against the current boss the only risk is a shockwave already in flight (rule 12); in a stagger a heal is nearly free. A heal adds no hit-stop or screen shake. Checked in the owner's playtest (AC-26); "feels earned" is not a threshold.

## UI Requirements

Detail is in `design/ux/healing-presentation.md`: a meter bar beside health with banked and banked-but-not-usable states and refusal cues; channel progress on the Seeker; `heal_mode` (hold or toggle) on an options page and in `design/accessibility-requirements.md` (Open Question 14); `heal` on the read-only controls page (keyboard A, gamepad B). **📌 UX Flag:** run `/ux-design` for the HUD before writing epics.

## Cross-References

| Document | Fact or rule referenced | Used for |
|----------|-------------------------|----------|
| `design/gdd/combat.md` | `hit_landed`; damages 8-30; charged heavy x2; the pogo is the down attack (8) | F1, rules 2, 3 |
| `design/gdd/guard-break.md` | Guarded hits x0.25 (boss x0.2); a steady 3-hit combo breaks the guard on the 8th hit (F2); stagger 4.0 s | Rule 2, F3, AC-3, AC-23 |
| `design/gdd/player-controller.md` | Hurt lock 0.35 s, invulnerability 1.0 s, states, `revive`, jump buffer 0.12 s, max health 100 | Rules 6, 9, 10, F2 |
| `design/gdd/bosses.md`, `enemies.md` | Planned three stages "tuned together with healing"; pattern gaps 2.4-3.0 s; enemy hit damage 10-30, enemies rebuilt on room entry | Rules 3, 12, F3, farming |
| `design/gdd/collectible-upgrades.md` | Derived max health (F2), a health step refills health, the edge multiplier (F3) | F2, Dependencies seam |
| `design/gdd/save-points-and-save-load.md` and `world-state.md` | A rest heals to full; no enemy near a rest area (rule 3a); health is not in the saved record | Rule 5, farming |
| `design/gdd/rooms-and-transitions.md` | A door or exit takes over; a room change keeps the meter | Rule 9 |
| `design/gdd/pause-and-menus.md` | Fixed controls (rule 17), reserved inputs (rule 19), flash reduction (rule 14), registry `flash_limit` | Dependencies |
| `design/ux/healing-presentation.md`, `design/art/art-bible.md`, `design/gdd/game-concept.md` | Presentation, HUD contract; art principles 1-3; core mechanic 6, anti-pillar 2 | Presentation, Overview |


| `docs/architecture/adr-0003-heal-tick-order.md` | The completion node, the `take_hit` caller rule, hit-stop, resume | Rules 14, 15 |
| `docs/architecture/healing-implementation-notes.md` | Component seam, cancel dispatch, config clamp, clips | Stories |

## Acceptance Criteria

**Conventions.** Defaults are the starting values at `max_health` 100 (capacity 120, `heal_share` 0.30, `channel_time` 1.0 s, `start_deficit` 15, `press_buffer` 0.12 s, `run_speed` 140), run against a pinned fixture `tests/fixtures/healing_config_test.tres` (a boss fixture pins the guard values for AC-23). Tick 0 is the press tick, a tick is 1/60 s, the timer after tick N is N x `delta`, and float comparisons use a tolerance. **[Logic]** is a unit test of the pure meter or channel component; **[Integration]** uses real nodes and the physics server (a hitter's overlap is established one step earlier; pause tests use a real paused tree). Criteria 25, 27, 31 and 40 are in `design/ux/healing-presentation.md`. Every "no cue" assertion has a positive control. **Not closable by Healing's story:** AC-9b, 9c, 20c, 32b (they close with the Continue, new game, rest and room-change flows) and AC-37 (it needs the boss stages). The first built story keeps the standard's launch-and-observe evidence: a retained screenshot of the placeholder heal pose in the `TrainingDummy` room in `production/qa/evidence/`.

- **AC-1 Fill [Logic].** Meter 0; attack1, 2, 3 land (10, 12, 20): 10, 22, 42. **1b:** a pogo (8) on a foe adds 8.
- **AC-2 Cap [Logic].** Meter 100, a charged heavy (60): 120; a further hit leaves 120 and `meter_full` was emitted exactly once across both.
- **AC-3 Guarded hits fill in full [Integration].** Boss GUARDED, meter 0, attack1 lands: the meter is 10 and the boss's health fell by 2.0 (within tolerance). **3b:** a finisher (attack3 on a BROKEN foe) fills 20, not 40.
- **AC-4 Only foes feed it [Integration].** Meter 30; the down attack hits (a) a hazard, (b) a breakable, (c) a pane, (d) a `HitTarget`: 30 each. **4b:** an enemy, a boss hurtbox or the `TrainingDummy` adds the hit's damage.
- **AC-5 Killing blow [Integration].** A foe with 5 health, meter 0, attack1 kills it: the meter is 10, added once.
- **AC-6 One swing, two foes [Integration].** Two foes under one attack1 swing, meter 0: 20.
- **AC-7 Bad damage [Logic].** Meter 50; damage 0, then -5, then NaN: 50 after each.
- **AC-8 No decay [Logic].** Meter 60 at full health: after 3600 ticks with no hit, 60. **8b:** a hit then raises it.
- **AC-9 Resets.** Meter 80: **9a [Logic]** a death and `revive` leave 0; **9b [Integration]** a Continue and a new game each leave 0; **9c [Integration]** a rest and a room change each leave 80; **9d [Logic]** the meter is not in the saved record.
- **AC-10 Not ready [Logic].** Meter full unless stated; `heal` pressed: **10a** meter 119: no `HEAL`, the meter cue; **10b** health 86 of 100: no `HEAL`, the health cue; **10c** health 85: `HEAL` starts; **10d** in each of `CROUCH`, `CLIMB`, `WALL_SLIDE`, `DASH`, `GRAPPLE`, `LEDGE`, `DEAD` with health 70: no `HEAL`, no cue; in `AIR`, `ATTACK`, `HURT` the press is buffered and expires if held; **10e** meter 50, health 100: the meter cue only; meter 50 in `AIR`: the meter cue; meter 120, health 100 in `AIR`: the health cue; meter 120, health 70 in `CROUCH`: no cue; **10f** max 180: health 161 refused, 160 starts; **10g** `start_deficit_share` 0: health 100 refused, 99 starts; **10h** a jump press on the same tick: the jump starts, no heal; **10i** a press during the landing animation starts at once.
- **AC-11 Fresh press and buffer [Logic].** **11a** `heal` held 30 ticks through an attack: no heal when it ends; released and pressed again: `HEAL` starts. **11b** (hold) pressed 7 ticks before the lock ends and still held: starts on the first `GROUND` tick; released first, or pressed 8 or more ticks before: nothing. **11c** the meter reaches capacity 3 ticks after a press: no heal. **11d** (toggle) a tap 5 ticks before the lock ends: the heal starts when it ends. **11e** `press_buffer` 0 still starts on the press tick.
- **AC-12 Planted [Integration].** Running at `run_speed`, full meter, health 70, `heal` pressed: horizontal speed is 0 by tick 5, displacement from the press at most 8.5 px, and from tick 6 x does not change (assert x only).
- **AC-13 Completion [Logic].** Meter 120, `heal` held to tick 60: **13a** health 70: 100, meter 0, `GROUND` at the end of tick 60 and control on tick 61; **13b** health 50: 80; **13c** max 180, meter 216, health 90: 144, meter 0; **13d** health 85: 100.
- **AC-14 Not before time [Logic].** After tick 59 the meter is 120 and health unchanged; the heal applies on tick 60 exactly. **14b:** with variable deltas summing to 1.0 s (0.3 + 0.7) it completes on the tick the sum reaches 1.0.
- **AC-15 Letting go [Logic].** **15a** (hold) a release on any tick 1 to 59: `GROUND` that tick, health unchanged, meter 120. **15b** a release on tick 60 completes the heal. **15c** (toggle) a second press at tick 30 cancels; on tick 60 it completes. **15d** a cancel at tick 30 then a fresh press: the heal completes 60 ticks after the new press.
- **AC-16 Action cancels [Integration].** A channel at tick 30: **16a** jump, **16b** dash, **16c** grapple (once owned): the channel ends that tick, the action starts that tick, meter 120, health unchanged; **16d** attack: `GROUND` that tick with a pending attack in Combat (a tap swings on release, a hold becomes the heavy); **16e** a dash on cooldown and a grapple with no anchor: the channel continues; **16f** on one tick the order grapple, dash, door interact, attack, jump wins, adjacent pairs table-driven.
- **AC-17 A hit cancels, no protection [Integration].** **17a** a channel at tick 30 and a foe attack of 15: health falls by 15, meter 0, no heal, `HURT`. A first hit lands on absolute tick 0 (hurt lock 21 ticks, invulnerability 60 ticks) and a fresh press on tick 22 starts the channel, so **the protected window ends on channel tick 38** (absolute 60). **17b** a hit at channel tick 37: `take_hit` returns false, the state is still `HEAL`, meter 120, health unchanged, timer running. **17c** a hit at channel tick 38: it lands, `HURT`, meter 0. **17d** a heal started after the window has fully ended is exposed from tick 0.
- **AC-18 Hit and completion on one tick [Integration].** A channel and a hitter whose `take_hit` runs on tick 60: the hit lands first, no heal, meter 0, `HURT`. One test per caller (**18a** enemy melee, **18b** boss melee, **18c** boss shockwave), each with the hitter before and after the Seeker in the tree. **18d** a static check fails on any `take_hit` caller not on the allowlist (enemy, boss, shockwave) and on any deferred call (ADR-0003). **18e** a release on tick 60 completes the heal; a jump press on tick 60 cancels it and the jump starts.
- **AC-19 Death [Logic].** **19a** a channel and a killing hit: cancelled; after `revive` the meter is 0 and the timer reset. **19b** the Seeker lands a hit and dies on one tick: the meter is 0 after `revive`.
- **AC-20 Interact takes over [Integration].** **20a** a channel in a door area, `interact`: the door takes over, the meter kept; **20b** `interact` with no door or rest area is ignored; **20c** the same in a rest area.
- **AC-21 Max health changes mid-channel [Logic].** Max 100 to 120 with health set to 120 during a channel: at completion no heal, `heal_cancelled(&"full_health")`, no `heal_completed`, the meter kept (144, the fraction kept).
- **AC-22 Pause [Integration].** A channel at tick 36, paused 300 frames with `heal` held, then resumed: the heal completes on the 24th tick after the resume, and a static check finds no scene-tree timer or real-time clock in the heal path.
- **AC-23 Boss cycle arithmetic [Integration].** Default config and a full-guard boss fixture: attack1, 2, 3, 1, 2, 3, 1, 2 break the guard on the 8th hit with the meter at 106; attack3 in the stagger gives 120. **23b:** meter 0 and a charged heavy: 60 at the break. **23c:** four uncharged heavies: 120.
- **AC-24 Config validation [Logic].** `meter_cost_ratio` 1.0, `heal_share` 0.6, `channel_time` 0.5, `start_deficit_cap` 0, `capacity_floor` 0 and `stick_cancel_deadzone` 0.2: `validate()` returns those six names, `report` receives them, and each value is clamped on a duplicate (2.8, 0.40, 0.7, 5, 60, 0.5) with the cached resource unchanged. **24b:** the boundary values of every range return an empty list. **24c:** just outside a bound (`meter_cost_ratio` 2.79, 10.01; `channel_time` 0.69) returns that name.
- **AC-26 Boss-cycle log and playtest.** **26a [Logic]** a `HealLog` writer with an injected tick clock writes the header `tick,event,source,max_health,attack_id,amount,lost,health,meter,spawn_id` and one row per event (`fill`, `meter_full`, `heal_started`, `heal_completed`, `heal_cancelled` with the meter lost, `damage_taken`, `kill`, `died`, `guard_broken`, and `stage_changed` once stages exist); derived figures are computed at report time, never asserted. **26a-int [Integration]** one full heal on the `TrainingDummy` writes one `heal_started` and one `heal_completed`. **26b [Playtest, advisory, read at the vertical-slice `/gate-check`, never a story gate]** the owner plays three attempts against the one-stage boss; a report in `production/qa/evidence/` holds the log, heals earned and spent per cycle, the F3 metrics at 100 and 180 max health, and a yes or no on "felt earned". **"Felt risky" and "felt fair" are recorded only once the boss pattern of Open Question 12 exists; until then they are not applicable.** No number is a pass-fail threshold **[Owner, 2026-11-22]**.
- **AC-28 Catch-all and the jump buffer.** **28a [Logic]** a channel at tick 30: crouch, climb, bow, cast, rapid fire, map, and in hold mode a stick push: the channel continues. **28b [Integration]** jump at tick 30: the channel ends and exactly one jump happens. **28c [Integration]** a jump pressed in a state that cannot use it 3 ticks before `GROUND` with the heal press buffered: the heal start clears the jump buffer and the state is still `HEAL` after its first tick. **28d [Integration]** a hit cancels on the tick a jump is pressed: no jump fires.
- **AC-29 Stick cancel [Integration].** **29a** (toggle) a fresh horizontal push at tick 30 cancels free: `GROUND`, meter kept, no restart while the button is held; **29b** (hold) the same push does nothing; **29c** a direction already held at the press does not cancel until it has returned inside the deadzone; **29d** an Up push never cancels; **29e** a push on tick 60 lets the heal complete.
- **AC-30 Edge slide [Integration].** The skid carries the Seeker off a ledge: `heal_cancelled(&"edge")`, `AIR`, meter kept, a coyote jump works, and the Seeker falls on the tick after the floor is lost.
- **AC-32 Locked input [Integration].** **32a** during a door transition, **32b** during a rest: `heal` starts nothing, the meter is unchanged, no cue.
- **AC-33 Start tick and the spent press [Logic].** **33a** with every condition holding, after the press tick the state is `HEAL`, `heal_started` was emitted once and `heal_refused` was not. **33b** (toggle) a second press at tick 30: `GROUND`, no new channel while the button stays held. **33c** a dash cancel at tick 30 with `heal` still held: no restart until a fresh press.
- **AC-34 Fill during a heal [Logic].** A channel, meter 60, an injected foe hit raises the meter by its damage and the channel continues.
- **AC-35 Toggle mode [Integration].** **35a** pressed at tick 0 and released at tick 1: the channel continues and completes at tick 60. **35b** a second press at tick 30 cancels free. **35c** a second press on tick 60 completes the heal. **35d** a press that fails to start (meter 119) does not arm the toggle: the next press with a full meter starts a heal.
- **AC-36 Release while paused [Integration].** A hold-mode channel, paused, `heal` released during the pause, resumed: the channel is cancelled on the first tick after the resume, and a press on that tick is not a heal press.
- **AC-37 Stage change [Logic, pending: blocked until the stages exist and Open Question 2 is settled; owner: Bosses].** A stage change emitted mid-channel with meter 80 and no hit: the meter is still 80, the channel is not cancelled and no `heal_cancelled` is emitted.
- **AC-38 Capacity derivation [Logic].** Capacity is 120 at max health 100, 216 at 180, never below 84 (`heal_share` 0.20 and ratio 2.8 at 100 give 56, so the floor applies). Max health 100 to 120 with the meter at 120: capacity and meter 144; at 60: 72. With old capacity 0 the rescale is skipped.
- **AC-39 Signals [Logic, recording listener].** A hit taking the meter from 119 to 120 emits `meter_full` once, and none on a further hit, a `revive`, a load, a rest or a room change. A channel emits `heal_started` on tick 0 and exactly one of `heal_completed(effective)` or `heal_cancelled(reason)` on its last tick for every exit, the reason one of `release`, `hit`, `death`, `door`, `rest`, `edge`, `jump`, `dash`, `grapple`, `attack`, `stick`, `full_health`. `heal_progress` is 0.5 at tick 30 and frozen while paused. Ten refused presses (meter not full) emit `heal_refused(&"meter")` ten times; a blocked-state press emits nothing (positive control: the same press in `GROUND` emits).
- **AC-41 Shipped config [Logic, advisory smoke check].** The shipped healing config equals the documented defaults and passes `validate()`.
- **AC-42 Test nodes out of shipped rooms [static].** No shipped scene contains a `TrainingDummy`.

**Gaps found by the lens (not blocking):** rule 11 has no source today (AC-34 injects one); rule 13 cannot be tested until the stages exist (AC-37); `tests/unit/healing/` and `tests/integration/healing/` do not exist yet, nor does a test runner (gdUnit4); the pre-edge damage seam (Open Question 4) has no criterion until an edge step can complete.

## Open Questions

| # | Question | Owner | Resolve by |
|---|----------|-------|------------|
| 1 | **Default bindings for `heal`: keyboard A, gamepad B** [Owner, 2026-11-23]. A is also `move_left` today, so keyboard A needs arrows-only movement (which moves `interact` and `crouch` off W and S) and `pause-and-menus.md` rule 17 follows. Gamepad B needs `interact` to drop B and B to be `cancel` only inside menus and the map (rule 19, done). Neither change is made by this GDD (Open Question 15); until they land the first story must not register `heal` on A while `move_left` holds it. | Owner, Player controller, Pause and menus | Before the controller story |
| 2 | **What a boss stage change does for the heal and the stagger.** Rule 13 says it does not touch the meter. Recommended: the change keeps the full 4.0 s stagger and gives no refill. | Owner | When the boss stages are built |
| 3 | **Farming.** A rebuilt foe is a heal source, and with the meter at 0 after a death a retry with a banked heal needs farming. Ship a RAM-only kill count per spawn point (reset by a rest, a death and a Continue; logged by AC-26a); if a playtest shows 3 or more kills of one spawn since the last rest, ship a fill multiplier of 1.0, 0.5, 0.25, then 0 for the nth kill. | Owner | After the first playtest |
| 4 | **Pre-edge damage on `hit_landed`** (Dependencies seam): Combat or Collectible upgrades keep the pre-edge value available. No edge step can complete in region 1, so it can wait. | Next `/design-review` of Combat or Collectible upgrades | Next revision |
| 5 | **Heal in the air** is not allowed (rule 6). Does a planted ground-only heal fit the movement-first pillar? | Owner | First playtest |
| 6 | **Meter upgrades.** Whether a collectible raises capacity or heal share, or adds a second bar; a heal's worth in boss hits grows 1.8 times from 100 to 180 max health while its cost per HP stays the same. | Owner | Alpha |
| 7 | **Channel time against the boss's gaps** (rule 12): raise toward 1.5 s if the heal is too safe, before changing the boss. | Owner, with the boss stages | Boss tuning round |
| 10 | **Heals per cycle and the heal ratio** (F3). The log reads `heal_wasted`, how often a full bar sits unusable under `start_deficit`, heal income against damage taken, and the 0.63 s protection a post-hit heal gets. | Owner | First boss playtest with the meter logged |
| 11 | **Guarded hits fill at full**, the largest source of easy heals in a stagger. Kept as the owner decided; revisit with the log (half fill, or fill from health damage dealt). | Owner | After the first heal-ratio log |
| 12 | **A boss pattern that punishes a planted Seeker (required, owner decision 2026-11-23).** The stake belongs to the boss. The boss needs a pattern or stage element that strikes inside the channel window (a short-wind-up strike, a tracking projectile, a delayed second strike, or the planned stage-2 falling hazards and stage-3 adds), and a stagger stake that healing forfeits. **The tuning round must state which case it punishes:** a heal started after a hit (about 0.35 s exposed) or a fresh heal (1.0 s exposed). Healing's "risky" sign-off depends on that boss story. Listed in `bosses.md` Dependencies; not yet written. | Owner, with Bosses | Boss tuning round |
| 13 | **Fill consistency.** Overkill adds up to one hit's damage per kill, and a guarded boss hit fills 5 times the health it removes. Cap each hit's fill at the target's remaining health? | Owner | With Open Question 11 |
| 14 | **The `heal_mode` option** needs a row in Pause and menus' options table and a line in `design/accessibility-requirements.md`; neither exists. | Pause and menus, accessibility | Before the controller story |
| 15 | **Other GDDs and code owe Healing rows.** Player controller (the `HEAL` state, `heal`, `heal_deceleration`, `stick_cancel_deadzone`, the completion node, the jump-buffer rule, arrows-only keyboard movement), Pause and menus (`heal_mode`; the controls row is done), Enemies (the `foe` group), Bosses (the punishing pattern, the damage budget, stage rules, a telegraph sound), Save points' rest glyph. Each needs the owner's go-ahead (coordination rule 5). | Each GDD's next revision | Next revision of each |
| 17 | **Heal economy.** Applied (owner, 2026-11-23): capacity derived from the heal, `start_deficit` capped, the whole bar spent, a heal may start while invulnerable. **Recommended, owed to Bosses: stage-3 adds do not feed the meter.** Open: a fill bonus for pogo and dash-attack hits, capping a hit's fill at the target's remaining health, whether the stagger heal should cost something. | Owner, economy-designer | After the first heal-ratio log |
| 18 | **Max health beyond 180.** Collectible upgrades allows `health_step` 10 to 30 and `steps_max` up to 6 (max 280) while F1 to F3 and registry `heal_amount` hold for 100 to 180. **Decision [Owner, 2026-11-23]: 100 to 180 is the supported range; Collectible upgrades owes a cap at 180** (for example `health_step` 20 with at most 4 steps). Not yet applied there. | Collectible upgrades | Next revision of that GDD |
| 19 | **Audio owner.** Mix priority, ducking, ready-tone anti-fatigue, a sound per cancel exit, loudness, bus and naming, the audio ACs. | audio-director | Audio GDD (index #25) |
| 22 | **A late-release recovery** was cut for the first build [Owner, 2026-11-23]. If playtests show heal-feinting, add a short recovery with a visible pose and update rules 9 and 15 and AC-15. A hold-mode stick push is held back for the same reason. | Owner | First playtest |
| 23 | **Meter fraction on a max-health change.** F1 keeps the fraction (a full bar stays full); the alternative keeps the raw value. | Owner | First story |
| 24 | **A boss damage budget.** Heal income while attacking (9 to 12 HP/s) is about 3x the boss's unavoidable damage at every max health. Owed to Bosses: a budget (for example unavoidable damage per attempt of 1.2 to 1.5x max health) or a lever on boss-sourced fill that keeps the full-fill-on-guarded-hits rule. | Owner, Bosses | Boss tuning round |
| 27 | **A hit mid-heal empties the meter** [Owner, 2026-11-23]. It gives the heal a stake of its own, but only a boss that can land a hit inside the channel window applies it (Open Question 12). Re-check in the first playtest: a lost bar is a new reason to farm (Open Question 3); the log records `heal_cancelled(hit)` with the meter lost. | Owner | First boss playtest |

*Numbering is kept; rows closed or owned elsewhere were removed: 8 (heal clip and sounds: art and audio, before the heal is built; a missing clip is a hard error), 9 and 20 (meter readout, cues: the HUD and `/ux-design`), 16 (advisory sections: Tuning Knobs is the Values table), 21 (ranged hits: when a ranged attack is designed), 25 (a boss telegraph sound outside the swell's band: Bosses), 26 (the registry's `flash_limit` unit: Pause and menus). Open Question 20's cue list (a buffered press that expires silently, a held-through press, a blocked-state press, why a heal was cancelled) goes to the HUD spec.*
