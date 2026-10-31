extends CharacterBody3D

const WALK_SPEED := 4.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.0022
const TOUCH_LOOK_SENSITIVITY := 0.0035

var has_entrance_key := false
var camera: Camera3D
var prompt_label: Label
var touch_controls := false

func _ready() -> void:
    touch_controls = OS.has_feature("mobile")
    if not touch_controls:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    camera = Camera3D.new()
    camera.position = Vector3(0, 0.55, 0)
    camera.current = true
    add_child(camera)
    var ray := RayCast3D.new()
    ray.name = "InteractRay"
    ray.target_position = Vector3(0, 0, -3.0)
    ray.enabled = true
    ray.collide_with_areas = true
    camera.add_child(ray)

    var canvas := CanvasLayer.new()
    get_tree().current_scene.add_child(canvas)
    prompt_label = Label.new()
    prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt_label.position = Vector2(-260, -100)
    prompt_label.size = Vector2(520, 42)
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 18)
    prompt_label.add_theme_color_override("font_color", Color.WHITE)
    canvas.add_child(prompt_label)
    var crosshair := Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-8, -18)
    crosshair.add_theme_font_size_override("font_size", 24)
    canvas.add_child(crosshair)
    if touch_controls:
        _create_touch_controls(canvas)

func _create_touch_controls(canvas: CanvasLayer) -> void:
    _add_touch_button(canvas, "◀", "move_left", Vector2(24, -126), Vector2(76, 64), Control.PRESET_BOTTOM_LEFT)
    _add_touch_button(canvas, "▶", "move_right", Vector2(184, -126), Vector2(76, 64), Control.PRESET_BOTTOM_LEFT)
    _add_touch_button(canvas, "▲", "move_forward", Vector2(104, -194), Vector2(76, 64), Control.PRESET_BOTTOM_LEFT)
    _add_touch_button(canvas, "▼", "move_backward", Vector2(104, -58), Vector2(76, 54), Control.PRESET_BOTTOM_LEFT)
    _add_touch_button(canvas, "JUMP", "jump", Vector2(-190, -112), Vector2(86, 62), Control.PRESET_BOTTOM_RIGHT, true)
    _add_touch_button(canvas, "INTERACT", "interact", Vector2(-100, -190), Vector2(112, 66), Control.PRESET_BOTTOM_RIGHT, true)
    var note := Label.new()
    note.text = "Drag right side to look around"
    note.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    note.position = Vector2(-250, 18)
    note.add_theme_font_size_override("font_size", 14)
    note.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.8))
    canvas.add_child(note)

func _add_touch_button(canvas: CanvasLayer, caption: String, action: String, offset: Vector2, dimensions: Vector2, preset, one_shot: bool = false) -> void:
    var button := Button.new()
    button.text = caption
    button.set_anchors_preset(preset)
    button.position = offset
    button.size = dimensions
    button.add_theme_font_size_override("font_size", 17)
    button.modulate = Color(1, 1, 1, 0.78)
    button.button_down.connect(func():
        if action == "interact":
            _try_interact()
        else:
            Input.action_press(action)
    )
    button.button_up.connect(func():
        if action != "interact":
            Input.action_release(action)
    )
    canvas.add_child(button)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
    elif event is InputEventScreenDrag:
        var screen_width := get_viewport().get_visible_rect().size.x
        if event.position.x > screen_width * 0.38:
            rotate_y(-event.relative.x * TOUCH_LOOK_SENSITIVITY)
            camera.rotate_x(-event.relative.y * TOUCH_LOOK_SENSITIVITY)
            camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event.is_action_pressed("interact"):
        _try_interact()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * WALK_SPEED
        velocity.z = direction.z * WALK_SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, WALK_SPEED * 5 * delta)
        velocity.z = move_toward(velocity.z, 0, WALK_SPEED * 5 * delta)
    move_and_slide()
    _update_prompt()

func _update_prompt() -> void:
    var ray: RayCast3D = camera.get_node("InteractRay")
    ray.force_raycast_update()
    if ray.is_colliding():
        var target = ray.get_collider()
        if target and target.is_in_group("interactable"):
            prompt_label.text = target.get_prompt(self)
            return
    prompt_label.text = "WASD / touch: Move   Mouse / drag: Look   E / INTERACT: Use"

func _try_interact() -> void:
    var ray: RayCast3D = camera.get_node("InteractRay")
    ray.force_raycast_update()
    if ray.is_colliding():
        var target = ray.get_collider()
        if target and target.is_in_group("interactable"):
            target.interact(self)
