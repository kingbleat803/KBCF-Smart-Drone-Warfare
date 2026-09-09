/*
    File: fn_predictPosition.sqf

    Description:
    Predicts the current position of a contact based on
    its last known position, velocity, and age.
*/

params
[
    ["_contact", createHashMap]
];

if ((count _contact) isEqualTo 0) exitWith
{
    [0,0,0]
};

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

private _predicted =
[
    (_position # 0) + ((_velocity # 0) * _age),
    (_position # 1) + ((_velocity # 1) * _age),
    (_position # 2) + ((_velocity # 2) * _age)
];

_predicted