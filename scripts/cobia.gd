extends CharacterBody2D

signal key_press
signal swap_direction(is_on_cooldown : bool) # can be either swapstart and swapend
signal add_score(amount : int)
signal add_corncob
signal damaged

@export var SPEED := 300.0
@export var switch_lane_speed_multiplier := 5
@export var gravity_speed_multiplier := 10
@export var floor_travel_distance := 440
@export var downward_travel_offset := 0
@export var hp := 3

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
var is_idling := false
var is_flashing := false
var is_game_over := false

func _ready():
	# assuming player got placed on the bottom lane
	current_lane = 4
	if !self.visible:
		queue_free()
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_game_over: # man i should've used 
		if not switching_lane:
			if Input.is_action_just_pressed("swap_direction"):
				key_press.emit("z (switch)")
				if can_swap_direction:
					$TimeBeforeIdle.stop()
					is_idling = false
					swap_direction.emit(true)
					can_swap_direction = false
					$FlipCooldown.start()
					switch_direction()
					$ChangeDirection.play()
			elif Input.is_action_just_pressed("switch_lane_up"):
				key_press.emit("c (up)")
				if current_lane > top_and_bottom_lane.min():
					posneg = Vector2.UP.y # -1
					switching_lane = true
					collision.disabled = true
					switch_lane_target_y = self.position.y - floor_travel_distance
					current_lane -= 1
					$MoveLane.play()
			elif Input.is_action_just_pressed("switch_lane_down"):
				key_press.emit("x (down)")
				if current_lane < top_and_bottom_lane.max():
					posneg = Vector2.DOWN.y # -1
					switching_lane = true
					collision.disabled = true
					switch_lane_target_y = self.position.y + floor_travel_distance + downward_travel_offset
					current_lane += 1
					$MoveLane.play()
				
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
		$CobiaHurt.flip_h = false
	else: # right
		current_direction = "left"
		sprite.flip_h = true
		$CobiaHurt.flip_h = true

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
	if not is_game_over:
		match (previous_anim):
			"run":
				sprite.play("idle")
				$TimeBeforeIdle.start()
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

func hurt_flash():
	is_flashing = true
	var shadermat : ShaderMaterial = sprite.get_material()
	shadermat.set_shader_parameter("active", true)
	$CobiaSprite.hide()
	$CobiaHurt.show()
	$FlashEndTimer.start()
	await get_tree().create_timer(0.5, true, true).timeout
	$CobiaSprite.show()
	$CobiaHurt.hide()
	
func _on_flash_end_timer_timeout() -> void:
	var shadermat : ShaderMaterial = sprite.get_material()
	shadermat.set_shader_parameter("active", false)
	is_flashing = false

func handle_colliding(body : Node2D, direction_that_can_take_damage : String):
	if not is_game_over:
		if current_direction == direction_that_can_take_damage: # collide from front
			if body.is_in_group("corncob"):
				add_corncob.emit()
				body.queue_free()
				$CollectSeed.play()
			else:
				if not is_idling:
					add_score.emit(1)
					body.trigger_death(direction_that_can_take_damage)
					$EnemyHurt.play()
		else:
			if !body.is_in_group("corncob") and not is_flashing and not is_game_over: # collide from behind
			# if not (body.is_in_group("corncob") or is_flashing or is_game_over): # someone says it should be this
				hp -= 1
				if hp <= 0:
					hp = 0
					is_game_over = true
					sprite.play("death")
					$Death.play()
				else:
					hurt_flash()
					$GotDamaged.play()
				damaged.emit()
			
func _on_right_detector_body_entered(body: Node2D) -> void: # only enemy are on this detector's mask
	handle_colliding(body, "right")

func _on_left_detector_body_entered(body: Node2D) -> void:# only enemy are on this detector's mask
	handle_colliding(body, "left")

func _on_time_before_idle_timeout() -> void:
	is_idling = true # cannot dash over enemy
