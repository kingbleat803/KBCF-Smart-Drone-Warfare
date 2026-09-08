/*
    File: fn_queryContacts.sqf

    Description:
    Returns all contacts from a side blackboard.
*/

params
[
    ["_side", sideUnknown]
];

private _board = KBCF_Blackboards get _side;

if (isNil "_board") exitWith
{
    []
};

values _board