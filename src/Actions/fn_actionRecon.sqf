/*
    File: fn_actionRecon.sqf

    Description:
    Non-destructive terminal action. Wraps the existing,
    side-effect-free KBCF_fnc_reconScan (queries nearby
    objects and publishes contacts; no damage, no vehicle
    creation, no drone loss) so the full plan lifecycle -
    PENDING to ACTIVE to COMPLETE - can be exercised without
    depending on actionAttack or actionGrenadeDrop, neither
    of which is part of this patch.

    A recon pass completes on its first execution: it is a
    passive scan, not an engagement, so there is nothing to
    wait on.

    Returns:
    Action Result HashMap.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap],
    ["_plan", createHashMap]
];

private _result =
createHashMapFromArray
[
    ["success", false],
    ["completed", false],
    ["replanRequired", false],
    ["reason", "UNKNOWN"]
];

if (isNull _drone) exitWith
{
    _result set ["reason", "INVALID_DRONE"];
    _result set ["replanRequired", true];
    _result
};

if (!alive _drone) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "DRONE_LOST"];
    _result
};

[
    _drone,
    1000
] call KBCF_fnc_reconScan;

_result set ["success", true];
_result set ["completed", true];
_result set ["reason", "RECON_COMPLETE"];

_result