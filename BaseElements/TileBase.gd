extends Node2D


func _on_death_area_body_entered(body: Node2D):
	if (body is Character):
		body.position = $Spawn.global_position;
		body.death();

func _ready():
	var children = get_children();
	for child in children:
		if (child is Transition):
			child.connect("body_entered", onBodyTransitionEntered);

func onBodyTransitionEntered(body:Node2D):
	if (body is Character):
		$Spawn.global_position = body.position;
