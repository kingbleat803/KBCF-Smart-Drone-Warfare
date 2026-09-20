/*
    File: fn_actionAttack.sqf
	Author:KingBleat
    Description:
    Terminal action for the FPV_STRIKE drone profile.

    The FPV continues a committed terminal run toward the live
    target position. Detonation is caused by physical contact,
    not by reaching a proximity radius around the assigned target.

    On contact with terrain or an object, the configured warhead
    detonates at the drone's actual impact position and the FPV is
    consumed by the strike. No explosive is attached or teleported
    to the assigned target.

    Existing Action Result contract preserved:
    params [_drone, _contact, _plan]
    returns HashMap: success, completed, replanRequired, reason

    Execution:
    Server / drone-local execution through the existing action path.
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
    _result set ["reason", "INVALID_DRONE"];
    _result set ["replanRequired", true];
    _result
};

/*
    The contact handler records a successful FPV strike before
    consuming the drone. If the existing lifecycle evaluates this
    action again while the destroyed vehicle object still exists,
    report successful terminal completion rather than a failure.
*/
if (_drone getVariable ["KBCF_FPVImpactDetonated", false]) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "FPV_IMPACT_DETONATED"];
    _result
};

if (!alive _drone) exitWith
{
    _result set ["reason", "DRONE_DESTROYED"];
    _result set ["replanRequired", true];
    _result
};

if ((count _plan) isEqualTo 0) exitWith
{
    _result set ["reason", "INVALID_PLAN"];
    _result set ["replanRequired", true];
    _result
};

private _target =
    _plan getOrDefault
    [
        "targetObject",
        objNull
    ];

if (isNull _target) exitWith
{
    _result set ["reason", "TARGET_MISSING"];
    _result set ["replanRequired", true];
    _result
};

/*
    A target destroyed before physical impact ends this engagement.
    The FPV does not teleport an explosive onto an already dead target.
*/
if (!alive _target) exitWith
{
    _result set ["success", true];
    _result set ["completed", true];
    _result set ["reason", "TARGET_ALREADY_DOWN"];

    [
        "ATTACK",
        format
        [
            "FPV terminal run ended | Target already down | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

private _driver = driver _drone;
if (isNull _driver) exitWith
{
    _result set ["reason", "DRONE_HAS_NO_DRIVER"];
    _result set ["replanRequired", true];
    _result
};

private _droneGroup = group _driver;
if (isNull _droneGroup) exitWith
{
    _result set ["reason", "DRONE_GROUP_MISSING"];
    _result set ["replanRequired", true];
    _result
};

if (!local _driver) exitWith
{
    _result set ["reason", "DRONE_DRIVER_NOT_LOCAL"];
    _result set ["replanRequired", false];

    [
        "ATTACK",
        format
        [
            "FPV terminal run not issued | Driver not local | Drone:%1",
            netId _drone
        ]
    ] call KBCF_fnc_log;

    _result
};

if (!isEngineOn _drone) then
{
    _drone engineOn true;
};

/*
    Idempotent. Normally already installed during MOVE_TO_INTERCEPT.
*/
[_drone] call KBCF_fnc_installFireReaction;

private _warheadClassname =
    _plan getOrDefault
    [
        "warheadClass",
        "SatchelCharge_Remote_Ammo_Scripted"
    ];

/*
    Install the impact handler once, after the FPV has entered its
    terminal ATTACK action. The handler uses only data stored on the
    drone so it remains independent of a specific vanilla or modded
    FPV classname.
*/
private _impactHandlerId =
    _drone getVariable
    [
        "KBCF_FPVImpactHandlerId",
        -1
    ];

if (_impactHandlerId < 0) then
{
    _drone setVariable
    [
        "KBCF_FPVWarheadClass",
        _warheadClassname
    ];

    _drone setVariable
    [
        "KBCF_FPVImpactDetonated",
        false
    ];

    _impactHandlerId =
        _drone addEventHandler
        [
            "EpeContactStart",
            {
                private _impactDrone = _this select 0;

                if (isNull _impactDrone) exitWith {};
                if (_impactDrone getVariable ["KBCF_FPVImpactDetonated", false]) exitWith {};

                _impactDrone setVariable
                [
                    "KBCF_FPVImpactDetonated",
                    true
                ];

                private _impactPosition = getPosATL _impactDrone;
                private _impactWarheadClass =
                    _impactDrone getVariable
                    [
                        "KBCF_FPVWarheadClass",
                        "SatchelCharge_Remote_Ammo_Scripted"
                    ];

                private _impactWarhead =
                    _impactWarheadClass createVehicle _impactPosition;

                if (!isNull _impactWarhead) then
                {
                    _impactWarhead setDamage 1;
                };

                [
                    "ATTACK",
                    format
                    [
                        "FPV physical impact | Drone:%1 | Position:%2 | WarheadClass:%3 | WarheadCreated:%4",
                        netId _impactDrone,
                        _impactPosition,
                        _impactWarheadClass,
                        !isNull _impactWarhead
                    ]
                ] call KBCF_fnc_log;

                _impactDrone setDamage 1;
            }
        ];

    _drone setVariable
    [
        "KBCF_FPVImpactHandlerId",
        _impactHandlerId
    ];

    [
        "ATTACK",
        format
        [
            "FPV impact fuze armed | Drone:%1 | Handler:%2 | WarheadClass:%3",
            netId _drone,
            _impactHandlerId,
            _warheadClassname
        ]
    ] call KBCF_fnc_log;
};

/*
    Continue the terminal run through the target position. There is
    deliberately no detonation radius and no target attachment.
    Physical contact owns detonation.
*/
private _targetPositionASL = aimPos _target;
private _targetPositionATL = ASLToATL _targetPositionASL;
private _dronePositionASL = getPosASL _drone;
private _toTarget = _targetPositionASL vectorDiff _dronePositionASL;
private _distance = vectorMagnitude _toTarget;

if (_distance <= 0.01) then
{
    _toTarget = vectorDir _drone;
};

private _attackDirection = vectorNormalized _toTarget;

/*
    Survivability: while under fire during the run-in, weave instead of
    flying a perfectly straight line. Within fpvCommitDistance the FPV
    stops weaving and commits, so the physical-contact fuze still
    detonates on the target and not somewhere short of it.

    The weave alternates left/right each cycle by about 14 degrees.
*/
if
(
    (missionNamespace getVariable ["KBCF_SURVIVAL_ENABLED", true])
    && {_distance > (_plan getOrDefault ["fpvCommitDistance", 60])}
    && {[_drone, 3] call KBCF_fnc_isUnderFire}
)
then
{
    private _weaveSign = _plan getOrDefault ["fpvWeaveSign", 1];

    _plan set ["fpvWeaveSign", -_weaveSign];

    private _lateral =
        vectorNormalized
        (
            _attackDirection vectorCrossProduct [0, 0, 1]
        );

    _attackDirection =
        vectorNormalized
        (
            _attackDirection vectorAdd (_lateral vectorMultiply (0.25 * _weaveSign))
        );

    [
        "ATTACK",
        format
        [
            "FPV weaving under fire | Drone:%1 | Distance:%2 | Sign:%3",
            netId _drone,
            round _distance,
            _weaveSign
        ]
    ] call KBCF_fnc_log;
};

private _currentSpeed = vectorMagnitude velocity _drone;
private _terminalSpeed = _plan getOrDefault ["fpvTerminalSpeed", 45];
private _commandedSpeed = _currentSpeed max _terminalSpeed;

_droneGroup move _targetPositionATL;
_drone setVectorDirAndUp
[
    _attackDirection,
    vectorUp _drone
];
_drone setVelocity (_attackDirection vectorMultiply _commandedSpeed);

_result set ["success", true];
_result set ["completed", false];
_result set ["replanRequired", false];
_result set ["reason", "FPV_TERMINAL_RUN"];

[
    "ATTACK",
    format
    [
        "FPV terminal run | Drone:%1 | Distance:%2 | Speed:%3 | TargetPosition:%4",
        netId _drone,
        round _distance,
        round _commandedSpeed,
        _targetPositionATL
    ]
] call KBCF_fnc_log;

_result
