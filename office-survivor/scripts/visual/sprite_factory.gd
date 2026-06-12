class_name SpriteFactory
extends RefCounted

const PIXEL_SCALE := 2
const ICON_PIXEL_SCALE := 3  # 16x16 art → 48x48 crisp upgrade icons

const PALETTE := {
	"a": Color("#ffd700"), "b": Color("#b8860b"), "c": Color("#333333"),
	"d": Color("#ffffff"), "e": Color("#e53e3e"), "f": Color("#742a2a"),
	"g": Color("#48bb78"), "h": Color("#276749"), "i": Color("#e2e8f0"),
	"j": Color("#718096"), "k": Color("#805ad5"), "l": Color("#553c9a"),
	"m": Color("#38b2ac"), "n": Color("#2c7a7b"), "o": Color("#4a5568"),
	"p": Color("#8b7355"), "q": Color("#a08060"), "r": Color("#c4b5a0"),
	"s": Color("#b8a892"), "t": Color("#2d3748"), "u": Color("#1a202c"),
	"v": Color("#3182ce"), "w": Color("#2b6cb0"), "x": Color("#dd6b20"),
	"y": Color("#9b2c2c"), "z": Color("#1a365d"),
	"A": Color("#f5cba7"), "B": Color("#dba878"), "C": Color("#edf2f7"),
	"D": Color("#4299e1"), "E": Color("#c53030"), "F": Color("#4a3728"),
	"G": Color("#2c5282"), "H": Color("#ecc94b"), "I": Color("#1a202c"),
	"J": Color("#fc8181"), "K": Color("#9f7aea"), "L": Color("#68d391"),
}

# 16x16 top-down office worker — head, shirt, tie, dark outline.
const PLAYER_ROWS: Array[String] = [
	"0000000000000000",
	"00000ttttt000000",
	"000ttFFFFFtt0000",
	"00ttAAAAAAAtt000",
	"00tAAABBAABAtt00",
	"00tAAABBAABAtt00",
	"00ttAAAAAAAtt000",
	"000ttCCCCtt00000",
	"000tCCDEECCt0000",
	"000tCCCCCCt00000",
	"0000tCCCCt000000",
	"0000tGGGGt000000",
	"0000tu00ut000000",
	"0000tu00ut000000",
	"00000tuut0000000",
	"0000000000000000",
]

const ENEMY_ROWS := {
	"deadline": [
		"0000000000000000",
		"00000ttttt000000",
		"0000teeeet000000",
		"000teeeeeet00000",
		"000teeeeeet00000",
		"0000teeeet000000",
		"00000tfft0000000",
		"00000tfft0000000",
		"00000tfft0000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"meeting": [
		"0000000000000000",
		"00000ttttt000000",
		"0000tklllkt00000",
		"000tklllllkt0000",
		"000tklllllkt0000",
		"000tklllllkt0000",
		"000tklllllkt0000",
		"0000tklllkt00000",
		"00000tooot000000",
		"00000tooot000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"slack_message": [
		"0000000000000000",
		"0000000000000000",
		"0000tttttt000000",
		"000tmmmmmmt00000",
		"000tmmmmmmt00000",
		"000tmmmmnnt00000",
		"00000tmmmt000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"overdue_report": [
		"0000000000000000",
		"00000ttttt000000",
		"0000teeeet000000",
		"000teeeeeeet0000",
		"000teexxeet00000",
		"000teexxeet00000",
		"0000teeeet000000",
		"00000tfft0000000",
		"00000tfft0000000",
		"00000tfft0000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"micromanager": [
		"0000000000000000",
		"00000ttttt000000",
		"0000tKKKKt000000",
		"000tKAAAKKt00000",
		"000tKAAAKKt00000",
		"0000tCCCCt000000",
		"0000tCEECt000000",
		"00000tGGt0000000",
		"0000tu00ut000000",
		"00000tuut0000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"crunch_time": [
		"0000000000000000",
		"0000tttttttt0000",
		"00ttJJJJJJJJtt00",
		"00tJJJJJJJJJJt00",
		"00tJJJeeJJJJt000",
		"00tJJJeeJJJJt000",
		"00tJJJJJJJJJJt00",
		"00ttJJJJJJJJtt00",
		"0000tuuuut000000",
		"0000tuuuut000000",
		"00000tuut0000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"executive": [
		"0000000000000000",
		"00000ttttt000000",
		"0000tFFFFFtt0000",
		"000tAAAAAAAtt000",
		"000tAAABBAAtt000",
		"000tAAABBAAtt000",
		"0000tIIIItt00000",
		"0000tIHHHIt00000",
		"0000tIIIIIt00000",
		"0000tIIIIIt00000",
		"00000tuut0000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
}

const BOSS_ROWS := {
	"performance_review": [
		"0000000000000000",
		"000tttttttttt000",
		"00tFFFFFFFFFFt00",
		"00tJJJJJJJJJJt00",
		"00tJJeeJJeeJJt00",
		"00tJJJJJJJJJJt00",
		"00tJJJJJJJJJJt00",
		"000tIIIIIIIIIt00",
		"000tIHHHHHHHIt00",
		"000tIIIIIIIIIt00",
		"000tIIIIIIIIIt00",
		"0000tuuuuuut0000",
		"0000tuuuuuut0000",
		"00000tuuuut00000",
		"0000000000000000",
		"0000000000000000",
	],
	"all_hands_chair": [
		"0000000000000000",
		"00tttttttttttt00",
		"0tFFFFFFFFFFFFt0",
		"0tJJJJJJJJJJJJt0",
		"0tJJeeJJJJeeJJt0",
		"0tJJJJJJJJJJJJt0",
		"0tJJJJJJJJJJJJt0",
		"00tIIIIIIIIIIt00",
		"00tIHHHHHHHHIt00",
		"00tIIIIIIIIIIt00",
		"00tIIIIIIIIIIt00",
		"00tzzzzzzzzzzt00",
		"00tzzzzzzzzzzt00",
		"000tzzzzzzzzt000",
		"0000000000000000",
		"0000000000000000",
	],
	"quarterly_review": [
		"0000000000000000",
		"000tttttttttt000",
		"00tFFFFFFFFFFt00",
		"00tJJJJJJJJJJt00",
		"00tJJeeJJeeJJt00",
		"00tJJJJJJJJJJt00",
		"00tJJJJJJJJJJt00",
		"000tIIIIIIIIIt00",
		"000tIEEEEEHHIt00",
		"000tIIIIIIIIIt00",
		"000tIIIIIIIIIt00",
		"0000tuuuuuut0000",
		"0000tuuuuuut0000",
		"00000tuuuut00000",
		"0000000000000000",
		"0000000000000000",
	],
}

const XP_ORB_ROWS: Array[String] = [
	"000000",
	"00tt00",
	"0tvvt0",
	"0tvvt0",
	"00vv00",
	"000000",
]

# 10×10 symmetric ring centered in the 16×16 grid (reads circular on screen).
const DONUT_ROWS: Array[String] = [
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
	"00000xxxxx000000",
	"0000xxxxxxx00000",
	"000xxxxxxxx00000",
	"00xxJJJJJJxx0000",
	"00xJJJttJJJx0000",
	"00xJJJttJJJx0000",
	"00xxJJJJJJxx0000",
	"000xxxxxxxx00000",
	"0000xxxxxxx00000",
	"00000xxxxx000000",
	"0000000000000000",
	"0000000000000000",
	"0000000000000000",
]

const UPGRADE_ICON_ROWS := {
	"stapler": [
		"0000000000000000",
		"0000000000000000",
		"00000ttttttt0000",
		"0000tFFFFFFt0000",
		"0000tFoFFFFt0000",
		"0000tFFFFFFt0000",
		"00000tiiiiit0000",
		"00000tiiiiit0000",
		"000000tooot00000",
		"000000ttttt00000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"coffee": [
		"0000000000000000",
		"0000000000000000",
		"0000000dd0000000",
		"000000d00d000000",
		"000000tBBBtt0000",
		"0000ttFFFFFFFtt0",
		"00tFFFFFFFFt0000",
		"00tFFppppppFFt00",
		"00tFppppppppFt00",
		"00tFFppppppFFt00",
		"00tFFFFFFFFt0000",
		"0000tttttttt0000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"extra_coffee": [
		"0000000000000000",
		"0000000dd0000000",
		"000000d00d000000",
		"000000tBBBtt0000",
		"0000ttFFFFFFFtt0",
		"00tFFFFFFFFt0000",
		"00tFFppppppFFt00",
		"00tFppppppppFt00",
		"00tFFppppppFFt00",
		"00tFFFFFFFFt0000",
		"0000tttttttt0000",
		"0000000HHH000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"email": [
		"0000000000000000",
		"0000000000000000",
		"00000twwwwt00000",
		"0000twwwwwwt0000",
		"0000twCCwwt00000",
		"0000twCCwwt00000",
		"0000twvevet00000",
		"0000twjjjet00000",
		"00000twwwwt00000",
		"000000twwt000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"printer_jam": [
		"0000000000000000",
		"0000000000000000",
		"0000tttttttt0000",
		"000tiiiiiiiit000",
		"000tiiiiiiiit000",
		"000tieeeeiit0000",
		"0000tiiiiit00000",
		"00000tCCt0000000",
		"00000tCCt0000000",
		"000000tt00000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"office_magnet": [
		"0000000000000000",
		"0000000000000000",
		"00000tzzzzt00000",
		"0000tzeeeeet0000",
		"0000tze000et0000",
		"0000tze000et0000",
		"0000tze000et0000",
		"0000tze000et0000",
		"0000tzeeeeet0000",
		"00000tzzzzt00000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"ergonomic_chair": [
		"0000000000000000",
		"0000000000000000",
		"00000tGGGGt00000",
		"00000tGLLGt00000",
		"00000tGGGGt00000",
		"0000tpppppppt000",
		"0000tpuuupupt000",
		"00000tpuuupt0000",
		"000000tFFt000000",
		"000000tFFt000000",
		"00000tuuut000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
	"reply_all": [
		"0000000000000000",
		"0000000000000000",
		"00000twwwwt00000",
		"0000twwwwwwt0000",
		"0000twCCwwt00000",
		"0000twCCwwt00000",
		"00000twwwwt00000",
		"000000twwt000000",
		"00000tvvvt000000",
		"0000tvvvvvt00000",
		"00000tvvt0000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
	],
}

# Legacy alias — weapon icons share upgrade art.
const WEAPON_ICON_ROWS := UPGRADE_ICON_ROWS

const TILE_ROWS := {
	"carpet": [
		"rrrrrrrr",
		"rsrsrsrs",
		"rrrrrrrr",
		"rsrsrsrs",
		"rrrrrrrr",
		"rsrsrsrs",
		"rrrrrrrr",
		"rsrsrsrs",
	],
	"desk": [
		"pppppppp",
		"pqqqqqqp",
		"pqqqqqqp",
		"pqqqqqqp",
		"pqqqqqqp",
		"pqqqqqqp",
		"pppppppp",
		"pppppppp",
	],
}


static func build_texture(rows: Array, scale: int = PIXEL_SCALE) -> ImageTexture:
	if rows.is_empty():
		push_warning("SpriteFactory.build_texture: empty row list")
		return null
	var height: int = rows.size()
	var width: int = 0
	for row in rows:
		if row is String:
			width = maxi(width, row.length())
	if width == 0:
		push_warning("SpriteFactory.build_texture: all rows empty")
		return null
	var image := Image.create(width * scale, height * scale, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in height:
		var row: String = rows[y]
		if row.length() < width:
			push_warning(
				"SpriteFactory.build_texture: row %d is %d chars (expected %d), padding with '0'"
				% [y, row.length(), width]
			)
			row = row + "0".repeat(width - row.length())
		for x in width:
			var ch: String = row[x]
			if ch == "0":
				continue
			var color: Color = PALETTE.get(ch, Color.MAGENTA)
			for sy in scale:
				for sx in scale:
					image.set_pixel(x * scale + sx, y * scale + sy, color)
	return ImageTexture.create_from_image(image)


static func build_solid_texture(color: Color, pixel_size: int = 16, scale: int = PIXEL_SCALE) -> ImageTexture:
	var image := Image.create(pixel_size * scale, pixel_size * scale, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


static func get_player_texture() -> ImageTexture:
	return build_texture(PLAYER_ROWS)


static func get_enemy_texture(enemy_type: String) -> ImageTexture:
	var rows: Array = ENEMY_ROWS.get(enemy_type, ENEMY_ROWS.deadline)
	return build_texture(rows)


static func get_boss_texture(boss_type: String) -> ImageTexture:
	var rows: Array = BOSS_ROWS.get(boss_type, BOSS_ROWS.performance_review)
	return build_texture(rows, 3)


static func get_weapon_icon(weapon_id: String) -> ImageTexture:
	return get_upgrade_icon(weapon_id)


static func get_upgrade_icon(upgrade_id: String) -> ImageTexture:
	var rows: Array = UPGRADE_ICON_ROWS.get(upgrade_id, UPGRADE_ICON_ROWS.stapler)
	return build_texture(rows, ICON_PIXEL_SCALE)


static func get_xp_orb_texture() -> ImageTexture:
	return build_texture(XP_ORB_ROWS, 3)


static func get_donut_texture() -> ImageTexture:
	return build_texture(DONUT_ROWS, 3)


static func get_tile_texture(tile_id: String) -> ImageTexture:
	var rows: Array = TILE_ROWS.get(tile_id, TILE_ROWS.carpet)
	return build_texture(rows, 2)
