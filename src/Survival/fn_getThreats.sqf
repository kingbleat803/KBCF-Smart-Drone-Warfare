/*
    File: fn_getThreats.sqf

    Description:
    Returns hostile, alive, manned entities near the drone (or near an
    optional centre position), nearest first. Used to decide what can
    see a candidate hiding position.

    Params:
    0: OBJECT - drone (its side defines "hostile")
    1: NUMBER - search radius; negative uses KBCF_THREAT_RANGE (default 400)
    2: ARRAY  - optional centre position; default is the drone itself

    Returns:
    ARRAY of OBJECT, nearest first
*/

params
[
    ["_drone", objNull],
    ["_range", -1],
    ["_center", []]
];

if (isNull _drone) exitWith
{
    []
};

if (_range < 0) then
{
    _range = missionNamespace getVariable ["KBCF_THREAT_RANGE", 400];
};

private _origin = _drone;

if ((count _center) >= 2) then
{
    _origin = _center;
};

private _mySide = side _drone;

private _candidates =
    (_origin nearEntities [["CAManBase", "LandVehicle", "Air"], _range]) select
    {
        alive _x
        && {!(_x isEqualTo _drone)}
        && {(_mySide getFriend (side _x)) < 0.6}
        && {(_x isKindOf "CAManBase") || {(count (crew _x)) > 0}}
    };

/*
    Sort by distance. The index is included so ties never make sort
    compare two objects.
*/
private _pairs = [];

{
    _pairs pushBack [_origin distance2D _x, _forEachIndex, _x];
} forEach _candidates;

_pairs sort true;

_pairs apply { _x select 2 }
