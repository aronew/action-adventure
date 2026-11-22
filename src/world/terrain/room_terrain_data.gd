## The per-room terrain data that tiles cannot hold (ADR-0001): a material per face
## segment, because a one-tile wall may differ on its two sides (terrain pipeline rule 6).
## Later this also holds the placement records, `crack` marks, the dressed baseline and
## the production state (tools spec). A face with no entry is [constant PLAIN].
class_name RoomTerrainData
extends Resource

const PLAIN := &"plain"
const NO_CLING := &"no_cling"

## Material overrides: key [code]Vector3i(cell_x, cell_y, side)[/code] ([enum TerrainBuilder.Side]),
## value the material's name.
@export var face_overrides: Dictionary = {}


## Sets the material of one cell's face. Use [constant PLAIN] to clear an override.
func set_face_material(cell: Vector2i, side: int, material: StringName) -> void:
	var key := Vector3i(cell.x, cell.y, side)
	if material == PLAIN:
		face_overrides.erase(key)
	else:
		face_overrides[key] = material


## The material of [param cell]'s face on [param side].
func material_at(cell: Vector2i, side: int) -> StringName:
	return face_overrides.get(Vector3i(cell.x, cell.y, side), PLAIN)
