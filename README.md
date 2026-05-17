# Hermes Godot Prototype Pack

A polished starter pack of tiny Godot 4.5 arcade prototypes created with Hermes Agent.

This repository is the first waypoint in a larger journey: prove that an AI-assisted workflow can rapidly generate, mutate, verify, and organize playable Godot ideas without losing the human-readable project structure.

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

### 3. Orbit Shooter

A tiny top-down arcade shooter with procedural orb enemies.

- Scene: `scenes/OrbitShooter.tscn`
- Script: `scripts/OrbitShooter.gd`
- Core loop: move, shoot, protect your lives, chase score

## Controls

From the menu:

- `1` — Crystal Dash
- `2` — Meteor Umbrella
- `3` — Orbit Shooter
- `Esc` — quit

In games:

- `WASD` / Arrow keys — move
- `Space` — shoot in Orbit Shooter
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

The project includes a headless smoke test that loads and instantiates every scene:

```bash
./run_all_smokes.sh
```

Expected result:

```text
HERMES_PROTOTYPE_PACK_SMOKE_START
PASS instantiate res://scenes/Menu.tscn root=Menu
PASS instantiate res://scenes/CrystalDash.tscn root=CrystalDash
PASS instantiate res://scenes/MeteorUmbrella.tscn root=MeteorUmbrella
PASS instantiate res://scenes/OrbitShooter.tscn root=OrbitShooter
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

Early prototype pack. The goal is not one finished game yet — it is a clean, expandable launchpad for Godot experiments.

## Credits

Built with Godot Engine and Hermes Agent.

## License

MIT. See `LICENSE`.
