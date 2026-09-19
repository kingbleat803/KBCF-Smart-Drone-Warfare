/*
    File: fn_evaluateObservationCondition.sqf

    Description:
    Classifies the current SCOUT observation condition using
    contact-intelligence fields that already exist in KBCF.

    This function is evaluation-only. It does not move the
    drone, change the active action, complete the plan, or
    alter framework/orchestration ownership.

    Inputs read from the contact:
    - alive
    - confidence
    - trackQuality
    - trackAge
    - lastSeen

    Optional thresholds read from the active plan:
    - scoutCurrentTrackQualityThreshold   (default 75)
    - scoutCurrentConfidenceThreshold     (default 75)
    - scoutLostTrackQualityThreshold      (default 50)
    - scoutLostConfidenceThreshold        (default 50)
    - scoutLostTrackAgeThreshold          (default 60)

    Returns:
    HashMap with:
    - condition: CURRENT | DEGRADED | LOST
    - reason
    - confidence
    - trackQuality
    - trackAge
    - contactAge
*/

params
[
    ["_contact", createHashMap],
    ["_plan", createHashMap]
];

private _result =
createHashMapFromArray
[
    ["condition", "LOST"],
    ["reason", "INVALID_CONTACT"],
    ["confidence", 0],
    ["trackQuality", 0],
    ["trackAge", 0],
    ["contactAge", 0]
];

if ((count _contact) isEqualTo 0) exitWith
{
    _result
};

private _alive =
    _contact getOrDefault
    [
        "alive",
        true
    ];

private _confidence =
    _contact getOrDefault
    [
        "confidence",
        0
    ];

private _trackQuality =
    _contact getOrDefault
    [
        "trackQuality",
        0
    ];

private _lastSeen =
    _contact getOrDefault
    [
        "lastSeen",
        0
    ];

private _contactAge =
    serverTime - _lastSeen;

if (_contactAge < 0) then
{
    _contactAge = 0;
};

private _trackAge =
    _contact getOrDefault
    [
        "trackAge",
        _contactAge
    ];

private _currentTrackThreshold =
    _plan getOrDefault
    [
        "scoutCurrentTrackQualityThreshold",
        75
    ];

private _currentConfidenceThreshold =
    _plan getOrDefault
    [
        "scoutCurrentConfidenceThreshold",
        75
    ];

private _lostTrackThreshold =
    _plan getOrDefault
    [
        "scoutLostTrackQualityThreshold",
        50
    ];

private _lostConfidenceThreshold =
    _plan getOrDefault
    [
        "scoutLostConfidenceThreshold",
        50
    ];

private _lostTrackAgeThreshold =
    _plan getOrDefault
    [
        "scoutLostTrackAgeThreshold",
        60
    ];

private _condition = "DEGRADED";
private _reason = "QUALITY_BELOW_CURRENT";

if (!_alive) then
{
    _condition = "LOST";
    _reason = "TARGET_NOT_ALIVE";
}
else
{
    if
    (
        (_confidence < _lostConfidenceThreshold)
        ||
        (_trackQuality < _lostTrackThreshold)
        ||
        (_trackAge > _lostTrackAgeThreshold)
    )
    then
    {
        _condition = "LOST";
        _reason = "CONTACT_TRACK_UNUSABLE";
    }
    else
    {
        if
        (
            (_confidence >= _currentConfidenceThreshold)
            &&
            (_trackQuality >= _currentTrackThreshold)
        )
        then
        {
            _condition = "CURRENT";
            _reason = "CONTACT_TRACK_CURRENT";
        };
    };
};

_result set ["condition", _condition];
_result set ["reason", _reason];
_result set ["confidence", _confidence];
_result set ["trackQuality", _trackQuality];
_result set ["trackAge", _trackAge];
_result set ["contactAge", _contactAge];

_result
