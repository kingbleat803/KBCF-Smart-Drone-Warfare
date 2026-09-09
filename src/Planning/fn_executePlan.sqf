/*
    File: fn_executePlan.sqf

    Description:
    Validates, activates, executes, and updates
    the lifecycle of an existing plan.

    Execution:
    Server only.

    Returns:
    Boolean indicating whether the plan was processed.
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

/*
    Fail if assigned drone is missing.
*/
if (isNull _drone) exitWith
{
    _plan set
    [
        "status",
        "FAILED"
    ];

    _plan set
    [
        "failureReason",
        "ASSIGNED_DRONE_MISSING"
    ];

    _plan set
    [
        "replanRequired",
        true
    ];

    _plan set
    [
        "lastExecutionTime",
        serverTime
    ];

    _contact set
    [
        "attackPlan",
        _plan
    ];

    [
        "PLAN",
        "Plan failed | Assigned drone missing"
    ] call KBCF_fnc_log;

    false
};

/*
    Fail if assigned drone is destroyed.
*/
if (!alive _drone) exitWith
{
    _plan set
    [
        "status",
        "FAILED"
    ];

    _plan set
    [
        "failureReason",
        "ASSIGNED_DRONE_DESTROYED"
    ];

    _plan set
    [
        "replanRequired",
        true
    ];

    _plan set
    [
        "lastExecutionTime",
        serverTime
    ];

    _contact set
    [
        "attackPlan",
        _plan
    ];

    [
        "PLAN",
        format
        [
            "Plan failed | Drone destroyed:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    false
};

/*
    Activate pending plans.
*/
if (_status isEqualTo "PENDING") then
{
    _status = "ACTIVE";

    _plan set
    [
        "status",
        _status
    ];

    _plan set
    [
        "activatedAt",
        serverTime
    ];

    [
        "PLAN",
        format
        [
            "Plan activated | Drone:%1",
            netId _drone
        ]
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

    private _success =
        _actionResult getOrDefault
        [
            "success",
            false
        ];

    private _completed =
        _actionResult getOrDefault
        [
            "completed",
            false
        ];

    private _replanRequired =
        _actionResult getOrDefault
        [
            "replanRequired",
            false
        ];

    private _reason =
        _actionResult getOrDefault
        [
            "reason",
            "UNKNOWN"
        ];

    _plan set
    [
        "lastActionResult",
        _actionResult
    ];

    if (_completed) then
    {
        _status = "COMPLETE";

        _plan set
        [
            "status",
            _status
        ];

        _plan set
        [
            "completedAt",
            serverTime
        ];

        _plan set
        [
            "failureReason",
            ""
        ];

        _plan set
        [
            "replanRequired",
            false
        ];

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
        if ((!_success) && {_replanRequired}) then
        {
            _status = "FAILED";

            _plan set
            [
                "status",
                _status
            ];

            _plan set
            [
                "failureReason",
                _reason
            ];

            _plan set
            [
                "replanRequired",
                true
            ];

            [
                "PLAN",
                format
                [
                    "Plan failed | Drone:%1 | Reason:%2",
                    netId _drone,
                    _reason
                ]
            ] call KBCF_fnc_log;
        };
    };
};

_plan set
[
    "status",
    _status
];

_plan set
[
    "lastExecutionTime",
    serverTime
];

_contact set
[
    "attackPlan",
    _plan
];

[
    "PLAN",
    format
    [
        "Status:%1 | Drone:%2",
        _status,
        netId _drone
    ]
] call KBCF_fnc_log;

true