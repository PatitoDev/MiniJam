extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().size = Vector2i(1920 * 1.5, 1080  * 1.5);
	$AudioPlayer.play(0);
