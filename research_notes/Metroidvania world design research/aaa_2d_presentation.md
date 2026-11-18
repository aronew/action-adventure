# AAA-quality 2D metroidvania presentation, and how to build it in Godot 4.7

Scope: the presentation techniques used by top 2D metroidvanias (Hollow Knight, Silksong, Nine Sols, Ori 1/2, Blasphemous, Prince of Persia: The Lost Crown, Aeterna Noctis, Ender Lilies, Dead Cells, Owlboy, Celeste), and how to build them in Godot 4.x. Target: Godot 4.7.2, GDScript, pixel art at 480x270 scaled by whole numbers, Camera2D following the player.

Source quality: developer-side material was thin. Most AAA 2D art talks (GDC Vault "The Art of Ori and the Will of the Wisps") are behind the GDC paywall. Noel Berry's Celeste lighting post returned HTTP 403. No primary sources turned up for Silksong, Nine Sols, The Lost Crown, Aeterna Noctis, Ender Lilies or Owlboy within the research budget. The Godot material comes from the current official docs, which serve 4.7 as "stable", and is strong.

---

## 1. Parallax: layer counts, speeds, atmospheric perspective, foreground framing, pitfalls

### Takeaway
Hollow Knight's look comes from a three-band structure: foreground, a middle play layer, and several background layers stacked behind it. Each band holds multiple parallax planes. The foreground has objects that pass in front of and block the player, and Team Cherry's art lead says doing this for every area cost months. Godot's Parallax2D does this with one `scroll_scale` per layer. The official docs give a 5-layer reference set of speeds from 0.1 to 0.7.

### Cited Findings
- Hollow Knight's environments are described as three layers: foreground, middle ground (where play happens) and background, with the background stacked to create a 3D feel. This is a third-party analysis, not Team Cherry — [Medium, "The Art of Hollow Knight"](https://medium.com/3d-environmental-art/the-art-of-hollow-knight-f4c05dda3882)
- PC Gamer notes Hollow Knight scenes have "objects blocking the screen in the foreground, parallaxed background layers, particle effects, clouds rolling by, and subtle lighting changes as you move through a level" — [PC Gamer](https://www.pcgamer.com/hollow-knights-charming-art-sets-the-bar-for-hand-drawn-games)
- Ari Gibson (Team Cherry) reportedly said multi-layer parallax was manageable in one area, but carrying that level of background work across the whole game added months. Simplifying enemy and NPC designs freed him to produce several backgrounds a day. This comes from a Chinese reprint of a Rock Paper Shotgun column; the English original was not verified — [gcores reprint of RPS](https://www.gcores.com/articles/106192)
- ACMI (Australian Centre for the Moving Image) describes Team Cherry's style as painted landscapes with "extravagant parallax" for depth in a side-on world — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/)
- An informal Reddit account puts Hollow Knight at 3-4 layers moving at different speeds. It is anecdotal, cited only as a cross-check — [via search summary, Medium/Reddit](https://medium.com/3d-environmental-art/the-art-of-hollow-knight-f4c05dda3882)
- Ori: Airborn Studios (a visuals vendor) describes the result as "a layered painterly look that has depth to it and doesn't look as flat as 2D games often do" — [Airborn Studios](https://airborn-studios.com/projects/ori)
- Blasphemous 2 uses layered backgrounds that shift at different rates. This is a Spanish secondary source — [Foro3D](https://foro3d.com/2026/febrero/blasphemous-unity-potencia-mundo-pixel-art.html)
- A senior pixel artist from the Blasphemous series (Jesús "Nerkin" Campos) worked on Ninja Gaiden: Ragebound. Its art direction is described as precise colour palettes, texture tiling design, and "layering decorative elements and parallax effects to bring depth" — [PlayStation Blog](https://blog.playstation.com/?p=407986)
- **Godot Parallax2D, reference speeds from the official tutorial:** Forest `scroll_scale (0.7, 1)`, Hills `(0.5, 1)`, Lower Clouds `(0.3, 1)`, Higher Clouds `(0.2, 1)`, Sky `(0.1, 1)`. 1 = moves with the camera, <1 = farther away, 0 = static, >1 = closer (foreground) — [Godot docs: 2D Parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html)
- **Parallax2D properties and defaults:**

  | Property | Default | Behaviour |
  |---|---|---|
  | `scroll_scale` | `(1,1)` | Per-axis speed multiplier |
  | `repeat_size` | `(0,0)` | Repeat distance; 0 disables repeating on that axis |
  | `repeat_times` | `1` | Extra repeats; "Useful for when zooming out with a camera" |
  | `autoscroll` | `(0,0)` | Pixels per second, e.g. for drifting clouds or fog |
  | `follow_viewport` | `true` | Offset by the current camera's position |
  | `ignore_camera_scroll` | `false` | Manual scrolling |
  | `limit_begin` / `limit_end` | `±10,000,000` | The layer stops scrolling when the camera is outside them |
  | `scroll_offset` | `(0,0)` | Not overridden; loops when `repeat_size > 0` |

  The page also notes "Any changes to this node's position made after it enters the scene tree will be overridden". `physics_interpolation_mode` defaults to `2` — [Godot class ref: Parallax2D](https://docs.godotengine.org/en/stable/classes/class_parallax2d.html)
- **Parallax2D pitfalls (official):**
  - Textures must start at (0,0). A centered texture only partly repeats.
  - The image should be at least as big as the viewport before you set `repeat_size`.
  - "`Parallax2D.repeat_size` and `Sprite2D.region_rect` do not take scaling into account."
  - Camera zoom of (0.5,0.5) can break the repeat; use `repeat_times = 3`.
  - For split screen, clone the parallax nodes into each SubViewport.
  - The tutorial says that "prior to 4.3" the approach was ParallaxBackground/ParallaxLayer, and now recommends Parallax2D. The KoBeWi "Parallax2D Preview" addon gives an in-editor preview.

  — [Godot docs: 2D Parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html)

### Inferences
- A reasonable layer budget at 480x270 is 4-6 background Parallax2D layers (sky 0.05-0.1, far silhouettes 0.2-0.3, mid 0.5, near background 0.7-0.85), the play layer at 1.0, and 1-2 foreground layers at about 1.1-1.4. The background numbers extend Godot's tutorial set; the foreground values above 1 are my extrapolation, not a sourced figure.
- Atmospheric perspective (desaturating and lightening toward the fog colour as layers recede) was described in sources only as "stacking" and "layered painterly depth". No developer source gave per-layer saturation or value numbers (see Gaps). In Godot, the cheap route is a per-layer `modulate` or a tiny canvas_item shader that lerps toward a per-biome fog colour by a per-layer `depth` uniform. Keep the fog colour in data, per the project's data-driven rule.
- **Readability pitfall for foreground framing:** foreground layers above 1.0 move faster than the player, so they should be dark silhouettes, low detail, and never hide collision edges or hazards. Hollow Knight's "objects blocking the screen" work because they are transient and dark. That is an observation, not a sourced rule.
- **Vertical parallax:** the tutorial examples use `y = 1` (no vertical parallax). Vertical-heavy metroidvania rooms need `y < 1` plus `limit_begin`/`limit_end`, or tall/repeating art, or the layer runs out of texture at the top and bottom.

### Gaps
- No developer-confirmed per-game layer counts or scroll factors for Hollow Knight, Silksong, Ori, Nine Sols, Lost Crown, Aeterna Noctis or Ender Lilies. The Ori art GDC talks (GDC Vault 1027375) are members-only.
- No sourced numbers for atmospheric perspective (per-layer saturation or value falloff).
- Whether Parallax2D interacts badly with `snap_2d_transforms_to_pixel` (layers jittering against each other) is not covered in the docs.

---

## 2. Lighting and atmosphere: lights, glow, shafts, fog, particles, grading, vignette; lighting pixel art without breaking it

### Takeaway
Dead Cells is the best-documented pixel-art lighting pipeline. It hand-paints backgrounds and decorations in pixel art, then redraws each in a normal map. A dynamic light system relights them per biome, so the "entire ambience" can change without repainting. Characters come from 3D, rendered at about 50 px tall with no antialiasing, a toon shader and per-frame normals. Godot 4 supports the same approach: CanvasTexture normal maps, PointLight2D/DirectionalLight2D, CanvasModulate for ambient light, and HDR 2D glow via WorldEnvironment.

### Cited Findings
- **Dead Cells backgrounds:** "The backgrounds and decorations are done in PA [pixel art] and then redrawn in normal maps." This lets the team "change the entire ambience of our levels without having to redraw all of the elements." "Our dynamic 3D lighting system" gives "different tints and reliefs," and "a torch on the left of a statue will light up the statue from the correct direction while respecting its base colours." The palette is "a saturated pallet, Celtic architecture/environments and alchemy" — Steve Filby, Motion Twin, [80.lv interview (2017)](https://80.lv/articles/interview-with-the-developers-of-dead-cells)
- **Dead Cells characters (Thomas Vasseur):**
  - 3DS Max models and skeletons, exported as FBX and rendered by a homebrew tool.
  - Rendered small without antialiasing: "the ingame height of the character will only be 50 pixels."
  - Each frame carries a normal map, with a basic toon shader for volume.
  - Lighting comes from a lighting system, not hand-drawn shadows.
  - Retiming is fast: "we can adjust the timing of the animations dozens of times in minutes."
  - Unsolved downside: "we still haven't found any solution for flickering pixels."

  — [Game Developer: Art Design Deep Dive, 3D pipeline for 2D animation in Dead Cells](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)
- **Blasphemous:** "From the very beginning we wanted to be very 'purist' about the pixel art style. That became a real problem because we were limited by the pixel art style" — Enrique Colinet, [Hollywood Reporter](https://www.hollywoodreporter.com/heat-vision/blasphemous-designer-purist-approach-games-pixel-art-style-1238370)
- **Ori (Moon Studios):** Gennadiy Korol said the artists needed "a 2D art pipeline that would allow them to efficiently build, preview and animate all of our art directly in the editor" — [MCV](https://www.mcvuk.com/development-news/unity-focus-making-ori-and-the-blind-forest/)
- **Hollow Knight** combines particle effects, rolling clouds and "subtle lighting changes as you move through a level" — [PC Gamer](https://www.pcgamer.com/hollow-knights-charming-art-sets-the-bar-for-hand-drawn-games)
- **Godot 2D lights:**
  - CanvasModulate sets the ambient colour where no light reaches. Without it, lights only brighten an already lit scene.
  - The background clear colour does not receive light; a Sprite2D must be there.
  - Light2D blend modes are Add (default), Subtract ("negative lights") and Mix.
  - Lights are limited by Z/Layer ranges and Item Cull Mask.
  - Larger `texture_scale` costs more because more pixels are lit.
  - `height` affects only normal-mapped surfaces.
  - A radial GradientTexture2D makes custom falloff.

  — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Godot shadows:**
  - Shadow filter None is "fastest, suited to pixel art". PCF5 is soft. PCF13 is softest and should be used for only a few lights.
  - Higher `filter_smooth` can band or streak.
  - DirectionalLight2D shadows are always infinitely long. `max_distance` culls them and ignores Camera2D zoom.
  - Occluders can be auto-generated from a Sprite2D ("Create LightOccluder2D Sibling") or set per tile in a TileSet occlusion layer.

  — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Godot pixel-art lighting caveat:** "Lighting and shadows are computed at the Viewport's pixel resolution, not the texture's texel resolution." Nearest filtering does not pixelate lights. To pixelate them, snap `LIGHT_VERTEX` and `SHADOW_VERTEX` with `floor()` and a `pixel_size` uniform in a canvas_item shader — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Godot normal and specular maps:**
  - Use a CanvasTexture with Diffuse, Normal Map and Specular slots, on any Node2D or Control.
  - Lower `shininess` gives broad, dim highlights; higher gives tight highlights for wet surfaces.
  - Lights look weaker after enabling normals; raise `height` and `energy`.
  - The docs recommend the free tool Laigter for generating normal maps.

  — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Cheap glow:** additive-blend sprites (CanvasItemMaterial, Blend Mode Add) render faster than Light2D. They suit bullets, explosions and short effects, but cannot light fully dark areas, cast shadows, or use normal maps — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- **Godot 2D glow and grading:**
  - WorldEnvironment Background = Canvas lets environment effects such as glow apply to 2D. `Canvas Max Layer` decides which CanvasLayers are affected, so the UI can stay out.
  - "Since Godot 4.2, you can enable HDR for 2D rendering when using the Forward+ and Mobile rendering methods" (Project Settings > Rendering > Viewport > HDR 2D, then restart). This gives per-object glow via Modulate/Self Modulate values above 1.
  - Warning: with HDR 2D on, the 2D renderer works in linear space, so colour textures in canvas_item shaders need `source_color` or they look washed out.
  - Glow blend modes: Softlight is the default and weakest; Additive is strongest.
  - Small glow levels give tight halos; large levels give screen-wide haze.
  - A glow map texture can tint or mask glow per screen region.
  - Adjustments: brightness, contrast, saturation, a 1D gradient colour-correction, or a 3D LUT (17/33/51/65 per axis, imported as Texture3D), applied after tonemapping.
  - Compatibility renderer: glow is a reduced implementation; Levels, Strength, Blend Mode and Map are hidden.

  — [Godot docs: Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html)
- **Forum pitfall (4.4):** Canvas background plus HDR showed a saturation-like shift on everything under the Mobile renderer. The poster eventually baked glow into the art — [Godot Forum](https://forum.godotengine.org/t/how-do-i-make-sure-the-hdr-glow-bloom-effect-doesnt-get-applied-to-certain-canvas-layers/106258)
- **Godot 2D SDF for shaders:** occluders feed a 2D signed distance field (SDF Collision is on by default, and costs nothing unless a shader reads it). Custom shaders can read it, and the docs suggest it for finite directional shadows. Project settings `rendering/2d/sdf/scale` and `oversize` control its resolution and coverage. The ProjectSettings descriptions contradict their own defaults ("120%" and "50%" in text vs `1` in the table) — [Godot docs: 2D lights](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html); [ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- **Shadow atlas:** `rendering/2d/shadow_atlas/size` defaults to 2048, rounded up to a power of 2, and is read only at startup — [ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- **New in 4.7:** `GradientTexture2D` gained `FILL_CONIC`, "useful for custom 2D shaders that need 3D-like shading". HDR output now works for "both 2D and 3D scenes" — [Godot 4.7 release page](https://godotengine.org/releases/4.7/)

### Inferences
- With stretch mode `viewport` at 480x270, Godot renders the whole canvas at 480x270, so lights and shadows are computed at game-pixel resolution. They will already look pixel-sized after integer upscale, which makes `LIGHT_VERTEX` snapping mostly unnecessary. This follows from the "Viewport's pixel resolution" rule plus how viewport stretch works ([multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)); verify in-engine.
- Dead Cells is the template for this project: paint tiles and decor flat, author a normal map per sheet (Laigter is the doc-recommended tool), and give each biome a CanvasModulate colour plus a few PointLight2Ds. That yields "different ambience without redrawing", as Filby put it.
- Two cheap Godot recipes, assembled from the documented features above; neither is a documented recipe:
  - **God rays:** an additive-blend Sprite2D or Polygon2D with a gradient texture (or a small shader scrolling noise along the ray), placed on a parallax layer just behind or in front of the play layer.
  - **Fog bands:** a Parallax2D with `autoscroll` and a tiling semi-transparent noise texture, tinted to the biome fog colour.
- **Vignette:** a full-screen ColorRect in a top CanvasLayer with a radial-darkening canvas_item shader. Keep it on a layer above `Canvas Max Layer` if HDR glow is used, so the vignette is not bloomed (inference from the Canvas Max Layer behaviour).
- **Ambient particles** (dust, spores, embers): GPUParticles2D in parallax layers. The play-layer copy should be sparse and low-contrast so it is not mistaken for hazards or projectiles (inference).

### Gaps
- No primary source on how Hollow Knight or Ori stack light, fog and glow layers (Ori GDC talks are paywalled).
- Noel Berry's "Remaking Celeste's Lighting" post (medium.com/@NoelFB) returned 403 and could not be read.
- No primary source on Blasphemous's lighting technique, or on Owlboy's.
- No sourced per-biome colour-grading numbers from any of the listed games.

---

## 3. Readability: play layer vs background, keeping characters readable, hazard colour language

### Takeaway
Within budget, no developer of the listed games gave explicit readability rules or numbers. The documented levers are Dead Cells' saturated palette with normal-mapped lighting and the three-band structure, where play happens in the middle layer. The rest below is inference and should be validated by playtest.

### Cited Findings
- Hollow Knight puts gameplay on the middle-ground layer, with background layers stacked behind and a separate foreground — [Medium analysis](https://medium.com/3d-environmental-art/the-art-of-hollow-knight-f4c05dda3882)
- Dead Cells keeps very different biomes coherent with "a saturated pallet," and relights props per biome through normal maps — [80.lv](https://80.lv/articles/interview-with-the-developers-of-dead-cells)
- Dead Cells characters are about 50 px tall in-game, rendered without antialiasing — [Game Developer](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)
- Godot can exclude objects from a light (Item Cull Mask) or from shadows (Occluder Light Mask vs Shadow Item Cull Mask). This allows "hero lighting", where the player is always lit or never shadowed — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- With HDR 2D, glow is controllable per object through Modulate/Self Modulate above 1. Hazards or pickups can glow while the scenery does not — [Godot docs: Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html)

### Inferences
- A common rule of thumb, not sourced to any of the listed developers:
  - Background layers: lower value contrast and saturation, shifted toward the fog colour.
  - Play layer: full contrast, with a dark or neutral outline or rim.
  - Player and enemies: the highest local contrast on screen.
  - Hazards: one consistent reserved hue that is used nowhere else in that biome.
- At 480x270 a 50 px character is about 18% of screen height (50/270). That Dead Cells figure is a useful scale reference for character size against the screen.
- Hero lighting in Godot: a small PointLight2D on the player with its own cull mask, so the player stays readable in dark CanvasModulate biomes.

### Gaps
- No primary source on hazard colour language, outline rules, or value-contrast numbers from Team Cherry, Moon Studios, The Game Kitchen, Red Candle (Nine Sols), Ubisoft Montpellier (Lost Crown), Aeterna Game Studio, Live Wire/Adglobe (Ender Lilies), D-Pad Studio (Owlboy) or Extremely OK Games (Celeste).

---

## 4. Terrain art pipeline: blockout collision plus art on top, edge tiles, AO at terrain edges

### Takeaway
Godot's TileSet separates collision (physics layers with per-tile polygons), light occlusion (occlusion layers), navigation, gameplay data (custom data layers) and auto-tiling (terrain sets) inside one resource. 4.7 adds a 2D Scene Paint Mode for scattering decoration scenes without a tilemap, which suits a "collision tiles + painted overlay" pipeline. Dead Cells' "paint in pixel art, redraw as normal map" is the documented precedent for lighting tile art dynamically.

### Cited Findings
- **TileSet layers:** you "will need to create a physics, navigation or occlusion layer for the TileSet resource first." Collision polygons are drawn per atlas tile, with `F` for a default rectangle that you trim to slopes, and one polygon can be painted across many tiles. Occlusion layers need "occluder polygons for 'solid' tiles" for 2D shadows — [Godot docs: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
- **Terrain sets:** three modes (Match Corners and Sides, Match Corners, Match Sides), equivalent to Godot 3.x autotile 3x3, 2x2 and 3x3-minimal. Peering bit `-1` means empty — [Godot docs: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
- **Custom data layers** store per-tile gameplay data, e.g. `damage_per_second = 25`, `destructible = false`, shared by all placed instances — [Godot docs: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
- **Scene tiles** "come with a greater performance overhead compared to atlases"; use them only when needed — [Godot docs: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
- Set the tile size before creating the atlas — [Godot docs: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
- **4.7 Scene Paint Mode:** "Godot now offers a **Scene Paint Mode** in 2D (B by default)" to scatter collectables, enemies or decorations without a tile map. It is 2D-editor only — [Godot 4.7 release page](https://godotengine.org/releases/4.7/)
- **4.7** adds `one_way_collision_direction` on CollisionShape2D. One-way platforms were previously always locally up — [Godot 4.7 release page](https://godotengine.org/releases/4.7/)
- **4.6:** scene tiles can be rotated, and TileMapLayer redraws were reduced — [Godot forum, 4.6 dev5](https://forum.godotengine.org/t/dev-snapshot-godot-4-6-dev-5/128995); [first look](https://d34kmbgkaszffl.cloudfront.net/blog/godot-4-6-a-first-look-at-what-s-coming-next)
- **Dead Cells:** backgrounds and decorations are pixel-art painted, then redrawn as normal maps — [80.lv](https://80.lv/articles/interview-with-the-developers-of-dead-cells)
- **Hollow Knight** environments are described as "painted landscapes" with parallax (not tile-based), built in Unity — [ACMI](https://www.acmi.net.au/stories-and-ideas/from-ludum-dare-to-pharloom/); [Unity case study](https://unity.com/made-with-unity/hollow-knight)

### Inferences
- A practical Godot structure for "black-box collision + painted tiles + natural shadows":
  1. **Collision TileMapLayer:** plain square and slope tiles with physics and occlusion polygons. Leave it invisible in game, or draw it as flat dark fill.
  2. **Visual TileMapLayer:** painted terrain tiles using a terrain set (Match Corners and Sides) for edges and corners. Give it no collision, and use a CanvasTexture with normal maps.
  3. **Decoration overlay:** Sprite2Ds or scenes for edge lips, roots, moss and rubble that break the grid, placed with 4.7's Scene Paint Mode.
  4. **Edge AO:** a dark gradient "inner shadow" tile variant, or a Light2D in Subtract mode placed along cavity interiors.

  Each step is a combination of documented features; none is a documented recipe.
- Keeping collision and visual layers separate lets art overhang collision (grass tufts, rounded lips) without changing the physics. Keep overhang under ~4 px at 480x270 so players do not misread ledges (rule of thumb, unsourced).

### Gaps
- No sourced statement on how Celeste separates collision tiles from decoration, or on Blasphemous's tile workflow.
- No sourced tile count for a full Godot terrain set (the "47-tile blob" is not mentioned in the docs).
- No primary Team Cherry description of Hollow Knight's environment-building workflow beyond "painted" and "parallax".

---

## 5. Camera: zones, look-ahead, framing, arena locks, shake, zoom, pixel jitter

### Takeaway
The canonical camera reference is Itay Keren's "Scroll Back". It gives named techniques with numbers, such as forward focus about 25% of screen width ahead (Defender), a camera window one jump high (Rastan), and platform-snapping (Super Mario World). In Godot, Camera2D gives drag margins (0.2 default), position smoothing (speed 5.0 px/s units), and limits with `limit_smoothed`. Arena locks and room zones are made by changing limits at runtime.

### Cited Findings
- **Camera-window:** the camera holds until the player hits the window edge. Rastan Saga's window is about one jump high; Fez uses a horizontal window — [Itay Keren, "Scroll Back", Game Developer](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)
- **Platform-snapping:** the camera stays still vertically during jumps and snaps on landing (Super Mario World; Rayman with a jump-height window) — [Scroll Back](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)
- **Lerp smoothing:** `a = a + t*(b - a)` (Donkey Kong Country). Very fast characters can outrun it — [Scroll Back](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)
- **Forward focus:** Defender keeps focus about 25% of screen width ahead. Super Mario Bros. has a speed-up point about 25% off-center. Cave Story moves focus with walking speed. Super Mario World keeps the current focus target until a threshold is crossed. Projected focus (aim at the extrapolated position) "works poorly for jumps and landings" — [Scroll Back](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)
- **Region-based zones:** Donkey Kong Country lets designers set camera behaviour per region. Mushroom 11 confines the camera to a per-region path with a preset zoom per region — [Scroll Back](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)
- **Cue focus / attractors:** Insanely Twisted Shadow Planet uses double-ring attractors (outer ring weighted, inner ring locks). Mushroom 11 uses cue focus for bosses — [Scroll Back](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)
- **Celeste:** the camera quickly scrolls between rooms on transition. This is a secondhand devlog observation. Celeste has 200+ rooms across eight chapters — [Cosmodrift devlog](https://endermagnet.itch.io/cosmodrift/devlog/589242/devlog-2-be-there-or-b); [Wikipedia](https://en.wikipedia.org/wiki/Celeste_(video_game))
- **Godot Camera2D defaults:**

  | Property | Default |
  |---|---|
  | `drag_horizontal_enabled` / `drag_vertical_enabled` | `false` |
  | Drag margins (left, right, top, bottom) | `0.2` each |
  | `drag_*_offset` | `0` |
  | `position_smoothing_enabled` | `false` |
  | `position_smoothing_speed` | `5.0` ("Speed in pixels per second of the camera's smoothing effect") |
  | `limit_enabled` | `true` |
  | Limits | `±10,000,000` |
  | `limit_smoothed` | `false` ("the camera smoothly stops when reaches its limits"; needs position smoothing) |
  | `anchor_mode` | Drag Center |
  | `process_callback` | Idle |
  | `ignore_rotation` | `true` |

  — [Godot class ref: Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html)
- **Camera2D gotchas:**
  - `global_position` is not the on-screen position when smoothing or limits apply; use `get_screen_center_position()`.
  - `reset_smoothing()` jumps instantly to the target (use it on room teleports and respawns).
  - Bitmap fonts blur under camera zoom.

  — [Godot class ref: Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html)
- **4.6 Camera2D fixes:** limit checks with inverted boundaries, and reset behaviour. Changelog aggregator only; weak source — [filehorse changelog](https://www.filehorse.com/download-godot-engine-64/98419/)
- **Jitter:** enable physics interpolation to fix jitter from mismatched physics/idle time sources ("interpolating the transforms of physics objects between physics frames"). Take care when teleporting, since it can visibly interpolate. It adds some input lag; raising physics ticks compensates. Prefer VRR with V-Sync on — [Godot docs: Fixing jitter, stutter and input lag](https://docs.godotengine.org/en/stable/tutorials/rendering/jitter_stutter.html)
- **Pixel snapping settings:**
  - `rendering/2d/snap/snap_2d_transforms_to_pixel` (default `false`): "If true, CanvasItem nodes will internally snap to full pixels... Useful for low-resolution pixel art games."
  - `snap_2d_vertices_to_pixel` (default `false`): snaps only final vertex positions.
  - Both are read only at project start.

  — [Godot class ref: ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- **Pixel-art scaling:**
  - Stretch mode `viewport` gives "low-resolution rendering that is then stretched".
  - `scale_mode = integer` (added in 4.2; default `fractional`) prevents uneven pixel scaling.
  - Use Exclusive Fullscreen, because plain Fullscreen's 1-px height reduction can drop the integer scale factor.
  - `viewport` mode limits sub-pixel movement; `canvas_items` allows it.

  — [Godot docs: Multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)

### Inferences
- **480x270 integer scales:** 2x = 960x540, 4x = 1920x1080, 8x = 3840x2160 all fill the screen exactly. 2560x1440 is not an integer multiple (5.33x), so 1440p players get 5x (2400x1350) with black bars. This is arithmetic from the docs' integer-scale rule.
- **Smooth camera vs pixel jitter in `viewport` mode:** the whole canvas renders at 480x270, so a smoothed camera lands on sub-pixel offsets and the image steps one game-pixel at a time. That is visible as stair-stepping during slow lerps. Common mitigations, which the official pages do not document:
  - (a) Accept whole-pixel camera steps, with `snap_2d_transforms_to_pixel` on so sprites and camera agree.
  - (b) Render the game in a SubViewport at 481x271, offset it by the camera's fractional remainder when displaying, and integer-scale it. This is the "smooth pixel camera" trick.

  Both are inference and need testing in 4.7.
- **Arena camera lock:** on boss-room entry, tween Camera2D's `limit_*` to the arena rect. Keep `limit_smoothed = true` with position smoothing so it eases, and restore the room limits on exit.
- **Room zones:** an Area2D per room carrying its limit rect, plus an optional zoom and offset as data. Call `reset_smoothing()` on teleports to avoid sweeping across the map.
- **Look-ahead:** set `drag_horizontal_offset` from facing direction and velocity (in -1..1) rather than moving `offset` by hand. That gives Cave Story-style focus shift. Clamp vertical look-ahead and use platform-snapping (only update the vertical target when grounded) per Keren.
- **Screen shake:** in `viewport` mode at 480x270, a 1-2 px shake is already large on screen (1 px at 4x scale is 4 screen pixels). Use `Camera2D.offset` with whole-pixel values and decay over about 0.1-0.3 s. These values are a rule of thumb, not sourced.

### Gaps
- No primary source on Hollow Knight's camera-lock zones, Ori's camera, or Celeste's look-ahead or offset logic. The search found only fan tutorials and reverse-engineering, not developer accounts.
- Physics interpolation for 2D: the docs recommend it, but this research did not confirm which version added 2D support, or how it interacts with Camera2D smoothing or `snap_2d_transforms_to_pixel` in 4.7.

---

## 6. Juice in presentation: hit-stop, impact frames, particles, flashes, room transitions

### Takeaway
Hit-stop (also called hitlag or freeze frames) is the key impact tool. Sakurai defines it as frozen frames that emphasize the power of the hit, sometimes paired with screen shake. Smash caps its duration and gives projectiles less of it. Vlambeer's "The Art of Screenshake" (INDIGO 2013) is the canonical "more of everything" juice talk. Dead Cells' attacks are pose-to-pose, with VFX carrying the motion and impact.

### Cited Findings
- **Hitstop** is "the frozen frames that emphasize the power of the hit," sometimes with screen shaking for powerful moves — Masahiro Sakurai's Famitsu column, via [Source Gaming translation](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/)
- **Smash hitstop specifics:** it has a cap, projectiles get less of it, and during hitstop grounded characters vibrate horizontally while aerial characters vibrate vertically. This comes from a fan translation that disclaims its own accuracy — [Source Gaming](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/); [SSBWiki: Hitlag](https://www.ssbwiki.com/Hitlag)
- **Sakurai video:** a 2022 episode of "Masahiro Sakurai on Creating Games" covers eight hit-stop techniques — [GoNintendo](https://www.gonintendo.com/contents/13581-sakurai-s-latest-game-dev-video-features-8-hit-stop-techniques)
- **Vlambeer:** Jan Willem Nijman's "The Art of Screenshake" (INDIGO 2013) covers screenshake, slow motion, particles, and adding more feedback. Whether it specifically covers hit-stop could not be confirmed — [Game Developer](https://gamedeveloper.com/design/vlambeer-co-founder-shares-advice-on-building-better-action-games); [DK Liao recreation devlog](https://dkliao.itch.io/the-art-of-screenshake-recreation/devlog/451576/quick-breakdown-of-all-the-effects)
- **Dead Cells:** animators set keyframes, then add interpolation frames before or after them, never in between. Attacks are pose-to-pose, "with VFX adding motion and impact" — [Game Developer](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)
- **Godot:** additive-blend sprites are the cheap path for flashes, bullets and explosions (faster than Light2D) — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html). With HDR 2D, a hit flash can push Modulate above 1 to bloom briefly — [Godot docs: Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html)
- **Celeste** transitions by scrolling the camera quickly between rooms (secondhand) — [Cosmodrift devlog](https://endermagnet.itch.io/cosmodrift/devlog/589242/devlog-2-be-there-or-b)

### Inferences
- **Godot hit-stop:**
  - Global: `Engine.time_scale = 0` for N frames, restored by a timer with `ignore_time_scale = true`.
  - Local: pause only the hitter's and victim's AnimationPlayer and physics.
  - Pair it with a 1-frame white flash, a canvas_item shader `flash_amount` uniform, and a 1-2 px whole-pixel camera shake.

  Durations of about 3-8 frames at 60 fps (50-130 ms), scaled by hit strength and capped, follow Sakurai's "cap it, less for projectiles" logic. The frame counts are a common rule of thumb, not sourced.
- **Room transitions:** either a Celeste-style fast camera pan between room limit rects (tween `limit_*` and position, then `reset_smoothing()`), or a short fade or iris on a top CanvasLayer while the next room loads.

### Gaps
- No sourced hit-stop frame counts from Hollow Knight, Nine Sols, Lost Crown or Dead Cells.
- No primary source for the "art of screenshake" frame counts. The talk video (YouTube AJdEqssNZ-U) was not reviewed.

---

## 7. Godot 4 implementation path and 4.5-4.7 caveats

### Takeaway
Every needed building block exists in Godot 4.7 and is documented: Parallax2D, TileMapLayer with physics, occlusion and terrain layers, CanvasModulate, Light2D with CanvasTexture normals, HDR-2D glow through WorldEnvironment, Camera2D limits and smoothing, integer viewport scaling, and the 2D snap settings. The 4.5-4.7 release pages show additions rather than breaking changes for these 2D features. The main risks are renderer choice (Compatibility glow is reduced), HDR 2D linear-space colour shifts, and jitter interactions, which the docs do not cover.

### Cited Findings
- **Project settings for this project's spec:**
  - Viewport 480x270, `display/window/stretch/mode = viewport` (default "disabled")
  - `scale_mode = integer` (default "fractional"; integer added in 4.2)
  - Exclusive Fullscreen

  — [Godot docs: Multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html); [ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- **Snap settings:** `snap_2d_transforms_to_pixel` and `snap_2d_vertices_to_pixel`, both default false and read only at startup — [ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- **2D batching:** `rendering/2d/batching/item_buffer_size` defaults to 16384 ("Maximum number of canvas item commands that can be batched into a single draw call"); `uniform_set_cache_size` defaults to 4096 — [ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
- **4.6:** the 2D renderer was reworked to cut the GPU cost of automatic batching (batching was added in 4.4) — [Godot 4.6 dev5 post](https://godotengine.org/article/dev-snapshot-godot-4-6-dev-5/)
- **4.6.3:** maintenance fixes include a TileMap layer-selector fix and a GLES3 batching fix — [Godot 4.6.3](https://godotengine.org/article/maintenance-release-godot-4-6-3/)
- **4.7 additions relevant here:**
  - 2D Scene Paint Mode (B key)
  - `one_way_collision_direction`
  - `GradientTexture2D` `FILL_CONIC`
  - `DrawableTexture2D` for drawing on textures
  - `AtlasTexture` in `TextureRect`
  - HDR output for 2D and 3D
  - `VirtualJoystick` (Fixed, Dynamic and Following modes)
  - The new nearest-neighbor viewport scaling option is 3D-only and "does not affect 2D rendering"
  - The page lists no 2D compatibility breaks and defers to the migration guide

  — [Godot 4.7 release page](https://godotengine.org/releases/4.7/)
- **HDR 2D** is Forward+ and Mobile only per the docs (Compatibility is not listed). Glow in Compatibility hides Levels, Strength, Blend Mode and Map — [Godot docs: Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html)

### Inferences
- **Suggested node layout per room:**
  - `Parallax2D` × N (sky, then far, mid and near), each with `scroll_scale`, `repeat_size` and a per-layer fog-tint material
  - `TileMapLayer` "Collision" (physics + occlusion)
  - `TileMapLayer` "Terrain" (visual, normal-mapped)
  - `Node2D` "Decor" (scene-painted)
  - Actors
  - `Parallax2D` foreground with `scroll_scale > 1`
  - `CanvasModulate` (biome ambient)
  - `PointLight2D`s (shadow filter None)
  - `GPUParticles2D` ambience
  - `WorldEnvironment` (Background Canvas, glow, adjustments/LUT, Canvas Max Layer below UI)
  - `CanvasLayer` for vignette and UI
  - `Camera2D` with limits from room data
- Choose Forward+ or Mobile if per-object HDR glow is wanted. Under Compatibility (e.g. for web export), plan to bake glow into sprites or use additive sprites instead (inference from the renderer limits).

### Gaps
- No official statement in the pages read on the version that added Parallax2D. The tutorial implies 4.3 ("Prior to 4.3"). No statement either on 2D physics interpolation's version or behaviour in 4.7.
- The 4.5 release notes were not examined in detail for 2D changes (the search returned the page without content). The 4.7 page lists no 2D breaking changes, but the migration guides (4.4→4.5, 4.5→4.6, 4.6→4.7) were not read.
- The project's `VERSION.md` notes the installed editor version is NOT DETERMINED. Confirm the 4.7-only features (Scene Paint Mode, `one_way_collision_direction`, `FILL_CONIC`) exist in the installed editor before relying on them.
