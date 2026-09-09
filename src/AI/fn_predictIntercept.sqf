/*
    File: fn_predictIntercept.sqf

    Description:
    Predicts an intercept point for a drone
    against a moving target.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap]
];

if (isNull _drone) exitWith
{
    [0,0,0]
};

if ((count _contact) isEqualTo 0) exitWith
{
    [0,0,0]
};

private _targetPosition =
[
    _contact
] call KBCF_fnc_predictPosition;

private _dronePosition =
    getPosASL _drone;

private _distance =
    _dronePosition distance2D _targetPosition;

private _droneSpeed = 50;

private _interceptTime =
    _distance / _droneSpeed;

private _velocity =
    _contact getOrDefault
    [
        "velocity",
        [0,0,0]
    ];

private _interceptPosition =
[
    (_targetPosition # 0) + ((_velocity # 0) * _interceptTime),
    (_targetPosition # 1) + ((_velocity # 1) * _interceptTime),
    (_targetPosition # 2) + ((_velocity # 2) * _interceptTime)
];

[
    "INTERCEPT",
    format
    [
        "Intercept In %1s At %2",
        round _interceptTime,
        _interceptPosition
    ]
] call KBCF_fnc_log;

_interceptPosition