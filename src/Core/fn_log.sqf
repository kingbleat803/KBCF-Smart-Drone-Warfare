/*
    File: fn_log.sqf

    Description:
    Centralized KBCF logger.
*/

params
[
    ["_category","GENERAL"],
    ["_message",""]
];

diag_log format
[
    "[KBCF-SDW][%1] %2",
    _category,
    _message
];