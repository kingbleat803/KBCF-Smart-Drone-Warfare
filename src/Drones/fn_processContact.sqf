/*
    File: fn_processContact.sqf

    Description:
    Processes a detected target and publishes it to the blackboard.
*/

params
[
    ["_side", sideUnknown],
    ["_drone", objNull],
    ["_target", objNull]
];

if (isNull _target) exitWith {};

private _classification =
[
    _target
] call KBCF_fnc_classifyTarget;

private _score =
[
    _classification
] call KBCF_fnc_scoreTarget;

[
    _side,
    _drone,
    _target
] call KBCF_fnc_publishContact;

[
    "RECON",
    format
    [
        "Processed %1 Score %2",
        _classification,
        _score
    ]
] call KBCF_fnc_log;