extends Node2D

const VERSION := "v0.3"
const GAME_TITLE := "Hermes Orbit: First Mission"
const WIDTH := 960.0
const HEIGHT := 540.0
const HEADER_H := 54.0
const MISSION_LENGTH := 92.0

var game_state := "title"
var player := Vector2(480, 438)
var player_velocity := Vector2.ZERO
var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var stars: Array[Dictionary] = []
var warnings: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var mission_events := {}
var fire_cd := 0.0
var score := 0
var lives := 3
var shield_time := 0.0
var rapid_time := 0.0
var magnet_time := 0.0
var shake := 0.0
var run_time := 0.0
var mission_phase := "launch"
var upgrade_pending := false
var selected_upgrade := ""
var message := "Press Space to launch the first mission."
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 9876
	_build_starfield()
	reset_to_title()

func _build_starfield() -> void:
	stars.clear()
	for i in range(88):
		stars.append({
			"pos": Vector2(rng.randf_range(0, WIDTH), rng.randf_range(HEADER_H, HEIGHT)),
			"speed": rng.randf_range(12, 72),
			"r": rng.randf_range(0.8, 2.3),
			"a": rng.randf_range(0.35, 0.9),
		})

func reset_to_title() -> void:
	game_state = "title"
	_clear_run_state()
	message = "Press Space to launch the first mission."
	queue_redraw()

func _clear_run_state() -> void:
	player = Vector2(480, 438)
	player_velocity = Vector2.ZERO
	bullets.clear()
	enemies.clear()
	pickups.clear()
	particles.clear()
	warnings.clear()
	popups.clear()
	mission_events.clear()
	fire_cd = 0
	score = 0
	lives = 3
	shield_time = 0
	rapid_time = 0
	magnet_time = 0
	shake = 0
	run_time = 0
	mission_phase = "launch"
	upgrade_pending = false
	selected_upgrade = ""

func start_run() -> void:
	game_state = "playing"
	_clear_run_state()
	shield_time = 1.2
	message = "Launch corridor. Calibrate movement."
	queue_redraw()

func force_mission_time(t: float) -> void:
	run_time = t
	mission_phase = _phase_for_time(run_time)
	if run_time >= 56.0 and run_time < 64.0 and selected_upgrade == "":
		upgrade_pending = true
		game_state = "upgrade"
		message = "Mission break: choose an upgrade."
	elif game_state == "upgrade" and (run_time < 56.0 or run_time >= 64.0):
		game_state = "playing"
		upgrade_pending = false
	queue_redraw()

func choose_upgrade(kind: String) -> void:
	selected_upgrade = kind
	upgrade_pending = false
	game_state = "playing"
	if kind == "rapid":
		rapid_time = 12.0
		message = "Upgrade: rapid fire."
	elif kind == "shield":
		shield_time = 12.0
		message = "Upgrade: shield mantle."
	elif kind == "repair":
		lives = min(5, lives + 2)
		message = "Upgrade: repair burst."
	else:
		magnet_time = 14.0
		message = "Upgrade: crystal magnet."
	_add_popup(player + Vector2(-60, -46), message, Color(1.0, 0.84, 0.28))
	queue_redraw()

func spawn_enemy(pos: Vector2, kind := "drifter") -> void:
	var hp := 1
	var radius := 20.0
	var color := Color(1.0, 0.22, 0.8)
	var speed := rng.randf_range(58, 104)
	if kind == "sine":
		hp = 2; radius = 21; color = Color(0.55, 0.35, 1.0); speed = rng.randf_range(82, 128)
	elif kind == "meteor":
		hp = 2; radius = 24; color = Color(1.0, 0.28, 0.12); speed = rng.randf_range(190, 260)
	elif kind == "crystal_guard":
		hp = 3; radius = 23; color = Color(0.16, 0.95, 0.82); speed = rng.randf_range(78, 110)
	elif kind == "boss":
		hp = 34; radius = 52; color = Color(1.0, 0.72, 0.18); speed = 42
	enemies.append({
		"pos": pos,
		"kind": kind,
		"phase": rng.randf_range(0, TAU),
		"speed": speed,
		"hp": hp,
		"max_hp": hp,
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
		"mission_time": run_time,
		"mission_phase": mission_phase,
		"enemies": enemies.size(),
		"pickups": pickups.size(),
		"bullets": bullets.size(),
		"shield_time": shield_time,
		"rapid_time": rapid_time,
		"magnet_time": magnet_time,
		"upgrade_pending": upgrade_pending,
		"selected_upgrade": selected_upgrade,
	}

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
		elif event.keycode == KEY_R:
			start_run()
		elif event.keycode == KEY_SPACE and game_state != "playing":
			if game_state == "upgrade":
				choose_upgrade("rapid")
			else:
				start_run()
		elif game_state == "upgrade":
			if event.keycode == KEY_1: choose_upgrade("rapid")
			elif event.keycode == KEY_2: choose_upgrade("shield")
			elif event.keycode == KEY_3: choose_upgrade("repair")
			elif event.keycode == KEY_4: choose_upgrade("magnet")

func _process(delta: float) -> void:
	_update_stars(delta)
	_update_particles(delta)
	_update_popups(delta)
	shake = max(0.0, shake - delta * 8.0)
	if game_state == "title" or game_state == "game_over" or game_state == "mission_complete":
		queue_redraw()
		return
	if game_state == "upgrade":
		_update_player(delta * 0.25)
		queue_redraw()
		return
	run_time += delta
	mission_phase = _phase_for_time(run_time)
	shield_time = max(0.0, shield_time - delta)
	rapid_time = max(0.0, rapid_time - delta)
	magnet_time = max(0.0, magnet_time - delta)
	_update_player(delta)
	_update_bullets(delta)
	_update_mission(delta)
	_update_enemies(delta)
	_update_warnings(delta)
	_update_pickups(delta)
	_check_collisions()
	if run_time >= MISSION_LENGTH and game_state == "playing":
		game_state = "mission_complete"
		message = "Mission complete. Score %d. Press Space/R for another run." % score
	if lives <= 0:
		game_state = "game_over"
		message = "Run ended. Press Space or R to relaunch."
	queue_redraw()

func _phase_for_time(t: float) -> String:
	if t < 10.0: return "launch"
	if t < 25.0: return "drifter wave"
	if t < 40.0: return "sine gauntlet"
	if t < 55.0: return "meteor corridor"
	if t < 64.0: return "upgrade break"
	if t < 74.0: return "crystal route"
	return "mini-boss"

func _update_mission(_delta: float) -> void:
	if run_time >= 2.0: _once("launch_pickups", Callable(self, "_event_launch_pickups"))
	if run_time >= 10.0: _once("drifter_1", Callable(self, "_event_drifter_1"))
	if run_time >= 17.0: _once("drifter_2", Callable(self, "_event_drifter_2"))
	if run_time >= 25.0: _once("sine_1", Callable(self, "_event_sine_1"))
	if run_time >= 33.0: _once("sine_2", Callable(self, "_event_sine_2"))
	if run_time >= 40.0: _once("meteor_warn_1", Callable(self, "_event_meteor_warn_1"))
	if run_time >= 46.0: _once("meteor_warn_2", Callable(self, "_event_meteor_warn_2"))
	if run_time >= 56.0 and selected_upgrade == "" and not upgrade_pending:
		upgrade_pending = true
		game_state = "upgrade"
		message = "Mission break: choose 1 Rapid, 2 Shield, 3 Repair, 4 Magnet."
	if run_time >= 64.0 and selected_upgrade == "":
		choose_upgrade("magnet")
	if run_time >= 64.0: _once("crystal_route", Callable(self, "_event_crystal_route"))
	if run_time >= 74.0: _once("boss_intro", Callable(self, "_event_boss_intro"))
	if run_time >= 82.0: _once("boss_support", Callable(self, "_event_boss_support"))

func _once(key: String, callback: Callable) -> void:
	if mission_events.has(key):
		return
	mission_events[key] = true
	callback.call()

func _event_launch_pickups() -> void:
	message = "Launch corridor: collect gold crystals for score."
	for x in [320, 480, 640]: spawn_pickup(Vector2(x, 170), "crystal")

func _event_drifter_1() -> void:
	message = "Drifter wave. Keep the nose steady."
	for x in [180, 320, 480, 640, 780]: spawn_enemy(Vector2(x, -40), "drifter")

func _event_drifter_2() -> void:
	for x in [250, 390, 570, 710]: spawn_enemy(Vector2(x, -70), "drifter")
	spawn_pickup(Vector2(480, -20), "repair")

func _event_sine_1() -> void:
	message = "Sine gauntlet: purple orbs weave."
	for x in [180, 360, 600, 780]: spawn_enemy(Vector2(x, -50), "sine")

func _event_sine_2() -> void:
	for x in [250, 480, 710]: spawn_enemy(Vector2(x, -60), "sine")
	spawn_pickup(Vector2(120, -20), "rapid")
	spawn_pickup(Vector2(840, -20), "shield")

func _event_meteor_warn_1() -> void:
	message = "Meteor corridor: warning lanes mark impact."
	for x in [170, 330, 610, 790]: _add_warning(x, 1.2)

func _event_meteor_warn_2() -> void:
	for x in [250, 480, 710]: _add_warning(x, 1.0)
	spawn_pickup(Vector2(480, -20), "repair")

func _event_crystal_route() -> void:
	message = "Crystal route: take the gold line through the chaos."
	for i in range(7): spawn_pickup(Vector2(180 + i * 100, 90 + (i % 2) * 58), "crystal")
	for x in [120, 840]: spawn_enemy(Vector2(x, -50), "crystal_guard")

func _event_boss_intro() -> void:
	message = "Mini-boss: the orbital core is awake."
	spawn_enemy(Vector2(WIDTH * 0.5, -65), "boss")
	shake = 0.9

func _event_boss_support() -> void:
	for x in [170, 790]: spawn_enemy(Vector2(x, -40), "sine")
	spawn_pickup(Vector2(480, -20), "shield")

func _add_warning(x: float, delay: float) -> void:
	warnings.append({"x": x, "delay": delay, "t": 0.0})

func _update_warnings(delta: float) -> void:
	for w in warnings:
		w.t += delta
	for i in range(warnings.size() - 1, -1, -1):
		if warnings[i].t >= warnings[i].delay:
			spawn_enemy(Vector2(warnings[i].x, -35), "meteor")
			warnings.remove_at(i)

func _update_stars(delta: float) -> void:
	for s in stars:
		s.pos.y += s.speed * delta
		if s.pos.y > HEIGHT:
			s.pos.y = HEADER_H
			s.pos.x = rng.randf_range(0, WIDTH)

func _update_player(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := input_vector * 330.0
	player_velocity = player_velocity.move_toward(target, 1120.0 * delta)
	player += player_velocity * delta
	player = player.clamp(Vector2(28, HEADER_H + 30), Vector2(WIDTH - 28, HEIGHT - 28))
	fire_cd -= delta
	var fire_rate := 0.075 if rapid_time > 0 else 0.15
	if Input.is_action_pressed("shoot") and fire_cd <= 0:
		fire_cd = fire_rate
		bullets.append({"pos": player + Vector2(-7, -28), "vel": Vector2(0, -680), "damage": 1})
		bullets.append({"pos": player + Vector2(7, -28), "vel": Vector2(0, -680), "damage": 1})
		_add_particles(player + Vector2(0, -28), Color(0.65, 1.0, 1.0), 4)

func _update_bullets(delta: float) -> void:
	for b in bullets: b.pos += b.vel * delta
	for i in range(bullets.size() - 1, -1, -1):
		if bullets[i].pos.y < HEADER_H - 20: bullets.remove_at(i)

func _update_enemies(delta: float) -> void:
	for e in enemies:
		e.phase += delta * 1.8
		if e.kind == "sine":
			e.pos.y += e.speed * delta
			e.pos.x += sin(e.phase) * 128.0 * delta
		elif e.kind == "meteor":
			e.pos.y += e.speed * delta
			e.pos.x += cos(e.phase) * 42.0 * delta
		elif e.kind == "boss":
			e.pos.y = min(e.pos.y + 42.0 * delta, 122.0)
			e.pos.x = WIDTH * 0.5 + sin(e.phase) * 220.0
		elif e.kind == "crystal_guard":
			e.pos.y += e.speed * delta
			e.pos.x += sin(e.phase * 0.7) * 50.0 * delta
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
		p.pos.y += 72.0 * delta
		if magnet_time > 0 and p.pos.distance_to(player) < 240:
			p.pos = p.pos.move_toward(player, 220.0 * delta)
	for i in range(pickups.size() - 1, -1, -1):
		if pickups[i].pos.y > HEIGHT + 28: pickups.remove_at(i)

func _check_collisions() -> void:
	for bi in range(bullets.size() - 1, -1, -1):
		var hit := false
		for ei in range(enemies.size() - 1, -1, -1):
			if bullets[bi].pos.distance_to(enemies[ei].pos) < enemies[ei].r:
				enemies[ei].hp -= bullets[bi].damage
				_add_particles(bullets[bi].pos, enemies[ei].color, 6)
				if enemies[ei].hp <= 0:
					var value := 12
					if enemies[ei].kind == "boss": value = 300
					elif enemies[ei].kind == "crystal_guard": value = 35
					score += value
					_add_popup(enemies[ei].pos, "+%d" % value, enemies[ei].color)
					shake = 0.25 if enemies[ei].kind != "boss" else 0.85
					_add_particles(enemies[ei].pos, enemies[ei].color, 18)
					enemies.remove_at(ei)
				hit = true
				break
		if hit: bullets.remove_at(bi)
	for ei in range(enemies.size() - 1, -1, -1):
		if player.distance_to(enemies[ei].pos) < enemies[ei].r + 22:
			_add_particles(enemies[ei].pos, enemies[ei].color, 16)
			enemies.remove_at(ei)
			if shield_time <= 0:
				lives -= 1
				shield_time = 0.9
			else:
				_add_popup(player + Vector2(-28, -44), "SHIELD", Color(0.35, 1.0, 0.75))
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
		_add_popup(player + Vector2(-28, -42), "+LIFE", Color(0.32, 1.0, 0.48))
	elif kind == "shield":
		shield_time = 5.0
		message = "Shield online."
		_add_popup(player + Vector2(-34, -42), "SHIELD", Color(0.25, 0.95, 1.0))
	elif kind == "rapid":
		rapid_time = 5.0
		message = "Rapid fire online."
		_add_popup(player + Vector2(-32, -42), "RAPID", Color(1.0, 0.52, 0.18))
	else:
		score += 25
		message = "Crystal route bonus +25."
		_add_popup(player + Vector2(-24, -42), "+25", Color(1.0, 0.78, 0.22))

func _add_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({"pos": pos, "vel": Vector2(rng.randf_range(-160, 160), rng.randf_range(-160, 160)), "life": rng.randf_range(0.22, 0.55), "max_life": 0.55, "color": color})

func _update_particles(delta: float) -> void:
	for p in particles:
		p.pos += p.vel * delta
		p.life -= delta
	for i in range(particles.size() - 1, -1, -1):
		if particles[i].life <= 0: particles.remove_at(i)

func _add_popup(pos: Vector2, text: String, color: Color) -> void:
	popups.append({"pos": pos, "text": text, "color": color, "life": 1.0})

func _update_popups(delta: float) -> void:
	for p in popups:
		p.pos.y -= 28.0 * delta
		p.life -= delta
	for i in range(popups.size() - 1, -1, -1):
		if popups[i].life <= 0: popups.remove_at(i)

func _draw() -> void:
	var offset := Vector2.ZERO
	if shake > 0: offset = Vector2(rng.randf_range(-shake, shake), rng.randf_range(-shake, shake)) * 8.0
	draw_set_transform(offset)
	_draw_world()
	draw_set_transform(Vector2.ZERO)
	_draw_hud()
	if game_state == "title": _draw_title_overlay()
	elif game_state == "upgrade": _draw_upgrade_overlay()
	elif game_state == "game_over": _draw_game_over("ORBIT LOST")
	elif game_state == "mission_complete": _draw_game_over("MISSION CLEAR")

func _draw_world() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(WIDTH, HEIGHT)), Color(0.004, 0.012, 0.026))
	for s in stars: draw_circle(s.pos, s.r, Color(0.45, 0.68, 1.0, s.a))
	for ring in range(5): draw_arc(Vector2(WIDTH * 0.5, HEIGHT + 150), 240 + ring * 70, PI + 0.2, TAU - 0.2, 64, Color(0.08, 0.22, 0.42, 0.42), 2)
	for w in warnings:
		var alpha := 0.35 + sin(w.t * 18.0) * 0.25
		draw_rect(Rect2(w.x - 28, HEADER_H, 56, HEIGHT - HEADER_H), Color(1.0, 0.18, 0.08, alpha), false, 3)
		draw_string(ThemeDB.fallback_font, Vector2(w.x - 34, 86), "!!", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1.0, 0.42, 0.18, 0.9))
	for p in pickups: _draw_pickup(p)
	for b in bullets:
		draw_rect(Rect2(b.pos - Vector2(3, 13), Vector2(6, 26)), Color(0.64, 1.0, 1.0))
		draw_circle(b.pos - Vector2(0, 12), 5, Color(1.0, 1.0, 1.0, 0.8))
	for e in enemies: _draw_enemy(e)
	for p in particles:
		var alpha: float = clamp(p.life / p.max_life, 0.0, 1.0)
		var c: Color = p.color; c.a = alpha
		draw_circle(p.pos, 2.5 + alpha * 2.5, c)
	for p in popups:
		var c: Color = p.color; c.a = clamp(p.life, 0, 1)
		draw_string(ThemeDB.fallback_font, p.pos, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, c)
	_draw_player()

func _draw_player() -> void:
	var ship := PackedVector2Array([player + Vector2(0, -28), player + Vector2(-23, 20), player + Vector2(0, 10), player + Vector2(23, 20)])
	draw_colored_polygon(ship, Color(0.18, 0.48, 1.0))
	draw_polyline(PackedVector2Array([ship[0], ship[1], ship[2], ship[3], ship[0]]), Color(0.88, 0.96, 1.0), 2)
	draw_circle(player + Vector2(0, 2), 6, Color(1.0, 0.78, 0.24))
	if shield_time > 0: draw_arc(player, 36 + sin(Time.get_ticks_msec() / 90.0) * 3.0, 0, TAU, 48, Color(0.34, 1.0, 0.72, 0.85), 3)
	if magnet_time > 0: draw_arc(player, 58, 0, TAU, 64, Color(1.0, 0.78, 0.22, 0.35), 2)

func _draw_enemy(e: Dictionary) -> void:
	if e.kind == "boss":
		draw_circle(e.pos, e.r, e.color)
		draw_arc(e.pos, e.r + 12, 0, TAU, 64, Color(1.0, 0.9, 0.36, 0.7), 4)
		draw_circle(e.pos, 17, Color(0.07, 0.02, 0.01))
		var hp_w := 96.0 * float(e.hp) / float(e.max_hp)
		draw_rect(Rect2(e.pos.x - 48, e.pos.y - e.r - 20, hp_w, 6), Color(1.0, 0.28, 0.16))
	elif e.kind == "meteor":
		draw_circle(e.pos, e.r, e.color)
		draw_line(e.pos + Vector2(-8, -18), e.pos + Vector2(18, 20), Color(1.0, 0.76, 0.24), 4)
	elif e.kind == "sine":
		draw_rect(Rect2(e.pos - Vector2(e.r, e.r), Vector2(e.r * 2, e.r * 2)), e.color, true)
		draw_circle(e.pos, e.r * 0.45, Color(0.08, 0.02, 0.08, 0.85))
	elif e.kind == "crystal_guard":
		var pts := PackedVector2Array([e.pos + Vector2(0, -e.r), e.pos + Vector2(e.r, 0), e.pos + Vector2(0, e.r), e.pos + Vector2(-e.r, 0)])
		draw_colored_polygon(pts, e.color)
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
	draw_rect(Rect2(0, 0, WIDTH, HEADER_H), Color(0.0, 0.0, 0.0, 0.66))
	draw_string(ThemeDB.fallback_font, Vector2(18, 34), "%s %s" % [GAME_TITLE, VERSION], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.42, 0.78, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(360, 34), "Score %d   Lives %d   %.0fs" % [score, lives, max(0.0, MISSION_LENGTH - run_time)], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.84, 0.32))
	draw_string(ThemeDB.fallback_font, Vector2(650, 34), mission_phase, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.75, 1.0, 0.88))
	draw_string(ThemeDB.fallback_font, Vector2(18, HEIGHT - 16), message + "  WASD/Arrows move, Space fire/start, R restart, Esc menu", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.74, 0.82, 0.95))

func _draw_title_overlay() -> void:
	draw_rect(Rect2(100, 112, 760, 295), Color(0.01, 0.025, 0.055, 0.9))
	draw_rect(Rect2(100, 112, 760, 295), Color(0.18, 0.48, 1.0, 0.9), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(155, 182), GAME_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color(0.48, 0.82, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(158, 230), "v0.3: an authored 90-second mission, warning lanes, upgrade break, mini-boss.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.88, 0.94, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(158, 294), "Press Space to start. Esc returns to prototype menu.", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(1.0, 0.78, 0.25))

func _draw_upgrade_overlay() -> void:
	draw_rect(Rect2(110, 122, 740, 305), Color(0.015, 0.02, 0.05, 0.94))
	draw_rect(Rect2(110, 122, 740, 305), Color(1.0, 0.78, 0.22, 0.9), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(165, 180), "MISSION BREAK — CHOOSE UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(1.0, 0.84, 0.28))
	draw_string(ThemeDB.fallback_font, Vector2(175, 242), "1 Rapid Fire     2 Shield Mantle", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.9, 0.96, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(175, 292), "3 Repair Burst   4 Crystal Magnet", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.9, 0.96, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(175, 355), "Space defaults to Rapid Fire. The mission resumes immediately.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(0.7, 0.82, 1.0))

func _draw_game_over(title: String) -> void:
	draw_rect(Rect2(200, 162, 560, 205), Color(0.03, 0.015, 0.02, 0.92))
	draw_rect(Rect2(200, 162, 560, 205), Color(1.0, 0.42, 0.16, 0.9), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(300, 235), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(1.0, 0.75, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(315, 292), "Final score: %d   Phase: %s" % [score, mission_phase], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.94, 0.94, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(300, 330), "Press Space or R to relaunch.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color(0.82, 0.9, 1.0))
