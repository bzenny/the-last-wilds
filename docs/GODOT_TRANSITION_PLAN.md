# Godot transition and first playable plan

Status: proposed implementation branch; no verified playable build yet.

## Preserve
- Keep main and existing Java/Gradle code intact until the Godot slice passes acceptance.
- Preserve GAMEPLAY_NORTH_STAR, HYBRID_GAMEPLAY_SPEC, FIRST_PLAY_AND_VALIDATION, and other design documents.
- Retain deterministic seeded simulation, explicit commands, snapshots, and data-driven content as architectural goals; port behavior rather than assuming Java source can be reused directly.

## Target stack
Godot 4.x (pin exact version in CI), GDScript, 2D tile-based scene, GitHub Actions for headless import/tests and desktop exports. Open-source assets with documented licenses.

## First playable scope
32x24 forest; sanctuary; Rootling, Brute, Spitter; logger, guard, settler; one road; five escalating encounters; Wild Energy; habitat health; pause; clear victory/defeat and replay.

## Execution gates
1. Bootstrap Godot project in a separate directory with a minimal launchable scene, input map and placeholder shapes.
2. Configure Linux headless import/check and deterministic logic tests; add Windows/macOS exports after pinning templates and verifying builds.
3. Implement selection, movement, pause and telegraphed human intent; no advanced AI before clarity review.
4. Add three guardian roles and basic ecology effects.
5. Publish a downloadable build artifact and conduct first-play testing with >=5 new players.
6. Iterate until clarity gates in FIRST_PLAY_AND_VALIDATION pass, then consider replacing Java implementation.

## Definition of done for first playable
Fresh checkout opens in pinned Godot; automated checks pass; downloadable build launches on target desktop OS; a player can finish or lose a 10-minute scenario, explain the threat and consequences, and replay without developer help.

## Constraints
Do not remove legacy code on this branch; no online mod browser or large art pipeline before playable clarity. All gameplay code changes through reviewable pull requests.
