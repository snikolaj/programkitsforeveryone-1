extends Node2D

onready var raycast = $RayCast2D

func _physics_process(delta):
	if raycast.is_colliding(): # if any entity has fallen off the map, kill it
		if raycast.get_collider().has_method("kill"): # kill it if it has a kill method, of course
			raycast.get_collider().call("kill")
