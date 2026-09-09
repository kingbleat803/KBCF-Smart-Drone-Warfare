/*
    File: fn_executeAttack.sqf

    Description:
    Executes an assigned drone attack.
*/

params
[
    ["_drone", objNull]
];

if (isNull _drone) exitWith {};

private _target =
    _drone getVariable
    [
        "KBCF_AssignedTarget",
        createHashMap
    ];

if ((count _target) isEqualTo 0) exitWith
{
    [
        "ATTACK",
        "No Assigned Target"
    ] call KBCF_fnc_log;
};

private _valid =
[
    _target
] call KBCF_fnc_validateAssignment;

if (!_valid) exitWith
{
    [
        "ATTACK",
        "Invalid Target - Requesting Reassignment"
    ] call KBCF_fnc_log;

    [
        _drone,
        east
    ] call KBCF_fnc_reassignTarget;
};

[
    _target
] call KBCF_fnc_trackTarget;

private _interceptPosition =
[
    _drone,
    _target
] call KBCF_fnc_predictIntercept;

_target set
[
    "interceptPosition",
    _interceptPosition
];

[
    "ATTACK",
    format
    [
        "Attacking %1 | Intercept Position %2",
        _target getOrDefault
        [
            "classification",
            "UNKNOWN"
        ],
        _interceptPosition
    ]
] call KBCF_fnc_log;

true