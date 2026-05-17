# Hermes Godot Prototype Pack

A polished starter pack of tiny Godot 4.5 arcade prototypes created with Hermes Agent.

This repository is the first waypoint in a larger journey: prove that an AI-assisted workflow can rapidly generate, mutate, verify, and organize playable Godot ideas without losing the human-readable project structure.

Current release: **v0.2 — Hermes Orbit: First Run**

## Included prototypes

### 1. Crystal Dash

A 20-second collection sprint. Route through a neon grid and grab all crystals before the timer expires.

- Scene: `scenes/CrystalDash.tscn`
- Script: `scripts/CrystalDash.gd`
- Core loop: movement precision + fast collection routing

### 2. Meteor Umbrella

A survival dodger where meteor pressure ramps over time.

- Scene: `scenes/MeteorUmbrella.tscn`
- Script: `scripts/MeteorUmbrella.gd`
- Core loop: dodge, reposition, survive longer each run

### 3. Hermes Orbit: First Run

The v0.2 champion prototype: a top-down arcade shooter vertical slice with stronger identity and a real run loop.

- Scene: `scenes/OrbitShooter.tscn`
- Script: `scripts/OrbitShooter.gd`
- Core loop: launch, dodge, shoot, collect pickups, survive waves, chase score
- v0.2 features: title overlay, wave system, enemy variants, pickups, shield, rapid fire, repair glyphs, crystal bonuses, particles, screen shake, boss seed, game-over/relaunch flow

## Controls

From the menu:

- `1` — Crystal Dash
- `2` — Meteor Umbrella
- `3` — Hermes Orbit: First Run
- `Esc` — quit

In games:

- `WASD` / Arrow keys — move
- `Space` — start/fire in Hermes Orbit
- `R` — restart current prototype
- `Esc` — return to menu

## Requirements

- Godot 4.5 stable or newer

No asset packs, plugins, or external runtime dependencies are required. Everything is drawn procedurally in GDScript.

## Run locally

Open this folder in Godot 4.5 and run the project. The main scene is:

```text
scenes/Menu.tscn
```

From WSL/Linux with Godot on your PATH:

```bash
godot --path .
```

Mike's local WSL setup can also use:

```bash
~/bin/godot45 --path .
```

## Verification

The project includes a headless smoke test that loads and instantiates every scene, then checks v0.2-specific Hermes Orbit behavior:

```bash
./run_all_smokes.sh
```

Expected result includes:

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

## Project structure

```text
scenes/        Godot scene entry points
scripts/       Game logic and procedural drawing
tools/         Headless verification scripts
docs/          Design notes and development roadmap
```

## Status

v0.2 turns the strongest seed into a first vertical slice. The pack remains lightweight and transparent so it can keep evolving publicly.

## Credits

Built with Godot Engine and Hermes Agent.

## License

MIT. See `LICENSE`.
