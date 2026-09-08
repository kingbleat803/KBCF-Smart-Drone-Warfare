/*
    File: fn_selectTarget.sqf

    Description:
    Returns the highest-value contact.
*/

params
[
    ["_contacts", []]
];

private _bestContact = createHashMap;
private _bestScore = -1;

{
    private _classification =
        _x getOrDefault
        [
            "classification",
            "UNKNOWN"
        ];

    private _score =
    [
        _classification
    ] call KBCF_fnc_scoreTarget;

    if (_score > _bestScore) then
    {
        _bestScore = _score;
        _bestContact = _x;
    };

} forEach _contacts;

_bestContact