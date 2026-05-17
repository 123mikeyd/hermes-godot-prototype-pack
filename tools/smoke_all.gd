extends SceneTree

var scenes := [
	"res://scenes/Menu.tscn",
	"res://scenes/CrystalDash.tscn",
	"res://scenes/MeteorUmbrella.tscn",
	"res://scenes/OrbitShooter.tscn",
]

func _initialize() -> void:
	print("HERMES_PROTOTYPE_PACK_SMOKE_START")
	for path in scenes:
		var packed := load(path) as PackedScene
		if packed == null:
			print("FAIL load " + path)
			quit(1); return
		var inst := packed.instantiate()
		get_root().add_child(inst)
		await process_frame
		print("PASS instantiate " + path + " root=" + inst.name)
		inst.queue_free()
		await process_frame
	print("HERMES_PROTOTYPE_PACK_SMOKE_PASS")
	quit(0)
