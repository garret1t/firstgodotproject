extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var player: CharacterBody2D = $".."
@onready var game_manager: Node = %GameManager


func _process(_delta: float) -> void:
	 # Get the mouse position in the world space
	var mouse_position = get_global_mouse_position()
	var character_position = player.position
	# Get the vector from the character to the mouse
	var direction = mouse_position - character_position
	
	# Normalize the direction vector to make it a unit vector
	direction = direction.normalized()
	
	# Scale the direction by 64 to set the sprite position
	var target_position = direction * (game_manager.max_web_range - 4)
	
	# Set the sprite's position (assuming the sprite is a child of this node)
	position = target_position

	# Rotate the sprite to face the mouse direction
	rotation = direction.angle()  # Rotate sprite towards the mouse
	
	if not game_manager.grapple_unlocked:
		$Sprite2D.visible = false
	else:
		$Sprite2D.visible = true
