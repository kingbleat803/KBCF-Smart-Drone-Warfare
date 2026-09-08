/*
    File: fn_executeAttack.sqf

   Description:
    Executes an assigned drone attack.
*/

params

    ["_drone", objNull],
    ["_contact", createHashMap]

if (isNull _drone) exitWith {false};

if ((count_contact) isEqualTo 0) exitWith {false};
_drone setvariable ["KBCF_AssignedTarget",_contact];
true