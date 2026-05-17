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
			if not require(inst.has_method("start_run"), "Orbit Shooter exposes start_run()"):
				return
			if not require(inst.has_method("spawn_pickup"), "Orbit Shooter exposes spawn_pickup()"):
				return
			if not require(inst.has_method("spawn_enemy"), "Orbit Shooter exposes spawn_enemy()"):
				return
			if not require(inst.has_method("get_debug_state"), "Orbit Shooter exposes get_debug_state()"):
				return
			inst.start_run()
			await process_frame
			inst.spawn_enemy(Vector2(480, 120), "drifter")
			inst.spawn_pickup(Vector2(480, 300), "shield")
			await process_frame
			var state: Dictionary = inst.get_debug_state()
			if not require(state.get("game_state") == "playing", "Orbit Shooter starts playable run"):
				return
			if not require(state.get("enemies", 0) >= 1, "Orbit Shooter can spawn enemies"):
				return
			if not require(state.get("pickups", 0) >= 1, "Orbit Shooter can spawn pickups"):
				return
		inst.queue_free()
		await process_frame
	print("HERMES_PROTOTYPE_PACK_SMOKE_PASS")
	quit(0)
