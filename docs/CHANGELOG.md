# KBCF Change Log

## Purpose

This document records historical project milestones.

This document records:

- Implemented changes
- Repository milestones
- Historical runtime checkpoints
- Major design decisions

This document is historical in nature.

Historical entries must not be interpreted as current runtime verification.

Current runtime status is tracked separately in Development_State.md.

---

# Major Milestones

## Milestone: Core Orchestration Framework

Status:
Historical milestone

Repository development established:

- Blackboard
- Commander
- Planner
- Scheduler
- Assignment lifecycle
- Cleanup lifecycle
- Retasking lifecycle

Repository documentation records historical runtime validation of the core orchestration lifecycle.

---

## Milestone: Autonomous Orchestration

Status:
Historical milestone

Repository documentation records historical testing covering:

Detection
→ Assignment
→ Planning
→ Execution
→ Completion
→ Cleanup
→ Retasking

Current runtime status requires fresh verification.

---

## Milestone: SHADOW Runtime Checkpoint

Status:
Historical runtime record

Repository documentation records a successful SHADOW runtime checkpoint.

Current runtime status remains unknown until retested.

---

## Milestone: FPV_STRIKE Runtime Checkpoint

Status:
Historical runtime record

Repository documentation records:

- Assignment
- MOVE_TO_INTERCEPT
- ATTACK transition
- Terminal lethality
- Completion
- Cleanup

Physical impact behavior was not demonstrated.

Current runtime status remains unknown until retested.

---

## Milestone: Controller Design Workflow Adoption

Status:
Design milestone

Project development workflow standardized as:

Desired Arma Behavior
↓
Doctrine
↓
Controller Specification
↓
Pseudocode
↓
SQF
↓
Runtime

This milestone marked the shift from framework creation toward controller behavior development.

---
MOVE_TO_INTERCEPT
↓
RECON
↓
OBSERVE cycle 1
↓
OBSERVE cycle 2
↓
REPORT
↓
COMPLETE
↓
Terminal Cleanup

Plan HashMap storage persisted SCOUT-owned data.

scoutState persisted across scheduler cycles.

scoutObserveCycles persisted across scheduler cycles.

executePlan retained ownership of plan completion.

scheduler retained ownership of cleanup.

Reservation cleanup remained intact.

No additional lifecycle owner was required.

fn_executeAction contained a corrupted action router.

Repair restored:

MOVE_TO_INTERCEPT
Engine Start
Takeoff
Navigation
Action Routing

Conclusion
SCOUT-owned state persistence inside the existing
ACTIVE plan lifecycle is runtime verified.

No framework redesign is required to support
persistent SCOUT controller behavior.

## Current Frontier

See:

- WelcomeBack.md
- Doctrine.md
- Development_State.md

for current project status.

