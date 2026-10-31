extends StaticBody3D

var opened := false
var opening := false

func get_prompt(player: CharacterBody3D) -> String:
    if opened:
        return "The entrance is open"
    if not player.has_entrance_key:
        return "Locked. Find the entrance key outside."
    return "Press E to unlock and open the Wada"

func interact(player: CharacterBody3D) -> void:
    if opened or opening:
        return
    if not player.has_entrance_key:
        print("The door is locked. Find the key outside.")
        return
    opening = true
    var hinge: Node3D = get_meta("hinge")
    var tween := create_tween()
    tween.tween_property(hinge, "rotation:y", deg_to_rad(-95), 1.2)
    tween.finished.connect(func():
        opened = true
        opening = false
        print("The Wada entrance is open.")
    )
