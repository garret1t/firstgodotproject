extends Node

var score = 0
var lives = 3

var double_jump_unlocked = false
var grapple_unlocked = true
var reeling_unlocked = true
var swinging_unlocked = true
var max_web_range = 70

@onready var ui: CanvasLayer = %UI
@onready var score_label: Label = %ScoreLabel

func add_point():
	score += 1
	score_label.text = "Score: " + str(score)
	print("Score: " + str(score))

func die():
	lives -= 1
	print("Lives: " + str(lives))
