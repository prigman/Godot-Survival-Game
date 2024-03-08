extends PanelContainer
class_name InventoryScript

const SLOT_SCENE = preload("res://inventory/inventory_scenes/inventory_slot.tscn")
@onready var grid_container = $MarginContainer/GridContainer

var slot_counter : int

func _set_inventory_data(inventory_data : InventoryData):
	inventory_data.signal_inventory_update.connect(_set_inventory_slots)
	_set_inventory_slots(inventory_data)
	
func _clear_inventory_data(inventory_data : InventoryData):
	inventory_data.signal_inventory_update.disconnect(_set_inventory_slots)

func _set_inventory_slots(inventory_data : InventoryData):
	for child in grid_container.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slots_data:
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		
		if slot_data:
			if slot_data.active_slot_data:
					slot.active_slot_panel.show()
			slot._set_slot_data(slot_data)
			
		if inventory_data.type == inventory_data.InventoryType.quick_slot:
			slot_counter += 1
			slot.slot_number.text = str(slot_counter)
			slot.slot_number.show()
			
		slot.signal_slot_clicked.connect(inventory_data._on_slot_clicked)
	slot_counter = 0
	
func _set_active_slot(inventory_data : InventoryData, new_slot_index : int, last_slot_index : int, new_slot_data : InSlotData, last_slot_data : InSlotData):
	var new_active_slot = grid_container.get_child(new_slot_index)
	var last_active_slot = grid_container.get_child(last_slot_index)
	if new_slot_data and !last_slot_data:
		new_active_slot.active_slot_panel.show()
		new_slot_data.active_slot_data = true
		print("active slot now: %s" % new_slot_data.item.name)
	if new_slot_data and last_slot_data:
		if new_slot_data == last_slot_data:
			new_active_slot.active_slot_panel.hide()
			new_slot_data.active_slot_data = false
			print("active slot hide")
		else:
			last_active_slot.active_slot_panel.hide()
			last_slot_data.active_slot_data = false
			new_active_slot.active_slot_panel.show()
			new_slot_data.active_slot_data = true
			inventory_data.signal_inventory_update.emit(inventory_data)
			print("active slot changed to %s" % new_slot_data.item.name)
	if !new_slot_data and last_slot_data:
		last_active_slot.active_slot_panel.hide()
		last_slot_data.active_slot_data = false
		print("active slot hide")
			
#func _on_item_panel_visibility_changed(inventory_data : InventoryData, last_inventory_data : InventoryData, clicked_slot_index : int, last_slot_index : int, panel_visible : bool):
	#var clicked_slot_data = inventory_data.slots_data[clicked_slot_index]
	#var last_slot_data = inventory_data.slots_data[last_slot_index]
	#if panel_visible:
		#if inventory_data == last_inventory_data:
			#if clicked_slot_data == last_slot_data:
				#clicked_slot.hover_panel.hide()
				#clicked_slot.right_clicked = false
			#elif clicked_slot_data:
				#last_slot.hover_panel.hide()
				#last_slot.right_clicked = false
				#clicked_slot.hover_panel.show()
				#clicked_slot.right_clicked = true
			#elif !clicked_slot_data:
				#last_slot.hover_panel.hide()
				#last_slot.right_clicked = false
		#else:
			#last_slot.hover_panel.hide()
			#last_slot.right_clicked = false
			#clicked_slot = grid_container.get_child(clicked_slot_index)
			##last_slot = grid_container.get_child(last_slot_index)
			#clicked_slot.hover_panel.show()
			#clicked_slot.right_clicked = true
	#if !panel_visible:
		#clicked_slot = grid_container.get_child(clicked_slot_index)
		#last_slot = grid_container.get_child(last_slot_index)
		#if clicked_slot_data:
			#clicked_slot.hover_panel.show()
			#clicked_slot.right_clicked = true
		#elif last_slot_data:
			#last_slot.hover_panel.hide()
			#last_slot.right_clicked = false
