# Gating and Ability Progression in Top Metroidvanias

Scope note: these notes add specifics to what the reader already knows: keys as verbs, the three gate types, the three ways to acquire a key, soft and hard gates, showing the lock before the key, and the sandbox escape. Source quality is marked inline:
- **[DEV]**: designer's own words
- **[ANALYSIS]**: critic or essayist (Game Maker's Toolkit, reviewers)
- **[GUIDE]**: wiki or strategy guide, used for orders and counts
- **[SNIPPET]**: I saw only a search-engine summary of the page, not the page itself
- **[FAN]**: fan speculation or community claim

Several wikis (Fandom, hollowknight.wiki, Fextralife) and the Game Maker's Toolkit (GMTK) transcript files on amara.org blocked direct fetching (Cloudflare or HTTP 403), so some counts and GMTK claims rest on search snippets and are marked that way.

---

## 1. Ability ORDER: full grant order, totals, and designers' reasoning

### Takeaway
No developer source I found explains *why* a particular ability comes before another (for example, why dash comes before wall-cling). Designers instead describe the process:
- Team Cherry fixed a rough ability order together with the world shape, then deliberately "chipped away" at hard gating.
- Mark Brown's analysis says Dread makes each key open fewer locks and places the most important lock near its key.

Orders across the games still share a pattern: a horizontal mobility key (dash or cloak) comes first, then vertical access (wall-cling or magnet), and unlimited vertical traversal (Space Jump, Monarch Wings, Faydown Cloak) comes late.

### Cited Findings

**Process (designers' words)**
- Hollow Knight's ordering process, from William Pellen [DEV]: "One of the earlier things we did was come up with the basic progression. All the character's abilities, and then we got them into a rough order. At the same time we were talking about the basic structure of the world... 'the characters are going to get these power ups in this specific order, what is the line, the path they take through the world to get those power-ups.' And then... as the game expanded, we started to... change that power-up progression from a linear thing to section it out." — [PC Gamer, Team Cherry 2017 interview](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- Ari Gibson on Hollow Knight [DEV]: "We chipped away at a lot of the hard gating in the game, to the point where a lot of those power-ups ended up being optional, anyway. And now people are speedrunning the game and getting barely any of the power-ups. Which is exactly what we had hoped." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- Hollow Knight's original prototype route was one power-up per biome, followed by revisits [DEV]: "you'd come from town, into the crossroads, into the fungus, get a powerup, go into the city, get a powerup, go into the bone forest, get a powerup, then come back and visit city 2, and then come back and revisit fungus." The double jump was later moved: "Double jump is here [Bone Forest], and it's in a whole new area in the final game." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- The original Hollow Knight game-jam idea used prefab rooms that would "rejig" themselves so "you might get powerups in a different order." It was abandoned: "It was a headache. It wasn't fun." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- Tom Happ (Axiom Verge) said a Metroidvania is "a linear game that's just been twisted around into a maze but you're still forced to do the same thing in a certain order" [DEV, as paraphrased by the blog] — [Limited Run Games blog](https://limitedrungames.com/blogs/news/limited-run-games-blog-that-axiom-urge) [SNIPPET]

**Hollow Knight (2017)**
- Movement keys and where they come from [GUIDE]:
  - Mothwing Cloak (dash): boss, Hornet in Greenpath
  - Mantis Claw (wall-cling): found in Mantis Village, needs the Cloak
  - Crystal Heart (super dash): found in Crystal Peak
  - Monarch Wings (double jump): boss, Broken Vessel in Ancient Basin
  - Isma's Tear (acid swim): found in Royal Waterways, needs Crystal Heart
  - Shade Cloak: found in the Abyss, an upgrade of the Cloak

  Sources: [Nintendo Life guide](https://nintendolife.com/guides/hollow-knight-abilities-locations); [SegmentNext](https://segmentnext.com/hollow-knight-abilities-locations) [SNIPPET]
- Wikipedia lists the movement set as: "an additional mid-air jump (Monarch Wings), adhering to and jumping off walls (Mantis Claw), a quick dash (Mothwing Cloak), and a speedy super dash (Crystal Heart)" — [Wikipedia: Hollow Knight](https://en.wikipedia.org/wiki/Hollow_Knight)
- Brown reads the Mantis Claw as the hinge where Hollow Knight opens up: "we enter the Mantis Village, and find the next power-up: the Mantis Claw. This allows us to scale up walls and is the perfect ability to get us past that bridge" (to the City of Tears). He argues the map then "opens up considerably." [ANALYSIS] — [GMTK Boss Keys: The World Design of Hollow Knight (transcript)](https://amara.org/subtitles/1YBjcP2T6VPf/en/1/download/The%20World%20Design%20of%20Hollow%20Knight%20%20Boss%20Keys.en.txt) [SNIPPET]

**Hollow Knight: Silksong (2025), per a GamesRadar order guide** [GUIDE] — [GamesRadar](https://www.gamesradar.com/games/silksong-abilities-skills-powers)

| # | Ability | What it does | How it is obtained |
|---|---|---|---|
| 1 | Silkspear | Silk skill | Shrine |
| 2 | Swift Step | Dash and sprint | Shrine, reached by a U-turn route out of Deep Docks |
| 3 | Drifter's Cloak | Glide | NPC quest: the Seamstress asks for Hoker spine cores |
| 4 | Cling Grip | Wall jump | Shellwood, behind the Sister Splinter boss |
| 5 | Needolin | Instrument; its tunes open sealed doors | Boss: the Widow, above Bellhart |
| 6 | Clawline | Harpoon | Found in the Underworks Cauldron |
| 7 | Faydown Cloak | Double jump | Platforming gauntlet on Mount Fay; needs the Clawline |
| 8 | Silk Soar | Super jump | Act 3 story, in the Abyss |
| 9 | Elegy of the Deep | Needolin tune that enters memories | Story |

- Silksong also has optional skills, including Thread Storm, Rune Rage (boss behind the Apostate Key), Cross Stitch (parry, from The Phantom boss), Pale Nails, Beastling Call and Sylphsong — [GamesRadar](https://www.gamesradar.com/games/silksong-abilities-skills-powers)
- Total-count conflict for Silksong: a completion checklist counts "6 Abilities" plus "6 Silk Skills" — [game-checklists.com](https://game-checklists.com/silksong/100-percent.html). Other guides say 8 abilities, or about 10 for the main story [SNIPPET]. The difference comes from how Needolin tunes and the Silk skills are counted.

**Metroid Dread (2021)**

The intended order, per [Gameranx](https://gameranx.com/features/id/274690/article/metroid-dread-where-to-find-every-suit-upgrade-progression-locations-guide/) ("Everything is covered in order") [GUIDE]. Sources are cross-checked with the [AV Club guide](https://www.avclub.com/metroid-dread-items-guide).

| # | Upgrade | Source |
|---|---|---|
| 1 | Charge Beam | |
| 2 | Spider Magnet | Artaria E.M.M.I. |
| 3 | Phantom Cloak | Boss: Corpius |
| 4 | Wide Beam | |
| 5 | Morph Ball | Cataris E.M.M.I. |
| 6 | Varia Suit | |
| 7 | Diffusion Beam | Boss: Kraid |
| 8 | Bomb | |
| 9 | Flash Shift | |
| 10 | Speed Booster | Dairon E.M.M.I. |
| 11 | Grapple Beam | |
| 12 | Super Missile | |
| 13 | Plasma Beam | |
| 14 | Spin Boost (double jump) | |
| 15 | Ice Missile | Ghavoran E.M.M.I. |
| 16 | Pulse Radar | |
| 17 | Storm Missile | Boss: Escue |
| 18 | Gravity Suit | |
| 19 | Screw Attack | |
| 20 | Cross Bomb | Boss: Golzuna |
| 21 | Wave Beam | Ferenia E.M.M.I. |
| 22 | Power Bomb | See note below |

- The two guides disagree on how the Power Bomb is obtained: Gameranx says "Defeat the Chozo Soldier"; AV Club says you only "enter the zone" of the Hanubia E.M.M.I.
- Note the late double jump: the Spin Boost comes 14th of 22.
- Brown counts 22 abilities in Dread and maps 13 of them against the rooms that need them [ANALYSIS] — [GMTK: Why You Didn't Get Lost in Metroid Dread (transcript)](https://amara.org/subtitles/Aci4iDbgsAtY/en/1/download/Why%20You%20Didnt%20Get%20Lost%20in%20Metroid%20Dread.en.txt) [SNIPPET]
- One guide says there are 25 different upgrades, not counting tanks — [Gameranx / bosslevelgamer search result](https://bosslevelgamer.com/?p=137871) [SNIPPET]. The 22-versus-25 difference is about whether small items count.

**Nine Sols (2024)**
- Movement abilities come from "Anomalous Root Nodes", which work as shrines [GUIDE] — [Red Candle support FAQ](https://coda.io/@redcandlegames/nine-sols-support/faqs-and-guide-14) [SNIPPET]:
  - Tai-Chi Kick (air parry-kick): taught by Lear in the Central Transport Hub
  - Air Dash: Factory (Underground)
  - Cloud Leap (double jump): Four Seasons Pavilion
  - Super Mutant Buster: an item turn-in that needs Tianhuo Serum plus Ji's Hair
- Red Candle on the baseline moveset [DEV]: "the traditional side-scrolling action controls remain unchanged, so players are free to use moves like dash, double jump, and wall jump/climb in the same ways you're familiar with." — [Into Indie Games interview](https://intoindiegames.com/features/nine-sols-an-interview-with-red-candle-games/)
- Full moveset: run, jump, double jump, wall jump, ground and air dash, climb, wall run, grapple — [Wikipedia: Nine Sols](https://en.wikipedia.org/wiki/Nine_Sols)

**Prince of Persia: The Lost Crown (2024)** [GUIDE] — [progameguides](https://progameguides.com/prince-of-persia-the-lost-crown/all-abilities-and-how-to-get-them-prince-of-persia-the-lost-crown/) [SNIPPET]; [exputer](https://exputer.com/guides/prince-of-persia-the-lost-crown-time-powers/); [GameSpot time powers](https://www.gamespot.com/gallery/prince-of-persia-the-lost-crown-all-time-powers-guide/2900-5033/)
- Rush of the Simurgh (air dash) comes first, right after the boss Jahandar.
- Shadow of the Simurgh (place a marker and teleport back to it) comes second.
- Dimensional Claw comes after the boss Kiana.
- Gravity Wings come after the Azhdaha fight.
- Fabric of Time is the final time power.
- Chakram Shadow (teleport to the thrown chakram) is a separate seventh power.
- Director Mounir Radi on the structure [DEV]: the team "didn't start with Metroidvania as the structure for the game, it ended up being perfect"; Sargon's powers master "another facet of time – space." — [GamesRadar interview](https://www.gamesradar.com/prince-of-persia-lost-crown-interview) [SNIPPET]

**Ori and the Blind Forest (2015)**
- Skills are learned from skill trees, except Spirit Flame and Kuro's Feather (glide). "In casual play, you are expected to acquire all the skills, but in speedruns, several of them are skippable." [GUIDE] — [Speed Demos Archive KB: Ori Skills](https://kb.speeddemosarchive.com/Ori/Skills_and_Abilities)
- Ability *upgrades* are bought at player-made soul links. "Each skill must be learned in sequential order from one of three ability trees." — [Wikipedia: Ori and the Blind Forest](https://en.wikipedia.org/wiki/Ori_and_the_Blind_Forest)

**Castlevania: Symphony of the Night (1997)**
- "most of the castle being inaccessible until various items and abilities are collected, including shapeshifting into a bat, wolf, or mist." The second half (Inverted Castle) requires collecting 5 pieces of Dracula from 5 bosses — [Wikipedia: SotN](https://en.wikipedia.org/wiki/Castlevania:_Symphony_of_the_Night)

**Axiom Verge (2015)**
- "features over 60 items and power-ups" — [Wikipedia: Axiom Verge](https://en.wikipedia.org/wiki/Axiom_Verge)

### Inferences
- **Horizontal key first, vertical key second.** In Hollow Knight, Silksong, Dread and Lost Crown alike, a horizontal key (Cloak, Swift Step, Rush, Phantom Cloak or Flash Shift) or a cling or magnet key comes first. The full double jump comes in the middle or late: Monarch Wings is the 4th movement key in Hollow Knight, Spin Boost is 14th of 22 in Dread, Faydown Cloak is 7th of 9 in Silksong.
  - A plausible rule: early keys extend reach a little; keys that remove vertical gaps outright come late, because they invalidate many gates at once.
- **Make ability order an output of world shape.** Team Cherry's process (order, then route through the world, then break the route into sections) suggests drafting a linear "golden path", then loosening it, then making some keys optional.
- **Cap the ability count.** Dread has about 22 keys and Hollow Knight 6 movement keys plus spells. Silksong's ~9 main abilities plus about 6 optional silk skills shows the scale ranges from small to large.

### Gaps
- I found no designer quote explaining *why* dash precedes wall-cling, or why the double jump comes late, for any game. The ACMI book interview with Team Cherry (sold at ACMI) may contain it; I could not access it.
- I could not get full unlock orders for:
  - Ori and the Will of the Wisps
  - Symphony of the Night (relic order)
  - Axiom Verge (Address Disruptor, Trace's drone, Lab Coat, Drill, Grapple)
  - Blasphemous
  - Aeterna Noctis
  - Ender Lilies (order of spirits)
  - Animal Well (item order)

  The relevant wikis returned Cloudflare blocks.
- **Unverified, from general knowledge.** The Ori Blind Forest order is commonly given as Wall Jump, Charge Flame, Double Jump, Bash, Stomp, Glide, Climb, Charge Jump, Grenade, Dash. I could not source this in this pass; one search snippet put Double Jump in the Moon Grotto / Gumo's Hideout after Wall Jump.

---

## 2. Showing the lock before the key: lead time, repetition, readability

### Takeaway
The best-documented techniques are Dread's. Each key opens a small set of distinct, single-purpose lock types (a door colour or covering per weapon), and the most important lock sits close to the key. Brown says this limits the area a player has to keep in mind.

Prince of Persia: The Lost Crown turns "remember the lock" into a player tool: Memory Shard screenshots pinned to the map, a limited number of them, and more given out in chests next to blocked paths.

I found no measured numbers for how long or how far ahead a lock is shown, or how many times it is seen before its key.

### Cited Findings

**Dread's gate vocabulary: one material, colour or covering per key** [GUIDE] — [Gameranx](https://gameranx.com/features/id/274690/article/metroid-dread-where-to-find-every-suit-upgrade-progression-locations-guide/); [AV Club](https://www.avclub.com/metroid-dread-items-guide)

| Key | Lock it opens |
|---|---|
| Charge Beam | "Required to open Orange Doors" |
| Spider Magnet | "blue, electric-looking strips scattered on the walls and ceilings" |
| Phantom Cloak | Sensor Doors |
| Wide Beam | "three-button switches and doors" (and "push blocks that look similar") |
| Super Missile | "green coverings" |
| Plasma Beam | Plasma Beam Coverings |
| Wave Beam | "purple Wave Beam Covers" |
| Ice Missile | "large flaming mushrooms that block your path" |
| Grapple Beam | grapple doors / "tiles with blue triangles" |
| Speed Booster | Speed Booster blocks |
| Storm Missile | Storm Missile doors |
| Pulse Radar | Itself a key that "scan[s] rooms to reveal all hidden blocks" |

**Boss-door telegraph in Dread** [GUIDE]: "That door-blocking menace will always be an indication that you're close to one of Dread's boss fights. It's also the game's way of replenishing your health and missiles before each encounter." — [AV Club](https://www.avclub.com/metroid-dread-items-guide)

**Brown's core argument on Dread** [ANALYSIS] — [GMTK transcript](https://amara.org/subtitles/Aci4iDbgsAtY/en/1/download/Why%20You%20Didnt%20Get%20Lost%20in%20Metroid%20Dread.en.txt) [SNIPPET]
- The game reduces "the number of locks each key opens" and places "the most important lock near the key that opens it."
- An ability like the Plasma Beam does not unlock "a flood of doors."
- After leaving Elun only one route forward remains.
- In Super Metroid by contrast, "after getting the missiles... there's literally only 13 rooms to check."

**Player pushback on Dread's signposting** (comment thread on the Brown video) [FAN]
- Players got lost when "you had to shoot a random unmarked wall or floor to break it."
- "MercurySteam's habit of closing off old pathways... made the game feel far more linear."
- The post-Speed-Booster Grapple Beam route needs a chain of shinesparks and teleporters that "expects prior knowledge."

Source: [Tildes thread on GMTK video](https://tildes.net/~games/z02/why_you_didnt_get_lost_in_metroid_dread)

**Super Metroid** [ANALYSIS]
- "the game very clearly tells the player that they're not meant to be there quite yet by introducing obstacles like certain doors or unique terrain that can't be opened without gear found in other areas." Brown maps the game as a "dependency chart" — [Game Developer on GMTK Boss Keys: Super Metroid](https://www.gamedeveloper.com/design/looking-back-at-the-level-design-triumphs-of-i-super-metroid-i-)
- Golden statues of the four bosses (Kraid, Ridley, Draygon, Phantoon) visibly block Tourian. Each statue's gem vanishes when its boss dies. This is a lock shown from the start whose progress is tracked on the lock itself — [Metroid Wiki: Super Metroid](https://www.metroidwiki.org/wiki/Super_Metroid)

**Prince of Persia: The Lost Crown, Memory Shards** [DEV]
- How it works: a button press takes a HUD-less screenshot and pins it to the map.
- Origin: it "started as an accessibility tool, but ultimately transitioned into a primary aspect" — [Inverse](https://www.inverse.com/gaming/prince-of-persia-lost-crown-accessibility-interview) [SNIPPET]
- Rémi Boutin on the problem it solves: "We were playing metroidvanias, we took a break, and when looking at our map we forgot what we were trying to do."
- Players start with **15** Memory Shards. There is a hard cap that "never changed throughout development", but the starting count changed several times: first the maximum, then "only a precious few", then 15 after playtests.
- Why the limit helps: "Because players have a limited number of Memory Shards they have to manage them efficiently and it helps them to keep their map 'clean'."
- Using rewards as reminders: "Offering more Memory Shards as rewards also allowed us to [remind players] about the feature, often by giving them in a chest near a blocked path."
- On the effort: "It took tons of iteration and playtest to get a 'natural' feeling."

Source: [Game Developer](https://www.gamedeveloper.com/design/how-memory-shards-help-players-find-secrets-in-prince-of-persia-the-lost-crown)

- After a new ability, Memory Shards "quickly remind players where they can use the skill they just learned" — [Digital Trends](https://www.digitaltrends.com/gaming/prince-of-persia-the-lost-crown-memory-shards-development/) [SNIPPET]

**Hollow Knight: map coherence as lock memory** [DEV]
- Pellen: "as soon as you have areas where you go through this door and come up through here and suddenly you're in another area and it doesn't make sense anymore, you can't map it in your head."
- Gibson: the world is "98% pure", with no paradox rooms. He adds: "It's super annoying to get to a point that's 2 centimeters from somewhere you want to be and you can't get there."

Source: [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)

**Hollow Knight: cognitive-load ceiling** [DEV]
- Bone Forest, the largest area, was cut partly because "the game's already quite overwhelming for some players... you have to keep a lot of it in your head, and potentially another very, very large area was just pushing people too far in their expectations for how much information they could retain." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)

### Inferences
- **Rule: one visual signature per key, never shared.** Dread's covering colours are distinct and match the beam or missile that opens them. A gate the player can read is one whose colour matches the key's colour or effect.
- **Rule: keep few locks open per key, and put the critical lock within a short walk of the key.** This is Brown's Dread principle. It works against the "flood of doors" that Plasma-style keys create.
- **Rule: give the player a memory aid for locks** (map stamps or Shards). Limit how many they can place, and hand out more of them next to gates as a reminder.
- **Rule: a progress meter on the lock itself.** Super Metroid's Tourian statues are an early lock whose state changes as each key is earned.
- **Rule: treat world size as a memory budget.** Team Cherry cut a whole biome on these grounds.

### Gaps
- No source gives distance or time from first sighting of a lock to the key, or a count of sightings, for any game.
- I found no primary or analysis source on Hollow Knight's gate visual vocabulary (Mantis Claw walls, acid, dark rooms, Shade Gates, crystal) or on the colour code of Ori's barriers. Brown's Hollow Knight video may cover them, but its transcript was blocked.

---

## 3. Where abilities are obtained and how: ratios, and the post-pickup "ability room"

### Takeaway
Exploration pickups dominate in every game I could count.

| Game | Keys counted | Boss | Special enemy / zone | Shrine or found | NPC, quest or story |
|---|---|---|---|---|---|
| Hollow Knight | 6 movement keys | 2 (Cloak, Wings) | — | 4 | — |
| Dread | ~22 | 4 to 5 | 5 to 6 (E.M.M.I.) | about 11 to 12 | — |
| Silksong | 9 main abilities | 2 | — | 3 | 4 (one NPC quest, three story beats) |

The Silksong row: the Widow and the Sister Splinter gate are bosses; the shrines are Silkspear and Swift Step, plus the Mount Fay gauntlet; the NPC quest is the Seamstress, and the Abyss and Elegy are story beats. The Silksong split leans more on quests and story.

Dread's E.M.M.I. zones are the clearest designed "sandbox": a temporary super-weapon kills the hunter, and the kill turns into a permanent new verb.

### Cited Findings

**Dread's E.M.M.I. loop**
- "E.M.M.I.s can only be destroyed when Samus obtains the temporary 'Omega Blaster' upgrade, which is lost upon using it to destroy one; destroying an E.M.M.I. however grants Samus a new permanent upgrade. Upgrades can also be found by finding Chozo statues or destroying a Core-X." — [Wikipedia: Metroid Dread](https://en.wikipedia.org/wiki/Metroid_Dread)
- Sakamoto on E.M.M.I. zones [DEV]: "We treat 'E.M.M.I Zones' like 'Dread Zones', something different to the normal areas you can explore... As you progress through the game though, Samus will learn how to counter E.M.M.I. and the process of getting stronger and counterattacking is no different to any other enemy." — [Nintendo Everything, Famitsu translation](https://nintendoeverything.com/?p=736896)
- Sakamoto on failure feedback [DEV]: "One of the things we focused on was to make sure when a player hits a game over, they know what to try on their next attempt... If you make it so that E.M.M.I. doesn't catch a player all that often... you can't really express the dread." — [Nintendo Wire](https://nintendowire.com/news/2022/01/24/metroid-dread-producer-discusses-the-games-difficulty-and-why-the-e-m-m-i-encounters-were-so-unforgiving/)
- Dread's sources by type:
  - E.M.M.I. rewards: Spider Magnet, Morph Ball, Speed Booster, Ice Missile, Wave Beam, and possibly the Power Bomb
  - Boss rewards: Phantom Cloak (Corpius), Diffusion Beam (Kraid), Storm Missile (Escue), Cross Bomb (Golzuna). AV Club says the Cross Bomb is "the last power-up that's locked behind a boss fight."
  - The rest are found on pedestals or Chozo statues

  Sources: [Gameranx](https://gameranx.com/features/id/274690/article/metroid-dread-where-to-find-every-suit-upgrade-progression-locations-guide/); [AV Club](https://www.avclub.com/metroid-dread-items-guide)
- A MercurySteam idea from Samus Returns carried into Dread [DEV]: the counter and dash melee, which "wouldn't stop the flow of the game." — [Nintendo Everything](https://nintendoeverything.com/?p=736896)

**Hollow Knight**
- Boss keys: Mothwing Cloak (Hornet) and Monarch Wings (Broken Vessel). Found keys: Mantis Claw, Crystal Heart, Isma's Tear, Shade Cloak — [Nintendo Life](https://nintendolife.com/guides/hollow-knight-abilities-locations) [SNIPPET]
- Original plan [DEV]: the three Dreamers were going to be "the same boss, kind of slightly reskinned", one per land, after which you return to the start for the final boss. The finished game kept that shape "really blown up." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)

**Silksong's mix**
- Shrines: Silkspear, Swift Step
- NPC quest: Drifter's Cloak (Seamstress)
- Bosses: Needolin (Widow); Cling Grip sits behind Sister Splinter
- Found: Clawline (Cauldron)
- Platforming gauntlet: Faydown Cloak (Mount Fay)
- Story beats: Silk Soar (Abyss), Elegy of the Deep

Source: [GamesRadar](https://www.gamesradar.com/games/silksong-abilities-skills-powers)

**Silksong's added intro area** [DEV, paraphrased by GamesRadar]
- Team Cherry added Moss Grotto *after* finding that The Marrow was "a brutal introduction."
- Instead of prompts, "subtle gameplay hints... you begin to grasp that this is how far you can jump, here are some spikes to negotiate, here's a hidden room, and here are some unthreatening caterpillar enemies."

Source: [GamesRadar](https://www.gamesradar.com/games/action/silksongs-first-area-was-only-added-after-team-cherry-realized-it-needed-a-softer-intro-were-trying-to-be-kind-of-respectful-to-the-player-were-not-trying-to-baby-them)

**Nine Sols**
- Mostly from Root Node shrines; one ability is an item turn-in — [Red Candle FAQ](https://coda.io/@redcandlegames/nine-sols-support/faqs-and-guide-14) [SNIPPET]

**Lost Crown**
- The first three time powers follow bosses: Jahandar, then Kiana, then Azhdaha — [GameSpot](https://www.gamespot.com/gallery/prince-of-persia-the-lost-crown-all-time-powers-guide/2900-5033/); [progameguides](https://progameguides.com/prince-of-persia-the-lost-crown/all-abilities-and-how-to-get-them-prince-of-persia-the-lost-crown/) [SNIPPET]

**Ender Lilies**
- Combat verbs come from defeated bosses and elites as spirits: "Special opponents can broaden the player's repertoire by discovering and defeating them, granting new abilities." Lily equips 3 spirits in 2 swappable loadouts — [Wikipedia: Ender Lilies](https://en.wikipedia.org/wiki/Ender_Lilies:_Quietus_of_the_Knights)

**Super Metroid**
- Varia Suit comes from Kraid. Gravity Suit comes from a Wrecked Ship storage room after Phantoon.
- The escape: after Mother Brain, Samus can optionally rescue three Etecoons and a Dachora on the way out — [Metroid Wiki](https://www.metroidwiki.org/wiki/Super_Metroid)

**Symphony of the Night**
- Five bosses hold the five Dracula relics needed for the finale — [Wikipedia](https://en.wikipedia.org/wiki/Castlevania:_Symphony_of_the_Night)

### Inferences
- **Mix sources by ability role.**
  - Bosses give *combat-relevant* movement (Hollow Knight's Cloak, Dread's Phantom Cloak).
  - Shrines and pedestals give *traversal-first* keys.
  - NPC and quest keys are rarer, and are used when the developer wants a narrative beat (Silksong's Seamstress).
- **Dread's "temporary weapon to permanent verb" model.** The player first *flees* the threat, then gets a one-use super-weapon, and the kill converts into a new traversal verb. The verb is introduced inside the same high-tension zone where the player just learned the zone's layout.
- **Make the next attempt obvious.** Sakamoto's rule is that a failed attempt should tell the player what to try next. It applies to every ability-test room after a pickup.

### Gaps
- No primary source on Super Metroid's Bomb Torizo room, the wall-jump-teaching Etecoon room, or the Hollow Knight Mantis Claw exit room as deliberate "teach the verb" designs. The commonly cited claim that the animal room confirms intent is [FAN] and unverified per this search: [Fandom: Sequence Breaking](https://metroid.fandom.com/wiki/Sequence_Breaking) [SNIPPET].
- No exact boss-versus-explore split for Ori, SotN, Axiom Verge, Blasphemous or Aeterna Noctis.

---

## 4. Item gates and knowledge gates

### Takeaway
Simple consumable item gates are kept few. Hollow Knight has 4 Simple Keys for 4 doors, and Silksong has an Apostate Key and Simple Keys guarding optional bosses or rooms.

The strongest documented case for knowledge gating is Animal Well. Billy Basso deliberately layers the game for three player types, and says a secret only works if it "break[s] from the pattern that even the current game you're playing established."

### Cited Findings

**Item gates in Hollow Knight and Silksong**
- Hollow Knight: "There are four Simple Keys in the game and four doors that require a Simple Key to unlock" [GUIDE] — search summary of Hollow Knight wiki and guides, e.g. [pindrop.gg items](https://pindrop.gg/hollow-knight/items) [SNIPPET]
- Hollow Knight also has a Shopkeeper's Key from Crystal Peak, brought to Sly, which unlocks more shard and fragment purchases — [game-checklists Hollow Knight](https://game-checklists.com/hollow-knight/112-checklist/)
- Silksong: the Apostate Key from the Putrified Ducts opens a cell in The Slab, leading to the First Sinner boss and the Rune Rage skill — [GamesRadar](https://www.gamesradar.com/games/silksong-abilities-skills-powers)

**Song-door gates**
- Silksong's Needolin tunes "open sealed doors" (Weaver doors), and Elegy of the Deep "allows you to enter dreams and memories at key locations," which unlock most of Verdania — [GamesRadar](https://www.gamesradar.com/games/silksong-abilities-skills-powers)

**Animal Well, from Billy Basso** [DEV]
- **Three layers**: "There's three layers to the game, and I'm always designing the game for three different people at any given point." — [Thinky Games](https://thinkygames.com/features/interview-how-animal-well-is-using-secrets-and-mysteries-to-be-a-different-kind-of-metroidvania/) [SNIPPET]
- The second layer is for "discovery and secret-oriented players": find all hidden eggs to get a second credits roll — [Wikipedia: Animal Well](https://en.wikipedia.org/wiki/Animal_Well)
- **Base game first**: "I think of [Animal Well] as multiple games that are superimposed on top of each other... to get people to care about the secrets, I had to make a compelling game as a base. I needed to first make something that was broadly accessible and fun." — [Time Extension](https://www.timeextension.com/features/the-making-of-animal-well-2024s-most-unique-metroidvania)
- **Old-school secrecy**: "Games used to be able to take more risks in terms of how they taught mechanics to a player, and it was okay if a player didn't see everything." — [Time Extension](https://www.timeextension.com/features/the-making-of-animal-well-2024s-most-unique-metroidvania)
- **Secrets must break pattern**: "when there's a secret, it needs to be actually surprising, and it needs to break from the pattern that even the current game you're playing established. Because as a player, you're constantly trying to fit a model around everything you're experiencing." — [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **On not marking secrets**: "a lot of people have said, 'I wish Animal Well did that.' And it's like, well, they wouldn't be secrets then... You're not entitled to get everything." — [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **The disc swap**: a knowledge gate built on Resident Evil's shotgun trap. You must find a fake disc and swap it "Indiana Jones-style" — [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **Cheater's Ring**: an item earned through great effort that lets the player clip through walls, revealing scripted content reachable only by "breaking" the game. Basso calls it "like the bonus features on a DVD." — [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **Structure and items**: a 16×16 grid of flip-screen rooms. The items are toys (slinky, frisbee, bubble wand) that "often have multiple uses, not all of which are immediately obvious." Matches permanently banish ghosts from a room — [Wikipedia: Animal Well](https://en.wikipedia.org/wiki/Animal_Well)
- **Self-imposed rule**: no traditional Metroidvania weapons. The yo-yo clears debris and the slinky hits switches — [Time Extension](https://www.timeextension.com/features/the-making-of-animal-well-2024s-most-unique-metroidvania)
- **Scale**: 256 encounters shipped, at least 500 cut — [GamesRadar](https://gamesradar.com/games/platformer/solo-dev-behind-breakout-metroidvania-hit-animal-well-says-his-game-has-256-encounters-but-he-had-to-cut-at-least-500-of-them-during-development) [SNIPPET]

**Axiom Verge's glitch gating, from Tom Happ** [DEV]
- "In a way the beaten path of the game exists just as an established baseline to allow off-the-beaten-path exploration. For example, I could have the entire game just be about using a glitch ray to glitch things, but then they wouldn't be glitches anymore - they'd just be the game."
- "You might even want to include traditional elements so that can provide context for when you later subvert them."

Source: [Game Developer: Metroidvania interview, Tom Happ](https://www.gamedeveloper.com/business/metroidvania-interview-tom-happ)

**Animal Well's gates as received by reviewers**
- Some puzzles took dozens of players collaborating — [Game Developer](https://gamedeveloper.com/design/why-animal-well-s-home-brewed-engine-was-key-to-its-success) [SNIPPET]
- Game Informer found the last section of layer one "stale"; PC Gamer found the map hard to use — [Wikipedia: Animal Well](https://en.wikipedia.org/wiki/Animal_Well)

### Inferences
- **Fairness rule for knowledge gates.** Put every required path on the "base" layer and teach it with the game's own pattern. Reserve pattern-breaking secrets for optional layers. That way, Basso's "you're not entitled to everything" never blocks the credits.
- **Make a "subversion" key work only against an established baseline.** Happ's glitch gun and Basso's disc swap work because the normal key rules were set up first.
- **Keep item gates few and pointed at optional content.** In Hollow Knight, 4 keys open 4 doors.

### Gaps
- No exact count of Animal Well's required items, or of Silksong Simple Keys and doors; the wikis were blocked.
- Nothing found from Tunic or Outer Wilds designers in this pass. Those games are outside the assigned list.

---

## 5. Soft gates and sequence breaking

### Takeaway
Team Cherry is explicit that loosening gates was the goal. Hollow Knight's power-ups became partly optional, and Silksong is built so that at any point "there could be three or four valid directions."

For Super Metroid, it is disputed whether its famous breaks were intended.

Moon Studios treats physics-based breaks as a balancing problem and brought speedrunners into testing.

### Cited Findings

**Team Cherry**
- Gibson on Silksong [DEV]: "It's a specific kind of lock-and-key type of progression, but we try to submerge that element in favour of a more naturalistic world... We definitely use it in some areas of the game." — [GamesRadar on the ACMI interview](https://www.gamesradar.com/games/action/hollow-knight-devs-highlight-a-big-difference-between-their-sequel-and-most-metroidvanias-the-players-choice-about-where-to-go-in-silksong-is-not-dictated-by-what-power-ups-you-currently-have)
- Pellen on Silksong [DEV]: "player's choice about where to go in Silksong is not dictated by what power-ups you currently have; there could be three or four valid directions... two of those directions might lead to a new ability - but the other two might lead to entirely new parts of the world, which might end up leading you to another power up." — [same GamesRadar piece](https://www.gamesradar.com/games/action/hollow-knight-devs-highlight-a-big-difference-between-their-sequel-and-most-metroidvanias-the-players-choice-about-where-to-go-in-silksong-is-not-dictated-by-what-power-ups-you-currently-have)
- Team Cherry's difficulty advice relies on this structure: if a player hits a wall, "they can always turn around and see what awaits down a different path." — [same GamesRadar piece](https://www.gamesradar.com/games/action/hollow-knight-devs-highlight-a-big-difference-between-their-sequel-and-most-metroidvanias-the-players-choice-about-where-to-go-in-silksong-is-not-dictated-by-what-power-ups-you-currently-have)
- Gibson on free world versus guided path [DEV]: "you can do things like get lost, really easily. You can go the complete other way than maybe would lead to your next upgrade, and that's totally fine. But it's also very common these days to create something that's a bit more like a roller coaster... where the game developers will direct you on a path." Pellen: in the funnel approach, "The world is built around that path, rather than the other way around." Guacamelee is cited as the good funnel example — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- Hollow Knight "does not restrict the player to one path nor require them to explore the whole world; there are places that can be missed when finishing the game." — [Wikipedia: Hollow Knight](https://en.wikipedia.org/wiki/Hollow_Knight)

**Super Metroid: was sequence breaking intended?**
- Super Metroid's "open-ended structure lends well to sequence breaking," which made it a speedrun staple — [Wikipedia: Super Metroid](https://en.wikipedia.org/wiki/Super_Metroid)
- **Intent disputed** [FAN]:
  - One claim: it is "nearly impossible to get stuck or cause crashes" when entering areas without the gear, which suggests awareness.
  - Giant Bomb calls the breaking unintentional; a forum commenter calls it "an accident of coding."

  Sources: [Fandom: Sequence Breaking](https://metroid.fandom.com/wiki/Sequence_Breaking) [SNIPPET]; [Giant Bomb](https://www.giantbomb.com/games/3030-8292/) [SNIPPET]
- A blog attributes a quote to Super Metroid programmer Yasuhiko Fujii: he wanted shortcuts "to be useful for those who have introduced the time system and time trials." **Secondary and unverified; no primary interview found.** — [Confusing Middle](https://confusingmiddle.com/2025/10/15/metroids-speed-revolution)
- The same blog lists the breaking techniques: Continuous Wall Jumps cross the Moat without the Grapple, and shinespark "shine breaking" reaches the Wrecked Ship's west exit. — [Confusing Middle](https://confusingmiddle.com/2025/10/15/metroids-speed-revolution)

**Metroid Dread**
- The same blog claims Dread's breaks (such as getting Bombs before Kraid) were "intentionally designed" and that patches fixed only softlocks. It attributes this to "community analysis". **Speculative.** — [Confusing Middle](https://confusingmiddle.com/2025/10/15/metroids-speed-revolution)

**Ori, from Thomas Mahler** [DEV] — [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- "because we're dealing with physics, there's some sequence breaking that players might be able to do due to physics... it's just a matter of tweaking things until the Design Department is happy overall."
- "the entire game basically has to become one huge puzzle: Change an element over here to the right in the world and it might have bad effects on this one spot to the far left of your world... you have 300+ levels."
- For Will of the Wisps "we also hired two of the best Ori speedrunners" for testing.
- Ori Blind Forest's Bash is "the foundation of one of the biggest sequence breaks in the game (the Sorrow Bash)" — [SDA KB](https://kb.speeddemosarchive.com/Ori/Skills_and_Abilities)

**Boss order: open versus fixed**
- Hollow Knight's Dreamers sit in different lands and can be done in any order, then you return to the start — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- Brown on Dread: after Elun "only one route forward remains" [SNIPPET] — [GMTK transcript](https://amara.org/subtitles/Aci4iDbgsAtY/en/1/download/Why%20You%20Didnt%20Get%20Lost%20in%20Metroid%20Dread.en.txt)
- Players note Dread closes old paths behind them — [Tildes](https://tildes.net/~games/z02/why_you_didnt_get_lost_in_metroid_dread) [FAN]
- Symphony of the Night's Inverted Castle was intended, per a summary of Igarashi, to "not push players into a certain play experience" — [Wikipedia: Inverted Castle](https://en.wikipedia.org/wiki/Inverted_Castle) [SNIPPET]

### Inferences
- **Allow breaks deliberately.** Design so the game cannot soft-lock without a key: every room reachable early must have a way out. Then let advanced movement reach later keys, as Team Cherry hoped for.
- **Use speedrunners as testers.** Moon's practice of hiring them gives a concrete way to find unintended breaks before ship.
- **"Three or four valid directions" as a checkable rule.** At any checkpoint in the critical path, count the routes still open. Team Cherry's target is about 3 or 4, with about half leading to keys.
- **Choose the boss-order model per act.** Use an open order (Dreamers, Sols-style) for mid-game objectives. Use one-way funnels (Dread) where pacing or story matters, and expect the "feels linear" criticism.

### Gaps
- No primary statement from Red Candle on sequence breaks or open boss order in Nine Sols.
- No primary Nintendo or Sakamoto statement on Super Metroid's sequence-break intent.

---

## 6. Keys as dual-purpose verbs (traversal plus combat), and failures

### Takeaway
Dread makes almost every key a weapon or a defence: magnet, cloak, Flash Shift, Speed Booster, Screw Attack and missile types. Nine Sols and Lost Crown tie mobility to parry and teleport combat.

The main documented failures:
- Blasphemous: its relics are passive environment toggles, not verbs.
- Optional pickups that do not change play: Basso's critique of Dread's missile tanks.
- Aeterna Noctis: unexplained or finicky traversal abilities.

### Cited Findings
- **Dread's keys used in combat**: Ice Missile "allows you to freeze your enemies and deal extra damage to the X"; Storm Missile can "target up to five objects / enemies"; Flash Shift gives "up to three quick dashes in rapid succession" and is needed to beat the Burenia E.M.M.I. — [AV Club](https://www.avclub.com/metroid-dread-items-guide); [Gameranx](https://gameranx.com/features/id/274690/article/metroid-dread-where-to-find-every-suit-upgrade-progression-locations-guide/)
- **Dread's stealth key**: the Phantom Cloak makes Samus invisible but slows her, and is used against E.M.M.I. — [Wikipedia: Metroid Dread](https://en.wikipedia.org/wiki/Metroid_Dread)
- **Nine Sols**
  - Combat is built on deflection, using "an opponent's strength against them" — [Game8](https://game8.co/articles/latest/nine-sols-taopunk-identity-sets-it-apart-from-other-souls-like-platformers) [SNIPPET]
  - Deflecting builds Qi, which powers "talisman dashing" — [Wikipedia](https://en.wikipedia.org/wiki/Nine_Sols)
  - The Tai-Chi Kick is an in-air parry used on enemies that flash green — [Red Candle FAQ](https://coda.io/@redcandlegames/nine-sols-support/faqs-and-guide-14) [SNIPPET]
  - A jumping parry for red unblockable attacks is borrowed from Sekiro — [GamesRadar review](https://gamesradar.com/games/action/nine-sols-review) [SNIPPET]
  - A reviewer notes the abilities "aren't just glorified keys" [SNIPPET; exact outlet not confirmed]
- **Lost Crown**: Shadow of the Simurgh (leave a marker and teleport back) and Chakram Shadow (teleport to the thrown chakram) are traversal keys built on combat tools — [progameguides](https://progameguides.com/prince-of-persia-the-lost-crown/all-abilities-and-how-to-get-them-prince-of-persia-the-lost-crown/) [SNIPPET]; [guides4gamers](https://guides4gamers.com/prince-of-persia-the-lost-crown/pois/abilities/) [SNIPPET]
- **Ori Blind Forest's Bash** "allows you to grab an enemy or projectile... and use it to propel Ori in one direction while the target flies in the opposite direction." Enemy projectiles become traversal anchors — [SDA KB](https://kb.speeddemosarchive.com/Ori/Skills_and_Abilities)
- **Ori Will of the Wisps** has "a skill that allows them to even use projectiles as a movement opportunity" (interviewer's framing) — [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- **Ender Lilies**: every combat skill *is* a spirit taken from a defeated enemy — [Wikipedia](https://en.wikipedia.org/wiki/Ender_Lilies:_Quietus_of_the_Knights)

**Failure: Blasphemous relics** [ANALYSIS]
- "Blasphemous doesn't require any ability gating... The abilities that do exist actually cause the environment to react to you, rather than affect your ability to play." Unlocking relics "has you backtracking in a boring way." — [Metroidvania Review: Blasphemous](https://metroidvaniareview.com/blasphemous/)
- The relics "all function to provide passive abilities, making them feel redundant" — [Geeks Under Grace](https://www.geeksundergrace.com/gaming/review-blasphemous/) [SNIPPET]
- "relics are easy to miss" — [Twinfinite](https://twinfinite.net/2019/09/blasphemous-review-castlevania-souls/) [SNIPPET]
- A user comment calls Blasphemous's "Zelda-like 'go to the temples to get the things' structure" a removal of surprise [FAN] — [Nintendo Life comments](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)

**Failure: a familiar kit** [DEV critique]
- Basso on Dread: "it was still the same item set you get in all the Metroid games. They added a few new abilities... but I don't think it was enough to really maintain my sense of excitement."
- He criticises the genre for following "the blueprint, give you the double jump and a dash."

Source: [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)

**Failure: Aeterna Noctis** [ANALYSIS] — [Aeterna Noctis reviews: FingerGuns](https://fingerguns.net/reviews/2023/02/20/aeterna-noctis-review-ps5-symphony-for-the-devil/); [PlayStation Country](https://www.playstationcountry.com/?p=19168) [SNIPPET; attribution across outlets not confirmed]
- Some abilities, such as the wall jump, are "temperamental."
- "If abilities are required to be used in a certain way then that should be explained rather than left to chance."

**Ori shards as optional verbs** [DEV]
- Will of the Wisps replaced Blind Forest's ability tree with Spirit Shards found in the world, because the tree forced upgrades "that the player might not even want to acquire."
- Some shards are navigational: "sticking to walls."
- Mahler: "There weren't really any strict rules as to what constitutes a good shard, we just decided based on our gut feeling."

Source: [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)

### Inferences
- **A key that only toggles the environment works as a door, not a verb.** If a key does nothing in combat or moment-to-moment movement, reviewers call it redundant (Blasphemous).
- **Test each key twice.** Ask (a) what new gate it opens and (b) what new enemy answer it gives. Dread's E.M.M.I. keys and Nine Sols's parry-kick satisfy both.
- **A finicky key is worse than no key.** If a key needs precision (Aeterna Noctis's wall jump), teach it explicitly and make its input forgiving.

### Gaps
- No designer postmortem found that admits a specific failed dual-purpose ability.

---

## 7. Optional upgrade economy: health and energy, charms, currency

### Takeaway
The canonical shard maths:

| Game | Health shards | Shards per upgrade | Max health | Other shards |
|---|---|---|---|---|
| Hollow Knight | 16 Mask Shards | 4 per mask | 9 masks | 9 Vessel Fragments |
| Silksong | 20 Mask Shards | 4 per mask | +5 masks | 18 Spool Fragments |

Hollow Knight also has about 40 charms. Silksong also has 52 Tools and 6 Crests.

Shops, grub-rescue rewards and quests feed the economy, not just hidden rooms. Basso's critique is that predictable "number-go-up" pickups (missile tanks) kill the urge to revisit.

### Cited Findings

**Hollow Knight**
- 16 Mask Shards; 4 make a mask; maximum 9 masks — [Fextralife: Mask Shard](https://hollowknight.wiki.fextralife.com/Mask+Shard) [SNIPPET]; [game-checklists](https://game-checklists.com/hollow-knight/112-checklist/)
- 9 Vessel Fragments, 3 per Soul Vessel → 3 vessels — [hollowknight.wiki: Mask Shard / Completion pages](https://hollowknight.wiki/w/Completion_%28Hollow_Knight%29) [SNIPPET]
  - **Conflict:** [game-checklists](https://game-checklists.com/hollow-knight/112-checklist/) says "Collect 4 Vessel Fragments to assemble 1 Soul Vessel." The 9-fragment total supports 3 per vessel.
- Each Soul Vessel adds "exactly one third of the starting amount, enough for exactly one heal or one spell cast" — [game-checklists](https://game-checklists.com/hollow-knight/112-checklist/)
- How shards are distributed:
  - Some are *bought* from Sly: 500 Geo, then 1500 Geo after delivering the Shopkeeper's Key.
  - Some are *rewards*: the Grubfather after 5 grubs.
  - Grub milestones give charms: 10 grubs, and all 46 grubs.
  - "Collect at least 40 Charms" to buy Salubra's Blessing.

  Source: [game-checklists](https://game-checklists.com/hollow-knight/112-checklist/)
- 112% completion requires only 24 of 35+ bosses, and requires full masks and vessels rather than individual shards — [game-checklists](https://game-checklists.com/hollow-knight/112-checklist/)
- Charms take limited "charm notches"; some are bought, some found — [Wikipedia: Hollow Knight](https://en.wikipedia.org/wiki/Hollow_Knight)
- On discovery, Gibson [DEV]: "discovery, for us, doesn't just mean finding 500 flags or something. 500 coins. It means actually coming upon unique sights, unique characters, unique systems, like a new shopkeeper that offers you something you haven't seen before." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- In the prototype, secret slots S1, S2 and S3 "could be taken up by a grub, or nothing, or a chest" — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)

**Silksong**
- 125 completion items: "20 Mask Shards · 18 Spool Fragments · 52 Tools · 6 Silk Skills · 6 Abilities · 6 Crests · 12 Needle, Crafting Kit and Tool Pouch upgrades · 3 Silk Hearts, the Everbloom and Sylphsong."
- 20 shards give 5 extra masks. Tools come in Red (attack), Blue (defence/utility) and Yellow (mobility), slotted through Crests. All 8 Craftmetals are needed to buy them. Some Spool Fragments are story rewards.

Source: [game-checklists Silksong](https://game-checklists.com/silksong/100-percent.html)

**Ori**
- Blind Forest: health cells, energy cells and ability cells. Soul links (player-made checkpoints) cost energy, "forcing players to create them only when necessary." — [Wikipedia](https://en.wikipedia.org/wiki/Ori_and_the_Blind_Forest)
- Will of the Wisps: Spirit Shards are "collect[ed] within the world to create your own custom loadout... to maximize efficiency of their particular playstyle." — [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)

**Nine Sols**
- Jin currency is spent at shops on items and jades. Jades take a limited number of jade slots — [Wikipedia](https://en.wikipedia.org/wiki/Nine_Sols)
- Jade upgrades and the skill tree also unlock abilities — [GameSkinny review](https://gameskinny.com/?p=196185) [SNIPPET]

**Ender Lilies**
- Relics are equipped with Chains of Sorcery. Amulet fragments raise max HP. Blights upgrade spirits. White Priestesses upgrade prayers (heals) — [Wikipedia](https://en.wikipedia.org/wiki/Ender_Lilies:_Quietus_of_the_Knights)

**Animal Well**
- 4 hearts at start; up to 4 extra blue hearts from blue fruit — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well)

**Dread's per-region rewards**
- Collecting 100% of the items in each of 8 regions unlocks a Chozo Archive image (a 9th unlocks after all 8) — [Metroid Wiki](https://www.metroidwiki.org/wiki/Metroid_Dread)

**Basso's critique of predictable pickups** [DEV]
- "[in Metroid Dread] I was like, I know these are all just missile upgrades. And because I already know ahead of time what I'm going to get, I'm not that excited to go collect them all. Plus they're not going to really enable any new gameplay experiences... It'll just see a number go up and I'll bomb all the hidden walls."

Source: [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)

### Inferences
- **Benchmark numbers.**
  - Health: 4 shards per health unit; 4 to 5 extra units across the game (16 or 20 shards).
  - Magic/silk: 9 to 18 fragments.
  - Build items: 40 to 50+ (charms or tools) as the variety layer.
- **Feed shards through several channels**: hidden rooms, shop stock unlocked by keys, rescue-count milestones and quests. Revisits then pay off in more than one way.
- **Optional pickups should vary in kind**, not just raise a number (Basso). A practical rule: mix every ~3 to 4 stat pickups with a charm, tool, lore item or NPC.

### Gaps
- I could not access verified counts for:
  - Super Metroid: commonly 14 Energy Tanks, 4 Reserve Tanks, 46 Missile, 10 Super Missile and 10 Power Bomb packs, 100 items total. Unverified here.
  - Dread: Missile Tanks, Missile+ Tanks, Energy Tanks/Parts, Power Bomb Tanks.
  - Ori: number of Spirit Shards and cells.
  - Nine Sols: number of jades.
  - Lost Crown: amulets.
  - SotN: relics.

---

## 8. Common gating mistakes cited by reviewers and designers

### Takeaway
Recurring complaints, with named examples:
1. Backtracking with nothing new, made worse by sparse fast travel (Aeterna Noctis, Blasphemous relic hunts).
2. Unmarked breakable walls on the critical path (Dread).
3. Over-funnelling and one-way closures that make an open world feel linear (Dread).
4. Optional rewards that are all the same type (Dread missile tanks).
5. Too much map to hold in memory (Team Cherry cutting Bone Forest).
6. Abilities with unexplained use rules or finicky inputs (Aeterna Noctis).
7. Hard-to-read level design (Ender Lilies, by its own developers' account).

### Cited Findings
- **Aeterna Noctis backtracking** [ANALYSIS] — [FingerGuns](https://fingerguns.net/reviews/2023/02/20/aeterna-noctis-review-ps5-symphony-for-the-devil/); [Push Square](https://pushsquare.com/reviews/ps5/aeterna-noctis); [Wireframe](https://wireframe.raspberrypi.com/articles/aeterna-noctis-review-a-hard-days-night-and-then-some) [SNIPPET; quotes summarised by search, per-outlet attribution not confirmed]
  - More time goes into "backtracking to areas you were already in rather than getting to explore and find new areas."
  - "an obnoxious amount" of backtracking.
  - "sparse fast-travel points, which cause needless backtracking back and forth."
  - "every area is bigger than it has to be."
  - The open structure is "needlessly uncompromising."
- **Aeterna Noctis ability rules** [ANALYSIS] — [PlayStation Country](https://www.playstationcountry.com/?p=19168) [SNIPPET]
  - Abilities are blocked after death until recollected.
  - "if abilities are required to be used in a certain way then that should be explained rather than left to chance."
- **Blasphemous** [ANALYSIS]
  - Relic unlocking "has you backtracking in a boring way" — [Metroidvania Review](https://metroidvaniareview.com/blasphemous/)
  - The checkpoint (Prie Dieu) distance is a frustration — [TheGamer](https://www.thegamer.com/blasphemous-review/) [SNIPPET]
- **Dread** [FAN]
  - Unmarked breakable walls on the main path.
  - Breadcrumbing that sends you to later regions before the current E.M.M.I. is done, which "makes you feel like you're doing things out of sequence."
  - Closed-off old paths make it "feel far more linear."

  Source: [Tildes](https://tildes.net/~games/z02/why_you_didnt_get_lost_in_metroid_dread)
- **Dread's E.M.M.I. fatigue**: a critic said that about halfway in "they stop being scary and start being annoying." — [Nintendo Life (AM2R creator)](https://3dsvc.nintendolife.com/news/2022/03/am2r-creator-isnt-a-fan-of-metroid-dreads-e-m-m-i-encounters) [SNIPPET]
- **Repetitive rewards**: Basso on Dread's missile tanks (see Q7) — [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **Memory load**: Team Cherry cut Bone Forest because players could not retain that much map information; Kingdom's Edge "became the catch-all... a lot of it was just for map balance." — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- **Near-miss frustration**: Gibson: "It's super annoying to get to a point that's 2 centimeters from somewhere you want to be and you can't get there". This is why Hollow Knight maximised inter-area connections — [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map)
- **Ender Lilies**: the developers acknowledged players found the "level design was sometimes difficult to understand," and that contact damage was a top complaint (removed in Ender Magnolia) — [RPGSite interview](https://www.rpgsite.net/interview/16259-binary-haze-interactives-ceo-creative-director-chats-with-us-on-ender-magnolia-the-sequel-to-ender-lilies) [SNIPPET]; [Automaton](https://automaton-media.com/en/news/ender-magnolia-devs-removed-contact-damage-in-response-to-player-feedback-it-felt-unconvincing-to-take-damage-just-from-bumping-into-an-enemy/) [SNIPPET]
- **Brutal first area**: Silksong's first major area (The Marrow) was "a brutal introduction," so Team Cherry added Moss Grotto before it — [GamesRadar](https://www.gamesradar.com/games/action/silksongs-first-area-was-only-added-after-team-cherry-realized-it-needed-a-softer-intro-were-trying-to-be-kind-of-respectful-to-the-player-were-not-trying-to-baby-them)
- **Two general warnings**
  - Tom Happ: "am I doing this just because it's tradition, or because it actually serves the game?" — [Game Developer](https://www.gamedeveloper.com/business/metroidvania-interview-tom-happ)
  - Igarashi: "if you don't think that your game is fun, I doubt anyone else playing it will find it fun either... Feedback from other people is vital!" — [Game Developer: Igarashi advice](https://www.gamedeveloper.com/design/-i-castlevania-i-s-koji-igarashi-offers-advice-to-today-s-metroidvania-devs)
- **Igarashi's reason for exploration over stages** [DEV]: stage-based games "were tending to get more and more difficult, leading to the situation where good players quickly finished them and beginners were no longer getting their money's worth"; the team "really liked The Legend of Zelda." — [Game Developer](https://www.gamedeveloper.com/design/-i-castlevania-i-s-koji-igarashi-offers-advice-to-today-s-metroidvania-devs)

### Inferences
- **Checklist derived from the critiques**
  1. Every gate on the critical path is visually marked; unmarked breakables only guard optional items.
  2. Every backtrack route crosses something new (a shortcut, an NPC, a changed area) or is short thanks to fast travel.
  3. Optional rewards vary in type.
  4. Total map size is budgeted against player memory, with memory aids (map stamps, Memory Shards).
  5. Every key's use rule is taught once, explicitly, in a safe room.
  6. The first area is gentle and teaches the player's reach without prompts.
  7. Funnelled one-way sections are used sparingly, and old paths reopen.
- **"Too many keys too similar" is not well sourced.** Basso's "same item set" critique comes closest. Dread's per-key colour coverings are the countermeasure.

### Gaps
- No sourced critique on "gates that look like walls" by name. The Dread "unmarked wall" complaint is the closest.
- No sourced claim found that dead ends without reward are a flaw in a specific named game; only general backtracking complaints.
- GDC talks not accessed in this pass:
  - Igarashi's GDC 2014 Symphony of the Night postmortem: [archive.org](https://archive.org/details/GDC2014Igarashi)
  - Team Cherry ACMI book
  - Retronauts episode 680 with Tom Happ: [podscripts](https://podscripts.co/podcasts/retronauts/680-axiom-verge)

  They likely contain more designer reasoning.
