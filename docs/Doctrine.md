SCOUT = Persistent ISR Asset

The SCOUT is the eyes of KBCF.

A SCOUT is not a recon action.

A SCOUT is not a weapon.

A SCOUT exists to create and maintain
battlefield awareness.

Responsibilities
---------------
Observe
Track
Validate
Publish Intelligence
Support Strike Assets
Perform Battle Damage Assessment

Life Cycle
----------
PATROL
↓
DETECT
↓
VALIDATE
↓
PUBLISH
↓
HANDOFF
↓
SHADOW
↓
BDA
↓
PATROL

Target Service Cycle
--------------------
SCOUT
↓
Patrol Sector
↓
Find Contact
↓
Hand Off To Strike Asset
↓
Shadow Target
↓
Provide Battle Damage Assessment
↓
Resume Patrol

Important Doctrine Principle
----------------------------

Attack Complete
≠
Target Service Complete

If the target survives:

Maintain observation
↓
Refresh Blackboard intelligence
↓
Continue shadowing when practical
↓
Enable another strike cycle
↓
Perform another BDA

If the target is eliminated:

Confirm the result
↓
Complete the target service cycle
↓
Resume patrol

Player Experience Doctrine
--------------------------

Players should observe evidence that
battlefield intelligence exists.

The intelligence cycle should not be hidden.

Drone
↓
Detection
↓
Warning
↓
Strike

Example:

"Enemy reconnaissance drone has identified your position."

Purpose:

Players learn the KBCF intelligence cycle through gameplay.


Doctrine Decision Recorded Today
--------------------------------

SCOUT Loss Doctrine

Chosen Direction:

Capability loss should matter.

Players should be rewarded for destroying ISR.

Enemy awareness should degrade.

Blackboard intelligence should decay naturally.

Blindness should not necessarily be permanent.

Future recovery may occur through doctrine-
defined cooldowns, reserves, replenishment,
or capability restoration systems.

The restoration mechanism remains undefined.

The desired battlefield outcome is defined.

-------------------------------------------------
SCOUT DOCTRINE v1

Role
-----
SCOUT is a Persistent ISR (Intelligence, Surveillance, Reconnaissance) Asset.

SCOUT exists to maintain battlefield awareness, discover threats, support asset selection, monitor service cycles, and verify target outcomes.

Core Principles
---------------
- Detection is a persistent capability.
- SCOUT should continuously gather intelligence.
- SCOUT should prioritize survivability when threatened.
- SCOUT should value threat-weighted intelligence over raw contact quantity.
- SCOUT should consider available battlefield resources when supporting responses.
- Players should have meaningful ISR counterplay.
- ISR loss should have battlefield consequences.

Patrol Doctrine
---------------
SCOUT should actively patrol information-rich areas rather than perform random movement.

Preferred patrol locations include:
- Roads
- Towns
- Objectives
- Recent contact areas
- Likely avenues of approach

Target Service Doctrine
-----------------------
Attack completion does not equal target service completion.

SCOUT owns target observation throughout the service cycle.

SCOUT responsibilities:
- Detect
- Validate
- Publish
- Handoff
- Shadow
- Perform BDA
- Confirm target service completion

Shadow Doctrine
---------------
SCOUT maintains observation on selected targets throughout the service cycle.

SCOUT should continue monitoring priority targets until:
- Target is destroyed
- Target no longer exists
- Target becomes invalid
- Higher priority circumstances require reassignment

Battle Damage Assessment Doctrine
---------------------------------
SCOUT verifies outcomes rather than assuming outcomes.

Target service completes only when SCOUT confirms the target no longer requires service.

Examples:
- Destroyed vehicle
- Eliminated target
- Abandoned target
- Invalid target
- No longer relevant target

Post-Service Doctrine
---------------------
After service completion, SCOUT returns to ISR duties and continues patrol operations.

---------------------------------------------------------------------------------------------
Drone Role Doctrine Checkpoint

Current KBCF drone roles:

SCOUT
- Intelligence collection asset
- Detects, tracks, and publishes contacts
- Provides battlefield awareness
- Does not directly engage targets

FPV_STRIKE
- Expendable precision strike asset
- Consumed during attack
- Uses kamikaze-style terminal engagement
- Intended for high-value target destruction

BOMBER
- Reusable strike asset
- Releases payload and survives
- Intended for repeated service missions
- Payload type may evolve independently of role

Architectural Decision:
Role is separate from physical drone platform.

KBCF reasons about battlefield roles and capabilities,
not specific airframe classnames.

Current implementation remains vanilla-first and
self-contained.

Third-party drone mods are not required for operation.

