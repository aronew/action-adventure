# Metroidvania Macro World Structure: Topology, Regions, Transit, Saves, Maps, Pacing

Scope note: This pass covered 14 benchmark games, with 31 search and fetch calls. Primary-source coverage is uneven. Team Cherry, Ubisoft Montpellier (Memory Shards), Nintendo/MercurySteam (Dread map tools), Billy Basso, Moon Studios (Soul Link) and the Ender Lilies developers produced usable designer statements. For Nine Sols, Lost Crown topology, Blasphemous, Aeterna Noctis and Axiom Verge, only guides, reviews or fan sources turned up. Several primary pages (PC Gamer's Team Cherry map article, the GMTK/Boss Keys transcripts on amara.org, the Stevivor Mahler interview) returned 403 or truncated content, so some claims rest on search-result excerpts and are flagged.

## 1. Region layout and connection topology (hubs, web vs spoke, vertical vs horizontal)

### Takeaway
The benchmarks rarely use one pure topology. They change topology by act: a tight funnel early, then a web or "any order" mid-game, then a remix of the start late. Hubs come in two kinds:
- **Geographic centres**, a region you physically pass through. Hollow Knight's Crossroads is one; Super Metroid's Crateria/Brinstar shafts are others.
- **Non-geographic home bases** that you reach by fast travel. Nine Sols' Four Seasons Pavilion and Lost Crown's Haven are examples.

Silksong adds a strong macro rule, "go up": a single vertical goal (the Citadel) is visible as the world's organising axis.

### Cited Findings
**Hollow Knight**
- After dropping an early procedural or random room-linking idea, Team Cherry planned four areas with the Crossroads in the middle. Pellen says the basic progression came early and the rest of the world grew outward from it. Source: [PC Gamer, "How to design a great Metroidvania map"](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map). Caveat: the fetch returned only the title, so this comes from search excerpts; the 2017 interview was republished in 2025.
- The game began as a game-jam project with a "somewhat randomly generated map", then moved to a deliberate map. Pellen: "It was mainly intuition. We've never put together something like this before" and "We started with the idea of the world, and that was the first thing." Gibson: "all of it's built around this sense of discovery." Source: [Game Developer, "How the Hollow Knight devs mapped out their metroidvania"](https://gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-).
- Early reach is limited to Dirtmouth plus the Forgotten Crossroads, after which the world opens up. This is the Boss Keys analysis as summarised in search excerpts; the transcript itself returned 403. Source: [amara.org transcript of "The World Design of Hollow Knight | Boss Keys"](https://amara.org/subtitles/1YBjcP2T6VPf/en/1/download/The%20World%20Design%20of%20Hollow%20Knight%20%20Boss%20Keys.en.txt).
- Late game, the central hub mutates: the Forgotten Crossroads becomes the Infected Crossroads, and the infection blocks well-travelled routes. This turns the most-used hub into fresh friction without new geometry. Source: [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map) (search excerpt).

**Hollow Knight: Silksong**
- Team Cherry's process: "we'll decide what area we're working on that month, and move through it"; "the plan is never so calcified that it can't bear a change of course two weeks later"; "we establish the foundations, and as those become clearer, the world suggests what else is going to exist." Source: [ACMI, "From Ludum Dare to Pharloom"](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/).
- Pellen: "As the map grew, we're generally not thinking about which power up you are getting next and where … We're thinking about the Citadel at the top of the world, and what's around it." They think space-first rather than item-first. Gibson says they "try to submerge" the lock-and-key element "in favour of a more naturalistic world." Source: [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/).
- Bloomberg's Jason Schreier reports, per search excerpt, that Team Cherry always planned an upward journey from Pharloom to the Citadel and then the Abyss, and built each act in order. Source: [Dexerto, "Creation of Silksong's Pharloom map"](https://jamtest.dexerto.com/gaming/creation-of-hollow-knight-silksongs-pharloom-map-3253000). This is secondary; the original Bloomberg piece was not fetched.

**Silksong structure (GMTK analysis, not designer statements)**
- **Act 1** is a mostly linear "giant U-bend": Moss Grotto → Bone Bottom → The Marrow → Deep Docks → Far Fields → Greymoor → Bellhart → Shellwood, "with little zig-zagging". Bosses come in a sequence: Bell Beast, Lace, Fourth Chorus, Moorwing, Sister Splinter, Widow, Last Judge. Optional skips exist: the Fleas caravan, a Deep Docks door, a Wormways door, and Sinner's Road. Source: [GMTK, "The World Design of Hollow Knight: Silksong"](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Act 2** is open-ended. Three melodies (Conductor's in High Halls, Architect's in Cogwork Core, Vaultkeeper's in Whispering Vaults) can be collected in any order, and the Clawline has two routes (through Trobbio or through Whiteward). **Act 3** mixes a linear Abyss dive with exploration, and the player needs 3 of 4 hearts. Brown calls this a "concertina structure" that alternates forward momentum with slower discovery. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- Pharloom reads as distinct zones with their own palettes. The Citadel (Choral Chambers, Cogwork Core, Whispering Vaults, High Halls, Whiteward, Songclave, Memorium, Cauldron, plus the Cradle and Underworks) shows as one blob on the zoomed-out map and feels like one continuous space. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- The vertical axis is a progression spine. The Drifter's Cloak (updrafts), Cling Grip (wall climb) and Faydown Cloak (double jump, which reaches Mount Fay) all serve "go up". Act 3's Abyss reverses the direction, and Silk Soar gives vertical flight. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- Key/lock density: each ability usually opens only a few locks, and the next lock is usually nearby. Cling Grip is the exception, opening many. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).

**Super Metroid** (Hugo Bille's analysis on Game Developer)
- Crateria's first move is forced: "To the right there is an insurmountable stone wall … Turn left." The first tunnel has doors the player can't open yet, so it becomes a familiar "safe zone" that later gets reopened. Source: [Game Developer, "The Invisible Hand of Super Metroid"](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- Lower Brinstar's "shaft of no return" is a one-way drop that closes off the upper areas and focuses the player on the lower map. Source: [Game Developer](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- Elevators "are usually reserved for passages between different zones", so they act as the macro region boundary marker. Source: [Game Developer](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- Bille argues the game never depends on the player following the intended path; it always provides "a back door", so crucial elements are met eventually, possibly in a different order. Source: [Game Developer](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- Super Metroid is described as a branching hub-and-spoke whose chambers vary widely in size and mechanics, unlike the original Metroid's alternating horizontal and vertical rooms. Source: [Hardcore Gaming 101, Super Metroid](https://www.hardcoregaming101.net/super-metroid/) (critic's view, via search excerpt).

**Castlevania: Symphony of the Night**
- Igarashi's stated reason for the Inverted Castle was to add content more cheaply than making new assets. The whole map was designed to work both ways up. Source: [Wikipedia, Inverted Castle](https://en.wikipedia.org/wiki/Inverted_Castle).
- Ario Barzan's room-shape analysis:
  - The castle has 14 "irregular" (non-rectangular) rooms, 9 of them large or primary.
  - "Nearly half of the map is negative space."
  - The Colosseum and Catacombs are the most compressed areas; the Catacombs are "never higher than two 'rooms'".
  - The Outer Wall is "mostly one vertical block".
  - Clock Tower and Long Library are "two large chunks bookending a minority of smaller bits".
  - The Royal Chapel's theme is ascent, with "the longest continuous staircase in the game".
  - Building subsidiary spaces around primary spaces is "Symphony's rule".
  - Comparison counts: Circle of the Moon has "nearly forty" irregular rooms and Aria of Sorrow has one.

  Source: [Game Developer, "Economy and Thematic Structure: SotN's Level Design"](https://www.gamedeveloper.com/design/economy-and-thematic-structure-symphony-of-the-night-s-level-design).

**Nine Sols**
- The Four Seasons Pavilion is a home base or hub, described as "the hub area connecting all major zones". Named zones with Root Nodes include Factory, Mines, Canal, Reservoir and Warehouse. Sources: [Twinfinite fast travel guide](https://twinfinite.net/guides/how-to-fast-travel-in-nine-sols); [Ludo.guide Root Node locations](https://www.ludo.guide/guide/nine-sols/guides/root-node-locations); [Wikipedia, Nine Sols](https://www.wikiwand.com/en/articles/Nine_Sols).

**Ender Lilies** (developer interview: Okabe, scenario lead; Yokoyama, level and action designer)
- The upper and lower halves of the map were designed to be told apart at a glance. Flooded areas below feel frightening, and the castle top holds dangerous enemies, so players can tell where to go from vertical position alone. Source: [Game*Spark interview, p.2](https://www.gamespark.jp/article/2021/09/05/111615_2.html).

**Aeterna Noctis**
- The developer advertises "16 different and connected areas in a pure Metroidvania style". Source: [aeternathegame.com](https://aeternathegame.com/).

### Inferences
- **Concertina rule (from Silksong and Hollow Knight):** funnel the first several regions in a near-linear chain with optional skips, open a 3-way "any order" phase at the midpoint, then close with a linear descent or corruption remix of known regions. The Infected Crossroads and Silksong's Act 3 both reuse the most familiar space for the late-game remix.
- **A visible "world axis" goal** (Citadel at the top; Dracula's castle keep; Ender Lilies' top equals danger) lets a big web stay legible. Players orient by "up versus down" before they learn region names.
- **Physical hub versus warp hub:** Hollow Knight's Crossroads is crossed on foot repeatedly. Nine Sols' Pavilion is reached by warp, and per the guides, fast travel routes through it. A warp hub gives a story and vendor anchor without forcing the map's geography to be radial.

### Gaps
- No primary-source counts were found for connections per region, such as how many exits the Crossroads has to neighbours. These would need counting from fan maps (for example the Hollow Knight wiki full map), which this pass did not do.
- No Red Candle designer statement on Nine Sols' world layout was found. The Into Indie Games and Digital Trends interviews did not cover it in their excerpts.
- No Ubisoft Montpellier statement on Mount Qaf's macro layout or the Haven was found.
- Silksong's GMTK piece calls Pharloom "12 distinct areas" but then lists more than 20 named places. "Area" versus "sub-area" counting is inconsistent, so do not quote "12" without checking.

## 2. Region size, count and playtime

### Takeaway
Hard room counts are scarce in primary sources. The best ones:
- Animal Well's world is a ~16×16 grid (~256 screens), cut down from 500+ designed rooms.
- Aeterna Noctis has 16 areas and runs ~50 hours.
- Silksong's boss count roughly doubles across acts.
- SotN's completion figure exceeds 200% because the castle is mirrored. The exact number disagrees between sources.

### Cited Findings
- **Animal Well:** the world is roughly a 16×16 grid, so about 256 rooms or "encounters". Basso estimated he designed more than 500 rooms overall, and many were cut or heavily changed. New rooms take "probably five or six iterations of just playing through it". He built sections around a few things he wanted to teach, then grew the map from them. Rooms are placed so tightly that swapping one can affect the whole structure. Sources: [GamesRadar](https://gamesradar.com/games/platformer/solo-dev-behind-breakout-metroidvania-hit-animal-well-says-his-game-has-256-encounters-but-he-had-to-cut-at-least-500-of-them-during-development); [PC Gamer](https://www.pcgamer.com/games/action/animal-wells-solo-dev-casually-reveals-that-the-breakout-metroidvania-left-at-least-twice-as-many-rooms-that-are-in-the-game-on-the-cutting-room-floor). Both report an Edge interview.
- **Silksong bosses:** 12 mandatory and 17 optional through Act 2, rising to 20 mandatory and 25 optional with Act 3. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Silksong optional items:**
  - 20 mask shards, 18 spool fragments, 8 pouch upgrades
  - 6 silk skills, 7 crests
  - 20 red tools, 21 blue tools, 12 yellow tools
  - 20 memory lockets
  - more than 50 secret walls, counted by Brown on a second playthrough
  - Most pick-ups unlock in Act 2 or later.

  Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Silksong first area:** Team Cherry added a softer opening area after finding The Marrow too hard a start: "We're trying to be kind of respectful to the player. We're not trying to baby them." Source: [GamesRadar](https://www.gamesradar.com/games/action/silksongs-first-area-was-only-added-after-team-cherry-realized-it-needed-a-softer-intro-were-trying-to-be-kind-of-respectful-to-the-player-were-not-trying-to-baby-them). Only the headline and quote were retrievable. That the first area is Moss Grotto is per GMTK's route list.
- **Aeterna Noctis:** 16 connected areas ([official site](https://aeternathegame.com/)). "Every area … is exasperatingly big" ([Wireframe review](https://wireframe.raspberrypi.com/articles/aeterna-noctis-review-a-hard-days-night-and-then-some)). Around 50 hours to complete ([TheGamer](https://www.thegamer.com/aeterna-noctis-beginner-tips/)).
- **SotN completion:** one fan source says players need to visit 196% of rooms across both castles, with one full castle counting as 100%. The often-quoted 200.6% was not confirmed in this pass. Source: search excerpt around [Goomba Stomp, flipping the castle](https://goombastomp.com/great-moments-in-gaming-flipping-the-castle-in-symphony-of-the-night/). Sources disagree.
- **SotN versus Bloodstained:** Bloodstained was reported at about 1.5× SotN's size, excluding the Inverted Castle. Source: [My Nintendo News](https://mynintendonews.com/2015/07/14/bloodstained-ritual-of-the-night-is-massive/).
- **Super Metroid Maridia:** a roughly three-screen tunnel in lower Brinstar is labelled on the auto-map as a separate area (Maridia), which teases a region long before entry. Source: [Game Developer, Invisible Hand](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).

### Inferences
- Animal Well's ratio (about 2:1 rooms cut to rooms shipped) is a useful planning heuristic for a dense hand-made map. Budget roughly twice the final room count in design iterations.
- Silksong's numbers suggest a pattern: optional content is back-loaded (most pickups in Act 2+), while the critical path is front-loaded. The early game stays tight and the late game rewards backtracking.

### Gaps
- Per-region room counts for Hollow Knight, Super Metroid, Dread, the Ori games, SotN, Blasphemous and Lost Crown were not retrieved. The Metroid wiki has per-area room lists ([Norfair list](https://metroid.fandom.com/wiki/List_of_rooms_in_Super_Metroid/Norfair)), but they were not tallied.
- Critical-path versus 100% playtime ratios (for example HowLongToBeat figures) were not gathered.
- No numbers were found for "first region" size (rooms or minutes) in any game except the qualitative Silksong note.

## 3. Transit systems and fast travel

### Takeaway
Fast travel is usually paid, sparse and placed at region hubs (Hollow Knight's 11 Stag stations, mostly one-time Geo tolls). Or it is dense and tied to checkpoints (Lost Crown: 56 Wak-Wak trees versus 22 fast-travel altars). Several games deliberately break fast travel between macro chunks to preserve distance: the Citadel/Pharloom split in Silksong, and Nine Sols' "Pavilion and last node only" behaviour.

### Cited Findings
**Hollow Knight Stag stations**
- There are 11 stations: Dirtmouth, Forgotten Crossroads, Greenpath, Queen's Station, Queen's Gardens, City Storerooms, King's Station, Resting Grounds, Distant Village, plus the Hidden Station (Ancient Basin) and the Stag Nest. Sources: [Hollow Knight wiki, Fast Travel](https://hollowknight.wiki/w/Fast_Travel_(Hollow_Knight)); [Fextralife Stag Station](https://hollowknight.wiki.fextralife.com/Stag+Station); [Steam discussion list](https://steamcommunity.com/app/367520/discussions/0/1729827777356010149).
- Most stations charge a one-time Geo toll, for example Forgotten Crossroads 50 and Greenpath 140. Resting Grounds opens by lever, and Hidden Station and Stag Nest are free. One source gives 9 stations (PinDrop, an older build or a pin count). Sources: [Fextralife](https://hollowknight.wiki.fextralife.com/Stag+Station); [PinDrop](https://pindrop.gg/hollow-knight/map/stag-station).

**Silksong**
- The Bell Beast and Bellways are Pharloom's fast travel. The Citadel uses separate pneumatic elevators, linked to Pharloom only through the Grand Bellway, so returning to Act 1 areas costs an extra step. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- Brown would have preferred walking back to Bone Bottom over Bell Beast travel in Act 3, and notes Mount Fay's fast travel is a cold hazard. Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- A fan site claims Bellways are unlocked through a Bell Beast encounter in Bellhart. This is unverified. Source: [Nerdschalk](https://nerdschalk.com/hollow-knight-silksong-full-map-everything-we-know-so-far/).

**Nine Sols root nodes**
- Root Nodes are checkpoints and the fast-travel network. Fast travel unlocks once the player reaches the Four Seasons Pavilion Root Node and gets the Fusang Horn from Lear. Source: [Twinfinite](https://twinfinite.net/guides/how-to-fast-travel-in-nine-sols).
- Sources conflict on how far it reaches:
  - Guides say travel works only between the Pavilion and the last visited node ([Twinfinite](https://twinfinite.net/guides/how-to-fast-travel-in-nine-sols)).
  - A May 2024 Steam thread quotes the Fusang Horn text as allowing travel to ANY registered node and calls the restriction a likely bug ([Steam discussion](https://steamcommunity.com/app/1809540/discussions/0/4333105050947440555)).
  - Another guide says the function is improved later to reach any visited node ([Into Indie Games walkthrough](https://intoindiegames.com/walkthroughs/nine-sols-walkthrough-part-2/)).

  Unresolved.
- Fast travel routing through the hub reinforces the story's context. Source: [Slant Magazine review](https://www.slantmagazine.com/games/nine-sols-review/).

**Prince of Persia: The Lost Crown**
- Wak-Wak trees are checkpoints where the player heals, saves and respawns. Separate Homa Statues form the fast-travel network, unlocked after destroying an anomaly. One guide counts 56 Wak-Wak trees and 22 fast-travel altars across Mount Qaf, and a Homa Statue sits beside the Soma Tree in the Haven. Sources: [Guides4Gamers](https://guides4gamers.com/prince-of-persia-the-lost-crown/poi/wak-wak-trees); [Game8](https://game8.co/games/Prince-of-Persia-The-Lost-Crown/archives/439388); [GamePressure fast travel list](https://www.gamepressure.com/prince-of-persia-the-lost-crown/all-fast-travel-points/z9111ea). These counts come from guides, not Ubisoft.

**Super Metroid**
- Elevators mark zone transitions, and a save point sits right by the elevator to Ridley's lair ("You are going to need it"). Source: [Game Developer, Invisible Hand](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).

### Inferences
- The checkpoint-to-fast-travel ratio is a tuning knob. Lost Crown is about 2.5:1 (56:22), while Hollow Knight's stag-to-bench ratio is about 11:52 (see section 4). Fewer travel nodes than save nodes keeps traversal meaningful.
- Splitting fast-travel networks by macro chunk (Silksong's Bellways versus Citadel elevators) is a technique for making a late region feel "far away" without adding walking distance.
- One-time tolls (Hollow Knight) put a currency cost on opening travel, which ties the economy to world access.

### Gaps
- Ori Spirit Well counts and unlock timing, Dread's teleporter, train and elevator counts, Blasphemous Prie Dieu and teleport counts, and Animal Well's travel system were not retrieved.
- No designer rationale for the number or placement of Hollow Knight Stag stations was found.

## 4. Save, bench and checkpoint spacing and placement

### Takeaway
There are three placement philosophies:
- **(a)** Always place a save right before every boss: Ender Lilies, explicitly stated by its developer, and Dread's auto-checkpoints around E.M.M.I. zones.
- **(b)** Sparse benches with deliberate run-backs: Hollow Knight. This is widely criticised, and Silksong reportedly has more and nearer benches.
- **(c)** Player-placed or manual saves: Ori's Soul Link, which Moon Studios abandoned for checkpoints in Will of the Wisps.

### Cited Findings
- **Ender Lilies:** Yokoyama says "セーブポイントも必ずボス前に置くようにしています", meaning they always place a save point before each boss. Source: [Game*Spark interview p.2](https://www.gamespark.jp/article/2021/09/05/111615_2.html).
- **Metroid Dread:** per fan analysis, invisible checkpoints sit just before entering and just after leaving E.M.M.I. zones, before and after bosses, and after inter-region travel. E.M.M.I. only patrol their own zones, so players know when they're entering one. Sources: [Why You Didn't Get Lost in Metroid Dread (transcript)](https://amara.org/subtitles/Aci4iDbgsAtY/en/1/download/Why%20You%20Didnt%20Get%20Lost%20in%20Metroid%20Dread.en.txt), via search excerpt with the fetch blocked; [Nintendo Everything, E.M.M.I. interview with Sakamoto](https://nintendoeverything.com/metroid-dread-hd-emmi-interview-yoshio-sakamoto/).
- **Hollow Knight bench count:** a checklist lists 52 benches in total. Source: [game-checklists.com](https://game-checklists.com/hollow-knight/benches-checklist/).
- **Hollow Knight versus Silksong:** one critic says Hollow Knight has far fewer benches than Silksong, and that they are farther away, making run-backs longer. Source: [Elliot C Smith, "Get Good: Is Silksong too hard?"](https://www.elliotcsmith.com/get-good-is-silksong-too-hard/).
- **The run-back debate:**
  - One former player argues "there should be a bench outside every single boss room" ([Epilogue Gaming, "Why I Quit Playing Hollow Knight"](https://epiloguegaming.com/?p=7321)).
  - A designer in an r/gamedesign thread counters that a bench before every boss can feel "too much like a video game world".
  - Others in the same thread call Hollow Knight's boss approaches "arduous labours that provided very minimal learning".

  Source: [r/gamedesign thread](https://libreddit.winscloud.net/r/gamedesign/comments/1nodf87/can_someone_explain_the_design_decision_in/nfrj8j8/?context=3). These are opinions; no Team Cherry statement on bench spacing was found.
- **Silksong benches:**
  - Resting on a bench fills in the map with visited areas.
  - Underworks benches are pay-per-use, which Brown reads as environmental storytelling.
  - Brown dislikes corpse-running because it pulls players back to one spot instead of encouraging other exploration. Mitigations exist, such as rosary strings and the Silkeater.

  Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Ori:**
  - In Blind Forest, Soul Links let players save anywhere at the cost of scarce energy ([Wikipedia](https://en.wikipedia.org/wiki/Ori_and_the_Blind_Forest)).
  - For Will of the Wisps, after playtesting with the new abilities and weapons, the team tried checkpoints instead. The B button was also needed. Mahler raised the problem of "how you remind people to put down a Soul Link" and said "Nobody missed" it.

  Sources: [Stevivor interview](https://stevivor.com/features/interviews/soul-link-ori-will-wisps-thomas-mahler) (search excerpt; the fetch was blocked); [VideoGamer](https://www.videogamer.com/soul-links-in-ori-and-the-will-of-the-wisps-didnt-make-sense-says-developer).
- **Super Metroid:**
  - A save point near the Wall Jump shaft lets the player save while trapped below the one-way drop.
  - The Wrecked Ship save station "will refuse you service" until Phantoon is beaten (power is out). The save point itself carries the state of the region.

  Source: [Game Developer, Invisible Hand](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).

### Inferences
- Rule candidates:
  - Always put a save before a boss arena (Ender Lilies, Dread).
  - Put a checkpoint on both sides of a "danger zone" (Dread's E.M.M.I.).
  - Put a save just after any one-way drop (Super Metroid).
  - Make one region's saves conditional, or cost currency, as region flavour (Wrecked Ship, Underworks).
- The run-back length is the contested variable. Since Silksong reportedly moved toward more benches, that suggests Team Cherry itself loosened the Hollow Knight approach. This is an inference, not a stated rationale.

### Gaps
- No systematic dataset was found of bench-to-boss distances (rooms or seconds) for Hollow Knight or Silksong.
- No Red Candle statement on Root Node spacing was found.
- Blasphemous Prie Dieu spacing and Aeterna Noctis checkpoint rules were not retrieved.

## 5. Map systems (buying, reveal, pins, highlighting, screenshots) and why

### Takeaway
Each benchmark's map system answers one problem.
- Hollow Knight and Silksong sell area maps from a wandering cartographer, which preserves discovery.
- Dread adds icon-highlighting for blocks and doors, which reduces "where did I see that lock".
- Lost Crown's Memory Shards (capped at 15) solve the problem of forgetting where you meant to return after a break.
- Ender Lilies deliberately keeps an abstract box map with red-circle unexplored exits, which keeps exploration a challenge.

### Cited Findings
- **Hollow Knight:** Team Cherry calls keeping a sense of discovery while still giving a useful map "the single biggest design challenge". Source: [PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map) (search excerpt).
- **Hollow Knight map accuracy:** a fan analysis of the full map says it closely matches the room layout, and a "98% pure" remark is attributed to Gibson. Attribution is unclear from excerpts; treat as unverified. Sources: [amara "Hollow Knight's Map is Broken"](https://amara.org/subtitles/stk1ABNP63rg/en/2/download/Hollow%20Knights%20Map%20is%20Broken.en.txt); [SUPERJUMP, "Getting Lost (by Design) in Hollow Knight"](https://www.superjumpmagazine.com/getting-lost-by-design-in-hollow-knight/).
- **Silksong:**
  - Areas start unmapped, and Shakra sells a map per zone.
  - Brown names "map poking" (probing unexplored map edges until progress happens). Secret walls do not show on the map, so poking can't find them.
  - Trail's End requires buying all of Shakra's maps.

  Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Metroid Dread:**
  - The official developer report describes more detailed map outlines, zoom, and "Icon Highlight", which lights up every icon of a chosen type (door, block, item) across the area and beyond.
  - Hidden breakable blocks on the main path "always have some hint" (an enemy, a glimpse of passage, a sound).

  Sources: [Nintendo AU, Dread Report Vol. 9](https://www.nintendo.com.au/news-and-articles/metroid-dread-report-vol-9-handy-tips-for-newcomers); [GamingBolt](https://gamingbolt.com/metroid-dread-map-improvements-include-markers-icon-highlighting-hints-and-more); [Nintendo Everything](https://nintendoeverything.com/metroid-dread-report-vol-9-released-details-controls-exploration-more).
- **Dread criticism:**
  - Block icons showing which weapon breaks them were found hard to read ([GamesRadar review](https://www.gamesradar.com/uk/metroid-dread-review)).
  - A commentator argues that breadcrumbing plus closing old paths made Dread feel more linear ([Tildes discussion of "Why You Didn't Get Lost in Metroid Dread"](https://tildes.net/~games/z02/why_you_didnt_get_lost_in_metroid_dread)).
  - Boss Keys notes Dread often temporarily locks the player into a small segment of the map (search excerpt).
- **Lost Crown Memory Shards (Rémi Boutin, senior game designer):**
  - A button press screenshots the room without HUD and pins it to the map.
  - Players start with 15, which can be increased but never made unlimited.
  - The cap began as a cloud-save file-size constraint and had "an interesting side effect": players manage shards efficiently, which keeps the map "clean".
  - The starting count changed several times in playtests before settling on 15.
  - Extra shards are sometimes placed in a chest near a blocked path, as a reminder that the feature exists.
  - Origin: "We were playing metroidvanias, we took a break, and when looking at our map we forgot what we were trying to do."
  - "It took tons of iteration and playtest to get a 'natural' feeling."

  Source: [Game Developer, Memory Shards](https://gamedeveloper.com/design/how-memory-shards-help-players-find-secrets-in-prince-of-persia-the-lost-crown). The page's displayed title is wrong, but the content is the Memory Shards article.
- **Lost Crown, further statements:**
  - Game director Mounir Radi said Memory Shards "came up on the table, to solve a memorisation issue" ([Press Start](https://press-start.com.au/?p=151027)).
  - Boutin said it began as an accessibility tool for disabled players and became a primary feature ([Digital Trends](https://digitaltrends.com/gaming/prince-of-persia-the-lost-crown-memory-shards-development)).
  - Map pieces are bought from Fariba in each biome, and players find her by her humming ([Ubisoft news](https://www.ubisoft.com/en-sg/game/prince-of-persia/news-updates/72RTKP9W7jiO9avMv9CGRt/use-the-eye-of-the-wanderer)).
- **Ender Lilies (Yokoyama):**
  - The map shows each area as a square joined by lines, with no terrain detail.
  - Area colour shows whether its items are collected; items themselves are not marked.
  - Unopened routes are red circles.
  - The map deliberately carries no story guidance, "an older style", to keep exploration challenging. A stuck player may have to re-search a whole stage.

  Source: [Game*Spark p.2](https://www.gamespark.jp/article/2021/09/05/111615_2.html). The sequel, Ender Magnolia, changed the map; lead designer Yokoyama called it a risky change that Early Access feedback validated ([Automaton](https://automaton-media.com/en/news/ender-magnolia-devs-removed-contact-damage-in-response-to-player-feedback-it-felt-unconvincing-to-take-damage-just-from-bumping-into-an-enemy/)).
- **Super Metroid:**
  - Map rooms exist in Crateria, Brinstar, Norfair, Maridia and the Wrecked Ship. They reveal most of an area, including some rooms behind walls, but not all ([search summary of HG101 and analyses](https://www.hardcoregaming101.net/super-metroid/)).
  - The Brinstar map shows "a clearly missing connection between the eastern and western parts". Kraid's lair is the one place where the map is the only hint ([Game Developer, Invisible Hand](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)).
- **Aeterna Noctis:** fog of war is lifted only by buying a map from a vendor. Source: [TheGamer](https://www.thegamer.com/aeterna-noctis-beginner-tips/).
- **Nine Sols map readability:** reviews call the map the game's main weakness, and map chips help only partially. Sources: [GamesRadar review](https://gamesradar.com/games/action/nine-sols-review); [Prima Games](https://primagames.com/?p=266102).

### Inferences
- The map's job can be framed as a choice:
  - **Discovery-preserving:** buy or draw it (Hollow Knight, Silksong, Aeterna Noctis, Lost Crown's Fariba).
  - **Memory-supporting:** pins, screenshot shards, icon highlight.
  - **Challenge-preserving:** abstract map with no item markers (Ender Lilies).

  Lost Crown combines a buy-the-map system with Memory Shards, so the two are not exclusive.
- A **capped pin budget** (15 shards) is a deliberate readability tool, not only a technical limit. Consider capping pins in a new game.
- **Showing a "missing connection"** on a revealed map (Super Metroid's Brinstar) works as a macro-level "lock before key".

### Gaps
- No primary Team Cherry quote on why Cornifer specifically sells maps and the Quill draws them was retrieved, beyond the "biggest design challenge" framing.
- No MercurySteam or Sakamoto rationale for the icon styling was found. Nintendo's report gives only features and intent.
- Ori's map system and Animal Well's map (stamps or pencil) were not covered.

## 6. How the world communicates its shape

### Takeaway
The legibility tools that recur:
- Region-specific palettes (Pharloom versus the "one blob" Citadel)
- Vertical-position semantics (Ender Lilies: flooded below, danger at the top)
- Sight-lines into regions you can't yet enter (Super Metroid's glass tube into Maridia)
- Statue or mural foreshadowing of the final gate (Super Metroid's Tourian statue room)
- Music-change thresholds placed at landmarks rather than doors (Super Metroid's Crateria)

### Cited Findings
- **Super Metroid sight-lines:**
  - Lower Brinstar's glass tunnel is "the only thing we know about Maridia" until the player breaks in.
  - Maridia's pipe ride shows rooms "swoosh by in the background".
  - The statue room depicts the four major bosses and is the gateway to Tourian.
  - Kraid's statue greys out after his defeat.
  - Crateria's cave music changes only at the outdoor environment, so players don't notice they've returned to Crateria. This is a deliberate disorientation or surprise.

  Source: [Game Developer, Invisible Hand](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- **Super Metroid visual cues:** the Charge Beam corridor has "two blocks [that] stand out like a sore thumb". Source: [same](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- **Silksong:** Pharloom zones have distinct palettes, while the Citadel reads as one continuous space. The world layout reinforces the pilgrimage narrative (climbing toward the Citadel). Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Hollow Knight and Silksong intent:** Gibson wants players "to see the entirety of the world, and to see what's around those corners". He also likes "just saying: 'Here's the world. Off you go!'" over tutorials. Source: [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/).
- **Ender Lilies:** a vertical-position mood gradient makes the map's upper and lower halves distinct, and the second half's change in atmosphere is meant to be felt intuitively (Okabe). Source: [Game*Spark p.2](https://www.gamespark.jp/article/2021/09/05/111615_2.html).
- **SotN:** each area has a navigational theme, for example the Royal Chapel's ascent and the longest staircase. Area shapes differ strongly: one vertical block, two-chunk bookends, a flat two-room-high Catacombs. The castle silhouette itself distinguishes areas. Source: [Game Developer, SotN](https://www.gamedeveloper.com/design/economy-and-thematic-structure-symphony-of-the-night-s-level-design).
- **Aeterna Noctis:** its 16 areas are described as belonging to "the same coherent and connected universe". Source: [aeternathegame.com](https://aeternathegame.com/).
- **Axiom Verge:** Tom Happ "started off just by drawing map areas" (early map dated May 2010). The map's semi-openness makes players feel they cause events rather than follow a script. Sources: [PlayStation Blog](https://blog.eu.playstation.com/2015/03/31/axiom-verge-adventure-5-years-making/); [Game Developer interview](https://gamedeveloper.com/business/metroidvania-interview-tom-happ).
- **Nine Sols:** the factory regions and forges are praised for backgrounds and level design, but the game is said to need more guidance. Source: [GamesRadar review](https://gamesradar.com/games/action/nine-sols-review).

### Inferences
- **Area silhouette as identity:** design each region's outer bounding shape to be distinct on the zoomed-out map, as SotN does (tall block, L-shape, flat strip). That gives map-level recognition independent of art.
- **"Shape" exceptions:** a region that intentionally does not have its own palette but reads as one blob (the Citadel) can signal "this is the destination", as opposed to the "frontier".

### Gaps
- No primary sources were found on Ori's landmarks, Blasphemous' biome identity, or Animal Well's environmental landmarks.
- No primary data was found on "everything connects" shortcut moments, such as how many inter-region shortcuts Hollow Knight has.

## 7. Region pacing: difficulty, roster, verbs, and openness

### Takeaway
- The early game is funnelled in nearly every benchmark: Super Metroid's left-only Crateria, Hollow Knight's Dirtmouth and Crossroads, Silksong's Act 1 U-bend.
- Openness peaks at a mid-game "pick any of N" (Silksong's three melodies).
- Late regions add environmental damage. Ender Lilies' developers admit they over-did it ("under-tuned"), producing unfairness.
- Optional routes are used to modulate difficulty.

### Cited Findings
- **Silksong:**
  - Act 1 is linear with a fixed boss sequence; Act 2 is three-way any-order; Act 3 is linear then open.
  - Alternate routes let players bypass hard fights, which works as difficulty modulation.
  - Backtracking in Acts 1–2 is mostly optional and unlocks optional rewards (Hunter's March, Sands of Karak, Wisp Thicket, Memorium).
  - Bilewater and Putrified Ducts are hidden behind secret walls. Brown finished the game without visiting Bilewater.

  Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Silksong criticism:** the Silk and Soul quest requires the Faydown Cloak, the Bellhome key, 22 fleas and 17 quest points. Its prerequisites "are not discoverable in-game". Source: [GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight).
- **Ender Lilies (Yokoyama):**
  - Difficulty was designed to rise with the story, adding gimmicks that match each area's scenery.
  - Late areas pile on damaging zones (miasma), which they admit were under-tuned and felt unfair rather than challenging.
  - The early stages are easy, so the difficulty gap is large.
  - The dodge was originally gated behind clearing the Catacombs.

  Source: [Game*Spark p.2](https://www.gamespark.jp/article/2021/09/05/111615_2.html). Players also found the level design hard to read at times ([RPG Site](https://www.rpgsite.net/interview/16259-binary-haze-interactives-ceo-creative-director-chats-with-us-on-ender-magnolia-the-sequel-to-ender-lilies)).
- **Super Metroid:**
  - Norfair's heat limits early reach, so the reachable area is small.
  - Kraid's lair entrance is "concealed behind a wall by the elevator to Norfair", findable only via the western Brinstar Map Room, which the one-way shaft cuts off.
  - A run-button room locks the player in until they learn to run.

  Source: [Game Developer, Invisible Hand](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid).
- **Metroid Dread:** E.M.M.I. zones are separate "Dread Zones" from normal exploration, patrolled only inside their bounds. Sakamoto conceived them about 15 years earlier for the DS version, and tuned their difficulty to emphasise dread. Sources: [Nintendo Everything](https://nintendoeverything.com/metroid-dread-hd-emmi-interview-yoshio-sakamoto/); [Shinesparkers](https://shinesparkers.net/sakamoto-reveals-he-first-conceived-the-e-m-m-i-fifteen-years-ago/); [Nintendo Wire](https://nintendowire.com/news/2022/01/24/metroid-dread-producer-discusses-the-games-difficulty-and-why-the-e-m-m-i-encounters-were-so-unforgiving/).
- **Animal Well:** Basso built each section around a few things to teach, then grew outward. He called metroidvania design much harder than linear platformers. Source: [GamesRadar](https://gamesradar.com/games/platformer/solo-dev-behind-breakout-metroidvania-hit-animal-well-says-his-game-has-256-encounters-but-he-had-to-cut-at-least-500-of-them-during-development).
- **Hollow Knight and Silksong:** Pellen says they are generally "not thinking about which power up you are getting next and where", designing space-first. Source: [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/). This contrasts with Basso's teach-first sections, a genuine difference in philosophy between the two sources.

### Inferences
- **Counterexample and pitfall:** stacking environmental damage in late regions (Ender Lilies) is the developers' own admitted mistake. Prefer new enemy and verb combinations over attrition zones.
- **Openness metric:** count simultaneously available "next objectives". Silksong goes from 1 (Act 1, plus optional skips) to 3 (Act 2) to "3 of 4" (Act 3). This gives a concrete knob for a new game's non-linearity curve.
- **Space-first versus teach-first:** Team Cherry and Basso describe opposite generative orders. Either can work; pick one consciously.

### Gaps
- No primary-source data was found on Ori, Blasphemous, Nine Sols or Lost Crown region difficulty curves or ability distribution per region.
- No primary source from Thomas Mahler on Ori world structure was retrieved (Stevivor returned 403; the Playday podcast was not transcribed).
- Igarashi's statements on SotN pacing and area order were not found beyond the Inverted Castle rationale.
- Blasphemous: no sources found in this pass on its world topology, hubs (Albero), Prie Dieu spacing or teleport system.
