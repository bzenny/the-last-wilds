# Architecture
## Modules
- `core`: pure Java, no LWJGL dependency; deterministic simulation, world grid, entities, factions, actions and combat.
- `desktop`: LWJGL GLFW window, OpenGL rendering, input, sound and asset loading.
- `content`: JSON definitions and schema validation (planned).
- `modding`: manifest, dependency resolution, sandboxed declarative assets (planned).

## Core rules
Simulation advances with `tick()` using a fixed time step. UI translates user commands into validated actions. Renderer reads snapshots and never mutates game state. Use seeded RNG injected at world creation. Stable string IDs identify content. Serialization must include schema version.

## Test pyramid
- Unit: world bounds, resource rules, combat damage, evolution costs.
- Simulation: identical seed + action stream yields identical snapshots.
- Content: manifests, duplicate IDs, references and asset constraints.
- Desktop smoke: launch/exit on each OS in release candidate validation.

## Future extension API
JSON manifest with `id`, `version`, `gameVersion`, `dependencies`, `content`. Types: creature, faction, biome, scenario. Never load executable third-party code by default. A curated catalog must verify hashes, licenses and compatibility.

## Build strategy
Gradle multi-project: `core` and `desktop`. GitHub Actions matrix on Windows, Linux and macOS. Early CI tests and compiles; release packaging is a separate later gate.
