# Cross-GDD Review Report (second run)

- **Date:** 2026-11-23, second run. The first run is in this file's git history (commit `414d669`).
- **GDDs reviewed:** 16 of 16 system GDDs present.
- **Not read:** none. `parallax-lighting-and-atmosphere.md` is covered for the first time. Some sections went unread in every GDD; they are listed at the end.
- **Focus:** full (consistency and design theory).
- **Systems covered:**
  - Runtime: player-controller, combat, guard-break, enemies, bosses, healing, collectible-upgrades, ability-gating.
  - World: rooms-and-transitions, terrain-pipeline, level-design, world-state, save-points-and-save-load, grid-map, pause-and-menus, parallax-lighting-and-atmosphere.
  - The pillars and anti-pillars come from `game-concept.md`. There is no `game-pillars.md`.
- **Changed since the first run:**
  - `healing.md`: a hit mid-heal now empties the meter.
  - `level-design.md`: rule 7 now follows pillar 4.
  - `save-points-and-save-load.md`: no damage block in a rest or on arrival; the rest starts on Up and D-pad up.
  - `pause-and-menus.md`: arrows-only layout; heal on the A key and gamepad B.
  - `player-controller.md`, `systems-index.md` and the registry.
- **How this run differed from the skill's method:**
  - The GDDs total about 1 MB, so each agent read its own sections by heading rather than being given pasted content.
  - Two `game-designer` agents ran consistency: A (runtime) and B (world). A third `game-designer` agent ran design theory.
  - All three hit their turn limit once. Each was resumed and delivered a full report with a NOT CHECKED list.
  - The main session walked the scenarios (Phase 4).

---

## Status of the first run's findings

| ID | Status | Note |
|----|--------|------|
| C-1 rest and arrival damage block | **Resolved** by option (a) | Save points rules 3 and 8 and its ACs now agree with controller AC-20. Placement enforcement is partial; see W-C1. |
| C-2 input bindings | **Resolved** | Pause rule 17 and rule 19, Save points rule 2 and the controller agree: arrows-only, `interact` on Up and D-pad up, heal on the A key and gamepad B, `rapid_fire` on Y. Only `systems-index.md` is stale (W-C3). |
| C-3 Rooms' hold on a respawn fade-in | Open, more important | With no damage block, Rooms' hold is now the only protection during a respawn fade-in, and Rooms still states it only for doors. |
| C-4 heal-to-door and heal-to-rest takeover | Open, **now Blocking** | See B-1. |
| C-5 up attack suppressed in a rest area | Open | `combat.md` L136 covers doors only. |
| C-6 where the edge multiplier is applied | Open | Unchanged. |
| C-7 Ability gating stale text; rule 19 missing from the controller | Open | Unchanged. |
| C-8 Healing's requirements on the controller and Enemies | Open, narrower | `heal_deceleration` and `stick_cancel_deadzone` are in `HealingConfig`. Still missing: the `HealCompletion` node, the HEAL coyote refresh and the jump-buffer zeroing in the controller; the `foe` group, the `take_hit` caller priority and the counted hit-stop restore in Enemies; and the hard/soft rating mismatch. |
| C-9 one-way dependency rows | Open | Every row listed in the first run remains. |
| C-10 Rooms never revised for Save points | Open, **now Blocking** | See B-2. |
| C-11 stale "no GDD" and status lines | Open | More instances; see W-C10. |
| C-12 Terrain's 4x viewport vs Pause F1 | Open | Unchanged. |
| D-1 heal trivialises the boss | **Open, Blocking** | See B-3. |
| D-2 level-design rule 7 vs pillar 4 | **Resolved** | Rule 7 now says "The double jump and the wall cling are pure traversal and change no fight rule (concept pillar 4). [Owner, 2026-11-23]". |
| D-3 to D-8 | Open | D-3 is stronger, D-4 broader and D-8 sharper; see the Game Design warnings. |
| Concern: flash rate | **Resolved** | `flash_limit` is 3 in the registry, Pause F4 and Healing. Pause rule 14 L66 still says "20 a second"; this is now a nit. |
| Concerns: max health 280, stale `referenced_by`, ledge pull-up refresh, rest area at small tiles, HEAL on a crossing, nits | Open | Unchanged. |

---

## Consistency Issues

### Blocking (must resolve before architecture begins)

🔴 **B-1 (was C-4): A heal cannot hand over to a door or a rest, although Healing requires it.** **Resolved the same day by option (a)** (owner, 2026-11-23): the controller's ENTER_DOOR and RESTING entries, its rule 12, AC-14 and open question, and Save points rule 2 and its Healing row now accept the press from HEAL, ending the channel with the meter kept. Healing needed no change. `healing.md` vs `player-controller.md` and `save-points-and-save-load.md`.
- Healing rule 9 (L60) lists "a door, an exit or a rest takes over (`interact` with a door or rest area overlapped)" as an involuntary cancel. It gives it a same-tick slot: "grapple, dash, door or rest `interact`, attack, jump". AC-20a and AC-20c test it.
- On the other side:
  - The controller's ENTER_DOOR entry (L62), rule 12 (L106) and AC-14 require "on the ground, not attacking".
  - Save points rule 2 requires "the controller's ground state". HEAL is a separate state.
  - Save points' Healing row (L180) says "Nothing beyond leaving the heal meter alone".
- So Healing AC-20c cannot pass under Save points rule 2 as written: two ACs that cannot both pass.
- The controller's open question (L297) also misdescribes Healing: "its rule 7 names only attack, jump, dash and grapple as cancels ... not settled".
- Options:
  - (a) The controller and Save points admit HEAL as an entry state for ENTER_DOOR and RESTING.
  - (b) Healing drops the door and rest takeover; `interact` in HEAL is then ignored.

🔴 **B-2 (was C-10): Rooms places a respawn standing, and its ACs cannot pass with Save points'.** **Revised the same day** (Rooms sixth design review, NEEDS REVISION, 2 blockers revised): seated arrival, presses discarded, the hold on arrival (rules 8, 9), and the rest-area checks in Rooms' room check (rule 16, W-C1). Awaiting the Rooms re-review. `rooms-and-transitions.md` vs `save-points-and-save-load.md` and `player-controller.md`.
- **Standing or seated:**
  - Rooms rule 8 (L40): "with zero velocity and the Seeker standing". Rooms AC L347: "arrives standing at its save point's arrival point".
  - Save points rule 8 and its AC L265: "in the sit pose".
  - Controller AC-15 (L280): "`revive` restores full health standing". It is not marked as describing today's code.
- **Buffered presses:**
  - Rooms rule 9 (L44): buffered presses "count as pressed on the first frame of the fade-in".
  - Save points rule 8 discards them on an arrival.
- **The hold (C-3):**
  - Save points rule 8: "Rooms must state that it sets the hold for this arrival".
  - Save points AC L267 expects no damage "under Rooms' hold" through the fade-in.
  - Rooms rule 8 never mentions a hold.
  - Since C-1 was resolved by removing the damage block, this hold is the only protection while the world runs during the fade-in.
- Why Blocking now: the first run kept C-2 Blocking because two pairs of ACs could not both pass. The same test applies here (Rooms L347 vs Save points L265, and controller AC-15). Consistency pass B rated it a Warning, as an owed revision; see Specialist Disagreements.
- Save points Open Question 1 already lists the five changes Rooms owes. Rooms (Approved, MVP Core) has not been revised for them.
- Options:
  - (a) Revise Rooms rules 8 and 9 and its respawn AC to Save points' seated arrival with presses discarded, stating the hold.
  - (b) Save points reverts to Rooms' standing arrival.

### Warnings (should resolve, but won't block)

⚠️ **W-C1: Rest-area placement is required but not enforced.**
- Level design rule 15 now says "The room check therefore also rejects a rest area when (a) leash … (b) spawn/hazard … (c) arena", with AC L342.
- What is still missing:
  - Rooms' room check has no rest-area checks.
  - Save points L302 names both Level design and Rooms as owners of the check.
  - The registry's `rest_area_max_width` and `chase_leash` still have `referenced_by: []`.
  - No GDD defines an arena lock, or a room field marking a room as an arena, so check (c) has nothing to read.
- A ground enemy's leash bound is a vertical strip at every height, so rule 15(a) is stricter than Save points 3(a) reads.

⚠️ **W-C2: The `heal_mode` option has no home in Pause.**
- Healing rule 14: "Toggle mode must ship with the heal". Healing L261 requires the `heal_mode` option of Pause.
- Pause rule 13's settings table has no such row.

⚠️ **W-C3: `systems-index.md` contradicts two owner decisions.**
- The Healing row says "a hit cancels and keeps the meter"; Healing rule 9 now empties it.
- The controller and Healing rows say "gamepad Y" for `heal`. The GDDs say B, with `rapid_fire` on Y, so following the index would put two actions on Y.

⚠️ **W-C4: The edge multiplier has no owner** (C-6, unchanged).

⚠️ **W-C5: Healing's requirements on the controller and Enemies are still partly unadopted** (C-8, narrower). Ability gating's stale text and rule 19 also still have no home in the controller (C-7).

⚠️ **W-C6: The boss death shake exceeds Parallax's band margin.**
- Parallax P2 (L154) takes `m` from "the largest camera shake any attack requests (… the heavy, 3 px)".
- `bosses.md` L72 and L109 give "a camera shake of 7 px for 0.4 s".
- At the edge of the camera's travel, about 4 px of band edge or clear colour shows, against Parallax rule 4 ("never an edge in view"). The sweep AC (L420) tests only 3 px.
- Options: `m` reads every shake source; cap all shakes at `m`; or Bosses lowers its shake.

⚠️ **W-C7: Parallax needs things from Terrain that Terrain doesn't provide.**
- Parallax rule 1 puts "the cobbled lip (terrain pipeline)" at 4-6, in front of the Seeker.
- Terrain's draw order (L275) has all trim on the play layer.
- Parallax rule 11 needs light-carrying props; Terrain Open Question 6 has only "reads solid" or "decoration".
- Parallax Open Question 1 carries it, and the dependency is Hard.

⚠️ **W-C8: Parallax's room-data fields and room checks are not in Rooms.**
- The room data needs fog scales, glow spots, sections, room-end pieces and bands off.
- The room checks needed are:
  - sections in strips along one axis;
  - edge spacing against `layer_blend`;
  - empty travel ranges;
  - room-end pieces at an exit.
- Rooms rule 1 and its Interactions have none of these, so Parallax ACs L421, L423 and L430 cannot be met.
- Grid map rule 11 doesn't say the map draws above the grade (Parallax Open Question 2).

⚠️ **W-C9: Build time.** Parallax rule 15 measured the long room's build at 1.4 s warm and 1.6 s cold, on the software renderer. Rooms R3's `build_time` range is 0.02 to 0.4 s, with a 0.10 s budget. Rooms doesn't know about the measurement.

⚠️ **W-C10: Stale status and "no GDD" text.**
- **Rooms:**
  - L253, "Only the terrain pipeline has a GDD".
  - L281.
  - L259 and L315 call Terrain "In Review".
- **Terrain:** L253, L302 and L303.
- **World state:** L129 and L159.
- **Level design:**
  - L105, Room Visited "drives the grid map".
  - L188 and L190.
  - L250 and L313.
  - L276, "art bible (not yet written)".
- **Grid map:** L172.
- **Save points:** L190.
- **Guard-break:** L138.
- **Collectible upgrades:** L186.
- **Ability gating:** L389 and L443.
- **Parallax:**
  - L310 and L331.
  - The header says "Approved" and also "awaiting re-review".
  - L309, L311 and L400 call Level design "Approved".
- **Status labels:**
  - Save points L168 and L241 and Pause L252 call the controller "Approved". Its frontmatter says "NEEDS REVISION ... re-review owed".
  - Pause L257 and L334 call Parallax "In Review".
- **Owed changes already made:**
  - Controller L299 and Healing Open Question 15 still list Pause's controls table and the rest glyph as owed.
  - Healing Open Question 1 still argues as if A were `move_left`.

⚠️ **W-C11: One-way dependency rows** (C-9, plus new rows).
- Carried from the first run:
  - Combat has no Save points or Collectible upgrades row.
  - Guard-break, Enemies and Bosses have no Collectible upgrades row.
  - Enemies has no Save points row.
  - Collectible upgrades has no Player controller row.
  - Rooms has no Pause row.
  - World state rule 1 says "Nothing else is in it", against Grid map's revealed cells.
- New:
  - Level design has no Parallax row, while Parallax L327 calls it a "Match".
  - Combat and Enemies were never checked against Parallax's projectile rule. The registry's `ember_size_max` has `referenced_by: []`.

⚠️ **W-C12: The render line in Level design contradicts Terrain and Parallax.**
- Level design L279: "renders at 480 x 270 with nearest filtering".
- Terrain rule 1 draws at 4x (1920 x 1080), and Terrain and Parallax both give painted art smooth, mipmapped filtering.

⚠️ **W-C13: Terrain's 4x viewport vs Pause F1** (C-12, unchanged). After the migration, F1 gives `max_scale` 1 on a 1080p screen.

### Concerns and nits
- **Max health can reach 280.** Collectible upgrades F2 allows `health_step` 10 to 30 with `steps_max` 0 to 6, against the registry's [100, 180] (Healing Open Question 18).
- **Registry notes:** `max_health_derived` still says "empty until then" and "steps 0-4". Several entries still have `referenced_by: []`.
- **Ledge pull-up refresh:** the controller refreshes air moves on a ledge pull-up (rule 3); Ability gating rule 18 doesn't list it.
- **Rest area at 1 to 3 px tiles:** the 3-tile cap falls under the 10 px hitbox.
- **Rooms' capture list omits HEAL** (rule 5).
- **Rooms R2's fastest rise** wasn't re-read and is presumed open.
- **Flash reduction:**
  - Pause names only Hit feedback and Combat, although Healing AC-27c and Parallax's `glow_flicker` (3 cycles/s, equal to `flash_limit`) are also affected.
  - Pause rule 14 L66 still says "20 a second".
- **Parallax text:**
  - The Reduced one-liner L390 misstates rule 14.
  - The rule 1 table is out of order.
  - L8 says "Implements Pillar: none defined", although pillar 5 exists.
- **Pause L83:** the heal row has lost its table indent.
- **Save points:** two Open Questions are numbered 7.
- **Grid map** says `ui_cancel` where Pause says `cancel`.
- **The controller** has no Cross-References table.
- **Healing AC-26a's `lost` column** doesn't capture a bar lost to a hit (Open Question 27).

---

## Game Design Issues

### Blocking

🔴 **B-3 (was D-1): Healing still makes boss stage 1 trivial. The empty-on-hit rule doesn't change that at today's timings.**
- Healing says so itself:
  - Overview L22: "nothing in it lands a hit inside the channel window, so the cost of a hit (the damage and the whole bar) never applies … Until it exists, stage 1 of the boss is risk-free by design".
  - Rule 12: "The boss cannot punish a heal at the current timings".
- The gaps:
  - From a strike's end to the next wind-up is 1.9 s after a slam and 1.6 s after a lunge or shockwave.
  - So a 1.0 s channel ends 0.6 to 0.9 s early, and still 0.25 to 0.55 s early after the 0.35 s hurt lock.
  - A heal started right after a hit is also protected for about 0.63 s (rule 10).
- Guarded hits still fill in full (rule 2). Heal income is about 9 to 12 HP/s against about 4.4 HP/s of boss damage (Open Question 24).
- The punishing pattern (Healing Open Question 12, owed to Bosses) is not written. Healing remains MVP, and the MVP pass test reads from this boss.
- Options:
  1. Write Open Question 12's pattern before the heal ships.
  2. Raise `channel_time` toward 1.5 to 1.6 s (Open Question 7).
  3. Set a boss damage budget (Open Question 24).
  4. Cut guarded-hit fill (Open Questions 11 and 13).
  5. Ship the heal and the boss stages as one story.

### Warnings

⚠️ **W-D1 (new): Healing's Player Fantasy contradicts its own rules.** L38 says "The player keeps the bar they earned". Rule 9 and the state table (L94) now empty the meter. AC-26's "felt fair" playtest questions are written in the fantasy's terms.

⚠️ **W-D2 (new): The charged heavy dominates guarded fights and makes guard fragments a false reward.**
- `guard-break.md` rule 2: a charged heavy breaks the guard "whatever the meter holds".
- The charge takes 0.55 s, and a slam leaves a 1.9 s gap. The light path needs 8 hits.
- `collectible-upgrades.md` F4 admits that guard steps only shorten "the two other routes".
- The first run's clean result ("melee balanced by the guard") holds only for foes without a guard.
- Options:
  - A charged heavy drains a large share of the guard instead of breaking it.
  - It breaks the guard only below a meter threshold.
  - The boss punishes a planted charge.

⚠️ **W-D3 (new): Player power scales, but nothing on the threat side does.**
- The player side:
  - Max health 100 to 180.
  - Edge x1.0 to x1.3.
  - Guard drain x1.0 to x1.3.
  - Heal 30 to 54.
- The threat side:
  - `collectible-upgrades.md` L156 says later enemies and bosses "are tuned for the steps a player can hold by then (Enemies and Bosses GDDs)", but neither GDD has per-region values.
  - The concept's "faster guards" per region has no owner.
- At 180 max health a heal (54) exceeds a slam (40).
- Option: a per-region threat table owned by Enemies and Bosses, or by a balance doc, before Alpha.

⚠️ **W-D4 (new, pillar 5): Parallax's readability check skips what a fight asks the player to read.**
- P4 measures only the floor lip and the Seeker against the background. It is "a warning, not a gate", and its example is stale.
- Enemy telegraphs "heat to orange" (`enemies.md` rule 4) and have to read through:
  - a warm grade that dims the screen away from the Seeker;
  - warm glows;
  - embers drawn in front of the Seeker.
- Rule 13's protected list omits foes and telegraphs.
- Options: add foes, telegraphs and hazards to P4's masks; keep telegraph hues out of each preset's ambient palette.

⚠️ **W-D5 (new): The concept promises a dash attack that doesn't exist.**
- `game-concept.md` Core Loop L117 says the dash lands a hit. The MVP's "Required for MVP (built)" list (L295) includes "dash".
- Against that:
  - `combat.md` L21 says "dash damage is planned, not built". AC-17 says the dash emits no `hit_landed`.
  - The dash has no invulnerability (controller L38).
- So the region 1 key does nothing in a fight, and pillar 4 holds only for the pogo. The pogo, by `level-design.md` rule 5, opens no gate. This builds on D-5.

⚠️ **D-3 (stronger): Farming the heal meter.** A bar lost to a hit is "a new reason to farm" (Healing Open Question 27). The meter is 0 after a death and enemies respawn, so a boss retry starts empty. This works against the concept's "the return is earned by mastery, not by grinding".
- Options: ship Open Question 3's fill falloff with the heal; or refill the bar on a boss respawn.

⚠️ **D-4 (broader):** every ordinary enemy's gap is longer than the channel, so the risk-free heal timing applies in ordinary rooms too:

| Enemy | Gap |
|---|---|
| Grunt | 1.2 s |
| Skitter | 1.5 s |
| Brute | 2.0 s |

Only a group of enemies can punish a heal.

⚠️ **D-6:** fragments pay nothing in region 1 (`collectible-upgrades` rule 12, unchanged).

⚠️ **D-7:** the boss fight's attention load is still 7 systems. The heal, now staking the whole bar, is the only one not taught beforehand, and the player has to read progress with no health bar.

⚠️ **D-8 (sharper): the boss's win condition.**
- Only stages 1 and 2 have an end condition (the guard-breaks).
- Estimate: two staggers on the charged-heavy path may empty the 600 health before stage 3. A break deals 60 and each charged finisher 120.
- So the boss may die before its adds appear.
- Options:
  - A damage budget per stage.
  - Health floors per stage.
  - End stage 3 on a third break.

### Concerns
- **The word "fragments" names two things.** Enemy and boss death bursts are "fragments" (`enemies.md` rule 7; `bosses.md` L72), and so are the upgrade pickups. Players may read the bursts as drops, which edges toward anti-pillar 2.
- **Dust:** the stage-2 hazards' dust telegraph vs Parallax rule 13's rule that ambient dust "follows nothing". The arena preset needs a rule.
- **"Death costs only the walk back"** (concept L107; Save points and World state Game Feel). A death also zeroes the heal meter and resets the boss.
- **Pillar 1 and the planted heal:** the tension is recorded in Healing but not in the concept's kept-tensions line.
- **Parallax silhouette:** the band covers the play space in falls. This is owner-accepted; recording it is optional.
- **Carried from the first run:**
  - Regions 5 to 8 add no key, and Brun's reward is undefined.
  - The mentor pact (Pell); rule 9 holds.
  - No remapping. Toggle mode now partly mitigates it.
  - Pogoing hazards: the code pogoes only `hittable` targets.
- **Clean results:**
  - **3a:** one dominant loop, keys and gates, with the map, fragments and bosses in support.
  - **3b:** about 4 systems in an ordinary room and about 4 in a traversal gauntlet.
  - **3d economy:**
    - Health is bounded.
    - Fragments and map reveal are finite.
    - There is no currency.
    - The only open loop is the heal-meter farm (D-3).
  - **Anti-pillars 1, 3 and 4 hold.**
  - **Pillars 2 and 5** are well served, including Parallax rule 13, the fog cap and `foreground_reach_max`.
  - **3g:** the fantasies are coherent apart from W-D1 and W-D5.

---

## Cross-System Scenario Issues

I walked 6 scenarios:
1. Death and respawn at a save point.
2. A heal interrupted by a door or a rest.
3. A boss gap heal and a hit mid-heal.
4. Completing an edge set, then fighting.
5. The boss's death.
6. An edge exit into a long room.

### Blockers

🔴 **Death and respawn at a save point** (Health, Save points, Rooms, Player controller).
- The chain: `depleted` → Dead → Rooms fade → Arriving, seated → stand-up.
- Rooms places the Seeker standing and delivers buffered presses at the fade-in. Save points seats it and discards them.
- Whether Rooms' hold covers a respawn fade-in is unstated, and nothing else protects the Seeker there now.
- Three systems give three different arrival states (B-2).

🔴 **A heal interrupted by a door or a rest** (Healing, Player controller, Save points).
- Healing hands over to ENTER_DOOR or RESTING. Neither entry condition admits HEAL, and Rooms' capture list omits HEAL.
- The behaviour is undefined, and the ACs conflict (B-1).

### Warnings

⚠️ **A boss gap heal and a hit mid-heal** (Healing, Bosses, Guard-break).
- Every gap and every stagger allows a free heal. The empty-on-hit rule is unreachable, because no boss hit can land in the window.
- Healing's fantasy and `systems-index.md` still describe the old rule, so the playtest questions and the index give contradictory messages (B-3, W-D1, W-C3).

⚠️ **Completing an edge set, then fighting** (Collectible upgrades, Combat, Healing). If the edge scales `attack_data.damage`, `hit_landed` carries edged damage and the meter fills faster than Healing allows: one trigger gives two rewards (W-C4).

⚠️ **The boss's death** (Bosses, Parallax, Pause). The 7 px death shake exceeds the 3 px band margin, so a band edge or clear colour can show at the camera's limit. Pause's Screen shake setting scales a value Parallax doesn't size for (W-C6).

⚠️ **An edge exit into a long room** (Rooms, Parallax, Player controller). The measured build of 1.4 to 1.6 s against a 0.10 s budget would stretch the 0.25 s freeze and break the momentum the exit lip preserves (pillar 1). This was measured on the software renderer only (W-C9).

### Info

ℹ️ **Death and the heal meter** (Healing, Save points). The meter is 0 on arrival (Healing rule 5), but Save points' Game Feel says "Death costs only the walk back". Messaging only.

---

## Specialist Disagreements

- **B-2 (Rooms vs Save points arrival).** Consistency pass B rated C-10 a Warning, as an owed revision that Save points Open Question 1 tracks. This report rates it Blocking, by the test the first run applied to C-2: two pairs of ACs cannot both pass.
- **B-1 (heal takeover).** The first run rated C-4 a Warning. Pass A now found the AC conflict between Healing AC-20c and Save points rule 2, which raises it to Blocking.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| healing.md | B-3 boss trivialised; B-1 takeover; W-D1 fantasy; D-3 farm; C-8 | Both | Blocking |
| rooms-and-transitions.md | B-2 arrival, hold and buffer; W-C1; W-C8; W-C9; W-C10; W-C11 | Consistency | Blocking |
| player-controller.md | B-1 ENTER_DOOR and RESTING entry; AC-15 (B-2); C-7; C-8 | Consistency | Blocking |
| save-points-and-save-load.md | B-1 rule 2 entry state; W-C1 check owner; nits | Consistency | Blocking |
| bosses.md | B-3's Open Question 12 pattern; D-8; W-D2; W-C6 shake | Both | Warning |
| parallax-lighting-and-atmosphere.md | W-C6; W-C7; W-C8; W-C10; W-D4 | Both | Warning |
| terrain-pipeline.md | W-C7 lip and props; W-C10; W-C13 | Consistency | Warning |
| level-design.md | W-C10; W-C11 Parallax row; W-C12 render line | Consistency | Warning |
| pause-and-menus.md | W-C2 `heal_mode`; W-C13; Flash reduction scope; L83 indent | Consistency | Warning |
| combat.md | C-5; W-C4; W-C11; W-D5 | Both | Warning |
| enemies.md | C-8; W-C11; W-D3 | Both | Warning |
| guard-break.md | W-D2; W-C10; W-C11 | Both | Warning |
| collectible-upgrades.md | W-C4; max health 280; W-C11; D-6 | Both | Warning |
| ability-gating.md | C-7; ledge pull-up refresh | Consistency | Warning |
| world-state.md | W-C11 rule 1 vs Grid map; W-C10 | Consistency | Warning |
| grid-map.md | W-C8 grade layer; `ui_cancel`; W-C10 | Consistency | Warning |
| game-concept.md (not a system GDD) | W-D5 dash attack claim | Design theory | Warning |
| systems-index.md (not a GDD) | W-C3 stale heal rule and binding | Consistency | Warning |

---

## Verdict: FAIL

There are 3 blocking items: B-1, B-2 and B-3. C-1, C-2 and D-2 from the first run are resolved.

### Required before re-running
1. ~~**B-1:**~~ Done (option a, applied 2026-11-23). Was: the owner decides whether a heal can hand over to a door or a rest. Then revise either the controller's ENTER_DOOR and RESTING entries and Save points rule 2, or Healing rule 9 and AC-20.
2. **B-2:** revised 2026-11-23, re-review owed. Was: revise Rooms rules 8 and 9 and its respawn AC to Save points' seated arrival with buffered presses discarded, and state the hold for respawn, load and fast-travel fade-ins (Save points Open Question 1). Then mark controller AC-15 as describing today's code, or rewrite it.
3. **B-3:** settle D-1 before the heal ships, choosing from the options above.

### Not checked by the passes
- Edge Cases in most GDDs, including Parallax and Healing.
- The ACs of Combat, Enemies, Guard-break, Bosses, World state, Grid map and Terrain beyond those quoted.
- Formulas, Tuning Knobs and ACs of Combat, Enemies, Guard-break, Bosses, Collectible upgrades and Ability gating. Runtime pass A checked these by grep only, so guard drain against F4 and boss damage against `heal_amount` were only partly covered.
- Rooms R2, rule 5 and the Edge Case on a save requested during a transition. Rooms was not revised, so these are presumed open.
- Terrain T3 to T5, and Grid map F1 and F2, against the registry.
- Parallax P1 to P3, P6 and P7 for design theory. Consistency re-derived them all correctly.
- Parallax rule 13 against Combat's hit-FX layer and enemy draw order.
- Whether World state rule 12 (cited by Collectible upgrades) exists.
- ADR-0003, `healing-implementation-notes.md`, `art-bible.md` against Parallax's presets, the registry in full, and live `.tres` data. All fill and time-to-kill figures are the GDDs' own estimates.
- `design/accessibility-requirements.md` does not exist.
