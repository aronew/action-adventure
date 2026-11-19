"""Rim tile with its black core cut out, leaving the edge band plus a soft contact
shadow that falls off into the core, so wall fill drawn under it shows through."""
import sys
from PIL import Image, ImageFilter
import numpy as np
src, dst = sys.argv[1], sys.argv[2]
radius = float(sys.argv[3]) if len(sys.argv) > 3 else 28
strength = float(sys.argv[4]) if len(sys.argv) > 4 else 0.9
a = np.array(Image.open(src).convert('RGBA')).astype(float)
mx = a[:, :, :3].max(axis=2)
opaque = a[:, :, 3] >= 250
core = opaque & (mx <= 2)
band = (a[:, :, 3] > 0) & ~core
# Distance-like falloff from the band into the core: blur the band mask.
pad = int(radius * 3)
m = np.pad(band.astype(np.uint8) * 255, pad, mode='edge')
blur = np.array(Image.fromarray(m).filter(ImageFilter.GaussianBlur(radius))).astype(float)[pad:-pad, pad:-pad] / 255
shadow = np.clip(blur * 2.0, 0, 1) * strength
out = a.copy()
out[core, 0:3] = 0
out[core, 3] = shadow[core] * 255
Image.fromarray(out.round().astype(np.uint8)).save(dst)
