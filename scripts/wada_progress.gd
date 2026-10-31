extends Node
class_name WadaProgress

signal inventory_changed
signal objective_changed(text: String)
signal map_revealed(room_id: String)

var inventory: Array[String] = []
var discovered_rooms: Array[String] = ["entrance"]
var current_objective := "Find the golden entrance key outside the Wada."
var clues_found := 0

func has_item(item_id: String) -> bool:
    return inventory.has(item_id)

func add_item(item_id: String) -> void:
    if inventory.has(item_id):
        return
    inventory.append(item_id)
    inventory_changed.emit()

func remove_item(item_id: String) -> void:
    inventory.erase(item_id)
    inventory_changed.emit()

func reveal_room(room_id: String) -> void:
    if discovered_rooms.has(room_id):
        return
    discovered_rooms.append(room_id)
    map_revealed.emit(room_id)

func set_objective(text: String) -> void:
    current_objective = text
    objective_changed.emit(text)

func add_clue() -> void:
    clues_found += 1
