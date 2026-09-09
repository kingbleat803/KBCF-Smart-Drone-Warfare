/*
    File: fn_planAttack.sqf

    Description:
    Generates an attack plan from the
    current target intelligence.

    Execution:
    Intended to run on the server.

    Returns:
    Attack plan HashMap.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap]
];

if (!isServer) exitWith
{
    createHashMap
};

if (isNull _drone) exitWith
{
    createHashMap
};

if (!alive _drone) exitWith
{
    createHashMap
};

if ((count _contact) isEqualTo 0) exitWith
{
    createHashMap
};

/*
    Generation 8C
    Engagement Authorization Gate
*/
private _authorization =
[
    _contact
] call KBCF_fnc_authorizeEngagement;

private _authorized =
    _authorization getOrDefault
    [
        "authorized",
        false
    ];

if (!_authorized) exitWith
{
    [
        "ATTACK",
        format
        [
            "Engagement denied | Reason:%1",
            _authorization getOrDefault
            [
                "reason",
                "UNKNOWN"
            ]
        ]
    ] call KBCF_fnc_log;

    createHashMap
};

private _interceptPosition =
[
    _drone,
    _contact
] call KBCF_fnc_predictIntercept;

private _interceptTime =
    _contact getOrDefault
    [
        "interceptTime",
        -1
    ];

private _interceptQuality =
    _contact getOrDefault
    [
        "interceptQuality",
        0
    ];

if (_interceptTime <= 0) exitWith
{
    [
        "ATTACK",
        "Plan not created because no valid intercept exists"
    ] call KBCF_fnc_log;

    createHashMap
};

private _plannedArrival =
    serverTime + _interceptTime;

private _routeQuality =
    _interceptQuality;

private _attackPlan =
createHashMapFromArray
[
    ["planType", "ATTACK"],

    ["actionType", "MOVE_TO_INTERCEPT"],

    ["assignedDrone", _drone],

    [
        "contactId",
        _contact getOrDefault
        [
            "id",
            ""
        ]
    ],

    ["status", "PENDING"],

    ["createdAt", serverTime],

    ["activatedAt", -1],

    ["completedAt", -1],

    ["lastExecutionTime", -1],

    ["replanRequired", false],

    ["failureReason", ""],

    ["interceptPosition", _interceptPosition],

    ["interceptTime", _interceptTime],

    ["interceptQuality", _interceptQuality],

    ["plannedArrival", _plannedArrival],

    ["routeQuality", _routeQuality]
];

_contact set
[
    "attackPlan",
    _attackPlan
];

[
    "ATTACK",
    format
    [
        "Plan created | Drone:%1 | Arrival:%2 | Quality:%3",
        netId _drone,
        round _plannedArrival,
        round _routeQuality
    ]
] call KBCF_fnc_log;

_attackPlan