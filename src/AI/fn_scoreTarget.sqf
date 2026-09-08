/*
    File: fn_scoreTarget.sqf

    Description:
    Returns a score based on threat evaluation.
*/

params
[
    ["_classification", "UNKNOWN"]
];

[
    _classification
] call KBCF_fnc_evaluateThreat