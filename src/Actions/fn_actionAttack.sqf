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

/*
    Tighter than the previous 8m generic-target radius. An
    armor-defeating charge needs to actually be on the hull,
    not merely nearby, so the drone is required to close all
    the way in before detonation is permitted.
*/
private _detonationRadius = 5;

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
    Detonation. The warhead class is configurable per-plan
    (fn_planAttack can write "warheadClass" into the plan for
    a given profile); if it does not, this falls back to a
    demolition-charge class. Charges in this family are
    documented by Bohemia specifically as being intended for
    scripted detonation via setDamage 1, and are the standard
    vanilla vehicle-killing explosive - unlike the previous
    Bo_GB6 frag grenade, this is sized to actually destroy
    armor, not just harass infantry.

    The charge is attached directly to the target rather than
    placed at the drone's own position, so the impact point is
    the hull itself. The drone is destroyed in the same event.
*/
private _warheadClassname =
    _plan getOrDefault
    [
        "warheadClass",
        "SatchelCharge_Remote_Ammo_Scripted"
    ];

private _warhead =
    _warheadClassname createVehicle _targetPosition;

if (isNull _warhead) exitWith
{
    _result set ["reason", "WARHEAD_CREATE_FAILED"];
    _result set ["replanRequired", true];

    [
        "ATTACK",
        format
        [
            "Kamikaze detonation failed | Reason:WARHEAD_CREATE_FAILED | Drone:%1 | WarheadClass:%2",
            netId _drone,
            _warheadClassname
        ]
    ] call KBCF_fnc_log;

    _result
};

_warhead attachTo
[
    _target,
    [0, 0, 0.2]
];

_warhead setDamage 1;

_drone setDamage 1;

_result set ["success", true];
_result set ["completed", true];
_result set ["reason", "KAMIKAZE_DETONATED"];

[
    "ATTACK",
    format
    [
        "Kamikaze detonated | Drone:%1 | Target:%2 | WarheadClass:%3 | Distance:%4",
        netId _drone,
        netId _target,
        _warheadClassname,
        round _distance
    ]
] call KBCF_fnc_log;

_result