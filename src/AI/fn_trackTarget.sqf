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

private _trackQuality = 100;

_trackQuality =
    _trackQuality - (_trackAge * 2);

if (_velocity isEqualTo [0,0,0]) then
{
    _trackQuality =
        _trackQuality - 20;
};

if (_trackQuality < 0) then
{
    _trackQuality = 0;
};

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
    "trackQuality",
    _trackQuality
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
        "%1 | Age:%2 | Quality:%3 | Predicted:%4",
        _contact getOrDefault
        [
            "classification",
            "UNKNOWN"
        ],
        round _trackAge,
        round _trackQuality,
        _predictedPosition
    ]
] call KBCF_fnc_log;

true