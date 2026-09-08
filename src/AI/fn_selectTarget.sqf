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

    private _distance = 0;

    if (!isNull _origin) then
    {
        _distance =
            _origin distance2D _position;
    };

    private _score =
        (_threat * _confidence)
        /
        (1 + (_distance / 1000));

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
            "%1 | Threat:%2 | Confidence:%3 | Distance:%4 | Score:%5",
            _classification,
            _threat,
            _confidence,
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