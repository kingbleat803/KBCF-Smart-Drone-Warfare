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

## Milestone: SCOUT State Persistence Verification

Status:

Historical runtime milestone

Objective:

Determine whether SCOUT-owned controller state could persist inside the existing ACTIVE plan lifecycle without introducing new framework ownership layers.

Runtime verified sequence:

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

Verified persistent fields:

scoutState

scoutObserveCycles

Verified conclusions:

- Plan HashMap storage persisted SCOUT-owned controller state.
- executePlan ownership remained unchanged.
- Scheduler ownership remained unchanged.
- Cleanup ownership remained unchanged.
- Reservation cleanup remained intact.
- No additional lifecycle owner was required.

Architectural conclusion:

Persistent SCOUT controller behavior operates within the existing ACTIVE lifecycle.

No framework redesign required.

---

## Milestone: Action Router Recovery

Status:

Historical repository milestone

fn_executeAction contained a corrupted action router.

Repair restored:

MOVE_TO_INTERCEPT
↓
Engine Start
↓
Takeoff
↓
Navigation
↓
Action Routing

Verified result:

Physical UAV movement resumed through the intended execution path.

---

## Milestone: SCOUT Prototype V2 Movement Event Detection

Status:

Historical runtime milestone

Objective:

Replace the pure observe-counter persistence test with the first runtime-verifiable information-event behavior.

Implemented:

- scoutMovementState
- Refresh-gated movement evaluation
- Horizontal speed classification
- STATIONARY state
- MOVING state
- STATIONARY_TO_MOVING information event detection

Runtime verified behavior:

Fresh Contact Refresh
↓
Movement Evaluation
↓
Movement Classification
↓
State Comparison
↓
Information Event Detection

Verified runtime evidence:

MovementState Initialized

MovementState Check

MovementState Updated

Information Event Detected | STATIONARY_TO_MOVING

Verified classifications:

STATIONARY

MOVING

Verified information event:

STATIONARY_TO_MOVING

Architectural conclusions:

- Movement-state information persisted on the active plan.
- Plan-owned SCOUT state successfully evolved across ACTIVE scheduler cycles.
- Scheduler ownership remained unchanged.
- executePlan ownership remained unchanged.
- Cleanup ownership remained unchanged.
- No framework redesign was required.

This milestone established the first runtime-verified SCOUT information-event capability.

---

## Current Frontier

See:

- WelcomeBackNotes.md
- Development_State.md
- ROADMAP.md

Current development focus:

SCOUT Prototype V3

The persistence question has been answered.

The movement-event question has been answered.

The next development objective is determining what information SCOUT should evaluate after movement-state detection.

Future candidate areas include:

- Information value evaluation
- Observation quality evaluation
- Confidence evaluation
- Intelligence freshness evaluation

Future work should preserve the verified lifecycle and ownership model unless runtime evidence demonstrates a genuine architectural requirement.