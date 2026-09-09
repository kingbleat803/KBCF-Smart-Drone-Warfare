/*
    File: fn_scheduler.sqf

    Description:
    Main KBCF scheduler.

    Responsibilities:
    - Advances every contact's existing plan each tick by
      calling KBCF_fnc_executePlan.
    - Once a plan resolves to COMPLETE, FAILED, or EXPIRED,
      performs terminal cleanup: releases the contact's
      reservation, clears the assigned drone's assignment,
      and clears the plan from the contact.

    Explicitly not this file's responsibility:
    - Target selection (fn_selectTarget)
    - Engagement authorization (fn_authorizeEngagement)
    - Plan creation (fn_planAttack)
    These remain solely inside fn_updateBattlefield /
    fn_planAttack. This file never calls them.

    Execution:
    Server only. Spawned once from fn_init.sqf.
*/

if (!isServer) exitWith {};

[
    "SCHEDULER",
    "Scheduler Started"
] call KBCF_fnc_log;

private _terminalStates =
[
    "COMPLETE",
    "FAILED",
    "EXPIRED"
];

while {true} do
{
    {
        private _side = _x;

        private _contacts =
        [
            _side
        ] call KBCF_fnc_queryContacts;

        {
            private _contact = _x;

            private _plan =
                _contact getOrDefault
                [
                    "attackPlan",
                    createHashMap
                ];

            if ((count _plan) > 0) then
            {
                [
                    _contact
                ] call KBCF_fnc_executePlan;

                _plan =
                    _contact getOrDefault
                    [
                        "attackPlan",
                        createHashMap
                    ];

                private _status =
                    _plan getOrDefault
                    [
                        "status",
                        ""
                    ];

                if (_status in _terminalStates) then
                {
                    private _contactId =
                        _contact getOrDefault
                        [
                            "id",
                            ""
                        ];

                    private _drone =
                        _plan getOrDefault
                        [
                            "assignedDrone",
                            objNull
                        ];

                    if (_contactId isNotEqualTo "") then
                    {
                        [
                            _side,
                            _contactId
                        ] call KBCF_fnc_releaseTarget;
                    };

                    if (!isNull _drone) then
                    {
                        _drone setVariable
                        [
                            "KBCF_AssignedTarget",
                            createHashMap
                        ];
                    };

                    _contact set
                    [
                        "attackPlan",
                        createHashMap
                    ];

                    [
                        "SCHEDULER",
                        format
                        [
                            "Terminal cleanup | Contact:%1 | Drone:%2 | FinalStatus:%3",
                            _contactId,
                            netId _drone,
                            _status
                        ]
                    ] call KBCF_fnc_log;
                };
            };
        } forEach _contacts;

    } forEach (keys KBCF_Blackboards);

    sleep KBCF_SCHEDULER_INTERVAL;
};