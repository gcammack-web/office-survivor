extends Node2D

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")

@export var grid_size: Vector2i = Vector2i(80, 45)
@export var tile_size: int = 16

var _carpet_tex: ImageTexture
var _desk_tex: ImageTexture


func _ready() -> void:
	_carpet_tex = SpriteFactory.get_tile_texture("carpet")
	_desk_tex = SpriteFactory.get_tile_texture("desk")
	queue_redraw()


func _draw() -> void:
	var carpet_size := Vector2(_carpet_tex.get_width(), _carpet_tex.get_height())
	for y in grid_size.y:
		for x in grid_size.x:
			var pos := Vector2(x, y) * tile_size
			draw_texture_rect(_carpet_tex, Rect2(pos, carpet_size), false)

	for i in 12:
		var gx := 8 + (i % 4) * 18
		var gy := 6 + int(i / 4) * 12
		var origin := Vector2(gx, gy) * tile_size
		var desk_size := Vector2(_desk_tex.get_width(), _desk_tex.get_height())
		draw_texture_rect(_desk_tex, Rect2(origin, desk_size * Vector2(5, 3)), false)
		draw_texture_rect(_desk_tex, Rect2(origin + Vector2(tile_size * 0.5, tile_size * 0.5), desk_size * Vector2(4, 2)), false)
