/*
    File:
        fn_actionGrenadeDrop.sqf

    Description:
        Terminal action for the BOMBER drone profile.

        Uses a background thread ONLY for flight/positioning (setVelocity
        loop toward the target, at a tick rate finer than the scheduler's
        own interval). The thread does NOT create the munition itself -
        createVehicle for the payload happens back in this file's own
        synchronous, per-scheduler-tick execution, which is the same
        execution context your original working version used. This avoids
        a reproducible engine restriction where createVehicle for ammo-
        simulation classes (Bo_GB6, HandGrenade, etc.) fails with
        "Cannot create non-ai vehicle" when called from inside a thread
        nested under the scheduler's own spawned loop.

        Plan-owned storage (same pattern already runtime-verified for
        SCOUT: scoutState / scoutObserveCycles) tracks flight progress
        across scheduler ticks, so the scheduler and reservation system
        are never told the mission is done before the payload has
        actually been created and released.

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
        Real physical drop from the drone's own position, falling
        toward the ground over visible time - intentional, so a
        player has a chance to see/hear it coming and react (move,
        take cover) rather than an instant CAS-style snipe at the
        target's position. Drone safety is handled separately below
        via an explicit breakaway maneuver + margin on the arm delay,
        not by faking the drop location.

        IEDUrbanSmall_Remote_Ammo: small, contained CfgVehicles-category
        explosive prop, infantry/grenade scale (same object family as
        FPV_STRIKE's satchel charge, so createVehicle is proven to work
        on this class). Does not auto-detonate on its own, so timing
        below is fully explicit and controlled.
    */
    private _payloadClass = "IEDUrbanSmall_Remote_Ammo";
    private _releasePosition = getPosASL _drone;
    _releasePosition set [2, (_releasePosition select 2) - 1.5];

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

    private _droneVelocity = velocity _drone;
    _munition setPosASL _releasePosition;
    _munition setVelocity
    [
        _droneVelocity select 0,
        _droneVelocity select 1,
        (_droneVelocity select 2) - 10 /* faster downward separation than before */
    ];

    /*
        Breakaway maneuver: the instant the payload is released, order
        the drone to climb and continue forward away from the drop
        point, instead of just coasting. This is what actually keeps
        the drone clear - not the arm delay by itself.
    */
    private _breakawayDriver = driver _drone;
    if (!isNull _breakawayDriver) then
    {
        private _breakawayGroup = group _breakawayDriver;
        if (!isNull _breakawayGroup) then
        {
            private _breakawayPos =
                (getPosATL _drone) vectorAdd [(_droneVelocity select 0) * 3, (_droneVelocity select 1) * 3, 60];

            _breakawayGroup move _breakawayPos;
        };

        _drone setVelocity
        [
            _droneVelocity select 0,
            _droneVelocity select 1,
            15 /* climb */
        ];
    };

    /*
        Arm delay: long enough for real fall time + the breakaway
        maneuver above to create separation, short enough that it's
        still clearly "just dropped," not a CAS-style instant hit.
    */
    [_munition] spawn
    {
        params ["_bomb"];
        sleep 2.5;
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

[
    _drone,
    _target,
    _droneGroup,
    _plan
] spawn
{
    params ["_drone", "_target", "_droneGroup", "_plan"];

    private _dropTriggered = false;
    private _cruiseSpeed = 15;

    while {alive _drone && alive _target && !_dropTriggered} do
    {
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

        _drone setVelocity
        [
            (_travelDir select 0) * _cruiseSpeed,
            (_travelDir select 1) * _cruiseSpeed,
            0
        ];

        _droneGroup move _overshootPosition;

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
