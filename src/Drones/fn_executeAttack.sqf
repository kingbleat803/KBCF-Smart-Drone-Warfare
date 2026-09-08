/*
    File: fn_executeAttack.sqf

   Description:
    Executes an assigned drone attack.
*/

params
[
    ["_drone", objNull]
];

private _target =
_drone getVariable
[
    "KBCF_AssignedTarget",
    createHashMap
];

if ((count _target) isEqualTo 0) exitWith {};

[
    "ATTACK",
    "Executing attack"
] call KBCF_fnc_log;