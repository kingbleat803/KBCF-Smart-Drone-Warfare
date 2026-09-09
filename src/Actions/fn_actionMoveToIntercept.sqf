/*
    File: fn_actionMoveToIntercept.sqf

    Description:
    Directs the assigned drone toward the intercept
    position stored in the active plan.

    Returns:
    Action result HashMap.
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

    _result set
    [
        "replanRequired",
        true
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

if ((count _plan) isEqualTo 0) exitWith
{
    _result set
    [
        "reason",
        "INVALID_PLAN"
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

if ((count _interceptPosition) < 2) exitWith
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

private _distance =
    _drone distance2D _interceptPosition;

private _completionRadius = 25;

/*
    The drone reached the objective.
*/
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
        format
        [
            "Intercept reached | Drone:%1 | Distance:%2",
            netId _drone,
            round _distance
        ]
    ] call KBCF_fnc_log;

    _result
};

/*
    Retrieve the drone's AI driver.

    For an autonomous UAV, this should normally
    be the AI unit controlling the vehicle.
*/
private _driver =
    driver _drone;

if (isNull _driver) exitWith
{
    _result set
    [
        "reason",
        "DRONE_HAS_NO_DRIVER"
    ];

    _result set
    [
        "replanRequired",
        true
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

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

/*
    Group movement commands must run where the
    controlling group is local.
*/
if (!local _driver) exitWith
{
    _result set
    [
        "reason",
        "DRONE_DRIVER_NOT_LOCAL"
    ];

    _result set
    [
        "replanRequired",
        false
    ];

    [
        "ACTION",
        format
        [
            "Movement not issued | Driver not local | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

_droneGroup move _interceptPosition;

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
        "Movement requested | Drone:%1 | Distance:%2 | Position:%3",
        netId _drone,
        round _distance,
        _interceptPosition
    ]
] call KBCF_fnc_log;

_result