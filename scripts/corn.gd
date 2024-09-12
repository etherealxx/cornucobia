extends CharacterBody2D

@export var SPEED := 300.0
@export var gravity_speed_multiplier := 10
@export var parabolic_stat : Parabolic
@export var flip_offset : Vector2
@export var sprite : AnimatedSprite2D
@export var default_sprite_facing_left := true

const JUMP_VELOCITY := -400.0
var current_direction := "left"
var on_wall_cooldown := false # can phase wall when true, for spawning
var is_dead := false # can phase wall when true, for spawning
var is_idle := false
#@onready var sprite = $SquirrelSprite

func _ready() -> void:
	$IdleCooldown.start(randf_range(2.5,5))

func _physics_process(delta: float) -> void:
	if not is_dead:
		velocity = Vector2.ZERO
		if not is_idle:
			if not is_on_floor():
				velocity += get_gravity() * delta * gravity_speed_multiplier

			var d : float = Vector2.RIGHT.x if (current_direction == "right") else Vector2.LEFT.x # "left", -1
			velocity.x = d * SPEED
		else: #idle
			pass

	else: # dead
		velocity.y += parabolic_stat.gravity * delta
	
	move_and_slide()
	
	if global_position.y > 2000:
		queue_free()

func adjust_spawn_direction(direction : String):
	if direction == current_direction and default_sprite_facing_left:
		switch_direction()
	else:
		if !default_sprite_facing_left:
			switch_direction()

func switch_direction():
	current_direction = "right" if current_direction == "left" else "left"
	sprite.flip_h = current_direction != "left" if default_sprite_facing_left else current_direction == "left"
	sprite.offset = flip_offset if sprite.flip_h else Vector2(0, 0)
	#if current_direction == "left":
		#current_direction = "right"
		#if default_sprite_facing_left:
			#sprite.flip_h = true
			#sprite.offset = flip_offset
		#else:
			#sprite.flip_h = false
			#sprite.offset = Vector2(0, 0)
	#else:
		#current_direction = "left"
		#if default_sprite_facing_left:
			#sprite.flip_h = false
			#sprite.offset = Vector2(0, 0)
		#else:
			#sprite.flip_h = true
			#sprite.offset = flip_offset

func start_wall_cooldown():
	pass

func trigger_death(from_direction):
	is_dead = true
	set_collision_mask(0)
	set_collision_layer(0)
	var angle_radians = deg_to_rad(parabolic_stat.angle_degrees)
	var d : int = 1 if (from_direction == "right") else -1 # "left"
	velocity.x = d * parabolic_stat.initial_velocity * cos(angle_radians)
	velocity.y = -parabolic_stat.initial_velocity * sin(angle_radians) # Negative because Godot's y-axis is downwards
	sprite.flip_v = true
	sprite.stop()
	
func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("wall") and not on_wall_cooldown and not is_dead:
		switch_direction()

func _on_wall_cooldown_timeout() -> void:
	on_wall_cooldown = false
	if not is_dead:
		set_collision_mask(CollisionCalc.mask([3, 4]))

func stop_idle_cooldown_and_go_idle():
	$IdleCooldown.stop()
	is_idle = true

func _on_idle_cooldown_timeout() -> void:
	if is_idle:
		$IdleCooldown.start(randf_range(2.5,5))
	else:
		$IdleCooldown.start(randf_range(1.0,2.0))
	is_idle = !is_idle
