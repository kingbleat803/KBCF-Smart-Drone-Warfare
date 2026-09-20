/*
    File:
        fn_actionGrenadeDrop.sqf
		author:KingBleat
		Description:
        Terminal action for the BOMBER drone profile.

        Uses a background thread ONLY for flight/positioning (setVelocity
        loop toward the target, at a tick rate finer than the scheduler's
        own interval). The thread does NOT create the munition itself -
        createVehicle for the payload happens back in this file's own
        synchronous, per-scheduler-tick execution, which is the same
        execution context proven to work (createVehicle for ammo-
        simulation classes like Bo_GB6/HandGrenade fails with "Cannot
        create non-ai vehicle" regardless of context - that was a
        class-type problem, not a threading problem).

        Plan-owned storage (same pattern already runtime-verified for
        SCOUT: scoutState / scoutObserveCycles) tracks flight progress
        across scheduler ticks, so the scheduler and reservation system
        are never told the mission is done before the payload has
        actually been created and released.

        CONFIRMED WORKING CONFIGURATION (owner-tested: target destroyed,
        drone survived and cleared the area): payload spawns near the
        target's position (CAS/artillery-simulation style) rather than
        falling from the drone - this keeps the drone's existing
        ~dropRadius separation from the blast without needing any
        additional breakaway maneuver.

        SURVIVABILITY (added): the flight thread calls
        KBCF_fnc_evadeFire about four times a second. While an evasion
        maneuver is active the thread stops issuing its own velocity and
        move commands, so it does not cancel the dodge, and resumes
        closing on the target once the maneuver ends. Payload creation,
        detonation and completion logic are unchanged.

    Signature:
        params [_drone, _contact, _plan]

    Returns:
        HashMap:
            success
            completed
            replanRequired
            reason

    Execution:
        Server only.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap],
    ["_plan", createHashMap]
];

private _result =
    createHashMapFromArray
    [
        ["success", false],
        ["completed", false],
        ["replanRequired", false],
        ["reason", "UNPROCESSED"]
    ];

if (!isServer) exitWith { _result set ["reason", "NOT_SERVER"]; _result };
if (isNull _drone || {!alive _drone}) exitWith { _result set ["reason", "INVALID_DRONE"]; _result set ["replanRequired", true]; _result };
if ((count _plan) isEqualTo 0) exitWith { _result set ["reason", "INVALID_PLAN"]; _result set ["replanRequired", true]; _result };

private _target = _plan getOrDefault ["targetObject", objNull];
if (isNull _target) exitWith { _result set ["reason", "TARGET_MISSING"]; _result set ["replanRequired", true]; _result };

private _flightState = _plan getOrDefault ["grenadeDropFlightState", "NOT_STARTED"];

/* =====================================================================
    FLIGHT THREAD ALREADY FINISHED CLOSING: do the actual drop here,
    synchronously, in the SAME execution context as the rest of the
    verified action-routing framework (executePlan -> executeAction ->
    this call). This is where createVehicle is proven to work.
===================================================================== */
if (_flightState == "IN_RANGE") exitWith
{
    if (!alive _target) exitWith
    {
        _result set ["success", true];
        _result set ["completed", true];
        _result set ["reason", "TARGET_ALREADY_DOWN"];
        ["BOMBER", format ["Bombing pass cancelled | Target already down | Drone:%1", netId _drone]] call KBCF_fnc_log;
        _result
    };

    /*
        CAS-style spawn: create the effect directly at the target's
        position (not the drone's own position) and detonate shortly
        after, the same way scripted CAS/artillery simulations work
        when there's no real fired munition or AI pilot involved. This
        keeps the drone clear of its own blast - it is still ~dropRadius
        away from the target when this fires - without depending on any
        separate breakaway maneuver.

        IEDUrbanSmall_Remote_Ammo: small, contained CfgVehicles-category
        explosive prop, infantry/grenade scale (same object family as
        FPV_STRIKE's satchel charge, so createVehicle is proven to work
        on this class). Does not auto-detonate on its own, so timing
        below is fully explicit and controlled.

        CONFIRMED (owner-observed): target destroyed, drone survived and
        flew clear of the area.
    */
    private _payloadClass = "IEDUrbanSmall_Remote_Ammo";
    private _releasePosition = getPosASL _target;
    _releasePosition set [2, (_releasePosition select 2) + 0.2]; /* just above ground level at the target */

    private _munition = _payloadClass createVehicle _releasePosition;

    if (isNull _munition) exitWith
    {
        ["ATTACK", format ["Payload creation failed | Drone:%1 | Payload:%2", netId _drone, _payloadClass]] call KBCF_fnc_log;

        _result set ["success", false];
        _result set ["completed", true];
        _result set ["replanRequired", true];
        _result set ["reason", "PAYLOAD_CREATE_FAILED"];
        _result
    };

    _munition setPosASL _releasePosition;

    /*
        Short delay to simulate travel time / give a beat between the
        drop sound and the impact. No drone-proximity risk either way
        since detonation happens at the target's location, not the
        drone's.
    */
    [_munition] spawn
    {
        params ["_bomb"];
        sleep 0.6;
        if (!isNull _bomb) then
        {
            _bomb setDamage 1;
            ["BOMBER", format ["Payload timed detonation | Munition:%1", netId _bomb]] call KBCF_fnc_log;
        };
    };

    playSound3D ["A3\Sounds_F\weapons\Closure\gr_launcher.wss", _drone];

    _plan set ["payloadReleased", true];
    _plan set ["activeMunition", _munition];
    _plan set ["releasePosition", _releasePosition];

    ["BOMBER", format ["Autonomous payload deployment success | Drone:%1", netId _drone]] call KBCF_fnc_log;

    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "GRENADE_RELEASED"];
    _result
};

if (_flightState == "TARGET_LOST") exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "TARGET_ALREADY_DOWN"];
    _result
};

/* Thread already spawned and still closing distance */
if (_flightState == "RUNNING") exitWith
{
    _result set ["success", true];
    _result set ["completed", false];
    _result set ["reason", "AUTONOMOUS_STRIKE_THREAD_RUNNING"];
    _result
};

/* =====================================================================
    FIRST ENTRY: not yet started. Run remaining sync guards, then spawn
    a FLIGHT-ONLY thread (no createVehicle inside it).
===================================================================== */

if (!alive _target) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "TARGET_ALREADY_DOWN"];
    ["BOMBER", format ["Bombing pass cancelled | Target already down | Drone:%1", netId _drone]] call KBCF_fnc_log;
    _result
};

private _driver = driver _drone;
if (isNull _driver || {!alive _driver}) exitWith { _result set ["reason", "DRONE_DRIVERS_COMPROMISED"]; _result set ["replanRequired", true]; _result };

private _droneGroup = group _driver;
if (isNull _droneGroup) exitWith { _result set ["reason", "DRONE_GROUP_MISSING"]; _result set ["replanRequired", true]; _result };

if (!local _driver) exitWith
{
    _result set ["reason", "DRIVER_NOT_LOCAL"];
    ["BOMBER", format ["Bombing pass deferred | Driver not local | Drone:%1", netId _drone]] call KBCF_fnc_log;
    _result
};

_plan set ["grenadeDropFlightState", "RUNNING"];

/* Idempotent. Normally already installed during MOVE_TO_INTERCEPT. */
[_drone] call KBCF_fnc_installFireReaction;

[
    _drone,
    _target,
    _droneGroup,
    _plan,
    _contact
] spawn
{
    params ["_drone", "_target", "_droneGroup", "_plan", "_contact"];

    private _dropTriggered = false;
    private _cruiseSpeed = 15;
    private _evading = false;
    private _nextEvadeCheck = 0;

    while {alive _drone && alive _target && !_dropTriggered} do
    {
        /* Evasion check, throttled to ~4 Hz (the loop itself runs ~30 Hz). */
        if (serverTime >= _nextEvadeCheck) then
        {
            _evading = [_drone, _contact, _plan] call KBCF_fnc_evadeFire;
            _nextEvadeCheck = serverTime + 0.25;
        };

        private _currentDronePos  = getPosATL _drone;
        private _targetPosition   = getPosATL _target; /* refreshed every loop, tracks a moving target */
        private _distanceToTarget = _drone distance2D _targetPosition;

        if (_distanceToTarget <= 25) exitWith { _dropTriggered = true; };

        private _diffX = (_targetPosition select 0) - (_currentDronePos select 0);
        private _diffY = (_targetPosition select 1) - (_currentDronePos select 1);

        if (_diffX == 0 && _diffY == 0) then { _diffX = 0.001; };
        private _dirVector = vectorNormalized [_diffX, _diffY, 0];
        private _pushVector = _dirVector vectorMultiply 300;
        private _overshootPosition = _targetPosition vectorAdd _pushVector;

        private _vX = (_overshootPosition select 0) - (_currentDronePos select 0);
        private _vY = (_overshootPosition select 1) - (_currentDronePos select 1);

        if (_vX == 0 && _vY == 0) then { _vX = 0.001; };
        private _travelDir = vectorNormalized [_vX, _vY, 0];

        /* While evading, evadeFire owns movement - do not cancel the dodge. */
        if (!_evading) then
        {
            _drone setVelocity
            [
                (_travelDir select 0) * _cruiseSpeed,
                (_travelDir select 1) * _cruiseSpeed,
                0
            ];

            _droneGroup move _overshootPosition;
        };

        sleep 0.03;
    };

    if (_dropTriggered) then
    {
        /* Do NOT createVehicle here. Just signal "in range" - the next
           scheduler tick's synchronous call handles the actual drop. */
        _plan set ["grenadeDropFlightState", "IN_RANGE"];
    }
    else
    {
        _plan set ["grenadeDropFlightState", "TARGET_LOST"];
    };
};

_result set ["success", true];
_result set ["completed", false];
_result set ["reason", "AUTONOMOUS_STRIKE_THREAD_INITIALIZED"];

_result
