/*
    File: fn_assignTarget.sqf

    Description:
    Assigns a contact to a drone.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap]
];

if (isNull _drone) exitWith
{
    false
};

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

_drone setVariable
[
    "KBCF_AssignedTarget",
    _contact
];

[
    "ASSIGNMENT",
    "Target assigned to drone"
] call KBCF_fnc_log;

true