extends CharacterBody2D

class_name Character

var currentInteractionItem = null;

enum DIRECTION {
	LEFT,
	RIGHT
}

var JUMP_FORCE = -200
var JUMP_RELEASE_FORCE = -200
var MAX_SPEED = 100
var ACCELERATION = 10
var FRICTION = 10
var GRAVITY = 10
var ADDITIONAL_FALL_GRAVITY = 4

const SPEED = 100.0
const JUMP_VELOCITY = -250.0
@onready var catSprite = $Sprite/Cat;
@onready var animation = $Sprite/AnimationTree
@onready var stateMachine = animation["parameters/playback"];

const WALL_JUMP_BOOST = 250;
var direction = DIRECTION.RIGHT;
var jumpCount = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

func _physics_process(delta):
	if (Input.is_action_just_pressed("interact")):
		onInteractionPressed();
	
	var shouldApplyGravity = true;
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right");
	
	if (is_on_wall()):
		print(get_wall_normal());
		input.x = 0;
	
	if input.x > 0:
		catSprite.scale.x = 1;
		direction = DIRECTION.RIGHT;
	elif input.x < 0:
		direction = DIRECTION.LEFT;
		catSprite.scale.x = -1;
	
	if input.x == 0:
		stateMachine.travel("IDLE");
		apply_friction();
		stopWalkAudio();
	else:
		stateMachine.travel("Walk");
		apply_acceleration(input.x);
		playWalkAudio();
		
	if (!is_on_floor()):
		#catSprite.play("JUMP");
		pass
	elif input.x == 0:
		stateMachine.travel("IDLE");
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_FORCE;
	else:
		if (is_on_wall()):
			#catSprite.play("WALL_JUMP");
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = - WALL_JUMP_BOOST;
				if direction == DIRECTION.LEFT:
					velocity.x = WALL_JUMP_BOOST;
				else:
					velocity.x = -WALL_JUMP_BOOST;
			else:
				shouldApplyGravity = false;
		else:
			if Input.is_action_just_pressed("ui_accept") and velocity.y < JUMP_RELEASE_FORCE:
				velocity.y = JUMP_RELEASE_FORCE;
			if velocity.y > 0:
				velocity.y += ADDITIONAL_FALL_GRAVITY;
				
	if (shouldApplyGravity):
		apply_gravity()
	move_and_slide();

func playWalkAudio():
	if (!$AudioStreamPlayer.playing):
		$AudioStreamPlayer.play(0);
		
func stopWalkAudio():
	$AudioStreamPlayer.stop();

func apply_gravity():
	velocity.y += GRAVITY;

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION);
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION);

func onInteractionPressed():
	if (currentInteractionItem is DialogueInteractionZone &&
		!UI.isDialogueShowing):
		$Key.hideKey();
		var character = currentInteractionItem.character;
		var text = currentInteractionItem.dialogueText;
		UI.showDialogue(text, character);
		return;
	
	if (currentInteractionItem is DialogueInteractionZone &&
		UI.isDialogueShowing):
			UI.hideDialogue();
			$Key.showKey();

func _on_collision_area_area_entered(area: Area2D):
	if (area.is_in_group('InteractionZone')):
		$Key.showKey();
		currentInteractionItem = area.get_parent();

func _on_collision_area_area_exited(area):
	if (area.is_in_group('InteractionZone') && currentInteractionItem != null):
		$Key.hideKey();
		currentInteractionItem = null;
		UI.hideDialogue();
