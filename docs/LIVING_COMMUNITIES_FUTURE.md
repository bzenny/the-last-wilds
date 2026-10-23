# Living Monster Communities — Forward Architecture (Q3)

Status: forward design, not part of the first-play vertical slice.

## Guiding premise
Monsters are members of a living community, not expendable towers. Their population, relationships, habitats, and adaptive traits should matter over multiple encounters.

## Data model seams to preserve now
- Stable entity ID independent of position and sprite.
- Species definition separate from individual creature state.
- Individual state: age/life stage, health, energy, experience, home habitat, needs, disposition.
- Community state: territory, nests, food capacity, bonds, population, shared behaviors.
- Traits are data-defined with costs, prerequisites and trade-offs.
- Events: born, matured, bonded, migrated, adapted, injured, died, habitat restored/destroyed.

## Three phases
1. **Identity (after clarity gate):** Persistent named guardians, home habitat, recovery, simple bonds. No reproduction yet.
2. **Community (after ecological simulation stabilizes):** Nests, carrying capacity, breeding conditions, juveniles, migration, care and population pressure.
3. **Evolution (later):** Trait inheritance, adaptation to human pressures, distinct species branches, cultural/learned community practices.

## Avoid
Population micromanagement, exponential reproduction, eugenic optimization framing, forced breeding, disposable creature churn, and invisible genetics. Evolution must create meaningful strategic choices and visible trade-offs.

## First prototype compatibility
The current encounter uses a temporary Kind enum and list-based units. Refactor to stable IDs and separate species templates before adding persistence; do not expand Q3 into the first playable gate.

## Gameplay North Star test
A community feature belongs only if it makes the player care about who is being protected, changes tactical/ecological choices, and remains understandable without a spreadsheet.
