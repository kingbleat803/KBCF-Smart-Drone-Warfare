/*
    File: fn_selectTarget.sqf

    Description:
    Returns the highest-priority contact.
*/

params
[
    ["_contacts", []],
    ["_origin", objNull]
];

private _bestContact = createHashMap;
private _bestScore = -1;

{
    private _threat =
        _x getOrDefault
        [
            "threat",
            0
        ];

    private _confidence =
        _x getOrDefault
        [
            "confidence",
            0
        ];

    private _position =
        _x getOrDefault
        [
            "position",
            [0,0,0]
        ];

    private _lastSeen =
        _x getOrDefault
        [
            "lastSeen",
            serverTime
        ];

    private _trackQuality =
        _x getOrDefault
        [
            "trackQuality",
            100
        ];

    private _interceptQuality =
        _x getOrDefault
        [
            "interceptQuality",
            100
        ];

    private _distance = 0;

    if (!isNull _origin) then
    {
        _distance =
            _origin distance2D _position;
    };

    private _age =
        serverTime - _lastSeen;

    private _freshness =
        1 - ((_age min 60) / 60);

    if (_freshness < 0) then
    {
        _freshness = 0;
    };

    private _trackFactor =
        _trackQuality / 100;

    private _interceptFactor =
        _interceptQuality / 100;

    private _score =
    (
        _threat
        *
        _confidence
        *
        _freshness
        *
        _trackFactor
        *
        _interceptFactor
    )
    /
    (
        1 + (_distance / 1000)
    );

    private _classification =
        _x getOrDefault
        [
            "classification",
            "UNKNOWN"
        ];

    [
        "TARGETING",
        format
        [
            "%1 | Threat:%2 | Confidence:%3 | Age:%4 | Track:%5 | Intercept:%6 | Distance:%7 | Score:%8",
            _classification,
            _threat,
            _confidence,
            round _age,
            round _trackQuality,
            round _interceptQuality,
            round _distance,
            round _score
        ]
    ] call KBCF_fnc_log;

    if (_score > _bestScore) then
    {
        _bestScore = _score;
        _bestContact = _x;
    };

} forEach _contacts;

_bestContact