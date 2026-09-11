/*
    File: fn_actionGrenadeDrop.sqf

    Description:
    Terminal action for the BOMBER drone profile. Releases a
    single munition over the target's current position and
    completes the plan once released. Unlike fn_actionAttack.sqf,
    the drone itself is not destroyed - it survives the drop,
    which is what distinguishes a bomber pass from a kamikaze
    strike.

    Dispatched only after fn_actionMoveToIntercept has already
    handed the plan's actionType over to "GRENADE_DROP" on
    arrival at the original intercept point. This handler
    closes any remaining gap to the target's live position and
    performs the release itself.

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

if (!alive _target) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "TARGET_ALREADY_DOWN"];

    [
        "ATTACK",
        format
        [
            "Grenade drop aborted | Target already down | Drone:%1",
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
            "Bombing run not issued | Driver not local | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

private _targetPosition =
    getPosATL _target;

private _distance =
    _drone distance2D _targetPosition;

private _dropRadius = 15;

if (_distance > _dropRadius) exitWith
{
    _droneGroup move _targetPosition;

    _result set ["success", true];
    _result set ["completed", false];
    _result set ["reason", "CLOSING_ON_TARGET"];

    [
        "ATTACK",
        format
        [
            "Bombing run closing | Drone:%1 | Distance:%2 | Target:%3",
            netId _drone,
            round _distance,
            _targetPosition
        ]
    ] call KBCF_fnc_log;

    _result
};

/*
    Release. The munition is spawned at the drone's own
    position with a downward velocity so it falls toward the
    target and detonates on impact through the engine's normal
    ammo simulation, rather than the target being damaged
    directly. The drone is not touched - it survives the pass.
*/
private _releasePosition =
    getPosASL _drone;

private _munition =
    "Bo_GB6" createVehicle _releasePosition;

_munition setPosASL _releasePosition;

_munition setVelocity
[
    0,
    0,
    -10
];

_result set ["success", true];
_result set ["completed", true];
_result set ["reason", "GRENADE_RELEASED"];

[
    "ATTACK",
    format
    [
        "Grenade released | Drone:%1 | Position:%2 | Distance:%3",
        netId _drone,
        _releasePosition,
        round _distance
    ]
] call KBCF_fnc_log;

_result