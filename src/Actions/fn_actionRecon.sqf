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
/*
    File: fn_actionRecon.sqf

    Description:
    Bounded SCOUT state-persistence prototype.

    This is not the completed SCOUT controller.

    The prototype verifies whether minimal SCOUT-owned state
    can persist inside the existing ACTIVE plan lifecycle.

    Prototype behavior:

    OBSERVE
    -> repeated ACTIVE executions
    -> REPORT
    -> completed = true

    SCOUT-owned prototype fields:

    scoutState
    scoutObserveCycles

    The fields are stored on the existing plan HashMap.

    This function does not modify plan["status"] directly.
    Plan lifecycle interpretation remains owned by
    KBCF_fnc_executePlan.

    Terminal cleanup remains owned by KBCF_fnc_scheduler.

    This prototype does not implement:

    - Risk Engine
    - Confidence Engine
    - Position selection
    - Position scoring
    - SEARCH
    - BDA
    - PATROL
    - INVESTIGATE
    - Full SCOUT doctrine behavior

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

/*
    Preserve the existing invalid-drone failure behavior.
*/
if (isNull _drone) exitWith
{
    _result set ["reason", "INVALID_DRONE"];
    _result set ["replanRequired", true];

    _result
};

/*
    Preserve the existing destroyed-drone behavior.
*/
if (!alive _drone) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "DRONE_LOST"];

    _result
};

/*
    Temporary prototype limit.

    This value exists only to force a bounded transition
    from OBSERVE to REPORT. It is not a doctrine value,
    confidence threshold, or final gameplay setting.
*/
private _prototypeObserveCycleLimit = 20;

/*
    Initialize only the two SCOUT-owned prototype fields.

    Their persistence inside the plan HashMap remains a
    candidate implementation hypothesis until demonstrated
    in the Arma runtime.
*/
private _scoutState =
    _plan getOrDefault
    [
        "scoutState",
        ""
    ];

if (_scoutState isEqualTo "") then
{
    _scoutState = "OBSERVE";

    _plan set
    [
        "scoutState",
        _scoutState
    ];

    _plan set
    [
        "scoutObserveCycles",
        0
    ];
};

switch (_scoutState) do
{
    case "OBSERVE":
{
    /*
        Capture freshness before scan.
    */
    private _lastSeenBefore =
        _contact getOrDefault
        [
            "lastSeen",
            -1
        ];

    /*
        Preserve the existing recon scan and scan range.
    */
    [
        _drone,
        1000
    ] call KBCF_fnc_reconScan;

    /*
        Capture freshness after scan.
    */
    private _lastSeenAfter =
        _contact getOrDefault
        [
            "lastSeen",
            -1
        ];

    private _wasRefreshed =
        _lastSeenAfter > _lastSeenBefore;

    /*
        Prototype V2 movement-event evaluation.
        Only execute if this assigned contact
        was refreshed during this scan.
    */
    if (_wasRefreshed) then
    {
        private _velocity =
            _contact getOrDefault
            [
                "velocity",
                [0,0,0]
            ];

        private _vx = _velocity select 0;
        private _vy = _velocity select 1;

        /*
            Horizontal speed only.
            Vertical movement is ignored.
        */
        private _horizontalSpeed =
            sqrt
            (
                (_vx * _vx)
                +
                (_vy * _vy)
            );

        private _currentMovementState = "STATIONARY";

        /*
            Prototype-only threshold.
        */
        if (_horizontalSpeed >= 1.0) then
        {
            _currentMovementState = "MOVING";
        };

        private _scoutMovementState =
            _plan getOrDefault
            [
                "scoutMovementState",
                ""
            ];

        /*
            First fresh observation creates
            the baseline only.
        */
        if (_scoutMovementState isEqualTo "") then
        {
            _plan set
            [
                "scoutMovementState",
                _currentMovementState
            ];

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

    _plan set
    [
        "observationEvent",
        _observationEvent
    ];

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

            _plan set
            [
                "scoutMovementState",
                _currentMovementState
            ];

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
        _plan getOrDefault
        [
            "scoutObserveCycles",
            0
        ];

    _scoutObserveCycles =
        _scoutObserveCycles + 1;

    _plan set
    [
        "scoutObserveCycles",
        _scoutObserveCycles
    ];

    [
        "SCOUT",
        format
        [
            "Prototype OBSERVE cycle %1 | Drone:%2",
            _scoutObserveCycles,
            netId _drone
        ]
    ] call KBCF_fnc_log;

    if
    (
        _scoutObserveCycles
        >=
        _prototypeObserveCycleLimit
    )
    then
    {
        _plan set
        [
            "scoutState",
            "REPORT"
        ];

        _result set ["success", true];
        _result set ["completed", false];
        _result set ["replanRequired", false];
        _result set ["reason", "SCOUT_TRANSITION_REPORT"];

        [
            "SCOUT",
            format
            [
                "Prototype OBSERVE to REPORT transition | Drone:%1 | ObserveCycles:%2",
                netId _drone,
                _scoutObserveCycles
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
    /*
        Retrieve observation event generated
        during OBSERVE.
    */
    private _observationEvent =
        _plan getOrDefault
        [
            "observationEvent",
            createHashMap
        ];

    private _eventType =
        _observationEvent getOrDefault
        [
            "eventType",
            ""
        ];

    /*
        Verify REPORT consumes the stored event.
    */
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

        /*
            Publish structured report to the contact.
        */
        _contact set
        [
            "lastScoutReport",
            _observationEvent
        ];

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

    _result set ["success", true];
    _result set ["completed", true];
    _result set ["replanRequired", false];
    _result set ["reason", "SCOUT_REPORT_COMPLETE"];

    [
        "SCOUT",
        format
        [
            "Prototype REPORT completion | Drone:%1",
            netId _drone
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
                "Prototype invalid state | Drone:%1 | State:%2",
                netId _drone,
                _scoutState
            ]
        ] call KBCF_fnc_log;
    };
};

_result