# Prototype Notes

## Crystal Dash

Crystal Dash tests the fastest possible Godot loop: single scene, procedural drawing, timer, collectibles, win/loss feedback.

Future upgrades:

- ghost replay route
- combo multiplier for clean paths
- moving crystals
- level seed selector

## Meteor Umbrella

Meteor Umbrella tests survival pressure and readable hazard pacing.

Future upgrades:

- shield cooldown
- wind lanes
- meteor warning shadows
- online daily seed

## Hermes Orbit: First Mission

Hermes Orbit is the champion prototype. It started as `OrbitShooter`, became `Hermes Orbit: First Run` in v0.2, and now has an authored first mission in v0.3.

v0.3 adds:

- 90-second mission timeline
- named phases: launch, drifter wave, sine gauntlet, meteor corridor, upgrade break, crystal route, mini-boss
- warning lanes before meteors enter
- upgrade break with four choices
- crystal magnet upgrade
- score popups
- mission clear state
- automation methods for testing mission phase jumps

Future upgrades:

- authored boss attack phases
- player hit flash and invulnerability animation
- sound/music pass
- controller support
- screenshot/GIF capture for GitHub
- release build packaging
