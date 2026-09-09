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

private _targetSpeed =
    vectorMagnitude _velocity;

private _interceptPosition =
[
    (_targetPosition # 0) + ((_velocity # 0) * _interceptTime),
    (_targetPosition # 1) + ((_velocity # 1) * _interceptTime),
    (_targetPosition # 2) + ((_velocity # 2) * _interceptTime)
];

private _interceptQuality = 100;

private _relativeAdvantage =
    _droneSpeed - _targetSpeed;

if (_relativeAdvantage <= 0) then
{
    _interceptQuality = 0;
}
else
{
    _interceptQuality =
        100 - _interceptTime;
};

if (_interceptQuality < 0) then
{
    _interceptQuality = 0;
};

_contact set
[
    "interceptPosition",
    _interceptPosition
];

_contact set
[
    "interceptTime",
    _interceptTime
];

_contact set
[
    "interceptQuality",
    _interceptQuality
];

[
    "INTERCEPT",
    format
    [
        "Time:%1 | Quality:%2 | Position:%3",
        round _interceptTime,
        round _interceptQuality,
        _interceptPosition
    ]
] call KBCF_fnc_log;

_interceptPosition