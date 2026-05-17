# Hermes Godot Prototype Pack

A polished starter pack of tiny Godot 4.5 arcade prototypes created with Hermes Agent.

This repository is the first waypoint in a larger journey: prove that an AI-assisted workflow can rapidly generate, mutate, verify, and organize playable Godot ideas without losing the human-readable project structure.

Current release: **v0.3 — Hermes Orbit: First Mission**

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

### 3. Hermes Orbit: First Mission

The v0.3 champion prototype: an authored 90-second top-down arcade mission with Star Fox / rail-shooter energy and neon score-chase readability.

- Scene: `scenes/OrbitShooter.tscn`
- Script: `scripts/OrbitShooter.gd`
- Core loop: launch, dodge, shoot, read warning lanes, choose an upgrade, clear the mini-boss
- v0.3 features: authored mission timeline, mission phases, meteor warning lanes, upgrade break, crystal route, magnet upgrade, score popups, mini-boss, mission-clear state

## Controls

From the menu:

- `1` — Crystal Dash
- `2` — Meteor Umbrella
- `3` — Hermes Orbit: First Mission
- `Esc` — quit
- `Q` — quit anywhere

In games:

- `WASD` / Arrow keys — move
- `Space` — start/fire in Hermes Orbit
- `R` — restart current prototype
- `Esc` — return to menu
- `Q` — quit immediately from any scene

Hermes Orbit upgrade break:

- `1` — Rapid Fire
- `2` — Shield Mantle
- `3` — Repair Burst
- `4` — Crystal Magnet
- `Space` — default Rapid Fire

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

The project includes a headless smoke test that loads and instantiates every scene, then checks v0.3-specific Hermes Orbit behavior:

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
PASS Hermes Orbit v0.3 exposes force_mission_time()
PASS Hermes Orbit v0.3 exposes choose_upgrade()
PASS Hermes Orbit reports v0.3
PASS Hermes Orbit authored mission reaches meteor corridor
PASS Hermes Orbit offers upgrade choice at mission break
PASS Hermes Orbit applies magnet upgrade
PASS Hermes Orbit authored mission reaches mini-boss
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

v0.3 turns Hermes Orbit from a random wave survival loop into a first authored mission. The next step is a feel/juice pass and capture media for the public repo.

## Credits

Built with Godot Engine and Hermes Agent.

## License

MIT. See `LICENSE`.
