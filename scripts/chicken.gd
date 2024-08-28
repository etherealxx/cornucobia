extends CharacterBody2D

signal key_press

@export var SPEED := 300.0
@export var switch_lane_speed_multiplier := 5
@export var gravity_speed_multiplier := 10
const JUMP_VELOCITY := -400.0
var current_direction := "right"
var switching_lane := false
var switch_lane_target_y
var posneg
var top_and_bottom_lane = [1,4]
var current_lane

func _ready():
	# assuming player got placed on the bottom lane
	current_lane = 4
	if !self.visible:
		queue_free()

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if not switching_lane:
		if Input.is_action_just_pressed("swap_direction"):
			key_press.emit("z (switch)")
			switch_direction()
		elif Input.is_action_just_pressed("switch_lane_up"):
			key_press.emit("c (up)")
			if current_lane > top_and_bottom_lane.min():
				posneg = Vector2.UP.y # -1
				switching_lane = true
				$BodyCollision.disabled = true
				switch_lane_target_y = self.position.y - 440
				current_lane -= 1
		elif Input.is_action_just_pressed("switch_lane_down"):
			key_press.emit("x (down)")
			if current_lane < top_and_bottom_lane.max():
				posneg = Vector2.DOWN.y # -1
				switching_lane = true
				$BodyCollision.disabled = true
				switch_lane_target_y = self.position.y + 440
				current_lane += 1
			
	## Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta * gravity_speed_multiplier
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		var d : int = 1 if (current_direction == "right") else -1 # "left"
		velocity.x = d * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		#if self.position.y != switch_lane_target_y:
		if (self.position.y > switch_lane_target_y and posneg == -1) or (
			self.position.y < switch_lane_target_y and posneg == 1):
			velocity.y = SPEED * switch_lane_speed_multiplier * posneg
		else:
			switching_lane = false
			$BodyCollision.disabled = false
			switch_lane_target_y = 0

	move_and_slide()

func switch_direction():
	if current_direction == "left":
		current_direction = "right"
		$ChickenSprite.flip_h = true
		$ChickenSprite.offset = Vector2(2.85, 0)
	else:
		current_direction = "left"
		$ChickenSprite.flip_h = false
		$ChickenSprite.offset = Vector2(0, 0)

func _on_wall_detector_body_entered(body: Node2D) -> void:
	## Uncomment for auto turn around when colliding with wall
	#if body.is_in_group("wall"):
		#switch_direction()
	pass
