/*
    File: fn_actionMoveToIntercept.sqf
	Author:KingBleat
    Description:
    Directs the assigned drone toward the intercept
    position stored in the active plan.

    Returns:
    Action result HashMap.
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
    ["reason", "UNPROCESSED"]
];

if (isNull _drone) exitWith
{
    _result set
    [
        "reason",
        "INVALID_DRONE"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

if (!alive _drone) exitWith
{
    _result set
    [
        "reason",
        "DRONE_DESTROYED"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

if ((count _plan) isEqualTo 0) exitWith
{
    _result set
    [
        "reason",
        "INVALID_PLAN"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

private _interceptPosition =
    _plan getOrDefault
    [
        "interceptPosition",
        []
    ];

if ((count _interceptPosition) < 2) exitWith
{
    _result set
    [
        "reason",
        "NO_INTERCEPT_POSITION"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

private _distance =
    _drone distance2D _interceptPosition;

private _completionRadius = 25;

/*
    The drone reached the objective.

    Reaching the intercept point is not itself plan
    completion. The plan carries a terminalActionType
    (written by fn_planAttack) describing what the drone
    must do once it arrives. Arrival hands the plan's
    actionType over to that terminal action so the next
    scheduler cycle dispatches it through the existing
    fn_executeAction router. This handler never dispatches
    the terminal action itself; it only performs the
    handoff and returns.

    A terminal action is only accepted if it is one of the
    known types AND its handler function is actually
    compiled - a string match alone is not enough, since a
    correct-looking terminalActionType whose function failed
    to compile would otherwise strand the plan ACTIVE with
    no handler able to advance it.
*/
if (_distance <= _completionRadius) exitWith
{
    private _terminalActionType =
        _plan getOrDefault
        [
            "terminalActionType",
            ""
        ];

    private _terminalActionHandlers =
    createHashMapFromArray
    [
        ["RECON", "KBCF_fnc_actionRecon"],
        ["ATTACK", "KBCF_fnc_actionAttack"],
        ["GRENADE_DROP", "KBCF_fnc_actionGrenadeDrop"]
    ];

    private _handlerFunctionName =
        _terminalActionHandlers getOrDefault
        [
            _terminalActionType,
            ""
        ];

    if (_handlerFunctionName isEqualTo "") exitWith
    {
        _result set
        [
            "success",
            false
        ];

        _result set
        [
            "completed",
            false
        ];

        _result set
        [
            "replanRequired",
            true
        ];

        _result set
        [
            "reason",
            "INVALID_TERMINAL_ACTION"
        ];

        [
            "ACTION",
            format
            [
                "Intercept reached | Invalid terminal action | Drone:%1 | TerminalActionType:%2",
                netId _drone,
                _terminalActionType
            ]
        ] call KBCF_fnc_log;

        _result
    };

    if (isNil _handlerFunctionName) exitWith
    {
        _result set
        [
            "success",
            false
        ];

        _result set
        [
            "completed",
            false
        ];

        _result set
        [
            "replanRequired",
            true
        ];

        _result set
        [
            "reason",
            "TERMINAL_ACTION_HANDLER_UNAVAILABLE"
        ];

        [
            "ACTION",
            format
            [
                "Intercept reached | Terminal action handler not compiled | Drone:%1 | TerminalActionType:%2 | Handler:%3",
                netId _drone,
                _terminalActionType,
                _handlerFunctionName
            ]
        ] call KBCF_fnc_log;

        _result
    };

    private _previousActionType =
        _plan getOrDefault
        [
            "actionType",
            ""
        ];

    /*
        Handoff. The plan's actionType now points at the
        terminal action; the plan stays ACTIVE so the next
        scheduler cycle's fn_executePlan -> fn_executeAction
        call dispatches it. Because actionType no longer
        equals MOVE_TO_INTERCEPT after this write, this
        handler will not be re-entered for this plan, which
        is what keeps the transition idempotent - it cannot
        run a second time or overwrite these fields again.
    */
    _plan set
    [
        "actionType",
        _terminalActionType
    ];

    _plan set
    [
        "interceptReachedAt",
        serverTime
    ];

    _plan set
    [
        "previousActionType",
        _previousActionType
    ];

    _plan set
    [
        "transitionReason",
        "INTERCEPT_REACHED_TRANSITIONING"
    ];

    _result set
    [
        "success",
        true
    ];

    _result set
    [
        "completed",
        false
    ];

    _result set
    [
        "replanRequired",
        false
    ];

    _result set
    [
        "reason",
        "INTERCEPT_REACHED_TRANSITIONING"
    ];

    [
        "ACTION",
        format
        [
            "Intercept reached | Transitioning | Drone:%1 | Distance:%2 | From:%3 | To:%4",
            netId _drone,
            round _distance,
            _previousActionType,
            _terminalActionType
        ]
    ] call KBCF_fnc_log;

    _result
};

/*
    Retrieve the drone's AI driver.

    For an autonomous UAV, this should normally
    be the AI unit controlling the vehicle.
*/
private _driver =
    driver _drone;

if (isNull _driver) exitWith
{
    _result set
    [
        "reason",
        "DRONE_HAS_NO_DRIVER"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

private _droneGroup =
    group _driver;

if (isNull _droneGroup) exitWith
{
    _result set
    [
        "reason",
        "DRONE_GROUP_MISSING"
    ];

    _result set
    [
        "replanRequired",
        true
    ];

    _result
};

/*
    Group movement commands must run where the
    controlling group is local.
*/
if (!local _driver) exitWith
{
    _result set
    [
        "reason",
        "DRONE_DRIVER_NOT_LOCAL"
    ];

    _result set
    [
        "replanRequired",
        false
    ];

    [
        "ACTION",
        format
        [
            "Movement not issued | Driver not local | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

/*
    Physical UAV lifecycle handoff.

    A valid movement plan does not automatically make a
    grounded UAV start its engine or take off.
*/

if (!isEngineOn _drone) then
{
    _drone engineOn true;

    [
        "ACTION",
        format
        [
            "Engine started | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;
};

/*
    Survivability layer.

    Fire detection is installed once per drone. If the drone was shot
    at, an evasion maneuver takes over movement for this cycle; the
    normal intercept order is re-issued on the first cycle after the
    maneuver ends.
*/
[_drone] call KBCF_fnc_installFireReaction;

if ([_drone, _contact, _plan] call KBCF_fnc_evadeFire) exitWith
{
    _result set ["success", true];
    _result set ["completed", false];
    _result set ["replanRequired", false];
    _result set ["reason", "EVADING_FIRE"];

    _result
};

private _movementPosition =
    +_interceptPosition;

private _droneProfile =
    _plan getOrDefault
    [
        "droneProfile",
        "UNKNOWN"
    ];

private _strikeProfile =
    (missionNamespace getVariable ["KBCF_SURVIVAL_ENABLED", true])
    && {_droneProfile in ["FPV_STRIKE", "BOMBER"]};

/*
    Strike profiles fly low so terrain and objects screen them.
    Other profiles keep the verified 50 m flight height.
*/
private _flightHeight = 50;

if (_strikeProfile) then
{
    _flightHeight =
        _plan getOrDefault
        [
            "strikeApproachHeight",
            (missionNamespace getVariable ["KBCF_STRIKE_APPROACH_HEIGHT", 15])
        ];
};

private _moveReason = "MOVING_TO_INTERCEPT";

/*
    Terrain-masked approach (strike profiles only).

    Once per plan, if the target is far enough away and hostiles are
    near it, look for a staging point that terrain or a building hides
    from them and fly there first. Then continue to the intercept
    position as before.

    approachStageState: "" (undecided) | NONE | TRAVEL | DONE
*/
private _stageState =
    _plan getOrDefault
    [
        "approachStageState",
        ""
    ];

if (_strikeProfile && {_stageState isEqualTo ""}) then
{
    _stageState = "NONE";

    if
    (
        _distance >
        (_plan getOrDefault ["approachStageMinDistance", 220])
    )
    then
    {
        private _threats =
        [
            _drone,
            300,
            _interceptPosition
        ] call KBCF_fnc_getThreats;

        if ((count _threats) > 0) then
        {
            private _stage =
            [
                _drone,
                _interceptPosition,
                _threats,
                250,
                120,
                _flightHeight
            ] call KBCF_fnc_findCoverPosition;

            if ((count _stage) > 0) then
            {
                _plan set ["approachStagePosition", _stage get "position"];
                _plan set ["approachStageAssignedAt", serverTime];

                _stageState = "TRAVEL";

                [
                    "ACTION",
                    format
                    [
                        "Cover stage selected | Drone:%1 | Kind:%2 | Position:%3 | Threats:%4",
                        netId _drone,
                        _stage get "kind",
                        _stage get "position",
                        count _threats
                    ]
                ] call KBCF_fnc_log;
            };
        };
    };

    _plan set ["approachStageState", _stageState];
};

if (_stageState isEqualTo "TRAVEL") then
{
    private _stagePosition =
        _plan getOrDefault
        [
            "approachStagePosition",
            []
        ];

    private _stageAge =
        serverTime -
        (_plan getOrDefault ["approachStageAssignedAt", serverTime]);

    if
    (
        (count _stagePosition) < 2
        || {(_drone distance2D _stagePosition) <= 25}
        || {_stageAge > 60}
    )
    then
    {
        _plan set ["approachStageState", "DONE"];

        [
            "ACTION",
            format
            [
                "Cover stage complete | Drone:%1 | Age:%2",
                netId _drone,
                round _stageAge
            ]
        ] call KBCF_fnc_log;
    }
    else
    {
        _movementPosition = +_stagePosition;
        _moveReason = "MOVING_TO_COVER_STAGE";
    };
};

/*
    Air assets require a flight altitude in order to
    physically execute movement.
*/
if (_drone isKindOf "Air") then
{
    _drone flyInHeight
    [
        _flightHeight,
        true
    ];

    if ((count _movementPosition) < 3) then
    {
        _movementPosition pushBack _flightHeight;
    }
    else
    {
        _movementPosition set
        [
            2,
            _flightHeight
        ];
    };
};

_droneGroup move _movementPosition;

_result set
[
    "success",
    true
];

_result set
[
    "completed",
    false
];

_result set
[
    "replanRequired",
    false
];

_result set
[
    "reason",
    _moveReason
];

[
    "ACTION",
    format
    [
        "Movement requested | Drone:%1 | Distance:%2 | Position:%3 | Engine:%4",
        netId _drone,
        round _distance,
        _movementPosition,
        isEngineOn _drone
    ]
] call KBCF_fnc_log;

_result