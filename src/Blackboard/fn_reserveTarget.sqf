/*
    File: fn_reserveTarget.sqf

    Description:
    Reserves a contact for a drone.
*/

params
[
    ["_side", sideUnknown],
    ["_contactId", ""],
    ["_drone", objNull]
];

if (_contactId isEqualTo "") exitWith
{
    false
};

private _contact =
[
    _side,
    _contactId
] call KBCF_fnc_getContact;

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

private _reservation =
    _contact getOrDefault
    [
        "reservation",
        createHashMap
    ];

private _owner =
    _reservation getOrDefault
    [
        "owner",
        objNull
    ];

if (!isNull _owner) exitWith
{
    false
};

_reservation set
[
    "owner",
    _drone
];

_reservation set
[
    "reservedAt",
    serverTime
];

_contact set
[
    "reservation",
    _reservation
];

[
    "RESERVATION",
    format
    [
        "Contact %1 Reserved",
        _contactId
    ]
] call KBCF_fnc_log;

true