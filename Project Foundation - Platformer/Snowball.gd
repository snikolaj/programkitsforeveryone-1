extends KinematicBody2D

onready var raycast = $RayCast2D

var anchor
var dist_from_anchor = 50

const VELOCITY = Vector2(25, 0)
var direction = -1

func _ready(): # sets the anchor around which it patrols
	anchor = self.global_position.x

func _process(delta):
	if raycast.is_colliding(): # flip movement if you're about to fall off a cliff
		if dist_from_anchor < abs(global_position.x - anchor): # if too far from the anchor, flip movement
			flip_movement()
		move_and_collide(VELOCITY * delta * direction)
	else:
		flip_movement()

func flip_movement(): # flip scale and direction
	scale.x = -1 # scale.x updates based on its current state, so you can't use the current state as a reference
	direction *= -1

func kill():
	queue_free()
