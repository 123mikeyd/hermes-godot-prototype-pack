# Verification

The smoke harness is `tools/smoke_all.gd`. It loads and instantiates:

- `scenes/Menu.tscn`
- `scenes/CrystalDash.tscn`
- `scenes/MeteorUmbrella.tscn`
- `scenes/OrbitShooter.tscn`

For v0.3, it also verifies that Hermes Orbit exposes the public debug/control methods used for automation:

- `start_run()`
- `spawn_enemy(pos, kind)`
- `spawn_pickup(pos, kind)`
- `force_mission_time(t)`
- `choose_upgrade(kind)`
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
PASS Hermes Orbit exposes start_run()
PASS Hermes Orbit exposes spawn_pickup()
PASS Hermes Orbit exposes spawn_enemy()
PASS Hermes Orbit exposes get_debug_state()
PASS Hermes Orbit v0.3 exposes force_mission_time()
PASS Hermes Orbit v0.3 exposes choose_upgrade()
PASS Hermes Orbit reports v0.3
PASS Hermes Orbit starts playable run
PASS Hermes Orbit can spawn enemies
PASS Hermes Orbit can spawn pickups
PASS Hermes Orbit authored mission reaches meteor corridor
PASS Hermes Orbit offers upgrade choice at mission break
PASS Hermes Orbit applies magnet upgrade
PASS Hermes Orbit authored mission reaches mini-boss
HERMES_PROTOTYPE_PACK_SMOKE_PASS
```
