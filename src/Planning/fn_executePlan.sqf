/*
    Inside src/Planning/fn_executePlan.sqf
    Validated persistence blocks matching existing framework data contracts.
*/
private _plan = _contact getOrDefault ["attackPlan", createHashMap];
if (count _plan isEqualTo 0) exitWith { false };

private _target = _plan getOrDefault ["targetObject", objNull];

// 1. TARGET_MISSING VALIDATION BLOCK
// legitimate failure state - target dropped from tracking matrices or database desync
if (isNull _target) exitWith
{
    _plan set ["status", "FAILED"];
    _plan set ["failureReason", "TARGET_MISSING"];
    _plan set ["replanRequired", true];
    _plan set ["lastExecutionTime", serverTime];
    
    // Explicit commitment to the parent Blackboard structure
    _contact set ["attackPlan", _plan];
    
    [
        "PLAN", 
        format ["Plan failed: Target missing tracking. Re-plan requested for contact %1", _plan getOrDefault ["contactId", "UNKNOWN"]]
    ] call KBCF_fnc_log;
    
    false
};

// 2. TARGET_DESTROYED VALIDATION BLOCK
// Mission objective achieved via cross-unit coordination or simultaneous weapon impacts
if (!alive _target) exitWith
{
    _plan set ["status", "COMPLETE"];
    _plan set ["failureReason", ""];
    _plan set ["replanRequired", false];
    _plan set ["completedAt", serverTime];
    _plan set ["lastExecutionTime", serverTime];
    
    // Explicit commitment to the parent Blackboard structure
    _contact set ["attackPlan", _plan];
    
    [
        "PLAN", 
        format ["Plan completed: Target already destroyed | Contact:%1", _plan getOrDefault ["contactId", "UNKNOWN"]]
    ] call KBCF_fnc_log;
    
    false
};

// ... [Remainder of existing state machine branches: MOVE_TO_INTERCEPT, Terminal Actions] ...
