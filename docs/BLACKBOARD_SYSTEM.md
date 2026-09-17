

## Core Model

```text
Sensor observes battlefield object
↓
Contact is published or updated
↓
Blackboard stores shared intelligence
↓
Tracking and prediction enrich the contact
↓
Commander evaluates available contacts
↓
Target is reserved and assigned
↓
Planner stores a mission on the contact
↓
Scheduler advances the mission
↓
Terminal cleanup releases the contact

Contact Identity

Each contact is stored using the detected object's network ID.

private _contactId = netId _target;


This means separate Arma objects normally become separate Blackboard contacts.

Examples:

Infantry object
→ Infantry contact ID

Vehicle object
→ Vehicle contact ID


A vehicle and occupant may therefore exist as separate contacts.

The current system does not explicitly link related contacts through fields such as:

occupantOf
dismountedFrom
relatedContact
parentVehicle


Vehicle-occupant association remains a future doctrine and coordination problem.

Contact Lifecycle

A contact can pass through these stages:

Created
↓
Updated
↓
Tracked
↓
Predicted
↓
Evaluated
↓
Reserved
↓
Assigned
↓
Planned
↓
Executed
↓
Released
↓
Updated, revisited, or expired


The contact can remain in the Blackboard after a mission completes.

Mission completion and contact elimination are not the same thing.

Mission COMPLETE
≠
Contact destroyed or removed


This distinction currently permits the Commander to select the same surviving contact again.

Contact Data

A normal contact can contain:

id
object
classification
position
velocity
confidence
threat
firstSeen
lastSeen
source
alive
reservation


Tracking and prediction may add:

predictedPosition
predictionAge
lastPredictionTime
trackAge
trackQuality
lastTrackUpdate
interceptPosition
interceptTime
interceptQuality
distance


Planning may add:

attackPlan


The contact is therefore more than a target reference. It is a living intelligence record that accumulates battlefield knowledge and mission state.

Blackboard Responsibilities

The Blackboard is responsible for:

Contact storage
Contact retrieval
Contact updates
Shared side intelligence
Contact confidence
Contact threat information
Tracking products
Prediction products
Reservation state
Persisted mission plans

Blackboard Non-Responsibilities

The Blackboard does not independently:

Discover drones
Register drones
Move drones
Select physical flight behavior
Execute actions
Determine post-mission loiter behavior
Start engines
Issue takeoff commands


Those responsibilities belong to sensing, Commander, planning, scheduler, action, and physical asset systems.

Reservations

A reservation prevents multiple assets from unintentionally selecting the same contact.

A reservation contains:

owner
reservedAt


Correct reservation usage requires:

[_side, _contactId, _drone] call KBCF_fnc_reserveTarget;


If the drone argument is omitted, the default owner is objNull. This may produce a timestamped reservation with no valid owner during debugger testing.

Do not treat that test artifact as proof that UAV control ownership is missing.

Mission Persistence

The planner stores the mission directly on the selected Blackboard contact:

contact
└── attackPlan


The scheduler finds these persisted plans and advances their lifecycle:

PENDING
↓
ACTIVE
↓
COMPLETE / FAILED / EXPIRED


When a plan reaches a terminal state, the scheduler:

Releases the reservation
Clears the drone assignment
Clears the contact's attackPlan


The contact itself may remain because the battlefield object may still be alive and observable.

Runtime-Verified Flow

The following path has been verified in Arma:

Recon
→ Contact processing
→ Blackboard
→ Commander
→ Reservation
→ Assignment
→ Tracking
→ Prediction
→ Authorization
→ Plan creation
→ Scheduler
→ ExecutePlan
→ ExecuteAction
→ MOVE_TO_INTERCEPT
→ Physical UAV movement
→ RECON
→ COMPLETE
→ Cleanup


Physical UAV movement required:

_drone engineOn true;
_drone flyInHeight [50, true];


and an airborne movement destination.

Current Known Behavior

After a RECON plan completes:

Reservation is released
Drone assignment is cleared
Plan is removed
Drone becomes available
Contact remains in Blackboard


If that contact remains the highest-priority eligible contact, the Commander may immediately select it again.

This produces the currently observed loop:

RECON_COMPLETE
↓
Cleanup
↓
Same contact remains
↓
Same contact selected
↓
New RECON plan


This proves automatic retasking works, but it also exposes missing recon doctrine.

Current Frontier

The Blackboard currently remembers:

The contact exists
The contact's classification
The contact's threat
The contact's confidence
The contact's tracking state
The contact's predicted state


The Blackboard does not yet clearly remember:

This contact was recently reconnoitered
This contact has already been serviced
This contact should not be selected again temporarily
This contact belongs to another related battlefield entity


Potential future fields include:

lastReconAt
lastServicedAt
lastAssignedAt
reconCooldownUntil
serviceStatus
relatedContacts


These are proposed doctrine fields, not verified current implementation.

Debugging Rule

The code describes intended Blackboard behavior.

Arma runtime proves actual Blackboard behavior.

When debugging:

1. Query contacts
2. Inspect the selected contact
3. Check freshness and object validity
4. Check tracking and prediction fields
5. Check reservation ownership
6. Check attackPlan persistence
7. Compare the Blackboard state with RPT logs


Never assume a missing field proves a broken function until the corresponding lifecycle stage has been invoked on a fresh contact.

Current Truth

The Blackboard system is operational and has been verified as part of the complete autonomous orchestration lifecycle.

The current work is no longer proving that Blackboard memory functions.

The current work is defining:

Contact revisit policy
Recon mission persistence
Recently serviced targets
Vehicle-occupant relationships
Post-mission behavior
Multi-asset coordination

Side note: 

### Why this version helps

It separates four things that were getting tangled together:

- **Contact lifecycle** versus mission lifecycle
- **Blackboard memory** versus scheduler control
- **Reservations** versus physical UAV control
- **Verified behavior** versus future doctrine

Most importantly, it records the new truth: KBCF remembers the truck, but not yet that Lil Homie just finished staring at the truck.