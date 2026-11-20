# World state — Review Log

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean; systems-designer and qa-lead lenses applied in session)
Blocking items: 3 | Recommended: 8
Summary: A sound, well-bounded persistence design whose cross-references to ability gating, level design and rooms check out. Three local gaps blocked it: recovery from the last good copy could rotate the unreadable main file over the only good copy, re-raising a held entry was not defined as no change (the load echo and per-frame `seen` would commit every frame), and a boss reward between `defeated` and the pickup could be lost for good. All three, and 5 recommended items, were revised in the same session; the GDD awaits a re-review.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Edge Cases / States: recovery from the last good copy left the record Clean and let the next commit rotate the unreadable file over the only good copy (fixed: Dirty after recovery; only a file read back as valid replaces the last good copy; AC added)
- [BLOCKING] Core Rules 5, 6: re-raising an entry already held was not defined as no change (fixed: rule 5; Edge Cases; AC for the load echo and 600 frames of `seen`)
- [BLOCKING] Edge Cases (cross-system): boss `defeated` committed before the reward is taken, with no rule for rebuilding the reward (fixed: rule 12, rewards derived from the record; Interactions, Dependencies, Edge Cases, AC)
- [RECOMMENDED] Core Rules 10: region ids and key ids had no never-reused guarantee (applied: requirement on Level design and Ability gating; bidirectional note)
- [RECOMMENDED] States: no return to Empty; `PlayerState` reset unspecified (applied: Empty row, rule 8, AC once Pause and menus exists)
- [RECOMMENDED] Core Rules 6: commit serialization, in-flight commit at quit, committer outliving scene changes (applied)
- [RECOMMENDED] Edge Cases: retry cadence on a failed commit (applied: `commit_retry_interval`, new Tuning Knobs section)
- [RECOMMENDED] Acceptance Criteria: cost AC not measurable (applied: commit's own duration, 4 ms proposed, reference machine, swap frame exempt; 60 fps assumption noted)
- [RECOMMENDED] Acceptance Criteria: no ACs for rule 8 or death on the flag frame; rule 3 fixture contradicted the respawn exception (applied)
- [RECOMMENDED] Edge Cases: moved-object release rule has no home in Level design (applied as a bidirectional note and Open Question 6; Level design itself not edited)
- [RECOMMENDED] Dependencies: stale claim that the index says "written at save points" (applied: removed; index line already matches)
Advisory (not counted): Player Fantasy absent (advisory at standard; Game Feel carries the intent).
Receipt note: world-state.md is stamped at its pre-revision HEAD blob (the version reviewed), so the next check reads CHANGED and runs a full re-review. The systems index is stamped before this session's status edit.
Reviewed-Content-Hash: design/gdd/world-state.md 465a1f516228ef9d3edbfb6ac64c02ff7a77b1ef
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/systems-index.md 9406e0cc24ed3f3371647625389e4ce61db39e1f
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/lore/premise.md e1115841f279e60d13891bef4eeac8e935d74c05
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/dialogue/mentor-pell.md a1e965cb34510db6c8541952eca945ee02680c0f
Reviewed-Content-Hash: src/player/player_state.gd b90c0adba681d9284f3be946a22ac3aa0eb3e69c
Reviewed-Content-Hash: src/enemies/boss/boss_arena.gd 8ad04774befe14264ab4951d4d7924560c531b93
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d
Reviewed-Content-Hash: project.yaml f6c15c39d7d0b8d5716f5c37f39b8fff77837308

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean; systems-designer and qa-lead lenses applied in session)
Blocking items: 2 | Recommended: 8
Summary: The three first-review blockers are closed. Two new contradictions blocked approval, both in text the last revision added or left: a failed commit's retry cadence disagreed with rule 6, the Dirty row and its own AC (which could never pass with a 1 s interval), and rule 12 literally forbade a boss reward from dropping in the live room. Both blockers and all 8 recommended items were revised in the same session with four owner decisions; the GDD awaits a re-review.
Prior verdict resolved: Yes (all 3 prior blockers; rule 12's rewrite introduced blocker 2)
Findings:
- [BLOCKING] Rule 6 / States / Edge Cases / AC: retry cadence contradicted the end-of-frame commit; a new change during a failure was unspecified; the failing-write AC could not pass (fixed: owner, a new change waits for the next retry; Dirty row; AC rewritten with a test clock, room-change and quit attempts)
- [BLOCKING] Rule 12: "never created by the event" forbade a live boss drop (fixed: one derive function on the flag's frame and at each build; live-drop AC; Bosses row)
- [RECOMMENDED] Rule 6: no snapshot or coalescing rule for an async commit (applied)
- [RECOMMENDED] Edge Cases / Summary: quit lumped with crash, against rule 6's finish-first (applied)
- [RECOMMENDED] Tuning Knobs: `commit_batch_delay` had no rule (applied: removed by owner; Open Question 2 keeps the fallback)
- [RECOMMENDED] Rule 2: unregistered flag names and key ids unspecified (applied: owner, stored without validation; AC)
- [RECOMMENDED] Edge Cases: a newer save replaced by a new game survived nowhere (applied: owner, kept aside as a kept copy no commit rotates; the last good copy would rotate within seconds; AC)
- [RECOMMENDED] Open Questions 3 / Interactions: region 1 lore's Half-glazed Waster "never returns", an MVP enemy-stays-dead case with no object id (applied)
- [RECOMMENDED] Dependencies / Cross-References: story 007 (Ready) saves at save points and saves the room, against rules 1, 4, 6 (flagged; story not edited)
- [RECOMMENDED] Acceptance Criteria: in-flight and overlapping commits, room-change retry, unknown flags and keys, upgrade keeping unknown entries, respawn replace, AC 218 wording (applied)
Advisory (not counted): Player Fantasy absent (advisory at standard; Game Feel carries the intent). Nits applied: "never reverts" lines name the respawn exception; header status In Review; Formulas size note.
Receipt note: world-state.md is stamped at its pre-revision HEAD blob (the version reviewed), so the next check reads CHANGED and runs a full re-review. The systems index is stamped before this session's status edit.
Reviewed-Content-Hash: design/gdd/world-state.md 8928397fa9694419c82b4929a4dea3cf80de580e
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/systems-index.md 6c3e47ca774f74b8b87350fac67d242ce7ab0ba3
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/lore/premise.md e1115841f279e60d13891bef4eeac8e935d74c05
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/dialogue/mentor-pell.md a1e965cb34510db6c8541952eca945ee02680c0f
Reviewed-Content-Hash: src/player/player_state.gd b90c0adba681d9284f3be946a22ac3aa0eb3e69c
Reviewed-Content-Hash: src/enemies/boss/boss_arena.gd 8ad04774befe14264ab4951d4d7924560c531b93
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean; systems-designer and qa-lead lenses applied in session)
Blocking items: 1 | Recommended: 6
Summary: Both second-review blockers held (retry cadence consistent across rule 6, the Dirty row and its AC; rule 12 derives the reward on the flag's frame and at each build). One new blocker came from last session's coalescing text: the Summary and the crash edge case promised "a crash loses at most one frame" while rule 6 lets changes wait as pending behind an in-flight commit, and a quit did not flush those pending changes. Revised the same session with the blocker and 5 of 6 recommended items, using three owner decisions; the GDD awaits a re-review.
Prior verdict resolved: Yes (both second-review blockers)
Findings:
- [BLOCKING] Rule 6 / Summary / Overview / Edge Cases: crash-loss bound contradicted in-flight + pending coalescing; quit did not flush pending changes (fixed: quit finishes the in-flight commit then commits what is pending; crash bound restated as changes since the in-flight snapshot; Summary and Overview reworded; two in-flight ACs added)
- [RECOMMENDED] States: Clean entered on a commit that succeeded while changes were pending; upgraded older record called Clean (applied: Clean/Dirty rows)
- [RECOMMENDED] Interactions / Dependencies: Pause and menus row said "None" despite the quit flow and title messages; a confirmed quit to the title with a Dirty record was unspecified (applied: owner, a confirmed quit drops it after one last attempt, no retry on the title; Both row and Dependencies row; AC)
- [RECOMMENDED] Edge Cases: kept copy had no way for a newer build to reach it, and the move-aside vs empty-commit order was unspecified (applied: owner, hand recovery only; copy made first, the new game waits for it; AC)
- [RECOMMENDED] Edge Cases: a new game over two unreadable files destroyed the "recoverable by hand" bytes (applied: owner, both kept aside as kept copies; AC)
- [RECOMMENDED] Acceptance Criteria: five-part compound retry AC (applied: split into five ACs)
- [RECOMMENDED] Cross-GDD: region-id and key-id never-reused rules unstated by Level design and Ability gating; story 007 still conflicts (open, not this GDD's to edit)
Advisory (not counted): Player Fantasy absent (advisory at standard). Nits applied: a respawn point rewritten with the same value is not a change (rule 5); Open Question 1 names write span and kept-copy location.
Receipt note: world-state.md is stamped at HEAD blob 8928397 (the last committed version), not the bytes reviewed: the reviewed version was an uncommitted working-tree revision, overwritten by this session's edits. The next check reads CHANGED and runs a full re-review, which is the intent. Only the files this review read are stamped.
Reviewed-Content-Hash: design/gdd/world-state.md 8928397fa9694419c82b4929a4dea3cf80de580e
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/systems-index.md 4e61e69cb97474d3ee3574374f3a0f02cf986fad
Reviewed-Content-Hash: src/player/player_state.gd b90c0adba681d9284f3be946a22ac3aa0eb3e69c
Reviewed-Content-Hash: src/enemies/boss/boss_arena.gd 8ad04774befe14264ab4951d4d7924560c531b93
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d
Reviewed-Content-Hash: project.yaml f6c15c39d7d0b8d5716f5c37f39b8fff77837308
