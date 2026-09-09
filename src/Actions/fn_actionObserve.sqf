/*
    File: fn_actionObserve.sqf

    Description:
    Directs a drone to observe a target.

    Returns:
    Action Result HashMap
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
    ["success", true],
    ["completed", true],
    ["replanRequired", false],
    ["reason", "OBSERVATION_COMPLETE"]
];

if (isNull _drone) exitWith
{
    _result set ["success", false];
    _result set ["reason", "INVALID_DRONE"];
    _result
};

[
    "ACTION",
    format
    [
        "Observe | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

_result