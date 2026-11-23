"""Draws each Cinderheart room's layout as a PNG map (rock, air, fake walls, markers,
exits) to production/qa/evidence/cinderheart/layout-<room>.png.
Run: python3 tools/level/draw_layouts.py
"""
import json, os
from PIL import Image, ImageDraw

HERE = os.path.dirname(__file__)
OUT = os.path.join(HERE, "..", "..", "production", "qa", "evidence", "cinderheart")
S = 12  # px per cell
COLORS = {"#": (52, 36, 36), ".": (196, 170, 150), "F": (150, 90, 160), "s": (110, 190, 120)}
MARK = {"start": (60, 160, 255), "rest": (90, 220, 120), "enemy": (230, 60, 50),
        "relic": (255, 120, 200), "ability": (255, 210, 40), "gate": (80, 200, 255)}

for room in json.load(open(os.path.join(HERE, "cinderheart_rooms.json"))):
    w, h = room["w"], room["h"]
    img = Image.new("RGB", (w * S, h * S))
    d = ImageDraw.Draw(img)
    cave = room.get("cave_from_col", -1)
    for y, row in enumerate(room["rows"]):
        for x, c in enumerate(row):
            col = COLORS[c]
            if c == "." and cave >= 0 and x >= cave:
                col = (150, 140, 135)  # cave section: the close rock wall behind
            d.rectangle([x * S, y * S, x * S + S - 1, y * S + S - 1], fill=col)
    for e in room["exits"]:
        a, b = e["a"], e["b"]
        if e["side"] in ("left", "right"):
            x = 0 if e["side"] == "left" else (w - 1) * S
            d.rectangle([x, a * S, x + S - 1, (b + 1) * S - 1], fill=(40, 200, 220))
        else:
            y = 0 if e["side"] == "top" else (h - 1) * S
            d.rectangle([a * S, y, (b + 1) * S - 1, y + S - 1], fill=(40, 200, 220))
    for m in room["markers"]:
        cx, cy = m["col"] * S + S // 2, (m["row"] - 1) * S + S // 2
        d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=MARK.get(m["kind"], (255, 255, 255)))
    img.save(os.path.join(OUT, "layout-%s.png" % room["key"]))
    print("layout-%s.png" % room["key"])
