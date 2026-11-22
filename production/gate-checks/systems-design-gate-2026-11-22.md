# Gate Check: Concept → Systems Design

**Date**: 2026-11-22
**Checked by**: gate-check skill (`workflow: standard`, `review_mode: lean`, `qa.level: standard`, `team.size: individual`)
**Recorded stage**: Concept (`project.yaml`, `production/stage.txt`), left unchanged

## Required Artifacts: 0/1 present
- [ ] `design/gdd/game-concept.md`: MISSING. Required at `standard`. The project has `design/game-brief.md`, the `minimal` tier's gate target.

Recommended at `standard` (not blocking):
- [ ] Game pillars: absent (the brief's `## Keep` and `## Avoid` are empty)
- [x] Visual Identity Anchor: art bible exists (Draft, sections 1-4); the gate looks for the anchor inside the concept doc
- [ ] Concept prototype with a REPORT.md: none (`prototypes/` holds engine spikes only)

Also present: engine setup (`project.yaml`), art bible, systems index. `brainstorm` and the concept review cannot be detected from disk.

## Quality Checks: 1/4 passing
- [x] Core loop is described (brief, Core loop)
- [ ] Target audience identified: stated but marked *(guessed)*
- [ ] Concept reviewed: no concept review exists (reviews are per-GDD)
- [ ] Visual Identity Anchor with a one-line rule and 2 principles: not in a concept doc

## Director Panel Assessment (2 of 4, `workflow: standard`)
Technical Director: CONCERNS. Nothing technical blocks entering Systems Design; the concept doc is missing and several brief entries are *(guessed)*; stale installed-version field in `VERSION.md`; gdUnit4 configured but not installed; performance budgets undocumented (acceptable now).
Producer: CONCERNS. Concept doc missing and no confirmed audience or pillars; recorded stage two phases behind; stories 001, 002, 003 and 005 closed under looser test rules with no unit tests; combat, guard-break, enemies, bosses and controller have no GDD; review churn (level design 18, parallax 11, terrain 8, about 80 open recommended items); kill condition never checked; scope under control.
Panel: 2 of 4. Creative and Art perspectives not consulted. Set `modes.workflow: full` (or raise `modes.rigor`) for the complete panel.

## Blockers
1. `design/gdd/game-concept.md` is missing. Run `/brainstorm` to write it at this tier.

## Recommendations
- Confirm the guessed audience, pillars and kill condition; fill `## Keep` / `## Avoid`.
- `/design-review` the concept once it exists.
- Reconcile the systems-index Progress Tracker (pause and menus shown "in review"; "Design docs reviewed: 9" against 10 review logs).
- Backfill or explicitly waive Test Evidence for stories 001, 002, 003, 005.
- Write GDDs for combat and guard-break to match what is built.
- Cap design-review rounds: one per GDD, then one batched revision pass.
- Decide whether the kill-condition check has been met.

## Verdict: FAIL
A required artifact is missing; a FAIL is never overridden into a stage change.

Chain-of-Verification: 5 questions checked (3 by tool: brief `## Keep` / `## Avoid` empty, epic has 16 stories, systems-index tracker stale), verdict unchanged.
