extends Sprite2D

var player
func _process(_delta: float) -> void:
	queue_redraw()
func _draw():
	if player:
		draw_line(Vector2(0,0), player.position-position, Color(1, 1, 1), 1)
	pass


func _ready() -> void:
	player = get_parent().get_node("Player")
