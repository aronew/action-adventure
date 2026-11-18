# Review Log: Level design and world layout

## Review — 2026-11-18 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 6 | Recommended: 8
Summary: Strong, well-sourced structure (world model, key order, workshop rule, topology), but the gate-fit formulas disagreed with the measured movement values and the key table conflicted with the one-boss, one-region scope. All 6 blockers were revised in the same session; the key-to-region mapping is a recommendation awaiting owner confirmation (Open Question 11). The hash stamps below are of the GDD as reviewed, before those revisions, so the next review reads it as changed and runs in full.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design (key table): dash gate "about 90 px" contradicted F1's 120-150 px window; a plain run-jump crosses 90 px (fixed)
- [BLOCKING] Formulas (F1): coyote time (14 px) left a perfect run-jump leaking at stated margins; run_jump_distance now about 122, gap_margin 8-15 (fixed)
- [BLOCKING] Formulas (F2) and Acceptance Criteria: "wall-jump reach" was 3 px in code; added cling_exclusion_px and an open-air test (fixed)
- [BLOCKING] Detailed Design (key table, rules 1/20): dash from "the region's boss" and grapple from "a later boss" conflicted with one boss per region and the brief's goal; resolved by the owner's 5-region count, mapping is a Rec pending confirmation (addressed)
- [BLOCKING] Formulas (F5): speedup undefined for routes impassable before the key; rule 22 now splits faster routes from newly opened routes (fixed)
- [BLOCKING] Dependencies / Formulas (F1-F3): gate dimensions overlapped Ability gating's ownership; kept here as provisional with a handoff note (fixed)
- [RECOMMENDED] Detailed Design: rule 9 ("within 3 rooms") vs its criterion ("3 rooms or more") is off by one
- [RECOMMENDED] Detailed Design: rule 15 "next to a shortcut" vs criterion "within one room"; rules 15/16 hardcode 7 while F4 makes it a knob
- [RECOMMENDED] Formulas (F4): "main route", boss-room screens and multi-screen routing are ambiguous
- [RECOMMENDED] Formulas: no numeric spec for the wall-cling shaft or dash-through barriers (consider F6)
- [RECOMMENDED] Detailed Design: mini-boss has no role or reward; F5 cites enemy respawns that nothing defines
- [RECOMMENDED] Acceptance Criteria: untestable or missing criteria (line 307 self-contradiction, "one objective", "player notices", rule 12 vs the leak check; no criteria for rule 8 twice, rule 1 screen multiples, no-backward states, Game Feel targets)
- [RECOMMENDED] Dependencies: five hard upstream GDDs do not exist yet; track each contract in the systems index
- [RECOMMENDED] Overview: brief says "I have the lore" while the GDD and index say lore is not provided; confirm
Reviewed-Content-Hash: design/gdd/level-design.md 62f2c89e0063dc4e58ed7eb0a129af5f44fe485f
Reviewed-Content-Hash: design/registry/entities.yaml dfeacb02917f751cb1dfd88cf490c7ec3d8d2d0f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/game-brief.md f8a91ee620b183a3c91062efaaa6bcc0ac8ff685
Reviewed-Content-Hash: design/research/metroidvania-world-design.md 4e070deab986ec3cae1a6a0173245f04901b0e67
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
