# Art-style long room: 10-screen performance test (2026-11-19)

Level design rule 1 (rooms of 6-20 screens, open-edge exits) and Open Question 22.
Room: `src/test_rooms/art_style_long_room.tscn`, Cinderheart Caldera, 2412 x 540 world px
(about 10 screens, 5 wide x 2 tall), Seeker at 4x, 1920x1080 window.
Bench: `tests/performance/art_room_bench.tscn`, one process per room, Godot 4.7.2.

**Hardware caveat:** no GPU in the cloud container. Rendering ran on lavapipe (llvmpipe,
CPU software Vulkan), so frame and GPU times are 50-100x a real GPU's and only compare
the two rooms. Memory, load times, node counts and draw calls are meaningful.

| Measure | 3-screen room | 10-screen room |
|---|---:|---:|
| Texture memory (MB) | 96.5 | 99.2 |
| Video memory (MB) | 139.4 | 142.1 |
| Static memory (MB) | 46.9 | 48.0 |
| Nodes | 243 | 524 |
| Draw calls per frame, median / max | 31 / 73 | 34 / 77 |
| Objects drawn per frame, median | 163 | 159 |
| Cold load to first frame (ms) | 1072 | 751 |
| Warm rebuild: build / to first frame (ms) | 316 / 480 | 325 / 477 |
| Render CPU per frame, median (ms) | 0.16 | 0.18 |
| Render GPU per frame, median (ms, software) | 122 | 95 |

Observations:
- Memory follows the biome's art set, not the room's size: the same textures serve every
  cell, so 3.3x the area cost 2.7 MB more texture memory.
- Per-frame cost follows what is on screen: draw calls and objects drawn are flat, far
  under the 500 draw-call budget (`technical-preferences.md`).
- Nodes grow with area (one node per terrain cell in this code-built room).
- The cold number of the 3-screen room ran first, with the OS file cache cold; the
  10-screen room's ran second and gained from it. Warm rebuild, an exit into a room of
  the same biome, is about 0.3 s of building plus one software-rendered frame.
- Memory did not grow after a full sweep or after freeing and rebuilding the room.

Screenshots: `long-sweep-000` (start, top band, left) to `long-sweep-599` (bottom band,
left); the Seeker is moved along a fixed path with physics off, so it floats.
