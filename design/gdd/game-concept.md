# Game Concept: Guardbreak *(working title)*

*Created: 2026-11-22*
*Status: Draft, revised 2026-11-22 after `/design-review` (NEEDS REVISION: MVP re-baselined, scope constraint stated, pillars and anti-pillars confirmed by the owner)*

---

## Elevator Pitch

> It's a hand-built 2D metroidvania where you chain movement abilities that
> double as attacks, through ability-gated regions of a painted underworld, to
> break the guard of each region's boss.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | 2D side-scrolling action-adventure metroidvania |
| **Platform** | PC (Steam / Epic), keyboard and gamepad |
| **Target Audience** | Explorers who also want Achievement (see Target Player Profile) |
| **Player Count** | Single-player |
| **Session Length** | 30-120 minutes |
| **Monetization** | None yet |
| **Estimated Scope** | Large (24-36+ months, solo; estimate, not measured). No fixed deadline (owner, 2026-11-22) |
| **Comparable Titles** | Hollow Knight, Hollow Knight: Silksong, Ori and the Blind Forest, Ori and the Will of the Wisps, Nine Sols. Sales figures: not researched |

---

## Core Fantasy

You are the Seeker: small in a vast, patient world. Each time you come back to
a place you could not reach before, your movement has grown enough to open it.
The promise is curiosity paid off: you see a gate, you know you will return,
and the return is earned by mastery, not by grinding.

---

## Unique Hook

Like Hollow Knight's connected, secret-filled world, *and also* movement
abilities that double as attacks (pogo, dash), with guard-break duels as the
boss signature. Only bosses, mini-bosses and the one tutorial foe have a guard;
ordinary enemies have health only.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** | 3 | Painted world, baked sword FX, sparks and glow on hits, warm light from below |
| **Fantasy** | 6 | The Seeker returning, stronger, to places once out of reach |
| **Narrative** | 5 | Lore carried by the world and its rooms, not exposition |
| **Challenge** | 2 | Traversal that gets harder by region; guard-break duels |
| **Fellowship** | N/A | Single-player |
| **Discovery** | 1 | Ability-gated routes, secrets, puzzles, a map that fills in |
| **Expression** | 4 | Chained movement and combat lines the player chooses |
| **Submission** | 7 | Quiet exploration rooms and save-point rests |

### Key Dynamics (Emergent player behaviors)

- Players chain dash into pogo into strike and look for cleaner lines through a room.
- Players note gates they cannot open yet and return when they hold the key.
- Players replay rooms to find secrets and better routes.

### Core Mechanics (Systems we build)

1. Movement set: run, jump, dash, double jump, wall cling, grapple
2. Melee: 3-hit combo, heavy, pogo, with some abilities doubling as attacks
3. Guard-break on bosses, mini-bosses and the tutorial foe
4. Ability-gated world with rooms, doors, save points and a grid map
5. Collectible upgrades

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** | The player chooses the route and the order of secrets | Core |
| **Competence** | Chained movement is mastered over time; bosses are read and beaten | Core |
| **Relatedness** | Lore found in the world; no companions | Minimal |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers**: collection, upgrades, boss defeats, map completion
- [x] **Explorers**: discovery, secrets, working out how the world fits together
- [ ] **Socializers**: not served (single-player)
- [ ] **Killers/Competitors**: not served (no PvP or leaderboards)

Secondary appeal: lore-seekers who assemble the world from rooms and fragments.
Not for: players who want loot grind, crafting or builds, or who dislike
precision platforming.

### Flow State Design

- **Onboarding curve**: wake in a quiet room, learn move and jump, meet the tutorial foe, break its guard and land the first finisher. Dash comes later, found in the world.
- **Difficulty scaling**: each region adds harder traversal and faster guards; later fights add mixed groups.
- **Feedback clarity**: hit sparks and baked FX, guard-break shatter, the map filling in, and new ability colours marking the gates they open.
- **Recovery from failure**: respawn at the last save point; death costs only the walk back.

---

## Core Loop

### Moment-to-Moment (30 seconds)

Run, jump, dash and strike as one chained line. It is satisfying when inputs
link without stalls and every hit and landing gets feedback. Pogo and dash are
the "two jobs": they carry the Seeker across a gap and also land a hit. Double
jump and wall cling stay pure traversal.

### Short-Term (5-15 minutes)

Enter a room, read its layout, and chain a route through hazards and an enemy
encounter. Along the way, spot a gate or secret that cannot be opened yet:
read, execute, spot a promise.

### Session-Level (30-120 minutes)

Push through a region, find a gate, and learn the key is elsewhere. Reach a
mini-boss or boss, earn the ability, then backtrack with it to the places
noted. Save points are the natural stopping points; the hook back in is the
list of gates seen and not yet opened.

### Long-Term Progression

Region 1 gives the dash (Keeper Tavik, mini-boss); its boss is Brun, the
Stacker. Double jump comes from region 2, wall cling from region 3, grapple
from region 4. Collectible upgrades and a filling map run alongside. The full
game is 8 regions, one per biome.

### Retention Hooks

- **Curiosity**: gates seen but not yet opened; unexplored rooms
- **Investment**: abilities, upgrades and map progress held at save points
- **Social**: none
- **Mastery**: cleaner lines through rooms; faster guard-breaks

---

## Game Pillars

*Pillars 1-5 and the design tests below confirmed by the owner, 2026-11-22.*

### Pillar 1: Movement Is the Mastery

Flowing momentum, executed precisely.

*Design test*: choosing between more content and tighter movement feel, feel wins.

### Pillar 2: Every Gate Is a Promise

The player sees a gate, knows they will return, and the key is never beside the lock.

*Design test*: if the ability that opens a gate sits near it, move it to a boss or a found place.

### Pillar 3: Curiosity Pays

Secrets, puzzles and upgrades reward looking, not grinding.

*Design test*: choosing between a signpost and a hidden reward, the hidden reward wins.

### Pillar 4: Two Jobs, Not One

Abilities that open the world also give the player something to do in a fight, where they fit.

*Design test*: a new ability must open a route; if it can also hit, it should.

*Which abilities*: pogo and dash attack as well as carry (owner, 2026-11-22). Double jump and wall cling are pure traversal. Whether grapple also hits is an open question.

### Pillar 5: A Place Worth Running Through

A beautiful world that is a pleasure to move in.

*Design test*: when decoration competes with readable ground and gaps, readability wins.

Tensions kept on purpose: pillar 1 against pillar 3 (hard traversal gating
secrets), and pillar 2 against pillar 3 (promised gates against hidden things).

### Anti-Pillars (What This Game Is NOT)

*Confirmed by the owner, 2026-11-22; anti-pillar 2 reworded the same day.*

- **NOT guards on ordinary enemies**: every fight would become a duel and break pillar 1's flow. Guards belong to bosses, mini-bosses and the one tutorial foe.
- **NOT loot grind or crafting**: they would replace the rewards of pillars 2 and 3 with grind. Collectible upgrades are found in the world. A merchant or a currency may exist, as in Hollow Knight, only if it never stands in for a found reward (owner, 2026-11-22).
- **NOT abilities handed over at the gate**: it would kill the promise of pillar 2.
- **NOT story and dialogue before the core feels good**: lore reaches the player through the world (pillars 3 and 5), not exposition.

---

## Visual Identity Anchor

Source: `design/art/art-bible.md` (Draft, 2026-11-20), Section 1.

- **The rule**: *Hard edges and light values mark what you can touch or hurt; soft edges and dark values mark what you can't.*
- **Principle 1, crisp means contact**: the Seeker, enemies and hit FX are crisp pixel art at a whole-number scale; everything else is soft. *Test: if it can hold, hurt or be struck, it is crisp or hard-edged.*
- **Principle 2, the greyscale order is fixed**: brightness runs Seeker, enemies, play-layer floor edges, mid layers, then back layers and foreground framing darkest. *Test: keep the value that leaves the room readable in greyscale.*
- **Principle 3, combat owns the light**: sword arcs and guard-break sparks are the brightest moments on screen. *Test: ambient effect versus combat effect, the sword arc and guard break win.*
- **Colour philosophy**: ambient light is always warm and from below. Orange (dash), chalk-yellow (double jump), copper-green (wall cling) and violet (grapple) mark each key's gates, pickup, icon and map markers.
- **Tagline (not a rule)**: *the one pale, crisp thing in a warm, painted dark.*

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Hollow Knight | Connected world, ability gates, secrets | Movement abilities that double as attacks | Validates the exploration spine |
| Hollow Knight: Silksong | Fast, precise movement and challenge | Guard-break duels as the boss signature | Validates the movement-challenge ramp |
| Ori (both games) | Flow, a beautiful world that is enjoyable to move through | Readability-first light tiering | Validates traversal as the main pleasure |
| Nine Sols | Level design, guarded duels | Guards only on bosses and mini-bosses | Validates the guard-break boss fight |

**Non-game inspirations**: kilns, glaze and ash (region 1's visual direction).

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | Not researched (18-35 assumed, guessed) |
| **Gaming experience** | Mid-core to hardcore |
| **Time availability** | 30-120 minute sessions |
| **Platform preference** | PC |
| **Current games they play** | Ori and the Blind Forest, Ori and the Will of the Wisps, Hollow Knight, Hollow Knight: Silksong, Nine Sols |
| **What they're looking for** | A beautiful, challenging world that rewards curiosity and mastery of movement |
| **What would turn them away** | Loot grind, imprecise controls, hand-holding, ability pickups next to their gates |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.7.2 (the owner's stated preference, 2026-11-22) |
| **Key Technical Challenges** | Tuning movement and attacks so abilities that double as attacks stay fair; the 1920x1080 painted world with a 4x pixel cast; frame capture speed in software GL; gdUnit4 configured but not installed |
| **Art Style** | Pixel cast in a painted world |
| **Art Pipeline Complexity** | Medium (asset packs now; own art planned later) |
| **Audio Needs** | Not yet scoped |
| **Networking** | None |
| **Content Volume** | 8 regions, one per biome; per-region room counts not yet totaled (`/map-systems` derives them) |
| **Procedural Systems** | None |

---

## Risks and Open Questions

### Design Risks
- Exploration and combat compete for polish time.
- The kill condition (guard-break is not fun in one arena after two tuning rounds) has not been checked.

### Technical Risks
- Feasibility **not assessed**: TD-FEASIBILITY was skipped in Lean mode.
- Movement and attack tuning.
- Performance of the painted world.

### Market Risks
- The genre is crowded with well-known titles (not researched).

### Scope Risks
- There is no fixed deadline (owner, 2026-11-22), but 8 regions is 24-36+ months solo and as a first game. The Vertical Slice (region 1) is the commit point; regions 2-8 are provisional until it is played.
- Replacing pack art with own art adds work.

### Open Questions
- Does the move set feel good for ten minutes in a room and a fight? Answer with the MVP pass test above.
- Does the guard-break fight hold up in one arena? Answer with the MVP pass test and the two-round kill condition above.
- Does the grapple also hit? Pogo and dash do; double jump and wall cling do not (pillar 4). Owner to decide before the grapple gates are tuned.
- Shops or currency: allowed only as a convenience, never in place of a found reward (anti-pillar 2). Whether any exist is undecided.

---

## MVP Definition

**Core hypothesis**: one move set feels good in a fight and in a room for ten minutes.

**Pass test** (owner, 2026-11-22): the owner plays the MVP build for 10 minutes. Pass = the owner completes one guard-break without prompting and says they would keep playing. Anything else is a fail, and the owner records what felt wrong.

**Kill condition** (from `design/game-brief.md`): if the guard-break fight is not fun in one arena after **two tuning rounds** (a round = change the numbers or the telegraphs, then replay the pass test), drop or redesign the guard-break. Not yet checked as of 2026-11-22.

**Status (re-baselined 2026-11-22)**: the MVP was written after the build had passed it. Per `design/gdd/systems-index.md`, stories 001-006 built the controller, melee, guard-break, three enemy types, one boss and two gated abilities (double jump and grapple in code). The 10-minute pass test has **not** been run; it is owed to the owner and is the first thing to record. The kill condition is still unchecked.

**Required for MVP** (built):
1. The controller wired to the pack's animations, with movement
2. The 3-hit combo, heavy, pogo and dash
3. A guard-break fight against one enemy

**Built beyond the MVP** (so no longer "NOT in MVP"): further enemy types, the region boss, and the first ability gates.

**Designed, not yet built** (approved GDDs): room transitions, ability gating rules, save points and the grid map. These belong to the Vertical Slice.

**Still deferred**:
- Bow, spell casts, elemental palettes and the Dream Seeker state

### Scope Tiers (if budget/time shrinks)

Timelines are estimates, not measured velocity; refine with `/estimate`.

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | One arena | Movement, combo, guard-break (built; pass test owed) | Weeks to about 3 months |
| **Vertical Slice** | Region 1 complete (Tavik, Brun, dash gate) | Core plus gates, saves, map | About 4-8 months |
| **Alpha** | Regions 1-4 (all four abilities) | All features, rough | About 12-18 months |
| **Full Vision** | All 8 regions | All features, polished | About 24-36+ months |

---

## Next Steps

- [ ] `/design-review design/gdd/game-concept.md`: check the concept is complete
- [ ] Confirm the *(guessed)* entries in `design/game-brief.md` against this concept
- [ ] `/map-systems`: reconcile the systems index with this concept
- [ ] `/design-system`: write GDDs for combat and guard-break to match what is built
- [ ] `/gate-check`: run the Concept to Systems Design gate again
