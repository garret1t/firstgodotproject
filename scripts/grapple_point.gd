extends RigidBody2D

var player

var speed:float = 5.0
var attached:bool = false

func _physics_process(_delta: float) -> void:
	queue_redraw()
	if attached:
		pass
	else:
		pass
func _draw():
	
	if player:
		draw_line(Vector2(0,0), player.position-position, Color(1, 1, 1), 1)
	pass


func _ready() -> void:
	player = get_parent().get_node("Player")
	


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("Grapple Collision with " + body.name)
	if body.name == "TileMap":
		print("Tile coordinates of collision is: " + str(body.get_coords_for_body_rid(body_rid)))
		var attached_tile = body.get_cell_tile_data(body.get_coords_for_body_rid(body_rid))
		print("attached to tile" + str(body.get_cell_tile_data(body.get_coords_for_body_rid(body_rid))))
		if attached_tile:
			attached = attached_tile.get_collision_polygons_count(0) > 0	
			rotation = 0
			freeze=true
			contact_monitor =false
			sleeping = true
			print("frozen")
