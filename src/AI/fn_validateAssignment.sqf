/*
    File: fn_validateAssignment.sqf

    Description:
    Validates whether an assigned contact
    remains suitable for engagement.
*/

params
[
    ["_contact", createHashMap]
];

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

private _confidence =
    _contact getOrDefault
    [
        "confidence",
        0
    ];

private _alive =
    _contact getOrDefault
    [
        "alive",
        true
    ];

private _lastSeen =
    _contact getOrDefault
    [
        "lastSeen",
        0
    ];

private _reservation =
    _contact getOrDefault
    [
        "reservation",
        createHashMap
    ];

private _contactAge =
    serverTime - _lastSeen;

if (!_alive) exitWith
{
    false
};

if (_confidence <= 0) exitWith
{
    false
};

if (_contactAge > 60) exitWith
{
    false
};

private _owner =
    _reservation getOrDefault
    [
        "owner",
        objNull
    ];

if (!isNull _owner) then
{
    if (!alive _owner) exitWith
    {
        false
    };
};

true