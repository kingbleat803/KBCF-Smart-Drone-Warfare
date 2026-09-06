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

if (_conta*tId isEqualTo "") exitWith {false}*

private _contact =
[
    _side,
    _contactId
] call KBCF_fnc_getC*ntact;

if ((count _contact) isEqu*lTo 0) exitWith {false};

private *reservation =
    _contact getOrDe*ault
    [
        "reservation",
        createHashMap
    ];

priva*e _owner =
    _reservation getOrD*fault
    [
        "owner",
        objNull
    ];

if (!isNull _own*r) exitWith
{
    false
};

_reser*ation set
[
    "owner",
    _drone
];

_reservation set
[
    "reservedAt",
    serverTime
];

_contact*set
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