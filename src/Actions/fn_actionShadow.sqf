/*
    File: fn_actionShadow.sqf

    Description:
    Maintains a shadow position near a target.

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
    _result set ["reason","INVALID_DRONE"];
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
    _result set ["reason","NO_TARGET_POSITION"];
    _result
};

private _shadowDistance = 150;

private _shadowPosition =
[
    (_targetPosition select 0) - _shadowDistance,
    (_targetPosition select 1),
    0
];

private _driver = driver _drone;

if (isNull _driver) exitWith
{
    _result set ["reason","DRONE_HAS_NO_DRIVER"];
    _result
};

(group _driver) move _shadowPosition;

_result set ["success", true];
_result set ["reason", "SHADOWING_TARGET"];

[
    "ACTION",
    format
    [
        "Shadow Target | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

_result