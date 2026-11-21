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
