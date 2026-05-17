extends Node2D

var player := Vector2(480, 480)
var meteors: Array[Dictionary] = []
var spawn_timer := 0.0
var survived := 0.0
var over := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 12345
	reset_game()

func reset_game() -> void:
	player = Vector2(480, 480)
	meteors.clear()
	spawn_timer = 0
	survived = 0
	over = false
	queue_redraw()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		reset_game()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	if over:
		queue_redraw(); return
	survived += delta
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player += v * 360.0 * delta
	player = player.clamp(Vector2(22, 72), Vector2(938, 512))
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = max(0.12, 0.45 - survived * 0.012)
		meteors.append({"pos": Vector2(rng.randf_range(20, 940), -30), "vel": Vector2(rng.randf_range(-45, 45), rng.randf_range(160, 260) + survived * 8.0), "r": rng.randf_range(12, 25)})
	for m in meteors:
		m.pos += m.vel * delta
	for i in range(meteors.size() - 1, -1, -1):
		if meteors[i].pos.y > 580:
			meteors.remove_at(i)
		elif player.distance_to(meteors[i].pos) < meteors[i].r + 19:
			over = true
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color(0.025, 0.018, 0.035))
	for i in range(7):
		draw_line(Vector2(i * 160.0, 54), Vector2(i * 160.0 - 110, 540), Color(0.12, 0.05, 0.17, 0.55), 3)
	for m in meteors:
		draw_circle(m.pos, m.r, Color(1.0, 0.25, 0.14))
		draw_circle(m.pos + Vector2(-m.r * .25, -m.r * .25), m.r * .35, Color(1.0, 0.75, 0.35))
	draw_circle(player, 20, Color(0.36, 1.0, 0.55))
	draw_arc(player, 32, PI, TAU, 20, Color(0.75, 1.0, 0.9), 4)
	draw_rect(Rect2(0, 0, 960, 54), Color(0, 0, 0, 0.55))
	draw_string(ThemeDB.fallback_font, Vector2(20, 35), "Meteor Umbrella  |  Survive %.1fs  |  WASD move, R restart, Esc menu" % survived, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.95, 0.93, 1.0))
	if over:
		draw_string(ThemeDB.fallback_font, Vector2(335, 276), "BONKED @ %.1fs" % survived, HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color(1.0, 0.72, 0.22))
