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
