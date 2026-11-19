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

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 3 | Recommended: 10
Summary: The fourth review's fixes held: the F1-F3 figures and every boundary criterion re-derive, the config and pogo values match, and the controller is unchanged. This first read of the real region 1 layout (Kiln City lore merged) found three gaps the rules never closed: no minimum room size for double-jump and grapple gates (Saggar Rows and Ropewalk Stair are 480 px wide and fail F8 and F3b), a rule 15 shortcut clause the layout fails, and an F4 count that dropped both save rooms and understated the walk by up to 4 screens. All 3 blockers and recommendations 1, 4-8 and the dependency and signature items were revised in the same session after the owner's decisions (widen rooms; save near, loop returns; count by screen position; dash workshop at the low end of the F1 window). The GDD hash below is of the version as reviewed, before those revisions, so the next review runs in full.
Prior verdict resolved: Yes (all 3 prior blockers fixed; prior open recommendations on rule 1 screen multiples, no-backward states and lore status addressed or superseded)
Findings:
- [BLOCKING] Formulas (F3b, F8) / Core Rules 1-2: no minimum room footprint; Saggar Rows (1x2) double-jump gate and Ropewalk Stair (1x3) grapple gap cannot meet F8 or F3b in 480 px (fixed: rule 26, F9; rooms to be widened in the layout, Open Question 18)
- [BLOCKING] Detailed Design (rule 15) / Acceptance Criteria: "arena within one room of a shortcut back to that save" is ambiguous and the draft layout fails the literal reading (S1 returns to N2, S3 to N4) (fixed: save near, loop returns)
- [BLOCKING] Formulas (F4): excluding both save rooms counts a multi-screen save room as 0; N2 to N3 is counted 2 but walks up to about 8 (fixed: count by screen position)
- [RECOMMENDED] Detailed Design (rule 9): "3 rooms" counted in rooms or steps (fixed: graph edges)
- [RECOMMENDED] Dependencies: Combat (pogo, `hittable`) missing; Enemies soft but F7 needs spawn and patrol bounds (fixed; systems index updated)
- [RECOMMENDED] Acceptance Criteria: "by any means in the kit" and "never crosses" are [Play] absence claims; "one objective" undefined (fixed: scripted replay, defined criterion)
- [RECOMMENDED] Detailed Design (rule 11): "smaller instance" meaningless for the dash (17 px window) (fixed: per-key definition)
- [RECOMMENDED] Detailed Design (rule 10): says boss (a Keeper) but key 1 comes from a mini-boss Keeper (fixed)
- [RECOMMENDED] Core Rules / Visual-Audio: no_cling candidate (thorn vines, green) collides with the reserved copper-green hue and the Mossy Cavern look (fixed: candidates revised; art bible decides)
- [RECOMMENDED] Formulas (F6a) / rule 7: which walls carry the wall-cling signature (open: Open Question 19)
- [RECOMMENDED] Integration doc: Cinder moths in room 5 vs rule 24; check list lacks rules 24-26 (open: Open Question 18, narrative side owns the file)
- [RECOMMENDED] Systems index: stale "lore not yet provided" (fixed)
- [RECOMMENDED] Carried over: no consolidated Tuning Knobs or Player Fantasy (advisory); Game Feel targets not acceptance criteria; enemy respawns deferred to the Enemies GDD (open)
Reviewed-Content-Hash: design/gdd/level-design.md 96e520f7831cb8d5a7032a202e3e6218126009dc
Reviewed-Content-Hash: design/registry/entities.yaml dfeacb02917f751cb1dfd88cf490c7ec3d8d2d0f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: design/research/metroidvania-world-design.md 4e070deab986ec3cae1a6a0173245f04901b0e67
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 2 | Recommended: 8
Summary: The fifth review's fixes landed (rule 15 and F4 counting agree with the criteria; F1-F3, F8 and F9 figures re-derive against `player_config.tres`), but two gaps followed from them: widening Saggar Rows for rule 26 pushed N2 to N3 to 8 screens, and F1 constrained only the gap's width, so a shallow pit let the start kit walk through the first gate. Both blockers and recommendations 1-7 were revised in the same session after the owner's decisions (a new save N2b in Saggar Rows; sealed alcoves are nooks in the gate room). The GDD hash below is of the version as reviewed, before those revisions, so the next review runs in full.
Prior verdict resolved: Yes (all 3 fifth-review blockers fixed in the text; the widening's effect on F4 is a new finding)
Findings:
- [BLOCKING] Formulas (F4) / Open Question 18: region 1 spacing "6, 2, 7, all valid" assumed a 1x2 Saggar Rows; at 2x2 (rule 26) N2 to N3 is 8 (fixed: save N2b, legs re-derived)
- [BLOCKING] Formulas (F1): no pit depth, lip height or mid-gap rule; a shallow safe floor lets the start kit cross (fixed: pit block, `pit_depth_min`, criteria)
- [RECOMMENDED] Core Rules (rule 26) / F8 / F9: "ceiling lower than target_top - launch_rise" exemption can never apply (fixed: removed)
- [RECOMMENDED] Formulas (F4): example counted 7 where the rule gives 6 (fixed)
- [RECOMMENDED] Formulas (F4): main route revisits rooms; adjacency along the walk undefined (fixed; post-dash legs wait on the draft, Open Question 18)
- [RECOMMENDED] Edge Cases: case 1's examples contradicted F1 and the criteria (fixed)
- [RECOMMENDED] Acceptance Criteria: "30 attempts" meaningless on a deterministic sim; stray [Play] tag (fixed: input sweep)
- [RECOMMENDED] Core Rules (rule 2) / States / criteria: sealed alcove room-or-not undefined (fixed: in the gate room, owner)
- [RECOMMENDED] Formulas (F9): assumes a free-standing gate (fixed: stated)
- [RECOMMENDED] Carried over: Open Questions 18-19; Game Feel targets not criteria; no Tuning Knobs or Player Fantasy (advisory); 8 hard upstream GDDs missing (open)
Reviewed-Content-Hash: design/gdd/level-design.md c271e3ebc71804f6a2fd45e80e82e0c43454b84e
Reviewed-Content-Hash: design/registry/entities.yaml dfeacb02917f751cb1dfd88cf490c7ec3d8d2d0f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 2 | Recommended: 6
Summary: The sixth review's fixes held (F1 pit rule registered; region 1 legs 3, 3, 4, 2, 7, 3 re-derive with N2b), and the rest of the registry values agree. Two blockers: the key table still gave the double-jump window as 72-108 against the registry's 72-106, and the gate states had no path for a leak or a key owned before its gate was seen. Both were revised in the same session, with two owner decisions: save spacing counts new ground only (backtracking and the walk back out of a dead end count 0), and spikes can be pogoed (rule 24 and F7 widened; a spiked dash pit needs hazard_pit_depth_min, about 84 px; grapple gaps use a kill plane until ability gating sets a depth, Open Question 20). The GDD hash below is of the version as reviewed, before those revisions, so the next review runs in full.
Prior verdict resolved: Yes (both sixth-review blockers fixed)
Findings:
- [BLOCKING] Detailed Design (rule 5 key table, line 42): double-jump ledges 72-108 vs registry double_jump_ledge_window [72, 106] (fixed)
- [BLOCKING] States and Transitions (Gate): no transition for a leak (Seen to Passed without the key) or a key owned before the gate is seen (fixed: Seen and Passed stored, Passable derived from "owned")
- [RECOMMENDED] Formulas (F4): a dead-end shrine detour walked back out of counts 8 (fixed by owner decision: new ground only; post-dash legs now at most 5 and 2)
- [RECOMMENDED] Game Feel: targets carried three reviews without criteria (fixed: relabelled as design targets)
- [RECOMMENDED] Formulas (F7): pogo_carry assumes a contact level with the lips (fixed: re-measure a gap reached by a drop)
- [RECOMMENDED] Detailed Design (rule 24): hazards "not pogo targets in the current code" (superseded by owner decision: spikes can be pogoed; hazard_pogo_reach and hazard_pit_depth_min added; Combat story; ability gating F1 and F3b and the registry's pit note to follow, Open Question 20)
- [RECOMMENDED] Open Questions 13 and 15: spend rule missing; "now measured" wording (fixed)
- [RECOMMENDED] Formulas (F4): save_spacing_max range 5-10, but the region 1 layout needs 7 or more (open, not approved for this pass)
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard)
- [NICE-TO-HAVE] Dash signature colour bisque vs reserved orange (open: art bible); integration draft still holds the bisque pane back (narrative side, ability gating Open Question 5)
Reviewed-Content-Hash: design/gdd/level-design.md 53d80590e3a2ef9e9a364372611dca6cb5906355
Reviewed-Content-Hash: design/registry/entities.yaml de075a01f7a8c2305ada96e1ea74493b65e1791f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md 69d70bda7bc48dee7538eee52c901fe625813f01
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 1 | Recommended: 7
Summary: The seventh review's fixes held, and every registry value the GDD restates agrees (145-162, 72-106, the F9 widths). One blocker: F7's gap-gate volume ended `hitbox_width` (10 px) past each lip and the column clearance was body-based. But the down attack's hitbox in `attack_data.tres` reaches 27 px ahead of the centre and 21 px behind it and hits the target's whole Area2D, so a hittable just past a far lip could be pogoed from over the gap. Everything was revised in the same session, with three owner decisions: alcoves get a one-way return in their room, `save_spacing_max` becomes 7-10 with saves in optional branches, and Passed gets a pass-line trigger. The GDD and registry hashes below are of the versions as reviewed, before those revisions, so the next review runs in full.
Prior verdict resolved: Yes (both seventh-review blockers fixed)
Findings:
- [BLOCKING] Formulas (F7) / Core Rules (rule 24): gap volume and `pogo_clearance_px` ignored the down attack's reach (27 forward, 21 back) and the target's hit area (fixed: `pogo_far_ext` 14, `pogo_clearance_px` 140, examples and criterion re-derived)
- [RECOMMENDED] Core Rules (rule 24) / Open Question 20: stale after ability gating's second review, which made grapple gaps kill plane only at any depth (fixed: resolved)
- [RECOMMENDED] Core Rules (rule 2): "no door" vs "a door that opens only from inside"; a drop cannot cross a grapple gap (fixed: one-way return in the gate room, owner)
- [RECOMMENDED] Formulas (F4): range 5-10 vs the region 1 leg of 7; optional branches unruled (fixed: 7-10, branches held to the limit, owner)
- [RECOMMENDED] States and Transitions (Gate): Passed had no trigger (fixed: pass line per gate type, leak logged, new criterion, owner)
- [RECOMMENDED] Acceptance Criteria: rule 8 and rule 13 playtests had no threshold; the 20-minute pass had no pass condition; the F5 timing was [Play] (fixed: 4 of 5 testers, 0 crossings, scripted sim run)
- [RECOMMENDED] Registry: level-design-owned values were unregistered (fixed: hazard_pit_depth_min, pogo_far_ext, pogo_clearance_px, save_spacing_max added as constants)
- [RECOMMENDED] Core Rules (rule 11): workshop size only in the criterion (fixed)
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); 8 hard upstream GDDs still missing
- [NICE-TO-HAVE] Ability gating's F11 flight envelope ("no hittable in it") should adopt `pogo_far_ext` at the lips at its re-review
Reviewed-Content-Hash: design/gdd/level-design.md b6de19ba4d19ad38d37c20fe016ce2a9050d379c
Reviewed-Content-Hash: design/registry/entities.yaml 557c2b7bbfc9f6faa61ee000cf547fe82f5b0a2f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md 02339fc256489a49753b3cbde2cf03d3974c5b21
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_combat.gd 789723518f859e962cba6f8e183d8fcf7212243d

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 1 | Recommended: 6
Summary: The eighth review's fixes held and every registry value the GDD restates agrees. One blocker: F7's column clearance (140) used the start kit's run-speed pogo carry, but every column gate's earlier kit owns the dash, and a pogo refreshes the air dash (and the air jump once the double jump is owned); a 60 Hz sim puts the carry at about 211 px with the dash and 287 with the F3a kit. Owner chose to widen the clearance per kit and keep the Hollow Knight-style refresh: `pogo_clearance_px` 250, new `pogo_clearance_f3a_px` 320; the sweep criterion now uses each gate's earlier kit with the pogo, and ability gating's sweep includes it. All items revised in the same session; the hashes below are of the versions as reviewed (git HEAD before the revisions), so the next review runs in full.
Prior verdict resolved: Yes (the eighth review's F7 down-attack reach blocker is fixed)
Findings:
- [BLOCKING] Formulas (F7) / Core Rules (rule 24): column clearance ignored the air dash and air jump a pogo refreshes for the dash-owning earlier kits (fixed: per-kit `pogo_clearance_px` 250 and `pogo_clearance_f3a_px` 320 from a sim; sweep criterion per earlier kit; owner)
- [RECOMMENDED] Interactions (World state): interface omitted gate Seen/Passed, alcove Found, room Visited, region Entered (fixed; Player controller row added)
- [RECOMMENDED] Formulas (F4): Output Range "at most 7" stale against range 7-10 (fixed)
- [RECOMMENDED] Acceptance Criteria (rule 11): "at the gap_min end" not measurable (fixed: at most gap_min + 4 px)
- [RECOMMENDED] Acceptance Criteria (rule 22): no criterion for "at least two old rooms per key" (fixed)
- [RECOMMENDED] Formulas (F7): `pogo_far_ext` derivation took the leading edge's shortfall for the centre's; derives to 9 (fixed: 14 kept as a stated safety band)
- [RECOMMENDED] Core Rules (rule 2): grapple-gap alcove return by a drop cannot cross the chasm (fixed: lever door into a passage beneath the kill plane)
- [NICE-TO-HAVE] Volume lower bound, Quick reference deps, Elemental palettes row, gaps note, F11 citing `pogo_far_ext` (all fixed); ability gating lists Combat as Soft where level design says Hard (open)
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); upstream GDDs other than ability gating still missing
Reviewed-Content-Hash: design/gdd/level-design.md ba453f960fbe41443b5d8d52a7958b54c9896514
Reviewed-Content-Hash: design/registry/entities.yaml 9f695b61183a384e292e23f81e231f0dc8341fde
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md 02339fc256489a49753b3cbde2cf03d3974c5b21
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_combat.gd 789723518f859e962cba6f8e183d8fcf7212243d

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 1 | Recommended: 5
Summary: The ninth review's per-kit F7 clearance holds and re-derives from attack_data.tres and player_config.tres; every registry value the GDD restates agrees. One blocker: rule 24 and F7 bounded enemies by spawn and patrol bounds, but enemy_base.gd chases the Seeker out to lose_range (240-280 px), stops only at floor edges and re-homes where a lost chase stops, so an enemy placed outside a gate volume can be lured into it (a skitter to a dash gap's far lip; any chaser under a ledge column). Owner chose to leash the chase to the spawn point: enemies are measured by their leash bound, spawn +/- (patrol_distance + chase_leash 48 + knockback_travel), grown by half-width. All items revised in the same session; the hashes below are of the revised files' versions as reviewed (git HEAD before the revisions), so the next review runs in full.
Prior verdict resolved: Yes (the ninth review's F7 per-kit clearance blocker is fixed)
Findings:
- [BLOCKING] Core Rules (rule 24) / Formulas (F7) / Edge Cases / Acceptance Criteria: chasing enemies leave their patrol bounds and can be lured into gate volumes (fixed: leash bound, `chase_leash` 48 px registered, boundary criterion, sweep lures each enemy to its leash edges, leash unit test, Open Question 21; leash not in code, an Enemies story; owner)
- [RECOMMENDED] Dependencies: ability gating listed Combat as Soft where level design says Hard (fixed in ability-gating.md: Hard)
- [RECOMMENDED] Status / rule 24 / F4 / F7: review history woven into rules (fixed: moved out; decision tags kept)
- [RECOMMENDED] Tuning Knobs: absent (advisory at standard) (fixed: 11-knob table, new ranges marked Rec)
- [RECOMMENDED] Player Fantasy: absent (advisory at standard) (fixed)
- [RECOMMENDED] Acceptance Criteria (rule 13): funnel "first 5-10 rooms" had no defined bound (fixed: funnel length k per region)
- [ADVISORY] Upstream GDDs other than ability gating still missing; GDD is 74 KB
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/attack_data.tres ff3546b25b67bdb9c8b01637d6d43433406bb5e6
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/enemies/enemy_base.gd 5fcf5cee27afd58084b73e8cff82ca673a3dac51
Reviewed-Content-Hash: src/enemies/enemy_config.gd 64ecebffb379b48ab0017e5e51798889cbbabd20
Reviewed-Content-Hash: src/enemies/enemy_grunt.tres cc60d3f8b768d749f87d7ca1d034fa9e9a046333
Reviewed-Content-Hash: src/enemies/enemy_brute.tres 31fbfb9fece80205ea2e4e42e39e75cc8366d296
Reviewed-Content-Hash: src/enemies/enemy_skitter.tres f1619fbd4dee8708a9eb2b42e76499647713b950
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/gdd/level-design.md 933369ab033e08191d5245f88b4adb68ac8c5ecc
Reviewed-Content-Hash: design/registry/entities.yaml f8bf7a3e1c6f3551b787f63e74ad0cf1287dc018
Reviewed-Content-Hash: design/gdd/ability-gating.md 8755589bf5ec7f0e76e6544671c5e912ed13d98b
