# Terrain collision spikes

Throwaway scripts that source the engine behaviour behind `docs/architecture/adr-0001-terrain-collision-build.md`
(Godot 4.7.2, headless, 2026-11-22). The engine reference does not cover 2D collision, so these are the evidence.
Re-run them after any engine upgrade and compare with the ADR's Related section.

Each script extends `SceneTree` and prints `RESULT` lines. From a project folder:

```bash
godot --headless --path . -s /absolute/path/to/prototypes/terrain-collision-spikes/seam.gd
```

| Script | Shows |
|---|---|
| `seam.gd` | A 10 x 22 body on a 160-tile floor at 140 and 370 px/s: no catch for merged, per-tile, polygon, `TileMapLayer` and segment shapes |
| `wall_cost.gd` | Wall slide and fall along per-tile shapes; ceiling dash; tile-shape build cost against merged |
| `contact.gd` | A `KinematicCollision2D` position and normal on a wall and a floor |
| `strips.gd` | One overlapping strip per face segment: 11 segments, 11 shapes on a pillar-on-block room; slides, a run and a fall |
| `strips_cost.gd` | Face, strip and shape build time on 800 x 45 tiles (naive face pass) |
| `faces_fast.gd` | The same face pass inlined on a padded grid |

Not part of the game or the test suite.
