/*
    File: fn_actionMoveToIntercept.sqf

    Description:
    Directs a drone toward the intercept
    position stored in the active plan.
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
    _result set
    [
        "reason",
        "INVALID_DRONE"
    ];

    _result
};

if (!alive _drone) exitWith
{
    _result set
    [
        "reason",
        "DRONE_DESTROYED"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

private _interceptPosition =
    _plan getOrDefault
    [
        "interceptPosition",
        []
    ];

if ((count _interceptPosition) isEqualTo 0) exitWith
{
    _result set
    [
        "reason",
        "NO_INTERCEPT_POSITION"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

/*
    Completion check
*/
private _distance =
    _drone distance2D _interceptPosition;

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
        "INTERCEPT_REACHED"
    ];

    [
        "ACTION",
        "Intercept reached"
    ] call KBCF_fnc_log;

    _result
};

/*
    Move toward intercept
*/

(group _drone) move _interceptPosition;

_result set
[
    "success",
    true
];

_result set
[
    "reason",
    "MOVING_TO_INTERCEPT"
];

[
    "ACTION",
    format
    [
        "Moving | Distance:%1 | Position:%2",
        round _distance,
        _interceptPosition
    ]
] call KBCF