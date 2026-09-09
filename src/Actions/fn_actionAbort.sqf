/*
    File: fn_actionAbort.sqf

    Description:
    Terminates the current action and
    stops the drone from pursuing its
    current objective.

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

/*
    Stop current AI movement.
*/

_driver stop true;

/*
    Clear active movement order.
*/

_droneGroup move (getPos _driver);

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
    "replanRequired",
    false
];

_result set
[
    "reason",
    "ABORT_COMPLETE"
];

[
    "ACTION",
    format
    [
        "Abort Complete | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

_result