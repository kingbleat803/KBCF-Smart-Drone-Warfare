/*
    File: fn_updateContact.sqf

    Description:
    Updates an existing contact with fresh information.
*/

params
[
    ["_contact", createHashMap],
    ["_target", objNull]
];

if ((count _contact) isEqualTo 0) exitWith {};

if (isNull _target) exitWith {};

private _classification =
[
    _target
] call KBCF_fnc_classifyTarget;

private _threat =
[
    _classification
] call KBCF_fnc_evaluateThreat;

_contact set ["position", getPosATL _target];
_contact set ["velocity", velocity _target];
_contact set ["lastSeen", serverTime];
_contact set ["alive", alive _target];
_contact set ["classification", _classification];
_contact set ["threat", _threat];

private _confidence =
    _contact getOrDefault
    [
        "confidence",
        50
    ];

_confidence = _confidence + 5;

if (_confidence > 100) then
{
    _confidence = 100;
};

_contact set
[
    "confidence",
    _confidence
];

_contact