WELCOME BACK NOTES

Before assuming a missing system, ask:

"What is the last runtime-verified lifecycle state?"

KBCF has repeatedly proven that runtime evidence is more reliable
than architectural speculation.

Debugging order:

1. Check logs
2. Check runtime variables
3. Check debugger state
4. Identify last successful transition
5. Only then inspect code

Do not assume Blackboard, Commander, Planning, Scheduler,
Assignment, or Execution are broken unless runtime evidence
indicates failure.

Major Milestone Verified:

Recon
→ Blackboard
→ Commander
→ Reservation
→ Assignment
→ Tracking
→ Prediction
→ Authorization
→ Plan Creation
→ ExecutePlan
→ ExecuteAction
→ MOVE_TO_INTERCEPT
→ Physical UAV Movement
→ RECON
→ COMPLETE
→ Cleanup

All runtime verified.

Known Architectural Truths:

- Blackboard is the shared intelligence layer.
- Drones are physical assets consuming Blackboard intelligence.
- Recon drones act as sensors.
- Strike/FPV drones act as weapons.
- The framework is intelligence-first, not asset-first.

Current Frontiers:

1. Automatic drone discovery and registration.
   Current state:
   Manual registerDrone calls.

2. Post-mission drone behavior.
   Current state:
   Drone remains physically hovering while KBCF considers it AVAILABLE.

3. Recon doctrine.
   Current state:
   SCOUT can automatically reacquire the same target after cleanup.

4. Target satiation.
   Framework remembers contacts.
   Framework does not yet remember that a contact was recently serviced.

Important Lesson:

Code shows intended behavior.
Arma shows actual behavior.

When they disagree:

Believe Arma.

STOP CHASING DOWNSTREAM FUNCTIONS FIRST.

Verify lifecycle ownership first.

What starts the chain?
What owns the chain?
What invokes the chain repeatedly?

Missing orchestration can make perfectly working downstream systems
appear broken.

IMPORTANT

KBCF may have entered a doctrine-first phase.

Before creating new managers, owners, or systems:

Ask:
"What should happen?"

not:

"Who owns it?"

See Development State for the full
Doctrine-Driven Framework Evolution notes.

## FPV_STRIKE Runtime Checkpoint

### Runtime Verified

- Manual `FPV_STRIKE` registration returned true.
- Contact processing and Commander assignment succeeded.
- `MOVE_TO_INTERCEPT` executed.
- The plan transitioned to `ATTACK`.
- `KBCF_fnc_actionAttack` executed.
- `SatchelCharge_Remote_Ammo_Scripted` destroyed the target.
- The drone was consumed.
- The plan reached `COMPLETE`.
- Reservation release and scheduler cleanup succeeded.

### Observed Limitation

The drone remained at the shared cruise/intercept altitude and did not physically impact the target.

The verified behavior was:

MOVE_TO_INTERCEPT
→ hover at intercept geometry
→ ATTACK
→ target-attached detonation
→ target and drone destroyed
→ COMPLETE
→ cleanup

This is not yet a verified physical-impact FPV attack.

### Rejected Test

Changing the ATTACK detonation radius from `5` to `0` caused the drone to hover indefinitely without detonating.

Restore and preserve the working `5` metre baseline.

Do not describe zero radius as an impact solution.

### Architectural Finding

`MOVE_TO_INTERCEPT` is a shared plan state used across profiles.

`INTERCEPT_REACHED` transitions the plan from its current `actionType` to its `terminalActionType`.

Do not change shared intercept behavior solely to satisfy FPV doctrine because that may alter SCOUT and BOMBER behavior.

FPV currently has verified terminal lethality but no verified profile-specific terminal movement.

### Lifecycle Map

registerDrone
→ profile stored
→ contact processed
→ Commander reserves and assigns
→ planAttack creates persistent plan
→ actionType: MOVE_TO_INTERCEPT
→ INTERCEPT_REACHED
→ terminalActionType: ATTACK
→ ExecutePlan dispatches actionAttack
→ COMPLETE
→ scheduler cleanup

### Debugging Lesson

HashMaps are persistent lifecycle memory.

For every state or field, trace:

1. Who creates it?
2. Who modifies it?
3. Who consumes it?
4. Who removes it?

Do not assume a function owns a decision merely because it consumes that decision.

Follow state creation and transitions before changing downstream handlers.

### Next Investigation

Trace only the FPV-specific lifecycle and determine where profile-specific terminal movement belongs.

Do not redesign shared movement, mod compatibility, registration, or other profiles until that ownership and the existing action-result contract are audited.