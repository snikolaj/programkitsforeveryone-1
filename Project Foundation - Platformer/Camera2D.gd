extends Camera2D

onready var tux = get_node("../Tux")
const camera_offset = Vector2(75, 50)


onready var blur = $Blur
var blur_amount = 0
var start_blur = false

func _ready():
	blur_amount = 0 # restarts shader because when reloading scene it stays the same
	blur.material.set_shader_param("blur_amount", blur_amount)

func _physics_process(delta):
	move_camera()
	if start_blur: # if the value has been set, begin blurring the scene
		blur_scene()

func move_camera():
	self.global_position.x = tux.global_position.x + camera_offset.x # only move in the x direction
	self.global_position.y = camera_offset.y # after moving, offset it by its initial position

func begin_blur():
	start_blur = true
	blur.modulate.a = 1

func blur_scene(): # uses a shader to blur the scene
	blur_amount = wrapf(blur_amount + 0.04, 0.0, 5.0)
	blur.material.set_shader_param("blur_amount", blur_amount)
	if blur_amount > 0.5:
		blur_amount = 2.0
