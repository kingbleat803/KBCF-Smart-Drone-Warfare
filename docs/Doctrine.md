# KBCF Controller Doctrine

## Purpose

## Important Distinction

Doctrine describes desired behavior.

Doctrine is not implementation.

Doctrine is not evidence that a behavior currently exists.

A documented behavior becomes project reality only after:

Controller Design
↓
Implementation
↓
Runtime Verification

Implementation status belongs in Development_State.md.

Runtime evidence belongs in VERIFIED.md.

This document defines desired controller behavior.

Doctrine describes what controllers should do.

Doctrine does not describe implementation status.

Doctrine does not imply a behavior exists.

Implementation and runtime verification are tracked separately.

---

# Doctrine Hierarchy

Gameplay Experience
↓
Doctrine
↓
Controller Design
↓
Implementation
↓
Runtime Verification

Doctrine provides direction.

Runtime determines reality.

---

# SCOUT Doctrine

## Mission

Provide useful battlefield intelligence while preserving survivability and maintaining observation capability.

---

## Core Priorities

1. Survivability
2. Observation Quality
3. Intelligence Collection
4. Intelligence Maintenance
5. Reporting

---

## Desired Behaviors

SCOUT should:

- Maintain observation of assigned intelligence requirements.
- Seek useful observation positions.
- Reposition when observation quality becomes unacceptable.
- Avoid unnecessary exposure.
- Adapt to changing battlefield conditions.
- Continue generating intelligence while operational.
- Verify observations before reporting.
- Maintain awareness of multiple relevant contacts when possible.

---

## Desired Decision Areas

SCOUT decisions may consider:

- Observation quality
- Distance
- Visibility
- Threat exposure
- Confidence level
- Available observation positions
- Mission requirements
- Intelligence value

---

## Desired Characteristics

SCOUT should be:

- Persistent
- Adaptive
- Survivable
- Information focused
- Resource conscious
- Autonomous

---

## Mission Completion

A SCOUT task is considered complete when:

- Intelligence requirements have been satisfied

OR

- Further observation is no longer beneficial

OR

- The controller determines continuation is not justified according to doctrine.

---

# FPV_STRIKE Doctrine

(TBD)

---

# BOMBER Doctrine

# BOMBER Doctrine

## Mission
Deliver area-of-effect ordnance against infantry and soft targets while
surviving the pass for re-tasking.

## Core Priorities
1. Target correctly (infantry / soft targets only)
2. Payload delivery accuracy
3. Drone survivability (reusable asset)
4. Re-tasking readiness after drop

## Desired Behaviors
BOMBER should:
- Close to effective drop radius before releasing payload
- Release munition appropriate to target class
- Survive the pass (distinguishing it from FPV_STRIKE)
- Report completion and become available for retasking

## Known Constraints
- Default munition (Bo_GB6) is a fragmentation charge: effective vs.
  infantry, not effective vs. armored vehicles.
- Anti-armor targets should be routed to FPV_STRIKE instead, or BOMBER
  needs a configurable warheadClass (mirroring fn_actionAttack.sqf's
  pattern) before it can be considered for vehicle targets.

## Mission Completion
A BOMBER task is considered complete when the munition has been
released and the plan reaches COMPLETE, regardless of confirmed kill —
kill confirmation (BDA) is separate, not-yet-implemented future work.

---

# Notes

Doctrine is a behavioral target.

Doctrine does not indicate current implementation state.

A documented behavior is not considered complete until implemented and runtime verified.