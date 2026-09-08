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

private _existingContact =
    _board getOrDefault
    [
        _contactId,
        createHashMap
    ];

if ((count _existingContact) > 0) exitWith
{
    [
        _existingContact,
        _target
    ] call KBCF_fnc_updateContact;

    [
        "CONTACT",
        format
        [
            "Updated Contact %1",
            _contactId
        ]
    ] call KBCF_fnc_log;
};

private _classification =
[
    _target
] call KBCF_fnc_classifyTarget;

private _threat =
[
    _classification
] call KBCF_fnc_evaluateThreat;

private _contact = createHashMapFromArray
[
    ["id", _contactId],
    ["object", _target],
    ["classification", _classification],
    ["position", getPosATL _target],
    ["velocity", velocity _target],
    ["confidence", 50],
    ["threat", _threat],
    ["firstSeen", serverTime],
    ["lastSeen", serverTime],
    ["source", _source],
    ["reservation", createHashMap]
];

_board set
[
    _contactId,
    _contact
];

[
    "CONTACT",
    format
    [
        "Published Contact %1",
        _contactId
    ]
] call KBCF_fnc_log;