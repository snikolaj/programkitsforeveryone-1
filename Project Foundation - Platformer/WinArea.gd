extends Area2D

func _on_WinArea_body_entered(body): # if the WinArea has been entered, the player has won
	if body.has_method("win"):
		body.win()
