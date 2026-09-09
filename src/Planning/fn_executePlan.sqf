/*
    File: fn_executePlan.sqf

    Description:
    Validates and updates plan status.
*/

params
[
    ["_contact", createHashMap]
];

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

private _plan =
    _contact getOrDefault
    [
        "attackPlan",
        createHashMap
    ];

if ((count _plan) isEqualTo 0) exitWith
{
    false
};

private _status =
    _plan getOrDefault
    [
        "status",
        "PENDING"
    ];

private _arrival =
    _plan getOrDefault
    [
        "plannedArrival",
        serverTime
    ];

if (serverTime >= _arrival) then
{
    _status = "COMPLETE";
};

_plan set
[
    "status",
    _status
];

_plan set
[
    "lastExecutionTime",
    serverTime
];

_contact set
[
    "attackPlan",
    _plan
];

[
    "PLAN",
    format
    [
        "Status:%1",
        _status
    ]
] call KBCF_fnc_log;

true