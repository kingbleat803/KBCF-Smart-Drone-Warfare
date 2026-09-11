/*
    File: fn_actionMoveToIntercept.sqf

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

_droneGroup move _interceptPosition;

_result set
[
    "success",
    true
];

_result set
[
    "reason",
    "MOVING_TO_INTERCEPT"
];

[
    "ACTION",
    format
    [
        "Movement requested | Drone:%1 | Distance:%2 | Position:%3",
        netId _drone,
        round _distance,
        _interceptPosition
    ]
] call KBCF_fnc_log;

_result