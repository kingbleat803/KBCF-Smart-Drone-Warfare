# KBCF Development State

## Purpose

This document records the current KBCF development board.

It answers:

- What currently exists in the repository?
- What does repository documentation record as historically runtime tested?
- What has been verified in the current Arma runtime?
- What work is presently being designed?
- What has not yet been implemented?
- What is the next project milestone?

This document must not promote historical checkpoints, design decisions,
saved context, or implementation claims into current runtime facts.

---

# Project Context

KBCF and Smart Drone Warfare are exclusively an open-source Arma 3 SQF
gameplay, controller, and AI-orchestration project.

All drones, contacts, commanders, controllers, targets, missions, attack
actions, payloads, spawning, movement, damage, and lifecycle events are
virtual Arma 3 simulation mechanics.

Profile and state names such as:

- SCOUT
- SHADOW
- FPV_STRIKE
- BOMBER
- ATTACK
- MOVE_TO_INTERCEPT
- Commander
- Blackboard
- Planner
- Scheduler

are Arma 3 gameplay identifiers, SQF function names, profile names, state
identifiers, or thematic labels.

They do not redefine the project beyond its Arma 3 gameplay context.

---

# Source-of-Truth Hierarchy

Use evidence in this order:

1. Current Arma runtime evidence
2. Current repository implementation
3. Current repository documentation
4. Current commits and historical exports
5. Previous handoffs and saved context
6. Speculation

Historical runtime documentation is not automatically current runtime
verification.

Repository implementation proves that code exists.

Only Arma runtime evidence proves current behavior.

---

# Current Project Stage

KBCF has progressed beyond proving that its core orchestration architecture
can function.

Repository documentation records historical end-to-end runtime checkpoints
covering:

Detection
→ Blackboard publication
→ Commander selection
→ Reservation
→ Assignment
→ Tracking
→ Prediction
→ Authorization
→ Plan creation
→ Plan execution
→ Action routing
→ Physical UAV movement
→ Plan completion
→ Reservation release
→ Assignment cleanup
→ Automatic retasking

These are historical runtime records preserved in the repository.

They must not be described as fresh current-runtime passes until the relevant
behavior has been tested again in Arma.

The current development frontier is primarily:

- Asset behavior
- Controller behavior
- Doctrine implementation
- Player-facing battlefield behavior
- Profile-specific lifecycle development
- Runtime verification of newly implemented behavior
- Gameplay refinement and presentation

The working project direction is:

Teach assets how to behave within the existing framework.

Do not reopen or rewrite the core orchestration framework without specific
repository or runtime evidence of a regression.

---

# Current Development Workflow

Controller development follows this sequence:

Desired Arma Behavior
↓
Doctrine
↓
Controller Specification
↓
State Machine
↓
Pseudocode
↓
SQF Implementation
↓
Runtime Testing
↓
Refinement
↓
Documentation

Do not skip directly from an idea to SQF.

The desired in-game behavior must be understood before implementation begins.

Unexpected behavior does not automatically indicate framework failure.

First classify the issue as one of the following:

- Doctrine
- Controller design
- Profile behavior
- Implementation
- Tuning
- Runtime regression
- Documentation mismatch

Framework-wide changes require framework-wide evidence.

Profile-specific behavior should remain profile-specific unless current
evidence establishes a shared architectural requirement.

---

# Repository-Supported Framework State

## Present in the Repository

The repository contains implementations for:

- Framework initialization
- Blackboard creation and contact storage
- Contact publication and updating
- Tracking and prediction
- Target evaluation and selection
- Reservations and assignments
- Mission-plan creation
- Scheduler lifecycle advancement
- Action dispatch
- Terminal cleanup
- Manual drone registration
- SCOUT profile routing
- FPV_STRIKE profile routing
- BOMBER profile routing
- RECON action handling
- SHADOW action handling
- ATTACK action handling
- GRENADE_DROP action handling
- Shared MOVE_TO_INTERCEPT behavior

Presence in the repository does not, by itself, establish current runtime
success.

---

# Runtime Evidence Board

## Current Runtime Verification

UNKNOWN

No fresh current-runtime verification has been recorded during the present
SCOUT doctrine and controller-design phase.

Current runtime status must remain UNKNOWN until Trevor performs a new Arma
test and records the result.

---

## Historical Runtime Records

Repository documentation records historical runtime success for the core
orchestration lifecycle.

Repository documentation also records a historical SHADOW runtime pass.

Current SHADOW runtime status remains UNKNOWN until fresh testing occurs.

Repository documentation records the following historical FPV_STRIKE
checkpoint:

- Assignment worked.
- MOVE_TO_INTERCEPT worked.
- The plan transitioned from MOVE_TO_INTERCEPT to ATTACK.
- Satchel-based terminal lethality worked.
- Target destruction occurred.
- Drone consumption occurred.
- The plan reached COMPLETE.
- Reservation release occurred.
- Scheduler cleanup occurred.

The historical FPV checkpoint did not demonstrate physical-impact behavior.

Shared intercept geometry remained in use.

FPV_STRIKE must not be described as a failed profile merely because physical
impact was not demonstrated.

Current FPV_STRIKE runtime status remains UNKNOWN until fresh testing occurs.

Repository documentation records GRENADE_DROP as a known failing or incomplete
runtime area at the time of that checkpoint.

Current BOMBER runtime status remains UNKNOWN until tested again.

---

# Current SCOUT Development State

## Desired Behavior

COMPLETE FOR V1 DESIGN

The intended player-facing behavior has been defined.

SCOUT should appear to be a cautious, adaptive observer.

SCOUT should not simply approach a target and hover directly above it.

SCOUT should seek useful observation positions, consider the surrounding
battlefield, preserve its ability to gather information, and reposition when
conditions materially change.

---

## Doctrine

COMPLETE FOR V1 DESIGN

SCOUT exists to maintain battlefield intelligence.

SCOUT services intelligence requirements rather than obsessing over one
individual target.

SCOUT prioritizes:

1. Survivability
2. Battlefield awareness
3. Intelligence requirements
4. Target observation
5. Observation quality
6. Position optimization

SCOUT doctrine prefers:

- Safer useful observation over perfect risky observation
- Battlefield awareness over single-contact tunnel vision
- Dynamic positioning over fixed distance
- Terrain-aware positioning over direct exposure
- Meaningful stability over constant movement
- Verification over assumption
- Sufficient confidence over premature completion

Observation does not end merely because a contact has been discovered.

Observation ends when the applicable intelligence requirement has been
satisfied with sufficient confidence.

A strike event does not automatically confirm destruction.

When the result is unclear, SCOUT should attempt a safer reposition and
continue battle-damage assessment.

---

## Controller Philosophy

COMPLETE FOR V1 DESIGN

SCOUT is currently defined as an intelligence controller, not merely a
movement or target-following controller.

Its central questions are:

- What information matters most?
- How certain is the current information?
- How risky is the current situation?
- Where can useful observation be maintained safely?
- Has the intelligence requirement been completed?

The current design identifies four primary decision engines:

### Intelligence Value Engine

Determines what information currently matters most.

Potential inputs include:

- Contact threat
- Contact activity
- Movement
- Recency
- Confidence
- Objective relevance
- Unresolved intelligence requirements

### Observation Position Engine

Determines where SCOUT should observe from.

Potential inputs include:

- Survivability
- Terrain masking
- Observation quality
- Battlefield awareness
- Distance from hostile contacts
- Exposure
- Stability
- Available alternatives

### Confidence Engine

Determines how certain SCOUT is about an intelligence product.

Proposed confidence levels:

- LOW
- MEDIUM
- HIGH
- CONFIRMED

### Risk Engine

Determines whether SCOUT can continue providing value from its present
position.

Proposed risk levels:

- LOW
- MEDIUM
- HIGH
- CRITICAL

Risk concerns the likelihood of losing continued intelligence capability,
not merely whether damage is immediately possible.

---

# Proposed SCOUT State Model

The current controller-design draft includes:

PATROL
↓
INVESTIGATE
↓
SELECT_OBSERVATION_POSITION
↓
MOVE_TO_POSITION
↓
OBSERVE

Potential transitions from OBSERVE include:

- Increased risk → REPOSITION
- Lost observation → SEARCH
- Meaningfully better position → REPOSITION
- Strike event → BDA
- Intelligence requirement satisfied → REPORT
- New intelligence opportunity → REEVALUATE

Additional proposed states:

- REPOSITION
- SEARCH
- BDA
- REPORT
- REEVALUATE

These states are design concepts only.

They have not yet been translated into pseudocode or SQF.

Their final names, ownership, persistence model, and relationship to the
existing KBCF plan lifecycle remain to be established through the controller
specification and repository audit.

---

# Important Implementation Clarification

No new SCOUT controller code has been written for this design.

No SCOUT pseudocode has been written.

No new position-selection algorithm has been implemented.

No Intelligence Value Engine has been implemented.

No Confidence Engine has been implemented for this controller design.

No Risk Engine has been implemented for this controller design.

No Battlefield Picture Engine has been implemented for this controller
design.

No new SCOUT runtime testing has occurred for this design.

Current work consists only of:

- Desired gameplay behavior
- Doctrine
- Controller philosophy
- Decision-model design
- Proposed state design

Repository functions that already contain names such as RECON, SHADOW,
TRACK, OBSERVE, or REPOSITION must not be treated as implementations of this
new SCOUT design merely because the labels overlap.

Implementation must be verified from behavior and ownership, not inferred
from names.

---

# Current Limitations and Open Questions

The following remain unresolved:

- Exact SCOUT controller ownership
- Relationship between the proposed SCOUT states and the existing plan
  lifecycle
- Candidate observation-position generation
- Candidate-position scoring formula
- Terrain-awareness method
- Line-of-sight evaluation
- Threat and risk inputs
- Intelligence-value scoring
- Confidence gain and decay
- Battlefield-picture representation
- Intelligence-requirement persistence
- Multiple-contact grouping
- Target-service completion
- BDA completion requirements
- Reposition thresholds
- Stability thresholds
- Search and reacquisition behavior
- Patrol behavior
- Post-service behavior
- State persistence between scheduler cycles
- Required HashMap fields
- Current-runtime behavior after implementation

These are not automatically framework defects.

Most are controller-specification, implementation, or gameplay-design work.

---

# Immediate Milestone

## SCOUT Controller Specification v1

The next milestone is to convert the approved doctrine into one coherent
controller specification.

That specification must define:

- State names
- State responsibilities
- Entry conditions
- Exit conditions
- Transition conditions
- Decision order
- Data inputs
- Persistent state
- HashMap ownership
- Confidence behavior
- Risk behavior
- Intelligence-value behavior
- Observation-position behavior
- Service-completion behavior
- Explicit non-responsibilities
- Relationship to existing scheduler and plan lifecycles

Do not write SQF until this specification is sufficiently precise to support
one bounded implementation experiment.

---

# Exactly One Next Test

No new runtime test should be selected yet because the new SCOUT behavior has
not been implemented.

The next verification activity is therefore not an Arma runtime test.

It is a repository ownership audit of the existing SCOUT route:

registerDrone
→ scheduler
→ Commander
→ planAttack
→ MOVE_TO_INTERCEPT
→ RECON
→ COMPLETE
→ cleanup

The purpose of this audit is to identify the smallest safe integration point
for SCOUT Controller v1 without changing the verified shared lifecycle
unnecessarily.

After that ownership audit and the creation of bounded pseudocode, implement
one minimal behavior slice and select exactly one runtime test for it.

---

# Anti-Drift Blockers

Do not:

- Rewrite the core framework without regression evidence.
- Treat historical runtime documentation as current runtime evidence.
- Treat function or state names as proof of completed behavior.
- Assume proposed controller engines already exist.
- Treat doctrine gaps as architecture failures.
- Invent managers or lifecycle owners before auditing current ownership.
- Let SCOUT behavior changes alter shared profile behavior without evidence.
- Treat brainstorming as implementation.
- Treat implementation as runtime verification.
- Treat an explosion as confirmed target destruction.
- Allow philosophy or terminology to override the fact that this is an
  Arma 3 gameplay project.

Always return to:

What should the player see?
↓
What should the asset decide?
↓
Which existing system owns that decision?
↓
What is the smallest implementation slice?
↓
What single runtime test verifies it?

---

# Current Board

## VERIFIED

- The repository contains the core KBCF orchestration architecture.
- Repository documentation records historical core-lifecycle runtime passes.
- Repository documentation records a historical SHADOW runtime pass.
- Repository documentation records a historical FPV_STRIKE lifecycle and
  terminal-lethality pass.
- Repository documentation records that FPV physical impact was not
  demonstrated.
- SCOUT v1 desired behavior has been defined.
- SCOUT v1 doctrine has been defined.
- SCOUT v1 controller philosophy has been defined.
- The project remains an Arma 3 SQF gameplay and controller project.

## CANDIDATE

- SCOUT intelligence-requirement lifecycle
- SCOUT state model
- Intelligence Value Engine
- Observation Position Engine
- Confidence Engine
- Risk Engine
- Battlefield Picture Engine
- Terrain-aware observation
- BDA behavior
- Dynamic repositioning
- Multiple-contact grouping

## UNKNOWN

- Current core-lifecycle runtime status
- Current SHADOW runtime status
- Current FPV_STRIKE runtime status
- Current BOMBER runtime status
- Final SCOUT integration point
- Final SCOUT state ownership
- Final HashMap schemas
- Performance cost
- Multiplayer locality behavior
- Whether the proposed behavior looks correct in Arma

---

# Current Save Point

SCOUT v1 behavior and doctrine are established.

Controller specification is the current work.

Pseudocode has not started.

SQF implementation has not started.

Runtime testing of the new SCOUT design has not started.

Next action:

Audit the existing SCOUT lifecycle ownership, then write SCOUT Controller
Specification v1.