extends SceneTree

var scenes := [
	"res://scenes/Menu.tscn",
	"res://scenes/CrystalDash.tscn",
	"res://scenes/MeteorUmbrella.tscn",
	"res://scenes/OrbitShooter.tscn",
]

func require(condition: bool, message: String) -> bool:
	if not condition:
		print("FAIL " + message)
		quit(1)
		return false
	print("PASS " + message)
	return true

func _initialize() -> void:
	print("HERMES_PROTOTYPE_PACK_SMOKE_START")
	for path in scenes:
		var packed := load(path) as PackedScene
		if not require(packed != null, "load " + path):
			return
		var inst := packed.instantiate()
		get_root().add_child(inst)
		await process_frame
		print("PASS instantiate " + path + " root=" + inst.name)
		if path.ends_with("OrbitShooter.tscn"):
			if not require(inst.has_method("start_run"), "Hermes Orbit exposes start_run()"):
				return
			if not require(inst.has_method("spawn_pickup"), "Hermes Orbit exposes spawn_pickup()"):
				return
			if not require(inst.has_method("spawn_enemy"), "Hermes Orbit exposes spawn_enemy()"):
				return
			if not require(inst.has_method("get_debug_state"), "Hermes Orbit exposes get_debug_state()"):
				return
			if not require(inst.has_method("force_mission_time"), "Hermes Orbit v0.3 exposes force_mission_time()"):
				return
			if not require(inst.has_method("choose_upgrade"), "Hermes Orbit v0.3 exposes choose_upgrade()"):
				return
			inst.start_run()
			await process_frame
			inst.spawn_enemy(Vector2(480, 120), "drifter")
			inst.spawn_pickup(Vector2(480, 300), "shield")
			await process_frame
			var state: Dictionary = inst.get_debug_state()
			if not require(state.get("version") == "v0.3", "Hermes Orbit reports v0.3"):
				return
			if not require(state.get("game_state") == "playing", "Hermes Orbit starts playable run"):
				return
			if not require(state.get("enemies", 0) >= 1, "Hermes Orbit can spawn enemies"):
				return
			if not require(state.get("pickups", 0) >= 1, "Hermes Orbit can spawn pickups"):
				return
			inst.force_mission_time(42.0)
			await process_frame
			state = inst.get_debug_state()
			if not require(state.get("mission_phase") == "meteor corridor", "Hermes Orbit authored mission reaches meteor corridor"):
				return
			inst.force_mission_time(58.0)
			await process_frame
			state = inst.get_debug_state()
			if not require(state.get("upgrade_pending") == true, "Hermes Orbit offers upgrade choice at mission break"):
				return
			inst.choose_upgrade("magnet")
			state = inst.get_debug_state()
			if not require(state.get("magnet_time", 0.0) > 0.0, "Hermes Orbit applies magnet upgrade"):
				return
			inst.force_mission_time(82.0)
			await process_frame
			state = inst.get_debug_state()
			if not require(state.get("mission_phase") == "mini-boss", "Hermes Orbit authored mission reaches mini-boss"):
				return
		inst.queue_free()
		await process_frame
	print("HERMES_PROTOTYPE_PACK_SMOKE_PASS")
	quit(0)
