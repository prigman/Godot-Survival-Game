extends Resource
class_name ItemData

enum ItemType {
	weapon,
	consumable,
	other
}

@export var name : String
@export_multiline var description : String
var type : ItemType
@export var stackable : bool = false
@export var max_stack : int
@export var icon : Texture
@export var properties : Dictionary
