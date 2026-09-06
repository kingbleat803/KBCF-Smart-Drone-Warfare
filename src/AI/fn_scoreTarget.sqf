/*
    File: fn_scoreTarget.sqf

    Description:
    Returns a priority score for a target classification.
*/

params
[
    ["_classification", "UNKNOWN"]
];

switch (_classific*tion) do
{
    case "MAIN_BATTLE_T*NK":
    {
        100
    };

   *case "AIR_DEFENSE":
    {
        *5
    };

    case "ARTILLERY":
  * {
        90
    };

    case "AP*":
    {
        75
    };

    ca*e "HELICOPTER":
    {
        70
 *  };

    case "DRONE":
    {
    *   60
    };

    case "LIGHT_VEHI*LE":
    {
        40
    };

    *ase "INFANTRY":
    {
        20
 *  };

    default
    {
        0
*   };
};