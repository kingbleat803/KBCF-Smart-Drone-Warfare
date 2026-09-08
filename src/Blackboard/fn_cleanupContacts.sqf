/*
    File: fn_cleanupContacts.sqf

    Description:
    Updates contact confidence and removes stale contacts.
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

    private _contact = _board get _contactId;

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