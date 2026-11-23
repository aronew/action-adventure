# Review log: Pause and menus

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 3 | Recommended: 8
Summary: A coherent, well cross-referenced design with three implementation holes in its own rules: the Up row could not drive both `move_up` and `interact` (interact's gamepad B would become up), gamepad B was both the fixed `cancel` and a bindable default, and a quit to the title had no world teardown. All three were revised in the same session on the owner's decisions; the recommended items are open.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design rule 17: Up row driving `move_up` and `interact` would make interact's B an up press (revised: Interact has its own row; Up and Interact may share an input)
- [BLOCKING] Detailed Design rules 10, 18, 19: gamepad B both `cancel` and interact's default, uncapturable (revised: B reserved like Start, interact's default B dropped)
- [BLOCKING] Detailed Design rule 4: quit to the title left the freeze, pending respawn, `RELOAD_DELAY` and `Engine.time_scale` undefined (revised: teardown rule, edge case, criterion)
- [RECOMMENDED] Detailed Design rule 14, F4: no mechanism or measurement for player-driven hit flashes against `flash_limit`
- [RECOMMENDED] States and Transitions: Escape/Start routing in Options, Capture and Prompt; no state for the first arrival after Continue/New game
- [RECOMMENDED] Detailed Design rule 16: keyboard/gamepad slider writes, atomic write, newer-format out-of-range values
- [RECOMMENDED] Game Feel: key repeat values only targets; menu timers on unscaled time
- [RECOMMENDED] Acceptance Criteria: no criteria for window close, fullscreen refused, unknown action kept, focus loss during capture
- [RECOMMENDED] Visual/Audio: freeze audio differs from Grid map's (music keeps playing)
- [RECOMMENDED] UI Requirements: hint-line device, cursor visibility and art, drag-resize, physical pixels in F1
- [RECOMMENDED] Dependencies: Rooms and transitions and index row 22 still owed; add a Tuning Knobs table
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Owed outside this GDD: Save points' rest glyph "B or D-pad up", `PlayerInputBindings` interact B, registry `pause_inputs` notes.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/pause-and-menus.md 38a8d9d5e4ca26272471649d4d46faee58b42edd
Reviewed-Content-Hash: design/registry/entities.yaml 54ae8bf7a7c531a21947aefc5034f4a369ef81bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 192efae4990edb88dff67911cb8ae45a00834c92
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 38c89c37c445fb0a6f50acd627ce31811ebe0568
Reviewed-Content-Hash: design/game-brief.md 56883b7b1e312ae6e2a9404665adf58563994694
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 13
Summary: The first review's three blockers were fixed, but the shared-input exception it added for the Up and Interact rows broke the rebinding swap: an input both rows hold had no single swap target, and a swap could leave a third row sharing an input with the sibling, which the load check then reset. The owner resolved it by dropping control remapping from the first scope: fixed controls (rule 17's table, the code's bindings with interact's gamepad B dropped, plus `pause` and `map`) and a read-only controls page. Four recommended items were applied in the same session; nine stay open.
Prior verdict resolved: Yes (all 3 first-review blockers confirmed fixed)
Findings:
- [BLOCKING] Detailed Design rule 19, with rule 17: swap undefined for an input held by both Up and Interact, and a swap could leave a third row sharing it with the sibling (resolved: remapping dropped, fixed controls, rules 17-20 rewritten, capture state, remapping edge cases and criteria removed; remapping in Open Question 11)
- [RECOMMENDED] Detailed Design rule 4: teardown order against World state's empty record (applied: world freed before the record is dropped)
- [RECOMMENDED] Detailed Design rule 9: an input pressed while the menu is open and still held at close, gamepad A being accept and Jump (applied, with a criterion)
- [RECOMMENDED] Formulas F2, F3, F4: step lists against "a divisor of 100"; `flash_limit` given a 0-3 range as a constant (applied)
- [RECOMMENDED] Dependencies, Open Questions 12: stale note on index row 22 (applied)
- [RECOMMENDED] Detailed Design rule 14, F4: event-driven flashes (combo hits) not counted; charge glow strobes at 10 Hz with the setting Off by default (carried)
- [RECOMMENDED] States and Transitions: Escape and Start routing in Options and Prompt (carried)
- [RECOMMENDED] States and Transitions, rules 2, 5: no state for the first arrival after Continue or New game (carried)
- [RECOMMENDED] Detailed Design rule 16: keyboard and gamepad slider writes, atomic write, newer-format out-of-range values (carried)
- [RECOMMENDED] Game Feel: key repeat only a target; menu timers on unscaled time (carried)
- [RECOMMENDED] Acceptance Criteria: no criteria for window close or fullscreen refused (carried; the capture and unknown-action ones went with remapping)
- [RECOMMENDED] Visual/Audio: freeze audio undecided while Grid map keeps music playing (carried)
- [RECOMMENDED] UI Requirements, F1: hint-line device, cursor, drag-resize, physical pixels (carried)
- [RECOMMENDED] Dependencies: no Tuning Knobs table; Rooms and transitions entry still owed (carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Owed outside this GDD: Save points' rest glyph, `PlayerInputBindings` (interact B, `pause`, `map`), registry `pause_inputs` notes, Rooms and transitions Dependencies entry.
Receipt note: the reviewed version was never committed, so the GDD hash below is the HEAD blob (the first review's version). It differs from the revised document, which therefore reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/pause-and-menus.md 38a8d9d5e4ca26272471649d4d46faee58b42edd
Reviewed-Content-Hash: design/registry/entities.yaml 54ae8bf7a7c531a21947aefc5034f4a369ef81bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 192efae4990edb88dff67911cb8ae45a00834c92
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 38c89c37c445fb0a6f50acd627ce31811ebe0568
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md f2fdefbae75b634eed2663f9d76f83fe691fb436
Reviewed-Content-Hash: design/game-brief.md 56883b7b1e312ae6e2a9404665adf58563994694
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-21 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 9
Summary: The second review's blocker is resolved by dropping remapping, and the document is internally consistent: rule 17's bindings match `PlayerInputBindings` (with the stated `interact` change and the new `pause` and `map`), the cited rules in Save points, World state, Rooms and transitions, Grid map and Parallax line up, the registry values match and the F1 to F4 examples compute. What remains is detail: F1 predates the 1920 x 1080 display migration, event flashes have no automatable rule against `flash_limit`, and the freeze must also stop shader `TIME`.
Prior verdict resolved: Yes (second review's one blocker; the first review's three still hold)
Findings:
- none
- [RECOMMENDED] Formulas F1, rule 13: the 480 x 270 base, whole-number scales and 3x default (1440 x 810) against Terrain pipeline's 1920 x 1080 at zoom 4 and its Open Question 9 (carried)
- [RECOMMENDED] Detailed Design rule 14, F4, Acceptance Criteria: hit, finisher and guard-break flashes are events, not step_time alternations, so only a played capture checks them; rate-limit flash events to 1 / (2 x flash_limit) s so it is automatable (carried)
- [RECOMMENDED] Open Question 1, Acceptance Criteria: shader `TIME` keeps advancing while the tree is paused (the fog shader uses it), a third thing the freeze must stop besides `Engine.time_scale` and `create_timer`; world-clock shaders need their time fed from the world clock
- [RECOMMENDED] Detailed Design rule 16: a slider "writes when released" is undefined for keyboard and gamepad steps (carried)
- [RECOMMENDED] Game Feel, Edge Cases: menu timers (key repeat, loading mark) on real time, since a hit-pause can still be running when the menu opens (carried)
- [RECOMMENDED] States and Transitions, rule 5: no state for the first arrival after Continue or New game, no Start routing in Options or a Prompt, and no word on pause during the Seeker's door-entry clip (carried, door entry new)
- [RECOMMENDED] Acceptance Criteria: none for window close or fullscreen refused (carried)
- [RECOMMENDED] Interactions, Cross-References, rules 14 and 17: stale text (the World state row still says bindings; rule 14's "20 a second" is steps, 10 flashes; rule 17 says one change from the code but also adds `map` and `pause`; Open Question 12's index bullet is done)
- [RECOMMENDED] Visual/Audio, UI Requirements, Dependencies: freeze audio undecided (Grid map keeps music playing), hint-line device, cursor, drag-resize and physical pixels, a Tuning Knobs table (carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard); the Edge Case "Quit to title with the pause open over … a pause held for a fade-in" cannot happen, as a held pause is not an open menu.
Reviewed-Content-Hash: design/gdd/pause-and-menus.md 8789f9cfab9ccec5b5d3b8aec845e061793ed77b
Reviewed-Content-Hash: design/registry/entities.yaml 54ae8bf7a7c531a21947aefc5034f4a369ef81bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 192efae4990edb88dff67911cb8ae45a00834c92
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 38c89c37c445fb0a6f50acd627ce31811ebe0568
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md f2fdefbae75b634eed2663f9d76f83fe691fb436
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md cc8a514f6192d296c7df733d70c67d328bbd77d8
Reviewed-Content-Hash: design/game-brief.md 56883b7b1e312ae6e2a9404665adf58563994694
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; no agents spawned)
Blocking items: 1 (revised the same day) | Recommended: 6 (9 carried items counted as one)
Summary: Fourth review, after the cross-GDD review of 2026-11-23 (C-2). F1 to F4 and the registry values (`flash_limit` 3, `pause_inputs`) hold; the one blocker was rule 17's fixed-controls table, stale against the owner's 2026-11-23 layout. Revised the same day with three owner decisions taken in this review: menus on the arrow keys only, `heal` on the A key and gamepad B, and gamepad B no longer reserved in play (rule 19 keeps only Escape and Start; B is `cancel` in menus and the map, which withhold input), so `rapid_fire` stays on Y. Follow-on edits approved and made in player-controller.md, healing.md, save-points-and-save-load.md and the registry's `pause_inputs` notes.
Prior verdict resolved: Yes (third review APPROVED; its 9 recommended items remain open)
Findings:
- [BLOCKING] Rule 17 table, its note, Edge Cases L239, AC L374: WASD movement and crouch, `interact` on W, no `heal` row, against player-controller.md's input table. Revised to the 2026-11-23 layout with heal on the A key and gamepad B (owner)
- [RECOMMENDED] Interactions, Dependencies, Bidirectional check, Cross-References: Player controller and Combat said to have no GDD. Revised
- [RECOMMENDED] Rule 20, Open Question 12: Save points' rest glyph is done. Revised
- [RECOMMENDED] Open Question 5: premise out of date; Rooms and the controller's Damage block protect the Seeker until the fade-in ends
- [RECOMMENDED] Options: healing.md asks for a `heal_mode` (hold or toggle) setting that rule 13's table does not hold
- [RECOMMENDED] Combat does not list this system (shake and flash requirements)
- [RECOMMENDED] Carried from the third review: F1 vs the 1920 x 1080 migration, automatable flash events, shader TIME in the freeze, slider writes on keys, menu timers on real time, arrival state and door-entry pause, window-close and fullscreen-refused ACs, freeze audio and hint-line device
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at `standard`)
Reviewed-Content-Hash: design/gdd/pause-and-menus.md aa956598e966d76f26910f4925a74e9fb87ef580
Reviewed-Content-Hash: design/registry/entities.yaml d1898ffe66580263b8666942a93138dcfd3a0616
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 2d8206c28ee7195ad626719bcdddb7781b4de0b3
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md d3fbdfdf2fe6a357a04860a017ff4be251f272de
Reviewed-Content-Hash: design/game-brief.md dc436c0b723420a0c7dbf2890f03b2771e3fc433
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 319821e70abf7cca3ebffe7e3d3bd8b48acca4ca
Reviewed-Content-Hash: design/gdd/player-controller.md bb4d01ede7c8e08fbfe7c9c58f0021616fa8a5f3
Reviewed-Content-Hash: design/gdd/healing.md 1fb4e240b8b05464b727dfca70910cf1cdcd2f51
Reviewed-Content-Hash: design/gdd/combat.md 0afd74178f6fa44180760a752dcf3a8456d62061
