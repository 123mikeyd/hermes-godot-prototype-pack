# Hermes Godot Prototype Pack Report

Created: 2026-05-16
Updated: v0.3

Project path:

`/mnt/c/Users/Mike/Desktop/HermesGodotPrototypePack`

Windows path:

`C:\Users\Mike\Desktop\HermesGodotPrototypePack`

## What is in the pack

A Godot 4.5 project with a menu and three tiny playable prototypes.

### 1. Crystal Dash

Fast 20-second collection sprint.

- Move a blue orb around a neon grid.
- Collect all 10 crystals before the timer expires.
- Immediate arcade loop: route planning + twitch movement.

### 2. Meteor Umbrella

Survival dodger.

- Green player with a little umbrella arc.
- Procedural red/orange meteors fall faster over time.
- Survive as long as possible.

### 3. Hermes Orbit: First Mission

v0.3 champion authored mission.

- 90-second mission timeline.
- Launch corridor.
- Drifter wave.
- Sine gauntlet.
- Meteor corridor with warning lanes.
- Upgrade break with Rapid/Shield/Repair/Magnet.
- Crystal route.
- Mini-boss phase.
- Score popups, particles, screen shake, mission clear.
- Debug methods for automated smoke tests.

## Verification performed

Godot 4.5 headless smoke test loads and instantiates all scenes and verifies v0.3 Hermes Orbit behavior.

Run:

```bash
./run_all_smokes.sh
```

## Play visually

Open the folder in Godot 4.5 and run the project. The main scene is the menu.

If launching from WSL with the installed binary:

```bash
cd /mnt/c/Users/Mike/Desktop/HermesGodotPrototypePack
~/bin/godot45 --path .
```
