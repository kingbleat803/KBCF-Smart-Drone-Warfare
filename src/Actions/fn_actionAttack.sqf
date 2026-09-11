/*
    File: fn_actionAttack.sqf

    Description:
    Terminal action for the FPV_STRIKE drone profile.
    Kamikaze behavior: closes on the target object's current
    position and, once within detonation range, destroys the
    drone in a self-inflicted explosion. The drone does not
    survive a completed attack - that is what distinguishes
    this from fn_actionGrenadeDrop.sqf, which releases a
    munition and lets the drone continue.

    Dispatched only after fn_actionMoveToIntercept has already
    handed the plan's actionType over to "ATTACK" on arrival at
    the original intercept point. This handler is responsible
    for closing any remaining gap to the target's live position
    and for the detonation itself, not for the initial approach.

    Signature and Action Result contract preserved:
    params [_drone, _contact, _plan]
    returns HashMap: success, completed, replanRequired, reason

    Execution:
    Server only.

    Returns:
    Action Result HashMap.
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

if (isNull _drone) exitWith
{
    _result set ["reason", "INVALID_DRONE"];
    _result set ["replanRequired", true];

    _result
};

if (!alive _drone) exitWith
{
    _result set ["reason", "DRONE_DESTROYED"];
    _result set ["replanRequired", true];

    _result
};

if ((count _plan) isEqualTo 0) exitWith
{
    _result set ["reason", "INVALID_PLAN"];
    _result set ["replanRequired", true];

    _result
};

private _target =
    _plan getOrDefault
    [
        "targetObject",
        objNull
    ];

if (isNull _target) exitWith
{
    _result set ["reason", "TARGET_MISSING"];
    _result set ["replanRequired", true];

    _result
};

/*
    A target that died between the handoff and this cycle is
    a completed engagement, not a failure.
*/
if (!alive _target) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "TARGET_ALREADY_DOWN"];

    [
        "ATTACK",
        format
        [
            "Kamikaze aborted | Target already down | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

private _driver =
    driver _drone;

if (isNull _driver) exitWith
{
    _result set ["reason", "DRONE_HAS_NO_DRIVER"];
    _result set ["replanRequired", true];

    _result
};

private _droneGroup =
    group _driver;

if (isNull _droneGroup) exitWith
{
    _result set ["reason", "DRONE_GROUP_MISSING"];
    _result set ["replanRequired", true];

    _result
};

if (!local _driver) exitWith
{
    _result set ["reason", "DRONE_DRIVER_NOT_LOCAL"];
    _result set ["replanRequired", false];

    [
        "ATTACK",
        format
        [
            "Kamikaze run not issued | Driver not local | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

private _targetPosition =
    getPosATL _target;

private _distance =
    _drone distance2D _targetPosition;

private _detonationRadius = 8;

if (_distance > _detonationRadius) exitWith
{
    _droneGroup move _targetPosition;

    _result set ["success", true];
    _result set ["completed", false];
    _result set ["reason", "CLOSING_ON_TARGET"];

    [
        "ATTACK",
        format
        [
            "Kamikaze closing | Drone:%1 | Distance:%2 | Target:%3",
            netId _drone,
            round _distance,
            _targetPosition
        ]
    ] call KBCF_fnc_log;

    _result
};

/*
    Detonation. A standalone explosive prop is spawned at the
    drone's own position so the blast is simulated through the
    engine's normal ammo/damage model rather than an instant,
    unconditional kill of only the recorded target reference;
    the drone is then destroyed in the same event.
*/
private _detonationPosition =
    getPosATL _drone;

"Bo_GB6" createVehicle _detonationPosition;

_drone setDamage 1;

_result set ["success", true];
_result set ["completed", true];
_result set ["reason", "KAMIKAZE_DETONATED"];

[
    "ATTACK",
    format
    [
        "Kamikaze detonated | Drone:%1 | Position:%2 | Distance:%3",
        netId _drone,
        _detonationPosition,
        round _distance
    ]
] call KBCF_fnc_log;

_result