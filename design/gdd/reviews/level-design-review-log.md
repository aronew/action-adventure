# Review Log: Level design and world layout

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 6 | Recommended: 8
Summary: Strong, well-sourced structure (world model, key order, workshop rule, topology), but the gate-fit formulas disagreed with the measured movement values and the key table conflicted with the one-boss, one-region scope. All 6 blockers were revised in the same session; the key-to-region mapping is a recommendation awaiting owner confirmation (Open Question 11). The hash stamps below are of the GDD as reviewed, before those revisions, so the next review reads it as changed and runs in full.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design (key table): dash gate "about 90 px" contradicted F1's 120-150 px window; a plain run-jump crosses 90 px (fixed)
- [BLOCKING] Formulas (F1): coyote time (14 px) left a perfect run-jump leaking at stated margins; run_jump_distance now about 122, gap_margin 8-15 (fixed)
- [BLOCKING] Formulas (F2) and Acceptance Criteria: "wall-jump reach" was 3 px in code; added cling_exclusion_px and an open-air test (fixed)
- [BLOCKING] Detailed Design (key table, rules 1/20): dash from "the region's boss" and grapple from "a later boss" conflicted with one boss per region and the brief's goal; resolved by the owner's 5-region count, mapping is a Rec pending confirmation (addressed)
- [BLOCKING] Formulas (F5): speedup undefined for routes impassable before the key; rule 22 now splits faster routes from newly opened routes (fixed)
- [BLOCKING] Dependencies / Formulas (F1-F3): gate dimensions overlapped Ability gating's ownership; kept here as provisional with a handoff note (fixed)
- [RECOMMENDED] Detailed Design: rule 9 ("within 3 rooms") vs its criterion ("3 rooms or more") is off by one
- [RECOMMENDED] Detailed Design: rule 15 "next to a shortcut" vs criterion "within one room"; rules 15/16 hardcode 7 while F4 makes it a knob
- [RECOMMENDED] Formulas (F4): "main route", boss-room screens and multi-screen routing are ambiguous
- [RECOMMENDED] Formulas: no numeric spec for the wall-cling shaft or dash-through barriers (consider F6)
- [RECOMMENDED] Detailed Design: mini-boss has no role or reward; F5 cites enemy respawns that nothing defines
- [RECOMMENDED] Acceptance Criteria: untestable or missing criteria (line 307 self-contradiction, "one objective", "player notices", rule 12 vs the leak check; no criteria for rule 8 twice, rule 1 screen multiples, no-backward states, Game Feel targets)
- [RECOMMENDED] Dependencies: five hard upstream GDDs do not exist yet; track each contract in the systems index
- [RECOMMENDED] Overview: brief says "I have the lore" while the GDD and index say lore is not provided; confirm
Reviewed-Content-Hash: design/gdd/level-design.md 62f2c89e0063dc4e58ed7eb0a129af5f44fe485f
Reviewed-Content-Hash: design/registry/entities.yaml dfeacb02917f751cb1dfd88cf490c7ec3d8d2d0f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/game-brief.md f8a91ee620b183a3c91062efaaa6bcc0ac8ff685
Reviewed-Content-Hash: design/research/metroidvania-world-design.md 4e070deab986ec3cae1a6a0173245f04901b0e67
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 4 | Recommended: 13
Summary: The first review's six fixes held up: a 60 Hz re-simulation confirmed the run-jump (107 px), apex (59), dash-jump (164) and double-jump (113) figures. This pass found another gate-formula leak (F3 had no open-air test), an undefined grapple "apart" variant, an unconfirmed key mapping that conflicted with the brief's core-build goal, and no rule for gates whose keys come from later regions. All 4 blockers and recommendations 5-13 were revised in the same session after the owner's decisions (dash from the region 1 mini-boss; F3b chained-anchor gaps; sealed alcoves; tutorial-foe exception). The GDD and brief hashes below are of the versions as reviewed, before those revisions, so the next review runs in full.
Prior verdict resolved: Yes (all 6 prior blockers fixed; prior recommendations 1-3, 5 and 6 addressed in this pass)
Findings:
- [BLOCKING] Formulas (F3): no open-air test; wall cling and climb (key 2) make a 121+ px grapple ledge next to a wall a ladder (fixed: F3a)
- [BLOCKING] Detailed Design (key table): grapple "> 200 px apart" undefined by F3 and beyond grapple_range (fixed: F3b, gap >= about 396 px + margin, chained anchors)
- [BLOCKING] Detailed Design (key mapping): unconfirmed; dash from the apex boss put the loop's payoff after the brief's goal (fixed: owner confirmed the dash from the mini-boss; brief updated)
- [BLOCKING] Detailed Design (rule 2): nothing specified behind double-jump and grapple gates in the core build (fixed: sealed alcoves)
- [RECOMMENDED] Formulas: header said figures ignore coyote time; ledge_nudge and corner_correction unaccounted for (fixed)
- [RECOMMENDED] Formulas (F1): dash_jump_distance called "farthest" but the air dash reaches about 180 px (fixed)
- [RECOMMENDED] Detailed Design (rule 20): brief's two early guarded foes vs one mini-boss (fixed: tutorial-foe exception)
- [RECOMMENDED] Formulas (F2/F3): unused 109-120 px ledge band unstated (fixed)
- [RECOMMENDED] Acceptance Criteria: self-contradicting dash-gap wording, weak rule 9 check, unmeasured "smaller lock", hardcoded 30% (fixed)
- [RECOMMENDED] Dependencies: systems index lacked Level design for rows 13, 18, 21 (fixed)
- [RECOMMENDED] Detailed Design: rules 9, 15, 16 off-by-one, wording and hardcoded 7 (fixed); F4 main route undefined (fixed)
- [RECOMMENDED] Formulas: no F6 for wall-cling shafts and dash-through barriers (open)
- [RECOMMENDED] Detailed Design: enemy respawns undefined (open; deferred to the Enemies GDD)
- [RECOMMENDED] Acceptance Criteria: rule 1 screen multiples, no-backward states, Game Feel targets, "one objective" (open)
- [RECOMMENDED] Overview: lore status vs the brief's "I have the lore" (open)
Reviewed-Content-Hash: design/gdd/level-design.md 091468a8c988e6e9e96fe849a5edde57d39fcd5f
Reviewed-Content-Hash: design/registry/entities.yaml dfeacb02917f751cb1dfd88cf490c7ec3d8d2d0f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/game-brief.md f8a91ee620b183a3c91062efaaa6bcc0ac8ff685
Reviewed-Content-Hash: design/research/metroidvania-world-design.md 4e070deab986ec3cae1a6a0173245f04901b0e67
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 3 | Recommended: 7
Summary: The second review's four fixes held, and a fresh 60 Hz simulation reproduced the run-jump, apex, double-jump and dash-jump figures. This pass found two more start-kit leaks: F1 and F3b compared edge-to-edge gaps with centre travel (the 10 px hitbox and ledge_nudge add up to 15 px), and the pogo (260 px/s, refreshes air moves) was in no gate rule. It also found that the wall-cling gate, the only other region 1 gate, had no spec. All 3 blockers and recommendations 1-5 were revised in the same session after the owner's decisions (pogo clearance rule 24 / F7; dash-through barriers cut; any wall kicks, marked surfaces climb, F6). The GDD hash below is of the version as reviewed, before those revisions, so the next review runs in full.
Prior verdict resolved: Yes (all 4 prior blockers fixed; prior open recommendation F6 escalated to a blocker and fixed)
Findings:
- [BLOCKING] Formulas (F1, F3b): gap width compared with centre travel; hitbox 10 px + ledge_nudge 5 px let a run-jump cross up to about 137 px, so gap_min leaked below margin 15; F3b max crossing is about 399, not 396 (fixed: landing_slack, edge-to-edge W, window 145-162 at margin 8, F3b 420+)
- [BLOCKING] Detailed Design (rules 4-5): start-kit pogo off any hittable bridges gaps and ledges; no rule or Auto check (fixed: rule 24, F7 pogo clearance)
- [BLOCKING] Detailed Design (key table) / Formulas: no spec for the wall-cling gate; dash-through barriers undefined (fixed: F6 kick shaft and climb wall; barriers cut, Open Question 14)
- [RECOMMENDED] Formulas (F3b) / Open Question 13: code shows grapple jump-out refreshes air moves; the anchor chain is not necessary (fixed: wording; reach still to measure)
- [RECOMMENDED] Formulas (F1): run-jump + air dash is about 215 px, not 180 (fixed)
- [RECOMMENDED] Dependencies: Player controller is Hard for every gate formula; derive Auto checks from the config (fixed; systems index updated)
- [RECOMMENDED] States and Transitions: a sealed alcove is visible, so it cannot be Hidden (fixed: own states)
- [RECOMMENDED] Acceptance Criteria: rule 8, 9 and 11 criteria named keys absent from the core build; rule 15 criterion grammar (fixed)
- [RECOMMENDED] Acceptance Criteria / Overview: carried over: rule 1, no-backward states, Game Feel, "one objective"; lore status vs the brief; enemy respawns (open)
- [RECOMMENDED] Tuning Knobs: no consolidated table; Implements Pillar "none defined" (open, advisory)
Reviewed-Content-Hash: design/gdd/level-design.md de4f53e2199abcfa141afbfdd792d23cbb087552
Reviewed-Content-Hash: design/registry/entities.yaml dfeacb02917f751cb1dfd88cf490c7ec3d8d2d0f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/game-brief.md 72140db0b83eb2018bee045e3aac874552ab5687
Reviewed-Content-Hash: design/research/metroidvania-world-design.md 4e070deab986ec3cae1a6a0173245f04901b0e67
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
