/*
    File: fn_recordFire.sqf

    Description:
    Records that a drone is being shot at. Called by the event handlers
    installed in KBCF_fnc_installFireReaction; not intended to be called
    from actions directly (actions read the result through
    KBCF_fnc_isUnderFire or the drone variables below).

    FIRED_NEAR shots are only counted when the shooter was actually aiming
    at the drone (round passes within roughly 10 m). Shots fired at
    something else nearby are ignored, so the drone does not dodge every
    gunshot on the battlefield.

    Writes on the drone:
    - KBCF_LastFireTime  (serverTime)
    - KBCF_LastFirer     (object)
    - KBCF_FireEventCount

    Params:
    0: OBJECT - victim (the drone, or a crew member inside it)
    1: OBJECT - shooter
    2: NUMBER - shooter distance, or -1 if unknown
    3: STRING - weapon classname, or "" if unknown
    4: STRING - FIRED_NEAR | HIT | MISSILE

    Returns:
    BOOL - true if the event was recorded
*/

params
[
    ["_victim", objNull],
    ["_shooter", objNull],
    ["_distance", -1],
    ["_weapon", ""],
    ["_kind", "FIRED_NEAR"]
];

if (!isServer) exitWith
{
    false
};

private _drone = vehicle _victim;

if (isNull _drone || {isNull _shooter}) exitWith
{
    false
};

if (((side _drone) getFriend (side _shooter)) >= 0.6) exitWith
{
    false
};

private _accept = true;

if (_kind isEqualTo "FIRED_NEAR") then
{
    private _direction = _shooter weaponDirection _weapon;

    if (_direction isEqualTo [0,0,0]) then
    {
        /*
            Aim direction unavailable. Only trust very close shots.
        */
        _accept = (_distance >= 0) && {_distance <= 25};
    }
    else
    {
        private _toDrone =
            (getPosASL _drone) vectorDiff (eyePos _shooter);

        private _dot =
            (
                (vectorNormalized _direction)
                vectorDotProduct
                (vectorNormalized _toDrone)
            ) min 1 max -1;

        private _angle = acos _dot;

        /*
            Angular tolerance equivalent to a ~10 m miss distance,
            never tighter than 5 degrees.
        */
        private _tolerance = (atan (10 / (_distance max 1))) max 5;

        _accept = _angle <= _tolerance;
    };
};

if (!_accept) exitWith
{
    false
};

private _previousFireTime =
    _drone getVariable
    [
        "KBCF_LastFireTime",
        -1000
    ];

_drone setVariable ["KBCF_LastFireTime", serverTime];
_drone setVariable ["KBCF_LastFirer", _shooter];
_drone setVariable
[
    "KBCF_FireEventCount",
    (_drone getVariable ["KBCF_FireEventCount", 0]) + 1
];

/*
    Log at most once per second so a sustained burst does not
    flood the RPT.
*/
if ((serverTime - _previousFireTime) > 1) then
{
    [
        "EVADE",
        format
        [
            "Under fire | Kind:%1 | Distance:%2 | Shooter:%3 | Drone:%4",
            _kind,
            round _distance,
            typeOf _shooter,
            netId _drone
        ]
    ] call KBCF_fnc_log;
};

true
