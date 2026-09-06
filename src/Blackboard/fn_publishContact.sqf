/*
    File: fn_publishContact.sqf

    Description:
    Creates or updates a contact in the side blackboard.
*/

params
[
    ["_side", sideUnknown],
    ["_source", objNull],
    ["_target", objNull]
];

if (isNull _target) exitWith {};

private _board = KBCF_Blackboards get _side;

if (isNil "_board") exitWith
{
    [
        "BLACKBOARD",
        "Invalid Blackboard"
    ] call KBCF_fnc_log;
};

private _contactId = netId _target;

private _contact = createHashMapFromArray
[
    ["id", _contactId],
    ["object", _target],
    ["classification", "UNKNOWN"],
    ["position", getPosATL _target],
    ["velocity", velocity _target],
    ["confidence", 1],
    ["threat", 0],
    ["firstSeen", serverTime],
    ["lastSeen", serverTime],
    ["source", _source],
    ["reservation", createHashMap]
];

_board set [_contactId, _contact];

[
    "CONTACT",
    format ["Published Contact %1", _contactId]
] call KBCF_fnc_log;