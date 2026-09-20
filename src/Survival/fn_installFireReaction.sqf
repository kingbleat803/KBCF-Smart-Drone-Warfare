/*
    File: fn_installFireReaction.sqf

    Description:
    Installs, once per drone, the event handlers that let the drone know
    it is being shot at. Safe to call every scheduler cycle; it is
    idempotent (same pattern fn_actionAttack uses for its impact handler).

    Detection sources:
    - FiredNear       hostile shooter fired near the drone while aiming at it
    - Hit             the drone took damage from a hostile source
    - IncomingMissile a guided round was launched at the drone

    Limitation:
    The engine only raises FiredNear for shots fired fairly close to the
    unit (about 70 m as far as I know), so this models rounds cracking
    past the drone, not long-range fire. Runtime testing should confirm
    the practical range.

    Params:
    0: OBJECT - drone

    Returns:
    BOOL - true if handlers are installed (now or previously)

    Execution:
    Server only.
*/

params
[
    ["_drone", objNull]
];

if (!isServer) exitWith
{
    false
};

if (isNull _drone || {!alive _drone}) exitWith
{
    false
};

if (_drone getVariable ["KBCF_FireReactionInstalled", false]) exitWith
{
    true
};

private _firedNearCode =
{
    params
    [
        "_unit",
        "_firer",
        "_distance",
        "_weapon",
        "_muzzle",
        "_mode",
        "_ammo",
        "_gunner"
    ];

    [
        _unit,
        _firer,
        _distance,
        _weapon,
        "FIRED_NEAR"
    ] call KBCF_fnc_recordFire;
};

private _hitCode =
{
    params
    [
        "_unit",
        "_source",
        "_damage",
        "_instigator"
    ];

    private _shooter = _instigator;

    if (isNull _shooter) then
    {
        _shooter = _source;
    };

    [
        _unit,
        _shooter,
        -1,
        "",
        "HIT"
    ] call KBCF_fnc_recordFire;
};

private _missileCode =
{
    params
    [
        "_target",
        "_ammo",
        "_vehicle",
        "_instigator"
    ];

    private _shooter = _instigator;

    if (isNull _shooter) then
    {
        _shooter = _vehicle;
    };

    [
        _target,
        _shooter,
        -1,
        "",
        "MISSILE"
    ] call KBCF_fnc_recordFire;
};

/*
    FiredNear is attached to the vehicle and to its AI crew, because
    depending on the drone class the engine may raise it on either.
    Both call the same recorder, so a double report is harmless.
*/
{
    _x addEventHandler ["FiredNear", _firedNearCode];
} forEach ([_drone] + (crew _drone));

_drone addEventHandler ["Hit", _hitCode];
_drone addEventHandler ["IncomingMissile", _missileCode];

_drone setVariable ["KBCF_FireReactionInstalled", true];

[
    "EVADE",
    format
    [
        "Fire reaction installed | Drone:%1",
        netId _drone
    ]
] call KBCF_fnc_log;

true
