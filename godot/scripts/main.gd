extends Node2D

# The Last Wilds — vertical slice. All art is original, deterministic vector art.
const W := 32
const H := 24
const CELL := 24
const ORIGIN := Vector2(42, 108)
const BOUNDARY := 5
const TICK := 0.75
const MAX_BREACHES := 3
const GUARDIAN_NAMES := ["ROOTLING", "BRUTE", "SPITTER"]
const GUARDIAN_COLORS := [Color("#9bdf8a"), Color("#e8b876"), Color("#b4a6ed")]
const INK := Color("#e6e7d5")
const GOLD := Color("#f0c57b")
const PANEL := Color("#14251f")
const FOREST := Color("#254936")
const DARK := Color("#172d25")

var guardians: Array[Vector2i] = [Vector2i(9, 8), Vector2i(9, 12), Vector2i(9, 16)]
var enemies: Array[Dictionary] = []
var selected := 0
var paused := false
var game_over := false
var victory := false
var elapsed := 0.0
var seconds := 0
var habitat := 100
var energy := 35
var breaches := 0
var defeated := 0
var wave := 0
var spawned := 0
var snare_tiles: Array[Vector2i] = []
var ability_cooldowns := [0, 0, 0]
var status := "The forest remembers. Stop the settlers before they reach the heart."
var status_time := 0.0

func _ready() -> void:
    _spawn_wave()
    queue_redraw()

func _spawn_wave() -> void:
    wave += 1
    var rows := [8, 12, 16]
    for i in range(3):
        enemies.append({"pos": Vector2i(30 + i % 2, rows[i]), "hp": 2 if wave > 1 else 1, "kind": i})
        spawned += 1
    _message("WAVE %d  /  Humans enter the old forest." % wave)

func _message(message: String) -> void:
    status = message
    status_time = 4.0

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_R:
            get_tree().reload_current_scene()
            return
        if event.keycode == KEY_SPACE and not game_over:
            paused = not paused
            _message("THE WORLD IS STILL" if paused else "THE FOREST AWAKENS")
        elif event.keycode >= KEY_1 and event.keycode <= KEY_3:
            selected = event.keycode - KEY_1
            _message("%s selected." % GUARDIAN_NAMES[selected])
        elif event.keycode == KEY_Q and not paused and not game_over:
            _attack()
        elif event.keycode == KEY_E and not paused and not game_over:
            _ability()
        queue_redraw()
    if event is InputEventMouseButton and event.pressed:
        var cell := Vector2i(floori((event.position.x - ORIGIN.x) / CELL), floori((event.position.y - ORIGIN.y) / CELL))
        if cell.x < 0 or cell.y < 0 or cell.x >= W or cell.y >= H:
            return
        if event.button_index == MOUSE_BUTTON_LEFT:
            for i in range(guardians.size()):
                if guardians[i] == cell:
                    selected = i
                    _message("%s selected." % GUARDIAN_NAMES[i])
        elif event.button_index == MOUSE_BUTTON_RIGHT and not paused and not game_over:
            if cell.x > BOUNDARY and not _enemy_at(cell):
                guardians[selected] = cell
                _message("%s moves to defend the wilds." % GUARDIAN_NAMES[selected])
            else:
                _message("The guardian cannot move there.")
        queue_redraw()

func _enemy_at(cell: Vector2i) -> bool:
    for enemy in enemies:
        if enemy["pos"] == cell:
            return true
    return false

func _nearest_target(radius: int) -> int:
    var target := -1
    var best := radius + 1
    for i in range(enemies.size()):
        var p: Vector2i = enemies[i]["pos"]
        var distance := absi(guardians[selected].x - p.x) + absi(guardians[selected].y - p.y)
        if distance <= radius and distance < best:
            best = distance
            target = i
    return target

func _damage_enemy(index: int, damage: int) -> void:
    var hp: int = enemies[index]["hp"]
    hp -= damage
    if hp <= 0:
        enemies.remove_at(index)
        defeated += 1
        energy = mini(100, energy + 3)
    else:
        enemies[index]["hp"] = hp

func _attack() -> void:
    if energy < 5:
        _message("Not enough Wild Energy. Need 5.")
        return
    var target := _nearest_target(4)
    if target == -1:
        _message("No human within four tiles. Reposition your guardian.")
        return
    energy -= 5
    _damage_enemy(target, 1)
    _message("%s strikes! The forest fights back." % GUARDIAN_NAMES[selected])
    _check_end()

func _ability() -> void:
    if ability_cooldowns[selected] > 0:
        _message("Ability recovering: %d ticks." % ability_cooldowns[selected])
        return
    if energy < 12:
        _message("Need 12 Wild Energy for a guardian ability.")
        return
    energy -= 12
    ability_cooldowns[selected] = 7
    match selected:
        0:
            snare_tiles.clear()
            for x in range(guardians[0].x - 2, guardians[0].x + 3):
                if x > BOUNDARY and x < W:
                    snare_tiles.append(Vector2i(x, guardians[0].y))
            _message("ROOTLING  /  Roots bind the invasion lane for seven ticks.")
        1:
            var hits := 0
            for i in range(enemies.size() - 1, -1, -1):
                var p: Vector2i = enemies[i]["pos"]
                if absi(p.x - guardians[1].x) + absi(p.y - guardians[1].y) <= 3:
                    _damage_enemy(i, 2)
                    hits += 1
            _message("BRUTE  /  Earthshatter struck %d intruders." % hits)
        2:
            var hits := 0
            for i in range(enemies.size() - 1, -1, -1):
                var p: Vector2i = enemies[i]["pos"]
                if absi(p.x - guardians[2].x) + absi(p.y - guardians[2].y) <= 6:
                    _damage_enemy(i, 1)
                    hits += 1
            _message("SPITTER  /  Thorn volley hit %d intruders." % hits)
    _check_end()

func _process(delta: float) -> void:
    if paused or game_over:
        return
    if status_time > 0:
        status_time -= delta
    elapsed += delta
    if elapsed < TICK:
        return
    elapsed -= TICK
    seconds += 1
    energy = mini(100, energy + 1)
    for i in range(ability_cooldowns.size()):
        ability_cooldowns[i] = maxi(0, ability_cooldowns[i] - 1)
    if ability_cooldowns[0] == 0:
        snare_tiles.clear()
    for i in range(enemies.size() - 1, -1, -1):
        var p: Vector2i = enemies[i]["pos"]
        if snare_tiles.has(p):
            continue
        p.x -= 1
        enemies[i]["pos"] = p
        if p.x <= BOUNDARY:
            enemies.remove_at(i)
            breaches += 1
            habitat = maxi(0, habitat - 25)
            _message("BREACH! A human reached the heart. Habitat -25.")
    _check_end()
    queue_redraw()

func _check_end() -> void:
    if breaches >= MAX_BREACHES or habitat <= 0:
        game_over = true
        victory = false
        _message("THE HEART HAS FALLEN  /  Press R to try again.")
    elif enemies.is_empty():
        if wave < 3:
            _spawn_wave()
        else:
            game_over = true
            victory = true
            _message("THE WILDS ENDURE  /  All three waves repelled. Press R.")
    queue_redraw()

func _label(at: Vector2, text_value: String, size: int = 14, color: Color = INK) -> void:
    draw_string(ThemeDB.fallback_font, at, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _rect(pos: Vector2, size: Vector2, color: Color) -> void:
    draw_rect(Rect2(pos, size), color)

func _center(cell: Vector2i) -> Vector2:
    return ORIGIN + Vector2(cell) * CELL + Vector2.ONE * (CELL * 0.5)

func _tree(at: Vector2, scale_value: float, tint: Color) -> void:
    draw_line(at + Vector2(0, 8) * scale_value, at + Vector2(0, -3) * scale_value, Color("#69563c"), 2.5 * scale_value)
    draw_circle(at + Vector2(-3, -4) * scale_value, 6.5 * scale_value, tint)
    draw_circle(at + Vector2(4, -6) * scale_value, 7 * scale_value, tint.lightened(0.09))
    draw_circle(at + Vector2(0, -10) * scale_value, 5 * scale_value, tint.lightened(0.15))

func _draw_guardian(i: int) -> void:
    var p := _center(guardians[i])
    var color: Color = GUARDIAN_COLORS[i]
    draw_circle(p + Vector2(1, 3), 12, Color("#0b1916"))
    if i == 0:
        draw_line(p + Vector2(-5, 7), p + Vector2(-10, 12), color, 3)
        draw_line(p + Vector2(5, 7), p + Vector2(10, 12), color, 3)
        draw_circle(p, 9, Color("#426b44"))
        draw_circle(p + Vector2(0, -5), 7, color)
        draw_line(p + Vector2(-5, -7), p + Vector2(-10, -13), color, 2)
        draw_line(p + Vector2(5, -7), p + Vector2(10, -13), color, 2)
    elif i == 1:
        draw_colored_polygon(PackedVector2Array([p + Vector2(-11, 8), p + Vector2(-9, -5), p + Vector2(-3, -11), p + Vector2(8, -10), p + Vector2(12, 5), p + Vector2(5, 10)]), color)
        draw_line(p + Vector2(-7, -7), p + Vector2(-12, -14), Color("#fff0c8"), 3)
        draw_line(p + Vector2(7, -7), p + Vector2(12, -14), Color("#fff0c8"), 3)
    else:
        draw_colored_polygon(PackedVector2Array([p + Vector2(-11, 8), p + Vector2(-8, -6), p + Vector2(0, -11), p + Vector2(10, -4), p + Vector2(12, 8)]), color)
        for k in range(3):
            draw_line(p + Vector2(-6 + k * 6, -7), p + Vector2(-8 + k * 6, -14), color, 2)
    draw_circle(p + Vector2(-3, -2), 1.5, Color("#15271e"))
    draw_circle(p + Vector2(4, -2), 1.5, Color("#15271e"))
    if selected == i:
        draw_arc(p, 15, 0, TAU, 36, GOLD, 2.0)
        _label(p + Vector2(-5, -18), str(i + 1), 12, GOLD)

func _draw_human(enemy: Dictionary) -> void:
    var p := _center(enemy["pos"])
    var coat := [Color("#c76e55"), Color("#a9a7a0"), Color("#d7a36b")][int(enemy["kind"])]
    draw_circle(p + Vector2(0, 5), 8, Color("#15221d"))
    _rect(p + Vector2(-5, -2), Vector2(10, 10), coat)
    draw_circle(p + Vector2(0, -6), 4.5, Color("#e2c5a2"))
    draw_line(p + Vector2(-7, 2), p + Vector2(-11, 7), Color("#c4b89e"), 2)
    draw_line(p + Vector2(6, 2), p + Vector2(11, -3), Color("#c4b89e"), 2)
    if int(enemy["hp"]) > 1:
        draw_circle(p + Vector2(9, -10), 2, GOLD)

func _draw() -> void:
    _rect(Vector2.ZERO, Vector2(1152, 768), Color("#0d1b18"))
    _rect(Vector2.ZERO, Vector2(1152, 86), PANEL)
    _label(Vector2(42, 31), "THE LAST WILDS", 24, GOLD)
    _label(Vector2(43, 57), "THE FOREST WILL NOT FALL QUIETLY", 11, Color("#a6b7a4"))
    _label(Vector2(410, 29), "HEART  %d%%" % habitat, 16, INK)
    _label(Vector2(570, 29), "WILD ENERGY  %d" % energy, 16, GOLD)
    _label(Vector2(770, 29), "WAVE  %d / 3" % wave, 16, INK)
    _label(Vector2(930, 29), "BREACHES  %d / 3" % breaches, 16, Color("#ed9782"))
    _rect(Vector2(410, 43), Vector2(138, 7), Color("#344038"))
    _rect(Vector2(410, 43), Vector2(138.0 * habitat / 100.0, 7), Color("#9bdf8a"))
    _rect(Vector2(570, 43), Vector2(138, 7), Color("#344038"))
    _rect(Vector2(570, 43), Vector2(138.0 * energy / 100.0, 7), GOLD)
    for y in range(H):
        for x in range(W):
            var p := ORIGIN + Vector2(x, y) * CELL
            var shade := 0.025 * float((x * 7 + y * 11) % 5)
            var color := FOREST.lightened(shade) if x > BOUNDARY else Color("#285e47").lightened(shade)
            if y == 12 and x >= 17:
                color = Color("#75634a").lightened(shade)
            _rect(p, Vector2(CELL - 1, CELL - 1), color)
            var seed := (x * 37 + y * 71 + x * y * 13) % 17
            if seed == 1 or seed == 4:
                draw_line(p + Vector2(7, 17), p + Vector2(10, 12), Color("#507b4b"), 1)
                draw_line(p + Vector2(10, 17), p + Vector2(10, 12), Color("#5e8a54"), 1)
            elif seed == 7 and x > BOUNDARY and not (y == 12 and x >= 17):
                _tree(p + Vector2(12, 13), 0.55, Color("#345e40"))
    var edge_x := ORIGIN.x + (BOUNDARY + 1) * CELL
    draw_line(Vector2(edge_x, ORIGIN.y), Vector2(edge_x, ORIGIN.y + H * CELL), GOLD.darkened(0.15), 2)
    for y in range(2, H, 5):
        draw_circle(_center(Vector2i(BOUNDARY, y)), 3, Color("#a1d9a5"))
    var heart := _center(Vector2i(3, 12))
    draw_circle(heart, 25, Color("#4c9475"))
    draw_circle(heart, 19, Color("#8bc8a4"))
    draw_circle(heart, 12, Color("#d5e9b8"))
    draw_arc(heart, 29, 0, TAU, 48, GOLD, 2)
    for tile in snare_tiles:
        var center := _center(tile)
        draw_line(center + Vector2(-8, 7), center + Vector2(8, -7), Color("#b1d88d"), 3)
        draw_line(center + Vector2(-8, -7), center + Vector2(8, 7), Color("#b1d88d"), 2)
    for enemy in enemies:
        _draw_human(enemy)
    for i in range(guardians.size()):
        _draw_guardian(i)
    _rect(Vector2(832, 108), Vector2(284, 576), PANEL)
    _label(Vector2(852, 141), "GUARDIANS OF THE WILDS", 16, GOLD)
    for i in range(3):
        var top := 160 + i * 112
        _rect(Vector2(847, top), Vector2(254, 99), Color("#345143") if i == selected else Color("#1c332a"))
        draw_circle(Vector2(871, top + 26), 10, GUARDIAN_COLORS[i])
        _label(Vector2(890, top + 31), "%d  %s" % [i + 1, GUARDIAN_NAMES[i]], 16, INK)
        var abilities := ["ROOT SNARE", "EARTHSHATTER", "THORN VOLLEY"]
        _label(Vector2(859, top + 58), "E  " + abilities[i] + "  /  12 energy", 12, Color("#b7c7b6"))
        _label(Vector2(859, top + 79), "READY" if ability_cooldowns[i] == 0 else "RECOVERING  %d" % ability_cooldowns[i], 11, GOLD)
    _label(Vector2(850, 526), "COMMANDS", 16, GOLD)
    _label(Vector2(850, 550), "LEFT CLICK   Select guardian", 12)
    _label(Vector2(850, 573), "RIGHT CLICK  Reposition", 12)
    _label(Vector2(850, 596), "Q   Strike nearby human", 12)
    _label(Vector2(850, 619), "E   Guardian special ability", 12)
    _label(Vector2(850, 642), "SPACE   Pause    /    R   Restart", 12)
    _rect(Vector2(26, 698), Vector2(1090, 50), PANEL)
    _label(Vector2(43, 719), status, 15, GOLD if game_over else INK)
    _label(Vector2(43, 738), "Humans advance each tick. Stop all three waves before three breaches. Each breach costs 25 habitat.", 11, Color("#a6b7a4"))
    if paused or game_over:
        _rect(Vector2(202, 318), Vector2(453, 106), Color("#10231e"))
        draw_rect(Rect2(Vector2(202, 318), Vector2(453, 106)), GOLD, false, 2)
        _label(Vector2(224, 363), "THE WILDS ENDURE" if victory else ("THE FOREST IS STILL" if paused else "THE HEART HAS FALLEN"), 24, GOLD)
        _label(Vector2(224, 395), "Press R to play again." if game_over else "Press SPACE to resume.", 16, INK)
