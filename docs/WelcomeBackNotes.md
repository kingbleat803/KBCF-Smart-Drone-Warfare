# Welcome Back Notes

## Purpose

This file is a rapid recovery guide for future development sessions.

This file is NOT the source of truth.

Detailed project status must always be obtained from:

- Development_State.md
- VERIFIED.md
- ROADMAP.md
- CHANGELOG.md

Runtime evidence and current repository implementation remain the ultimate authorities.

---

## Project Context

KBCF and Smart Drone Warfare are exclusively an open-source Arma 3 SQF gameplay, AI orchestration, and autonomous asset framework project.

All drones, commanders, contacts, planners, targets, missions, actions, payloads, movement systems, and lifecycle events referenced throughout the repository are virtual Arma 3 gameplay systems.

Repository implementation and Arma runtime evidence define project reality.

---

## Current Project Status

Core orchestration is runtime verified.

Physical UAV movement is runtime verified.

Action routing is runtime verified.

SCOUT state persistence is runtime verified.

SCOUT Prototype V2 movement-event detection is runtime verified.

Current development frontier is SCOUT Prototype V3.

---

## Most Recent Milestone

### SCOUT Prototype V2 Movement Event Detection

Verified:

- scoutMovementState
- STATIONARY classification
- MOVING classification
- STATIONARY_TO_MOVING event detection

Verified runtime evidence:

- MovementState Initialized
- MovementState Check
- MovementState Updated
- Information Event Detected | STATIONARY_TO_MOVING

---

## Verified Architectural Conclusions

The following questions have already been answered through runtime verification.

SCOUT state persistence works.

Plan-owned storage successfully supports persistent SCOUT controller state across ACTIVE scheduler cycles.

Movement-event evaluation works.

Plan-owned storage successfully supports movement-state persistence and comparison.

No framework redesign is currently required.

Scheduler ownership remains unchanged.

executePlan ownership remains unchanged.

Cleanup ownership remains unchanged.

No additional lifecycle owner has been shown necessary.

---

## Current Frontier

The persistence question has been answered.

The movement-event detection question has been answered.

The current question is:

What information should SCOUT evaluate next?

Current verified behavior:

OBSERVE
↓
Movement Evaluation
↓
Event Detection
↓
REPORT

Future direction:

OBSERVE
↓
Evaluate
↓
Decide
↓
REPORT

---

## Current Candidate Directions

Smallest-first philosophy remains in effect.

Candidate V3 directions:

- MOVING_TO_STATIONARY detection
- Information quality evaluation
- Confidence evaluation
- Observation quality assessment

The next milestone should remain intentionally small and runtime testable.

---

## Do Not Reopen Without New Evidence

The following questions have already been resolved and documented:

- Confidence does not represent SCOUT progress.
- Freshness does not represent SCOUT progress.
- SCOUT state persistence is runtime verified.
- Movement-event detection is runtime verified.
- Plan-owned SCOUT state is sufficient.
- Scheduler ownership remains unchanged.
- executePlan ownership remains unchanged.
- Cleanup ownership remains unchanged.
- No framework redesign is currently justified.

These conclusions were resolved through repository analysis and/or runtime verification as documented in VERIFIED.md and Development_State.md.

Future sessions should start from these conclusions unless newer evidence supersedes them.

Reopen only if:

- Runtime evidence contradicts an existing conclusion.
- Repository implementation changes.
- A regression is observed.
- New runtime behavior exposes an unmet responsibility.

Do not reopen solved architectural questions based solely on theory, speculation, or familiarity with past discussions.

---

## Recovery Workflow

When starting a new session:

1. Read this file.
2. Read Development_State.md.
3. Read VERIFIED.md.
4. Read ROADMAP.md.
5. Read CHANGELOG.md.
6. Confirm current repository implementation.
7. Confirm current runtime evidence.
8. Continue from the current frontier rather than historical uncertainty.

---

## Session Goal Reminder

Current milestone sequence:

SCOUT State Persistence Verification
↓
SCOUT Prototype V2 Movement Event Detection
↓
SCOUT Prototype V3 Intelligence Evaluation

The current frontier is intelligence evaluation, not architecture redesign.