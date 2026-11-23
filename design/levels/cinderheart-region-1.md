# Cinderheart (region 1): first build

Status: first playable layout, 2026-11-23. Built from `tools/level/cinderheart_layout.py`;
the rooms are `src/world/cinderheart/rooms/*.tscn` and are edited in Godot from here on.

## What we took from Hollow Knight and Silksong (principles, not layouts)

1. **Fall into the world, land in a hub.** The player starts small and safe, goes down,
   and drops into a central room they can't climb back out of the same way. The hub has a
   rest spot and several exits, so the first choice is "which way?".
2. **Show the lock before the key.** The first gate (a gap too wide to jump) is one room
   from the hub, seen early. The player learns there's a way forward they can't use yet.
3. **The key is guarded and used at once.** The ability sits behind the region's toughest
   fight so far, and the very next room needs it.
4. **Loop home.** The path out of the key room comes back into the hub through a door the
   player saw from the other side. The trip back is short; the world folds in on itself.
5. **Rests by role, not distance.** One at the start, one in the hub, one before the boss.
6. **Teach, then mix.** Enemies are met one at a time first (Ash Steps), then in groups on
   uneven ground (Cinder Run), then with a brute (Keeper's Forge).
7. **Room shapes vary.** Descents, a wide hub, a long corridor, an arena, a climb.

## The map

```
 [C1 Waking Niche] ──► [C2 Ash Steps]
   rest, start           descent, 2 grunts
                              │ (one-way drop onto a high shelf)
                              ▼
 [C7 Bellows Climb] ──► [C3 KILN HALL] ──► [C5 Glaze Bridge] ──► [C8 Antechamber] ──► Boss (Brun)
   shortcut, dash gap     HUB, rest          DASH GATE (seen early)   rest
        ▲                     │ floor hole
        │                     ▼
 [C6 Keeper's Forge] ◄── [C4 Cinder Run]
   brute + skitters        combat corridor
   DASH PICKUP
```

The intended first run: C1 → C2 → drop into C3 → try right, hit the dash gap in C5 →
back to C3 → down the hole → C4 → C6, win the dash → C7, cross its dash gap → arrive in
C3's lower left (shortcut done) → C5, dash across → C8, rest → boss.

## Numbers the layout relies on (from `player_config.tres`)

- A cell is 36 px. A jump rises about 65 px, so **one-cell steps are climbable, two are
  not**. Shelves two or more cells up are one-way.
- A run jump crosses about 137 px. A **4-cell gap** (about 155 px between the painted rock
  faces) needs the dash; the far side sits one cell higher so it can't be reached from the
  pit below, and the pit has a step back to the near side.

## Not built yet (placeholders today)

- Keeper Tavik is a brute and two skitters; the boss door leads to the existing test arena.
- No map screen, no collectibles, no breakable walls or levers, no kill planes, no save.
- Rest spots heal and set the respawn point (press Up). Enemies come back on room entry.
