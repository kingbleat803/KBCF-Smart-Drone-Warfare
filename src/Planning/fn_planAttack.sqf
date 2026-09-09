/*
    File: fn_planAttack.sqf

    Description:
    Generates a attack plan from the
    current target intelligence.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap]
];

if (isNull _drone) exitWith
{
    createHashMap
};

if ((count _contact) isEqualTo 0) exitWith
{
    createHashMap
};

private _interceptPosition =
[
    _drone,
    _contact
] call KBCF_fnc_predictIntercept;

private _interceptTime =
    _contact getOrDefault
    [
        "interceptTime",
        0
    ];

private _interceptQuality =
    _contact getOrDefault
    [
        "interceptQuality",
        0
    ];

private _plannedArrival =
    serverTime + _interceptTime;

private _routeQuality =
    _interceptQuality;

private _attackPlan =
createHashMapFromArray
[
    ["interceptPosition", _interceptPosition],
    ["interceptTime", _interceptTime],
    ["interceptQuality", _interceptQuality],
    ["plannedArrival", _plannedArrival],
    ["routeQuality", _routeQuality]
];

_contact set
[
    "attackPlan",
    _attackPlan
];

[
    "ATTACK",
    format
    [
        "Arrival:%1 | Quality:%2",
        round _plannedArrival,
        round _routeQuality
    ]
] call KBCF_fnc_log;

_attackPlan