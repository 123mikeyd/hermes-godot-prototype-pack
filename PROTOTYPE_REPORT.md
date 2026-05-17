# Hermes Godot Prototype Pack Report

Created: 2026-05-16

Project path:

`/mnt/c/Users/Mike/Desktop/HermesGodotPrototypePack`

Windows path:

`C:\Users\Mike\Desktop\HermesGodotPrototypePack`

## What I made

A Godot 4.5 project with a menu and three tiny playable prototypes.

### 1. Crystal Dash

Fast 20-second collection sprint.

- Move a blue orb around a neon grid.
- Collect all 10 crystals before the timer expires.
- Immediate arcade loop: route planning + twitch movement.

Scene:

`scenes/CrystalDash.tscn`

Script:

`scripts/CrystalDash.gd`

### 2. Meteor Umbrella

Survival dodger.

- Green player with a little umbrella arc.
- Procedural red/orange meteors fall faster over time.
- Survive as long as possible.

Scene:

`scenes/MeteorUmbrella.tscn`

Script:

`scripts/MeteorUmbrella.gd`

### 3. Orbit Shooter

Tiny top-down arcade shooter.

- Triangular ship.
- WASD/Arrows move.
- Space fires shots upward.
- Procedural pink orb enemies drift downward.
- Score and lives UI.

Scene:

`scenes/OrbitShooter.tscn`

Script:

`scripts/OrbitShooter.gd`

## Menu

Main scene:

`scenes/Menu.tscn`

The menu lets you press:

- `1` for Crystal Dash
- `2` for Meteor Umbrella
- `3` for Orbit Shooter
- `Esc` to quit

## Shared controls

- WASD / Arrow keys: move
- Space: shoot in Orbit Shooter
- R: restart current game
- Esc: return to menu

## Verification performed

Godot 4.5 headless smoke test successfully loaded and instantiated all scenes.

Log file:

`proof_logs/smoke_all.stdout.log`

Successful log contents included:

```text
HERMES_PROTOTYPE_PACK_SMOKE_START
PASS instantiate res://scenes/Menu.tscn root=Menu
PASS instantiate res://scenes/CrystalDash.tscn root=CrystalDash
PASS instantiate res://scenes/MeteorUmbrella.tscn root=MeteorUmbrella
PASS instantiate res://scenes/OrbitShooter.tscn root=OrbitShooter
HERMES_PROTOTYPE_PACK_SMOKE_PASS
```

## Run smoke check

From WSL:

```bash
cd /mnt/c/Users/Mike/Desktop/HermesGodotPrototypePack
./run_all_smokes.sh
```

From Windows:

Double-click:

`RUN_PROTOTYPE_PACK_FROM_WSL.bat`

## Play visually

Open the folder in Godot 4.5 and run the project. The main scene is the menu.

If launching from WSL with the installed binary:

```bash
cd /mnt/c/Users/Mike/Desktop/HermesGodotPrototypePack
~/bin/godot45 --path .
```
