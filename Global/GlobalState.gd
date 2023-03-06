extends Node

var totalCats = 50;
var catsFreed = 0;

func setCatFree():
	catsFreed += 1;
	UI.updateUI();
