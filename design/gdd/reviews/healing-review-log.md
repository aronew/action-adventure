# Healing — Review Log

## Review — 2026-11-22 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; game-designer, systems-designer and qa-lead lenses applied in the main review)
Blocking items: 4 | Recommended: 8
Summary: The design is coherent and every cited rule, code fact and art-bible value checked out, and the registry has no conflicts. The boss-tuning basis is unsound: F3 counts two swings in a 4.0 s stagger, which at about 0.86 s per 3-hit combo fills more than one meter on its own, so a skilled player earns about 2 heals per cycle against the stated target of 1. The remaining blockers are an internal contradiction (rule 8 vs the max-health edge case and AC-21), two acceptance criteria that cannot pass as written (AC-12, AC-10) and one-way dependencies in seven GDDs.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas F3 / Core Rules 12 / AC-23: cycle_fill counts two post-break swings in a 4.0 s boss stagger; real fill is about 190 over the stagger (about 4.6 combos), so effective heals per cycle are about 2, not 1; the cap hides it and AC-23 cannot detect it
- [BLOCKING] Core Rules 8 / States and Transitions: rule 8 and the "Completes" row always spend the meter, but the Edge Cases and AC-21 keep the meter when health is already max at completion
- [BLOCKING] Acceptance Criteria AC-12: "speed 0 within 0.1 s" and "position does not change until the channel ends" conflict; the charge skid (2000 px/s2) moves the Seeker about 5 px
- [BLOCKING] Acceptance Criteria AC-10: expects `heal_refused` during a door or rest, but those states lock input so no press reaches the heal logic
- [BLOCKING] Dependencies: bidirectional check fails; Combat, Player controller, Guard-break, Enemies, Collectible upgrades, Save points and Pause and menus do not name Healing (only Bosses does)
- [RECOMMENDED] Core Rules 12 / Game Feel / Open Question 7: safe heal window against the boss is at least 2.4 s (recovery 1.0 + cooldown 0.6 + shortest wind-up 0.8), not 1.0-1.3 s; the channel_time range note repeats the wrong premise
- [RECOMMENDED] Header / Overview: "Implements P4" does not fit P4's design test; "rewards landing hits while moving" is not delivered by any rule; the planted channel is a tension with P1 to acknowledge; farming (Open Question 3) needs a measurable trigger
- [RECOMMENDED] States / Dependencies: decide whether CHANNEL is a top-level state or a sub-state, and whether heal logic is a pure RefCounted
- [RECOMMENDED] Core Rules 3: no foe discriminator named for `hit_landed` targets (hittable group also holds TrainingDummy and test HitTarget)
- [RECOMMENDED] Core Rules 9: cancel list omits crouch and the reserved bow, cast and rapid_fire inputs; add a catch-all
- [RECOMMENDED] Dependencies seam / Open Question 4: edge-multiplier vs pre-edge fill cannot occur in the core build (no edge set completes in region 1); settle before an edge step can complete
- [RECOMMENDED] Acceptance Criteria: no criterion verifies the heal's visuals or the flash limit (only AC-25 meter display)
- [RECOMMENDED] Open Question 8: heal clip and audio are not built; state the evidence the first built story must retain
- [NICE] Core Rules 6 / F2: a heal at 1 HP missing spends the whole meter; confirm accepted or add a minimum deficit
- [NICE] F3: `hits_per_heal` range "3-40" does not match the formula (2-15 at defaults)
- [NICE] AC-26: needs meter logging in the build, not specified
Reviewed-Content-Hash: design/gdd/healing.md 6d64f918703d1a2a2869c447a57096f4fa9ee477
Reviewed-Content-Hash: design/registry/entities.yaml 1b74df6f5817249bf170e0d1d65ae2fdb0b0478a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 93772b3230e683fe5e6d64ed863b9815874a3f5e
Reviewed-Content-Hash: design/gdd/guard-break.md 0f7718a7ff0ff4c290986f61c4606a840c466a21
Reviewed-Content-Hash: design/gdd/player-controller.md 83bdba6d2b88087832db1f3e1c8ee495b402b55b
Reviewed-Content-Hash: design/gdd/bosses.md 4bd4c5ba038f32b77eb4038503641332e5e7edb4
Reviewed-Content-Hash: design/gdd/enemies.md 8954f6ab7c3008c2242cda2933d33ce6c4ef587f
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md f2fdefbae75b634eed2663f9d76f83fe691fb436
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 192efae4990edb88dff67911cb8ae45a00834c92
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/pause-and-menus.md 8789f9cfab9ccec5b5d3b8aec845e061793ed77b
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-22 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, gameplay-programmer, godot-specialist, ux-designer; creative-director (senior)
Blocking items: 7 | Recommended: 17
Summary: The owner's loop (hit-fed meter, planted channel, meter kept on cancel) holds together and the four first-review blockers are resolved, but the Overview's "gamble" is untrue (a free cancel, a 2.4 s or longer gap between boss strikes and 0.65 s of post-hit invulnerability make a heal near risk-free), F3 starts every cycle with an empty meter and ignores the charged-heavy guard break so the boss-tuning basis is wrong, and the doc still cites 1.0-1.3 s boss recoveries against Open Question 11's 2.4 s. The engineering spec (top-level HEAL state, rule 9 catch-all, foe marker, hit order, timer source) and several acceptance criteria (AC-26 gate, flash limit, tick tolerances) cannot yet support a story.
Prior verdict resolved: Yes (the 4 blockers of 2026-11-22 lean review); 6 of its 8 recommendations remain open
Findings:
- [BLOCKING] Overview / Core Rules 9-10 / Game Feel: "a gamble" is not delivered; a free cancel plus readable telegraphs and 0.65 s of invulnerability make healing near risk-free; add a cost to a voluntary cancel plus a boss pattern that punishes healing, or drop the word (a meter cost reopens an owner decision)
- [BLOCKING] Formulas F3 / Core Rules 12 / Edge Cases: F3 assumes an empty meter each cycle (steady state about 2.1 heals, 60 HP per cycle at max 100), omits the charged-heavy break (meter 60, 1 heal plus 0.73 banked), and "costs the punish damage" is false in stages 1-2; model carry-in meter and damage taken per cycle, log HP healed against boss damage
- [BLOCKING] Formulas Values / Game Feel / registry channel_time: 1.0-1.3 s recovery premise contradicts Open Question 11 (gaps lunge 2.4, shockwave 2.6, slam 3.3 s, plus 1.0 s after a stagger); fix every site including the registry note
- [BLOCKING] Core Rules 3, 6, 9 / States / Edge Cases: CHANNEL must be a new top-level Player.State.HEAL; rule 9 needs a catch-all and a jump-buffer clear on every exit; name a foe marker (hit_landed carries only the Area2D; decide TrainingDummy); name a hit-order mechanism (enemies call take_hit from their own _physics_process); the timer runs on the pausable physics delta; say what a ledge slide does
- [BLOCKING] Acceptance Criteria AC-26: no pass/fail, "deferred" so the story cannot close; make it an advisory milestone playtest plus a scripted log test and a written decision
- [BLOCKING] Acceptance Criteria / Visual/Audio: no visual or flash-limit criterion; the refusal cue has no rate limit so mashing is about 10 flashes per second against a limit of 3, and a tap-cancel can exceed it
- [BLOCKING] Acceptance Criteria AC-10, AC-12, AC-13, AC-14, AC-18, AC-22: the door/rest press points at AC-20, which tests interact in a channel; no tick tolerances (float accumulation at 1.0 s, 3.8-6.1 px stop distance, same-tick order, pause resume)
- [RECOMMENDED] Core Rules 2 / Open Question: guarded hits fill at full (meter about 88% when a guard breaks); owner to revisit
- [RECOMMENDED] Core Rules 6, 8 / F2: whole meter spent for 1 HP (cost cliff 0 to 120); spend in proportion or refuse a start below about 50% of the heal
- [RECOMMENDED] Formulas Values: heal_share 0.10-0.50 is degenerate at the bounds; narrow to about 0.20-0.40 and state the heal-to-slam ratio
- [RECOMMENDED] Edge Cases: forbid a heal start while invulnerable, or lengthen the channel past the 0.65 s protected window
- [RECOMMENDED] Core Rules 2 / F1: cap each hit's fill at the target's remaining health; guarded boss hits fill at 5 times the damage dealt
- [RECOMMENDED] Edge Cases / Open Question 3: farming becomes mandatory for a banked heal after death; ship a diminishing fill per room
- [RECOMMENDED] Core Rules 13 / Open Question 2: decide whether a stage change keeps the full stagger and gives no refill
- [RECOMMENDED] Header / Overview: drop "Implements P4"; admit the planted-heal tension with P1; consider a fill floor for pogo and dash-attack hits
- [RECOMMENDED] UI / Visual/Audio / Open Question 1: split the refusal cue by reason; persistent non-colour "meter full" marker; 0.1-0.15 s press buffer (press still held when the heal becomes possible); hold/toggle option in design/accessibility-requirements.md; stagger readout; reconsider the R3 default
- [RECOMMENDED] Dependencies: PlayerHealth.heal(), a healed signal and set_max_health(); meter owned by Player; explicit reset hook for Continue and new game (revive has no callers yet)
- [RECOMMENDED] Formulas Values: HealingConfig.validate() should clamp and push_error; "as the save-point config does" points at an unbuilt design
- [RECOMMENDED] Visual/Audio: heal glow as a capped sprite effect (no Environment glow in the project, existing aura is additive); separate heal_loop and heal_end clips; state whether project.godot or PlayerInputBindings owns the heal binding
- [RECOMMENDED] Acceptance Criteria: split bundled criteria (AC-4, 8, 9, 10, 11, 13, 16, 17); cover the pre-edge seam, rule 5, DASH/LEDGE/GRAPPLE/DEAD refusals, i-frame start, release on completion tick and the Game Feel timing targets; AC-9/19/20 as component-contract tests; AC-24 testable; AC-25 belongs to the HUD story
- [RECOMMENDED] Dependencies seam / Open Question 4: settle the pre-edge damage seam on hit_landed before an edge step can complete
- [RECOMMENDED] Open Question 8: state the evidence the first built story must retain for the heal clip and audio
- [RECOMMENDED] Dependencies: Healing's index row should add Enemies, Bosses, HUD and Hit feedback
- [RECOMMENDED] Player Fantasy and Tuning Knobs sections (advisory at standard)
Reviewed-Content-Hash: design/gdd/healing.md c1bbe804b0f4040d293f53817707d94f2d2f9674
Reviewed-Content-Hash: design/registry/entities.yaml ee25e2367cb2a24a2047a1c1924226c5c5f09574
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 504cb4c4a7b721d2b21fd518e8d4796f82e709c9
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
Reviewed-Content-Hash: design/gdd/bosses.md 4bd4c5ba038f32b77eb4038503641332e5e7edb4
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, gameplay-programmer, godot-specialist, ux-designer, audio-director; creative-director (senior)
Blocking items: 8 | Recommended: 15
Summary: The owner's loop is coherent and most of the second review's mechanical blockers held, but "gamble" came back for the third time: a free movement cancel, a kept meter and a 1.0 s channel that ends 0.6 to 0.9 s before the boss's next wind-up mean no current pattern can punish a heal. F3's cycle model ignored the cap and carry-in (and the stated boss gaps were same-pattern repeats), rule 15's ordering mechanism did not work, and four acceptance criteria could not pass as written. The owner decided the stake belongs to the boss, plus a free release window, an interruptible recovery and none in toggle mode; all 8 blockers were revised the same day.
Prior verdict resolved: Partly (5 of the 7 blockers of the second full review held; the "gamble" and F3 tuning-basis blockers recurred in new forms)
Findings:
- [BLOCKING] Overview / Core Rules 9-10, 12: "gamble" untrue at default timings; owner decision (b): the stake is the boss's (Open Question 12 a requirement); a free release window, interruptible recovery and none in toggle mode
- [BLOCKING] Core Rules 12 / Values channel_time / registry: boss gap labels were same-pattern repeats; true gaps 2.4 to 3.0 s; the in-flight shockwave was uncovered; "above 2.0 s" claim was false
- [BLOCKING] Formulas F3 / Values: cycle model ignored carry-in and the cap; Example 1 heal_ratio 1.5 contradicted start_deficit; stagger_time minus channel could go negative; meter_capacity minimum 40 degenerate (raised to 84)
- [BLOCKING] Core Rules 15: the completion re-test fallback cannot see later hitters; the boss Shockwave Area2D was not covered; priority value and location unnamed
- [BLOCKING] Core Rules 9, 14: jump-buffer clear ate the cancelling press and a stale buffer cancelled a heal on its first tick; release detection lost during pause; no priority for simultaneous presses; completion-tick asymmetry unstated
- [BLOCKING] Acceptance Criteria: AC-17b hit landed on tick 62, past the 60-tick window; AC-18 tested tick 59 and one caller; AC-27 impossible by letting go and contradicted Flash reduction; AC-28 contradicted rule 9; AC-15 self-contradictory; AC-9/19/20 could pass vacuously; refusal priority untested
- [BLOCKING] Visual/Audio / AC-27: a "still change of brightness" is still a luminance change; Flash reduction defaults Off; an additive self_modulate collides with the blink and heavy-ready writers and cannot guarantee the luma cap; HDR output could defeat it
- [BLOCKING] Dependencies: Bosses dependency one-way and misstated (no Dependencies row, no Open Questions entry)
- [RECOMMENDED] Open Question 3 / Edge Cases: farming had no measurable trigger (about 6 to 12 heals a minute on paper); trigger and per-spawn diminishing fill recorded
- [RECOMMENDED] Core Rules 6, 8 / Open Question 17: whole-bar spend cost cliff; start_deficit scales with max health but boss hits do not; capacity versus heal scaling; pogo and dash-attack fill; invulnerable heal start
- [RECOMMENDED] Open Question 18: max health can reach 280 under collectible-upgrades ranges while the registry says 20 to 72
- [RECOMMENDED] Open Questions 1, 14: no viable default binding (R3 poor, controls fixed) and the heal_mode option unspecified; owner decision before the controller story
- [RECOMMENDED] Visual/Audio / Open Question 19: audio rows are directions only (mix priority, ready-tone trigger, swell structure, cancel sounds, 0.5 s pip twin); one negative constraint kept; owner audio-director
- [RECOMMENDED] UI / Open Question 20: refusal priority applied; buffer-expiry silence, cancel feedback, non-luminance progress cue, ready-marker size and stagger readout owed to the UX spec
- [RECOMMENDED] Edge Cases / Core Rules 7: Engine.time_scale scales delta, not tick rate (unverified); hit-stop could leave time_scale stuck; coyote refresh in HEAL; missing heal clips are a hard error
- [RECOMMENDED] Acceptance Criteria: toggle-mode, Game Feel timing targets, HealingConfig bounds and launch-and-observe evidence (a story gate, not a GDD gate)
- [NICE] Acceptance Criteria numbering is out of reading order; AC-25 and AC-31 captures named exact values; validate() returns names so tests avoid the error stream
Reviewed-Content-Hash: design/gdd/healing.md 7694a62838d58f409ef68369ba9b02907083f637
Reviewed-Content-Hash: design/registry/entities.yaml a8852b71d2c5ee1b6dc8396122809d50baf9f2c7
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 504cb4c4a7b721d2b21fd518e8d4796f82e709c9
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
Reviewed-Content-Hash: design/gdd/bosses.md 4bd4c5ba038f32b77eb4038503641332e5e7edb4
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, gameplay-programmer, godot-specialist, ux-designer, audio-director; creative-director (senior)
Blocking items: 14 | Recommended: 18
Summary: The meter, the HEAL state and the config are sound enough to build, and none of the blockers is a wrong core design: they are precision defects (tick counts, the jump buffer, an unbuildable glow recipe, untestable ACs) plus three economy decisions that belong to the owner. This is the fourth NEEDS REVISION in a row and the new defects keep appearing in the same places (tick ordering, implementation recipes, the "gamble" framing), so the creative-director's condition is that the next pass consolidates the document; a fifth review finding new contradictions there would escalate to MAJOR REVISION NEEDED. The owner decided: RECOVER and the free window are cut, the meter capacity is derived from the heal amount with a capped start deficit, guarded hits keep their full fill, and a heal may start inside the invulnerability window. All 11 GDD blockers and the 3 decisions were revised the same day; the document grew from 98.6 KB to 110.7 KB, so the consolidation is still owed.
Prior verdict resolved: Mostly (the third review's 8 blockers held in substance; the revised text introduced new defects in tick counting, the jump buffer and the glow recipe, and the boss gap table was still not exact)
Findings:
- [BLOCKING] Core Rules 9, 15 / AC-15b: the free-window tick count was off by one against rule 15's step order (the timer is read before it advances); a release on the completion tick needs a one-delta lookahead
- [BLOCKING] States / Core Rules 9: the jump buffer was cleared on every exit from HEAL but must survive a jump cancel; the same-tick dispatch to the ground handler was unspecified
- [BLOCKING] Core Rules 10 / Edge Cases: a heal started inside the invulnerability window is protected, contradicting "no protection" (owner: allowed, rule 10 reworded)
- [BLOCKING] Core Rules 9, 14: a press could cancel and restart a heal in one tick (toggle mode) because the press age was never consumed
- [BLOCKING] Core Rules 9 / AC-16d: an attack cancel cannot start an attack on the same tick (Combat arms its tap/hold resolution)
- [BLOCKING] Acceptance Criteria: the Logic ACs cannot drive Input (a pure HealChannel step), cues had no signal contract, AC-28d contradicted AC-16a, AC-24 asserted and forbade the error stream, AC-26a was not deterministic, toggle mode, pause release and rule 13 were uncovered
- [BLOCKING] Formulas / Values: start_deficit_share 0 started a heal at full health, fill_rate 0 gave NaN, no cross-field validation
- [BLOCKING] Visual/Audio: the HealGlow overlay shader cannot read the parent sprite's pixels, ignores self_modulate and is multiplied by modulate
- [BLOCKING] Visual/Audio / UI: "ready" (meter full) is not "usable" (health must also be low enough); the marker had no contrast or size
- [BLOCKING] Overview / Visual/Audio / Formulas: the text argued with itself (a leftover gamble sentence, "the one vulnerable moment", a wrong "damped three ways")
- [BLOCKING] Visual/Audio: the 0.5 s pip had no visual twin
- [BLOCKING, owner decision] Core Rules 9 / States: RECOVER was unreadable (stick movement did not interrupt it); cut together with the free window
- [BLOCKING, owner decision] Formulas F1, F2 / Values: a fixed meter cost against a heal and start_deficit that scale with max health; capacity derived from the heal (ratio 4.0), start_deficit capped at 20
- [BLOCKING, owner decision] Core Rules 2: guarded hits fill at full; kept, with the fill source logged (Open Question 11)
- [RECOMMENDED] Core Rules 12: the 2.4 to 3.0 s boss gaps are lower bounds and some pairs cannot occur for a planted Seeker (distance windows, walk time)
- [RECOMMENDED] Dependencies: priority 10 is a plan; the boundary cases need numbers and AC-18 needs real frames
- [RECOMMENDED] Open Question 3 / Edge Cases: ship the kill counter as logging and restate the farming trigger as fill per minute
- [RECOMMENDED] Core Rules 6, 9: heal start's place in the ground handler's polling order, climb in the ignored list, "landing" is a flag not a state
- [RECOMMENDED] Visual/Audio: heal_end needs a gating flag (GROUND replays idle every tick); missing clips are a hard error
- [RECOMMENDED] Core Rules 14 / Edge Cases: a press the pause menu consumed cannot be detected by polling; hit-stop must restore time_scale from a static; clamp a duplicate of the config, not the shared resource
- [RECOMMENDED] Visual/Audio / UI: refusal cues are peripheral HUD transients with nothing on the Seeker; a start refused in the hurt lock gives no cue; edge-slide cancels are invisible
- [RECOMMENDED] Visual/Audio: channel progress readable without the glow; photosensitivity capture should include a boss fight
- [RECOMMENDED] Formulas: heal_ratio at zero damage, hits_per_heal ceil, press_buffer operator, heal_share rationale arithmetic
- [RECOMMENDED] Formulas / Open Question 18: max health up to 280 against the 100 to 180 ranges
- [RECOMMENDED] Acceptance Criteria: pin a test fixture, AC-17b setup, AC-15e, AC-18d allowlist, orphaned ACs (9b, 9c, 20c, 32b), UI ACs not closable, AC-26b trigger, luma scale mismatch
- [RECOMMENDED] Visual/Audio: the telegraph-fundamental constraint has no referent in Bosses; event contract and audio ACs
- [RECOMMENDED] Overview: Player Fantasy section (advisory) and consolidation of the document
- [RECOMMENDED] Core Rules 12 / Edge Cases: a heal in a stagger is nearly free (owner-accepted, watched in the log)
- [RECOMMENDED] Dependencies: design/accessibility-requirements.md does not exist; toggle mode must ship with the heal
- [RECOMMENDED] Dependencies: Health (R6), HUD (R9) and Hit feedback (R8) have no GDD; interfaces stay provisional
- [RECOMMENDED] Rule 3: TrainingDummy is in group foe and must stay out of shipped rooms (specialist-rated NICE, kept as a note)
- [RECOMMENDED] Open Question 21: whether bow, cast and rapid-fire hits fill the meter
Reviewed-Content-Hash: design/gdd/healing.md 788dcea94c353fce0bad417ff5e23823d7891023
Reviewed-Content-Hash: design/registry/entities.yaml b2c2e737a8b0057ffbb8daf22ca999bdabf9c5fc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 504cb4c4a7b721d2b21fd518e8d4796f82e709c9
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
Reviewed-Content-Hash: design/gdd/bosses.md 025d6e45c55d02b0ffe748d22de9466fde7db4e4
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-23 — Verdict: MAJOR REVISION NEEDED
Review mode: full · Workflow: standard
Scope signal: L (trends to XL if the tick-order change reaches Combat and Enemies)
Specialists: game-designer, systems-designer, economy-designer, qa-lead, gameplay-programmer, godot-specialist, ux-designer, audio-director; creative-director (senior)
Blocking items: 10 | Recommended: 15
Summary: The core design is buildable and no finding is a wrong mechanic. The fourth review's escalation condition is met: the document is still 110.7 KB (consolidation not done) and new contradictions appeared in tick ordering, implementation recipes and the risk framing. The creative-director's plan: split the document (rules, formulas, edge cases, dependencies and ACs stay; the priority mechanism, hit-stop, press age, unpause and latch details go to an ADR; the shader recipe and test seam go to an implementation-notes file), state each fact once, fix the blockers, target 50 KB or less, and do not re-review until it is under 60 KB with no engine API names outside Dependencies. Owner decisions (not editor fixes): stick cancel (recommended: toggle mode only), tick-order approach (helper node vs Seeker-wide priority, with the technical-director), a boss damage budget and whether stage-3 adds feed the meter (recommended: no), the farming trigger as a per-spawn kill count (log only), whether an empty meter is announced mid-combo or in the air, and the default `heal` binding.
Prior verdict resolved: Mostly (the fourth review's 14 items held in substance; consolidation was not done and the revised text introduced new defects)
Findings:
- [BLOCKING] whole document: 110.7 KB, mixes rules, rationale and engine recipes; consolidate and split (creative-director condition unmet)
- [BLOCKING] Dependencies, Implementation notes (1) / Core Rules 15: the priority-10 claim "a hitter sees the previous tick's invulnerability decrement" is wrong; real effects are a hurt lock one tick shorter and Seeker swings resolving after the foe's strike on the same tick, so Combat and Enemies ACs need re-derivation (alternative: a priority-10 helper node)
- [BLOCKING] Overview, Player Fantasy, Cross-References / Core Rules 9: "any movement press cancels" contradicts rule 9, which ignores stick, D-pad, crouch and climb; a toggle-mode player is trapped planted with no cue (wording fix mandatory; stick cancel is an owner decision)
- [BLOCKING] Core Rules 14: a buffered press needs the input "still held", which breaks toggle mode (a tap)
- [BLOCKING] Dependencies (4) / Visual/Audio / AC-39: no `heal_progress` or pip signal for the swell and the 0.5 s pip; the at-max completion fits neither `heal_completed` nor `heal_cancelled`; the `heal_cancelled` reasons are not enumerated
- [BLOCKING] Acceptance Criteria: the `HealChannel` seam cannot drive AC-10, 11, 13, 21, 33, 16 or 28e; AC-28c's setup contradicts rule 6; AC-39 does not cover the at-max completion
- [BLOCKING] Formulas / Values: "above 10 a guard phase (106) never fills it" is false (true at 4.0); F3 `hits_per_heal` range 38 is wrong (50 at 100 max health, 90 overall); Core Rules 12's 0.6 to 0.9 s margin ignores the hurt lock (about 0.25 s after a lunge) and "1.0 s more after a stagger" is +0.4 s; OQ18's 210 max health bound is 172 on the charged path
- [BLOCKING] AC-26: the log schema cannot compute fill per minute, `heal_ratio`, `heal_effective` or the max-health read; needs fill, damage_taken, kill and died rows and max_health, attack_id, amount, lost and spawn_id columns
- [BLOCKING] Visual/Audio: the ready marker's 3:1 contrast against the lightest background cannot be met by Bone Pale; add a Void Black outline or halo
- [BLOCKING] Player Fantasy / AC-26: "pressing heal is a decision" and "felt risky / felt fair" hold only once Bosses supplies the risk (OQ12); state that stage 1 is risk-free (downgraded from the game-designer's blocker: an accepted dependency)
- [RECOMMENDED] Core Rules 14: "first tick after resume" has no mechanism; specify `NOTIFICATION_UNPAUSED` or a frame counter and an `_input` latch for sub-tick taps
- [RECOMMENDED] Visual/Audio: the glow shader recipe still bakes in `modulate` through `COLOR`; sample `TEXTURE` and take only alpha from `COLOR`; confirm which sprite layer shows in `HEAL`
- [RECOMMENDED] Core Rules 9: a cancel press that cannot start (dash on cooldown, no grapple anchor) still cancels; the polling order is not `_state_ground`'s (climb precedes jump); `heal_cancelled(reason)` needs a stored reason
- [RECOMMENDED] Visual/Audio, Game Feel, AC-27/39: the 0.5 s refusal rate limit contradicts "within 1 tick"; rate-limit only the luminance event
- [RECOMMENDED] Core Rules 6 / UI: an empty meter is silent when mashing mid-combo or in the air; banked is not usable and the marker's name and meaning disagree across sections
- [RECOMMENDED] Visual/Audio / AC-27: the flash-limit unit (WCAG absolute 0.10 vs relative 10%) is ambiguous; per-hit meter brightening is unrated; HDR must be a requirement
- [RECOMMENDED] Open Questions 3, 17 / F3: farming trigger as a per-spawn kill count (log only); add the uncharged-heavy break path (120 fill); log missing health at heal start; decide whether stage-3 adds feed the meter
- [RECOMMENDED] Formulas / Values: `capacity_floor` is not in `validate()` (zero makes "full" always true and divides by zero); add float tolerance on "full" and `is_finite` on damage
- [RECOMMENDED] Acceptance Criteria: about nine rules and edges lack an AC; AC-8 is Logic; AC-3 needs a tolerance; AC-17d for the real protected window (about 0.63 s); renumber (AC-29 missing); split AC-35
- [RECOMMENDED] Visual/Audio: make the telegraph-versus-swell constraint bilateral with Bosses; the ready tone's rising shape and the swell's pause and `time_scale` behaviour are undefined
- [RECOMMENDED] Edge Cases (pause/time_scale): reduce the hit-stop paragraph to one requirement (restore `time_scale` from a static counter)
- [RECOMMENDED] Open Question 1: name a proposed default `heal` binding (none is free today; ux-designer suggests Y with `rapid_fire` moved to R3)
- [RECOMMENDED] Visual/Audio: `heal_end` flag must be set after `_set_state(GROUND)`; hurt-lock press buffer expires before the natural heal moment
- [RECOMMENDED] Open Question 12: heal income is about 3x boss damage at every max health, so one punishing pattern punishes timing, not volume; a boss damage budget is owed to Bosses
Reviewed-Content-Hash: design/gdd/healing.md 70619b5f57de352fe342dc0b51bd0f61b1dfa605
Reviewed-Content-Hash: design/registry/entities.yaml 66e7b3910ab53e9ac66c44ed12c435386d5081b4
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 504cb4c4a7b721d2b21fd518e8d4796f82e709c9
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
Reviewed-Content-Hash: design/gdd/bosses.md 025d6e45c55d02b0ffe748d22de9466fde7db4e4
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-23 — Verdict: MAJOR REVISION NEEDED
Review mode: full · Workflow: standard
Scope signal: L (trending XL: Collectible upgrades, Bosses, Player controller, Pause and menus, `PlayerHealth` and `enemy_base.gd` need changes; a HUD spec and an audio spec are new documents)
Specialists: game-designer, systems-designer, economy-designer, qa-lead, gameplay-programmer, godot-specialist, ux-designer, ui-programmer, audio-director; creative-director (senior)
Blocking items: 11 | Recommended: about 30
Summary: The core design is sound; the document form fails. The fifth review's condition (under 60 KB, no engine API names outside Dependencies) is unmet (86 KB), and each pass finds new contradictions against `src/` because the GDD narrates the code. Verified against `player.gd`: jump is not polled first, stand-up is in CROUCH, attack plus jump on one tick gives only the jump, `PlayerHealth` has no heal API. Creative-director path: no seventh review until the doc is under 60 KB with zero engine names outside Dependencies; rules state outcomes and mechanisms go to ADR-0003; Visual/Audio and its ACs move to a HUD spec and an audio spec; every code claim gets a `file:line`; run the story-1 spike (priority order, hit-stop counter, unpause, Area2D flush, AC-17d boundary, gdUnit4 install) before the review; then a lean review scoped to the 11 items.
Prior verdict resolved: Mostly (the fifth review's 10 blockers held in substance; the split was done but the size and engine-name conditions were not met, and new code-fact errors appeared)
Owner questions (recommendation): own stake for Healing (no, the boss owns it); per-foe `fill_scale` default 1.0 (yes); whole-bar spend vs proportional (keep whole bar); farm counter resets on rest only, shipped dormant (yes); boss damage budget as a paper invariant owned by Bosses (yes); keyboard A for heal (reopen with ux-designer, it removes WASD); audio telegraph priority rule into `bosses.md` (yes).
Disagreements adjudicated by the creative-director: own stake and 0.5 guarded fill rejected (override dated owner decisions); `body_entered` hazard safety unverified on both sides (spike); tick-60 asymmetry kept; AC-26b stays a non-gate and the "risky" sign-off moves to Bosses; "decided in play" holds for feel values, not for paper bounds (items 5 and 6).
Findings:
- [BLOCKING] Core Rules 6, 9, 15 / Game Feel: misdescribe `player.gd` (jump not polled first; stand-up is in CROUCH; attack plus jump gives only the jump; no same-tick control after completion with the priority-10 helper)
- [BLOCKING] Dependencies (Health): `PlayerHealth` has no `heal`, `healed` or `set_max_health`; `configure()` resets and clears the invulnerability window
- [BLOCKING] AC-28c: contradicts the 0.12 s jump buffer (about 4 ticks still live, jump fires first)
- [BLOCKING] Core Rules 9, 15 / Values: `stick_cancel_deadzone` 0.2 to 0.9 is below the InputMap deadzone 0.5; toggle stick push on tick 60 unspecified
- [BLOCKING] Formulas F1/F2/F3 / registry: max health reaches 220 (health_step 30 x 4 steps), breaking capacity, heal and F3 ranges; cap health_step at 20 or widen every range
- [BLOCKING] Values `channel_time`: at or below about 0.63 s a heal completes inside rule 10's protected window and can never be punished; raise the lower bound to about 0.7 s
- [BLOCKING] Interactions / UI / Visual-Audio: no HUD data contract (owner, payload, tick, meter-change cause, usable-state owner); rule 6 and the Visual/Audio table contradict on door and death
- [BLOCKING] Core Rules 6, 14: "reason visible on the Seeker" false for crouch, ladder, wall, ledge; held press through HURT silently dropped in hold mode
- [BLOCKING] Visual/Audio: ready chime always coincides with the filling hit; completion swell contradicts "stops within 80 ms" and "one voice"
- [BLOCKING] Acceptance Criteria: AC-17d, AC-27a/40, AC-18d pattern, unowned "not closable" ACs, AC-37 vacuous, AC-26b vs Open Question 12
- [BLOCKING] whole document: 86 KB against the 60 KB condition; engine API names outside Dependencies
- [RECOMMENDED] ADR-0003: delete "a `body_entered` hazard is probably safe"; `take_hit` only from physics-process context; hit-stop counter breaks "Enemies not changed" (file a bug for `enemy_base.gd` `_hit_stop`)
- [RECOMMENDED] Formulas / Values: capacity_floor 60 lets one charged heavy fill the bar; no joint `validate()`; start_deficit_cap 28 to 40 dead; t_full and heal_ratio undefined at fill_rate 0 and zero damage; carry_in label; rescale needs a min; rule 12 holds for stage 1 only
- [RECOMMENDED] Economy: boss damage-budget invariant owned by Bosses; `fill_scale` hook; farm counter resets on rest only; retry asymmetry; stagger heal has no stake
- [RECOMMENDED] Core Rules 14 / ADR: tabulate hidden state; epsilon in rules 8 and 15; `NOTIFICATION_UNPAUSED`; latch is toggle-only; CHANNEL vs HEAL naming (`player-controller.md`); missing `heal_loop` clip is a hard error
- [RECOMMENDED] Acceptance Criteria: no test runner (gdUnit4 absent); Logic ACs assert states the seam cannot report; AC-8 vacuous; about 12 rules without an AC; bundled ACs; unmeasurable AC-31, 27e, 14b, 22; AC-42 vs the TrainingDummy room
- [RECOMMENDED] UX / Audio: `heal_mode` options row and accessibility doc missing; minimum HUD contract; channel progress legibility; stick drift cancels toggle; swell-vs-telegraph priority in `bosses.md`; swell pause behaviour; refusal ticks; chime anti-fatigue; no audio ACs; glow luma units and HDR clamp
Reviewed-Content-Hash: design/gdd/healing.md e999a7ef97a08ddf4b2f9c7cea9a96b8bd87c311
Reviewed-Content-Hash: design/registry/entities.yaml e5dde6408bcb54311a80f136adf0b0fea54ee0be
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 504cb4c4a7b721d2b21fd518e8d4796f82e709c9
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
Reviewed-Content-Hash: design/gdd/bosses.md 025d6e45c55d02b0ffe748d22de9466fde7db4e4
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Change note — 2026-11-23 — not a review
Edited during the Pause and menus session, on the owner's decision (2026-11-23): a hit that lands during the heal channel cancels it, deals its damage and **empties the meter**, as a hit loses the soul in Hollow Knight; every voluntary cancel (letting go, a jump, dash, grapple or attack press, a toggle press or stick push) and the environmental ones (door, rest, edge slide) stay free and keep the meter. Changed: Overview, "Where the risk lives", the pillar 1 line, rules 9, 10 and 15, the state table, Edge Cases, the Feel reference and Game Feel row, AC-17a, AC-17c and AC-18, and a new Open Question 27. Context: cross-GDD review D-1 (the heal makes boss stage 1 risk-free): the heal still needs a boss attack that lands inside the channel window (Open Question 12), which now costs the bar as well as the damage. Status unchanged (Needs Revision, 11 blockers from the sixth review not yet revised); a full re-review in a fresh session is owed.

## Review — 2026-11-23 — Verdict: MAJOR REVISION NEEDED
Review mode: lean · Workflow: standard
Scope signal: L (trending XL, unchanged)
Specialists: none (lean)
Blocking items: 11 | Recommended: carried from the sixth review
Summary: Seventh review. The text changed only by owner decisions made in other sessions (a hit empties the meter; a door, exit or rest takes over); the change note confirms the sixth review's 11 blockers were not revised, and the creative-director's precondition (under 60 KB, no engine names outside Dependencies) is unmet at 88 KB. Each sixth-review blocker was checked against the current text and src/player/player_health.gd and all still stand; the changed sections (Overview through Values) were read in full and add one new blocker. The remaining ~50 KB was not re-read line by line (it would reproduce known findings on a document its own senior reviewer said must be restructured first). Main-review assessment only (lean: no creative-director).
Prior verdict resolved: No (the sixth review's blockers stand)
Findings:
- [BLOCKING] Player Fantasy ("Being hit"): says the player keeps the bar; rules 9 and 10, the exit table and the Overview now empty it on a landed hit (owner, 2026-11-23) — new
- [BLOCKING] Rule 6: "jump is polled first" contradicts rule 9's order (jump last) and player.gd; stand-up still described as a GROUND flag — carried
- [BLOCKING] Interactions / Dependencies: PlayerHealth.heal and healed do not exist (player_health.gd has configure() only) — carried
- [BLOCKING] Values: stick_cancel_deadzone 0.2-0.9 below the project deadzone 0.5; channel_time lower bound 0.5 s (needs about 0.7 s); max health to 280 (Open Question 18) — carried
- [BLOCKING] Rule 6 / Edge Cases: "reason is visible on the Seeker" false for crouch, ladder, wall, ledge — carried
- [BLOCKING] Interactions / UI: no HUD data contract — carried
- [BLOCKING] Visual/Audio: "stops within 80 ms" vs the completion swell — carried
- [BLOCKING] Acceptance Criteria: AC-17d, AC-27a/40, AC-37, AC-26b defects unrevised — carried
- [BLOCKING] Whole document: 88 KB against the 60 KB condition; engine API names outside Dependencies (e.g. Engine.time_scale line 222) — carried
- [RECOMMENDED] Rule 9 summary list (line 59) omits an exit taking over (the involuntary list names it); Dependencies does not name Rooms and transitions
- [RECOMMENDED] All sixth-review recommended items remain open
Reviewed-Content-Hash: design/gdd/healing.md b0fe575dac61be3248dfd3d464447531aec39a42
Reviewed-Content-Hash: design/registry/entities.yaml f9a1ec2541f72715a52114f805bf6d32d3ee9dcb
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/player-controller.md b5767f9f0ac6f93f3ccbd508dfb09d1787d95b0a
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md d594feb094dca1291ef14d458e4bee0cd2184c73
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md 279a4745fa7a3a1c6f3f4978ca736a4ef516e27a
Reviewed-Content-Hash: design/gdd/pause-and-menus.md aa956598e966d76f26910f4925a74e9fb87ef580
Reviewed-Content-Hash: src/player/player_health.gd 1b3845a8d619de08ff3041f78baa21f1a657b0bd

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 (revised the same day) | Recommended: 7
Summary: Eighth review, after the restructure (61 KB, presentation split out, rules rewritten as outcomes). All 11 blockers from the seventh review are resolved in the text; the ACs spot-checked against F1 to F3 hold. One blocker remained: the registry disagreed with the GDD on the channel_time range (0.5 vs 0.7 s) and on meter_capacity and capacity_floor (84 fixed vs 60-120 tunable); registry and GDD ranges were aligned in this session. No re-review of the edited text yet.
Prior verdict resolved: Yes (the seventh review's blockers)
Findings:
- [BLOCKING] Registry vs Values/F1/AC-38: channel_time range, meter_capacity output_range and capacity_floor "fixed" contradicted the GDD — revised
- [RECOMMENDED] AC-18d / ADR-0003: spikes and floor hazards call take_hit but are not on the allowlist; the body_entered "probably safe" claim is unverified
- [RECOMMENDED] Rule 10 / Values: at channel_time 0.7 s a post-hit heal is exposed for 4 ticks (0.07 s), so "can be punished" is nearly vacuous at the floor
- [RECOMMENDED] Dependencies / Open Question 15: Player controller still owes heal_deceleration, stick_cancel_deadzone, heal_mode; Enemies row lacks the foe group and calls the dependency soft
- [RECOMMENDED] design/accessibility-requirements.md does not exist; no test runner (gdUnit4)
- [RECOMMENDED] Open Questions 11 and 13: guarded boss hits fill 5x the health they remove
- [RECOMMENDED] Cross-References: stray rows after the table break at lines 284-286
- [RECOMMENDED] Status line wording and systems-index row aligned (done)
Reviewed-Content-Hash: design/gdd/healing.md 82abe4598bf5fe8bc83e27d5f4b66ea72d3f4cdc
Reviewed-Content-Hash: design/registry/entities.yaml 372853165dc992da6330584ba30a784515e58fdc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md 0afd74178f6fa44180760a752dcf3a8456d62061
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/player-controller.md b5767f9f0ac6f93f3ccbd508dfb09d1787d95b0a
Reviewed-Content-Hash: design/gdd/bosses.md 025d6e45c55d02b0ffe748d22de9466fde7db4e4
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md d594feb094dca1291ef14d458e4bee0cd2184c73
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md 279a4745fa7a3a1c6f3f4978ca736a4ef516e27a
Reviewed-Content-Hash: design/gdd/pause-and-menus.md aa956598e966d76f26910f4925a74e9fb87ef580
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8
Reviewed-Content-Hash: src/player/player_health.gd 1b3845a8d619de08ff3041f78baa21f1a657b0bd
