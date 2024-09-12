extends CharacterBody2D

@export var SPEED := 300.0
@export var gravity_speed_multiplier := 10
@export var parabolic_stat : Parabolic
const JUMP_VELOCITY := -400.0
var current_direction := "left"
var on_wall_cooldown := false # can phase wall when true, for spawning
var is_dead := false # can phase wall when true, for spawning

@onready var sprite = $SquirrelSprite

func _physics_process(delta: float) -> void:
	if not is_dead:
		velocity = Vector2.ZERO

		if not is_on_floor():
			velocity += get_gravity() * delta * gravity_speed_multiplier

		var d : float = Vector2.RIGHT.x if (current_direction == "right") else Vector2.LEFT.x # "left", -1
		velocity.x = d * SPEED

	else: # dead
		velocity.y += parabolic_stat.gravity * delta
	
	move_and_slide()
	
	if global_position.y > 2000:
		queue_free()

func adjust_spawn_direction(direction : String):
	if direction == current_direction:
		switch_direction()

func switch_direction():
	if current_direction == "left":
		current_direction = "right"
		sprite.flip_h = true
		#sprite.offset = Vector2(-2.475, 0)
	else:
		current_direction = "left"
		sprite.flip_h = false
		#sprite.offset = Vector2(0, 0)

func start_wall_cooldown():
	on_wall_cooldown = true
	set_collision_mask(CollisionCalc.mask([3]))
	$WallCooldown.start()

func trigger_death(from_direction):
	#print("death triggered")
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
