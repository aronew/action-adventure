# Epic: Guardbreak

> **Source**: `design/game-brief.md` (minimal tier: the brief is the design record; no GDD, ADRs or control manifest)
> **Engine**: Godot 4.7.2 · GDScript · Risk HIGH (see `docs/engine-reference/godot/VERSION.md`)

## Goal

A hand-animated side-scrolling metroidvania where one move set breaks enemy guards in duels and carries you through a hand-built, ability-gated world.

## Scope

The brief's 7 Features, then every system from `## Your systems` thin, then deepened one system at a time. Order follows the brief's Build order:

1. Import the character and wire the controller to the pack's animations; movement and the 3-hit combo
2. Guard-break fight against one enemy
3. Second enemy type and a boss
4. One ability gate with its two abilities
5. Room transitions, save points and the map

Out of scope for the core (built only by the thin and deepen stories, after the core feels good): bow, spell casts, elemental palette power-ups, Dream Seeker state. Never in scope: multiplayer, crafting, loot, shops, full story and dialogue, more than one region, localization.

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Seeker controller and movement set | Visual/Feel | Complete | N/A |
| 002 | Melee: 3-hit combo, air/up/down attacks, charged heavy | Visual/Feel | Complete | N/A |
| 003 | Guard-break | Logic | Complete | N/A |
| 004 | Two or three enemy types with telegraphed attacks | Logic | Complete | N/A |
| 005 | First-region boss fight | Logic | Ready | N/A |
| 006 | Double jump and grapple found in the world | Integration | Ready | N/A |
| 007 | Rooms, doors, save points and the grid map | Integration | Ready | N/A |
| 008 | Bow, thin | Logic | Ready | N/A |
| 009 | Spell casts, thin | Logic | Ready | N/A |
| 010 | Elemental palette swap, thin | Visual/Feel | Ready | N/A |
| 011 | Dream Seeker empowered state, thin | Visual/Feel | Ready | N/A |
| 012 | Deepen level design | Integration | Ready | N/A |
| 013 | Deepen bow | Logic | Ready | N/A |
| 014 | Deepen spell casts | Logic | Ready | N/A |
| 015 | Deepen elemental palette power-ups | Visual/Feel | Ready | N/A |
| 016 | Deepen Dream Seeker state | Visual/Feel | Ready | N/A |

## Notes

- Character art: `assets/characters/seeker/` (Hooded Seeker PRO). Its `Animation_Guide.txt` holds the frame timings, hit frames and feet pivots the stories cite. The art's license forbids sharing it, so this repo must stay private.
- The pack has no enemy or boss art. Stories 004 and 005 use placeholder art until some exists.
