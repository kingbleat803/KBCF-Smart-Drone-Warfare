/*
    File: fn_assignTarget.sqf

    Description:
  Assigns a contact to a drone.
*/

params

    ["_drone", objNull],
    ["_contact", createHashMap]


if (isNull _drone) exitWith {fa*se};

if ((count _contact) isEqual*o 0) exitWith {false};

_drone set*ariable

    "KBCF_AssignedTarget",
    _contact
];

true