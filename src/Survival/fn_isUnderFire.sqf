/*
    File: fn_isUnderFire.sqf

    Description:
    Returns true if the drone recorded hostile fire (a round aimed at it
    passing close, a hit, or an incoming missile) within the last
    _window seconds.

    Requires KBCF_fnc_installFireReaction to have been called for the
    drone; otherwise this always returns false.

    Params:
    0: OBJECT - drone
    1: NUMBER - window in seconds (default 1.5)

    Returns:
    BOOL
*/

params
[
    ["_drone", objNull],
    ["_window", 1.5]
];

if (isNull _drone) exitWith
{
    false
};

private _lastFireTime =
    _drone getVariable
    [
        "KBCF_LastFireTime",
        -1000
    ];

(serverTime - _lastFireTime) <= _window
