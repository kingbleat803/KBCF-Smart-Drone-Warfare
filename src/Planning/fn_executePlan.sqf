/*
    File: fn_executePlan.sqf

    Description:
    Validates and updates plan status.
*/

params
[
    ["_contact", createHashMap]
];

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

/*
    Activate pending plans
*/
if (_status isEqualTo "PENDING") then
{
    _status = "ACTIVE";

    [
        "PLAN",
        "Plan activated"
    ] call KBCF_fnc_log;
};

/*
    Execute active plans
*/
if (_status isEqualTo "ACTIVE") then
{
    private _actionResult =
    [
        player,
        _contact,
        _plan
    ] call KBCF_fnc_executeAction;

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

    if (_completed) then
    {
        _status = "COMPLETE";

        [
            "PLAN",
            "Plan completed"
        ] call KBCF_fnc_log;
    };

    if (_replanRequired) then
    {
        _status = "FAILED";

        [
            "PLAN",
            "Plan failed and requires replanning"
        ] call KBCF_fnc_log;
    };
};

/*
    Legacy arrival completion check
*/
private _arrival =
    _plan getOrDefault
    [
        "plannedArrival",
        serverTime
    ];

if
(
    (_status isEqualTo "ACTIVE")
    &&
    (serverTime >= _arrival)
)
then
{
    _status = "COMPLETE";

    [
        "PLAN",
        "Planned arrival reached"
    ] call KBCF_fnc_log;
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
        "Status:%1",
        _status
    ]
] call KBCF_fnc_log;

true