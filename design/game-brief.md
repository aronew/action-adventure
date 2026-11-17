# Game Brief: Guardbreak *(provisional — working title, replace with your game's name)*

## In your words
side scrolling action adventure metroidvania style game that has similar level design of Nine Sols, with satisfying combat and amazing animations and movement. I have the lore

Picked concepts: "Break the guard" + "One move set, two jobs".

im going to get a character from itch.io who has

* Combat that feels good out of the box: a 3-hit combo drawn to flow together, plus jump, up, down and heavy attacks, everything you may want for melee variety.

* Crisp sword slashes with sparks and glow, baked onto the sprites, and on their own FX layer so you can recolour or detach them, drawn for fast stylish visuals.

* A charged heavy attack: the whole blade is swallowed in strobing light, then unleashes a massive arc upon release.

* A full movement set: idle, run, dash, double jump, wall slide, climb, crouch, grapple, enter door, everything you need for a great character controller.

* Ranged options: a bow that loops into endless multi-shots, and in PRO you get three pre-made spell casts with all the animations and FX baked in OR on separate layers so you can edit or replace them with your own.

* 4 main palettes, Void, Ember, Frost and Bone, each with their own matching FX. Great for adding player customization options, alternate elemental power-ups, and even Multiplayer possibilities!

* PRO BONUS: the Dream Seeker, a fifth special palette with a custom  holographic dream aesthetic, perfect to add a very unique vibe to your protagonist or as a special empowered state swap.

so the way they have their controls for this character its Space or Z= Jump, X= Attack, Shift or C = Dash, E= Grapple, X Hold = Heavy, Down arrow or W + X= air: Pogo, F= Bow, Q= Cast/Charge, V= Rapid Fire. and have the grapple fling him about his body height higher than what he grapples off of d

one thing too is I want to use the bone sprite not the void sprite

**Pitch:** A hand-animated side-scrolling metroidvania where one move set breaks enemy guards in duels and carries you through a hand-built, ability-gated world. *(guessed)*

**Genre:** 2D side-scrolling action-adventure metroidvania.

**Controls:** Keyboard as in the Seeker pack's playable test: Space or Z jump, X attack, X hold heavy, down + X in the air pogo, Shift or C dash, E grapple, F bow, Q cast/charge, V rapid fire; arrows or WASD move, Up enters doors *(guessed)*. Gamepad too.

**Question:** Does the one move set feel good in a fight and in a room for ten minutes? *(guessed)*

**Hooks:** The charged heavy, where the blade is swallowed in light and released in a huge arc, is the guard-breaker. Every movement ability opens rooms and adds an attack angle. *(guessed)*

**Intent:**

## Look and references
- Look: 2D pixel side view using the itch.io character pack, in the Bone palette. Sword FX on their own layer, sparks and glow on hits. The other palettes (Void, Ember, Frost) and the Dream Seeker are for power-ups later.
- References: Nine Sols (level design, per your words).
- View: 2D · Camera: side-on, follows the player, locks per room. *(guessed)*

## First minute
Wake in a quiet room, learn move, jump and dash by crossing a gap, then meet one guarded enemy: break its guard and land the first finisher. *(guessed)*

## Challenge
A tougher guarded enemy about one minute in; a loss sends you back to the last save point. Later fights add faster guards and mixed groups. *(guessed)*

## Core loop
- Fight: wear down a guard, break it, land a finisher.
- Gain: a new ability or a route that opens.
- Explore: use the ability to reach new rooms, then fight again.

## Goal & fail state
- Goal: reach and beat the final boss of the first region. *(guessed)*
- Fail: health reaches zero; respawn at the last save point. *(guessed)*

## Features
- [x] Movement from the pack: run, dash, double jump, wall slide, climb, crouch, grapple, enter door
- [ ] Melee: 3-hit combo, jump, up and down attacks, heavy attack
- [ ] Guard-break: enemies have a guard meter; the charged heavy shatters it and opens a finisher
- [ ] 2–3 enemy types with readable, telegraphed attacks
- [ ] One boss fight
- [ ] Double jump and grapple found in the world, each opening routes and new attack angles *(guessed)*
- [ ] Rooms with doors, save points and a grid map that fills in

## Your systems
- combat · in the slice
- movement · in the slice
- level design · thin stand-in *(guessed)*
- bow · later *(guessed)*
- spells (PRO) · later *(guessed)*
- elemental palette power-ups · later *(guessed)*
- Dream Seeker empowered state · later *(guessed)*

## Keep
-

## Avoid
-

## Out of scope
- Multiplayer, crafting, loot and shops
- Full story and dialogue (lore comes after the core feels good)
- More than one region; localization
- Bow, spell casts, elemental palette power-ups and the Dream Seeker state (after the core feels good)

## Build order
1. Import the character and wire the controller to the pack's animations in a blank room; then movement and the 3-hit combo
2. Guard-break fight against one enemy
3. Second enemy type and a boss
4. One ability gate with its two abilities
5. Room transitions, save points and the map

---
**Kill condition:** If the guard-break fight isn't fun in one arena after two tuning rounds. *(guessed)*

**Who it's for / what they feel:** Players of tight 2D action who want animation-heavy duels and a connected world. *(guessed)*

**Games you love / don't:** Love Nine Sols (level design).
