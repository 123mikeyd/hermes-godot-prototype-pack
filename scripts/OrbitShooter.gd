extends Node2D

var player := Vector2(480, 440)
var bullets: Array[Vector2] = []
var enemies: Array[Dictionary] = []
var fire_cd := 0.0
var wave_timer := 0.0
var score := 0
var lives := 3
var over := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 9876
	reset_game()

func reset_game() -> void:
	player = Vector2(480, 440)
	bullets.clear(); enemies.clear()
	fire_cd = 0; wave_timer = 0; score = 0; lives = 3; over = false
	queue_redraw()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		reset_game()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	if over:
		queue_redraw(); return
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player += v * 290.0 * delta
	player = player.clamp(Vector2(26, 74), Vector2(934, 514))
	fire_cd -= delta
	if Input.is_action_pressed("shoot") and fire_cd <= 0:
		fire_cd = 0.16
		bullets.append(player + Vector2(0, -24))
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].y -= 560.0 * delta
		if bullets[i].y < 48:
			bullets.remove_at(i)
	wave_timer -= delta
	if wave_timer <= 0:
		wave_timer = max(0.25, 0.9 - score * 0.015)
		enemies.append({"pos": Vector2(rng.randf_range(40, 920), -20), "phase": rng.randf_range(0, TAU), "speed": rng.randf_range(65, 120) + score * 1.5})
	for e in enemies:
		e.phase += delta * 2.4
		e.pos.y += e.speed * delta
		e.pos.x += sin(e.phase) * 75.0 * delta
	for bi in range(bullets.size() - 1, -1, -1):
		var hit := false
		for ei in range(enemies.size() - 1, -1, -1):
			if bullets[bi].distance_to(enemies[ei].pos) < 24:
				enemies.remove_at(ei); score += 1; hit = true; break
		if hit:
			bullets.remove_at(bi)
	for ei in range(enemies.size() - 1, -1, -1):
		if enemies[ei].pos.y > 565:
			enemies.remove_at(ei); lives -= 1
		elif player.distance_to(enemies[ei].pos) < 31:
			enemies.remove_at(ei); lives -= 1
	if lives <= 0:
		over = true
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color(0.005, 0.016, 0.03))
	for i in range(30):
		var x := fmod(float(i * 83), 960.0)
		var y := fmod(float(i * 157), 540.0)
		draw_circle(Vector2(x, y), 1.2, Color(0.5, 0.72, 1.0, 0.45))
	for b in bullets:
		draw_rect(Rect2(b - Vector2(3, 12), Vector2(6, 24)), Color(0.65, 1.0, 1.0))
	for e in enemies:
		draw_circle(e.pos, 20, Color(1.0, 0.22, 0.8))
		draw_circle(e.pos, 8, Color(0.2, 0.02, 0.16))
	var ship := PackedVector2Array([player + Vector2(0, -26), player + Vector2(-20, 18), player + Vector2(20, 18)])
	draw_colored_polygon(ship, Color(0.25, 0.6, 1.0))
	draw_polyline(ship + PackedVector2Array([player + Vector2(0, -26)]), Color(0.9, 0.97, 1.0), 2)
	draw_rect(Rect2(0, 0, 960, 54), Color(0, 0, 0, 0.55))
	draw_string(ThemeDB.fallback_font, Vector2(20, 35), "Orbit Shooter  |  Score %d  Lives %d  |  WASD move, Space shoot, R restart, Esc menu" % [score, lives], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.9, 0.95, 1.0))
	if over:
		draw_string(ThemeDB.fallback_font, Vector2(340, 276), "ORBIT LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 48, Color(1.0, 0.76, 0.2))
