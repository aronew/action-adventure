# Pause and menus — Review Log

This log was written on `claude/beautiful-einstein-mpkdqk`; the GDD itself lives on `claude/gifted-ritchie-ovam4j` (unmerged at the time of the review). The hash below is of that branch's copy of `design/gdd/pause-and-menus.md`.

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; no senior-lead pass)
Blocking items: 2 | Recommended: 7
Summary: A thorough design that ties cleanly to Save points, World state, Rooms and transitions, Grid map and Parallax (every cited rule number and registry value checks out, and the formula examples compute). Both blockers sit in the controls-remapping model, where the code's real gamepad bindings meet the one-row-two-slots design.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Control remapping (rules 10, 18, Edge Cases): gamepad B is menu `cancel`, which ends a capture, so B can never be captured as a binding, yet the code's default `interact` includes gamepad B and the Reset criterion requires every default to be restorable. Decide how a gamepad player cancels a capture (an on-screen Cancel item, a timeout, or a Back/Select button reserved for capture only).
- [BLOCKING] Control remapping (rule 17): the Up row drives `move_up` and `interact`, but in code `interact` has the extra gamepad button B that `move_up` lacks. Putting B in the row's second slot would make B walk up; leaving it out leaves B with no slot. Decide: Interact gets its own row, or paired rows get per-action slots; state the default slot contents of every row (the Down row and `crouch` raise the same question).
- [RECOMMENDED] F1 and rule 13: the 480 x 270 base, whole-number scales and 3x default (1440 x 810) predate the display migration to 1920 x 1080 at zoom 4 (Terrain pipeline Open Question 9); redefine Window size and its default, or state the dependency.
- [RECOMMENDED] Rule 16: "a slider writes when it is released" is undefined for keyboard and gamepad steps; say when the file is written (leaving the slider, closing the page, quit) and add a criterion.
- [RECOMMENDED] Rule 8 and Edge Cases: menu timers (key repeat, the loading mark) must use real time, since a hit-pause can still be running (`Engine.time_scale` 0.05) when the menu opens.
- [RECOMMENDED] Rule 16: no atomic write for the settings file (write to a temp file, then rename) and no file path or format; a crash mid-write can break it.
- [RECOMMENDED] Rule 5: the Seeker entering a door is not in the list of states where pause opens (Rooms and transitions freezes the world there); say whether pause waits or opens.
- [RECOMMENDED] Stale text: Open Question 12 says `flash_limit` and `pause_inputs` will be registered, but both already are (only their `referenced_by` lists are empty); the systems index still sizes this system at S.
- [RECOMMENDED] Add a short Tuning Knobs section (`volume_step`, `shake_step`, the defaults, key repeat, the default window scale).
Reviewed-Content-Hash: design/gdd/pause-and-menus.md 38a8d9d5e4ca26272471649d4d46faee58b42edd
