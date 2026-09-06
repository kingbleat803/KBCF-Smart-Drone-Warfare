/*
    File: fn_releaseTarget.sqf

    Description:
    Releases a reserved contact.
*/

params
[
    ["_side", sideUnknown],
    ["_contactId", ""]
];

private _contact =
[
    _side,
    _contactId
] call KBCF_fnc_getContact;

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

_contact set
[
    "reservation",
    createHashMap
];

[
    "RESERVATION",
    format
    [
        "Released Contact %1",
        _contactId
    ]
] call KBCF_fnc_log;

true