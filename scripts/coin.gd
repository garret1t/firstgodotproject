extends Area2D
@onready var game_manager: Node = %GameManager




func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		game_manager.add_point()
		queue_free()