extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var tux_sprite = $Sprite
onready var raycast = $RayCast2D
onready var collision_timer = $CollisionTimer
onready var win_timer = $WinTimer

# variables relating to movement
var velocity = Vector2.ZERO
const SPEED = 125
const JUMP_FORCE = -300
var input_vector = Vector2.ZERO
var speed_multiplier = 1
var jump_multiplier = 1
var gravity = 10

# variables relating to interaction with enemies and the environment 
var lives = 3
var collisions_enabled = true

# variables relating to the score
const COINS_VALUE = 100
const SNOWBALLS_VALUE = 250
const VICTORY_VALUE = 1000
var coins = 0
var snowballs = 0
var victory = false
var score = 0

func _physics_process(delta):
	if victory and win_timer.time_left == 0: 
		# if the player has won and the timer has finished, begin blurring the scene
		get_node("../Camera2D").begin_blur()
	else: 
		# if the timer hasn't finished execute the movement functions - the victory condition is irrelevant
		jump()
		move()
		fall()
	if not victory: 
		# if victory hasn't been achieved, check for inputs and collisions
		# the timer only runs when victory is achieved, so checking for the timer would be redundant 
		get_input_vector()
		check_collisions_enabled() # check if collisions are enabled
		check_for_collisions()
		calculate_score()

func get_input_vector(): # handles input
	input_vector.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) 
	# is easily modifiable, it's possible to add a controller or other controls and slighy change for it to work

func move(): #handles movement
	# the difference between the input vector and velocity is important for adding speed-affecting differences later
	if input_vector != Vector2.ZERO: # only deals with movement in the x-axis
		velocity.x = input_vector.x * SPEED * speed_multiplier # possible to add speed boosts later
		animation_player.play("walk") # is overwritten later by the fall function, so it never displays during the jump
		change_direction()
	else: 
		velocity.x = 0
		animation_player.play("idle")
	move_and_slide(velocity, Vector2(0, -1)) # delta is automatically added

func change_direction(): # handles change in direction
	if input_vector.x > 0: # if going in a positive direction, don't flip
		tux_sprite.flip_h = false
	else:
		tux_sprite.flip_h = true

func fall(): # handles gravity 
	if !is_on_floor(): # if he's falling, apply gravity (increase acceleration)
		velocity.y += gravity
		animation_player.play("jump")
		
		if is_on_ceiling(): # tux loses momentum if he hits the ceiling
			velocity.y = gravity
	else:
		velocity.y = gravity # if he's standing, make him stick to the ground by constantly applying gravity

func jump(): # handles jumping
	if Input.is_action_pressed("ui_up"):
		if is_on_floor(): # only jump when on a floor
			velocity.y = JUMP_FORCE * jump_multiplier

func check_collisions_enabled(): # checks the status of the collision timer
	if !collisions_enabled and collision_timer.time_left == 0:
		collisions_enabled = true

func check_for_collisions(): # handles collisions
	if collisions_enabled:
		if get_slide_count() > 0: # gets collisions after move_and_slide
			for i in range (0, get_slide_count()):
				var col = get_slide_collision(i)
				check_enemy_collision(col.collider) # compares the collider to a list of enemies

func check_enemy_collision(enemy_type): # compares colliders to enemies, currently only 1 enemy exists
	if enemy_type.name.substr(0, 8) == "Snowball":
		handle_snowball(enemy_type)

func handle_snowball(enemy_type): # handles the "Snowball" type of enemy
	if enemy_type == raycast.get_collider(): # if the snowball is below the player, kill it
		# it knows if snowball is below the player from the raycast pointed below the player
		enemy_type.kill() # calls the function in the snowball script
		snowballs += 1
	else: # if player hit snowball, remove 1 life
		if lives > 1: # if lives are available, give a grace period to the player
			lives -= 1
			collisions_enabled = false
			collision_timer.start()
		else: # if no lives are available, restart the scene
			kill()

func kill(): # restarts scene
	get_tree().reload_current_scene()

func calculate_score(): # calculates current score
	score = 0
	score += coins * COINS_VALUE
	score += snowballs * SNOWBALLS_VALUE
	if victory:
		score += VICTORY_VALUE

func collect_coin(): # handles collection of coins
	coins += 1

func win(): # handles the completion of the level
	victory = true
	velocity.x = 0
	velocity.y = JUMP_FORCE / 2
	win_timer.start()

func get_stats(): # allows other nodes to access tux's stats
	var stats = {
		"score": score,
		"lives": lives,
		"has_won": victory
	}
	return stats
