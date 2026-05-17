# Verification

The smoke harness is `tools/smoke_all.gd`. It loads and instantiates:

- `scenes/Menu.tscn`
- `scenes/CrystalDash.tscn`
- `scenes/MeteorUmbrella.tscn`
- `scenes/OrbitShooter.tscn`

Run:

```bash
./run_all_smokes.sh
```

The first successful local smoke run produced:

```text
HERMES_PROTOTYPE_PACK_SMOKE_START
PASS instantiate res://scenes/Menu.tscn root=Menu
PASS instantiate res://scenes/CrystalDash.tscn root=CrystalDash
PASS instantiate res://scenes/MeteorUmbrella.tscn root=MeteorUmbrella
PASS instantiate res://scenes/OrbitShooter.tscn root=OrbitShooter
HERMES_PROTOTYPE_PACK_SMOKE_PASS
```
