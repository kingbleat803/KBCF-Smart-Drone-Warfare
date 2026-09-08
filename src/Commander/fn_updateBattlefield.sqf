/*
    File: fn_updateBattlefield.sqf

    Description:
    Assigns the best available contacts to available drones.
*/

params
[
    ["_side", sideUnknown],
    ["_drones", []]
];

if (_side isEqualTo sideUnknown) exitWith
{
    0
};

if ((count _drones) isEqualTo 0) exitWith
{
    0
};

private _contacts =
[
    _side
] call KBCF_fnc_queryContacts;

if ((count _contacts) isEqualTo 0) exitWith
{
    0
};

private _assignmentCount = 0;

{
    private _drone = _x;

    if (!isNull _drone && {alive _drone}) then
    {
        private _availableContacts =
            _contacts select
            {
                private _reservation =
                    _x getOrDefault
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

                isNull _owner
            };

        if ((count _availableContacts) > 0) then
        {
            private _selectedContact =
            [
                _availableContacts,
                _drone
            ] call KBCF_fnc_selectTarget;

            if ((count _selectedContact) > 0) then
            {
                private _contactId =
                    _selectedContact getOrDefault
                    [
                        "id",
                        ""
                    ];

                if (_contactId isNotEqualTo "") then
                {
                    private _reserved =
                    [
                        _side,
                        _contactId,
                        _drone
                    ] call KBCF_fnc_reserveTarget;

                    if (_reserved) then
                    {
                        private _assigned =
                        [
                            _drone,
                            _selectedContact
                        ] call KBCF_fnc_assignTarget;

                        if (_assigned) then
                        {
                            _assignmentCount =
                                _assignmentCount + 1;

                            [
                                "COMMANDER",
                                format
                                [
                                    "Assigned contact %1 to drone %2",
                                    _contactId,
                                    netId _drone
                                ]
                            ] call KBCF_fnc_log;
                        }
                        else
                        {
                            [
                                _side,
                                _contactId
                            ] call KBCF_fnc_releaseTarget;
                        };
                    };
                };
            };
        };
    };

} forEach _drones;

_assignmentCount