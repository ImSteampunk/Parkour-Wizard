#class_name Player_Character
#https://www.youtube.com/watch?v=JlgZtOFMdfc - just stolen from this
extends CharacterBody3D

@onready var pill = $PlayerNormal
@onready var pill_collision = $PlayerCollision
@onready var pill_collision_slide = $PlayerCollisionSlide
@onready var pill_slide = $PlayerSlide


@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sens:=.25

@export_group("Movement")
@export var move_speed := 30.0
@export var acceleration := 10000
@export var jump_impulse := 25

#Doublejump
var coyote_time := 5.0
var double_jump_true := 1
var dashCD := 5.0
var dash_true := 1
var wallrun_true := 0
var wallrun_CD := 5
var lastwallrun := 0
var was_sliding_last_frame := 0
var slide_time := 0

var is_descending := 0

var speed_lock := 0
var locked_in_speed

var _camera_input_direction := Vector2.ZERO
var gravity := -50.0

# Texture
var matwhite = preload("res://white.tres")
var matblue = preload("res://blue.tres")
var matred = preload("res://red.tres")
var matlgreen = preload("res://lightgreen.tres")
var matdgreen = preload("res://darkgreen.tres")
var matpurple = preload("res://purple.tres")
var matorange = preload("res://orange.tres")
var lastmat = matwhite

@onready var _camera_pivot : Node3D = %CameraPivotPlayer
@onready var _camera: Camera3D =%Camera3DPlayer

func _ready() -> void:
	set_wall_min_slide_angle(PI/4)


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
	if is_on_floor() ==  true:
		pill.set_surface_override_material(0,matwhite)
	
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x , -PI/2.3, PI/6)
	
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	$CameraPivotPlayer/SpringArm3D.spring_length=8
	
	#If making it first person set camera.rotation.x to multiply by negative delta
	
	
	var raw_input := Input.get_vector("move_left","move_right","move_forward","move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x 
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	if (move_direction.length()>=.2) and is_on_floor()==true:
		pill.set_surface_override_material(0,matpurple)
	
	
	
	var velocity_y := velocity.y
	velocity.y = 0.0
	
	# Execute moving
	if Input.is_action_just_pressed("dash") and dashCD>=30 and dash_true==1:
		dashCD=-5.0;
		dash_true=0
		lastmat = pill.get_surface_override_material(0)
		
	if Input.is_action_just_pressed("duck") and slide_time<=-30 and is_on_floor():
		slide_time = 20
		
		
	if slide_time >= 0:
		if (was_sliding_last_frame == 0):
			locked_in_speed = move_direction
		pill_collision.set_disabled(true)
		pill_collision_slide.set_disabled(false)
		speed_lock = 1.0
		was_sliding_last_frame = 1
		velocity = velocity.move_toward(locked_in_speed * (move_speed+(3*slide_time)), acceleration * delta)
		slide_time-=1
		pill.visible = false
		pill_slide.visible = true
	else:
		pill_collision.set_disabled(false)
		pill_collision_slide.set_disabled(true)
		speed_lock = 0.0
		if (was_sliding_last_frame==1):
			was_sliding_last_frame = 0
		if (slide_time >= -30):
			slide_time -=1
		pill.visible = true
		pill_slide.visible = false
		velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	
	

	if (dashCD<=0):
		velocity = velocity.move_toward(move_direction * 7000, 7000 * delta)
		pill.set_surface_override_material(0,matblue)
		#print(dashCD)
	elif (dashCD==1):
		pill.set_surface_override_material(0,lastmat)
		
	
	#jump/gravity
	velocity.y = velocity_y + gravity * delta
	
	# for a falling animation, maybe it can be in accordance to how fast you're falling down?
	# <-50 plummet/slam, <-10 regular fall

		
	
	if wallrun_CD>=0 and is_on_wall() and Input.is_action_pressed("wallrun"):
		if lastwallrun==0:
			lastmat = pill.get_surface_override_material(0)
		if Input.is_action_pressed("move_forward"):
			if is_on_floor() == true and lastwallrun==0:
				velocity.y=30
			else:
				velocity.y=10
		else:
			velocity.y=-3
		wallrun_CD-=1
		pill.set_surface_override_material(0,matred)
		wallrun_true=1
	else:
		if (lastwallrun==1):
			pill.set_surface_override_material(0,lastmat)
		wallrun_true=0
		
	lastwallrun=wallrun_true
	
	
	var is_jumping := Input.is_action_just_pressed("single_jump") and coyote_time>=0.0
	if is_jumping:
		velocity.y = jump_impulse
		pill.set_surface_override_material(0,matlgreen)
	var is_double_jumping := Input.is_action_just_pressed("single_jump") and is_on_floor()==false and coyote_time<=-5.0 and double_jump_true==1
	if is_double_jumping:
		double_jump_true = 0
		pill.set_surface_override_material(0,matdgreen)
		velocity.y = jump_impulse
		
	if Input.is_action_just_pressed("descend"):
		is_descending = 1
	if is_descending == 1:
		velocity.y=-50
		pill.set_surface_override_material(0,matorange)
		
	if velocity.y<=-60:
		pill.set_surface_override_material(0,matred)
	
	if Input.is_action_just_pressed("testbutton"):
		velocity.y=100
	
	
	move_and_slide()
	
func _counters() -> void:
	if is_on_floor() == true:
		coyote_time = 5.0
		double_jump_true = 1
		dash_true = 1
		wallrun_CD = 30
		is_descending = 0
	else:
		coyote_time -= 1.0
		
	dashCD+=1
	
	
	
	
		
		
		
		
func _process(delta: float) -> void:
	_counters()
		
		

	
	
