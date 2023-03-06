extends Node2D
class_name CatJail

@export var isTrapped = true;

func _ready():
	setIsTrapped(isTrapped);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func setIsTrapped(isTrappedTo: bool):
	isTrapped = isTrappedTo;
	if (!isTrapped):
		$Sfx.play(0);
		GlobalState.setCatFree();
		$Sprite2D.frame = 20;
	else:
		$Sprite2D.frame = 8;
