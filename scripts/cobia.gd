extends CharacterBody2D

signal key_press
signal swap_direction(is_on_cooldown : bool) # can be either swapstart and swapend
signal add_score(amount : int)

@export var SPEED := 300.0
@export var switch_lane_speed_multiplier := 5
@export var gravity_speed_multiplier := 10
@export var floor_travel_distance := 440
@export var downward_travel_offset := 0

@onready var sprite = $CobiaSprite
@onready var collision = $BodyCollision

const JUMP_VELOCITY := -400.0
var current_direction := "right"
var switching_lane := false
var switch_lane_target_y : float
var posneg : float
var top_and_bottom_lane = [1,4]
var current_lane : int
var previous_anim : String
var can_swap_direction := true

func _ready():
	# assuming player got placed on the bottom lane
	current_lane = 4
	if !self.visible:
		queue_free()
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if not switching_lane:
		if Input.is_action_just_pressed("swap_direction"):
			key_press.emit("z (switch)")
			if can_swap_direction:
				swap_direction.emit(true)
				can_swap_direction = false
				$FlipCooldown.start()
				switch_direction()
		elif Input.is_action_just_pressed("switch_lane_up"):
			key_press.emit("c (up)")
			if current_lane > top_and_bottom_lane.min():
				posneg = Vector2.UP.y # -1
				switching_lane = true
				collision.disabled = true
				switch_lane_target_y = self.position.y - floor_travel_distance
				current_lane -= 1
		elif Input.is_action_just_pressed("switch_lane_down"):
			key_press.emit("x (down)")
			if current_lane < top_and_bottom_lane.max():
				posneg = Vector2.DOWN.y # -1
				switching_lane = true
				collision.disabled = true
				switch_lane_target_y = self.position.y + floor_travel_distance + downward_travel_offset
				current_lane += 1
			
		if not is_on_floor():
			velocity += get_gravity() * delta * gravity_speed_multiplier

	else: # switching lane process
		if (self.position.y > switch_lane_target_y and posneg == -1) or (
			self.position.y < switch_lane_target_y and posneg == 1):
			velocity.y = SPEED * switch_lane_speed_multiplier * posneg
		else:
			switching_lane = false
			collision.disabled = false
			switch_lane_target_y = 0

	var d : int = 1 if (current_direction == "right") else -1 # "left"
	#if sprite.get_animation() != "idle":
	# so that it doesn't push past the wall
	if !(switching_lane and (self.position.x < 120 or self.position.x > 950)):
		velocity.x = d * SPEED
			
	move_and_slide()

func switch_and_flip():
	if current_direction == "left":
		current_direction = "right"
		sprite.flip_h = false
	else: # right
		current_direction = "left"
		sprite.flip_h = true

func switch_direction():
	if sprite.get_animation() == "idle":
		previous_anim = "idle"
		switch_and_flip()
		sprite.play("idle_to_run")
	else:
		previous_anim = "flip_run_1"
		sprite.play("flip_run")

func _on_animation_finished():
	#print("prevanim: " + str(previous_anim))
	match (previous_anim):
		"run":
			sprite.play("idle")
		"flip_run_1":
			previous_anim = "flip_run_2"
			switch_and_flip()
			sprite.play_backwards("flip_run")
		"flip_run_2":
			sprite.play("run")
		"idle":
			sprite.play("run")

func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("wall") and sprite.get_animation() != "idle":
		previous_anim = "run"
		sprite.play("run_to_idle")
	pass

func _on_flip_cooldown_timeout() -> void:
	can_swap_direction = true
	swap_direction.emit(false)

func _on_right_detector_body_entered(body: Node2D) -> void: # only enemy are on this detector's mask
	if current_direction == "right":
		add_score.emit(1)
		body.trigger_death("right")

func _on_left_detector_body_entered(body: Node2D) -> void:# only enemy are on this detector's mask
	if current_direction == "left":
		add_score.emit(1)
		body.trigger_death("left")
