/*
    File: fn_executeAction.sqf

    Description:
    Executes the action associated with
    an active plan.
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
    ["reason", "NO_ACTION"]
];

if (isNull _drone) exitWith
{
    _result set
    [
        "reason",
        "INVALID_DRONE"
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

    _result
};

private _actionType =
    _plan getOrDefault
    [
        "actionType",
        "MOVE_TO_INTERCEPT"
    ];

switch (_actionType) do
{
    case "MOVE_TO_INTERCEPT":
    {
        _result =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionMoveToIntercept;
    };

    default
    {
        _result set
        [
            "reason",
            format
            [
                "UNKNOWN_ACTION:%1",
                _actionType
            ]
        ];
    };
};

_result