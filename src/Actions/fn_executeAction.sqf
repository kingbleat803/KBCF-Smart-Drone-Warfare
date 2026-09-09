/*
    File: fn_executeAction.sqf

    Description:
    Dispatches actions to the appropriate
    action handler.

    Returns:
    Action Result HashMap.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap],
    ["_plan", createHashMap]
];

private _failure =
createHashMapFromArray
[
    ["success", false],
    ["completed", false],
    ["replanRequired", true],
    ["reason", "UNKNOWN"]
];

if (isNull _drone) exitWith
{
    _failure set
    [
        "reason",
        "INVALID_DRONE"
    ];

    _failure
};

if ((count _plan) isEqualTo 0) exitWith
{
    _failure set
    [
        "reason",
        "INVALID_PLAN"
    ];

    _failure
};

private _actionType =
    _plan getOrDefault
    [
        "actionType",
        ""
    ];

if (_actionType isEqualTo "") exitWith
{
    _failure set
    [
        "reason",
        "NO_ACTION_TYPE"
    ];

    _failure
};

[
    "ACTION",
    format
    [
        "Executing Action:%1",
        _actionType
    ]
] call KBCF_fnc_log;

private _result = createHashMap;

/*
    Dispatch action.
*/

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

    case "OBSERVE":
    {
        _result =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionObserve;
    };

    case "TRACK":
    {
        _result =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionTrack;
    };

    case "SHADOW":
    {
        _result =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionShadow;
    };

    case "REPOSITION":
    {
        _result =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionReposition;
    };

    case "ABORT":
    {
        _result =
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionAbort;
    };

    default
    {
        _result =
        createHashMapFromArray
        [
            ["success", false],
            ["completed", false],
            ["replanRequired", true],
            ["reason", "UNKNOWN_ACTION"]
        ];
    };
};

_result