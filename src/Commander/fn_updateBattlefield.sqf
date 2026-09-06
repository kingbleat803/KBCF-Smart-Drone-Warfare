

params

    ["_side", sideUnknown],
    ["_drone", objNull];

if (isNull _drone) exitWith {};

private _contacts =
[
    _side
] call KBCF_fnc_queryContacts;

if ((count _contacts) isEqualTo 0) exitWith
{
    [
        "COMMANDER",
        "No Contacts Available"
    ] call KBCF_fnc_log;
};

private _bestContact =
[
    _contacts
] call KBCF_fnc_selectTarget;

if ((count _bestContact) isEqualTo 0) exitWith {};

private _contactId =
_bestContact getOrDefault
[
    "id",
    ""
];

private _reserved =
[
    _side,
    _contactId,
    _drone
] call KBCF_fnc_reserveTarget;

if (!_reserved) exitWith
{
    [
        "COMMANDER",
        "Contact Already Reserved"
    ] call KBCF_fnc_log;
};

[
    _drone,
   _bestContact
]    call KBCF_fnc_assignTarget;


    "COMMANDER",
    format
    [
        "Assigned Contact %1",
        _contactId
    ]
 call KBCF_fnc_log;