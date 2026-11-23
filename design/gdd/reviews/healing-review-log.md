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
