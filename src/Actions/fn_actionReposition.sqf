/*
    File: fn_actionReposition.sqf

    Description:
    Moves the drone to a designated
    battlefield position.

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
    _plan getOrDefault
    [
        "repositionPosition",
        []
    ];

if ((count _targetPosition) < 2) exitWith
{
    _result set
    [
        "reason",
        "NO_REPOSITION_POSITION"
    ];

    _result
};

private _distance =
    _drone distance2D _targetPosition;

private _completionRadius = 25;

if (_distance <= _completionRadius) exitWith
{
    _result set
    [
        "success",
        true
    ];

    _result set
    [
        "completed",
        true
    ];

    _result set
    [
        "reason",
        "REPOSITION_COMPLETE"
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
    "reason",
    "REPOSITIONING"
];

[
    "ACTION",
    format
    [
        "Reposition | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

_result