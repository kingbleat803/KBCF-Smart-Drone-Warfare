/*
    File: fn_classifyTarget.sqf

    Description:
    Returns a classification string for a target.
*/

params
[
    ["_target", objNull]
];

if (isNull _target) exitWith
{
    "UNKNOWN"
};

private _type = typeOf _target;

if (_target isKindOf "Man") exitWith
{
    "INFANTRY"
};

if (_target isKindOf "Tank") exitWith
{
    "MAIN_BATTLE_TANK"
};

if (_target isKindOf "Car") exitWith
{
    "LIGHT_VEHICLE"
};

if (_target isKindOf "Helicopter") exitWith
{
    "HELICOPTER"
};

if (_target isKindOf "Plane") exitWith
{
    "AIRCRAFT"
};

if (_target isKindOf "UAV_01_base_F") exitWith
{
    "DRONE"
};

"UNKNOWN"