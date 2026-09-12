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