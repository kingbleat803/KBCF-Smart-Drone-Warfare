/*
    File: fn_actionTrack.sqf
	Author: Kingbleat
    Description:
    Directs the assigned drone to maintain
    contact with a target.

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
    ["reason", "UNKNOWN"]
];

if (isNull _drone) exitWith
{
    _result set
    [
        "reason",
        "INVALID_DRONE"
    ];

    _result
};

private _targetPosition =
    _contact getOrDefault
    [
        "position",
        []
    ];

if ((count _targetPosition) < 2) exitWith
{
    _result set
    [
        "reason",
        "NO_TARGET_POSITION"
    ];

    _result
};

private _driver =
    driver _drone;

if (isNull _driver) exitWith
{
    _result set
    [
        "reason",
        "DRONE_HAS_NO_DRIVER"
    ];

    _result
};

private _droneGroup =
    group _driver;

if (isNull _droneGroup) exitWith
{
    _result set
    [
        "reason",
        "DRONE_GROUP_MISSING"
    ];

    _result
};

/*
    Survivability: while evading, the maneuver owns movement. The plan
    stays ACTIVE and normal tracking resumes when the maneuver ends.
*/
[_drone] call KBCF_fnc_installFireReaction;

if ([_drone, _contact, _plan] call KBCF_fnc_evadeFire) exitWith
{
    _result set ["success", true];
    _result set ["completed", false];
    _result set ["replanRequired", false];
    _result set ["reason", "EVADING_FIRE"];

    _result
};

_droneGroup move _targetPosition;

_result set
[
    "success",
    true
];

_result set
[
    "completed",
    false
];

_result set
[
    "replanRequired",
    false
];

_result set
[
    "reason",
    "TRACKING_TARGET"
];

[
    "ACTION",
    format
    [
        "Tracking Target | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

_result