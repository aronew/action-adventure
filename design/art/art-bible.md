# Art Bible: Guardbreak *(working title)*

> **Status**: Draft (sections 1-4 in progress, `/art-bible`, lean, standard)
> **Owned By**: art-director
> **Last Updated**: 2026-11-20
> **Art Director Sign-Off (AD-ART-BIBLE)**: [Not yet reviewed]

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
Ambient light comes from below, warm and soft (region 1 visual direction). The sword arcs and the guard-break sparks are the brightest moments on screen; embers and glows stay dimmer and slower (parallax rules 11, 13). The four reserved hues, orange (dash), copper-green (wall cling), chalk-yellow (double jump) and violet (grapple), mark ability gates and nothing else.
*Test: when an ambient effect and a combat effect compete for the eye, the sword arc and the guard break win.*

**Tagline (not a rule):** *the one pale, crisp thing in a warm, painted dark.*

## 2. Mood & Atmosphere

[To be designed] — for each major game state (exploration, combat, victory,
defeat, menus — whichever this game has): the emotional target, lighting
character (time of day, colour temperature, contrast), 3–5 atmospheric
descriptors, and energy level. Each state must look distinct from the others.

## 3. Shape Language

[To be designed] — character silhouette philosophy (readable at thumbnail
size, one distinguishing trait per archetype), environment geometry, UI shape
grammar, and hero versus supporting shapes.

## 4. Color System

[To be designed] — a primary palette of 5–7 colours with their meaning in this
world, semantic colour usage, per-area colour temperature rules, the UI palette
and where it diverges, and colourblind safety: which semantic colours need a
shape, icon or sound backup.

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
