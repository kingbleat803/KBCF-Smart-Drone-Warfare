/*
    File: fn_actionShadow.sqf
	Author: KingBleat
    Description:
    Maintains an active observation position near a moving
    Arma game object.

    The scheduler may call this handler repeatedly while the
    plan remains ACTIVE. Each execution refreshes the object's
    live position, recalculates the desired shadow position,
    and updates the UAV movement request when necessary.

    Params:
    0: OBJECT  - Arma drone object
    1: HASHMAP - KBCF contact
    2: HASHMAP - active KBCF plan

    Returns:
    Action Result HashMap:
    success
    completed
    replanRequired
    reason
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

/*
    Validate the Arma drone.
*/
if (isNull _drone) exitWith
{
    _result set ["reason", "INVALID_DRONE"];
    _result set ["replanRequired", true];
    _result
};

if (!alive _drone) exitWith
{
    _result set ["reason", "DRONE_DESTROYED"];
    _result set ["replanRequired", true];
    _result
};

/*
    Prefer the live Arma object stored on the contact.
    A direct Debug Console preview may instead provide
    only a position.
*/
private _target =
    _contact getOrDefault
    [
        "object",
        objNull
    ];

private _targetPosition = [];

if (!isNull _target && {alive _target}) then
{
    _targetPosition = getPosATL _target;

    /*
        Refresh the contact with the latest game state.
    */
    _contact set ["position", _targetPosition];
    _contact set ["velocity", velocity _target];
    _contact set ["lastSeen", serverTime];
    _contact set ["alive", true];
}
else
{
    _targetPosition =
        _contact getOrDefault
        [
            "position",
            []
        ];
};

if ((count _targetPosition) < 2) exitWith
{
    _result set ["reason", "NO_TARGET_POSITION"];
    _result set ["replanRequired", true];
    _result
};

/*
    Validate the vanilla Arma UAV driver and group.
*/
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

/*
    Movement commands must run where the UAV driver is local.
*/
if (!local _driver) exitWith
{
    _result set ["reason", "DRONE_DRIVER_NOT_LOCAL"];
    _result set ["replanRequired", false];
    _result
};

/*
    Prepare the Arma UAV for movement.
*/
if (!isEngineOn _drone) then
{
    _drone engineOn true;
};

/*
    Survivability: if the drone is being shot at, an evasion maneuver
    owns movement this cycle. Scanning below still runs so the SCOUT
    keeps updating contacts; only flight-height and movement orders
    are suspended.
*/
[_drone] call KBCF_fnc_installFireReaction;

private _evading =
[
    _drone,
    _contact,
    _plan
] call KBCF_fnc_evadeFire;

private _flightHeight =
    _plan getOrDefault
    [
        "shadowFlightHeight",
        60
    ];

if (!_evading && {_drone isKindOf "Air"}) then
{
    _drone flyInHeight
    [
        _flightHeight,
        true
    ];
};

/*
    Configurable shadow spacing.
*/
private _shadowDistance =
    _plan getOrDefault
    [
        "shadowDistance",
        175
    ];

/*
    Determine the direction from the object toward the drone.

    This keeps the destination on the drone's current side
    instead of always subtracting from the world's X axis.
*/
private _targetX = _targetPosition # 0;
private _targetY = _targetPosition # 1;

private _dronePosition = getPosATL _drone;

private _offsetX =
    (_dronePosition # 0) - _targetX;

private _offsetY =
    (_dronePosition # 1) - _targetY;

private _offsetLength =
    sqrt
    (
        (_offsetX * _offsetX)
        +
        (_offsetY * _offsetY)
    );

/*
    If the drone is directly above the object, use a
    predictable fallback direction.
*/
if (_offsetLength < 1) then
{
    _offsetX = -1;
    _offsetY = 0;
    _offsetLength = 1;
};

private _directionX =
    _offsetX / _offsetLength;

private _directionY =
    _offsetY / _offsetLength;

private _shadowPosition =
[
    _targetX + (_directionX * _shadowDistance),
    _targetY + (_directionY * _shadowDistance),
    _flightHeight
];

/*
    Avoid replacing the movement order every scheduler cycle
    when the calculated destination has barely changed.
*/
private _previousShadowPosition =
    _plan getOrDefault
    [
        "shadowPosition",
        []
    ];

private _destinationChanged = true;

if ((count _previousShadowPosition) >= 2) then
{
    _destinationChanged =
        (
            _previousShadowPosition
            distance2D
            _shadowPosition
        ) > 20;
};

private _distanceFromShadowPosition =
    _drone distance2D _shadowPosition;

/*
    Refresh movement when:
    - the desired destination changed significantly, or
    - the drone remains too far from that destination.
*/
if
(
    (
        _destinationChanged
        ||
        {_distanceFromShadowPosition > 35}
    )
    &&
    {!_evading}
)
then
{
    _droneGroup move _shadowPosition;

    _plan set
    [
        "shadowPosition",
        _shadowPosition
    ];

    _plan set
    [
        "lastShadowMoveAt",
        serverTime
    ];
};

/*
    Run the existing recon scan periodically so the SCOUT
    continues updating contacts while shadowing.
*/
private _scanInterval =
    _plan getOrDefault
    [
        "shadowScanInterval",
        5
    ];

private _lastShadowScanAt =
    _plan getOrDefault
    [
        "lastShadowScanAt",
        -1000
    ];

if
(
    (serverTime - _lastShadowScanAt)
    >=
    _scanInterval
)
then
{
    [
        _drone,
        1000
    ] call KBCF_fnc_reconScan;

    _plan set
    [
        "lastShadowScanAt",
        serverTime
    ];
};

/*
    SHADOW remains active.

    completed stays false so executePlan leaves the plan
    ACTIVE and the scheduler may invoke this handler again.
*/
_result set ["success", true];
_result set ["completed", false];
_result set ["replanRequired", false];
_result set ["reason", if (_evading) then {"EVADING_FIRE"} else {"SHADOWING_TARGET"}];

[
    "ACTION",
    format
    [
        "Shadow active | Drone:%1 | Target:%2 | DesiredPosition:%3 | Distance:%4 | DestinationChanged:%5",
        netId _drone,
        if (isNull _target) then
        {
            "POSITION_ONLY"
        }
        else
        {
            netId _target
        },
        _shadowPosition,
        round _distanceFromShadowPosition,
        _destinationChanged
    ]
] call KBCF_fnc_log;

_result