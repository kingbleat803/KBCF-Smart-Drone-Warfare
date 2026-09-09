/*
    File: fn_trackTarget.sqf

    Description:
    Updates tracking information for a contact.
*/

params
[
    ["_contact", createHashMap]
];

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

private _valid =
[
    _contact
] call KBCF_fnc_validateAssignment;

if (!_valid) exitWith
{
    false
};

private _predictedPosition =
[
    _contact
] call KBCF_fnc_predictPosition;

private _lastKnownPosition =
    _contact getOrDefault
    [
        "position",
        [0,0,0]
    ];

private _velocity =
    _contact getOrDefault
    [
        "velocity",
        [0,0,0]
    ];

private _lastSeen =
    _contact getOrDefault
    [
        "lastSeen",
        serverTime
    ];

private _trackAge =
    serverTime - _lastSeen;

_contact set
[
    "predictedPosition",
    _predictedPosition
];

_contact set
[
    "trackAge",
    _trackAge
];

_contact set
[
    "lastTrackUpdate",
    serverTime
];

[
    "TRACKING",
    format
    [
        "%1 | Last Position:%2 | Predicted Position:%3 | Velocity:%4 | Age:%5",
        _contact getOrDefault
        [
            "classification",
            "UNKNOWN"
        ],
        _lastKnownPosition,
        _predictedPosition,
        _velocity,
        round _trackAge
    ]
] call KBCF_fnc_log;

true