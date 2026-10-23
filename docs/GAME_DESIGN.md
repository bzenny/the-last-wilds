# The Last Wilds — Game Design Document (v0.1)
## High concept
A 2D top-down territorial ecology strategy game. The player leads monster guardians defending an ancient sanctuary as human settlers expand roads, farms, logging camps, and forts. Humans have understandable needs; conflict and coexistence are possible.

## Design pillars
1. **Territory matters:** Terrain, connectivity, habitat and resources affect every decision.
2. **Two living systems:** Humans expand for resources and safety; wild creatures respond to habitat pressures.
3. **Readable tactics:** Distinct monsters, telegraphed enemy intents, concise actions.
4. **Meaningful adaptation:** Evolution trades strengths against costs.
5. **Moddable by design:** Content is data, with stable IDs and schema validation.

## MVP player loop
Inspect map → select guardian → place or move guardian → advance fixed-tick simulation → repel incursions → restore habitat → gain Wild Energy → upgrade or evolve → defend next incursion.

## Core resources
- Wild Energy: gained from thriving habitats, spent on deployment and upgrades.
- Habitat Integrity (0–100): measures forest health; affects regeneration.
- Human Supplies: accumulated from accessible farms/logging sites; fuels construction.
- Settlement Pressure: calculated from population, resources, routes and threat.

## Monster roster (MVP)
| Species | Role | Ability | Weakness |
| --- | --- | --- | --- |
| Rootling | Support/control | Regrow tile; root enemy | Fragile |
| Brute | Tank/melee | Knockback | Slow |
| Spitter | Ranged/harassment | Corrosive projectile | Low armor |

Evolution is a choice between mutually exclusive branches, e.g. Rootling: rapid regeneration vs stronger immobilization. Each branch costs Wild Energy and has ecological consequences.

## Human roster (MVP)
- Logger: harvests nearby forest; retreats from heavy threat.
- Settler: constructs an outpost when connected to a road and supplied.
- Guard: protects civilians and attacks threatening monsters.

## Human expansion algorithm
Each planning interval, evaluate candidate actions: forage, log, extend road, build farm, establish outpost, defend, retreat. Score by food deficit, timber deficit, road reachability, distance, safety, and local habitat. Select best affordable legal action. No teleporting construction.

## Ecology model
Tile fields: terrain, fertility, biomass, moisture, corruption, owner/influence, traversability. Logging reduces biomass; roads fragment habitat; regrowth restores biomass where moisture/fertility permit. Healthy contiguous habitat increases monster regeneration and Wild Energy production. Numbers initially tuned for readability, not realism.

## Territory and victory
MVP: five invasion waves; victory if sanctuary survives; defeat if sanctuary integrity reaches zero. Post-MVP: alternative victory through reclaiming contested regions or negotiated boundaries. Nonlethal deterrence is a viable strategic option.

## Replayability
Seeded maps, different entry points, resource distribution, evolving settlement goals, monster evolution branches, difficulty modifiers, and scenario packs. Same seed and inputs should reproduce a run.

## Scope control
v0.1: one forest biome, three monster units, three human units, 32×24 map, one sanctuary, fixed-step simulation, five waves, basic UI. No multiplayer, online workshop, executable mods or complex diplomacy in MVP.

## Accessibility
Remappable keys (later milestone), scalable UI, color-independent faction cues, pause/speed controls, readable combat indicators.

## Design risks and tests
- Runaway expansion: cap construction and require supplies.
- Snowballing guardians: upkeep and evolving human counterplay.
- Performance: fixed-step simulation, spatial queries, pooling later if profiling warrants.
- Balance: deterministic seeded scenario tests and telemetry only with consent.

## Future milestones
v0.2 tactical roster; v0.3 organic expansion and ecology; v0.4 campaign/save/load; v0.5 public alpha; v0.6 declarative mods; v1.0 polished stable release.
