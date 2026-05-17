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

## Hermes Orbit: First Run

Hermes Orbit is the v0.2 champion prototype. It started as `OrbitShooter` and now has enough systems to evaluate as a real first playable:

- title overlay and relaunch flow
- acceleration-based player feel
- twin-shot firing
- wave scaling
- enemy variants: drifter, sine, meteor, boss seed
- pickups: crystal, repair, shield, rapid fire
- particles and screen shake
- debug API used by headless smoke tests

Future upgrades:

- distinct enemy silhouettes
- authored first mission instead of pure random spawns
- boss attack patterns
- sound/music pass
- controller support
- screenshot/GIF capture for GitHub
