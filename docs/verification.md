# Verification

The smoke harness is `tools/smoke_all.gd`. It loads and instantiates:

- `scenes/Menu.tscn`
- `scenes/CrystalDash.tscn`
- `scenes/MeteorUmbrella.tscn`
- `scenes/OrbitShooter.tscn`

For v0.2, it also verifies that Hermes Orbit exposes the public debug/control methods used for automation:

- `start_run()`
- `spawn_enemy(pos, kind)`
- `spawn_pickup(pos, kind)`
- `get_debug_state()`

Run:

```bash
./run_all_smokes.sh
```

Expected output includes:

```text
HERMES_PROTOTYPE_PACK_SMOKE_START
PASS load res://scenes/Menu.tscn
PASS instantiate res://scenes/Menu.tscn root=Menu
PASS load res://scenes/CrystalDash.tscn
PASS instantiate res://scenes/CrystalDash.tscn root=CrystalDash
PASS load res://scenes/MeteorUmbrella.tscn
PASS instantiate res://scenes/MeteorUmbrella.tscn root=MeteorUmbrella
PASS load res://scenes/OrbitShooter.tscn
PASS instantiate res://scenes/OrbitShooter.tscn root=OrbitShooter
PASS Orbit Shooter exposes start_run()
PASS Orbit Shooter exposes spawn_pickup()
PASS Orbit Shooter exposes spawn_enemy()
PASS Orbit Shooter exposes get_debug_state()
PASS Orbit Shooter starts playable run
PASS Orbit Shooter can spawn enemies
PASS Orbit Shooter can spawn pickups
HERMES_PROTOTYPE_PACK_SMOKE_PASS
```
