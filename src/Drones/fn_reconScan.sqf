/*
    File: fn_reconScan.sqf

    Description:
    Scans for nearby enemy targets.
*/

params
[
    ["_drone", objNull],
    ["_range", 1000]
];

if (isNull _drone) exitWith {};

private _targets =
nearestObjects
[
    _drone,
    ["Man","LandVehicle","Air"],
    _range
];

{
    if (side _x != side _drone) then
    {
        [
            side _drone,
            _drone,
            _x
        ] call KBCF_fnc_publishContact;
    };
}
forEach _targets;

[
    "RECON",
    format
    [
        "Scan Complete. %1 Targets Found",
        count _targets
    ]
] call KBCF_fnc_log;