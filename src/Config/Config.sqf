/*
    File: Config.sqf
	Author:KingBleat
    Description:
    Global KBCF configuration values.
*/

KBCF_VERSION = "0.1.0";

KBCF_DEBUG = true;

KBCF_MAX_DRONES = 20;

KBCF_CONTACT_LIFETIME = 300;

KBCF_SCHEDULER_INTERVAL = 1;

KBCF_SCAN_INTERVAL = 2;

KBCF_RESERVATION_DURATION = 120;

/*
    Survivability layer (terrain masking, cover, evasion).
    All values are optional; the functions fall back to these same
    defaults if a value is missing.
*/

KBCF_SURVIVAL_ENABLED = true;

// Hostile-detection radius used by cover checks (metres)
KBCF_THREAT_RANGE = 400;

// FPV_STRIKE / BOMBER approach height above ground (metres)
KBCF_STRIKE_APPROACH_HEIGHT = 15;

// Evasion tuning
KBCF_EVADE_WINDOW = 20;            // seconds an engagement counts toward "sustained fire"
KBCF_EVADE_COVER_AFTER = 2;        // engagements in window before breaking for cover
KBCF_EVADE_BUDGET = 45;            // total seconds of evasion per plan before committing
KBCF_EVADE_JINK_MIN = 30;          // jink distance (metres)
KBCF_EVADE_JINK_MAX = 55;
KBCF_EVADE_JINK_HOLD = 2.5;        // seconds a jink holds before normal movement resumes
KBCF_EVADE_KICK_SPEED = 8;         // lateral velocity kick (m/s)
KBCF_EVADE_MIN_HEIGHT = 8;         // altitude band while evading (metres AGL)
KBCF_EVADE_MAX_HEIGHT = 45;

// Minimum seconds between cover searches (each search runs many raycasts)
KBCF_COVER_SEARCH_INTERVAL = 5;
