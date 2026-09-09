/*
    File: fn_predictPosition.sqf

    Description:
    Predicts the current position of a contact
    based on last known position, velocity,
    and observation age.
*/

params
[
    ["_contact", createHashMap]
];

if ((count _contact) isEqualTo 0) exitWith
{
    [0,0,0]
};

/*
    Debug marker

    Remove after validation.
*/
[
    "PREDICTION",
    "PredictPosition loaded - GEN7 CHECKPOINT"
] call KBCF_fnc_log;

private _position =
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

private _age =
    serverTime - _lastSeen;

/*
    Prevent invalid negative age.
*/
if (_age < 0) then
{
    _age = 0;
};

/*
    Linear extrapolation.
*/
private _predictedPosition =
[
    (_position # 0) +
    ((_velocity # 0) * _age),

    (_position # 1) +
    ((_velocity # 1) * _age),

    (_position # 2) +
    ((_velocity # 2) * _age)
];

/*
    Store intelligence products.
*/
_contact set
[
    "predictedPosition",
    _predictedPosition
];

_contact set
[
    "predictionAge",
    _age
];

_contact set
[
    "lastPredictionTime",
    serverTime
];

[
    "PREDICTION",
    format
    [
        "Age:%1 | Position:%2 | Velocity:%3 | Predicted:%4",
        round _age,
        _position,
        _velocity,
        _predictedPosition
    ]
] call KBCF_fnc_log;

/*
    Explicit function return.
*/
_predictedPosition