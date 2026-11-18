# Playtest Record: Story 006 — Double jump and grapple found in the world

**Story**: `production/epics/guardbreak/story-006-ability-gates.md`
**Date**: 2026-11-18
**Build**: branch `claude/beautiful-einstein-mpkdqk`, files as stamped in `production/qa/evidence/story-006-ability-gates/stamp.txt` (all unchanged at close)
**Scene**: `src/test_rooms/gate_test_rooms.tscn`
**Tester**: the project owner, playing on their own machine (Godot 4.7.2). Recorded from their answers in the `/story-done` session; this is a human playtest, not an automated test.

## What was checked

| Check | Result (tester's answer) |
|---|---|
| The gate room starts with both abilities locked; each pickup grants its ability once | Passes |
| Without the double jump, a second jump in the air does nothing; after the pickup, the double jump works as in story 001 | Passes |
| The mid shelf cannot be reached without the double jump, nor the summit without the grapple, however tried (wall jumps off the side walls, dashes, dash-jumps) | Passes: the gates hold |
| Every area can be left back toward the start whatever is owned (no soft-lock) | Passes: never stuck |

## Supporting evidence (captured in the cloud session with Godot 4.7.2, Compatibility renderer)

- `production/qa/evidence/story-006-ability-gates/01-start-locked.png`: HUD "Double jump: locked  Grapple: locked" at the start
- `02-no-double-jump-misses-shelf.png`: a full jump from under the shelf without the double jump peaks at feet y 333 against the shelf top at y 284
- `03-double-jump-owned.png`, `04-mid-shelf-grapple-owned.png`: each pickup grants its ability and lights its sign
- `05-summit.png`: the summit beside the grapple anchor

## Tester's design notes (for the real world, not this test room)

> In a real metroidvania it makes sense to see something you cant yet get up to that you need double jump for, or a grapple section you cant get to until you get grapple ability. How you obtain them though should be done with more planned out thought, like through a boss, or some sort of found location not just right in front of the gate itself. the top metroidvania games use these systems you see an ability gate you know at some point you'll have to return to that location to get whatever you need. in a metroidvania game exploration and curiosity comes first.

Carried into the world design: `design/game-brief.md` (In your words) and level design (story 012).
