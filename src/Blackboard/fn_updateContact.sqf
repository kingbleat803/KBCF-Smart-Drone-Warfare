/*
File: fn_updateContact.sqf
 
Description:
Updates an existing contact with fresh information.
*/

params
[
["_contact", createHashMap],
["_target", objNull]
];

if (
(count _contact) isEqualTo 0
) exitWith {};

if (
isNull _target
) exitWith {};

_contact set
[
"position",
getPosATL _target
];

_contact set
[
"lastSeen",
serverTime
];

_contact set
[
"alive",
alive _target
];

_contact