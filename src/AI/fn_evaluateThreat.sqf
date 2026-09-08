/*
    File: fn_evaluateThreat.sqf

    Description:
    Returns a threat value based on classification.
*/

params
[
    ["_classification", "UNKNOWN"]
];

switch (_classification) do
{
    case "MAIN_BATTLE_TANK": {100};
    case "AIR_DEFENSE": {95};
    case "ARTILLERY": {90};
    case "APC": {75};
    case "HELICOPTER": {70};
    case "DRONE": {60};
    case "LIGHT_VEHICLE": {40};
    case "INFANTRY": {20};

    default {0};
};