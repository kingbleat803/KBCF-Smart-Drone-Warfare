# KBCF Architecture

## Purpose

This document describes system ownership and execution architecture.

Architecture explains:

- Who owns a responsibility.
- How systems interact.
- How plans move through the framework.
- Where controller behaviors execute.

Architecture does not describe implementation status.

Architecture does not imply a behavior exists.

Implementation status belongs in Development_State.md.

Runtime evidence belongs in VERIFIED.md.

---

# Architecture Hierarchy

Gameplay Experience
↓
Doctrine
↓
Controller Design
↓
Architecture
↓
Implementation
↓
Runtime Verification

Architecture defines ownership.

Runtime determines reality.

---

# Core Framework Ownership

## Blackboard

Owns:

- Contact storage
- Contact updates
- Contact memory
- Shared battlefield information
- Persisted mission plans

Does not own:

- Target selection
- Mission assignment
- Mission execution

---

## Commander

Owns:

- Contact evaluation
- Contact prioritization
- Reservation
- Assignment decisions
- Asset allocation

Does not own:

- Physical execution
- Flight behavior
- Controller behavior

---

## Planner

Owns:

- Mission creation
- Plan generation
- Initial action sequencing

Does not own:

- Action execution
- Runtime controller decisions

---

## Scheduler

Owns:

- Plan lifecycle advancement
- ACTIVE cycle execution
- Completion handling
- Cleanup triggering
- Retasking flow

Does not own:

- Controller doctrine
- Action-specific behavior

---

## Action System

Owns:

- Physical behavior execution
- Runtime action logic
- Controller-specific actions

Actions may maintain plan-owned state across scheduler cycles.

---

# Execution Path

Mission execution follows:

Contact
↓
Commander
↓
Reservation
↓
Assignment
↓
Planner
↓
Plan Creation
↓
Scheduler
↓
executePlan
↓
executeAction
↓
Action Handler
↓
Completion
↓
Cleanup
↓
Retasking

---

# Physical UAV Ownership

## MOVE_TO_INTERCEPT

Owns:

- Engine startup
- Takeoff
- Flight altitude
- Navigation
- Intercept movement
- Arrival detection
- Terminal action transition

Verified execution sequence:

MOVE_TO_INTERCEPT
↓
Engine Start
↓
Takeoff
↓
Navigate
↓
Intercept Reached
↓
Terminal Action

---

# Controller Architecture

## Controller Purpose

Controllers define how a profile behaves after reaching its operational phase.

Controllers implement doctrine through runtime decision-making.

Controllers are not doctrine.

Controllers are not architecture.

Controllers execute within architecture.

---

# SCOUT Architecture

## Current Verified Controller Foundation

Runtime verification has established that SCOUT state can persist across ACTIVE scheduler cycles using plan-owned storage.

Verified plan-owned controller state:

- scoutState
- scoutObserveCycles

Verified prototype flow:

MOVE_TO_INTERCEPT
↓
RECON
↓
OBSERVE
↓
OBSERVE
↓
REPORT
↓
COMPLETE
↓
Cleanup

Verified conclusion:

SCOUT controller state can persist within the existing scheduler lifecycle.

No scheduler redesign required.

No executePlan redesign required.

No cleanup redesign required.

---

## SCOUT Ownership

SCOUT owns:

- Observation logic
- Intelligence gathering
- Observation-state progression
- Reporting decisions
- Future confidence evaluation
- Future observation-quality evaluation
- Future reposition decisions

SCOUT does not own:

- Scheduling
- Cleanup
- Retasking
- Plan lifecycle advancement

---

## Current Architectural Status

Verified:

- Plan-owned state persistence
- ACTIVE-cycle state progression
- Observation-state transitions
- Report transition
- Completion transition

Not yet implemented:

- Confidence engine
- Observation quality engine
- Risk evaluation
- Adaptive repositioning
- Search behavior
- Patrol behavior
- BDA behavior
- Intelligence requirement completion logic

These are behavior-layer features, not architecture-layer features.

---

# Automatic Retasking

Ownership:

Scheduler

Flow:

Plan Complete
↓
Cleanup
↓
Assignment Released
↓
Commander Selects New Contact
↓
New Plan Generated

Automatic retasking has been runtime verified.

---

# Architecture Principles

1. Ownership should be explicit.

2. Controllers execute inside the framework rather than replacing it.

3. Architecture should not be expanded without runtime evidence.

4. Verified ownership should not be moved without regression evidence.

5. Doctrine describes desired behavior.

6. Controllers implement behavior.

7. Runtime verification determines reality.

---

# Summary

Framework Ownership
✅ Established

Execution Path
✅ Established

Physical UAV Ownership
✅ Established

SCOUT State Persistence Architecture
✅ Verified

Controller Behavior Expansion
🔄 Ongoing

Current Development Frontier
→ Controller behaviors and doctrine implementation within the verified architecture.