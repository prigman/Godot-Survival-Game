extends Control
class_name InventoryInterface
signal signal_drop_slot_data(slot_data : InSlotData)
signal signal_force_close
var grabbed_slot_data : InSlotData
var external_inventory_owner

@onready var player_inventory = %PlayerInventory
@onready var player_quick_slot = %PlayerQuickSlot
@onready var grabbed_slot = %GrabbedSlot
@onready var external_inventory = %ExternalInventory

func _physics_process(_delta):
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)
	
	if external_inventory_owner \
		and external_inventory_owner.global_position.distance_to(Global.get_global_position()) > 4:
			signal_force_close.emit()

func _set_player_inventory_data(inventory_data : InventoryData):
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	player_inventory._set_inventory_data(inventory_data)
	
func _set_quick_slot_data(inventory_data : InventoryData):
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	player_quick_slot._set_inventory_data(inventory_data)

func _set_external_inventory(inventory_owner):
	external_inventory_owner = inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.signal_inventory_interact.connect(_on_inventory_interact)
	external_inventory._set_inventory_data(inventory_data)
	
	external_inventory.show()
	
func _clear_external_inventory():
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.signal_inventory_interact.disconnect(_on_inventory_interact)
		external_inventory._clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null
	
func _on_inventory_interact(inventory_data : InventoryData, index : int, button : int):
	#print("%s %s %s" % [inventory_data, index, button])
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data._grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data._drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data._drop_single_slot_data(grabbed_slot_data, index)
	_update_grabbed_slot()


func _update_grabbed_slot():
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot._set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func _on_gui_input(event):
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				signal_drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
		_update_grabbed_slot()


func _on_visibility_changed():
	if not visible and grabbed_slot_data:
		signal_drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		_update_grabbed_slot()