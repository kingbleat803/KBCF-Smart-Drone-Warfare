/*
    File: fn_rankTargets.sqf

    Description:
    Evaluates and ranks a collection of contacts
    using engagement scoring.

    Returns:
    Array of contacts sorted by descending score.
*/

params
[
    ["_contacts", []]
];

private _rankedTargets = [];

{
    private _contact = _x;

    private _authorization =
    [
        _contact
    ] call KBCF_fnc_authorizeEngagement;

    private _authorized =
        _authorization getOrDefault
        [
            "authorized",
            false
        ];

    if (_authorized) then
    {
        private _score =
            _authorization getOrDefault
            [
                "engagementScore",
                0
            ];

        _rankedTargets pushBack
        [
            _score,
            _contact
        ];
    };

} forEach _contacts;

/*
    Highest score first
*/
_rankedTargets sort false;

private _result = [];

{
    _result pushBack (_x select 1);
}
forEach _rankedTargets;

_result