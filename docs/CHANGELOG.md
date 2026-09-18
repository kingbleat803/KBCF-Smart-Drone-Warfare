## KBCF Change Log

### Purpose

This document records historical project milestones.

This document records:

- Implemented changes
- Repository milestones
- Historical runtime checkpoints
- Major design decisions

This document is historical in nature.

Historical entries must not be interpreted as current runtime verification.

Current runtime status is tracked separately in Development_State.md.

## Major Milestones

### Milestone: Core Orchestration Framework

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

### Milestone: Autonomous Orchestration

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

### Milestone: SHADOW Runtime Checkpoint

Status:

Historical runtime record

Repository documentation records a successful SHADOW runtime checkpoint.

Current runtime status remains unknown until retested.

---

### Milestone: FPV_STRIKE Runtime Checkpoint

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

### Milestone: Controller Design Workflow Adoption

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

### Milestone: SCOUT State Persistence Verification

Status:

Historical runtime milestone

Objective:

Determine whether SCOUT-owned controller state could persist inside the existing ACTIVE plan lifecycle without introducing additional ownership layers.

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

Verified Findings:

Plan HashMap storage persisted SCOUT-owned data.

scoutState persisted across scheduler cycles.

scoutObserveCycles persisted across scheduler cycles.

executePlan retained ownership of plan completion.

scheduler retained ownership of cleanup.

Reservation cleanup remained intact.

No additional lifecycle owner was required.

Verified Conclusion:

SCOUT-owned state persistence inside the existing ACTIVE plan lifecycle is runtime verified.

No framework redesign is required to support persistent SCOUT controller behavior.

---

### Milestone: Action Router Recovery

Status:

Historical repository milestone

Problem:

fn_executeAction contained a corrupted action router.

Repair restored:

MOVE_TO_INTERCEPT

Engine Start

Takeoff

Navigation

Action Routing

Verified Result:

Physical UAV movement resumed through the intended execution path.

The execution path:

executePlan
↓
executeAction
↓
Action Handler

was successfully restored.

---

### Milestone: SCOUT Prototype V2 Movement Event Detection

Status:

Historical runtime milestone

Objective:

Expand beyond persistence verification and implement the first runtime-verifiable SCOUT information-event behavior.

Implemented:

- scoutMovementState
- Refresh-gated movement evaluation
- Horizontal speed classification
- STATIONARY classification
- MOVING classification
- STATIONARY_TO_MOVING information event detection

Runtime verified evidence:

MovementState Initialized

MovementState Check

MovementState Updated

Information Event Detected | STATIONARY_TO_MOVING

Verified classifications:

STATIONARY

MOVING

Verified information event:

STATIONARY_TO_MOVING

Verified conclusion:

Movement-state information can persist and evolve inside the existing ACTIVE plan lifecycle.

Plan-owned storage supports movement-state evaluation.

Plan ownership unchanged.

Scheduler ownership unchanged.

executePlan ownership unchanged.

Cleanup ownership unchanged.

No framework redesign required.

This milestone established the first runtime-verified SCOUT information-event capability.

---
#### Milestone: SCOUT Prototype V3 Observation Event Reporting

Status:

Historical runtime milestone

Objective:

Extend SCOUT beyond movement-event detection and verify
that observation events can survive until REPORT and be
published to contact intelligence.

Implemented:

- observationEvent storage
- REPORT event consumption
- REPORT event publication
- lastScoutReport contact publication

Runtime verified evidence:

Information Event Detected
Observation Event Stored
REPORT Consumed Event
REPORT Published Event

Verified conclusion:

Observation-event data successfully persisted
from OBSERVE into REPORT.

REPORT successfully consumed stored
observation-event data.

REPORT successfully published observation
information to the assigned contact.

No ownership changes were required.

No framework redesign was required.

This milestone established the first
runtime-verified SCOUT observation-event
reporting capability.

### Current Frontier

See:

- WelcomeBackNotes.md
- Doctrine.md
- Development_State.md
- ROADMAP.md

for current project status.

The persistence question has been answered.

The first movement-event detection question has been answered.

Current development focus is identifying the next meaningful intelligence-evaluation behavior while preserving the verified lifecycle and ownership model.