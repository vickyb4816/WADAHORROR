extends Area3D

func get_prompt(_player: CharacterBody3D) -> String:
    return "Press E to pick up the entrance key"

func interact(player: CharacterBody3D) -> void:
    player.has_entrance_key = true
    queue_free()
    print("Entrance key collected.")
