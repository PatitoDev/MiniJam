extends Node2D

enum CHARACTER {
	SITTING_DUCK,
	MINI_FAT_DUCK
}

var isDialogueShowing = false;
@onready var dialogue = $Dialogue/Dialogue/HBoxContainer/DialogueLabel;
@onready var Camera = $Camera;
var visibleCharacters = 0;
var currentTween;
@onready var targetCameraPosition = Camera.position;

func moveCamereTo(target: Vector2):
	targetCameraPosition = Camera.position + target;

func _physics_process(delta):
	Camera.position = Camera.position.move_toward(targetCameraPosition, 4000 * delta);

func createAnimation():
	$Dialogue/Dialogue/HBoxContainer/DialogueLabel.visible_characters = 0;
	if (currentTween != null):
		currentTween.kill();
	currentTween = get_tree().create_tween();
	var characterCount = dialogue.text.length();
	var speed = characterCount / 20;
	currentTween.tween_property($Dialogue/Dialogue/HBoxContainer/DialogueLabel, "visible_characters", characterCount, speed);

func showDialogue(content: String, character: CHARACTER):
	if (isDialogueShowing):
		return;
	
	$DialogueSFX.play();
	$CharacterSFX.play();
	isDialogueShowing = true;
	dialogue.text = content;
	$DialogueAnimationPlayer.play("Show");
	createAnimation();
	
	match character:
		CHARACTER.MINI_FAT_DUCK:
			$Dialogue/Dialogue/HBoxContainer/PanelContainer/MiniFatDuck.visible = true;
			$Dialogue/Dialogue/HBoxContainer/PanelContainer/SittingDuck.visible = false;
		CHARACTER.SITTING_DUCK:
			$Dialogue/Dialogue/HBoxContainer/PanelContainer/MiniFatDuck.visible = false;
			$Dialogue/Dialogue/HBoxContainer/PanelContainer/SittingDuck.visible = true;

func hideDialogue():
	if (isDialogueShowing):
		$DialogueSFX.play();
		isDialogueShowing = false;
		$DialogueAnimationPlayer.play("Hide");
