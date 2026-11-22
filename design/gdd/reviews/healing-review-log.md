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
