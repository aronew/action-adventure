# Review log: Rooms and transitions

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 4 | Recommended: 8
Summary: The design is coherent and honest about its gaps (memory, the room-storage ADR and the provisional interfaces are marked NOT ASSESSED), and its owner decisions align with the brief and level design. The blockers were local: the Seeker's state between crossing an exit and the screen going dark was undefined and contradicted across rules 5, 6 and 9, R1, R2 and the ACs; R3 had no build time; object ids for world state were undefined; R5's speed bound missed fast falls. All four were revised in the same session. Owner decisions: freeze at the crossing with an arrival inset, a dark build term, authored object ids, blockers only.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Rules 5, 6, 9 / R1, R2 / States: crossing-to-dark interval undefined (world runs during fade-out yet dash time "unchanged"; up to 96 px of travel beyond bounds; re-arm fall-back through space with no room)
- [BLOCKING] R3: no build_time term; measured 0.33 s rebuild contradicts the 0.35 s and 16.6 ms ACs
- [BLOCKING] Rules 3, 12 / Interactions: object ids promised to world state but never defined
- [BLOCKING] R5: dash_speed 370 bound ignores fast_fall_speed 640; load_time has no source (example 1.07 s vs AC 0.75 s)
- [RECOMMENDED] Rule 11 / R6: no Loading-to-Unloaded path; free-before-load order unset (three biomes transient on an X-X-Y-Y-Z chain); "neighbours span three biomes" wording omits the room's own biome
- [RECOMMENDED] Edge Cases: 48 px spawn clearance ignores enemy reach (leash ±103, lunge about 126 px); hazards near arrivals unchecked; immunity vs invulnerability_time 1.0 s
- [RECOMMENDED] Rule 15: graph edges carry no kind, side or one-way/locked flag (level design rules 14, 27)
- [RECOMMENDED] Rules 13, 14: overlapping camera zones, boundary re-trigger, shake vs bounds untested
- [RECOMMENDED] Edge Cases: death-state Seeker carried across an exit; door area size unowned
- [RECOMMENDED] Acceptance Criteria: missing ACs for rules 8, 10 and shake; grounded fixture for the buffered jump
- [RECOMMENDED] R3 / tuning: fade sum can reach 0.8 s against a 0.5 s comfort limit; no Tuning Knobs section (advisory at standard)
- [RECOMMENDED] Dependencies: stale line 270 (index already lists World state); Rooms and World state soft cycle unrecorded
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard)
Receipt note: the GDD stamp is the reviewed (pre-revision) version, HEAD blob of commit 7becc1a, so the next run reads CHANGED and re-reviews; the registry and systems index are stamped before this session's tracking edits.
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md 1f732f7dbb299f4335ef60c7f032a6ac9c5ed287
Reviewed-Content-Hash: design/registry/entities.yaml 5cc8842d035ec61ef3d5f43f6bf92fedeb6fc215
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md d0cad1f45606cdf1f50889fb73e065cf525d675d
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_camera.gd 0b5b78d296c438adc2773993b9a7983a8fcfc0a2
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 7
Summary: All four prior blockers held: the freeze at the crossing is consistent across rules 5, 6, 9, the states table, R1, R2 and the ACs; R3 has build_time; object ids are defined; R5 bounds falls by fast_fall_speed. Registry values match. The revision introduced one defect: the apron was exit_rearm deep, the depth of the arrived centre, so the box's far half (11 px through a fall or rise exit, 5 px through a side opening) could overlap solid, and the line 326 AC certified it. Two ACs (lines 329, 337) were scoped to frames a correct build fails on. Both were revised in the same session. Owner decision: apron per axis.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rule 4 / R2 / AC line 326: apron depth = exit_rearm reaches the arrived centre, not the box; a solid tile 12 px in overlaps the box by 11 px (fall) or 5 px (side)
- [BLOCKING] Acceptance Criteria lines 329, 337: "from the crossing" and "fade alpha below 1" include the crossing and fade-out frames, which a correct build fails
- [RECOMMENDED] Rule 3 / Edge Cases: "never reused" needs a retired-id record per room and globally; a cut room's region is unrecorded
- [RECOMMENDED] Edge Cases: corner tie keeps the tangential coordinate outside the opening span; likely unreachable (solid beyond the corner), say so or clamp
- [RECOMMENDED] Rule 6: perpendicular openings shut during the fade-in act as floor or ceiling; unstated
- [RECOMMENDED] Carried over: residency cancel path and free-before-load; arrival safety (enemy reach, hazards, invulnerability_time); graph edge attributes; overlapping zones and shake vs bounds; death-state crossing and door area
- [RECOMMENDED] R5: arrival points omit save-point and default arrival points (rule 8)
- [RECOMMENDED] Dependencies line 273: stale (index line 102 lists World state)
- [RECOMMENDED] Tuning Knobs absent (advisory at standard); fade ranges plus build_time can exceed the 0.5 s comfort limit
Receipt note: the GDD stamp is the reviewed (pre-revision) version, HEAD blob of commit fb64ba3, so the next run reads CHANGED and re-reviews; the systems index is stamped before this session's tracking edit.
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md 80a1f88a1234eaf87c345b6faf18020afc9eb3a1
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md 43dd773287e10e0e6f0c93c14e11cd268366d88a
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_camera.gd 0b5b78d296c438adc2773993b9a7983a8fcfc0a2
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 14
Summary: Both prior blockers held (apron per axis: 18 px side, 24 px fall or rise; the two ACs scoped to the fade-in) and registry values match. Two new defects: rule 5 fires when the box centre passes the bounds line, so the box already overhangs it by 5 or 11 px, yet nothing says what lies beyond the bounds at an opening (at zero depth no crossing fires) and rule 6 and R2 claimed the Seeker is never beyond the bounds; and the freeze AC spanned the swap, where the Seeker is placed and the enemies replaced. Both were revised in the same session. Owner decision: overhang per axis, just enough (6 px side, 12 px fall or rise).
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rules 4, 5, 6 / R2: no free overhang beyond an opening although the centre-at-the-line trigger needs half_extent + 1 of it; "never in space beyond the bounds" false in the old room through the fade-out
- [BLOCKING] Acceptance Criteria (freeze AC): "unchanged from frame to frame" from the crossing to the fade-in start includes the swap, where positions and enemies must change
- [RECOMMENDED] Rule 3 / Edge Cases: "never reused" needs a retired-id record per room and globally; a cut room's region is unrecorded
- [RECOMMENDED] Edge Cases: corner tie keeps the tangential coordinate outside the opening span; likely unreachable (solid beyond the corner), say so or clamp
- [RECOMMENDED] Rule 6: perpendicular openings shut during the fade-in act as floor or ceiling; unstated
- [RECOMMENDED] Rule 11 / R6: no Loading-to-Unloaded cancel path; free-before-load order unset (B-A-A-C chain holds 3 biomes if C loads first); "neighbours span three biomes" (R6, AC) omits the room's own biome
- [RECOMMENDED] Edge Cases: arrival safety (48 px spawn clearance vs enemy reach about 103-126 px, hazards at arrivals, fade-in immunity vs invulnerability_time 1.0 s)
- [RECOMMENDED] Rule 15: graph edges carry no kind, side or one-way/locked flag
- [RECOMMENDED] Rules 13, 14: overlapping zones, arrival snap inside a zone, shake vs bounds untested
- [RECOMMENDED] Edge Cases: death-state Seeker carried across an exit; door area size unowned
- [RECOMMENDED] R5: arrival points omit save-point and default arrival points (rule 8)
- [RECOMMENDED] Dependencies line 276: stale (index line 102 lists World state)
- [RECOMMENDED] Tuning Knobs absent (advisory at standard); fade ranges plus build_time can exceed the 0.5 s comfort limit (0.68 s at the measured 0.33 s rebuild)
- [RECOMMENDED] AC (rise-exit crossing-back): 0.45 s assumes build_time at budget, hold it as AC 338 does; split compound ACs (lines 325, 331, 332)
- [RECOMMENDED] R2 / registry: transition_time minimum is 0.32 s (0.1 + 0.02 + 0.1), not 0.2; half_height in the formula was undefined (fixed this session)
- [RECOMMENDED] Rule 7: EnterDoor is 1.62 s (seeker_animations.json) and in no timing; same-room door pair: rebuild or not
Receipt note: the GDD stamp is the reviewed (pre-revision) version, HEAD blob of commit 920161b, so the next run reads CHANGED and re-reviews; the systems index is stamped before this session's tracking edit. seeker_animations.json is stamped for the first time.
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md daebbe9f2ed094edd3a8072864378263b0b10173
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md 1f9d67099ffb807987bf29db900a559eda8e3894
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_camera.gd 0b5b78d296c438adc2773993b9a7983a8fcfc0a2
Reviewed-Content-Hash: src/player/seeker_animations.json 239b491a4a44fdf87998575f680742e2e714eaa0
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d
