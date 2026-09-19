KBCF Development State
Purpose
This document records the current development board for KBCF.

It answers:

What exists in the repository?
What has been runtime verified?
What is currently under development?
What remains unresolved?
What is the next milestone?
This document is not a changelog. This document represents the current project board.

Project Context
KBCF and Smart Drone Warfare are exclusively an open-source Arma 3 SQF gameplay, AI orchestration, and autonomous asset framework project.

All drones, contacts, commanders, planners, targets, missions, actions, controllers, payloads, and lifecycle events are virtual Arma 3 gameplay systems.

Repository implementation and Arma runtime evidence define project reality.

Source Of Truth Hierarchy
Current Arma Runtime Evidence
Current Repository Implementation
Current Repository Documentation
Historical Runtime Records
Previous Checkpoints
Speculation
Runtime evidence is final authority. Documentation should reflect runtime where possible.

Current Project Stage
The project has moved beyond proving that the orchestration framework can function.

Current runtime evidence has verified:

Contact Detection → Blackboard Publication → Commander Selection → Reservation → Assignment → Tracking → Prediction → Authorization → Plan Creation → Plan Activation → Action Execution → Physical UAV Movement → Completion → Cleanup → Automatic Retasking

The primary development focus is no longer framework creation. The primary development focus is controller behavior and doctrine implementation inside the verified lifecycle.

Runtime Verified Systems
Core Orchestration
VERIFIED — Blackboard creation, Contact storage, Contact updates, Target classification, Threat evaluation, Target selection, Reservation system, Assignment system, Plan generation, Plan activation, Scheduler orchestration, Terminal cleanup, Automatic retasking.

Physical UAV Control
VERIFIED — Engine startup, Takeoff, Intercept navigation, Intercept arrival detection, Terminal action transitions.

Verified sequence: MOVE_TO_INTERCEPT → Engine Start → Takeoff → Navigate → Intercept Reached → Terminal Action

Action Routing
VERIFIED — shared execution route: executePlan → executeAction → Action Handler.

Fresh runtime verification established successful dispatch for: MOVE_TO_INTERCEPT, RECON, ATTACK, GRENADE_DROP.

The repository also contains routes for: SHADOW, TRACK, OBSERVE, REPOSITION. Repository presence does not establish fresh runtime success for those handlers — current profile-specific runtime status is tracked separately in VERIFIED.md.

SCOUT State Persistence
VERIFIED — plan-owned storage successfully supports persistent SCOUT controller state across multiple ACTIVE scheduler cycles.

Verified fields: scoutState, scoutObserveCycles Verified runtime sequence: OBSERVE cycle 1 → OBSERVE cycle 2 → REPORT → COMPLETE → Terminal Cleanup Verified conclusion: Persistent SCOUT state can operate inside the existing ACTIVE plan lifecycle. No framework redesign required. Scheduler / executePlan / Cleanup ownership unchanged.

SCOUT Prototype V2 — Movement Event Detection
VERIFIED — first runtime-verified SCOUT information-event behavior.

Verified field: scoutMovementState Verified classifications: STATIONARY, MOVING Verified information event: STATIONARY_TO_MOVING Verified runtime evidence: MovementState Initialized, MovementState Check, MovementState Updated, Information Event Detected STATIONARY_TO_MOVING Verified conclusion: Movement-event evaluation operates successfully inside the existing ACTIVE plan lifecycle. No framework redesign required.

SCOUT Prototype V3 — Observation Event Reporting
VERIFIED — movement-event detection expanded into observation-event reporting.

Verified artifacts: observationEvent, lastScoutReport Verified runtime evidence: Information Event Detected, Observation Event Stored, REPORT Consumed Event, REPORT Published Event Verified conclusion: Observation events can persist from OBSERVE into REPORT. No framework redesign required.

FPV_STRIKE — Physical Impact Strike
VERIFIED — fn_actionAttack.sqf rewritten to detonate on genuine physical contact rather than target-attached satchel placement.

Verified: terminal run continues through live target position (no detonation radius, no teleported charge) → physical impact via EpeContactStart → warhead detonation at actual impact position → drone consumed → plan completion → cleanup.

Evidence: Runtime verified in Arma, owner-observed end-to-end.

BOMBER — GRENADE_DROP
VERIFIED — full fix history and verified sequence recorded in VERIFIED.md. Summary: compile bug fixed → premature-completion bug fixed via plan-owned flight-state tracking → payload class iterated (Bo_GB6/HandGrenade/GrenadeHand broken → Bomb_03_F oversized → IEDUrbanSmall_Remote_Ammo correct) → drone breakaway maneuver added for safe separation.

Verified: payload created → breakaway → timed detonation → target destroyed → drone survives → plan completes → cleanup.

Known non-blocking issue: release sound path not found (audio only).

Current SCOUT State
Verified
SCOUT Ownership Audit, SCOUT Controller Specification V1 Draft, SCOUT Controller Pseudocode V1/V2, SCOUT State Integration Prototype, SCOUT State Persistence Verification, SCOUT Prototype V2 Movement Event Detection, SCOUT Prototype V3 Observation Event Reporting.

Prototype Currently Implemented
MOVE_TO_INTERCEPT → RECON → OBSERVE → Movement Evaluation → Event Detection → Observation Event Storage → REPORT → Event Publication → COMPLETE

Current verified movement evaluation: refresh-gated evaluation, horizontal speed classification, STATIONARY/MOVING classification, STATIONARY_TO_MOVING detection. Current verified reporting behavior: observationEvent creation/storage, REPORT event consumption/publication, lastScoutReport publication.

The observe counter remains as a bounded prototype mechanism supporting state progression. It is not doctrine and not intended final gameplay behavior.

Not Yet Implemented
Risk Engine, Confidence Engine, Position Selection, Position Scoring, SEARCH, PATROL, INVESTIGATE, BDA, Multi-contact Intelligence Evaluation, Observation Quality Assessment, Adaptive Repositioning, Intelligence Requirement Completion Logic, MOVING_TO_STATIONARY detection, Information quality evaluation, Confidence accumulation logic.

These remain future controller work.

Current Development Frontier
The persistence question has been answered. The first movement-event detection question has been answered. The first observation-event reporting question has been answered. FPV_STRIKE and BOMBER terminal actions are now runtime verified.

The next question is: what information should SCOUT evaluate next, and what doctrine should govern FPV_STRIKE and BOMBER now that their mechanics are settled?

Current verified behavior: OBSERVE → Movement Evaluation → Event Detection → Event Storage → REPORT → Event Publication

Future direction: OBSERVE → Evaluate → Decide → REPORT

The next behavior should be intentionally small and runtime testable. Do not expand architecture without evidence. Prefer improving behavior within the verified lifecycle.

Current Unknowns
Best observation-position selection method, Observation quality evaluation, Information quality evaluation, Confidence accumulation, Confidence decay, Intelligence requirement completion thresholds, Threat-based reposition thresholds, BDA behavior, Performance at scale, Large multiplayer behavior.

Immediate Milestone
Current milestone: FPV_STRIKE and BOMBER runtime verified end-to-end.

Verified this session:

FPV_STRIKE physical-impact rewrite runtime verified, owner-observed.
BOMBER GRENADE_DROP fully repaired and runtime verified, owner-observed (target destruction + drone survival).
Root causes for both identified and documented in VERIFIED.md / CHANGELOG.md, not just patched blind.
Current Frontier:

Doctrine.md: write FPV_STRIKE and BOMBER sections (currently both TBD) now that behavior is settled.
SCOUT doctrine evolution beyond V3 (observation behavior quality).
SHADOW behavior refinement.
BOMBER release sound path cleanup (non-blocking).
Current Board
VERIFIED

SCOUT

✅ Exists / Runtime Verified / Observation-Oriented Behavior
✅ SHADOW behavior exists / REPORT behavior exists
✅ ObservationCondition instrumentation / MovementState instrumentation / STATIONARY_TO_MOVING reporting
✅ ObservationEvent pipeline / Runtime Tested
🟨 Doctrine refinement continues
FPV_STRIKE

✅ Physical impact detonation verified
✅ Impact-position explosion verified
✅ Target-attached satchel behavior removed
✅ Scheduler completion verified
✅ Cleanup verified
✅ End-to-end lifecycle verified (owner-observed)
BOMBER

✅ Compile bug fixed
✅ Premature-completion bug fixed (plan-owned flight-state tracking)
✅ Payload class corrected (IEDUrbanSmall_Remote_Ammo)
✅ Drone breakaway maneuver verified effective
✅ Payload deployment runtime verified
✅ Target destruction confirmed (owner-observed)
✅ Drone survives (owner-observed)
✅ Plan completion verified
✅ Cleanup verified
⬜ Release sound path (non-blocking, open)
NOT YET VERIFIED

LOST classification
CURRENT → LOST transition
DEGRADED → LOST transition
LOST → DEGRADED transition
LOST → CURRENT transition
Latest Runtime Verification
ObservationCondition instrumentation functioning.
MovementState instrumentation functioning.
STATIONARY_TO_MOVING detection functioning.
ObservationEvent pipeline functioning.
REPORT pipeline functioning.
FPV_STRIKE physical-impact detonation functioning end-to-end.
BOMBER GRENADE_DROP functioning end-to-end (payload, breakaway, detonation, target destruction, drone survival).
Audit Findings
Blackboard stale-contact cleanup is driven by confidence decay from lastSeen.
Contacts expire after approximately five minutes without refresh.
Observed stale-contact behavior was existing framework behavior, not a regression introduced by any new patch.