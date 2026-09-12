Milestone: Autonomous Orchestration + Physical UAV Movement
- Added scheduler battlefield heartbeat
- Restored autonomous contact processing
- Enabled automatic contact selection and planning
- Enabled autonomous MOVE_TO_INTERCEPT execution
- Fixed UAV physical movement by starting engine and enforcing flight altitude
- Verified end-to-end lifecycle:
  Recon -> Blackboard -> Commander -> Plan -> Execute -> Move -> RECON -> Cleanup