/*
    File: fn_selectTarget.sqf

    Description:
    Returns the highest-value contact.
*/

params
[
    ["_contacts", []]
];

private _bestContact = createHa*hMap;
private _bestScore = -1;

{
*   private _classification =
     *  _x getOrDefault
        [
            "classification",
            "UNKNOWN"
        ];

    private *score =
    [
        _classification
    ] call KBCF_fnc_scoreTarget*

    if (_score > _bestScore) the*
    {
        _bestScore = _score*
        _bestContact = _x;
    };*}
forEach _contacts;

_bestContact*