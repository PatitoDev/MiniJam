extends Node2D

enum SIZE {
	MINI,
	NORMAL
}

@export var key: String = 'E';
@export var size: SIZE = SIZE.NORMAL;
@onready var font = preload("res://Fonts/Pixellari.ttf");
	
func _ready():
	var settings = LabelSettings.new();
	settings.font = font;
	font.antialiasing = false;
	settings.font_color = Color.from_string('#4d234a', Color.BLACK);
	$Label.text = key;
	if (size == SIZE.NORMAL):
		$KeyMini.visible = false;
		$Key.visible = true;
		settings.font_size = 16;
	else:
		$KeyMini.visible = true;
		$Key.visible = false;
		settings.font_size = 8;
	$Label.label_settings = settings;
