extends Node

var totalCats = 6;
var catsFreed = 0;

func setCatFree():
	catsFreed += 1;
	UI.updateUI();
