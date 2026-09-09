/*
    File: fn_authorizeEngagement.sqf

    Description:
    Determines whether a contact should be
    authorized for engagement and calculates
    an engagement score.

    Returns:
    HashMap
*/

params
[
    ["_contact", createHashMap]
];

private _result =
createHashMapFromArray
[
    ["authorized", false],
    ["engagementScore", 0],
    ["reason", "UNKNOWN"]
];

if ((count _contact) isEqualTo 0) exitWith
{
    _result set
    [
        "reason",
        "INVALID_CONTACT"
    ];

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

private _interceptQuality =
    _contact getOrDefault
    [
        "interceptQuality",
        0
    ];

private _threat =
    _contact getOrDefault
    [
        "threat",
        0
    ];

private _trackAge =
    _contact getOrDefault
    [
        "trackAge",
        0
    ];

private _distance =
    _contact getOrDefault
    [
        "distance",
        0
    ];

/*
    Hard rejection checks
*/

if (!_alive) exitWith
{
    _result set
    [
        "reason",
        "TARGET_DEAD"
    ];

    _result
};

if (_confidence < 50) exitWith
{
    _result set
    [
        "reason",
        "LOW_CONFIDENCE"
    ];

    _result
};

if (_trackQuality < 50) exitWith
{
    _result set
    [
        "reason",
        "LOW_TRACK_QUALITY"
    ];

    _result
};

if (_interceptQuality < 25) exitWith
{
    _result set
    [
        "reason",
        "LOW_INTERCEPT_QUALITY"
    ];

    _result
};

if (_threat < 25) exitWith
{
    _result set
    [
        "reason",
        "LOW_THREAT"
    ];

    _result
};

if (_trackAge > 120) exitWith
{
    _result set
    [
        "reason",
        "STALE_CONTACT"
    ];

    _result
};

if (_distance > 5000) exitWith
{
    _result set
    [
        "reason",
        "OUT_OF_RANGE"
    ];

    _result
};

/*
    Engagement scoring
*/

private _engagementScore = 0;

/*
    Threat contribution
    0-40 points
*/
_engagementScore =
    _engagementScore
    +
    ((_threat min 100) * 0.40);

/*
    Confidence contribution
    0-25 points
*/
_engagementScore =
    _engagementScore
    +
    ((_confidence min 100) * 0.25);

/*
    Track quality contribution
    0-15 points
*/
_engagementScore =
    _engagementScore
    +
    ((_trackQuality min 100) * 0.15);

/*
    Intercept quality contribution
    0-10 points
*/
_engagementScore =
    _engagementScore
    +
    ((_interceptQuality min 100) * 0.10);

/*
    Freshness contribution
    0-10 points
*/

private _freshnessScore =
    100 - (_trackAge min 100);

_engagementScore =
    _engagementScore
    +
    (_freshnessScore * 0.10);

_engagementScore =
    round _engagementScore;

/*
    Approved
*/

_result set
[
    "authorized",
    true
];

_result set
[
    "engagementScore",
    _engagementScore
];

_result set
[
    "reason",
    "APPROVED"
];

_result