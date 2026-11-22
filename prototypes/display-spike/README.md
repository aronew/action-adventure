# Display spike

Sources the stretch and zoom behaviour behind `docs/architecture/adr-0002-display-base-and-camera-zoom.md`
(Godot 4.7.2, 2026-11-22). A scratch project: base 1920 x 1080, `canvas_items`, `keep`, `fractional`, a
`Camera2D` at zoom 4, and a script that resizes the window and prints the total scale and the world pixels
across it. Expected: 480 x 270 world px at every 16:9 size (total scale 4.0 at 1920, 3.0 at 1440, 2.0 at 960).

```bash
cd prototypes/display-spike
xvfb-run -a -s "-screen 0 2600x1500x24" godot --path . --rendering-method gl_compatibility --rendering-driver opengl3 -s res://spike.gd
```

Re-run after any engine upgrade. Not part of the game or the test suite.
