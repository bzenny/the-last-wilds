# First Play and Gameplay Validation v0.2

Status: design proposal; not implemented or playtested.

## North Star
Every decision makes the player feel like a guardian of a living wilderness defending its future against expanding civilization.

## Controls decision (provisional)
Pausable real-time tactical guardians plus light ecology management. Left-click select/inspect; right-click move or target; 1–3 guardian selection; Q/E abilities; Space pause; WASD pan; wheel zoom; Esc menu. Guardians auto-attack and act according to stance. No direct action combat.

## Ten-minute first-play script
| Time | Situation | Player decision | Feedback |
| --- | --- | --- | --- |
| 0:00–1:00 | Sanctuary and logging route visible | Inspect threat | Highlight logging target, sanctuary health and forest tiles |
| 1:00–2:00 | First logger approaches | Select and position Rootling | Range indicator and movement path |
| 2:00–3:00 | Logger begins cutting | Root/snare or reposition | Tree biomass falls; logger visibly slowed |
| 3:00–4:00 | Player earns Wild Energy | Regrow tile or save energy | Immediate terrain change and resource cost |
| 4:00–5:30 | Guard escorts logger | Deploy Brute or maneuver Rootling | Different attack/defense roles become clear |
| 5:30–7:00 | Settler attempts road outpost | Choose to defend chokepoint or reclaim road | Telegraph construction and supply line |
| 7:00–8:30 | Two threats converge | Use Spitter at range or redistribute team | Legible enemy intent and outcome |
| 8:30–10:00 | Expansion wave resolves | Protect sanctuary; review results | Win/loss, habitat restored/lost, replay prompt |

## Player-facing clarity rules
Always show: sanctuary integrity, Wild Energy, selected unit, current objective, incoming threat direction, human intent, threatened habitat, and action cost. Telegraph irreversible construction and major damage before resolution.

## Measurement plan
Recruit >=5 first-time players for formative usability tests, then >=15 for an alpha readiness round. No coaching except accessibility accommodations. Record task success, time, help requests, confusion points, reasons for defeat, and replay interest.

## Proposed gates
- >=80% identify objective within 60 seconds.
- >=80% issue a correct guardian command unaided.
- >=80% identify next expansion target.
- >=80% explain consequence of last action.
- >=70% identify two viable responses.
- >=70% voluntarily replay or report desire to replay.
- No critical softlocks; deterministic replay for seeded scenario.

## Fun-factor diagnostics
Observe meaningful choices per minute, strategy diversity, perceived fairness, and whether losses suggest an actionable improvement. Do not infer fun from raw session length alone.

## Scope lock
Do not implement sophisticated combat, expansion AI, evolution, or mod browsing until control and first-play design are reviewed. Build/CI verification can proceed independently.
