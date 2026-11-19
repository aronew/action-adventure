"""Makes the owner's modular rim edges repeat seamlessly.

The modular tiles are crops of continuous sections: TL-T-TR along the top, BL-B-BR along
the bottom, TL-L-BL down the left, TR-R-BR down the right. Each pair of neighbours in the
atlas joins, but a straight edge tile placed beside a copy of itself does not, so a long
floor or wall showed a break every cell.

Every join is made to look like the one the atlas already has between the first two
tiles of a run (corner end | straight start): a straight tile's far end cross-fades into
the corner's far end, and the far corner's near end cross-fades in from the straight
tile's start. Then corner-straight, straight-straight and straight-corner all join.

Usage: loop_rim_edges.py <tiles dir> <out dir> [blend px]
"""
import sys
from pathlib import Path
from PIL import Image
import numpy as np

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
blend = int(sys.argv[3]) if len(sys.argv) > 3 else 160
dst.mkdir(parents=True, exist_ok=True)
TL, T, TR, L, R, BL, B, BR = 0, 1, 2, 7, 9, 14, 15, 16
tiles = {i: np.array(Image.open(src / f"tile-{i:02d}.png").convert('RGBA')).astype(float) / 255
		for i in (TL, T, TR, L, R, BL, B, BR)}
out = {i: t.copy() for i, t in tiles.items()}


def mix(a, b, w):
	"""Premultiplied blend from a (w=0) to b (w=1)."""
	pa = np.concatenate([a[..., :3] * a[..., 3:], a[..., 3:]], axis=-1)
	pb = np.concatenate([b[..., :3] * b[..., 3:], b[..., 3:]], axis=-1)
	m = (1 - w) * pa + w * pb
	alpha = m[..., 3:]
	rgb = np.where(alpha > 1e-6, m[..., :3] / np.maximum(alpha, 1e-6), 0)
	return np.concatenate([rgb, alpha], axis=-1)


ramp = np.linspace(0.0, 1.0, blend)
ramp = ramp * ramp * (3 - 2 * ramp)


def run(first, straight, last, axis):
	"""first-straight-last along axis 1 (x) or 0 (y)."""
	w = ramp[None, :, None] if axis == 1 else ramp[:, None, None]
	end = (slice(None), slice(-blend, None)) if axis == 1 else (slice(-blend, None), slice(None))
	start = (slice(None), slice(0, blend)) if axis == 1 else (slice(0, blend), slice(None))
	# Straight tile's far end -> the first corner's far end (which leads into its start).
	out[straight][end] = mix(tiles[straight][end], tiles[first][end], w)
	# Last corner's near end <- the straight tile's start (what follows that end).
	out[last][start] = mix(tiles[straight][start], out[last][start], w)


run(TL, T, TR, 1)
run(BL, B, BR, 1)
run(TL, L, BL, 0)
run(TR, R, BR, 0)
for i, t in out.items():
	Image.fromarray((t * 255).round().clip(0, 255).astype(np.uint8)).save(dst / f"tile-{i:02d}.png")
