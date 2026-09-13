KBCF Smart Drone Warfare

Framework Status:
Operational

Runtime Verified:
Recon -> Blackboard -> Commander -> Reservation
-> Assignment -> Planning -> ExecutePlan
-> ExecuteAction -> Physical UAV Movement
-> RECON -> COMPLETE -> Cleanup

Current Focus:
Doctrine definition, behavior development,
and doctrine-driven framework evolution

Next Frontiers:

1. Formalize and implement persistent SCOUT ISR doctrine.
2. Define SCOUT patrol, handoff, shadow, and BDA transitions.
3. Define post-mission behavior for surviving assets.
4. Define target service, revisit, and satiation doctrine.
5. Define SCOUT-loss recovery parameters and restoration doctrine.
6. Define automatic asset creation and registration doctrine.
7. Generalize third-party drone and payload compatibility.
8. Runtime-test FPV_STRIKE and BOMBER role lifecycles.
9. Develop multi-asset coordination.

==================================================
CURRENT LIMITATIONS
==================================================

The framework architecture has been runtime verified,
however several implementation limitations remain.

Asset Compatibility

- Manual drone registration required.
- Automatic asset discovery not implemented.
- Vanilla drone platforms are the primary tested assets.
- Third-party drone platform compatibility has not been generalized.

Weapon Compatibility

- One hardcoded munition class is currently used by strike actions.
- Weapon and payload selection are not yet profile-driven.
- Munition compatibility is not yet dynamically determined from the asset.

==================================================
CAPABILITY EXHAUSTION RUNTIME TEST
==================================================

Setup:

Single registered SCOUT providing ISR capability.

Result:

SCOUT destroyed during runtime testing.

Observed Behavior:

- Dead asset record remained in KBCF_Drones.
- No replacement asset appeared.
- No ISR restoration observed.
- Existing Blackboard contacts persisted temporarily.
- Contacts eventually expired and were removed as stale.
- Blackboard became empty after contact expiration.

Verified Runtime Flow:

SCOUT Loss
↓
No reconScan updates
↓
Contact confidence decay
↓
Removed stale contact
↓
Blackboard empty

Current Interpretation:

Blackboard provides temporary intelligence persistence
but does not independently restore ISR capability
following complete recon asset loss.

Status:

Runtime behavior is verified.

Doctrine now establishes that destruction of the
final SCOUT should temporarily degrade OPFOR
battlefield awareness and reward successful
counter-ISR action.

Blindness should not necessarily be permanent.

The cooldown, replacement limits, restoration
conditions, spawn mechanism, and architectural
owner remain undefined.

Architecture must not be assigned until those
doctrine conditions are formalized.

==================================================
SCOUT LOSS DOCTRINE
==================================================

Chosen Direction:

Capability loss should matter.

Players should be rewarded for destroying
OPFOR ISR assets.

When the final SCOUT is destroyed:

- Fresh ISR generation stops.
- Existing Blackboard intelligence decays naturally.
- OPFOR battlefield awareness degrades.
- The resulting period of blindness should provide
  a meaningful player advantage.
- Blindness should not necessarily be permanent.

Future ISR restoration may use configurable
cooldowns, reserves, replenishment limits,
bases, or other capability-restoration mechanisms.

The desired battlefield effect is now defined.

The restoration mechanism, parameters, and
architectural owner remain doctrine pending.

==================================================
DOCTRINE-DRIVEN FRAMEWORK EVOLUTION
==================================================

KBCF evolution follows:

Runtime
↓
Doctrine
↓
Architecture
↓
Implementation
↓
Runtime Verification
↓
Documentation

Runtime reveals an outcome.

Doctrine determines whether the outcome is desirable.

Architecture determines ownership and support for
the chosen doctrine.

Implementation realizes the architecture.

Runtime verifies the implementation.

Documentation preserves the result.

Do not assume a missing owner, manager, or system
before first determining whether the observed
runtime outcome is actually undesirable.

Many suspected missing systems may instead be
doctrine decisions that have not yet been formalized.

The complete-loss SCOUT test demonstrates this process:

Runtime revealed that loss of the final SCOUT
stops fresh ISR, allows Blackboard contacts to
decay, and eventually leaves the Blackboard empty.

Doctrine then determined that capability loss
should matter, but blindness should not
necessarily be permanent.

Architecture and implementation for eventual
ISR restoration remain undefined.

==================================================
FRAMEWORK ASSESSMENT
==================================================

FPV_STRIKE Runtime Verification

Setup:
- OPFOR UAV named drone1
- Drone manually registered as FPV_STRIKE
- Hostile vehicle published as an EAST Blackboard contact
- Commander assignment manually invoked

Registration:
[drone1, east, "FPV_STRIKE"] call KBCF_fnc_registerDrone;

Result:
- Registration returned true
- Assignment count returned 1
- Drone physically moved toward the assigned target

Verified execution:
- MOVE_TO_INTERCEPT executed
- INTERCEPT_REACHED occurred
- Plan transitioned to ATTACK
- KBCF_fnc_actionAttack executed
- SatchelCharge_Remote_Ammo_Scripted was created
- Drone remained hovering at shared intercept/cruise altitude
- No physical impact with target was observed
- Warhead event occurred near the target
- Vehicle was destroyed
- Drone was destroyed
- Plan reached COMPLETE
- Reservation was released
- Scheduler performed terminal cleanup

Architectural Discovery

Observed behavior does not match expected FPV doctrine.

Runtime suggests FPV_STRIKE currently inherits
shared MOVE_TO_INTERCEPT behavior used by other
drone profiles.

Observed result:
Hover
↓
ATTACK
↓
Detonation
↓
COMPLETE

not:

Impact
↓
Detonation
↓
COMPLETE

OPEN INVESTIGATION

INTERCEPT_REACHED currently occurs at:

private _completionRadius = 25;

This variable controls transition from
MOVE_TO_INTERCEPT to terminalActionType.

The effect of this shared lifecycle parameter
on FPV behavior has not yet been verified.