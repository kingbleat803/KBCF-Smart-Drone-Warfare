/*
    File: fn_getContact.sqf

    Description:
    Returns a specific contact by ID.
*/

params
[
    ["_side", sideUnknown],
    ["_contactId", ""]
];

private _board = KBCF_Blackboards get _side;

if (isNil "_board") exitWith
{
    createHashMap
};

_board getOrDefault
[
    _contactId,
    createHashMap
];