/*
    fn_registerDrone.sqf

    Params:
    0: OBJECT - drone
    1: SIDE   - side
    2: STRING - profile
*/

params [
    ["_drone", objNull],
    ["_side", sideUnknown],
    ["_profile", "SCOUT"]
];

if (isNull _drone) exitWith { false };

private _id = netId _drone;

private _sideRegistry = KBCF_Drones getOrDefault [
    _side,
    createHashMap
];

if (!isNil { _sideRegistry get _id }) exitWith { true };

_drone setVariable [
    "KBCF_Controlled",
    true,
    true
];

_drone setVariable [
    "KBCF_DroneProfile",
    _profile,
    true
];

_drone setVariable [
    "KBCF_Status",
    "AVAILABLE",
    true
];

_drone setVariable [
    "KBCF_AssignedTarget",
    createHashMap,
    true
];

private _record = createHashMapFromArray [
    ["id", _id],
    ["object", _drone],
    ["side", _side],
    ["profile", _profile],
    ["status", "REGISTERED"],
    ["registeredAt", serverTime]
];

_sideRegistry set [_id, _record];
KBCF_Drones set [_side, _sideRegistry];

diag_log format [
    "[KBCF] Registered drone %1 (%2)",
    _id,
    _profile
];

true