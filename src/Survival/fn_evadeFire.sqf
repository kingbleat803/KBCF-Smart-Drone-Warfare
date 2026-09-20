/*
    File: fn_evadeFire.sqf

    Description:
    One non-blocking evasion step, designed to be called once per
    scheduler cycle by any action that moves the drone (the same
    contract as the other actions: no sleeping, all state lives in the
    plan).

    Behaviour:
    - A new hostile-fire event triggers a maneuver.
    - First engagement(s): JINK - break perpendicular to the shooter
      (side chosen so terrain does not block the path), change altitude
      and apply a sharp lateral velocity kick so the dodge is visible
      immediately (AI pilots turn slowly).
    - Repeated engagement inside KBCF_EVADE_WINDOW seconds: COVER - search
      for a hidden hover point (buildings + dead ground) and break to it.
    - Total evasion time per plan is capped by KBCF_EVADE_BUDGET; once
      spent the drone commits to its mission instead of dodging forever.

    Plan-owned state written:
    evadeLog, evadeMode, evadeDestination, evadeUntil,
    evadeHandledFireTime, evadeCoverSearchAt, evadeLastTickAt,
    evadeSecondsUsed

    Params:
    0: OBJECT  - drone
    1: HASHMAP - contact (unused, kept for action signature parity)
    2: HASHMAP - active plan

    Returns:
    BOOL - true while an evasion maneuver is in progress. The caller
    must NOT issue its own movement order that cycle when this is true.

    Execution:
    Server only, drone-local.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap],
    ["_plan", createHashMap]
];

if (!isServer) exitWith
{
    false
};

if (!(missionNamespace getVariable ["KBCF_SURVIVAL_ENABLED", true])) exitWith
{
    false
};

if (isNull _drone || {!alive _drone}) exitWith
{
    false
};

if ((count _plan) isEqualTo 0) exitWith
{
    false
};

private _driver = driver _drone;

if (isNull _driver || {!local _driver}) exitWith
{
    false
};

private _droneGroup = group _driver;

if (isNull _droneGroup) exitWith
{
    false
};

[_drone] call KBCF_fnc_installFireReaction;

private _now = serverTime;
private _budget = missionNamespace getVariable ["KBCF_EVADE_BUDGET", 45];
private _secondsUsed = _plan getOrDefault ["evadeSecondsUsed", 0];

/*
    Budget spent: commit to the mission.
*/
if (_secondsUsed >= _budget) exitWith
{
    false
};

/*
    React to a new fire event.
*/
private _lastFireTime = _drone getVariable ["KBCF_LastFireTime", -1000];
private _handledFireTime = _plan getOrDefault ["evadeHandledFireTime", -1000];

if (_lastFireTime > _handledFireTime) then
{
    _plan set ["evadeHandledFireTime", _lastFireTime];

    private _window = missionNamespace getVariable ["KBCF_EVADE_WINDOW", 20];
    private _coverAfter = missionNamespace getVariable ["KBCF_EVADE_COVER_AFTER", 2];
    private _searchInterval = missionNamespace getVariable ["KBCF_COVER_SEARCH_INTERVAL", 5];
    private _jinkMin = missionNamespace getVariable ["KBCF_EVADE_JINK_MIN", 30];
    private _jinkMax = missionNamespace getVariable ["KBCF_EVADE_JINK_MAX", 55];
    private _kickSpeed = missionNamespace getVariable ["KBCF_EVADE_KICK_SPEED", 8];
    private _minHeight = missionNamespace getVariable ["KBCF_EVADE_MIN_HEIGHT", 8];
    private _maxHeight = missionNamespace getVariable ["KBCF_EVADE_MAX_HEIGHT", 45];

    private _log = (_plan getOrDefault ["evadeLog", []]) select { (_now - _x) <= _window };
    _log pushBack _now;
    _plan set ["evadeLog", _log];

    private _firer = _drone getVariable ["KBCF_LastFirer", objNull];
    private _threats = [_drone] call KBCF_fnc_getThreats;

    private _from = _firer;

    if (isNull _from && {(count _threats) > 0}) then
    {
        _from = _threats select 0;
    };

    private _bearing = random 360;

    if (!isNull _from) then
    {
        _bearing = _drone getDir _from;
    };

    /*
        Repeated engagement: look for cover (throttled).
    */
    private _cover = createHashMap;

    if ((count _log) >= _coverAfter && {(count _threats) > 0}) then
    {
        private _lastSearchAt = _plan getOrDefault ["evadeCoverSearchAt", -1000];

        if ((_now - _lastSearchAt) >= _searchInterval) then
        {
            _plan set ["evadeCoverSearchAt", _now];

            private _currentHeight = (getPosATL _drone) select 2;

            _cover =
            [
                _drone,
                getPosATL _drone,
                _threats,
                90,
                45,
                (_currentHeight max _minHeight) min _maxHeight
            ] call KBCF_fnc_findCoverPosition;
        };
    };

    private _mode = "JINK";
    private _destination = [];
    private _height = 25;
    private _kickDirection = _bearing + 90;
    private _holdSeconds = missionNamespace getVariable ["KBCF_EVADE_JINK_HOLD", 2.5];
    private _coverKind = "NONE";

    if ((count _cover) > 0) then
    {
        private _coverPosition = _cover get "position";

        _mode = "COVER";
        _coverKind = _cover get "kind";
        _destination = _coverPosition;
        _height = _coverPosition select 2;
        _kickDirection = _drone getDir _coverPosition;
        _holdSeconds = 6 + (random 4);
    }
    else
    {
        private _currentHeight = (getPosATL _drone) select 2;

        _height =
            ((_currentHeight + (selectRandom [-8, 8])) max _minHeight) min _maxHeight;

        private _jinkDistance = _jinkMin + (random (_jinkMax - _jinkMin));
        private _dronePositionASL = getPosASL _drone;
        private _order = selectRandom [[90, -90], [-90, 90]];
        private _chosen = [];

        /*
            Prefer the flank whose flight path is not blocked by terrain.
        */
        {
            if ((count _chosen) isEqualTo 0) then
            {
                private _direction = _bearing + _x + ((random 30) - 15);
                private _candidate = _drone getPos [_jinkDistance, _direction];

                private _candidateASL =
                [
                    _candidate select 0,
                    _candidate select 1,
                    (getTerrainHeightASL _candidate) + _height
                ];

                if
                (
                    (!(surfaceIsWater _candidate))
                    && {!(terrainIntersectASL [_dronePositionASL, _candidateASL])}
                )
                then
                {
                    _chosen =
                    [
                        _candidate select 0,
                        _candidate select 1,
                        _height,
                        _direction
                    ];
                };
            };
        } forEach _order;

        if ((count _chosen) isEqualTo 0) then
        {
            /*
                Both flanks blocked by terrain: climb and back away
                from the shooter.
            */
            _height = _maxHeight;

            private _fallbackDirection = _bearing + 180;
            private _fallback = _drone getPos [_jinkMin, _fallbackDirection];

            _chosen =
            [
                _fallback select 0,
                _fallback select 1,
                _height,
                _fallbackDirection
            ];
        };

        _destination = [_chosen select 0, _chosen select 1, _chosen select 2];
        _kickDirection = _chosen select 3;
    };

    _plan set ["evadeMode", _mode];
    _plan set ["evadeDestination", _destination];
    _plan set ["evadeUntil", _now + _holdSeconds];

    if (_drone isKindOf "Air") then
    {
        _drone flyInHeight [_height, true];

        private _kick = [sin _kickDirection, cos _kickDirection, 0];

        _drone setVelocity
        (
            (velocity _drone) vectorAdd (_kick vectorMultiply _kickSpeed)
        );
    };

    _droneGroup move _destination;

    [
        "EVADE",
        format
        [
            "Maneuver | Mode:%1 | Cover:%2 | Engagements:%3 in %4s | Height:%5 | Shooter:%6 | Drone:%7",
            _mode,
            _coverKind,
            count _log,
            _window,
            round _height,
            if (isNull _from) then {"UNKNOWN"} else {typeOf _from},
            netId _drone
        ]
    ] call KBCF_fnc_log;
};

/*
    Maintain an active maneuver.
*/
private _evadeUntil = _plan getOrDefault ["evadeUntil", -1];
private _active = _now < _evadeUntil;

if (_active) then
{
    private _lastTickAt = _plan getOrDefault ["evadeLastTickAt", _now];
    private _elapsed = ((_now - _lastTickAt) max 0) min 2;

    _plan set ["evadeSecondsUsed", _secondsUsed + _elapsed];
    _plan set ["evadeLastTickAt", _now];

    /*
        Aircraft AI can drop a move order; keep it alive until the
        drone reaches the evasion destination.
    */
    private _activeDestination = _plan getOrDefault ["evadeDestination", []];

    if ((count _activeDestination) >= 2 && {(_drone distance2D _activeDestination) > 8}) then
    {
        _droneGroup move _activeDestination;
    };
}
else
{
    _plan set ["evadeLastTickAt", _now];

    if ((_plan getOrDefault ["evadeMode", "NONE"]) isNotEqualTo "NONE") then
    {
        _plan set ["evadeMode", "NONE"];

        [
            "EVADE",
            format
            [
                "Maneuver complete | Evasion used:%1s of %2s | Drone:%3",
                round (_plan getOrDefault ["evadeSecondsUsed", 0]),
                _budget,
                netId _drone
            ]
        ] call KBCF_fnc_log;
    };
};

_active
