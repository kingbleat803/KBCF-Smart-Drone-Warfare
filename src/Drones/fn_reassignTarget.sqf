/*
    File: fn_reassignTarget.sqf

    Description:
    Clears an invalid assignment and requests
    a new target from the Commander.
*/

params
[
    ["_drone", objNull],
    ["_side", sideUnknown]
];

if (isNull _drone) exitWith
{
    false
};

private _oldTarget =
    _drone getVariable
    [
        "KBCF_AssignedTarget",
        createHashMap
    ];

if ((count _oldTarget) > 0) then
{
    private _contactId =
        _oldTarget getOrDefault
        [
            "id",
            ""
        ];

    if (_contactId isNotEqualTo "") then
    {
        [
            _side,
            _contactId
        ] call KBCF_fnc_releaseTarget;
    };
};

_drone setVariable
[
    "KBCF_AssignedTarget",
    createHashMap
];

[
    _side,
    [_drone]
] call KBCF_fnc_updateBattlefield;

[
    "ASSIGNMENT",
    format
    [
        "Drone %1 requested reassignment",
        netId _drone
    ]
] call KBCF_fnc_log;

true