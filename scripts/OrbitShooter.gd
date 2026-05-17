extends Node2D

const VERSION := "v0.2"
const GAME_TITLE := "Hermes Orbit: First Run"
const WIDTH := 960.0
const HEIGHT := 540.0
const HEADER_H := 54.0

var game_state := "title"
var player := Vector2(480, 438)
var player_velocity := Vector2.ZERO
var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var stars: Array[Dictionary] = []
var fire_cd := 0.0
var wave_timer := 0.0
var pickup_timer := 0.0
var score := 0
var lives := 3
var wave := 1
var shield_time := 0.0
var rapid_time := 0.0
var shake := 0.0
var run_time := 0.0
var message := "Press Space to launch."
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 9876
	_build_starfield()
	reset_to_title()

func _build_starfield() -> void:
	stars.clear()
	for i in range(72):
		stars.append({
			"pos": Vector2(rng.randf_range(0, WIDTH), rng.randf_range(HEADER_H, HEIGHT)),
			"speed": rng.randf_range(10, 55),
			"r": rng.randf_range(0.8, 2.1),
			"a": rng.randf_range(0.35, 0.9),
		})

func reset_to_title() -> void:
	game_state = "title"
	player = Vector2(480, 438)
	player_velocity = Vector2.ZERO
	bullets.clear()
	enemies.clear()
	pickups.clear()
	particles.clear()
	fire_cd = 0
	wave_timer = 0
	pickup_timer = 2.0
	score = 0
	lives = 3
	wave = 1
	shield_time = 0
	rapid_time = 0
	shake = 0
	run_time = 0
	message = "Press Space to launch."
	queue_redraw()

func start_run() -> void:
	game_state = "playing"
	player = Vector2(480, 438)
	player_velocity = Vector2.ZERO
	bullets.clear()
	enemies.clear()
	pickups.clear()
	particles.clear()
	fire_cd = 0
	wave_timer = 0.25
	pickup_timer = 3.0
	score = 0
	lives = 3
	wave = 1
	shield_time = 1.2
	rapid_time = 0
	shake = 0
	run_time = 0
	message = "Wave 1: clear the drift."
	queue_redraw()

func spawn_enemy(pos: Vector2, kind := "drifter") -> void:
	var hp := 1
	var radius := 20.0
	var color := Color(1.0, 0.22, 0.8)
	if kind == "sine":
		hp = 2; radius = 21; color = Color(0.55, 0.35, 1.0)
	elif kind == "meteor":
		hp = 2; radius = 24; color = Color(1.0, 0.28, 0.12)
	elif kind == "boss":
		hp = 24; radius = 48; color = Color(1.0, 0.72, 0.18)
	enemies.append({
		"pos": pos,
		"kind": kind,
		"phase": rng.randf_range(0, TAU),
		"speed": rng.randf_range(58, 104) + wave * 7.0,
		"hp": hp,
		"r": radius,
		"color": color,
	})

func spawn_pickup(pos: Vector2, kind := "crystal") -> void:
	pickups.append({"pos": pos, "kind": kind, "t": 0.0})

func get_debug_state() -> Dictionary:
	return {
		"version": VERSION,
		"game_state": game_state,
		"score": score,
		"lives": lives,
		"wave": wave,
		"enemies": enemies.size(),
		"pickups": pickups.size(),
		"bullets": bullets.size(),
		"shield_time": shield_time,
		"rapid_time": rapid_time,
	}

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
		elif event.keycode == KEY_R:
			start_run()
		elif event.keycode == KEY_SPACE and game_state != "playing":
			start_run()

func _process(delta: float) -> void:
	_update_stars(delta)
	_update_particles(delta)
	shake = max(0.0, shake - delta * 8.0)
	if game_state != "playing":
		queue_redraw()
		return
	run_time += delta
	shield_time = max(0.0, shield_time - delta)
	rapid_time = max(0.0, rapid_time - delta)
	_update_player(delta)
	_update_bullets(delta)
	_update_waves(delta)
	_update_enemies(delta)
	_update_pickups(delta)
	_check_collisions()
	if lives <= 0:
		game_state = "game_over"
		message = "Run ended. Press Space or R to relaunch."
	queue_redraw()

func _update_stars(delta: float) -> void:
	for s in stars:
		s.pos.y += s.speed * delta
		if s.pos.y > HEIGHT:
			s.pos.y = HEADER_H
			s.pos.x = rng.randf_range(0, WIDTH)

func _update_player(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := input_vector * 330.0
	player_velocity = player_velocity.move_toward(target, 1100.0 * delta)
	player += player_velocity * delta
	player = player.clamp(Vector2(28, HEADER_H + 30), Vector2(WIDTH - 28, HEIGHT - 28))
	fire_cd -= delta
	var fire_rate := 0.09 if rapid_time > 0 else 0.17
	if Input.is_action_pressed("shoot") and fire_cd <= 0:
		fire_cd = fire_rate
		bullets.append({"pos": player + Vector2(-7, -28), "vel": Vector2(0, -650), "damage": 1})
		bullets.append({"pos": player + Vector2(7, -28), "vel": Vector2(0, -650), "damage": 1})
		_add_particles(player + Vector2(0, -28), Color(0.65, 1.0, 1.0), 4)

func _update_bullets(delta: float) -> void:
	for b in bullets:
		b.pos += b.vel * delta
	for i in range(bullets.size() - 1, -1, -1):
		if bullets[i].pos.y < HEADER_H - 20:
			bullets.remove_at(i)

func _update_waves(delta: float) -> void:
	wave = 1 + int(score / 12)
	wave_timer -= delta
	pickup_timer -= delta
	if pickup_timer <= 0:
		pickup_timer = rng.randf_range(4.5, 7.5)
		var kinds := ["crystal", "repair", "shield", "rapid"]
		spawn_pickup(Vector2(rng.randf_range(70, WIDTH - 70), -20), kinds[rng.randi_range(0, kinds.size() - 1)])
	if wave_timer > 0:
		return
	wave_timer = max(0.18, 0.72 - wave * 0.045)
	var roll := rng.randf()
	if score > 0 and score % 30 == 0 and not _has_boss():
		spawn_enemy(Vector2(WIDTH * 0.5, -54), "boss")
	elif wave >= 4 and roll < 0.22:
		spawn_enemy(Vector2(rng.randf_range(40, WIDTH - 40), -30), "meteor")
	elif wave >= 2 and roll < 0.55:
		spawn_enemy(Vector2(rng.randf_range(40, WIDTH - 40), -30), "sine")
	else:
		spawn_enemy(Vector2(rng.randf_range(40, WIDTH - 40), -30), "drifter")

func _has_boss() -> bool:
	for e in enemies:
		if e.kind == "boss":
			return true
	return false

func _update_enemies(delta: float) -> void:
	for e in enemies:
		e.phase += delta * (1.4 + wave * 0.08)
		if e.kind == "sine":
			e.pos.y += e.speed * delta
			e.pos.x += sin(e.phase) * 110.0 * delta
		elif e.kind == "meteor":
			e.pos.y += (e.speed + 90) * delta
			e.pos.x += cos(e.phase) * 35.0 * delta
		elif e.kind == "boss":
			e.pos.y = min(e.pos.y + 42.0 * delta, 122.0)
			e.pos.x = WIDTH * 0.5 + sin(e.phase) * 220.0
		else:
			e.pos.y += e.speed * delta
	for i in range(enemies.size() - 1, -1, -1):
		if enemies[i].pos.y > HEIGHT + 70:
			enemies.remove_at(i)
			lives -= 1
			shake = 0.45

func _update_pickups(delta: float) -> void:
	for p in pickups:
		p.t += delta
		p.pos.y += 78.0 * delta
	for i in range(pickups.size() - 1, -1, -1):
		if pickups[i].pos.y > HEIGHT + 28:
			pickups.remove_at(i)

func _check_collisions() -> void:
	for bi in range(bullets.size() - 1, -1, -1):
		var hit := false
		for ei in range(enemies.size() - 1, -1, -1):
			if bullets[bi].pos.distance_to(enemies[ei].pos) < enemies[ei].r:
				enemies[ei].hp -= bullets[bi].damage
				_add_particles(bullets[bi].pos, enemies[ei].color, 6)
				if enemies[ei].hp <= 0:
					var value := 10 if enemies[ei].kind != "boss" else 150
					score += value
					shake = 0.25 if enemies[ei].kind != "boss" else 0.8
					_add_particles(enemies[ei].pos, enemies[ei].color, 18)
					enemies.remove_at(ei)
				hit = true
				break
		if hit:
			bullets.remove_at(bi)
	for ei in range(enemies.size() - 1, -1, -1):
		if player.distance_to(enemies[ei].pos) < enemies[ei].r + 22:
			_add_particles(enemies[ei].pos, enemies[ei].color, 16)
			enemies.remove_at(ei)
			if shield_time <= 0:
				lives -= 1
				shield_time = 1.0
			shake = 0.7
	for pi in range(pickups.size() - 1, -1, -1):
		if player.distance_to(pickups[pi].pos) < 30:
			_apply_pickup(pickups[pi].kind)
			_add_particles(pickups[pi].pos, _pickup_color(pickups[pi].kind), 12)
			pickups.remove_at(pi)

func _apply_pickup(kind: String) -> void:
	if kind == "repair":
		lives = min(5, lives + 1)
		message = "Repair glyph restored one life."
	elif kind == "shield":
		shield_time = 5.0
		message = "Shield online."
	elif kind == "rapid":
		rapid_time = 5.0
		message = "Rapid fire online."
	else:
		score += 25
		message = "Crystal route bonus +25."

func _add_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({
			"pos": pos,
			"vel": Vector2(rng.randf_range(-150, 150), rng.randf_range(-150, 150)),
			"life": rng.randf_range(0.22, 0.55),
			"max_life": 0.55,
			"color": color,
		})

func _update_particles(delta: float) -> void:
	for p in particles:
		p.pos += p.vel * delta
		p.life -= delta
	for i in range(particles.size() - 1, -1, -1):
		if particles[i].life <= 0:
			particles.remove_at(i)

func _draw() -> void:
	var offset := Vector2.ZERO
	if shake > 0:
		offset = Vector2(rng.randf_range(-shake, shake), rng.randf_range(-shake, shake)) * 8.0
	draw_set_transform(offset)
	_draw_world()
	draw_set_transform(Vector2.ZERO)
	_draw_hud()
	if game_state == "title":
		_draw_title_overlay()
	elif game_state == "game_over":
		_draw_game_over()

func _draw_world() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(WIDTH, HEIGHT)), Color(0.004, 0.012, 0.026))
	for s in stars:
		draw_circle(s.pos, s.r, Color(0.45, 0.68, 1.0, s.a))
	for ring in range(4):
		draw_arc(Vector2(WIDTH * 0.5, HEIGHT + 150), 250 + ring * 70, PI + 0.2, TAU - 0.2, 64, Color(0.08, 0.22, 0.42, 0.45), 2)
	for p in pickups:
		_draw_pickup(p)
	for b in bullets:
		draw_rect(Rect2(b.pos - Vector2(3, 13), Vector2(6, 26)), Color(0.64, 1.0, 1.0))
		draw_circle(b.pos - Vector2(0, 12), 5, Color(1.0, 1.0, 1.0, 0.8))
	for e in enemies:
		_draw_enemy(e)
	for p in particles:
		var alpha: float = clamp(p.life / p.max_life, 0.0, 1.0)
		var c: Color = p.color
		c.a = alpha
		draw_circle(p.pos, 2.5 + alpha * 2.5, c)
	_draw_player()

func _draw_player() -> void:
	var ship := PackedVector2Array([player + Vector2(0, -28), player + Vector2(-23, 20), player + Vector2(0, 10), player + Vector2(23, 20)])
	draw_colored_polygon(ship, Color(0.18, 0.48, 1.0))
	draw_polyline(PackedVector2Array([ship[0], ship[1], ship[2], ship[3], ship[0]]), Color(0.88, 0.96, 1.0), 2)
	draw_circle(player + Vector2(0, 2), 6, Color(1.0, 0.78, 0.24))
	if shield_time > 0:
		draw_arc(player, 36, 0, TAU, 48, Color(0.34, 1.0, 0.72, 0.85), 3)

func _draw_enemy(e: Dictionary) -> void:
	if e.kind == "boss":
		draw_circle(e.pos, e.r, e.color)
		draw_arc(e.pos, e.r + 12, 0, TAU, 64, Color(1.0, 0.9, 0.36, 0.7), 4)
		draw_circle(e.pos, 17, Color(0.07, 0.02, 0.01))
	else:
		draw_circle(e.pos, e.r, e.color)
		draw_circle(e.pos + Vector2(-e.r * 0.25, -e.r * 0.25), e.r * 0.38, Color(1.0, 0.92, 1.0, 0.65))
		draw_circle(e.pos, e.r * 0.38, Color(0.08, 0.02, 0.08, 0.85))

func _draw_pickup(p: Dictionary) -> void:
	var c := _pickup_color(p.kind)
	var bob := sin(p.t * 5.0) * 4.0
	var pos: Vector2 = p.pos + Vector2(0, bob)
	draw_circle(pos, 15, c)
	draw_arc(pos, 22, 0, TAU, 32, Color(c.r, c.g, c.b, 0.45), 2)
	draw_string(ThemeDB.fallback_font, pos + Vector2(-7, 6), _pickup_letter(p.kind), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.02, 0.02, 0.04))

func _pickup_color(kind: String) -> Color:
	if kind == "repair": return Color(0.32, 1.0, 0.48)
	if kind == "shield": return Color(0.25, 0.95, 1.0)
	if kind == "rapid": return Color(1.0, 0.52, 0.18)
	return Color(1.0, 0.78, 0.22)

func _pickup_letter(kind: String) -> String:
	if kind == "repair": return "+"
	if kind == "shield": return "S"
	if kind == "rapid": return "R"
	return "C"

func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEADER_H), Color(0.0, 0.0, 0.0, 0.64))
	draw_string(ThemeDB.fallback_font, Vector2(18, 34), "%s %s" % [GAME_TITLE, VERSION], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.42, 0.78, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(350, 34), "Score %d   Lives %d   Wave %d" % [score, lives, wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.84, 0.32))
	var buffs := []
	if shield_time > 0: buffs.append("Shield %.0f" % shield_time)
	if rapid_time > 0: buffs.append("Rapid %.0f" % rapid_time)
	draw_string(ThemeDB.fallback_font, Vector2(690, 34), "  ".join(buffs), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.75, 1.0, 0.88))
	draw_string(ThemeDB.fallback_font, Vector2(18, HEIGHT - 16), message + "  WASD/Arrows move, Space fire/start, R restart, Esc menu", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.74, 0.82, 0.95))

func _draw_title_overlay() -> void:
	draw_rect(Rect2(120, 122, 720, 270), Color(0.01, 0.025, 0.055, 0.88))
	draw_rect(Rect2(120, 122, 720, 270), Color(0.18, 0.48, 1.0, 0.9), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(178, 190), GAME_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color(0.48, 0.82, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(182, 236), "v0.2 vertical slice: waves, pickups, shield, rapid fire, boss seed.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.88, 0.94, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(182, 300), "Press Space to start. Esc returns to prototype menu.", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(1.0, 0.78, 0.25))

func _draw_game_over() -> void:
	draw_rect(Rect2(210, 170, 540, 190), Color(0.03, 0.015, 0.02, 0.9))
	draw_rect(Rect2(210, 170, 540, 190), Color(1.0, 0.42, 0.16, 0.9), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(330, 240), "ORBIT LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color(1.0, 0.75, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(322, 292), "Final score: %d   Wave: %d" % [score, wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.94, 0.94, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(300, 330), "Press Space or R to relaunch.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color(0.82, 0.9, 1.0))
