# Metroidvania Micro Scale: Room Composition and Room-to-Room Flow

Scope note: these notes cover the micro scale (single rooms and the links between them). They skip the basics the user already knows (sparse natural platforms, mass floors, black-box collision, shortcut folding and re-contextualized geometry in general) and add specifics, numbers, named examples and pitfalls instead. Primary developer statements are marked **[dev]**, third-party analysis **[analysis]**, and fan or unverified claims **[fan/unverified]**. Points under "Inferences" are this researcher's synthesis. Where an Inference names an example from memory with no source found, it is tagged **(recall, unsourced - verify)**.

Research limits: about 37 tool calls. Several primary pages blocked fetching (TechPowerUp's reprint of the Ubisoft interview, the Boss Keys transcript on amara.org) or came back truncated (the PC Gamer map-design article, GamesRadar body text). The sources available for Nine Sols, Aeterna Noctis, Ender Lilies and Metroid Dread room craft say very little at the micro scale; the Gaps sections record each of these.

---

## 1. Room types and their jobs (corridor, shaft, arena, platforming challenge, hub, save, secret, boss antechamber); sizes in screens; frequency

### Takeaway
Only two of these games have published numbers. Super Metroid builds rooms from 256x256-px "screens" of 16x16 blocks, and a typical room is 1 to 30 screens. Blasphemous builds from fixed screens, with save altars never more than 7 screens apart. Room-type frequencies are not published for any of the games. The best available proxies are total room counts (Animal Well 256; Ori WotW 300+ "levels"; Hollow Knight about 307 by fan count).

### Cited Findings
- **Super Metroid screen unit [ROM-hacking docs]:** one Super Metroid screen is 256x256 px, which is 16x16 blocks of 16x16 px each. Rooms are built from these screens, and a typical room spans 1 to 30 screens. — [Super Metroid Mod Manual (Metroid Construction)](https://metroidconstruction.com/SMMM/); room range also stated in [AAAI paper "Content Reinjection for Super Metroid"](https://cdn.aaai.org/ojs/18905/18905-52-22671-1-2-20211004.pdf)
- A room's size in screens is a property you edit (Room Properties: width and height in screens). It is limited by per-room tile data and by "scroll data", which sets which screens the camera may scroll into, so a room's camera bounds are authored per screen. — [Moonedit SMILE FAQ](https://forum.metroidconstruction.com/index.php/topic,300.0.html); [SMMM](https://metroidconstruction.com/SMMM/)
- The original NES Metroid strictly alternated horizontal and vertical rooms. Super Metroid dropped that rule, and its rooms "vary wildly in size, layout, purpose, and mechanics." [analysis] — [Anatomy of Metroid (GameSpite, archived)](https://www.quaddicted.com/webarchive/www.anatomyofgames.com_20170315/gamespite-quarterly/the-anatomy-of-metroid-i/index.html)
- **Blasphemous [dev, Enrique Colinet, lead level designer]:** the team first built large scrolling areas, then switched to fixed screen-based scenes in June 2018 because the levels felt too big, were hard to build collaboratively, and hurt performance. The hierarchy is district, then zone, then scene. Prie Dieu save altars sit about one per area and are "never more than seven screens apart." — [Game Developer: How Blasphemous' level design iterates on classic Metroidvanias](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Blasphemous boss-room placement [dev]:** boss fights are placed next to shortcuts (citing classic God of War) so that after a boss players can "go straight to wherever they want to be." — [Game Developer (Blasphemous)](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Animal Well [dev, Billy Basso]:** exactly 256 rooms on a 16x16 grid, because each room had a one-byte ID. "I just focused on making every room as dense as possible." He designed 500+ rooms that were cut or "altered beyond recognition", at least twice as many as shipped. — [Game Developer: scratch coding and discipline at the heart of Animal Well](https://www.gamedeveloper.com/programming/the-scratch-coding-and-discipline-at-the-heart-of-animal-well); [PC Gamer on cut rooms](https://www.pcgamer.com/games/action/animal-wells-solo-dev-casually-reveals-that-the-breakout-metroidvania-left-at-least-twice-as-many-rooms-that-are-in-the-game-on-the-cutting-room-floor/); [GamesRadar: 256 encounters, 500 cut](https://www.gamesradar.com/games/platformer/solo-dev-behind-breakout-metroidvania-hit-animal-well-says-his-game-has-256-encounters-but-he-had-to-cut-at-least-500-of-them-during-development/)
- **Ori and the Will of the Wisps [dev, Thomas Mahler]:** "300+ levels", which makes the whole game "one large puzzle"; changing one area "might have bad effects on this one spot" elsewhere. — [Game Developer Q&A: Designing Ori and the Will of the Wisps](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- **Hollow Knight room count [fan/unverified]:** fans who rebuilt the map from screenshots counted 307 rooms. — reported in [The Untold Truth of Hollow Knight (SVG)](https://www.svg.com/366885/the-untold-truth-of-hollow-knight/)
- **Hollow Knight room dimensions [fan/modding docs]:** a sample custom-scene setup in the modding API docs uses a tilemap of `width = 30; height = 17` cells. This is a modding example, not a confirmed vanilla room size. — [Hollow Knight Modding API docs: Creating custom scenes](https://radiance.synthagen.net/apidocs/_images/NewScene.html)
- **Hollow Knight process [dev, Pellen]:** room and map layout was guided by "mainly intuition", not rules such as set tile counts per room. The world came first, then the route through it. Early random room-linking was abandoned. — [Game Developer: How the Hollow Knight devs mapped out their Metroidvania](https://gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-)
- **Ability "learning workshop" rooms, Prince of Persia: The Lost Crown [dev, Mounir Radi, game director]:** right after a new ability, the player is "exposed to a learning workshop highlighting blockers similar to those he met previously." Timed challenges use "short-term" frameworks "to remove friction in case of failure." — [GameRant interview](https://gamerant.com/prince-persia-lostcrown-metroidvania-gameplay-interview/)
- **Lost Crown optional hard rooms [dev, Tom Guiraud, level designer]:** the hardest platforming challenge is tucked into an "innocuous" optional room, built as a series of difficult challenges for players who want them, and re-tested by several level designers each time a chapter was added. — [Remap Radio: Prince of Persia and the High Price of Pants](https://remapradio.com/articles/prince-of-persia-and-the-high-price-of-pants)
- **Super Metroid tutorial room [analysis, Hugo Bille]:** a "run-button room" has a brittle floor that drops you unless you run, and it locks you in until you learn to run. Two separate Grapple tutorial rooms come before a Crateria room that needs the same technique. — [Game Developer: The Invisible Hand of Super Metroid](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)

### Inferences
- Rule candidates from the published numbers: cap the distance between safe rooms (Blasphemous uses at most 7 screens). Put a shortcut out of every boss room. Follow every major ability pickup with a short "workshop" room that restates an earlier blocker (Lost Crown). Pair each optional hard platforming room with a low-cost retry (respawn at the room entrance).
- Super Metroid's 1-to-30-screen range points to a long-tailed distribution: many 1-to-2-screen connectors and save/map/recharge rooms, and a few huge multi-screen shafts and halls. Recall examples include the 1-screen save rooms and long shafts such as Red Brinstar's tower. (recall, unsourced - verify)
- An authored, per-screen camera-scroll mask (Super Metroid "scroll data") is the right primitive in Godot as well: per-room camera limits plus optional sub-region locks.

### Gaps
- No source gives a measured breakdown of room types by frequency (for example, the percentage of corridors versus arenas) for any of the games. Getting one would need a manual count from map rips.
- No published room sizes in screens for Hollow Knight, Silksong, Nine Sols, Ori, Dread, Ender Lilies, Aeterna Noctis or Lost Crown.
- Hollow Knight's 307-room figure is a fan count and could not be traced to a primary source.

---

## 2. Room composition: mass terrain versus platforms, keeping platforms natural, solid versus background readability, silhouettes, drawing routes into terrain

### Takeaway
The clearest developer technique is to start a room from a concrete place-image ("a cavern with a lake on the left", "a ruined tower") instead of an empty box, and let that image decide where platforms go (Team Cherry). Moon Studios blocks out Ori's rooms as free polygons, not a grid, and gets design approval before any art. For readability, the classic rules are to make collision edges the brightest values and the background darker, use warm edge outlines, and use a single light direction.

### Cited Findings
- **Team Cherry [dev, William Pellen, Silksong]:** "If you're trying to build a Mario level, you might take an empty space and think, oh, should there be a few platforms here?... But if you just start thinking- well, it's a cavern with a lake on the left or it's a ruined tower," the micro-level space design "is much easier." Also: "If you think about it more as a world and a space, it's actually much easier to come up with stuff to put in it." — [ACMI: From Ludum Dare to Pharloom](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/); headline quote in [GamesRadar](https://www.gamesradar.com/games/action/team-cherry-explains-the-silksong-development-process-that-was-so-fun-devs-just-couldnt-stop-if-youre-trying-to-build-a-mario-level-you-might-take-an-empty-space-and-think-oh-should-there-be-a-few-platforms-here/)
- Team Cherry approach environments "less as a series of levels, and more as the building out of space." [ACMI narration] — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/)
- **Ori [dev, Mahler]:** "we simply draw polygons that define the platforms and shapes Ori will run and jump on." The world is not grid-based. Each blockout gets "harsh and honest feedback" from other designers until it earns a "design approved" stamp, and only then does set dressing start. Hundreds of objects (bouncy twigs, ropes) were rigged to react to Ori's movement, and projectiles double as traversal opportunities. — [Game Developer Q&A (Ori WotW)](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- **Ori [dev, Gennadiy Korol]:** the studio "always starts with the solids"; an enemy that isn't fun while you're jumping on boxes won't be fun in the final art. — [MCV: Unity focus, making Ori and the Blind Forest](https://www.mcvuk.com/development-news/unity-focus-making-ori-and-the-blind-forest/)
- **Ori [dev, Mahler]:** every level is designed so that "every jump feels really good". The level-design goal is to avoid stretches of holding the stick forward (a "walking simulator"). He also says Perlin-noise heightmap terrain is boring and that experienced people "can spot it from miles away." — [Film Stories interview](https://filmstories.co.uk/gaming/ori-and-the-will-of-the-wisps-interview-making-a-masterpiece/); [80.lv](https://80.lv/articles/ori-designer-explined-why-players-are-tired-of-open-worlds)
- **Hollow Knight has no pass-through (one-way) platforms [analysis/opinion]:** every surface is solid, so rooms need explicit routes (ledges, wall-cling surfaces, wing heights). The analyst's claim that this was a deliberate choice is not sourced to Team Cherry. — [Ludonauta: The Hidden Genius Behind Hollow Knight's Terrain Design](https://ludonauta.itch.io/platformer-essentials/devlog/1084669/the-hidden-genius-behind-hollow-knights-terrain-design)
- **Hollow Knight tile size [fan/unverified]:** an itch.io commenter says Team Cherry blocked out levels with 64x64-px tiles and placed HD art over them by hand. This is secondhand and unconfirmed. — [itch.io comments, Mossy Cavern](https://maaot.itch.io/mossy-cavern/comments?after=0)
- **Blasphemous [dev, Colinet]:** art ideas for a scenario shape the level, the level shapes the enemies and further art, and "a cycle of continuous iteration is born." Level design goes "hand-in-hand" with art and narrative. — [Game Developer (Blasphemous)](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Readability rules [Adam Saltsman, "Sexy Tiles: Sidescrollers"]:** block in the play area first. Use bright, obvious floors and walls and dark, receding backgrounds, then strip the color to check the values (about 3 values is enough). Add bright edges on solids and darker bands on background tiles. A warm (dark red) outline on solids makes them advance against cool backgrounds. Use one consistent light source. "Gameplay edges win visual priority over light and shadow." Break the grid with irregular shapes, as Flashback's jungle tiles do. Communication first, realism "a distant second." — [Game Developer: Sexy Tiles: Sidescrollers](https://gamedeveloper.com/art/sexy-tiles-sidescrollers)
- **Lost Crown [dev, via Ubisoft interview]:** the team "used the camera to ensure that the path is super-readable." Procedural tools were used for world building to speed up level-design and level-art iteration. The primary reprint (TechPowerUp) returned 403 during this research, so these come from a search summary only. — [TechPowerUp forum reprint](https://techpowerup.com/forums/posts/5179958) (unfetched)

### Inferences
- Rule: write a one-line "place sentence" for every room ("flooded mine shaft with a collapsed lift on the right") before blocking it out, and derive the platform positions from the objects in that sentence (lift cage, broken beams, roots) rather than placing platforms in empty space.
- Rule: run a grayscale value check on every room. Collision edges should be the lightest values in their neighborhood, and the background should step darker near those edges. A warm rim on solids works against a cool background.
- Rule: block out as free polygons and play the blockout until it is approved; no art passes before then (Ori). Godot's `CollisionPolygon2D` or `Polygon2D` blockouts suit this better than a strict TileMap.
- Without one-way platforms, every ledge must be reachable from below by a jump, wall-cling or ability. That makes the route visible in the silhouette of the terrain itself.

### Gaps
- No primary source gives Hollow Knight or Silksong tile or unit scale, the Knight's height, or jump height.
- No Nine Sols developer statements on architecture-as-terrain were found. The Digital Trends interview contained none.
- No developer source on silhouette rules for foreground, midground and background layers in HK, Ori or Nine Sols.

---

## 3. Entrances and exits: door placement, telegraphing, camera framing, transitions, avoiding dead-end frustration

### Takeaway
Super Metroid shows the most documented room-level techniques. It uses impassable-looking walls to turn the player around, differently colored doors to steer choice, conspicuous blocks and off-screen ceilings to hint at hidden exits, and locked doors that open only after a teaching event. Lost Crown and Blasphemous add modern techniques: Memory Shard screenshot pins for blocked exits (25 per save), a deliberately safer-looking route patched in after playtests, and z-axis doors that never lead to a new district.

### Cited Findings
- **Super Metroid [analysis, Hugo Bille]:** in Crateria, an unbreakable-looking wall to the right turns the player around ("Turn around. Turn left."). In a pirate-filled shaft, one door needs missiles and the other doesn't, and players take the open one toward the statue room. The Speed Booster room's doors lower as you approach, so the first lets you through and the second forces a fast escape. The statue-room door stays locked until the boss-statue sequence plays. The Brinstar map room reveals Kraid's lair in the east. A short lower-Brinstar corridor is labeled "Maridia" on the map, which seeds curiosity. — [Game Developer: The Invisible Hand of Super Metroid](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)
- **Super Metroid one-way drop [analysis]:** a one-way drop through a lower-Brinstar shaft guarded by invincible flying bugs closes off the upper world and focuses the player on the lower map. — [Invisible Hand of Super Metroid](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)
- **Super Metroid scrolling [ROM-hacking docs]:** each room authors which screens the camera may scroll into (scroll data), which lets designers hide parts of a room until an event or position is reached. — [SMMM](https://metroidconstruction.com/SMMM/); [SMILE FAQ](https://forum.metroidconstruction.com/index.php/topic,300.0.html)
- **Blasphemous [dev, Colinet]:** doors on the z-axis (into the background) never lead to a new district unless they are a portal. The first real branch, after Wasteland of the Buried Churches, has three exits, two of them valid: one to the harder Where Olive Trees Wither, one to the easier Mercy Dreams. Players took the harder route first, so a patch added a safer-looking stepladder down toward Mercy Dreams. — [Game Developer (Blasphemous)](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Lost Crown [dev, Rémi Boutin, senior game designer]:** "The principle of taking mental notes is a key element of Metroidvania games... If you take a break or if you have to take too many mental notes, you forget what you were trying to achieve." Memory Shards pin a screenshot to the map. There are 25 per save, and the limit "pushes the player to 'clean' their Memory Shards and keep a readable map." — [Digital Trends: Memory Shards development](https://www.digitaltrends.com/gaming/prince-of-persia-the-lost-crown-memory-shards-development/)
- **Lost Crown [dev, Microsoft developer article]:** designers placed Memory Shard chests near locked paths to remind players of the feature, and used playtests to space map objectives so they were not confusing. — [Microsoft Game Dev: Lost Crown accessibility](https://developer.microsoft.com/en-us/games/articles/2025/03/prince-of-persia-the-lost-crown-accessibility/)
- **Lost Crown [dev, Radi]:** "inaccessible routes often appearing as landmarks to stimulate his memory"; "although you have many open roads, they close fairly quickly or bounce back to the main path." — [GameRant](https://gamerant.com/prince-persia-lostcrown-metroidvania-gameplay-interview/)
- **Silksong [dev, Gibson]:** "with our players, you can guide them a little bit, and that's enough." Moss Grotto was added in front of The Marrow as a softer opening, but deliberately not as a standalone tutorial. — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/); [GamesRadar on Moss Grotto](https://www.gamesradar.com/games/action/silksongs-first-area-was-only-added-after-team-cherry-realized-it-needed-a-softer-intro-were-trying-to-be-kind-of-respectful-to-the-player-were-not-trying-to-baby-them/)
- **Metroid Dread camera [fan/artist observation]:** the camera is normally locked to authored framing. — [Digital Frontiers (ArtStation)](https://digitalfrontiers.artstation.com/projects/oblGlW)

### Inferences
- Rules from the Super Metroid examples:
  - The first exit a player sees should be the intended one; make the alternatives visibly costlier (a different door color or a blocked look).
  - Lock a teaching room until the lesson is done, so players cannot leave without it.
  - Make one-way drops obviously one-way (hazards above, smooth walls) so they read as commitments, not traps.
- Rule (Blasphemous): if playtesters keep choosing the harder branch, add an affordance to the easier one, such as a ladder or a lit doorway. Do not block the harder branch.
- Every blocked exit should be screenshot-worthy, meaning distinct enough to pin. If a player could not describe it in five words, it will be forgotten (Lost Crown's premise).
- Godot implementation: per-room `Camera2D` limits plus exit trigger zones placed 1 tile inside the door, so the exit is framed on screen before the cut.

### Gaps
- No primary source on cut versus seamless transitions (HK's fade cuts, Ori's seamless streaming, Dread's door loads) or on transition timing in milliseconds.
- No developer guidance found on door height or offset conventions (for example, doors at floor level only, or exits kept a set number of tiles from room corners).

---

## 4. Shortcut folding in detail: one-way doors, breakable walls, levers, elevators, drop-downs; how many and where

### Takeaway
The best-documented count rule is Blasphemous: save altars at most 7 screens apart, and a shortcut beside every boss. Blasphemous also gives a warning: one-use levers were "overused" and cluttered the screen, so many were replaced with breakable glass cases. Hollow Knight-level counts per region are not published.

### Cited Findings
- **Blasphemous [dev, Colinet]:** levers were the first shortcut mechanic but were "overused" in production. They were one-use and cluttered the screen. Many were replaced with breakable glass cases smashed with the sword. Reusable teleports and elevators link distant districts to avoid long detours. Layout was planned on a whiteboard, then with recycled post-it notes, then in Photoshop specifically to plan shortcuts. — [Game Developer (Blasphemous)](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Blasphemous boss-to-shortcut adjacency [dev]:** after a boss, players should "go straight to wherever they want to be." — [same](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Metroid Dread [dev, Jacobo Luengo, former MercurySteam designer]:** a Bomb Block placement in Burenia exists to stop players getting stuck after Ghavoran. Colleagues "did a very conscientious job of detecting unawared situations and preventing softblocks." Shortcut-seeking players are a constant challenge, handled by "covering all the cases you can think of." — [Shinesparkers interview: Jacobo Luengo](https://shinesparkers.net/interviews/jacobo-luengo/)
- **Dread Speed Booster shortcuts [analysis/reviews]:** Speed Booster and Shinespark are rarely needed on the critical path, but mastering them opens shortcuts and hidden upgrades. One Dairon room puts a +10 Missile tank at the top behind a Speed Booster puzzle. — [TV Tropes: Metroid Dread](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/MetroidDread); [CBR](https://www.cbr.com/nintendo-key-metroid-dread-mechanic-prime-4/); [Shinesparkers review](https://shinesparkers.net/features/shinesparkers-reviews-metroid-dread/)
- **Ori [dev, Mahler]:** "every inch of our levels gets scrutinized all the time by many different people" for gating. Two expert Ori speedrunners were hired to find sequence breaks. — [Game Developer Q&A (Ori WotW)](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- **Lost Crown [dev, Radi]:** open side roads "close fairly quickly or bounce back to the main path." — [GameRant](https://gamerant.com/prince-persia-lostcrown-metroidvania-gameplay-interview/)

### Inferences
- Pitfall (Blasphemous): if every shortcut is a lever, shortcuts become visual noise. Vary the opening verbs (break, drop, ride, kick down a ladder) and make the shortcut device part of the room's "place sentence."
- Rule: every boss room and every save room should be within one shortcut of a hub or of the previous save. Audit this by graph distance after each region blockout.
- Rule (Dread): for every one-way shortcut, test the state "player arrived early with fewer abilities" and add a soft-lock breaker, such as a breakable block, where needed.
- From general genre knowledge (recall, unsourced - verify): HK's Forgotten Crossroads to Greenpath, City of Tears elevators, the Crossroads stag station, and one-way gates opened from the far side follow a "shortcut back to the bench" pattern similar to Dark Souls.

### Gaps
- No primary source counts shortcuts per region for Hollow Knight, Silksong or Nine Sols.
- No Nine Sols developer statements on shortcuts or the Four Seasons Pavilion hub were found.
- The Boss Keys Hollow Knight transcript (amara.org) was blocked (403), so Mark Brown's analysis of HK's shortcut network is not included.

---

## 5. Re-contextualized geometry and friction-to-flow: concrete rooms and planning for both movesets

### Takeaway
The documented concrete examples are mostly Super Metroid and Lost Crown. Super Metroid links each new tool to a known hazard (Ice Beam freezes a flier into a platform over lava; the Grapple tutorial room points to a Crateria room that needs grapple). Lost Crown puts a "learning workshop" room after each ability that revisits earlier blockers. Moon and MercurySteam say they keep both movesets working through constant scrutiny and speedrunner testing, not through a published method.

### Cited Findings
- **Super Metroid [analysis]:**
  - After the Ice Beam, a flying enemy from the "shaft of no return" can be frozen and used as a platform over lava, which ties the new tool to a hazard the player already knows.
  - Two Grapple tutorial rooms are followed by a Crateria room that needs the technique, which plants the location in memory.
  - A spiky corridor blocks progress until Grapple, which makes the player return later for X-Ray.
  — [Invisible Hand of Super Metroid](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)
- **Lost Crown [dev, Radi]:** after each ability, a "learning workshop highlighting blockers similar to those he met previously." — [GameRant](https://gamerant.com/prince-persia-lostcrown-metroidvania-gameplay-interview/)
- **Dread [analysis]:** ZDR "regularly throws slopes and tight passages at you that hide secrets designed around creative Shinesparking." Dread "goes out of its way to reward sequence breaking." — [Shinesparkers review](https://shinesparkers.net/features/shinesparkers-reviews-metroid-dread/); [Goomba Stomp](https://goombastomp.com/metroid-dread-gameplay-story-analysis-breakdown/)
- **Dread [dev, Luengo]:** some sequence breaks are intentional; the early Kraid fight with bombs "rewards a feat players may have already achieved." — [Shinesparkers interview](https://shinesparkers.net/interviews/jacobo-luengo/)
- **Dread [dev, Luengo]:** Scan Pulse was "so useful for exploration, which makes it very tempting to use constantly," so it was moved later and changed rather than limited by Aeion cost, which would have discouraged other Aeion use. Lesson: move an exploration-trivializing tool later in the order instead of taxing it. — [Shinesparkers interview](https://shinesparkers.net/interviews/jacobo-luengo/)
- **Dread [dev, Sakamoto]:** Sakamoto wrote out what makes Metroid work and showed it to each level designer. Gameplay and level design were "crafted in such a way that players have everything to help Samus outmaneuver her enemies." — [Nintendo Life: Dread producer hopes it inspires Metroidvania devs](https://www.nintendolife.com/news/2022/01/metroid-dread-producer-hopes-it-showcased-potential-and-inspires-metroidvania-devs); [Nintendo Everything](https://nintendoeverything.com/metroid-dread-difficulty-explaind-yoshio-sakamoto)
- **Ori [dev, Mahler]:** physics-driven interactions (bash off projectiles, rigged objects) allow sequence breaks. Gating is "scrutinized all the time"; two speedrunners were hired. — [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- **Silksong [dev, Pellen]:** "As the map grew, we're generally not thinking about which power up you are getting next and where." Gibson: "It's a specific kind of lock-and-key type of progression... we try to submerge that element in favour of a more naturalistic world." — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/); see also [GamesRadar: choice not dictated by power-ups](https://www.gamesradar.com/games/action/hollow-knight-devs-highlight-a-big-difference-between-their-sequel-and-most-metroidvanias-the-players-choice-about-where-to-go-in-silksong-is-not-dictated-by-what-power-ups-you-currently-have/)
- **Blasphemous II [dev]:** controlling which areas open depending on the weapon chosen took trial and error with level designers, "a very hard thing to do in a Metroidvania." — [Game Developer: Making big swings in Blasphemous II](https://www.gamedeveloper.com/design/making-huge-genre-specific-swings-in-blasphemous-ii)

### Inferences
- Rule: design each traversal ability as "new verb plus an old hazard" (Ice Beam on a lava flier). Place the first use within sight of a blocker the player has already seen.
- Rule (Silksong): hide locks inside natural geometry (a high ledge, a current) rather than colored doors, so the room reads as a place and not a puzzle box.
- Rule: keep a "both movesets" checklist per room: (a) the early route works, (b) the late route is faster or reveals something, and (c) no early-arrival soft-lock.
- From general knowledge (recall, unsourced - verify): Ori's Bash turns enemy projectiles and lanterns into traversal nodes; HK's Crystal Dash turns long horizontal Crystal Peak and Kingdom's Edge rooms into one-dash crossings; Dread's Speed Booster turns long corridors into Shinespark-charging runways.

### Gaps
- No developer-sourced, room-specific Ori Bash, HK Crystal Dash or Dread Speed Booster room breakdowns were found.
- No published method (spreadsheet or matrix) from any studio for checking rooms against both early and late movesets.

---

## 6. Secrets and rewards: hinting, frequency, contents

### Takeaway
Team Cherry's principle is that any breakable wall could hide anything, from a grub to a whole area with a boss, which gives the player a reason to hunt. Animal Well's Basso argues a true secret must break the pattern the game itself has set up. Super Metroid's classic tell is conspicuous blocks, a disconnected floor, or ceiling geometry seen beyond the screen.

### Cited Findings
- **Hollow Knight [dev, Pellen]:** the team made sure "that there was stuff in the world that people had the feeling that if they did find a breakable wall or whatever, or hunt down a secret, there could be anything behind it... Or it could be a whole new area with its own boss." "It's easy to underestimate how good people are at finding stuff." "I don't think we overhid or underhid anything." — [Kotaku](https://kotaku.com/the-makers-of-hollow-knight-are-fine-with-players-missi-1828721254)
- **Hollow Knight [dev, Gibson]:** "We didn't build something [where] we expect people to see everything as they go through"; missing things "makes it more special for that person." — [Kotaku](https://kotaku.com/the-makers-of-hollow-knight-are-fine-with-players-missi-1828721254)
- **Super Metroid Charge Beam corridor [analysis]:** two conspicuous blocks, a disconnected floor, and a glimpse of a ceiling beyond the screen edge draw the player to blast the right spot. — [Invisible Hand of Super Metroid](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)
- **Animal Well [dev, Basso]:**
  - "No matter what you put in a game, it will get found."
  - "The harder it's buried, the more interesting it is."
  - A secret "needs to break from the pattern that even the current game you're playing established."
  - On Metroid-style signposting: "they wouldn't be secrets then."
  - "I avoided almost all the existing tropes that I was aware of in Metroidvanias."
  — [Nintendo Life: Peeling back the layers of Animal Well](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **Animal Well [dev, Basso]:** "a game about secrets and holding back information." He builds item-centered puzzle sections that "can be played in isolation" and then lets the rest of the map "grow roots on it." Each new room or item takes "five or six iterations" of playthroughs. — [Game Developer (Animal Well)](https://www.gamedeveloper.com/programming/the-scratch-coding-and-discipline-at-the-heart-of-animal-well); [PC Gamer](https://www.pcgamer.com/games/action/animal-wells-solo-dev-casually-reveals-that-the-breakout-metroidvania-left-at-least-twice-as-many-rooms-that-are-in-the-game-on-the-cutting-room-floor/)
- **Lost Crown [dev, Radi]:** "getting lost is each time the promise of a new adventure or a significant reward"; players sink "into optional areas full of surprise." — [GameRant](https://gamerant.com/prince-persia-lostcrown-metroidvania-gameplay-interview/)
- **Dread [analysis]:** secrets in ZDR are hidden behind slopes and tight passages that need creative Shinesparking. — [Shinesparkers review](https://shinesparkers.net/features/shinesparkers-reviews-metroid-dread/)

### Inferences
- Use a tiered tell system:
  - Tier 1, readable tells: a cracked texture or a geometry gap that runs off-screen. Holds small rewards.
  - Tier 2, "something's off" tells: a room whose map shape does not match its interior, or a wall thicker than its neighbors. Holds mid rewards.
  - Tier 3, pattern-breakers (Basso): secrets that violate a rule the game itself taught. Hold the big rewards.
- Rule (Pellen): make sure at least a few breakable walls lead to something large (an area, a boss), so every breakable wall feels like it could.
- Rule (Super Metroid): hint off-screen geometry by showing a sliver of it, such as a ceiling or floor edge peeking past the camera bounds.

### Gaps
- No source gives secret frequency (for example, secrets per room or per region) for any listed game.
- No source documents HK's actual visual tell for breakable walls (texture difference, sound cue). It is commonly cited but unsourced here.

---

## 7. Environmental storytelling and landmarks

### Takeaway
Silksong is built around one dominant landmark, the Citadel "at the top of the world", whose architecture spreads to outposts and whose resource extraction scars nearby areas. Its rooms therefore tell the same political story through borrowed or damaged architecture. Lost Crown deliberately makes inaccessible routes into landmarks, and Super Metroid uses the map room to show a landmark before the player reaches it.

### Cited Findings
- **Silksong [dev, Pellen]:** "We're thinking about the Citadel at the top of the world, and what's around it." [ACMI narration]: outposts copy the Citadel's ornate architecture, and areas damaged by extraction show the cost of its power. Moss Grotto's existence then "suggested" the mosslands outside the Citadel's influence. — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/)
- **Silksong [dev, Gibson]:** "we establish the foundations, and as those become clearer, the world suggests what else is going to exist... Then we just get to follow all those little ideas to their conclusion." — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/)
- **Hollow Knight [dev, Gibson]:** "all of it's built around this sense of discovery. Exploration and discovery." — [Game Developer (HK map)](https://gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-)
- **Lost Crown [dev, Radi]:** "inaccessible routes often appearing as landmarks to stimulate his memory." — [GameRant](https://gamerant.com/prince-persia-lostcrown-metroidvania-gameplay-interview/)
- **Lost Crown [review]:** each area uses distinct color palettes and lighting to stay recognizable. — [Checkpoint Gaming review](https://checkpointgaming.net/reviews/2024/01/prince-of-persia-the-lost-crown-review-a-crowning-achievement/)
- **Super Metroid [analysis]:** a statue room with boss depictions previews the endgame. The Brinstar map room exposes Kraid's lair as a far-east landmark. — [Invisible Hand of Super Metroid](https://gamedeveloper.com/design/the-invisible-hand-of-super-metroid)
- **Animal Well [dev, Basso]:** museums inspired the level design because they are "designed to be viewed in any order." — [Nintendo Life](https://www.nintendolife.com/features/i-avoided-almost-all-the-existing-tropes-peeling-back-the-layers-of-animal-well)
- **Blasphemous [dev]:** the teleport map shows how areas connect abstractly, with vertical position implied by context (mountain areas sit above). Stacking outdoor scenes believably was hard. — [Game Developer (Blasphemous)](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)

### Inferences
- Rule: pick one world-dominant landmark and make its influence visible at room scale in three states: copied architecture (allied areas), damaged or mined architecture (exploited areas), and no trace (outsider areas). Players can then place a room by its architecture alone.
- Rule: make every blocked route a landmark (a distinct prop, light color or sound) so it is remembered without map markers.
- Pitfall (Blasphemous): outdoor scenes are hard to stack vertically in a believable way. Put vertical stacking in interiors, caves and towers, and keep outdoor areas mostly horizontal.

### Gaps
- No Nine Sols, Ender Lilies or Aeterna Noctis developer statements on environmental storytelling at room scale were found.
- No source quantifies landmark density (for example, one landmark per N rooms).

---

## 8. Combat-space design: arena shapes, ceiling heights, platforms in arenas, enemy placement relative to hazards

### Takeaway
This is the thinnest area for primary sources. The only usable developer statements are Ori's "start with the solids" test (combat must be fun on gray boxes) and Dread's design intent that level design always gives Samus room to outmaneuver enemies. No studio was found publishing arena dimensions or ceiling-height rules.

### Cited Findings
- **Ori [dev, Korol]:** "always starts with the solids": enemies that aren't fun while you jump around boxes won't be fun later. Combat and space are judged on blockout geometry first. — [MCV](https://www.mcvuk.com/development-news/unity-focus-making-ori-and-the-blind-forest/)
- **Dread [dev, Sakamoto]:** gameplay and level design were "crafted in such a way that players have everything to help Samus outmaneuver her enemies." Nintendo and MercurySteam had many fresh testers check the difficulty. — [Nintendo Life](https://www.nintendolife.com/news/2022/01/metroid-dread-producer-hopes-it-showcased-potential-and-inspires-metroidvania-devs); [Nintendo Wire](https://nintendowire.com/news/2022/01/24/metroid-dread-producer-discusses-the-games-difficulty-and-why-the-e-m-m-i-encounters-were-so-unforgiving/)
- **Dread E.M.M.I. zones [dev, Luengo]:** "level design constraints" shaped the final E.M.M.I. design, and the enemy is "always there" (simulated off-screen too). [critical review]: E.M.M.I.-zone level design was said to "severely block" the game's potential. — [Shinesparkers interview](https://shinesparkers.net/interviews/jacobo-luengo/); [Metroid Database review](https://metroiddatabase.com/reviews/metroid-dread-review/)
- **Blasphemous [dev, Colinet]:** art drives level design and level design drives enemies, in an iterative loop. — [Game Developer (Blasphemous)](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- **Nine Sols [reviews]:** GamesRadar praised the level design but wanted more guidance through the world. Aggregated Steam reviews call the level design "too linear for a Metroidvania." — [GamesRadar review](https://gamesradar.com/games/action/nine-sols-review); [Vaporlens](https://vaporlens.app/app/1809540/nine_sols.md)
- Nine Sols' gameplay inspirations were Sekiro, Hollow Knight and Katana Zero (writer's description). — [Digital Trends](https://digitaltrends.com/gaming/nine-sols-taopunk-developer-interview)

### Inferences
- Rule: grey-box test every combat room with final enemy AI before any art (Ori). If the fight is not fun on boxes, change the geometry, not the art.
- Rule: every arena needs an escape vector, either a platform, wall or ceiling height that allows a jump over the enemy's attack, so the "outmaneuver" promise holds (Dread).
- For parry-centric combat (Nine Sols-like), keep enemy encounters on flat, wide floors and keep precision platforming hazards out of parry zones. A parry timing failure should cost health, not a fall into spikes. This is design reasoning, not a sourced Red Candle statement.
- (recall, unsourced - verify) Hollow Knight's lockdown arenas (Colosseum, Mantis Lords, and roaming "ambush" rooms that seal) are typically single-screen-wide boxes with a flat floor and optional ledges.

### Gaps
- No primary source gives arena widths, ceiling heights, or rules for platforms in arenas for any listed game.
- No Red Candle (Nine Sols), Live Wire/Adglobe (Ender Lilies) or Aeternum Game Studios (Aeterna Noctis) level-design interview was found.
- No Blasphemous source on enemy placement relative to spikes and pits, although the game is known for knockback into pits.

---

## 9. Grid and tile metrics: tile sizes, character-to-tile ratios, jump-height-to-room numbers

### Takeaway
Only Super Metroid has hard published numbers: 16x16-px blocks, 256x256-px screens of 16x16 blocks, and rooms of 1 to 30 screens. The 256x224 visible output resolution is commonly cited but was not confirmed by a fetched source here. Animal Well's 256 rooms on a 16x16 grid is confirmed. Ori is explicitly not grid-based. Hollow Knight's 64-px blockout tile is an unverified fan claim.

### Cited Findings
- **Super Metroid:** blocks are 16x16 px, a screen is 256x256 px (16x16 blocks), and rooms are 1 to 30 screens. Block coordinates count across the whole room, not per screen. — [SMMM](https://metroidconstruction.com/SMMM/); [AAAI paper](https://cdn.aaai.org/ojs/18905/18905-52-22671-1-2-20211004.pdf); [Metroid Construction wiki FAQ](https://wiki.metroidconstruction.com/doku.php?id=sm%3Abasic_guides%3Afaq)
- **NES Metroid [ROM hacker]:** level design is "always 16x16 blocks", and one room view is 256x240 px. The camera follows Samus rather than flipping at screen edges. — [NesDev forum thread](https://nesdev.nes.science/f2/t17736.xhtml); [Metroid Database level data](https://metroiddatabase.com/old_site/m1/lvldata.php)
- **Animal Well:** 256 rooms on a 16x16 grid with one-byte room IDs. Built in a custom in-game editor ("like Super Mario Maker") using Photoshop-style paint bucket and eyedropper tools. — [Game Developer (Animal Well)](https://www.gamedeveloper.com/programming/the-scratch-coding-and-discipline-at-the-heart-of-animal-well)
- **Ori:** the world is "not grid-based", and platforms are hand-drawn polygons. — [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)
- **Hollow Knight [fan/unverified]:** 64x64-px blockout tiles with hand-placed HD art on top. A modding sample scene uses 30x17 cells. — [itch.io comment](https://maaot.itch.io/mossy-cavern/comments?after=0); [HK Modding API docs](https://radiance.synthagen.net/apidocs/_images/NewScene.html)
- **Hollow Knight [dev, Pellen]:** no mathematical rules such as set tile counts for rooms; "It was mainly intuition." — [Game Developer (HK map)](https://gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-)
- **Tile art convention [Saltsman]:** 16x16-px tiles as the simpler mental model. The GBA built 16x16 metatiles from flipped 8x8 tiles. — [Sexy Tiles](https://gamedeveloper.com/art/sexy-tiles-sidescrollers)

### Inferences
- A screen of 16x16 blocks (Super Metroid) is a proven room-authoring unit. In Godot, a "screen" can be defined as N x M tiles matching the viewport (for 1920x1080 at 64-px tiles, 30x16.875, which explains the fan-reported 30x17), and room sizes authored in whole screens.
- A Samus-height of about 3 blocks (48 px) and a standard jump clearing several blocks are commonly cited (recall, unsourced - verify). These should be measured from the project's own controller rather than borrowed.
- Rule: derive every room metric from the movement controller's measured numbers (jump apex height, max horizontal jump distance, dash length) and keep a "metrics room" in the project that is rebuilt whenever movement is tuned.

### Gaps
- No fetched primary source confirms Super Metroid's 256x224 output resolution, Samus's hitbox size in blocks, or jump height in blocks. A ROM hacking reference such as the Metroid Construction wiki or the Super Metroid disassembly would settle these.
- No published metrics were found for Hollow Knight or Silksong (unit scale, Knight height, jump height), Nine Sols, Dread (rooms or tiles), Lost Crown, Ender Lilies or Aeterna Noctis.
- Datamined values (for example, HK via AssetRipper and collider inspection) are possible but were not done here.
