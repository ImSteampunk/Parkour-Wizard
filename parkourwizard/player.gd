#class_name Player_Character
# classname is a bit worthless atm, it's a consideration for if I want to do multiplayer some day
extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sens:=.25

var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot : Node3D = %CameraPivotPlayer

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion:= (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relate * mouse_sens
		
func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	
