# KBCF Drone Profiles
Author:KingBleat
## Purpose

This document describes profile-specific drone behavior and the tuning
keys each behavior reads.

Status in this document is **implementation status only**.
Runtime verification belongs in VERIFIED.md.

---

# Survivability Layer

Status: IMPLEMENTED - NOT RUNTIME VERIFIED

Adds terrain/building cover and evasion to the existing action lifecycle.
No scheduler, executePlan, commander, reservation or cleanup ownership
was changed. All behavior lives in Actions and in helper functions under
`src/Survival`.

## Helpers (`src/Survival`)

| Function | Role |
| --- | --- |
| `installFireReaction` | Installs FiredNear / Hit / IncomingMissile handlers once per drone |
| `recordFire` | Handler target. Counts a shot only if the shooter was aiming at the drone |
| `isUnderFire` | True if the drone recorded hostile fire within a time window |
| `getThreats` | Hostile manned entities near the drone or a position, nearest first |
| `isPositionHidden` | Terrain + object line-of-sight test against a list of threats |
| `findCoverPosition` | Finds a hidden hover point (building walls + dead ground) |
| `evadeFire` | One non-blocking evasion step per scheduler cycle |

## Per-profile behavior

### FPV_STRIKE
- MOVE_TO_INTERCEPT flies at `KBCF_STRIKE_APPROACH_HEIGHT` (default 15 m).
- If hostiles are near the target and the target is far enough away,
  flies first to a hidden staging point (`approachStage*` plan keys).
- Evades under fire during MOVE_TO_INTERCEPT.
- ATTACK weaves while under fire until `fpvCommitDistance` (default 60 m),
  then commits so the contact fuze detonates on the target.

### BOMBER
- Same low, cover-staged approach as FPV_STRIKE.
- GRENADE_DROP keeps the existing flight-thread + synchronous-drop
  design (`grenadeDropFlightState`: NOT_STARTED / RUNNING / IN_RANGE /
  TARGET_LOST) and its target-position payload. Only evasion was added:
  the flight thread calls `evadeFire` about 4 times a second and stops
  issuing its own velocity/move commands while a maneuver is active.
- No post-release egress: the action completes on release, as before.

### SCOUT
- Evades under fire during MOVE_TO_INTERCEPT and RECON OBSERVE.
- Scanning and observation-condition evaluation continue while evading;
  only observation-position movement is suspended.

### Shared actions (SHADOW, TRACK, REPOSITION, OBSERVE)
- Each installs fire detection and calls `evadeFire` once per cycle.
- While a maneuver is active the action does not issue its own
  movement or flight-height orders and reports `EVADING_FIRE` with the
  plan still ACTIVE. Normal behavior resumes on the first quiet cycle.
- SHADOW keeps running its recon scan while evading.
- Standalone OBSERVE normally completes in one cycle; under fire it
  holds the plan open until the maneuver ends, then completes.

## Evasion model

1. A new hostile-fire event triggers a maneuver.
2. First engagement: JINK - break perpendicular to the shooter on the
   side terrain does not block, change altitude, lateral velocity kick.
3. `KBCF_EVADE_COVER_AFTER` engagements within `KBCF_EVADE_WINDOW`
   seconds: COVER - break to a hidden hover point.
4. After `KBCF_EVADE_BUDGET` seconds of evasion per plan the drone
   commits to its mission.

## Configuration (`src/Config/Config.sqf`)

`KBCF_SURVIVAL_ENABLED`, `KBCF_THREAT_RANGE`,
`KBCF_STRIKE_APPROACH_HEIGHT`, `KBCF_EVADE_WINDOW`,
`KBCF_EVADE_COVER_AFTER`, `KBCF_EVADE_BUDGET`, `KBCF_EVADE_JINK_MIN`,
`KBCF_EVADE_JINK_MAX`, `KBCF_EVADE_JINK_HOLD`, `KBCF_EVADE_KICK_SPEED`,
`KBCF_EVADE_MIN_HEIGHT`, `KBCF_EVADE_MAX_HEIGHT`,
`KBCF_COVER_SEARCH_INTERVAL`.

Set `KBCF_SURVIVAL_ENABLED = false` to disable the layer without
removing it.

Per-plan overrides (plan HashMap keys): `strikeApproachHeight`,
`approachStageMinDistance`, `fpvCommitDistance`.

## Known limits

- FiredNear is only raised for fairly close shots (about 70 m as far as
  I know), so this reacts to rounds passing near the drone, not to
  long-range fire.
- Cover search runs up to 72 candidates x up to 6 threats of raycasts per
  call and is throttled by `KBCF_COVER_SEARCH_INTERVAL`. Performance at
  scale is unmeasured.
- Low flight height risks tree and building collisions. Tune
  `KBCF_STRIKE_APPROACH_HEIGHT` per map.
