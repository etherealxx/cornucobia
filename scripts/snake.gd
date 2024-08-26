extends CharacterBody2D

@export var SPEED := 300.0
@export var gravity_speed_multiplier := 10
const JUMP_VELOCITY := -400.0
var current_direction := "left"

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_speed_multiplier

	var d : float = Vector2.RIGHT.x if (current_direction == "right") else Vector2.LEFT.x # "left", -1
	velocity.x = d * SPEED

	move_and_slide()

func switch_direction():
	if current_direction == "left":
		current_direction = "right"
		$SnakeSprite.flip_h = true
		$SnakeSprite.offset = Vector2(-2.475, 0)
	else:
		current_direction = "left"
		$SnakeSprite.flip_h = false
		$SnakeSprite.offset = Vector2(0, 0)
	pass

func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("wall"):
		switch_direction()
