# Cross-GDD Review Report (third run)

- **Date:** 2026-11-23, third run. The first and second runs are in this file's git history (the second is the version before this commit; the first is commit `414d669`).
- **GDDs reviewed:** 10 of 16 system GDDs present, by section (healing, player-controller, rooms-and-transitions, save-points-and-save-load, bosses, combat, guard-break, enemies, collectible-upgrades, pause-and-menus), plus `design/ux/healing-presentation.md` and the registry (partial).
- **Not read:** terrain-pipeline, ability-gating, grid-map, parallax-lighting-and-atmosphere. Level-design and world-state were grepped for Healing and rest-area wording only.
- **Focus:** full (consistency and design theory), scoped since-last-review: CHANGED healing, player-controller, rooms-and-transitions, save-points-and-save-load, plus their declared dependencies.
- **Changed since the second run:** `healing.md` `channel_time` floor raised 0.7 to 0.9 s (post-hit heal exposed at least 0.25 s); AC-18d hazard allowlist note; Rooms, Save points and the controller revised for the heal-to-door/rest handover and the seated arrival.
- **How this run differed from the skill's method:**
  - The GDDs total about 1 MB, so each agent read its own sections by heading instead of being given pasted content.
  - One `game-designer` agent ran consistency and stopped at its turn limit; it was asked to report from what it had, so its NOT CHECKED list is long (below).
  - A second `game-designer` agent ran design theory and walked the scenarios (Phase 4).
  - Pillars and anti-pillars come from `game-concept.md`; there is no `game-pillars.md`.

---

## Status of the second run's findings

| ID | Status | Note |
|----|--------|------|
| B-1 heal handover to a door or rest | **Resolved in text** | Rooms rule 5, Save points rule 2 and the controller name HEAL as an entry state. Residue: W1 (crossing), W3 (rest condition), W4 (controller row). |
| B-2 Rooms arrival vs Save points | **Mostly resolved** | Rooms rules 8, 9 and 16 adopted. Residue: W5 (controller AC-15) and W6 (stale text). |
| B-3 heal trivialises the boss | **Open, Blocking** | Now B-A below. The 0.9 s floor changes none of the boss numbers. |
| W-D1 Player Fantasy vs empty-on-hit | **Resolved** | `healing.md` Player Fantasy now says the banked bar is gone. |
| W-C1 arena marker | **Open** | W7. |
| W-C2 `heal_mode` home | **Open** | W8. |
| D-3, D-5 to D-8, W-D2, W-D3 | **Unchanged** | Not re-reported. |

---

## Consistency Issues

### Blocking

None new.

### Warnings

- **W1. A room-exit crossing ends a heal, but Healing and the controller don't list it as an exit.**
  - `rooms-and-transitions.md` rule 5 (L37), Interactions (L103) and Dependencies (L286): a heal ends at the crossing with the meter kept.
  - `healing.md` rule 9 lists only "a door, exit or rest takes over (`interact` ...)". Its States table, AC-39's `heal_cancelled` reasons and `healing-presentation.md` L18 have no crossing.
  - The `player-controller.md` HEAL row (L68) omits a crossing. The skid (rule 7) can carry a planted Seeker over a bounds line.
  - Options:
    - (a) Healing adds a crossing exit (state row, rule 9, AC-39 reason, an AC), and the controller follows.
    - (b) Rooms lets a heal carry across, with a rule for what it does.
    - (c) A crossing counts as `edge`, and that is stated.
- **W2. The Rooms press buffer vs Healing's press rules.**
  - Rooms rule 9 (L44) delivers presses made during the freeze, which lasts 0.25 s or more, on the first frame of the fade-in. Healing's `press_buffer` is 0.12 s, and its "a press is spent once" rule doesn't cover a crossing.
  - Options:
    - Rooms excludes `heal` from the buffer.
    - Healing says a delivered press follows its normal start rules, with the press's age measured from the first frame of the fade-in.
- **W3. The rest takeover condition is looser in Healing than in Save points.**
  - Healing rule 9 needs only the rest area overlapped. Save points rule 2 (L29) also requires the Seeker's feet within one tile of the seat's floor. AC-20c doesn't test a refused rest.
  - Change: Healing rule 9 cites Save points rule 2, and AC-20c gains a "refused rest does not cancel" case.
- **W4. `player-controller.md` contradicts itself on starting a rest.**
  - Its RESTING row (L69) allows a rest from `HEAL`. Its Save points dependency row (L254) doesn't.
  - RESTING "Leaves when" omits a landed hit (Save points States L56).
- **W5. Controller AC-15 still says `revive` leaves the Seeker "standing" (L303).**
  - Save points rule 8, its AC (L265) and Rooms rule 8 say seated. The controller's own L149 calls a seated arrival new.
  - Options: mark AC-15 as today's code and add a target AC for ARRIVING, or rewrite AC-15 as seated.
- **W6. Stale text left from the Rooms revision. No design decision is needed to fix it.**
  - Save points L40, L69, L166, L185 and L237 contradict its Open Question 1, "Adopted 2026-11-23".
  - `level-design.md` L406 still lists as owed a room check that Rooms rule 16 now runs.
  - Status labels disagree with the documents' own status lines: Save points L64, L168 and L241; `pause-and-menus.md` L252; Rooms L330 and L331.
- **W7. The "arena" check has no data field.**
  - The Rooms AC (L385) checks whether a room "is marked as an arena". No room-data field in rule 1 or 14, Level design rule 15(c) or Save points rule 3(c) defines that mark.
  - Options: Rooms adds an `arena` or camera-zone `lock` flag, or Bosses or Level design own the marker.
- **W8. `heal_mode` still has no option row in `pause-and-menus.md`.**
  - Its controls row (L83) says "hold to heal (planned)". Healing rule 14 says toggle mode must ship with the heal.
  - Options: add the option row to Pause rule 13 and reword L83, or Healing drops toggle mode for the first scope, which also drops the stick-push cancel and AC-29 and AC-35.
- **W9. `design/ux/healing-presentation.md` hard-codes a 1.0 s channel.**
  - L32 "Channel (1.0 s) ... pip at 0.5 s" and AC-31 "glow at ticks 0, 30 and 59" don't hold at the new 0.9 s floor, where the heal completes on tick 54.
  - Change: express them as `heal_progress` fractions.
- **W10. Collectible upgrades' contract with Healing is narrower than Healing's.**
  - `collectible-upgrades.md` L197 says Healing only reads max health at completion. Healing F1 and AC-38 also rescale the meter on a step, and Healing needs a cap at 180.
  - Collectible upgrades' F2 still reaches 280. The registry note for `max_health_derived` ("steps 0-4", up to 220) exceeds its own [100, 180] output range.
  - Options: Collectible upgrades adopts the rescale and the cap, or Healing widens its range.

**Verified consistent:**
- `channel_time` 0.9-2.0 s across Healing (rule 10, Values, AC-14b, AC-24) and the registry.
- The boss strike gaps (1.9 and 1.6 s) and damages (40, 25, 20) against Healing rule 12, `heal_share` and `start_deficit_cap`.
- The F1 to F3 arithmetic against `guard-break.md` and the registry.
- No duplicate tuning-knob ownership.

**Notes:**
- Registry `channel_time`, `meter_capacity`, `heal_share` and `chase_leash` still have `referenced_by: []`, though Bosses L163 now names Healing.
- `pause-and-menus.md` L244 lists a fade-in protection gap that Rooms rule 8 now answers.

---

## Game Design Issues

### Blocking

- **B-A. The boss still can't punish a heal, and the new stake can't be seen** (carries B-3). Healing and Bosses.
  - Healing's Overview (L22) and rule 12 still call boss stage 1 "risk-free by design". The `bosses.md` strike gaps are 1.9 s after a slam and 1.6 s after a lunge or shockwave.
  - Rule 10 protects a heal started right after a hit for about 0.65 s. At the 0.9 s floor only 0.25 s is exposed, and a boss pattern would have to strike 0.65 to 0.9 s after a press it can't see.
  - The player can't tell when the protection ends (`healing-presentation.md` Open items L69). That conflicts with the Fantasy line "blame their read of the telegraph, never the rules" (L34).
  - Healing's "risky" sign-off (AC-26b) waits on a Bosses pattern that isn't written (Open Question 12). Bosses is "tuned together with healing" (`bosses.md` L84).
  - Options:
    1. Write Open Question 12's pattern before the heal ships, and say whether it punishes a fresh heal (1.0 s exposed) or one started right after a hit (0.25 s exposed).
    2. Cut rule 10's protection for a heal started right after a hit.
    3. Show on the Seeker when that protection ends.
    4. Ship Healing and the boss stages as one story.

### Warnings

- **W-A. No attrition in the guarded fight.**
  - Heal income is about 9 to 12 HP/s (`healing.md` L188). Unavoidable boss damage is about 34 HP per 7.7 s cycle, about 4.4 HP/s.
  - A guarded boss hit fills 5 times the health it removes (Healing AC-3, `guard-break.md` F1).
  - The Fantasy's "Never: a free refill" (L35) conflicts with rule 12's "a stagger heal is nearly free".
  - Options: a boss damage budget (Open Question 24), cutting guarded-hit fill (Open Questions 11 and 13), or making a stagger heal cost something.
- **W-B. F3 omits the charged-heavy fill rate.**
  - F3 uses about 49/s, the light-combo rate. A charged heavy fills 60 per roughly 0.55 s, about 109/s (unmeasured), on the path that already breaks the guard in one hit.
  - Options: add the path to F3 and AC-26, or cap each hit's fill at the target's remaining health.
- **W-C. Upgrades quietly shift heal income.**
  - Three guard steps cut `guard_fill` from 106 to about 84. Edge steps cut fill per kill by up to about 23%.
  - F3 isn't parameterised by upgrades.
- **W-D. Whether stage-3 adds feed the meter is still only a recommendation** (rule 3, Open Question 17). If they do, the player can farm a bar inside the fight. Owner decision needed before stage 3 is designed.
- **W-E. Attention budget.** A boss fight asks the player to track about 8 active systems, and the boss has no guard or health bar (`bosses.md` L81). The heal is the only one of those systems not taught before the boss. Option: put the heal in the tutorial foe's room.
- **W-F. Pillar tensions.**
  - Fill per hit rewards trading blows while planted (pillar 1).
  - Enemies come back when a room is re-entered (Rooms rule 12), and a death zeroes the meter, so farming before a boss retry becomes near-mandatory. That conflicts with "earned by mastery, not grinding" (concept L36). Options: Open Question 3's falloff, or keep the bar across a death.
  - Concept L107's "death costs only the walk back" no longer holds.
- **W-G. Ordinary rooms.** Every ordinary enemy's gap is at least 1.2 s against a 1.0 s channel, so health is no longer a one-way budget, contrary to Healing's Overview (L22). Attrition survives only in hazard gauntlets. Option: record that as intended in Level design, or limit the meter to bosses and mini-bosses.
- **W-H. Nobody resets the meter.** Healing rule 5 and Save points L180 both say the meter resets on death, Continue and new game, but neither names the owner. `revive` has no callers. Option: name the owner in Save points rule 8 or in ARRIVING.

### Info

- **I-1.** A rest and a health step both refill health and keep a full bar, as Healing rule 5 and Collectible upgrades rule 9 both state.
- **I-2.** The dominant loop is keys and gates, and the heal meter isn't a progression loop. This matches the second run's clean 3a result.

---

## Cross-System Scenario Issues

Scenarios walked: 7.

| # | Scenario | Rating | Note |
|---|----------|--------|------|
| 1 | Hit on the completion tick | INFO | Settled by rule 15 and AC-18. The guard ticks in `_process` and the foe in physics (`guard-break.md` L122), so a hit-stop stretches one clock but not the other. |
| 2 | Heal, then a door or rest | INFO | Was Blocking. Now consistent, with no double-dip. |
| 3 | Stage change with a full meter | WARNING | Whether the transition freezes the boss, keeps the 4.0 s stagger or refills the guard is undefined (`bosses.md` L92, Healing Open Question 2). AC-37 is blocked. |
| 4 | Stage-2 falling hazards | WARNING | A hazard landing on the completion tick must join the AC-18d allowlist. None has been reviewed. Hazards are the likely answer to Open Question 12. |
| 5 | Health upgrade mid-channel | INFO | The cancel is silent as `full_health`, so the player isn't told why the heal did nothing. Whether a pickup can be touched while planted is unstated. |
| 6 | Death with a banked meter | WARNING | W-H (no owner for the reset) and W-F (forced farming). |
| 7 | Heal right after a hit, with a shockwave in flight | WARNING | The wave passes the invulnerable Seeker, then can land in the 0.65 to 0.9 s window with no cue (B-A). |

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| healing.md | B-A; W1, W2, W3; W-A, W-B, W-H | Consistency and Design Theory | Blocking |
| bosses.md | B-A (Open Question 12 pattern), W-D, scenario 3 | Design Theory | Blocking |
| player-controller.md | W4, W5 | Consistency | Warning |
| save-points-and-save-load.md | W6, W-H | Consistency | Warning |
| collectible-upgrades.md | W10 | Consistency | Warning |
| pause-and-menus.md | W8, W6 | Consistency | Warning |
| rooms-and-transitions.md | W7, W6 | Consistency | Warning |

`design/ux/healing-presentation.md` (W9) is a UX spec and is not in the systems index.

---

## Verdict: FAIL

One blocking design issue (B-A) must be resolved before architecture begins. The coverage gaps below would otherwise make this NOT ASSESSED; FAIL outranks that.

### Required before re-running

1. Healing and Bosses: resolve B-A by one of its four options. If option 1, Bosses writes the punishing pattern and says which heal it punishes.
2. Healing: add the crossing exit or state the alternative (W1), and settle the buffered press across a crossing (W2).

### NOT CHECKED

- terrain-pipeline, ability-gating, grid-map, parallax-lighting-and-atmosphere: not read. Level-design and world-state: grep only.
- The controller's Formulas (F1 to F5) and Edge Cases.
- Rooms' Tuning Knobs, R1 to R6 and Formulas.
- Healing Open Questions against Pause.
- The ACs of combat, enemies, bosses, guard-break (partial), world-state, grid-map, collectible-upgrades, ability-gating and terrain-pipeline.
- Grid map rule 11 (whether HEAL counts as "normal play" for the map).
- Cross-References element checks outside Healing, Rooms and Save points.
- The full registry. ADR-0003 and `healing-implementation-notes.md`. Live `.tres` data. Source code.
- All fill rates are paper estimates. Nothing was run or playtested.
