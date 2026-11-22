## Placement constants for the test rooms' throwaway debug HUDs.
##
## The HUD canvas is the project's 1920 x 1080 base (docs/architecture/
## adr-0002-display-base-and-camera-zoom.md), but these HUDs were laid out for 480 x 270.
## Their positions and sizes are multiplied by [constant SCALE] and their text uses
## [constant FONT_SIZE], at CanvasLayer scale 1: a layer scale would rasterise 8 px text
## and magnify it. A real HUD replaces them (systems index, HUD).
class_name DebugHud
extends RefCounted

## HUD canvas px per game px (the base height / one screen's height).
const SCALE := 4.0
## The text size the old 8 px labels become.
const FONT_SIZE := 32
