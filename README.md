<img width="1774" height="887" alt="KBCFSD" src="https://github.com/user-attachments/assets/0cea4d1d-803d-45f3-973d-f4cd4e7ff0a0" />


 # KBCF Smart Drone Warfare

KingBleat's Custom Framework (KBCF) Smart Drone Warfare is an open-source Arma 3 autonomous battlefield intelligence and drone coordination project.

The project explores how battlefield assets can observe, remember, evaluate, track, predict, plan, and execute missions using a shared intelligence system instead of isolated per-drone logic.

---

## Philosophy

KBCF is being developed in evolutionary generations.

Each generation builds upon the previous generation.

The objective is not merely to create smarter drones.

The objective is to create autonomous battlefield agents capable of:

Observe
↓
Remember
↓
Evaluate
↓
Track
↓
Predict
↓
Pursue
↓
Plan
↓
Act
↓
Engage

---

## What Is KBCF?

KBCF is an intelligence-first framework.

Arma assets provide the physical body.

KBCF provides the battlefield intelligence layer.

```text
KBCF
=
Memory
Evaluation
Tracking
Prediction
Planning
Scheduling
Coordination

Arma
=
Movement
Flight
Weapons
Damage
Simulation
```

The framework uses a shared Blackboard system that allows assets to consume common battlefield intelligence.

---

## Smart Drone Warfare

Smart Drone Warfare is the first KBCF module.

Current drone profiles include:

```text
SCOUT
FPV_STRIKE
BOMBER
```

Each profile consumes battlefield intelligence and executes role-specific behavior.

---

## Current Status

Development State:
ACTIVE DEVELOPMENT

The core autonomous framework has been runtime verified in Arma.

Verified systems include:

- Blackboard intelligence storage
- Contact processing
- Tracking
- Prediction
- Target selection
- Reservations
- Assignment
- Mission planning
- Scheduler execution
- Action routing
- Physical UAV movement
- Terminal cleanup
- Automatic retasking

Verified runtime flow:

```text
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
```

---

## Project Structure

Documentation is separated by purpose.

```text
README
Architecture
Blackboard System
Development State
Welcome Back Notes
Changelog
```

See individual documents for detailed implementation information.

---

## Current Focus

The framework itself has been validated.

Current development is focused on:

- Automatic drone discovery and registration
- Post-mission drone behavior
- Recon doctrine
- Target revisit policy
- Multi-asset coordination
- Additional KBCF modules

---

## Future Modules

KBCF is intended to support additional battlefield systems built on the same intelligence architecture.

Examples include:

```text
Artillery Coordination
Close Air Support
Electronic Warfare
Air Defense
Additional Autonomous Warfare Systems
```

These systems are expected to consume shared Blackboard intelligence rather than implement separate intelligence layers.

---

## Development Philosophy

Repository code describes intended behavior.

Runtime testing verifies actual behavior.

Architectural claims should be considered verified only after successful testing inside Arma.

---

## License

See repository license for details.
