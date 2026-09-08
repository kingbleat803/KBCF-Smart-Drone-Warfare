/*
    File: fn_scheduler.sqf

    Description:
    Main KBCF scheduler.
*/

[
    "SCHEDULER",
    "Scheduler Started"
] call KBCF_fnc_log;

while {true} do
{
    [
        "SCHEDULER",
        "Heartbeat"
    ] call KBCF_fnc_log;

    sleep 5;
};