extends Node2D

var player := Vector2(90, 280)
var crystals: Array[Vector2] = []
var score := 0
var time_left := 20.0
var over := false

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	player = Vector2(90, 280)
	crystals.clear()
	for i in range(10):
		crystals.append(Vector2(180 + (i * 73) % 700, 90 + (i * 131) % 360))
	score = 0
	time_left = 20.0
	over = false
	queue_redraw()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		reset_game()
	if Input.is_key_pressed(KEY_Q):
		get_tree().quit()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	if over:
		return
	time_left -= delta
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player += v * 310.0 * delta
	player = player.clamp(Vector2(24, 54), Vector2(936, 516))
	for i in range(crystals.size() - 1, -1, -1):
		if player.distance_to(crystals[i]) < 30:
			crystals.remove_at(i)
			score += 1
	if crystals.is_empty() or time_left <= 0:
		over = true
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color(0.02, 0.025, 0.055))
	for x in range(0, 960, 48):
		draw_line(Vector2(x, 54), Vector2(x, 540), Color(0.05, 0.13, 0.25), 1)
	for y in range(54, 540, 48):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.05, 0.13, 0.25), 1)
	for c in crystals:
		draw_circle(c, 16, Color(0.15, 1.0, 0.82))
		draw_circle(c, 7, Color(1, 1, 1))
	draw_circle(player, 20, Color(0.25, 0.62, 1.0))
	draw_circle(player + Vector2(7, -7), 6, Color(0.85, 0.96, 1.0))
	draw_rect(Rect2(0, 0, 960, 54), Color(0, 0, 0, 0.55))
	draw_string(ThemeDB.fallback_font, Vector2(20, 35), "Crystal Dash  |  Score %d/10  |  Time %.1f  |  WASD move, R restart, Esc menu, Q quit" % [score, max(time_left, 0.0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.9, 0.95, 1.0))
	if over:
		var msg := "CLEAR" if crystals.is_empty() else "TIME UP"
		draw_string(ThemeDB.fallback_font, Vector2(375, 276), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 52, Color(1.0, 0.78, 0.26))
