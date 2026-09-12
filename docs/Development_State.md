KBCF Smart Drone Warfare

Framework Status:
Operational

Runtime Verified:
Recon -> Blackboard -> Commander -> Reservation
-> Assignment -> Planning -> ExecutePlan
-> ExecuteAction -> Physical UAV Movement
-> RECON -> COMPLETE -> Cleanup

Current Focus:
Doctrine, behaviors, and autonomous asset management

Next Frontiers:
- Automatic drone discovery/registration
- Post-mission behavior
- Recon doctrine
- Target revisit logic
- Multi-drone coordination
- Strike/FPV role testing

## Current Limitations

The framework architecture has been runtime verified, however several implementation limitations remain.

### Asset Compatibility

- Manual drone registration required.
- Automatic asset discovery not implemented.
- Vanilla drone platforms are the primary tested assets.
- Third-party drone platform compatibility has not been generalized.

### Weapon Compatibility

- One hardcoded munition class is currently used by strike actions.
- Weapon and payload selection are not yet profile-driven.
- Munition compatibility is not yet dynamically determined from the asset.