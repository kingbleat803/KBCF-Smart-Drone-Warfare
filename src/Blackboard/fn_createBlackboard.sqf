/*
    File: fn_createBlackboard.sqf

    Description:
    Creates side blackboards.
*/

KBCF_Blackboards = createHashMapFromArray
[
    [west, createHashMap],
    [east, createHashMap],
    [independent, createHashMap]
];

[
    "BLACKBOARD",
    "Created WEST EAST IND boards"
] call KBCF_fnc_log;