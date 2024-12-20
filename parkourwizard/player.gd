#class_name Player_Character
#https://www.youtube.com/watch?v=JlgZtOFMdfc - just stolen from this
extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sens:=.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration :=20

var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot : Node3D = %CameraPivotPlayer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("menu-exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion:= (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sens
		
func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x , -PI/3, PI/6)
	
	_camera_pivot.rotation.y += _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
