extends Node2D

const W := 32
const H := 24
const CELL := 24
const OFFSET := Vector2(32, 64)
var guardians := [Vector2i(8, 10), Vector2i(10, 12), Vector2i(8, 14)]
var selected := 0
var paused := false
var elapsed := 0.0
var habitat := 100.0
var wild_energy := 30.0
var enemies := [Vector2i(29, 8), Vector2i(29, 12), Vector2i(29, 16)]
var status := "Defend the sanctuary. Click a guardian, right-click to move."
var game_over := false
var victory := false
var defeated := 0
const SANCTUARY_X := 5
const DAMAGE_PER_RAIDER := 15.0

func _ready() -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			if not game_over:
				paused = not paused
				status = "Paused" if paused else "Defend the sanctuary"
		elif event.keycode >= KEY_1 and event.keycode <= KEY_3:
			selected = event.keycode - KEY_1
		elif event.keycode == KEY_R:
			get_tree().reload_current_scene()
		queue_redraw()
	if event is InputEventMouseButton and event.pressed:
		var cell := Vector2i((event.position - OFFSET) / CELL)
		if cell.x < 0 or cell.y < 0 or cell.x >= W or cell.y >= H:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			for i in guardians.size():
				if guardians[i] == cell:
					selected = i
					break
		elif event.button_index == MOUSE_BUTTON_RIGHT and not paused and not game_over:
			guardians[selected] = cell
			status = "Guardian moved to (%d, %d)" % [cell.x, cell.y]
		queue_redraw()

func _process(delta: float) -> void:
	if paused or game_over:
		return
	elapsed += delta
	while elapsed >= 1.0 and not game_over:
		elapsed -= 1.0
		for i in range(enemies.size() - 1, -1, -1):
			enemies[i].x -= 1
			if enemies[i].x <= SANCTUARY_X:
				habitat = maxf(0.0, habitat - DAMAGE_PER_RAIDER)
				enemies.remove_at(i)
				status = "A raider breached the sanctuary! -15 habitat."
		if habitat <= 0:
			game_over = true
			status = "SANCTUARY LOST. Press R to replay."
		elif enemies.is_empty():
			game_over = true
			victory = habitat > 0
			status = "RAID SURVIVED! Sanctuary at %d. Press R to replay." % int(habitat)
		wild_energy += 1.0
		queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(32, 28), "THE LAST WILDS  |  Sanctuary: %d  |  Wild Energy: %d  |  Raiders: %d" % [int(habitat), int(wild_energy), enemies.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, Vector2(32, 49), status + "  |  Space: pause  1-3: select  R: restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	for y in H:
		for x in W:
			var color := Color("#264c32") if (x + y) % 2 == 0 else Color("#31583a")
			if x == 5:
				color = Color("#547a50")
			if y == 12 and x > 16:
				color = Color("#80684c")
			draw_rect(Rect2(OFFSET + Vector2(x, y) * CELL, Vector2(CELL - 1, CELL - 1)), color)
	for i in guardians.size():
		var center := OFFSET + Vector2(guardians[i]) * CELL + Vector2.ONE * CELL / 2.0
		draw_circle(center, 9.0, [Color("#8ee07a"), Color("#e7b563"), Color("#a4a4ef")][i])
		if selected == i:
			draw_arc(center, 12.0, 0, TAU, 32, Color.WHITE, 2.0)
	for i in enemies.size():
		var center := OFFSET + Vector2(enemies[i]) * CELL + Vector2.ONE * CELL / 2.0
		draw_circle(center, 8.0, Color("#e36b59"))
