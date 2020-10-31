extends Control

onready var camera = get_node("../Camera2D")
onready var tux = get_node("../Tux")

onready var score_counter = $ScoreCounter
onready var lives_counter = $LivesCounter

var tux_stats
func _process(delta):
	tux_stats = tux.get_stats()
	set_labels()
	if tux_stats["has_won"]:
		show_restart_button()
	# only way to get current position of smooth camera
	# all other ways follow the camera as it's smoothly moving
	# which is distracting to the player
	set_global_position(camera.get_camera_screen_center()) 

func set_labels(): # sets the values of the labels that it gets from tux
	score_counter.text = String(tux_stats["score"]) # accessing the returned dictionary
	lives_counter.text = String(tux_stats["lives"])

func show_restart_button():
	$RestartButton.visible = true # calling it like this is fine because it's only once
	$WinLabel.visible = true

func _on_RestartButton_pressed():
	tux.kill()
