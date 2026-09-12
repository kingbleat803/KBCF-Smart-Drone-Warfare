I’d make Architecture the clean, current source of truth for how KBCF’s systems relate to each other. It should explain ownership and data flow without turning into another roadmap, changelog, or historical diary.

# KBCF Architecture

## Purpose

KBCF is a server-authoritative battlefield intelligence, planning, and autonomous asset orchestration framework for Arma 3.

Smart Drone Warfare is the first module built on the framework, but the architecture is designed around shared battlefield intelligence rather than one specific drone type.

The framework separates:

- Battlefield memory
- Intelligence processing
- Decision-making
- Asset ownership
- Mission planning
- Runtime scheduling
- Physical action execution

This separation allows KBCF to coordinate different battlefield assets without placing the complete intelligence system inside each individual drone.

---

## Architectural Model

```text
Arma Battlefield
↓
Sensors and Recon Assets
↓
Blackboard
↓
Tracking and Prediction
↓
Commander
↓
Reservation and Assignment
↓
Mission Planning
↓
Scheduler
↓
Action Execution
↓
Arma AI and Physical Assets
↓
Mission Result
↓
Blackboard and Cleanup

System Metaphor

KBCF was developed using a biological systems metaphor.

Blackboard
=
Shared battlefield memory

Tracking and Prediction
=
Nervous system

Commander
=
Decision-making layer

Scheduler
=
Heartbeat

Plans
=
Executable intentions

Actions
=
Motor instructions

Arma AI and UAVs
=
Physical body


The metaphor is useful for understanding responsibilities, but the actual implementation remains modular.

Core Architectural Principle

KBCF provides the intelligence and coordination layer.

Arma provides the physical simulation and asset behavior layer.

KBCF:
Remember
Evaluate
Track
Predict
Prioritize
Reserve
Assign
Plan
Schedule
Coordinate

Arma:
Start engines
Take off
Move
Patrol
Target
Fire
Drop ordnance
Apply damage
Simulate destruction


KBCF does not replace Arma AI.

KBCF gives Arma-controlled assets informed missions and coordinated objectives.

Blackboard

The Blackboard is the shared intelligence layer.

It stores contacts and the intelligence products associated with them.

A contact may contain:

Identity
Object reference
Classification
Position
Velocity
Confidence
Threat
Tracking quality
Prediction data
Intercept data
Reservation state
Mission plan


Sensors publish information to the Blackboard.

The Commander reads information from the Blackboard.

The planner stores missions on Blackboard contacts.

The scheduler discovers and advances those missions.

The Blackboard is therefore both shared battlefield memory and the central exchange point between KBCF systems.

The Blackboard does not independently command physical assets.

Sensors and Recon

Recon assets observe the Arma battlefield and publish detected objects as contacts.

Current sensing flow:

Recon scan
↓
Process contact
↓
Classify target
↓
Evaluate threat
↓
Publish or update contact
↓
Blackboard


Recon drones are persistent intelligence assets.

Their long-term doctrine may include:

Patrol
Loiter
Search
Investigate
Track
Shadow
Maintain surveillance


The currently verified SCOUT implementation uses:

MOVE_TO_INTERCEPT
↓
RECON
↓
COMPLETE


This behavior successfully verifies orchestration and physical movement, but permanent recon doctrine remains under development.

Tracking and Prediction

Tracking converts a raw observation into a maintained intelligence product.

Contact
↓
Validate
↓
Track target
↓
Predict position
↓
Predict intercept


Tracking generates information such as:

trackAge
trackQuality
predictedPosition
interceptPosition
interceptTime
interceptQuality


The Commander and planning systems depend on this enriched intelligence.

Raw contacts must therefore be prepared before engagement authorization and mission creation.

Commander

The Commander is the decision-making and resource-allocation layer.

The Commander does not physically control drone movement.

The Commander:

Queries contacts
↓
Filters invalid contacts
↓
Selects the best available contact
↓
Reserves the contact
↓
Assigns an available asset
↓
Requests mission planning


Current Commander implementation:

fn_updateBattlefield


The Commander owns the decision that an asset should receive a mission.

The scheduler owns the continued execution of the mission after the plan is created.

Reservations and Assignments

Reservations prevent multiple assets from unintentionally receiving the same contact.

Contact selected
↓
Contact reserved
↓
Reservation owner stored
↓
Asset assigned


Reservation state belongs to the Blackboard contact.

Assignment state belongs to the asset.

This means KBCF maintains two related pieces of ownership:

Contact:
Who reserved me?

Asset:
What contact am I assigned to?


Terminal cleanup must clear both sides.

Mission Planning

fn_planAttack evolved from the earlier mission-planning concept.

Despite the current function name, its architectural purpose is broader than attacking.

It creates an executable mission plan containing:

Assigned asset
Contact identity
Target object
Target classification
Drone profile
Intercept position
Intercept time
Route quality
Current action
Terminal action
Lifecycle status
Execution timestamps
Failure and replanning state


Current mission birth flow:

Prepared contact
↓
Engagement authorization
↓
Mission creation
↓
Plan persisted on Blackboard contact
↓
Scheduler discovers plan


Current supported profile mapping:

SCOUT
→ RECON

FPV_STRIKE
→ ATTACK

BOMBER
→ GRENADE_DROP


The function name may remain planAttack for compatibility, but architecture documentation should treat it as mission creation.

Scheduler

The scheduler is KBCF’s permanent runtime heartbeat.

It starts from framework initialization and repeatedly circulates work through the architecture.

Current scheduler responsibilities include:

Front-Half Orchestration
Read registered assets
↓
Identify available drones
↓
Invoke role-appropriate sensing
↓
Call the Commander
↓
Create new mission plans

Plan Lifecycle
Find persisted plans
↓
Activate pending plans
↓
Execute active plans
↓
Monitor action results
↓
Set terminal state

Terminal Cleanup
Release contact reservation
↓
Clear asset assignment
↓
Clear completed plan
↓
Return surviving asset to availability


The scheduler is the heartbeat, but it does not replace the Commander, planner, or action handlers.

It periodically invokes the systems that own those decisions.

Plan Lifecycle

Plans use explicit lifecycle states:

PENDING
↓
ACTIVE
↓
COMPLETE


A plan may alternatively end as:

FAILED
EXPIRED


State meanings:

PENDING

The mission exists but has not yet begun execution.

ACTIVE

The scheduler is advancing the mission and dispatching its current action.

COMPLETE

The mission achieved its defined completion condition.

FAILED

The mission encountered a condition requiring termination or replanning.

EXPIRED

The mission exceeded its usable time window.

Mission completion does not automatically mean the contact was destroyed.

For example:

RECON_COMPLETE


means the recon action completed.

It does not mean:

CONTACT_ELIMINATED


This distinction is important for future mission doctrine.

Action Layer

The action layer translates plans into physical instructions.

Current action routing includes:

MOVE_TO_INTERCEPT
OBSERVE
TRACK
SHADOW
REPOSITION
RECON
ATTACK
GRENADE_DROP


The scheduler calls:

executePlan
↓
executeAction
↓
Specific action handler


Action handlers return a standard result:

success
completed
replanRequired
reason


This contract allows the scheduler to understand whether an action:

Succeeded and completed
Succeeded but remains active
Failed and requires replanning
Encountered a temporary condition

Physical UAV Handoff

A KBCF movement instruction is not sufficient by itself to make a grounded Arma UAV fly.

Runtime verification established that air assets require physical preparation:

Start engine
↓
Establish forced flight height
↓
Create an airborne destination
↓
Issue movement order to the UAV driver’s group


The verified movement preparation includes:

_drone engineOn true;
_drone flyInHeight [50, true];
_droneGroup move _movementPosition;


This is the boundary between KBCF planning and Arma physical simulation.

The movement action must execute where the UAV driver is local.

Runtime-Verified Lifecycle

The following autonomous lifecycle has been verified in Arma:

Registered SCOUT
↓
Scheduler heartbeat
↓
Recon scan
↓
Contact processing
↓
Blackboard publication
↓
Target evaluation
↓
Target selection
↓
Reservation
↓
Assignment
↓
Tracking
↓
Position prediction
↓
Intercept prediction
↓
Engagement authorization
↓
Mission creation
↓
Plan persistence
↓
Plan activation
↓
MOVE_TO_INTERCEPT
↓
Physical UAV movement
↓
RECON
↓
COMPLETE
↓
Reservation release
↓
Assignment cleanup
↓
Plan cleanup


This proves that the core KBCF architecture operates as a connected autonomous system.

Automatic Retasking

After terminal cleanup, a surviving drone becomes available again.

The scheduler can automatically assign that drone another mission.

Runtime testing verified that the same SCOUT could:

Complete mission
↓
Release contact
↓
Become available
↓
Acquire another assignment


The current implementation may immediately select the same surviving contact again if that contact remains the highest-scoring eligible option.

This proves automatic retasking works.

It also exposes an unfinished doctrine problem.

Current Doctrine Gaps

The infrastructure is operational.

The remaining work increasingly concerns mission doctrine and asset behavior.

Recon Persistence

Should a recon plan complete immediately after one scan?

Or should it remain active while the contact remains alive and relevant?

Target Revisit Policy

Should a recently reconnoitered contact be selected again immediately?

Potential future concepts include:

lastReconAt
lastServicedAt
reconCooldownUntil
observationRequirement
serviceStatus

Idle Asset Behavior

What should an available drone do without an assignment?

Possible behaviors include:

Loiter
Patrol
Search
Standby
Return to base
Maintain current position

Related Contacts

How should KBCF represent relationships between:

Vehicle
Occupant
Dismounted infantry
Related battlefield objects


The current Blackboard normally treats separate Arma objects as separate contacts.

Asset Compatibility

Future Commander doctrine should determine which profile is suitable for each mission and contact type.

Examples:

SCOUT
→ Persistent sensing and tracking

FPV_STRIKE
→ Disposable precision engagement

BOMBER
→ Reusable ordnance delivery

Future assets
→ Consume shared Blackboard intelligence

Current Manual Boundary

Drone registration currently requires an explicit call such as:

[drone1, east, "SCOUT"] call KBCF_fnc_registerDrone;


Once registered, the scheduler can take over the autonomous lifecycle.

The current startup frontier is:

Mission initialization
↓
Discover eligible assets
↓
Determine side
↓
Determine profile
↓
Register asset
↓
Scheduler takes ownership


Automatic asset discovery and registration are not yet implemented.

Architectural Rules
Rule 1: Intelligence First

Assets consume shared Blackboard intelligence.

Individual drones should not independently duplicate the complete battlefield knowledge system.

Rule 2: One Owner Per Responsibility
Blackboard
→ Memory

Commander
→ Selection and allocation

Planner
→ Mission creation

Scheduler
→ Runtime circulation and lifecycle advancement

Actions
→ Physical instructions

Arma
→ World simulation

Rule 3: Preserve One Execution Route

The modern execution path is:

executePlan
→ executeAction
→ action handler


Legacy execution functions should not be reconnected in parallel without checking for duplicated responsibilities.

Rule 4: Mission State and Contact State Are Different
Mission complete
≠
Contact eliminated


Plans may end while their contacts remain valid.

Rule 5: Runtime Is Final Authority

Repository code describes intended behavior.

Arma runtime proves actual behavior.

Architectural claims should be marked as runtime verified only after observing them in the game, debugger, or RPT logs.

Current Status
Framework initialization
VERIFIED

Blackboard memory
VERIFIED

Contact processing
VERIFIED

Tracking and prediction
VERIFIED

Commander selection
VERIFIED

Reservations and assignments
VERIFIED

Engagement authorization
VERIFIED

Mission planning
VERIFIED

Scheduler lifecycle
VERIFIED

Action routing
VERIFIED

Physical UAV movement
VERIFIED

Terminal cleanup
VERIFIED

Automatic retasking
VERIFIED

Automatic drone discovery
NOT IMPLEMENTED

Post-mission idle behavior
NOT DEFINED

Recon persistence and revisit doctrine
NOT DEFINED

Architectural Summary

KBCF has crossed the boundary from disconnected capabilities into a working autonomous framework.

The current architecture can:

Observe
Remember
Evaluate
Track
Predict
Select
Reserve
Assign
Plan
Execute
Move
Complete
Clean up
Retask


The next phase is not rebuilding the framework.

The next phase is defining how different assets should behave within it.

Side notes:

### Why this belongs in Architecture

This document answers:

- **What is KBCF?**
- **Who owns each responsibility?**
- **How does data move through the system?**
- **Where does KBCF stop and Arma begin?**
- **What has been runtime verified?**
- **Which remaining problems are doctrine rather than infrastructure?**

I would keep commit history out of this file. Put historical changes in the changelog, current development priorities in Development State, Blackboard-specific details in Blackboard System, and Copilot recovery guidance in Welcome Back Notes.