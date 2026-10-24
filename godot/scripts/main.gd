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
const ATTACK_RANGE := 4
const ATTACK_COST := 5.0
const REGEN_COST := 15.0
const MAX_BREACHES := 3
var breaches := 0

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
		elif event.keycode == KEY_Q and not paused and not game_over:
			attack_nearest()
		elif event.keycode == KEY_E and not paused and not game_over:
			if wild_energy >= REGEN_COST:
				wild_energy -= REGEN_COST
				habitat = minf(100.0, habitat + 10.0)
				status = "Sanctuary restored +10 habitat."
			else:
				status = "Need 15 Wild Energy to restore habitat."
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
				breaches += 1
				enemies.remove_at(i)
				status = "A raider breached the sanctuary! -15 habitat."
		if habitat <= 0 or breaches >= MAX_BREACHES:
			game_over = true
			status = "SANCTUARY LOST. Press R to replay."
		elif enemies.is_empty():
			game_over = true
			victory = habitat > 0
			status = "RAID SURVIVED! Sanctuary at %d. Raiders defeated: %d. Press R." % [int(habitat), defeated]
		wild_energy += 1.0
		queue_redraw()

func attack_nearest() -> void:
	if wild_energy < ATTACK_COST:
		status = "Need 5 Wild Energy to attack."
		return
	var target := -1
	var nearest := ATTACK_RANGE + 1
	for i in enemies.size():
		var distance := absi(guardians[selected].x - enemies[i].x) + absi(guardians[selected].y - enemies[i].y)
		if distance <= ATTACK_RANGE and distance < nearest:
			nearest = distance
			target = i
	if target == -1:
		status = "No raider within 4 tiles. Move closer and press Q."
		return
	wild_energy -= ATTACK_COST
	enemies.remove_at(target)
	defeated += 1
	status = "Guardian stopped a raider! Defeated: %d" % defeated
	if enemies.is_empty():
		game_over = true
		victory = true
		status = "VICTORY! All raiders stopped. Press R to replay."

func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(32, 28), "THE LAST WILDS | Habitat: %d | Energy: %d | Raiders: %d | Breaches: %d/%d" % [int(habitat), int(wild_energy), enemies.size(), breaches, MAX_BREACHES], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, Vector2(32, 49), status + " | Q: attack  E: heal  Space: pause  1-3: select  R: restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
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
