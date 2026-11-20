# Art Bible: Guardbreak *(working title)*

> **Status**: Draft. Sections 1-4 written 2026-11-20 (`/art-bible`, lean, standard: the required minimum); sections 5-9 not yet authored
> **Owned By**: art-director
> **Last Updated**: 2026-11-20
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-11-20 — lean mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

**The rule:** *Hard edges and light values mark what you can touch or hurt; soft edges and dark values mark what you can't.* **[Owner, 2026-11-20]**

This is how a pixel-art cast lives in a painted world without the mix looking accidental. The things a player acts on sit in a sharp, high-contrast tier: the Seeker and enemies as crisp pixel art, and the play layer's floor edges as a bright painted lip against black fill. Fog, blur and the parallax layers sit in a soft, dark tier. A player reads "act on this" and "look at this" without being taught. The game brief's look line ("2D pixel side view") predates the owner's choice of painted environments (2026-11-18); read it as *pixel cast, painted world*.

Anchored in the brief's pitch ("a hand-animated side-scrolling metroidvania where one move set breaks enemy guards in duels and carries you through a hand-built, ability-gated world") and its audience ("players of tight 2D action who want animation-heavy duels and a connected world"); the brief has no pillars.

**Principle 1: Crisp means contact.** *Serves: "tight 2D action", "animation-heavy duels".*
The Seeker, enemies and hit FX are pixel art at a whole-number scale (4x) with nearest filtering. The play layer's floor edges are painted and smooth-filtered (terrain pipeline, Visual/Audio: filtering), so their hardness comes from value and contrast, a bright lip against black fill, not from pixels. Everything else is soft: blurred, fogged, lower in contrast.
*Test: when it is unclear whether something should be sharp or soft, ask whether it can hold, hurt or be struck. If yes, it is crisp or hard-edged; if no, it is soft.*

**Principle 2: The greyscale order is fixed.** *Serves: "tight 2D action", "a connected world".*
Brightness runs, from lightest: the Seeker, then enemies, then the play layer's floor edges, then the mid layers, then the back layers and the foreground framing, darkest. The order holds in every biome, and that is what makes six differently painted packs read as one world (region 1 visual direction, Palette and light; level design, Readability; parallax P4).
*Test: when two values compete, keep the one that leaves the room readable in greyscale.*

**Principle 3: Combat owns the light.** *Serves: "hand-animated", "animation-heavy duels".*
Ambient light comes from below, warm and soft (region 1 visual direction). The sword arcs and the guard-break sparks are the brightest moments on screen; embers and glows stay dimmer and slower (parallax rules 11, 13). The four key colours, orange (dash), chalk-yellow (double jump), copper-green (wall cling) and violet (grapple), mark a key's gates, its pickup, its icon and its map markers; a gate is known first by blocking the way and by its reserved shape (Sections 3, 4).
*Test: when an ambient effect and a combat effect compete for the eye, the sword arc and the guard break win.*

**Tagline (not a rule):** *the one pale, crisp thing in a warm, painted dark.*

## 2. Mood & Atmosphere

**Light direction underground.** There is no sun and no time of day. Direction is where the warm source sits, and it is always below: the ambient gradient is cooler and darker at the top and warmer at the bottom (parallax, rule 12; region 1 visual direction, "light comes from below"). A game state changes how far that warmth reaches and how tightly the Seeker's own light holds; no state flips the direction, because that would break Principle 3. A biome changes the hue of the light from below, never its position (Section 4). Every state below is the tagline, *the one pale, crisp thing in a warm, painted dark*, with one or two of those dials moved.

| State | Emotional target | Lighting character | What carries the mood | Descriptors | Energy |
|---|---|---|---|---|---|
| Exploration | Wary curiosity: a small figure at the edge of something vast and patient, drawn to the next unseen edge | Low contrast, warm from below, cooler and darker toward the top; all atmosphere on | Kiln windows and firebox glows low on the mid layer, embers rising past them | hushed, vast, lived-in, patient, warm-dark | 2/5 |
| Ordinary combat (health-only enemies) | Brisk, clean competence: each hit lands and the room answers | The room's light is unchanged on purpose (Principle 3): only the Seeker's soft light and the sword arcs rise | The sword arc; crazing on a glazed foe, grit shed by an unglazed one | snappy, percussive, crisp, clipped | 3/5 |
| Guarded duel (bosses, mini-bosses, the tutorial foe) | A held-breath standoff: two fighters measuring each other, then release at the shatter | The highest contrast of any state: on engagement the ambient dims by about 0.10 and the vignette tightens over about 1 s; both ease back at the finisher. The warmth from below stays **[Owner, 2026-11-20]** | The guard-break shatter against the foe's silhouette (Brun's block) in a dimmed room | tense, sparse, ritual, heavy, focused | 4/5, peaking at the shatter |
| Resting at a save point | Relief: the one exhale, healed and held, with no text, so the image carries it alone | The warmest, steadiest light in the game; nothing flickers. It is the save points GDD's rest moment, inside `rest_hold_time` (1.0 s), not a separate effect | Ash settles, the Seeker's pale shade warms a half-step, the nearest glazed figure's highlight slowly dims (save points, Visual/Audio) | still, tender, warm, quiet | 1/5 |
| Death and respawn | Loss without scorn: the warmth leaves, then comes back, quickly | Saturation and split tone drain toward grey-mauve and the vignette closes on the Seeker, whose own light goes out last; respawn fades up warm. It plays inside the existing death clip and fade and adds no time (`death_hold_time` 0: death costs only the walk back) **[Owner, 2026-11-20]** | Colour leaving the room, which rhymes with region 1's remembered image of the glow leaving the trays | hollow, hushed, brief, reset | falls from 3 to 0, returns at 1 |
| Room transition | Neutral punctuation, not an event | A plain fade to dark and back (about 0.45 s, rooms and transitions R3) with no hue shift, vignette or desaturation, so it is never mistaken for death or rest; the next room's ambient and embers are already there on the fade-up (parallax, rule 15) | The fade itself | neutral, quick, clean | momentary |
| Map, pause and menus | Calm clarity: stepping out of the world to think | Ungraded and flat: no gradient, vignette, bloom or direction, the only state without a light direction. On pause the frozen world sits under a dark scrim | Crisp UI lines in Bone Pale on Void Black (Sections 3, 4) | flat, clear, orderly, quiet | 1/5, still |
| Dream Seeker (later; out of the core build) | Lucid, weightless, uncanny: the Seeker becomes the light | Cool, iridescent and translucent; the Seeker is the brightest source in the room and the warmth from below recedes | Translucency and scan structure rather than saturation (Section 4) | lucid, weightless, uncanny, cold | 4/5 |

**Why each state reads as its own.** Around the exploration baseline, the ambient steps down in a duel and holds warm at rest. Death is the only state that drains hue. A transition changes brightness only, with no hue and no vignette. Menus are the only state with no grade. Every ambient change is a one-way, eased move over at least 0.5 s, far inside the flicker limit (amplitude 0.2, three changes a second; parallax, Edge Cases), so no state change reads as a flash. Each carrier still reads with the atmosphere set to Reduced (parallax, rule 14): the duel's shatter reads through its shards and shapes, not through bloom.

**Owed by other documents.** The duel dim and the death drain need the parallax grade to take a state input (today it has none, parallax rule 12); the death drain must fit inside the save points GDD's death clip and fade (its F2, `death_to_control`).

## 3. Shape Language

Shape does the same sorting job as value in Section 1: angular, planar and straight means solid and actionable; curved, ragged, blurred and large means scenery. Shape is also the colourblind-safe channel, so it carries the weight wherever Section 4's hues cannot.

**Shape 1: the hero is small and upright.** *Serves: "tight 2D action".* The Seeker is the only small, upright, point-topped figure (the hood) in a world of heavy horizontals, so the eye finds it by scale and orientation before value. It reads as vulnerable but exact, which suits a game about precise timing (region 1 visual direction, Silhouettes: "small, hooded, upright").

**Shape 2: one trait per archetype, readable as a black fill at thumbnail size.** *Serves: "animation-heavy duels".* The test: fill a sprite solid black, shrink it to a thumbnail and name the archetype. Every attack telegraph also changes the silhouette, not only adds FX, because duels are read through animation.

| Archetype | Single distinguishing trait | What it says |
|---|---|---|
| Seeker | Small, upright, hood point | One person standing their ground |
| Glazed enemies | Bilateral symmetry plus the 1 px white highlight line | Formal, brittle, made to a pattern |
| Unglazed enemies | Lopsided, chipped, always shedding grit | Worn, hurt, unmade |
| Tavik (mini-boss) | Tall, narrow, leaning forward, a flat tray held out | Servile pursuit, leaning into you |
| Brun (boss) | Wide square block, a tall column on his back | Immovable: a wall that fights |

Symmetry against lopsidedness sorts glazed from unglazed before hue does (region 1 visual direction, Glazed vs unglazed).

**Shape 3: angles are ground, curves are distance.** *Serves: "a connected world".* The play layer is hewn and planar: right angles, flat tops, the bright cobbled lip. The mid layers carry the big curves (kiln domes, arches), and the back layers soft verticals (the chimney skyline). Nothing curved is walkable, and no bright horizontal lip appears anywhere off the play layer (parallax, rule 13; level design, Readability). The architecture feels stern near the player and grand far away.

**Foreground foliage never reads as ground.** The shared silhouette foliage and the collision fill are both true black **[Owner, 2026-11-20: keep true black]**. They are told apart by depth and shape, not value:

| Cue | Collision fill | Foreground foliage |
|---|---|---|
| Depth | On the play layer, with the lighter middle-foreground rim on its edges | Nearest the camera, drawn in front of a lighter middle-foreground layer so it pops against it, as in `art_style_test_room.tscn` **[Owner]** |
| Edge | Planar, with a bright lip | Ragged, pointed, hanging; never a lip, and no straight horizontal run over about 24 px (Rec, tunable) |
| Gaps | Solid mass | The scene shows through |
| Motion | Moves with the world | Moves faster than the world (foreground factor 1.2, parallax rule 7) |

The middle-foreground layers and the foliage will be built out and reiterated as the art matures **[Owner]**; whatever changes, the foliage keeps a lighter layer behind it.

**Key signatures are reserved shapes.** *Serves: "an ability-gated world".* Ability gating rule 10's candidates are fixed here, and no other object, prop or UI element may use these shapes:

| Key | Reserved shape and material |
|---|---|
| Dash | A thin, pale bisque pane, and bisque gap lips |
| Wall cling | Parallel vertical finger-drag grooves |
| Double jump | A horizontal kiln shelf on thin stilts |
| Grapple | An iron ring with a cord; no other circle exists on the play layer or in the UI |

**Which walls grip, and the `no_cling` face (ability gating rules 11, 14).** Once the wall cling is owned, any plain wall can be clung to, as in Hollow Knight; the copper-green grooves mark only the wall-cling gate walls and `climbable` surfaces (ability gating rule 11) **[Owner, 2026-11-20: any plain wall]**. The rare face the Seeker cannot cling to, even with the wall cling, carries hard-edged **horizontal bands of slick glaze** with a cold, hue-less highlight **[Owner, 2026-11-20]**. Vertical lines mean grip (the cling grooves) and horizontal bands mean none, so direction carries the message without colour, which keeps it colourblind-safe, and it is never copper-green (rule 14). It replaces the thorn-vine candidate, whose Mossy Cavern pack is not among the six biome packs. With the key order the owner set on 2026-11-20 (double jump before wall cling, see Section 4), few `no_cling` faces are needed.

**UI shape grammar.** UI is rectilinear with 45-degree chamfers, never rounded: cut tile, hard-edged like everything actionable. Meters are segmented bars, and the guard meter's cells are the same shape that shatters. Selection is a bracket, not a hue. Circles stay reserved for the grapple, in the UI as in the world.

**Hero versus supporting.** Hero shapes (the Seeker, foe silhouettes, floor lips, key signatures) get the sharpest angles and the strongest contrast. Supporting shapes (back layers, foliage, haze) get the softest edges and the least contrast.

## 4. Color System

**The grade delivers the greyscale order, with art that is dark enough.** Raw, the Cinderheart far layer's brightest colour (#AE5E59, luma 0.46) is brighter than the Seeker's body (#796167, 0.41), so the order of Section 1's Principle 2 holds only after fog and the screen grade: on the graded reference frame the back measures about 0.34, the floor edges 0.49-0.70 and the Seeker 0.53-0.61 (parallax, P4; a warning at a margin of 0.10, judged by eye). New art keeps far layers at a raw luma of 0.46 or less and mid layers at 0.41 or less, and is judged on a graded frame, never trusting the grade to rescue a pack that is too bright. The owner's outlined biome sets already meet the order raw: their floor lips reach about 0.45 against backgrounds of 0.08-0.20 (measured 2026-11-20). Luma is 0.299 R + 0.587 G + 0.114 B throughout.

**Primary palette** (region 1, Cinderheart Caldera; authoring targets taken from the measured art):

| Name | Hex (luma) | Role in this world |
|---|---|---|
| Void Black | #050001 (0.01) | Collision fill and outlines: solid, unseen |
| Soot Umber | #31262A (0.16) | Ground and the mid layers |
| Ash Aubergine | #5E424B (0.30) | Back layers and the cooler top of the ambient gradient |
| Furnace Burgundy | #885256 (0.39) | The pack's body red |
| Kiln Amber | #A8703C (0.48) | The light from below; never above mid value (region 1 visual direction) |
| Bone Pale | #B59D91 (0.64) | The Seeker's lit tone; UI body text |
| Flash White | #F6EBDD (0.93) | The Seeker's sword arcs and the guard-break spark |

**What colour means.** In a world lit burgundy and amber, red cannot mean danger, so meaning is carried by temperature and brightness:

| Colour | Means | Why |
|---|---|---|
| Bone Pale and Flash White, warm | You: the Seeker, your arcs, your rest | The lightest warm thing in the dark is the one thing that is you |
| Cool ice-white #CFE0F2 (0.87) | An enemy attack you must dodge, not block | A cool, slightly dimmer flash that stands out against every biome; against your warm arc (0.93) it differs in temperature, brightness and shape. Every other enemy telegraph carries no colour: a wind-up pose that changes the silhouette, a short pause and a sound, as in Hollow Knight **[Owner, 2026-11-20]** |
| Kiln Amber, steady | Safe: the rest pool | Warmth that never flickers |
| Void Black | Solid | The mass you cannot enter |
| Peak brightness | Reward: the guard break, the finisher | Reward is an event of maximum light, not a pickup colour |

**Biomes.** Each biome is one dark base colour and at most one accent light (or none: the owner's grey thorn cave is pure greyscale), with the warmth from below added by the grade's ambient gradient (parallax, rule 12). The floor lip stays the brightest painted thing in every biome. Region 1 uses the Cinderheart Caldera pack as it is, the reference room's look **[Owner, 2026-11-20: "it just looks good right now"; subject to change]**; the region 1 lore's Cooling Yards palette (soot-umber, kiln windows) and the owner's kiln concept image stay a possible later direction. Measured accents in the owner's other sets: peach-orange lanterns and orbs (#C57A55) over navy, a teal glow (hue about 195 degrees) over deep blue-teal.

**Key colours and the key order.** The keys come in this order: dash (region 1), double jump (region 2), wall cling (region 3), grapple (region 4) **[Owner, 2026-11-20; was dash and wall cling in region 1]**. Each key has one colour, shared by its gates, the pickup that grants it, its owned-key icon and its gate markers on the map, so lock and key match **[Owner, 2026-11-20]**:

| Key | Colour | On the gate |
|---|---|---|
| Dash | Orange #FF7A1A | A pale bisque pane or gap lip with a hard orange seam (ability gating rule 10) |
| Double jump | Chalk-yellow #B8AC68 | The kiln shelf on stilts |
| Wall cling | Copper-green #3AA386 | The vertical finger-drag grooves |
| Grapple | Violet #9B66F2 | The iron ring and cord |

A gate is known first by blocking the way and by its reserved shape (Section 3); its colour reminds the player which ability opens it **[Owner, 2026-11-20: "you know it's a gate because you can't clear it"]**. Biome art may therefore use these hues freely (the lantern ruins' orange orbs, a teal or violet haze): no hue is withheld from the environment.

**UI palette.** The UI draws above the grade, ungraded, so its colours show as authored. Panels are Void Black and body text Bone Pale (about 8:1 contrast); Flash White is kept for the one focused item and the guard-break flash. Selection is a bracket and brightness, not a hue (Section 3). Health and guard colours wait for the HUD design, but neither may use a key colour or rely on red against green.

**Colourblind safety.** Hue alone is never the only cue:

| Pair at risk | Backup |
|---|---|
| Dash orange and wall-cling copper-green (red-green) | Shape: a pane or lip against vertical grooves; distinct pickup and map pictograms |
| Dash orange and double-jump chalk-yellow | Shape: a pane against a stilted shelf (their luma is close) |
| Grapple violet and blue glaze or haze | The ring and cord shape |
| Your warm arc and an enemy's cool dodge flash | Brightness (0.93 against 0.87), crescent against wind-up silhouette, timing |

The reference frame is also reviewed through protanopia, deuteranopia and tritanopia filters before a biome's look is signed off.

**Open.** Whether the game's biomes take the six painted packs' look or the owner's outlined sets (grey thorn cave, blue lantern ruins, teal grave garden, all with full tile and terrain sets) is not decided **[Owner, 2026-11-20: subject to change]**. The Seeker plays in the Bone palette, whose low-saturation pinkish greys sit clear of every key colour; the Ember, Frost and Dream Seeker palettes are checked against the key colours when those power-ups are designed.

## 5. Character Design Direction

[To be designed] — the player character's visual archetype, how players tell
enemies, NPCs and allies apart at a glance, expression and pose style, and how
much detail survives at game camera distance (LOD philosophy).

## 6. Environment Design Language

[To be designed] — architectural style and its tie to the world's culture,
texture philosophy (painted, PBR or stylised, and why), prop density rules per
area type, and environmental storytelling guidelines.

## 7. UI/HUD Visual Direction

[To be designed] — diegetic versus screen-space HUD, typography (personality,
weight, size hierarchy, minimum readable size), iconography style, UI animation
feel, and any art-direction versus readability conflict and how it was decided.

## 8. Asset Standards

[To be designed] — file formats, naming convention, texture resolution tiers,
LOD levels, export settings, and the engine's hard limits (poly budgets per
asset category, texture memory, material slots). Where an art preference and a
technical limit disagree, record both and the trade-off chosen.

## 9. Reference Direction

[To be designed] — 3–5 references (games, films, art styles or artists). For
each: the specific element to take from it, and what to avoid so the result
does not read as a copy.
