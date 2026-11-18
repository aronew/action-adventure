# Third-party art packs (not in git)

Everything in this folder except this README is gitignored. The Mossy Cavern
licence forbids repackaging or redistributing its assets "no matter how much
they are modified", and this repository is public, so the pack files are
never committed. Download each pack yourself and unzip it into the layout
below.

| Folder | Pack | Source | Licence (as stated on the page, checked 2026-11-18) |
|--------|------|--------|------------------------------------------------------|
| `maaot-brown-cave/` | 2D Brown Cave Assets by Maaot (`CaveAssetsMaaot.zip`, `PlantsAnimated.zip`) | https://maaot.itch.io/2d-browncave-assets | No formal licence. The author says in the comments that it may be used in commercial and monetized games. Name-your-own-price. |
| `maaot-mossy-cavern/` | Mossy Cavern by Maaot (`Mossy Assets.zip`, `Plant Animations.zip`) | https://maaot.itch.io/mossy-cavern | "LICENSE: V0.1. This asset pack can be used in free and commercial projects. You may not repackage, redistribute, or resell the assets, no matter how much they are modified." Credit not required but appreciated. |

## Expected layout

```text
assets/third_party/
├── maaot-brown-cave/
│   ├── Assets 1024 Cave/      # CaveAssetsMaaot.zip
│   └── Vegetation/            # PlantsAnimated.zip
└── maaot-mossy-cavern/
    ├── Mossy Tileset/         # Mossy Assets.zip
    └── Plant Animations/      # Plant Animations.zip (13 animations)
```

## Before shipping

- Confirm the brown cave pack's terms with the author (there is no written licence).
- Credit Maaot in the game's credits for both packs.
- Shipped builds contain the art, which both licences allow. Only the source
  files must stay out of this repository.
