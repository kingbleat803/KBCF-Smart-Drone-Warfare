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

private _result = switch (_actionType) do
{
    //
        //Existing Action Set
    //

     ["replanRequired", true],
    ["reason", "UNKNOWN"]
];

if (isNull _drone) exitWith
{   case "MOVE_TO_INTERCEPT":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionMoveToIntercept
    };

    case "OBSERVE":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionObserve
    };

    case "TRACK":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionTrack
    };

    case "SHADOW":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionShadow
    };

    case "REPOSITION":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionReposition
    };

    /*
        Generation 9 Terminal Actions
    */

    case "ATTACK":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionAttack
    };

    case "GRENADE_DROP":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionGrenadeDrop
    };

    case "RECON":
    {
        [
            _drone,
            _contact,
            _plan
        ] call KBCF_fnc_actionRecon
    };

    default
    {
        createHashMapFromArray
        [
            ["success", false],
            ["completed", false],
            ["replanRequired", true],
            ["reason", "UNKNOWN_ACTION"]
        ]
    };
};

_result