# Prototype Test Plan

## Goal
Validate the Hybrid B+C loop before expanding AI, content, art or modding.

## Paper prototype (first)
Use a 12x8 grid with forest, road, river, sanctuary, three guardians, one logger, one guard and one settler. Advance in ten-second planning increments. Player chooses one guardian order and one Wild Energy action per turn. Log the resulting map changes.

## First 10 minutes
0–2: learn sanctuary and logger intent, command Rootling.
2–4: choose snare or regrowth, observe biomass change.
4–6: guard arrives, use Brute to hold or disrupt.
6–8: settler tries outpost, use Spitter to deny road or convoy.
8–10: resolve threats and review sanctuary/habitat outcomes.

## Test instrumentation
Per action record timestamp, selected guardian, issued command, intended effect, actual effect, energy cost, habitat delta, human plan delta, and any help request. No personally identifiable data by default.

## Design gate
Five unfamiliar players for formative testing, 15+ for alpha gate. Target >=80% objective/control/threat/cause-effect clarity, >=70% two-strategy identification and replay interest. Qualitative debrief is required even if thresholds pass.

## Build acceptance
CI compiles and tests core on Windows/Linux/macOS; desktop launches on supported machines; seeded scenario reproduces same outcome; no softlocks; pause freezes simulation.

## Scope rule
Do not add more units, biomes, online mods or art complexity until the first slice meets the clarity gate.
