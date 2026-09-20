/*
    File: fn_actionObserve.sqf
	Author:KingBleat
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

/*
    Survivability: this action normally completes in a single cycle.
    If the drone is under fire it holds the plan open while an evasion
    maneuver runs, then completes on the first quiet cycle. Without
    this the plan would complete and release the drone mid-dodge.
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

[
    "ACTION",
    format
    [
        "Observe | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

_result