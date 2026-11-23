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

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 16
Summary: The freeze AC held. The third review's overhang (6 px side, 12 px fall or rise, "just enough" for the centre to pass the line) guaranteed the crossing fires but made the crossing frame a collision frame at almost any speed. Checked against player.gd at 60 physics ticks: a dash hits the wall beyond on about 5 in 6 crossings and ends with velocity.x 0; a fall hits the floor beyond on about 10 in 11 at fast_fall_speed, runs _land() and refreshes the air jump, air dash and coyote time; a jump head-bonks on about 4 in 5 and loses its upward speed. Revised in the same session. Owner decisions: exit lip = tile x ceil((half_extent + one frame of the fastest move) / tile), 12 px side and 24 px fall or rise, carved by the room build; carried state re-derived from contact on the first frame of the fade-in; invulnerable and input locked from the up press for EnterDoor (1.62 s, door trip 2.07 s). Registry values match.
Prior verdict resolved: Yes (freeze AC held; overhang blocker superseded by the lip fix)
Findings:
- [BLOCKING] Rules 4, 5 / R2: overhang of half_extent + 1 makes the crossing frame collide; dash ends, fall exits refill air moves and emit landed, rise exits zero upward velocity (AC 334 fails)
- [RECOMMENDED] Rule 5: captured state names 4 of the controller's 11 states; arrival rule for wall-slide, climb, grapple, crouch, hurt (fixed this session: re-derive from contact)
- [RECOMMENDED] Rule 4 / AC 331: who creates the overhang outside the bounds (fixed this session: carved by the build)
- [RECOMMENDED] Rule 4: "overhang" collides with terrain's trim overhang (T3); renamed exit lip here, terrain and level design do not yet mention the apron or lip
- [RECOMMENDED] Rule 7 / States: EnterDoor 1.62 s had no invulnerability, input lock or timing; same-room door pair (fixed this session)
- [RECOMMENDED] Game Feel: the frozen Seeker is cut by the screen edge for 0.25 s (playtest note added this session)
- [RECOMMENDED] Dependencies line 277: stale, World state already in index row 3 (fixed this session)
- [RECOMMENDED] Rule 3 / Edge Cases: retired-id record per room and globally
- [RECOMMENDED] Registry: collision_tile referenced_by lacks this GDD; exit_rearm and the apron and lip depths unregistered. The third review's "transition_time minimum 0.32 s" was an arithmetic slip (0.22 s); R2 and the registry's 0.2 floor are correct, item withdrawn
- [RECOMMENDED] Edge Cases: corner tie keeps the tangential coordinate outside the opening span
- [RECOMMENDED] Rule 6: perpendicular openings shut during the fade-in act as floor or ceiling, unstated
- [RECOMMENDED] Rule 11 / R6: no Loading-to-Unloaded cancel path, no free-before-load order, "neighbours span three biomes" omits the room's own biome
- [RECOMMENDED] Edge Cases: arrival safety (48 px clearance vs enemy reach, hazards at arrivals, fade-in immunity vs invulnerability_time 1.0 s); death-state Seeker carried; door area size unowned
- [RECOMMENDED] Rule 15: graph edges carry no kind, side or one-way flag; "two-way" contradicts a one-way fall exit
- [RECOMMENDED] Rules 13, 14 / R5: overlapping zones, arrival snap in a zone, shake vs bounds untested; R5 omits save-point and default arrival points
- [RECOMMENDED] Tuning Knobs absent (advisory); fade sum plus build_time can exceed 0.5 s (0.68 s at the measured rebuild)
- [RECOMMENDED] ACs: crossing-back AC now holds build_time (fixed this session); compound ACs at 326, 330, 333-335, 342 still to split
Receipt note: the GDD stamp is the reviewed (pre-revision) version, HEAD blob of commit 916bedb, so the next run reads CHANGED and re-reviews; the systems index is stamped before this session's tracking edit. project.godot is stamped for the first time (physics_ticks default).
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md cb19171854c8ab58caba75a3ebe4ad6399139b44
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md 203211cbaef9e96d28bfa2170bbe31d0ebc68007
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_camera.gd 0b5b78d296c438adc2773993b9a7983a8fcfc0a2
Reviewed-Content-Hash: src/player/seeker_animations.json 239b491a4a44fdf87998575f680742e2e714eaa0
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b

## Review — 2026-11-19 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 0 | Recommended: 13
Summary: The fourth review's blocker is resolved: the exit lip (12 px side, 24 px fall or rise) holds one physics frame of the fastest move beyond the box's half extent, so the crossing frame touches no solid (checked against player.gd: dash ends on is_on_wall, _land refreshes air moves); apron, lip, R1 in all four directions, R3, R5 and the 2.07 s door trip (EnterDoor frame ms sum 1620) all reproduce, and registry values match. No new blocker; the open items sit at the controller and registry seams. Main-review assessment only (lean: no creative-director).
Prior verdict resolved: Yes (exit-lip blocker resolved; 9 recommended items from entry 4 still open)
Findings:
- [RECOMMENDED] Rule 5 / R1 / R2: the GDD speaks of the box centre but the controller's origin is the feet (centre 11 px up standing, 7 crouched); a trigger or placement on global_position breaks the rise-exit lip and the (x, 12) arrival. State the conversion; add crouch to the re-derive list
- [RECOMMENDED] Edge Cases / AC 374: the corner tie is unreachable (the quadrant beyond both lips is solid, so the box hits solid before the centre passes both lines); drop it or reject corner-meeting openings
- [RECOMMENDED] Rule 7 / Dependencies: door input is the `interact` action (W, Up, D-pad up, B); invulnerability and input lock during ENTER_DOOR are a new controller requirement (take_hit now cancels it into HURT); the x snap to the door is unstated
- [RECOMMENDED] Rule 6: resting on the shut line is a real landing (landed, air jump and dash refreshed, 0.1 s coyote past the opening): a free jump at every rise exit; intend it or suppress it
- [RECOMMENDED] Rule 3 / Edge Cases: retired-id record per room and globally
- [RECOMMENDED] Rule 11 / R6 / AC 355: "neighbours span three biomes" misses own biome plus two others; no Loading-to-Unloaded cancel; no free-before-load order
- [RECOMMENDED] Edge Cases: arrival safety (48 px vs enemy reach, hazards and kill planes within the fade-in's fall, invulnerability_time 1.0 s, death-state crossing, door area size)
- [RECOMMENDED] Rule 15: graph edges carry no kind, side or one-way flag
- [RECOMMENDED] Rules 13, 14 / R5: overlapping zones, arrival snap in a zone, shake and dip vs bounds untested; R5 omits save-point and default arrival points
- [RECOMMENDED] Registry: collision_tile referenced_by lacks this GDD; exit_rearm, apron_depth, lip_depth and fade times unregistered; terrain and level design do not name the apron or lip
- [RECOMMENDED] Tuning Knobs absent (advisory); fade sum plus build_time 0.68 s at the measured rebuild
- [RECOMMENDED] ACs 326, 330, 333-335, 342, 345 compound; split
- [RECOMMENDED] Player Fantasy absent (advisory)
Receipt note: the systems index is stamped before this session's status edit.
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/registry/entities.yaml f269a9c7ce2f64828d802bd72e532420c5f80ce3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md 67636b3566845ee72743c3c2633ae55c531c697a
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_input_bindings.gd dbdc4b68adbe1235169478df7f825fa12030d7df
Reviewed-Content-Hash: src/player/seeker_animations.json 239b491a4a44fdf87998575f680742e2e714eaa0
Reviewed-Content-Hash: production/epics/guardbreak/story-007-rooms-saves-map.md 71f3e50fc28b2fe93ac0dd1a8e105ab77230014d
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 8
Summary: Re-review of the unchanged 2026-11-19 text against GDDs that moved since (cross-GDD review 2026-11-23 B-2). The exit, lip, R1-R6 and camera mechanics still hold and registry values match; the failures are at the seams: since the owner removed the rest and arrival damage block (2026-11-23), Save points' safety rests on two things Rooms owns, the hold on an arrival and the room check, and Rooms had neither. Both blockers revised the same session (owner: Rooms' room check runs every rest-area check). Main-review assessment only (lean: no creative-director).
Prior verdict resolved: Yes (prior APPROVED; 13 recommended items from 2026-11-19, 3 now fixed: stale World state line, door input and ENTER_DOOR block as a controller need, R5 save-point arrivals via rule 8)
Findings:
- [BLOCKING] Rule 8 / rule 9 / ACs L347, L351: respawn arrives standing with buffered presses delivered and no damage hold stated, against Save points rule 8 (seated, presses discarded) and its AC L265 and L267 — revised: seated arrival, presses discarded, hold from the request to the fade-in's end, two new ACs
- [BLOCKING] Room check: no rest-area checks although Save points rule 1 and Level design rule 15 assign them to it — revised: new rule 16 (shape and placement checks), two AC groups, Save points and Level design upstream rows
- [RECOMMENDED] Rules 5, 7 / AC L346: door press from HEAL (owner B-1) and a heal ended by a crossing, meter kept — revised
- [RECOMMENDED] Parallax room-data fields and two room-check items (Parallax OQ2) — open, Open Question 10
- [RECOMMENDED] Grid map room index and hidden exit mark — open, Open Question 10
- [RECOMMENDED] R3: Parallax measured a long-room build of 1.4-1.6 s against the 0.02-0.4 s range — open, Open Question 10
- [RECOMMENDED] R2: fastest rise is a grapple jump-out (440 px/s, controller F2 as corrected by its parallel third review), not the wall jump (380); the lip holds — revised
- [RECOMMENDED] Stale status text (header, pillar line, "no GDD" lines, Terrain and Level design status, save-during-transition edge case, no Pause row) — revised
- [RECOMMENDED] Retired room id record naming its region (Save points rule 9) — open, Open Question 9
- [RECOMMENDED] Carried from 2026-11-19: box centre vs feet origin, unreachable corner tie, shut-line landing refresh, residency cancel and free-before-load, graph edge attributes, camera zone ACs, compound ACs, Tuning Knobs and Player Fantasy (advisory) — open
Receipt note: the target doc is stamped at the reviewed (pre-revision) text; the other files at their state when the review ended.
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/registry/entities.yaml fa7bf604b024d9a00eec9d8af9bd36137f36015d
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md d594feb094dca1291ef14d458e4bee0cd2184c73
Reviewed-Content-Hash: design/gdd/level-design.md 98715c97dfbc832944c44cfe593b5ada9e0e8df1
Reviewed-Content-Hash: design/gdd/player-controller.md 44a81dd9f3c23d59ca70498d81be889701c020be
Reviewed-Content-Hash: design/gdd/healing.md b0fe575dac61be3248dfd3d464447531aec39a42
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md d3fbdfdf2fe6a357a04860a017ff4be251f272de
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
