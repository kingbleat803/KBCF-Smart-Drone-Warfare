/*
    File: fn_executePlan.sqf

    Description:
    Validates, activates, executes, and updates
    the lifecycle of an existing plan.

    Execution:
    Server only.

    Compatibility:
    - Signature preserved: [_contact] call KBCF_fnc_executePlan
    - Reads and writes contact["attackPlan"] only.
    - Does not release reservations, clear assignment, or
      delete the plan. Those responsibilities belong to
      fn_scheduler.

    Returns:
    Boolean. true if the plan was processed this cycle
    (activated, executed, or resolved to a terminal state).
    false if there was nothing to process: missing contact,
    missing plan, or the plan was already terminal on entry.
*/

params
[
    ["_contact", createHashMap]
];

if (!isServer) exitWith
{
    false
};

if ((count _contact) isEqualTo 0) exitWith
{
    false
};

private _plan =
    _contact getOrDefault
    [
        "attackPlan",
        createHashMap
    ];

if ((count _plan) isEqualTo 0) exitWith
{
    false
};

private _status =
    _plan getOrDefault
    [
        "status",
        "PENDING"
    ];

private _terminalStates =
[
    "COMPLETE",
    "FAILED",
    "EXPIRED"
];

if (_status in _terminalStates) exitWith
{
    false
};

private _drone =
    _plan getOrDefault
    [
        "assignedDrone",
        objNull
    ];

private _target =
    _plan getOrDefault
    [
        "targetObject",
        objNull
    ];

/*
    Validate assigned drone.
*/
if (!alive _drone) exitWith
{
    private _fpvImpactDetonated =
        _drone getVariable
        [
            "KBCF_FPVImpactDetonated",
            false
        ];

    if (_fpvImpactDetonated) then
    {
        _plan set ["status", "COMPLETE"];
        _plan set ["failureReason", ""];
        _plan set ["replanRequired", false];
        _plan set ["completedAt", serverTime];
        _plan set ["lastExecutionTime", serverTime];

        _contact set ["attackPlan", _plan];

        [
            "PLAN",
            format
            [
                "Plan completed | FPV physical impact | Drone:%1",
                netId _drone
            ]
        ] call KBCF_fnc_log;
    }
    else
    {
        _plan set ["status", "FAILED"];
        _plan set ["failureReason", "ASSIGNED_DRONE_DESTROYED"];
        _plan set ["replanRequired", true];
        _plan set ["lastExecutionTime", serverTime];

        _contact set ["attackPlan", _plan];

        [
            "PLAN",
            format
            [
                "Plan failed | Drone destroyed:%1",
                netId _drone
            ]
        ] call KBCF_fnc_log;
    };

    true
};

if (!alive _drone) exitWith
{
    _plan set ["status", "FAILED"];
    _plan set ["failureReason", "ASSIGNED_DRONE_DESTROYED"];
    _plan set ["replanRequired", true];
    _plan set ["lastExecutionTime", serverTime];

    _contact set ["attackPlan", _plan];

    [
        "PLAN",
        format ["Plan failed | Drone destroyed:%1", netId _drone]
    ] call KBCF_fnc_log;

    true
};

/*
    Validate target object.
*/
if (isNull _target) exitWith
{
    _plan set ["status", "FAILED"];
    _plan set ["failureReason", "TARGET_MISSING"];
    _plan set ["replanRequired", true];
    _plan set ["lastExecutionTime", serverTime];

    _contact set ["attackPlan", _plan];

    [
        "PLAN",
        format
        [
            "Plan failed | Target missing | Contact:%1",
            _plan getOrDefault ["contactId", "UNKNOWN"]
        ]
    ] call KBCF_fnc_log;

    true
};

/*
    A destroyed target is mission success, not a failure.
*/
if (!alive _target) exitWith
{
    _plan set ["status", "COMPLETE"];
    _plan set ["failureReason", ""];
    _plan set ["replanRequired", false];
    _plan set ["completedAt", serverTime];
    _plan set ["lastExecutionTime", serverTime];

    _contact set ["attackPlan", _plan];

    [
        "PLAN",
        format
        [
            "Plan completed | Target already destroyed | Contact:%1",
            _plan getOrDefault ["contactId", "UNKNOWN"]
        ]
    ] call KBCF_fnc_log;

    true
};

/*
    Activate pending plans. This intentionally falls through
    into the execution block below in the same call rather
    than waiting for a second cycle.
*/
if (_status isEqualTo "PENDING") then
{
    _status = "ACTIVE";

    _plan set ["status", _status];
    _plan set ["activatedAt", serverTime];

    [
        "PLAN",
        format ["Plan activated | Drone:%1", netId _drone]
    ] call KBCF_fnc_log;
};

/*
    Execute active plans.
*/
if (_status isEqualTo "ACTIVE") then
{
    private _actionResult =
    [
        _drone,
        _contact,
        _plan
    ] call KBCF_fnc_executeAction;

    private _validResult = false;

    if (!(isNil "_actionResult")) then
    {
        if (_actionResult isEqualType (createHashMap)) then
        {
            private _resultKeys = keys _actionResult;

            _validResult =
                ("success" in _resultKeys) &&
                {"completed" in _resultKeys} &&
                {"replanRequired" in _resultKeys} &&
                {"reason" in _resultKeys};
        };
    };

    if (!_validResult) then
    {
        _status = "FAILED";

        _plan set ["status", _status];
        _plan set ["failureReason", "INVALID_ACTION_RESULT"];
        _plan set ["replanRequired", true];

        [
            "PLAN",
            format
            [
                "Plan failed | Drone:%1 | Reason:INVALID_ACTION_RESULT",
                netId _drone
            ]
        ] call KBCF_fnc_log;
    }
    else
    {
        private _success = _actionResult get "success";
        private _completed = _actionResult get "completed";
        private _replanRequired = _actionResult get "replanRequired";
        private _reason = _actionResult get "reason";

        _plan set ["lastActionResult", _actionResult];

        if (_completed) then
        {
            _status = "COMPLETE";

            _plan set ["status", _status];
            _plan set ["completedAt", serverTime];
            _plan set ["failureReason", ""];
            _plan set ["replanRequired", false];

            [
                "PLAN",
                format
                [
                    "Plan completed | Drone:%1 | Reason:%2",
                    netId _drone,
                    _reason
                ]
            ] call KBCF_fnc_log;
        }
        else
        {
            if (!_success && {_replanRequired}) then
            {
                _status = "FAILED";

                _plan set ["status", _status];
                _plan set ["failureReason", _reason];
                _plan set ["replanRequired", true];

                [
                    "PLAN",
                    format
                    [
                        "Plan failed | Drone:%1 | Reason:%2",
                        netId _drone,
                        _reason
                    ]
                ] call KBCF_fnc_log;
            }
            else
            {
                /*
                    success = true, completed = false: normal
                    in-progress case, plan stays ACTIVE.

                    success = false, replanRequired = false: a
                    soft, non-fatal condition. Plan also stays
                    ACTIVE so the next cycle can retry rather
                    than being abandoned on an undefined
                    combination.
                */
                [
                    "PLAN",
                    format
                    [
                        "Plan active | Drone:%1 | Reason:%2",
                        netId _drone,
                        _reason
                    ]
                ] call KBCF_fnc_log;
            };
        };
    };
};

_plan set ["status", _status];
_plan set ["lastExecutionTime", serverTime];

_contact set ["attackPlan", _plan];

[
    "PLAN",
    format ["Status:%1 | Drone:%2", _status, netId _drone]
] call KBCF_fnc_log;

true