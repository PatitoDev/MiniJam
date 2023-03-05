extends Node2D

enum SIZE {
	MINI,
	NORMAL
}

@export var isInitiallyVisible = false;
@export var key: String = 'E';
@export var size: SIZE = SIZE.NORMAL;
@onready var font = preload("res://Fonts/Pixellari.ttf");
@onready var label = $KeyGroup/Label;
@onready var normalKeySprite = $KeyGroup/Key;
@onready var miniKeySprite = $KeyGroup/KeyMini;
@onready var keyGroup = $KeyGroup;
var isShowing = false;

func _ready():
	$KeyGroup.visible = isInitiallyVisible;
	if (isInitiallyVisible):
		$AnimationPlayer.play("IDLE");
	var settings = LabelSettings.new();
	settings.font = font;
	font.antialiasing = false;
	settings.font_color = Color.from_string('#4d234a', Color.BLACK);
	label.text = key;
	if (size == SIZE.NORMAL):
		miniKeySprite.visible = false;
		normalKeySprite.visible = true;
		settings.font_size = 16;
	else:
		miniKeySprite.visible = true;
		normalKeySprite.visible = false;
		settings.font_size = 8;
	label.label_settings = settings;

func showKey():
	isShowing = true;
	$AnimationPlayer.play("Show");

func hideKey():
	if (isShowing):
		isShowing = false;
		$AnimationPlayer.play("Hide");

func onFinishShow():
	$AnimationPlayer.play("IDLE");
