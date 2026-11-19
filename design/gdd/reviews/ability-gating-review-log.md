# Review Log: Ability gating

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 3 | Recommended: 6
Summary: A coherent, unusually well-measured design: the F1, F3, F9 and F10 arithmetic all reproduces, and the registry ranges match the document. The weak point was F11: grappling spends neither air move, so a release from the second-to-last gate anchor plus a double jump and an air dash could skip the last anchor, breaking the owner's "every anchor is needed" rule. All 3 blockers and 5 of the 6 recommendations were revised in the same session (owner decision: hooking a gate anchor spends the air jump and air dash). The hash stamps below for the GDD and the registry are of the files as reviewed, before those revisions, so the next review reads them as changed and runs in full.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas (F11): unspent air jump and air dash survive the hook, so a release from a_(n-1) can skip a_n; release_reach ignored them (fixed: hooking a gate anchor spends both, rule 18)
- [BLOCKING] Formulas (F3b, F11): the last step a_n to the far floor is a flight, not a grapple hop, with no crossability bound; hop metric undefined (fixed: exit_reach_min bound; Euclidean hop from global_position plus grapple_arrive_distance)
- [BLOCKING] Detailed Design (rule 16), F10 and Edge Cases: "touching" vs the 9 px detect band vs "a dash 1 px short does not break it" disagreed (fixed: breaks on band entry; boundary criterion added)
- [RECOMMENDED] Formulas (F2): ledge_max used double_jump_total 115 on the crossable side; sim 113.5 gives 106.5 (fixed: double_jump_total_low, window 72-106)
- [RECOMMENDED] Detailed Design (rule 19): gate-anchor data model and chain-step resets unspecified (fixed: chain_id, chain_index, resets on ground, window, death, room change)
- [RECOMMENDED] Visual/Audio (rule 10): dash signature "bisque" conflicts with kiln-city-visual-direction.md's reserved orange, and bisque is the Seeker's own material (open: art bible)
- [RECOMMENDED] Acceptance Criteria: unbounded "0 crossings" sweep, "within one frame's deceleration", "reads from the far side", Game Feel targets without sample sizes (fixed: sweep grid with positive control, 351 px/s, 4 of 5 testers)
- [RECOMMENDED] Formulas: F8 and F9 cited by level design but not registered (fixed: wall_launch_reach, gate_room_footprint)
- [RECOMMENDED] Detailed Design (rule 15): pane faces' cling status unstated (fixed: plain, counted by F2, F3, F8, F9)
- [ADVISORY] Player Fantasy and Tuning Knobs sections absent (advisory at standard; not added)
- [FOLLOW-UP] level-design.md line 42 still says 72-108 and Q13 predates the spend rule: for its next review
Reviewed-Content-Hash: design/gdd/ability-gating.md cb5b0387c12b56eef84bffb1de9367dbcd1d8980
Reviewed-Content-Hash: design/registry/entities.yaml d6ca57b81ae4b14195a4925040c72ad8dfb613b1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/level-design.md 53d80590e3a2ef9e9a364372611dca6cb5906355
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: design/narrative/lore/premise.md e1115841f279e60d13891bef4eeac8e935d74c05
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/narrative/dialogue/mentor-pell.md a1e965cb34510db6c8541952eca945ee02680c0f

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 3 | Recommended: 6
Summary: The first review's three blockers held. The F1, F2, F3, F8, F9 and F10 arithmetic and the registry ranges still reproduce. The new blockers were all ways around a closed gate. Spikes are now pogoable, which broke F1's and F3b's hazard floors. The climb state restores the air moves, which `rule 18` missed. F11's reaches were scalars, but they depend on anchor height. Reading `_begin_grapple_release` showed that a release flings the feet 24 px above the anchor and a jump-out can follow it, so the old example chain could be skipped. All 3 blockers and 5 of the 6 recommendations were revised in the same session. Owner decisions: F3b uses a kill plane only, and a placement rule keeps `climbable` surfaces out of the flight envelope. The GDD and registry hash stamps below are of the files as reviewed (HEAD, before the revisions), so the next review runs in full. The player code and config are stamped because this review read them for the F11 and rule 18 findings.
Prior verdict resolved: Yes (2026-11-18: F11 spend rule, last-flight bound, pane band entry all present)
Findings:
- [BLOCKING] Formulas (F1, F3b), AC: hazard floors at any depth, but spikes are pogoable (level design rule 24, Open Question 20) (fixed: F1 hazard floor at hazard_pit_depth_min 84 or deeper, F3b kill plane only, boundary ACs, registry notes)
- [BLOCKING] Detailed Design (rule 18), Edge Cases, AC: "air moves come back only on ground or pogo", but `_state_climb` refreshes both (fixed: climb listed; no climbable in the flight envelope)
- [BLOCKING] Formulas (F11), AC: release_reach and exit_reach_min were scalars with no anchor height; the release-then-jump-out combo was missed; the 147/293 example fails the skip check (fixed: release_reach(h), exit_reach_min(h, theta), sim table, new 80/230 example, old one rejected)
- [RECOMMENDED] Formulas (F11): "flight path" undefined (fixed: flight envelope defined)
- [RECOMMENDED] Acceptance Criteria: input sweep unbounded (fixed: sweep_max_moves, pruning, sweep_budget_s 600 s)
- [RECOMMENDED] Dependencies: systems index missing Combat in the design-order list and the Terrain pipeline contract (fixed)
- [RECOMMENDED] Formulas (F3b, F11): one-anchor chain contradiction (fixed: at least two anchors, derived)
- [RECOMMENDED] Registry: grapple_gate output_range capped at 434, plain far face reaches 441 (fixed)
- [RECOMMENDED] Visual/Audio (rule 10): dash bisque vs reserved orange (open: art bible)
- [ADVISORY] Player Fantasy and Tuning Knobs sections absent (advisory at standard; not added)
- [FOLLOW-UP] level-design.md rule 24 and Open Question 20 still say "until ability gating sets a depth": now resolved (F1 cites hazard_pit_depth_min, F3b kill plane only), for its next review
Reviewed-Content-Hash: design/gdd/ability-gating.md 69d70bda7bc48dee7538eee52c901fe625813f01
Reviewed-Content-Hash: design/registry/entities.yaml de075a01f7a8c2305ada96e1ea74493b65e1791f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/level-design.md b6de19ba4d19ad38d37c20fe016ce2a9050d379c
Reviewed-Content-Hash: design/game-brief.md b1b6b19338ea6ea8ea0a3279a5eb30ab890ba619
Reviewed-Content-Hash: design/narrative/lore/premise.md e1115841f279e60d13891bef4eeac8e935d74c05
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/narrative/dialogue/mentor-pell.md a1e965cb34510db6c8541952eca945ee02680c0f
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
