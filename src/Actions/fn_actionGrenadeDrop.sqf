// ============================================================================
// KBCF PATCH: REUSABLE VELOCITY-INHERITING PAYLOAD RELEASE
// Replace ONLY the legacy payload creation block ("Bo_GB6") with this section.
// ============================================================================

private _releasePosition = getPosASL _drone;
private _droneVel = velocity _drone;

// Lower Z coordinate slightly to prevent any potential clipping with drone geometry on spawn
_releasePosition set [2, (_releasePosition select 2) - 1.5];

// Deploy candidate payload
private _munition = "HandGrenade" createVehicle _releasePosition;

// Runtime evaluation constraint: Verify entity creation success and log failures
if (isNull _munition) exitWith 
{
    [
        "ATTACK",
        format [
            "Payload creation failed | Drone:%1 | Payload:%2",
            netId _drone,
            "HandGrenade"
        ]
    ] call KBCF_fnc_log;

    _result set ["success", false];
    _result set ["completed", false];
    _result set ["replanRequired", true];
    _result set ["reason", "PAYLOAD_CREATE_FAILED"];
    
    _result
};

// Anchor position safely in ASL space
_munition setPosASL _releasePosition;

// Inherit aircraft velocity vectors + apply deliberate downward push
_munition setVelocity 
[
    (_droneVel select 0),
    (_droneVel select 1),
    (_droneVel select 2) - 8
];

// Local sound effect generation from the release hook mechanism
playSound3D ["A3\Sounds_F\weapons\Closure\gr_launcher.wss", _drone];

// ============================================================================
// END KBCF PATCH BLOCK
// ============================================================================
