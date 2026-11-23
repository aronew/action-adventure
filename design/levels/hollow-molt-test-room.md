# The Hollow Molt: test room

Status: art test, 2026-11-23. Scene: `src/world/hollow_molt/rooms/hm01_molt_test.tscn`
(open it in Godot and press F6). It uses Waking Niche's layout so the two biomes can be
compared on the same shapes. It has no exits.

## The art

`assets/environment/hollow-molt/`, from the owner's two packs (the terrain pack and the
biome pack): the gameplay terrain tiles (same 7x7 layout as Cinderheart), the distant
background and midground, ceiling and ground foreground bands (A, B, C), room-edge borders,
props (including the floating platforms), and a darker decorative copy of the terrain
(`middle-foreground/`) meant as near-camera scenery blocks, not used yet. Imported with
mipmaps on, like Cinderheart's.

## Webs

`assets/environment/hollow-molt/foreground/webs/`, the owner's web pack (2026-11-23):
three standalone pieces (ceiling curtain, corner web, hanging shroud), each in black
silhouette and grey-white silk. `RegionRoom._add_webs` hangs them from every ceiling with
at least 5 open cells below it (`WEB_MIN_HEADROOM`; the low tunnels get none):

- a corner web where the ceiling meets a wall, mirrored for a wall on the right;
- curtains and shrouds along the ceiling every 9 cells (`WEB_SPACING`), kept 3 cells
  clear of a corner web, a curtain swapped for a shroud where it wouldn't fit;
- grey silk behind the rock (its attach point tucked behind the ceiling's edge), tinted
  to a mid-grey and a little see-through like the concept art (`WEB_SILK_TINT`);
- beside half of them, a smaller black silhouette in front of the Seeker (the pack's
  README: silhouettes nearest the camera, silk behind).

A web hangs at most 42% of the open height below it (`WEB_DROP_SHARE`), capped per piece
(`WEB_PIECES`). Placement is hashed from the cells, so a room looks the same every visit.
A biome turns webs on with a `"webs"` folder in its `BIOMES` entry; Cinderheart has none.

## How a room picks its biome

`RegionRoom.biome_id` ("cinderheart" or "hollow_molt") selects an entry of
`RegionRoom.BIOMES`, which sets the art room's per-biome settings: the art folder, which
layers exist (Hollow Molt has no close rock and plant bands, no cave wall, no textured
wall fill and no rim), back tint and clear colour, the terrain tiles' collision trims
(measured from the tiles' alpha; the same measurement reproduces Cinderheart's within a
few px), the platform props' bounds and walkable tops, the foreground band pieces and
where they sit, the exit light's colour, and whether the warm mood pass runs (off: it is
amber and this biome is grayscale). Cinderheart's values are the defaults, unchanged.

In the layout script a room takes `biome = "hollow_molt"` and an output folder; the
builder sets the room's biome and points the editor preview at that biome's tiles.

## Open

- The decorative `middle-foreground/` blocks and the room borders are not placed yet.
- No mood pass for this biome (a grayscale fog, dust and grade would be the equivalent).
