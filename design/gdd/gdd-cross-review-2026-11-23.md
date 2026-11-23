# Cross-GDD Review Report

- **Date:** 2026-11-23
- **GDDs reviewed:** 15 of 16 system GDDs present.
- **Not read:** `parallax-lighting-and-atmosphere.md`. No pass read it; only its registry entries were checked.
- **Focus:** full (consistency and design theory).
- **Systems covered:**
  - Runtime: player-controller, combat, guard-break, enemies, bosses, healing, collectible-upgrades, ability-gating.
  - World: rooms-and-transitions, terrain-pipeline, level-design, world-state, save-points-and-save-load, grid-map, pause-and-menus.
  - The pillars and anti-pillars come from `game-concept.md`. There is no `game-pillars.md`.
- **How this run differed from the skill's method:**
  - The GDDs total about 1 MB, too much to paste into the agents' prompts, so each agent read its sections itself, by heading.
  - The consistency phase was split across two `game-designer` agents (runtime systems and world systems). A third `game-designer` agent ran the design-theory phase.
  - Both consistency agents hit their turn limit and delivered partial reports. Their NOT CHECKED items are at the end of this report.
  - The main session walked the scenarios (Phase 4).

---

## Consistency Issues

### Blocking (must resolve before architecture begins)

🔴 **C-1: Damage during a rest and on arrival.** `save-points-and-save-load.md` vs `player-controller.md`; both consistency passes found this independently.
- Save points rule 3: "The Seeker cannot be hurt or killed from the accepted up press until the stand-up ends, as during EnterDoor."
- Save points rule 8 says the same "from the death, or the load, until the stand-up ends".
- Save points' Dependencies row asks the Player controller to "block damage".
- `player-controller.md` Damage block: "It does **not** hold in a rest or on arrival: a bench is safe because no enemy can reach it (owner, 2026-11-23)".
- `player-controller.md` AC-20: "A hit in a rest area is not blocked by the controller."
- The two sets of ACs cannot both pass.
- Rooms' hold ends at the fade-in, so 0.10 s of the stand-up is covered by no source.
- The owner decision of 2026-11-23 is newer than the Save points reviews of 2026-11-20.
- Options:
  - (a) Save points drops its block and relies on placement (rule 3 a-c). That placement isn't enforced yet:
    - `rest_area_max_width` has `referenced_by: []`.
    - Rooms' room check has no rest-area checks.
    - Enemies has no leash requirement for rest areas.
  - (b) The controller adds a third block source for RESTING and ARRIVING.

🔴 **C-2: Input bindings are stale against the owner's 2026-11-23 layout.** `pause-and-menus.md` and `save-points-and-save-load.md` vs `player-controller.md` and the registry's `pause_inputs`.
- `pause-and-menus` rule 17 (L76) says Move is "WASD or the arrow keys".
- `pause-and-menus` L82 and L239 put `interact` on "W or the up arrow".
- `pause-and-menus` gives Rapid fire "V / Y" and has no heal row.
- Pause rule 10's menus use WASD. That is a separate context; say so explicitly.
- `save-points` rule 2 binds `interact` to "W, Up, D-pad up and gamepad B". Its AC starts a rest on gamepad B, and its glyph is "B or D-pad up".
- Pause rule 19 reserves B for `cancel`, so Save points' B-rest AC and Pause's AC (`interact` holds no gamepad B) cannot both pass.
- Authoritative: the Player controller owns the action list. Arrows-only movement is the owner's call (2026-11-23).

### Warnings (should resolve, but won't block)

⚠️ **C-3: Rooms' damage hold on respawn, load and fast-travel fade-ins.**
- The controller (Damage block source 2) says Rooms' hold covers "every fade-in after a respawn, load or fast travel".
- Rooms names only the crossing frame and the EnterDoor press; it doesn't say it sets the hold for rule 8 arrivals.

⚠️ **C-4: No GDD admits the heal-to-door or heal-to-rest takeover.**
- Healing rule 9 and AC-20 say a door or rest press during the channel takes over.
- The controller's ENTER_DOOR row requires "on the ground", and Save points rule 2 requires the controller's ground state. HEAL is a separate state.

⚠️ **C-5: The rest-area up-attack suppression isn't in Combat.**
- `combat.md` Input resolution 1 and AC-1 suppress the up attack only on a door.
- Save points rule 2 and its AC (about L252) suppress it in a rest area too.
- Combat has no Save points Dependencies row.

⚠️ **C-6: No GDD owns where the edge multiplier is applied.**
- `collectible-upgrades` says the edge scales every sword attack's health damage (`attack_data.tres` `damage`).
- Combat F1 has no edge term, and `hit_landed` damage "already includes the charged multiplier".
- Healing requires pre-edge damage for the meter fill, and Collectible upgrades L197 agrees.
- Nobody says where the edge is applied. If it scales `attack_data`, the meter fills too fast.
- Options: Combat emits a separate pre-edge damage on the signal; or the edge applies only in the target's `take_hit`.

⚠️ **C-7: Ability gating has stale status text, and the controller is missing rule 19.**
- `ability-gating.md` Interactions, Dependencies and Bidirectional check still say the Player controller and Combat have "no GDD".
- Its rule 19 (ordered gate-anchor targeting: `chain_id`, `chain_step`, `chain_window` 0.6 s, the out-of-order fall-through) needs a controller change.
- That change is absent from `player-controller.md` rule 9, its "Required, not built" table, its Dependencies row and its ACs.

⚠️ **C-8: Healing's requirements aren't in the controller or Enemies.**
- Healing requires these of the controller, and they are absent from `player-controller.md`:
  - `heal_deceleration`
  - `stick_cancel_deadzone`
  - the `HealCompletion` node priority (ADR-0003)
  - the coyote refresh in HEAL
  - the jump-buffer zeroing (AC-28c)
- Healing requires these of Enemies, and they are absent from `enemies.md`:
  - the `foe` group
  - the rule that a `take_hit` caller runs at priority 0 or lower
  - the counted hit-stop restore
- Enemies rates Healing "Soft"; Healing rates Enemies "Hard".
- Healing Open Question 15 is stale against the controller's table.

⚠️ **C-9: One-directional dependency rows.**
- Combat has no Save points row.
- Guard-break, Enemies and Bosses have no Collectible upgrades row.
- Enemies has no Save points row.
- Collectible upgrades has no Player controller row, although F2 uses `base_max_health`.
- Rooms has no Pause and menus row.
- World state rule 1 ("Nothing else is in it") vs Grid map rule 2, which needs revealed cells stored there.

⚠️ **C-10: Rooms was never revised for Save points.**
- Rooms rule 8 and its respawn AC say "standing"; Save points has the arrival seated.
- Rooms rule 9 delivers buffered presses; Save points rule 8 discards them.
- Rooms' room check lacks the rest-area checks.
- Its "save requested during a transition" edge case is stale, since Save points has no manual save.

⚠️ **C-11: Stale "no GDD yet" lines and status labels.**
- "No GDD yet" for the controller, Enemies and Bosses remains in `world-state.md`, `rooms-and-transitions.md`, `level-design.md` and `terrain-pipeline.md`.
- Level design still says the map reads "Room: Visited", but Grid map reads revealed cells.
- Status labels disagree across `grid-map`, `save-points` and `pause-and-menus`.
- Health (R6), Camera (R7) and Hit feedback (R8) have no GDD but are queued in the systems index.

⚠️ **C-12: Terrain's viewport migration vs Pause F1.**
- `terrain-pipeline` rule 1 and Open Question 9 plan a 1920 x 1080, 4x world.
- Pause F1 reads a 480 x 270 base with a 3x default and doesn't say which base it reads.

### Concerns
- **Max health range.**
  - Collectible upgrades F2 allows `health_step` 10 to 30 with `steps_max` 0 to 6, so max health can reach 280.
  - The registry's `max_health_derived` [100, 180] and `heal_amount` [20, 72] assume 100 to 180.
  - Healing Open Question 18 asks for both GDDs to be constrained.
- **Stale registry lists.** `referenced_by` is `[]` or stale for `chase_leash`, `enemy_return_delay`, `heal_share`, `meter_capacity`, `channel_time` and `rest_area_max_width`. The `max_health_derived` note is stale.
- **Ledge pull-up refresh.** The controller refreshes air moves on a ledge pull-up (rule 3). Ability gating rule 18 doesn't list it. Ledge grab is disabled by default.
- **Rest area at small tiles.** `terrain-pipeline` allows `collision_tile` of 1, 2, 3 or 6. At 3 or less, `rest_area_max_width`'s 3-tile cap is narrower than the 10 px hitbox.
- **Rooms R2's fastest rise.** Rooms cites 380 (the wall jump). The real maximum is the grapple fling at -635 px/s. The lip still holds: 10.6 against 10.7.
- **Flash rate.** Pause rule 14 allows a 0.05 s glow step (20 a second); the registry's `flash_limit` is 10 a second.
- **Heal channel on a crossing.** Rooms rule 5's capture list omits HEAL. It is likely moot, since an exit cancels the channel, but worth a sentence.
- **Nits.**
  - Save points has two Open Questions numbered 7.
  - Grid map says `ui_cancel` where the controller and Pause say `cancel`.

---

## Game Design Issues

### Blocking

🔴 **D-1: Healing makes the current boss trivial.**
- `healing.md` says: "Until it exists, stage 1 of the boss is risk-free by design."
- Rule 9: "letting go is always free."
- Rule 2: guarded hits fill the meter in full, about 5 times the health they remove (Open Question 11).
- F3: heal income is about 12 HP/s against the boss's unavoidable damage of about 4.4 HP/s (Open Question 24).
- Rule 12: boss gaps are 2.4 to 3.0 s against a 1.0 s channel.
- The owner already found the boss "super easy", and the MVP pass test reads from it.
- Options:
  - Write the punishing pattern (Open Question 12) before the heal ships.
  - Fill less from guarded hits (Open Questions 11 and 13).
  - Raise `channel_time` (Open Question 7).
  - Set a boss damage budget (Open Question 24).
  - Ship the heal and the boss stages as one story.

🔴 **D-2: `level-design.md` rule 7 contradicts pillar 4.**
- Rule 7 says every key "changes combat as well as movement (dash: dodge and gap-close; wall cling: wall-based attack angles; double jump: second air window; grapple: pull and fling)".
- Pillar 4 (owner, 2026-11-22) says: "Double jump and wall cling are pure traversal."
- Rule 7 is tagged [Sourced] from Metroid Dread; it was not confirmed by the owner.
- Options: amend rule 7; or the owner revises pillar 4.

### Warnings

⚠️ **D-3: A heal-meter farm, against the spirit of anti-pillar 2 ("NOT loot grind").**
- The meter keeps filling at full health (rule 4) and is 0 after a death (rule 5).
- Enemies return when their room is re-entered.
- Rest areas must be clear of enemies.
- So a boss retry starts with no heal unless the player farms. Healing's throttle ships only if a playtest finds farming (Open Question 3).

⚠️ **D-4: In ordinary rooms, fighting and healing beats resting.**
- A grunt kill fills about 21 HP of heal against its 15-damage hit.
- A skitter kill fills about 12.5 HP against 10.
- A brute kill is capped at about 30 HP against 30.
- So health is only a real budget against bosses, and saves lose their tension.

⚠️ **D-5: Pillar 4 is half-specified.**
- The dash attack has no damage, guard cost or fill value (`combat.md`).
- The grapple hit is undecided (`game-concept.md`).
- The pogo is in the starting kit, so it doesn't "open the world".

⚠️ **D-6: Fragments pay nothing in region 1.** `collectible-upgrades` rule 12: "a fragment is therefore found and counted but changes no stat." So pillar 3 pays nothing in the vertical slice.

⚠️ **D-7: The boss fight's attention load is 7 systems.** They are:
1. Movement, with the shockwave check.
2. Melee tap, hold and charge.
3. Reading the telegraphs.
4. The guard meter.
5. The heal meter and channel.
6. Stage-2 hazards.
7. Stage-3 adds.

The heal is the only one not taught on its own beforehand.

⚠️ **D-8: The boss's win condition is unstated.**
- The boss has 600 health and no health bar, and guarded hits deal x0.2.
- No GDD gives a damage-per-stagger figure or a stage-3 end condition.
- So the "3-4 attempts" target (`bosses.md`) can't be derived.

### Concerns
- **Progression after region 4.** Regions 5 to 8 add no movement key and have no stated goal. Brun's boss reward is undefined.
- **The mentor pact.** The double jump comes through a mentor pact (Pell), which edges toward anti-pillar 3. The "never in the same room as its first gate" rule holds.
- **Heal vs pillar 1.** The planted heal is a tension with pillar 1 that isn't recorded with the concept's two kept tensions.
- **Fixed controls.** Controls can't be rebound (`pause-and-menus` rule 17), so the arrows-only layout has no remap fallback.
- **Heal vs slam at high health.** At 180 max health a heal (54) exceeds a boss slam (40). Boss damage does not scale.
- **Pogo loops and hazards.**
  - A pogo loop over the Brute and the boss is unmeasured.
  - Pogoing spikes is owner-confirmed (level design rule 24), but Combat pogoes only `hittable` targets.
  - Whether stage-2 hazards are pogo targets is undefined.
- **Clean results.**
  - Anti-pillar 1: guards are only on bosses, mini-bosses and one tutorial foe.
  - No currency or shop exists.
  - The melee choices (combo 42, heavy 30, charged 60) are balanced by the guard.

---

## Cross-System Scenario Issues

I walked 5 scenarios:
1. Death and respawn at a save point.
2. A heal interrupted by a door or a rest.
3. Completing an edge set, then fighting.
4. A boss fight with the heal.
5. A gate-anchor chain with a pogo.

### Blockers

🔴 **Death and respawn at a save point** (Health, Save points, Rooms, Player controller).
- The sequence: `depleted` → Dead → Rooms fade → Arriving, seated → stand-up.
- Rooms' hold ends at the fade-in, and Save points expects protection until the stand-up ends.
- The controller has no block for ARRIVING, and Rooms doesn't state that it sets the hold for a respawn.
- Whether the Seeker can be hit while seated is undefined (C-1, C-3).
- Rooms also places the Seeker standing, against Save points' seated arrival (C-10).

🔴 **A heal interrupted by a door or a rest** (Healing, Player controller, Save points, Rooms).
- Healing says the door or rest takes over.
- Neither entry condition admits HEAL, and Rooms' capture list doesn't include HEAL.
- What happens is undefined (C-4).

### Warnings

⚠️ **Completing an edge set, then fighting** (Collectible upgrades, Combat, Healing). If the edge scales `attack_data.damage`, `hit_landed` carries edged damage and the meter fills faster than Healing allows: one trigger gives two rewards (C-6).

⚠️ **A boss fight with the heal** (Healing, Bosses, Guard-break). A free heal on every gap and every stagger, plus a positive loop (heal, more hits, more fill) with no boss counter (D-1).

### Info

ℹ️ **A gate-anchor chain with a pogo** (Ability gating, Player controller, Combat). The pogo refresh and the gate spend agree across the three GDDs. The rule 19 chain order has no home in the controller (C-7).

---

## Specialist Disagreements

- **The input map (C-2).** Consistency pass B rated it Blocking, because two pairs of ACs cannot both pass. Pass A rated it a Warning, because it is an owed text edit. This report keeps it Blocking for that AC reason.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| save-points-and-save-load.md | C-1 rest/arrival block; C-2 B and W bindings | Consistency | Blocking |
| pause-and-menus.md | C-2 rule 17 table, `interact` on W, Y for rapid fire; C-12 | Consistency | Blocking |
| level-design.md | D-2 rule 7 vs pillar 4; C-11 | Design theory | Blocking |
| healing.md | D-1 boss trivialised; D-3 farm (already Needs Revision) | Design theory | Blocking |
| rooms-and-transitions.md | C-3, C-10, C-11 | Consistency | Warning |
| player-controller.md | C-4, C-7 rule 19, C-8 | Consistency | Warning |
| combat.md | C-5, C-6, C-9 | Consistency | Warning |
| ability-gating.md | C-7 stale status text | Consistency | Warning |
| enemies.md | C-8, C-9 | Consistency | Warning |
| collectible-upgrades.md | C-6, C-9, max health range; D-6 | Both | Warning |
| world-state.md | C-9 rule 1 vs Grid map; C-11 | Consistency | Warning |
| bosses.md | D-8 win condition; C-9 | Both | Warning |

---

## Verdict: FAIL

There are 4 blocking items: C-1, C-2, D-1 and D-2. `parallax-lighting-and-atmosphere.md` was not read. FAIL outranks NOT ASSESSED, but that gap stands and the next run must cover it.

### Required before re-running
1. The owner picks option (a) or (b) for C-1. Then revise Save points rules 3 and 8 and their ACs, or the controller's Damage block and AC-20.
2. Revise `pause-and-menus` rule 17, L82 and L239 and its rapid-fire row, and `save-points` rule 2, its glyph and its B AC, to the 2026-11-23 layout.
3. Settle D-1 before the heal ships. The options are listed under D-1.
4. The owner decides D-2: amend `level-design.md` rule 7, or revise pillar 4.
5. Include `parallax-lighting-and-atmosphere.md` in the next run.

### Not checked by the passes
- Level design's gate bands against Ability gating.
- `max_health_derived` against the HUD and Pause displays.
- The ACs of World state, Grid map, Level design and Terrain beyond the ones quoted.
- Bosses' arena seams (`RELOAD_DELAY`, the arena lock against Save points rule 3(c)).
- Terrain T1 to T5, Level design F5 and F7, and Grid map F1 and F2 against the registry.
- How Collectible upgrades stores fragment counts, against World state rule 1.
- `game-concept.md` Core Fantasy and Player Motivation.
- ADR-0003 and `design/accessibility-requirements.md`, which does not exist.
- Live data: no `.tres` balance data was compared, and the fill rates are the GDDs' own estimates.
