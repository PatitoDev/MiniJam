extends Area2D

class_name Transition

enum DIRECTION {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

@export var moveDirection: DIRECTION = DIRECTION.RIGHT;
@export var songToPlay = UI.SONGS.FOREST;

const SCREEN_SIZE = Vector2(320, 180);

func _on_body_entered(body: Node2D):
	if !(body is Character): 
		return
	var userPos = body.position;
	var camaraPos = UI.Camera.position;
	var offset = SCREEN_SIZE / 2;
	if (
		userPos.x < (camaraPos.x + offset.x)  &&
		userPos.x > (camaraPos.x - offset.x) &&
		userPos.y < (camaraPos.y + offset.y)  &&
		userPos.y > (camaraPos.y - offset.y)
		):
			return;
	var targetCameraPosition: Vector2 = Vector2(0, 0);
	if (body is Character):
		match moveDirection:
			DIRECTION.LEFT:
				targetCameraPosition = Vector2(-1, 0);
			DIRECTION.RIGHT:
				targetCameraPosition = Vector2(1, 0);
			DIRECTION.TOP:
				targetCameraPosition = Vector2(0, -1);
			DIRECTION.BOTTOM:
				targetCameraPosition = Vector2(0, 1);
				
	UI.moveCamereTo(Vector2i(targetCameraPosition.x * SCREEN_SIZE.x, targetCameraPosition.y * SCREEN_SIZE.y));
	UI.setMusic(songToPlay);
