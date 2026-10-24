# The Last Wilds — illustrated vertical slice playtest

## Build status
This branch is an experimental vertical slice. Only use artifacts from a green Godot desktop workflow on the exact commit being tested. Export success is not proof of interactive correctness.

## Core loop
Defend the sanctuary heart (left) against three waves of three human invaders. Each breach reduces habitat by 25; the third breach ends the run. Defeat all humans in all three waves to win. Guardians can be repositioned immediately in this prototype. Wild Energy regenerates one point per simulation tick and defeating a human returns three.

## Controls
- Left-click guardian or keys 1, 2, 3: select Rootling, Brute, Spitter.
- Right-click valid forest cell: reposition selected guardian.
- Q: strike closest human within Manhattan distance four (5 energy).
- E: unique guardian ability (12 energy; seven-tick cooldown).
- Space: pause or resume.
- R: restart.

## Guardian abilities
- Rootling: root snare on its current row within two columns, temporarily stops invaders standing in snared cells.
- Brute: Earthshatter, two damage to enemies within three cells.
- Spitter: Thorn Volley, one damage to enemies within six cells.

## Acceptance test
1. Confirm new HUD has HEART, WILD ENERGY, WAVE and BREACHES.
2. Confirm all three guardians have distinct silhouettes and numbered selection works.
3. Select Rootling, reposition to intercept the top lane and use E. Confirm a snared human stops.
4. Select Brute, move within three cells of humans, use E and confirm defeated invaders disappear.
5. Select Spitter, move within six cells of humans and use E; confirm range and energy cost.
6. Confirm Q attack, pause, restart and energy regeneration.
7. Let three humans breach and verify defeat; restart and defeat all three waves to verify victory.
8. Report readability, difficulty, glitches, or input problems, including OS and build commit.

## Known limitations
This is a first visual/gameplay pass. Guardian movement is instantaneous, AI uses deterministic lanes, and abilities have placeholder effects. No persistence, audio, pathfinding, sprite atlas, accessibility menu, or modding interface yet. No claim of full game completion.
