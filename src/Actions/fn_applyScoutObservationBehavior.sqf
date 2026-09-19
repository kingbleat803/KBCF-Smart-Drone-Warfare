/*
    File: fn_applyScoutObservationBehavior.sqf

    Description:
    Applies player-visible SCOUT movement for the observation
    condition already calculated by
    KBCF_fnc_evaluateObservationCondition.

    Doctrine mapping:

    CURRENT
    - Maintain a deliberate, target-relative stand-off.
    - Avoid hovering directly above the observed target.

    DEGRADED
    - Tighten the observation stand-off and climb modestly.
    - Attempt to recover a stronger track without diving onto
      the target or creating erratic movement.

    LOST
    - Search around the last predicted position using a slow,
      bounded four-point pattern.
    - Continue using existing RECON scans for reacquisition.

    Ownership boundary:
    - Does not modify plan status.
    - Does not complete the action.
    - Does not release reservations.
    - Does not select a new target.
    - Does not alter scheduler or orchestration ownership.

    Returns:
    HashMap with success, mode, reason, and destination.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap],
    ["_plan", createHashMap],
    ["_observationCondition", "LOST"],
    ["_wasRefreshed", false]
];

private _result =
createHashMapFromArray
[
    ["success", false],
    ["mode", "NONE"],
    ["reason", "UNPROCESSED"],
    ["destination", []]
];

if (isNull _drone || {!alive _drone}) exitWith
{
    _result set ["reason", "INVALID_DRONE"];
    _result
};

private _driver = driver _drone;

if (isNull _driver) exitWith
{
    _result set ["reason", "DRONE_HAS_NO_DRIVER"];
    _result
};

private _droneGroup = group _driver;

if (isNull _droneGroup) exitWith
{
    _result set ["reason", "DRONE_GROUP_MISSING"];
    _result
};

if (!local _driver) exitWith
{
    _result set ["reason", "DRONE_DRIVER_NOT_LOCAL"];
    _result
};

if (!isEngineOn _drone) then
{
    _drone engineOn true;
};

private _contactPosition =
    _contact getOrDefault
    [
        "position",
        []
    ];

private _predictedPosition =
    _contact getOrDefault
    [
        "predictedPosition",
        _contactPosition
    ];

private _mode = "SEARCH";
private _reason = "LOST_SEARCH_PATTERN";
private _destination = [];
private _flightHeight = 90;
private _refreshDistance = 25;

switch (_observationCondition) do
{
    case "CURRENT":
    {
        _mode = "SHADOW";
        _reason = "CURRENT_MAINTAIN_STANDOFF";
        _flightHeight =
            _plan getOrDefault ["scoutCurrentFlightHeight", 60];

        private _standOff =
            _plan getOrDefault ["scoutCurrentStandOff", 175];

        if ((count _contactPosition) >= 2) then
        {
            private _dronePosition = getPosATL _drone;
            private _offsetX = (_dronePosition # 0) - (_contactPosition # 0);
            private _offsetY = (_dronePosition # 1) - (_contactPosition # 1);
            private _offsetLength = sqrt ((_offsetX * _offsetX) + (_offsetY * _offsetY));

            if (_offsetLength < 1) then
            {
                _offsetX = -1;
                _offsetY = 0;
                _offsetLength = 1;
            };

            _destination =
            [
                (_contactPosition # 0) + ((_offsetX / _offsetLength) * _standOff),
                (_contactPosition # 1) + ((_offsetY / _offsetLength) * _standOff),
                _flightHeight
            ];
        };
    };

    case "DEGRADED":
    {
        _mode = "RECOVER";
        _reason = "DEGRADED_RECOVER_TRACK";
        _flightHeight =
            _plan getOrDefault ["scoutRecoveryFlightHeight", 75];

        private _standOff =
            _plan getOrDefault ["scoutRecoveryStandOff", 110];

        private _recoveryCenter = _predictedPosition;

        if ((count _recoveryCenter) < 2) then
        {
            _recoveryCenter = _contactPosition;
        };

        if ((count _recoveryCenter) >= 2) then
        {
            private _dronePosition = getPosATL _drone;
            private _offsetX = (_dronePosition # 0) - (_recoveryCenter # 0);
            private _offsetY = (_dronePosition # 1) - (_recoveryCenter # 1);
            private _offsetLength = sqrt ((_offsetX * _offsetX) + (_offsetY * _offsetY));

            if (_offsetLength < 1) then
            {
                _offsetX = -1;
                _offsetY = 0;
                _offsetLength = 1;
            };

            _destination =
            [
                (_recoveryCenter # 0) + ((_offsetX / _offsetLength) * _standOff),
                (_recoveryCenter # 1) + ((_offsetY / _offsetLength) * _standOff),
                _flightHeight
            ];
        };
    };

    default
    {
        _mode = "SEARCH";
        _reason = "LOST_SEARCH_PATTERN";
        _flightHeight =
            _plan getOrDefault ["scoutSearchFlightHeight", 90];

        private _searchRadius =
            _plan getOrDefault ["scoutSearchRadius", 140];

        private _searchStepDuration =
            _plan getOrDefault ["scoutSearchStepDuration", 6];

        private _searchCenter = _predictedPosition;

        if ((count _searchCenter) < 2) then
        {
            _searchCenter = _contactPosition;
        };

        if ((count _searchCenter) >= 2) then
        {
            private _searchStartedAt =
                _plan getOrDefault ["scoutSearchStartedAt", -1];

            if (_searchStartedAt < 0) then
            {
                _searchStartedAt = serverTime;
                _plan set ["scoutSearchStartedAt", _searchStartedAt];
            };

            private _searchIndex =
                floor ((serverTime - _searchStartedAt) / _searchStepDuration);

            _searchIndex = _searchIndex mod 4;

            private _offsets =
            [
                [0, _searchRadius],
                [_searchRadius, 0],
                [0, -_searchRadius],
                [-_searchRadius, 0]
            ];

            private _searchOffset = _offsets # _searchIndex;

            _destination =
            [
                (_searchCenter # 0) + (_searchOffset # 0),
                (_searchCenter # 1) + (_searchOffset # 1),
                _flightHeight
            ];

            _plan set ["scoutSearchIndex", _searchIndex];
        };
    };
};

if ((count _destination) < 2) exitWith
{
    _result set ["mode", _mode];
    _result set ["reason", "NO_BEHAVIOR_DESTINATION"];
    _result
};

if (_drone isKindOf "Air") then
{
    _drone flyInHeight [_flightHeight, true];
};

private _previousMode =
    _plan getOrDefault ["scoutBehaviorMode", ""];

private _previousDestination =
    _plan getOrDefault ["scoutBehaviorDestination", []];

private _modeChanged =
    _previousMode isNotEqualTo _mode;

private _destinationChanged = true;

if ((count _previousDestination) >= 2) then
{
    _destinationChanged =
        (_previousDestination distance2D _destination) > _refreshDistance;
};

private _distanceToDestination =
    _drone distance2D _destination;

if
(
    _modeChanged
    ||
    _destinationChanged
    ||
    {_distanceToDestination > 40}
)
then
{
    _droneGroup move _destination;

    _plan set ["scoutBehaviorDestination", _destination];
    _plan set ["scoutBehaviorMoveAt", serverTime];
};

_plan set ["previousScoutBehaviorMode", _previousMode];
_plan set ["scoutBehaviorMode", _mode];

if (_modeChanged) then
{
    [
        "SCOUT",
        format
        [
            "Behavior Transition | Previous:%1 | Current:%2 | Condition:%3 | Refreshed:%4 | Destination:%5 | Drone:%6",
            if (_previousMode isEqualTo "") then {"NONE"} else {_previousMode},
            _mode,
            _observationCondition,
            _wasRefreshed,
            _destination,
            netId _drone
        ]
    ] call KBCF_fnc_log;
};

_result set ["success", true];
_result set ["mode", _mode];
_result set ["reason", _reason];
_result set ["destination", _destination];

_result
