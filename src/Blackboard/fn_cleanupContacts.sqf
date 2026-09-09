/*
    File: fn_cleanupContacts.sqf

    Description:
    Updates contact confidence, cleans invalid reservations,
    and removes stale contacts.
*/

params
[
    ["_side", sideUnknown]
];

private _board = KBCF_Blackboards get _side;

if (isNil "_board") exitWith {};

private _expiredContacts = [];

{
    private _contactId = _x;

    private _contact =
        _board get _contactId;

    private _lastSeen =
        _contact getOrDefault
        [
            "lastSeen",
            0
        ];

    private _age =
        serverTime - _lastSeen;

    private _confidence =
        100 - floor (_age / 3);

    if (_confidence < 0) then
    {
        _confidence = 0;
    };

    _contact set
    [
        "confidence",
        _confidence
    ];

    private _reservation =
        _contact getOrDefault
        [
            "reservation",
            createHashMap
        ];

    private _owner =
        _reservation getOrDefault
        [
            "owner",
            objNull
        ];

    if
    (
        !isNull _owner
        &&
        {!alive _owner}
    ) then
    {
        _contact set
        [
            "reservation",
            createHashMap
        ];

        [
            "RESERVATION",
            format
            [
                "Released Invalid Reservation %1",
                _contactId
            ]
        ] call KBCF_fnc_log;
    };

    if (_confidence <= 0) then
    {
        _expiredContacts pushBack _contactId;
    };

} forEach (keys _board);

{
    _board deleteAt _x;

    [
        "BLACKBOARD",
        format
        [
            "Removed stale contact %1",
            _x
        ]
    ] call KBCF_fnc_log;

} forEach _expiredContacts;
