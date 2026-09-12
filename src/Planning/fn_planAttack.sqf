/*
    File: fn_planAttack.sqf

    Description:
    Prepares target intelligence and creates a multi-stage plan.
    Execution:
    Server only.
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

if (isNull _drone || {!alive _drone}) exitWith
{
    createHashMap
};

if ((count _contact) isEqualTo 0) exitWith
{
    createHashMap
};

/*
    Prepare the contact before authorization.
*/
private _tracked =
[
    _contact
] call KBCF_fnc_trackTarget;

if (!_tracked) exitWith
{
    [
        "ATTACK",
        "Plan not created | Contact tracking failed"
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
        "Plan not created | No valid intercept"
    ] call KBCF_fnc_log;

    createHashMap
};

/*
    Store actual drone-to-contact distance for authorization.
*/
private _contactPosition =
    _contact getOrDefault
    [
        "position",
        [0,0,0]
    ];

_contact set
[
    "distance",
    _drone distance2D _contactPosition
];

/*
    Authorization now receives a fully prepared contact.
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

private _droneProfile =
    _drone getVariable
    [
        "KBCF_DroneProfile",
        "UNKNOWN"
    ];

private _terminalActionType = "ATTACK";

switch (_droneProfile) do
{
    case "FPV_STRIKE":
    {
        _terminalActionType = "ATTACK";
    };

    case "BOMBER":
    {
        _terminalActionType = "GRENADE_DROP";
    };

    case "SCOUT":
    {
        _terminalActionType = "RECON";
    };

    default
    {
        _terminalActionType = "ATTACK";
    };
};

private _plannedArrival =
    serverTime + _interceptTime;

private _attackPlan =
createHashMapFromArray
[
    ["planType", "ATTACK"],
    ["actionType", "MOVE_TO_INTERCEPT"],
    ["terminalActionType", _terminalActionType],
    ["droneProfile", _droneProfile],
    [
        "targetClassification",
        _contact getOrDefault
        [
            "classification",
            "UNKNOWN"
        ]
    ],
    [
        "targetObject",
        _contact getOrDefault
        [
            "object",
            objNull
        ]
    ],
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
    ["routeQuality", _interceptQuality]
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
        "Plan created | Drone:%1 | Profile:%2 | Terminal:%3",
        netId _drone,
        _droneProfile,
        _terminalActionType
    ]
] call KBCF_fnc_log;

_attackPlan

