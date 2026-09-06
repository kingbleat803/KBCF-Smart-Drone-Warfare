/*
    File: fn_init.sqf

    Description:
    Initializes KBCF-SDW.
*/

if (!isServer) exitWith {};

call compile preprocessFileLineNumbers "src\Config\config.sqf";

["INIT","Starting KBCF Smart Drone Warfare"] call KBCF_fnc_log;

KBCF_Drones = createHashMap;
KBCF_Blackboards = createHashMap;
KBCF_Jammers = createHashMap;

KBCF_AssignmentSequence = 0;

[] call KBCF_fnc_createBlackboard;

[] spawn KBCF_fnc_scheduler;

["INIT","Framework Initialized"] call KBCF_fnc_log;