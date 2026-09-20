/*
    File: fn_actionRecon.sqf
	Author:KingBleat
    Description:
    Integrated SCOUT doctrine candidate for assigned-target
    observation inside the existing ACTIVE plan lifecycle.

    Preserved verified behavior:
    - Repeated RECON scanning
    - Observation-condition evaluation
    - Movement-state evaluation
    - STATIONARY_TO_MOVING event storage
    - REPORT event publication
    - Plan completion through executePlan

    Added player-visible doctrine behavior:
    - CURRENT  -> SHADOW stand-off observation
    - DEGRADED -> RECOVER closer observation position
    - LOST     -> bounded SEARCH around predicted position

    This action does not alter scheduler, commander,
    reservation, cleanup, or retasking ownership.

    The current patch covers assigned-target SCOUT behavior.
    Patrol without an assigned plan and service-cycle BDA are
    intentionally not claimed because those flows are owned
    outside this action by the current repository lifecycle.

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

private _observeCycleLimit =
    _plan getOrDefault ["scoutObserveCycleLimit", 20];

private _scoutState =
    _plan getOrDefault ["scoutState", ""];

if (_scoutState isEqualTo "") then
{
    _scoutState = "OBSERVE";
    _plan set ["scoutState", _scoutState];
    _plan set ["scoutObserveCycles", 0];
};

switch (_scoutState) do
{
    case "OBSERVE":
    {
        /*
            Survivability: if the SCOUT is being shot at, an evasion
            maneuver owns movement this cycle. Scanning, tracking and
            condition evaluation continue so intelligence is not lost;
            only the observation-position movement is suspended.
        */
        [_drone] call KBCF_fnc_installFireReaction;

        private _evading =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_evadeFire;

        private _lastSeenBefore =
            _contact getOrDefault ["lastSeen", -1];

        [_drone, 1000] call KBCF_fnc_reconScan;

        private _lastSeenAfter =
            _contact getOrDefault ["lastSeen", -1];

        private _wasRefreshed =
            _lastSeenAfter > _lastSeenBefore;

        private _trackUpdated =
            [_contact] call KBCF_fnc_trackTarget;

        private _observationConditionResult =
            [_contact, _plan] call KBCF_fnc_evaluateObservationCondition;

        private _observationCondition =
            _observationConditionResult getOrDefault ["condition", "LOST"];

        private _previousObservationCondition =
            _plan getOrDefault ["observationCondition", ""];

        _plan set ["previousObservationCondition", _previousObservationCondition];
        _plan set ["observationCondition", _observationCondition];
        _plan set ["observationConditionResult", _observationConditionResult];
        _plan set ["observationConditionUpdatedAt", serverTime];

        if (_previousObservationCondition isEqualTo "") then
        {
            [
                "SCOUT",
                format
                [
                    "ObservationCondition Initialized | Condition:%1 | Reason:%2 | Refreshed:%3 | TrackUpdated:%4 | TrackQuality:%5 | Confidence:%6 | TrackAge:%7 | Drone:%8",
                    _observationCondition,
                    _observationConditionResult getOrDefault ["reason", "UNKNOWN"],
                    _wasRefreshed,
                    _trackUpdated,
                    round (_observationConditionResult getOrDefault ["trackQuality", 0]),
                    round (_observationConditionResult getOrDefault ["confidence", 0]),
                    round (_observationConditionResult getOrDefault ["trackAge", 0]),
                    netId _drone
                ]
            ] call KBCF_fnc_log;
        }
        else
        {
            if (_previousObservationCondition isNotEqualTo _observationCondition) then
            {
                [
                    "SCOUT",
                    format
                    [
                        "ObservationCondition Transition | Previous:%1 | Current:%2 | Reason:%3 | Refreshed:%4 | TrackUpdated:%5 | TrackQuality:%6 | Confidence:%7 | TrackAge:%8 | Drone:%9",
                        _previousObservationCondition,
                        _observationCondition,
                        _observationConditionResult getOrDefault ["reason", "UNKNOWN"],
                        _wasRefreshed,
                        _trackUpdated,
                        round (_observationConditionResult getOrDefault ["trackQuality", 0]),
                        round (_observationConditionResult getOrDefault ["confidence", 0]),
                        round (_observationConditionResult getOrDefault ["trackAge", 0]),
                        netId _drone
                    ]
                ] call KBCF_fnc_log;
            }
            else
            {
                [
                    "SCOUT",
                    format
                    [
                        "ObservationCondition Check | Condition:%1 | Refreshed:%2 | TrackUpdated:%3 | TrackQuality:%4 | Confidence:%5 | TrackAge:%6 | Drone:%7",
                        _observationCondition,
                        _wasRefreshed,
                        _trackUpdated,
                        round (_observationConditionResult getOrDefault ["trackQuality", 0]),
                        round (_observationConditionResult getOrDefault ["confidence", 0]),
                        round (_observationConditionResult getOrDefault ["trackAge", 0]),
                        netId _drone
                    ]
                ] call KBCF_fnc_log;
            };
        };

        private _behaviorResult = createHashMap;

        if (_evading) then
        {
            _behaviorResult =
            createHashMapFromArray
            [
                ["success", true],
                ["mode", "EVADE"],
                ["reason", "EVADING_FIRE"],
                ["destination", []]
            ];
        }
        else
        {
            _behaviorResult =
            [
                _drone,
                _contact,
                _plan,
                _observationCondition,
                _wasRefreshed
            ] call KBCF_fnc_applyScoutObservationBehavior;
        };

        _plan set ["lastScoutBehaviorResult", _behaviorResult];

        if (!(_behaviorResult getOrDefault ["success", false])) then
        {
            [
                "SCOUT",
                format
                [
                    "Behavior Soft Failure | Mode:%1 | Reason:%2 | Drone:%3",
                    _behaviorResult getOrDefault ["mode", "NONE"],
                    _behaviorResult getOrDefault ["reason", "UNKNOWN"],
                    netId _drone
                ]
            ] call KBCF_fnc_log;
        };

        if (_wasRefreshed) then
        {
            private _velocity =
                _contact getOrDefault ["velocity", [0,0,0]];

            private _vx = _velocity select 0;
            private _vy = _velocity select 1;

            private _horizontalSpeed =
                sqrt ((_vx * _vx) + (_vy * _vy));

            private _currentMovementState = "STATIONARY";

            if (_horizontalSpeed >= 1.0) then
            {
                _currentMovementState = "MOVING";
            };

            private _scoutMovementState =
                _plan getOrDefault ["scoutMovementState", ""];

            if (_scoutMovementState isEqualTo "") then
            {
                _plan set ["scoutMovementState", _currentMovementState];

                [
                    "SCOUT",
                    format
                    [
                        "MovementState Initialized | State:%1 | Speed:%2 | Drone:%3",
                        _currentMovementState,
                        _horizontalSpeed,
                        netId _drone
                    ]
                ] call KBCF_fnc_log;
            }
            else
            {
                [
                    "SCOUT",
                    format
                    [
                        "MovementState Check | Previous:%1 | Current:%2 | Speed:%3 | Drone:%4",
                        _scoutMovementState,
                        _currentMovementState,
                        _horizontalSpeed,
                        netId _drone
                    ]
                ] call KBCF_fnc_log;

                if
                (
                    (_scoutMovementState isEqualTo "STATIONARY")
                    &&
                    (_currentMovementState isEqualTo "MOVING")
                )
                then
                {
                    private _observationEvent =
                        createHashMapFromArray
                        [
                            ["eventType", "STATIONARY_TO_MOVING"],
                            ["observedAt", time],
                            ["sourceDrone", netId _drone],
                            ["previousState", _scoutMovementState],
                            ["currentState", _currentMovementState]
                        ];

                    _plan set ["observationEvent", _observationEvent];

                    [
                        "SCOUT",
                        format
                        [
                            "Information Event Detected | STATIONARY_TO_MOVING | Drone:%1",
                            netId _drone
                        ]
                    ] call KBCF_fnc_log;

                    [
                        "SCOUT",
                        format
                        [
                            "Observation Event Stored | Type:%1 | Drone:%2",
                            "STATIONARY_TO_MOVING",
                            netId _drone
                        ]
                    ] call KBCF_fnc_log;
                };

                _plan set ["scoutMovementState", _currentMovementState];

                [
                    "SCOUT",
                    format
                    [
                        "MovementState Updated | State:%1 | Drone:%2",
                        _currentMovementState,
                        netId _drone
                    ]
                ] call KBCF_fnc_log;
            };
        };

        private _scoutObserveCycles =
            _plan getOrDefault ["scoutObserveCycles", 0];

        _scoutObserveCycles = _scoutObserveCycles + 1;
        _plan set ["scoutObserveCycles", _scoutObserveCycles];

        [
            "SCOUT",
            format
            [
                "Integrated OBSERVE cycle %1 | Condition:%2 | Mode:%3 | Drone:%4",
                _scoutObserveCycles,
                _observationCondition,
                _behaviorResult getOrDefault ["mode", "NONE"],
                netId _drone
            ]
        ] call KBCF_fnc_log;

        if (_scoutObserveCycles >= _observeCycleLimit) then
        {
            _plan set ["scoutState", "REPORT"];

            _result set ["success", true];
            _result set ["completed", false];
            _result set ["replanRequired", false];
            _result set ["reason", "SCOUT_TRANSITION_REPORT"];

            [
                "SCOUT",
                format
                [
                    "Integrated OBSERVE to REPORT transition | Drone:%1 | ObserveCycles:%2 | FinalCondition:%3 | FinalMode:%4",
                    netId _drone,
                    _scoutObserveCycles,
                    _observationCondition,
                    _behaviorResult getOrDefault ["mode", "NONE"]
                ]
            ] call KBCF_fnc_log;
        }
        else
        {
            _result set ["success", true];
            _result set ["completed", false];
            _result set ["replanRequired", false];
            _result set ["reason", "SCOUT_OBSERVING"];
        };
    };

    case "REPORT":
    {
        private _observationEvent =
            _plan getOrDefault ["observationEvent", createHashMap];

        private _eventType =
            _observationEvent getOrDefault ["eventType", ""];

        if (_eventType != "") then
        {
            [
                "SCOUT",
                format
                [
                    "REPORT Consumed Event | Type:%1 | Drone:%2",
                    _eventType,
                    netId _drone
                ]
            ] call KBCF_fnc_log;

            _contact set ["lastScoutReport", _observationEvent];

            [
                "SCOUT",
                format
                [
                    "REPORT Published Event | Type:%1 | Drone:%2",
                    _eventType,
                    netId _drone
                ]
            ] call KBCF_fnc_log;
        }
        else
        {
            [
                "SCOUT",
                format
                [
                    "REPORT No Observation Event | Drone:%1",
                    netId _drone
                ]
            ] call KBCF_fnc_log;
        };

        private _conditionReport =
        createHashMapFromArray
        [
            ["condition", _plan getOrDefault ["observationCondition", "UNKNOWN"]],
            ["behaviorMode", _plan getOrDefault ["scoutBehaviorMode", "NONE"]],
            ["reportedAt", serverTime],
            ["sourceDrone", netId _drone]
        ];

        _contact set ["lastScoutConditionReport", _conditionReport];

        _result set ["success", true];
        _result set ["completed", true];
        _result set ["replanRequired", false];
        _result set ["reason", "SCOUT_REPORT_COMPLETE"];

        [
            "SCOUT",
            format
            [
                "Integrated REPORT completion | Drone:%1 | Condition:%2 | Mode:%3",
                netId _drone,
                _conditionReport getOrDefault ["condition", "UNKNOWN"],
                _conditionReport getOrDefault ["behaviorMode", "NONE"]
            ]
        ] call KBCF_fnc_log;
    };

    default
    {
        _result set ["success", false];
        _result set ["completed", false];
        _result set ["replanRequired", true];
        _result set ["reason", "INVALID_SCOUT_STATE"];

        [
            "SCOUT",
            format
            [
                "Integrated invalid state | Drone:%1 | State:%2",
                netId _drone,
                _scoutState
            ]
        ] call KBCF_fnc_log;
    };
};

_result
