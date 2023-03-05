extends CharacterBody2D

class_name Character

var currentInteractionItem = null;

enum DIRECTION {
	LEFT,
	RIGHT
}

enum STATE {
	JUMP,
	FALL,
	IDLE,
	WALK,
	PRE_WALK,
	WALL_WALK,
	WALL_GRAB,
}

var MAX_SPEED = 150
var ACCELERATION = 5

var JUMP_FORCE = -500
var JUMP_RELEASE_FORCE = 300

var FRICTION = 10
var GRAVITY = 10
var ADDITIONAL_FALL_GRAVITY = 4
const WALL_JUMP_BOOST = 250;

const JUMP_VELOCITY = -250.0

@onready var catSprite = $Sprite/Cat;
@onready var animation = $Sprite/AnimationTree
@onready var stateMachine = animation["parameters/playback"];

@onready var stepSfx = preload("res://Sounds/fx_stone_footsteps.ogg");
@onready var jumpSfx = preload("res://Sounds/Jump_20.wav");
@onready var sfxPlayer = $SfxPlayer;
@onready var particles = $ParticleContainer/Particles;
@onready var particlesContainer = $ParticleContainer

var direction = DIRECTION.RIGHT;
var jumpCount = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

func getCurrentState():
	var currentState = stateMachine.get_current_node();
	match currentState:
		'Jump':
			return STATE.JUMP;
		'Fall':
			return STATE.FALL;
		'IDLE':
			return STATE.IDLE;
		'Walk':
			return STATE.WALK;
		'PreWalk':
			return STATE.PRE_WALK;
		'WallWalk':
			return STATE.WALL_WALK;
		'WallGrab':
			return STATE.WALL_GRAB;


func _physics_process(delta):
	var isGrabbingWall = is_on_wall() && Input.is_action_pressed("grab");
	var currentState = getCurrentState();
	
	if (Input.is_action_just_pressed("interact")):
		onInteractionPressed();
	
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right");
	var targetDirection = null;
	if (input.x > 0):
		targetDirection = DIRECTION.RIGHT;
		direction = targetDirection;
		particlesContainer.scale.x = 1;
	elif (input.x < 0):
		targetDirection = DIRECTION.LEFT
		direction = targetDirection;
		particlesContainer.scale.x = -1;
	
	if (is_on_floor() && (input.x == 0 || is_on_wall())):
		stateMachine.travel("IDLE");
		apply_friction();
		stopSfx();
	elif (is_on_floor()):
		stateMachine.travel("Walk")
		playSfx(stepSfx);
	
	if (input.x != 0):
		apply_acceleration(input.x);
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			playSfx(jumpSfx);
			stateMachine.travel("Jump");
			velocity.y = -JUMP_RELEASE_FORCE;
	else:
		if velocity.y > 0:
			if (currentState != STATE.WALL_GRAB || !is_on_wall()):
				stateMachine.travel("Fall");
			velocity.y += ADDITIONAL_FALL_GRAVITY;

	if targetDirection == DIRECTION.RIGHT:
		catSprite.flip_h = false;
	elif targetDirection == DIRECTION.LEFT:
		catSprite.flip_h = true;
	
	# wall grab / jump
	var shouldApplyGravity = true;
	
	var wallNormal = get_wall_normal();
	var wallDirection = DIRECTION.LEFT;
	if (wallNormal.x == 1):
		wallDirection = DIRECTION.RIGHT;
	
	var isFacingWall = (
		(direction == DIRECTION.RIGHT && wallDirection == DIRECTION.LEFT) ||
		(direction == DIRECTION.LEFT && wallDirection == DIRECTION.RIGHT)
	);
	#double jump condition
	
	var isPressingOnWall = (
		(targetDirection == DIRECTION.RIGHT && wallDirection == DIRECTION.LEFT) ||
		(targetDirection == DIRECTION.LEFT && wallDirection == DIRECTION.RIGHT)
	);
	
	particles.emitting = false;
	# Wall fall friction state
	if ((currentState == STATE.FALL || currentState == STATE.WALL_GRAB) && is_on_wall()):
		if (is_on_floor()):
			stateMachine.travel("IDLE");
		else:			
			particles.emitting = isPressingOnWall;
			if (isPressingOnWall):
				stateMachine.travel("WallGrab");
				velocity.y -= GRAVITY * 1;
			
			## if falling and im pressing the key facing the wall, fall with friction;
			## if pressing opposite key + jump, jump with extra boost
			pass
			# if falling and pressing grab, grab once
			# and stop falling. cancel gravity
			#move up down, based on input + animation
	# wall grab static state
	if (isGrabbingWall):
		var verticalDirection = Input.get_axis("ui_up", "ui_down");
		catSprite.flip_h = (wallDirection != DIRECTION.LEFT);
			
		if (verticalDirection == 0):
			velocity.y = 0;
			stateMachine.travel("WallGrab");
		elif (verticalDirection > 0):
			stateMachine.travel("WallWalk");
			velocity.y = 50;
		elif (verticalDirection < 0):
			stateMachine.travel("WallWalk");
			velocity.y = -50;
		shouldApplyGravity = false;
	
	if (Input.is_action_just_released("grab")):
		shouldApplyGravity = true;
	
	if (shouldApplyGravity):
		apply_gravity()
	# wall jump
	if (
		is_on_wall() && !is_on_floor() &&
		Input.is_action_just_pressed("ui_accept")):
		stateMachine.travel("Jump");
		velocity = Vector2(-100, -300);
		if (isPressingOnWall || isGrabbingWall):
			velocity -= Vector2(200, 0);
		
		if (wallDirection == DIRECTION.RIGHT):
			velocity.x *= -1;
		
	move_and_slide();

func apply_gravity():
	velocity.y += GRAVITY;

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION);
	
func apply_acceleration(directionAsInt: int):
	print(velocity.x);
	velocity.x = move_toward(velocity.x, MAX_SPEED * directionAsInt, ACCELERATION);

func playSfx(sound: AudioStream):
	var isSameStream = sound == sfxPlayer.stream;
	if (!isSameStream || !sfxPlayer.playing):
		sfxPlayer.stream = sound;
		sfxPlayer.play(0);
		
func stopSfx():
	sfxPlayer.stop();

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
