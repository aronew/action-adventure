"""Reachability checker for text-grid rooms, using the Seeker's measured jump (jump_speed
420: rises 96 px = 2.6 cells, run jump 138 px, dash jump 176 px; a cell is 36 px).

A standing spot is an air cell with collidable rock ('#') under it. From a spot the Seeker
can reach another spot dy rows up (negative) or down, |dx| columns away, if:
  up 2: |dx| <= 3   up 1: |dx| <= 4   level: |dx| <= 4   down k: |dx| <= 4 + k
  with the dash: up 2: 4, up 1: 5, level: 5, down k: 6 + k
and the air between is clear (the take-off column 2 rows up for a rise, the row above the
lower of the two spots across the span, the landing column down for a drop).
"""

SOLID = "#"


def passable(g, x, y):
    if y < 0 or y >= len(g) or x < 0 or x >= len(g[0]):
        return False
    return g[y][x] != SOLID


def standing(g, x, y):
    return passable(g, x, y) and (y + 1 >= len(g) or g[y + 1][x] == SOLID)


def reach_limits(dy, dash):
    if dy <= -3:
        return -1
    if dy == -2:
        return 4 if dash else 3
    if dy == -1 or dy == 0:
        return 5 if dash else 4
    return min((6 if dash else 4) + dy, 9)


def clear(g, x, y, x2, y2):
    lo, hi = sorted((x, x2))
    top = min(y, y2)
    if y2 < y:
        for r in range(y2 - 1, y + 1):
            if not passable(g, x, r):
                return False
    for c in range(lo, hi + 1):
        if not passable(g, c, top) or (c not in (x, x2) and not passable(g, c, top - 1)):
            return False
    if y2 > y:
        for r in range(y, y2 + 1):
            if not passable(g, x2, r):
                return False
    return True


def spots(g):
    return [(x, y) for y in range(len(g)) for x in range(len(g[0])) if standing(g, x, y)]


def reachable(g, starts, dash):
    all_spots = set(spots(g))
    seen = set(s for s in starts if s in all_spots)
    todo = list(seen)
    while todo:
        x, y = todo.pop()
        for (x2, y2) in all_spots:
            if (x2, y2) in seen:
                continue
            dx, dy = abs(x2 - x), y2 - y
            lim = reach_limits(dy, dash)
            if dx <= lim and clear(g, x, y, x2, y2):
                seen.add((x2, y2))
                todo.append((x2, y2))
    return seen


def land(g, x, y):
    """The standing spot an object dropped at air cell (x, y) falls to."""
    while y < len(g) - 1 and passable(g, x, y + 1):
        y += 1
    return (x, y)
