/*
    File: fn_findCoverPosition.sqf

    Description:
    Finds a hover point near _center that is hidden from every listed
    threat. Two kinds of candidate are tested:

    BUILDING  points around the walls of nearby buildings
              (small preference - a wall is dependable cover)
    TERRAIN   rings of points around _center (finds dead ground:
              reverse slopes, folds and gullies)

    Every candidate is validated with KBCF_fnc_isPositionHidden at the
    hover height the drone will actually fly at, so a ridge that hides
    a drone at 8 m does not count for a drone at 40 m.

    Cost is bounded: at most 6 buildings x 6 points plus 3 rings x 12
    points = 72 candidates per call. Callers should throttle calls
    (see KBCF_COVER_SEARCH_INTERVAL).

    Params:
    0: OBJECT - drone
    1: ARRAY  - centre position to search around
    2: ARRAY  - threats (objects) that must not see the position
    3: NUMBER - search radius for buildings (default 150)
    4: NUMBER - preferred distance from centre (default 80)
    5: NUMBER - hover height in metres AGL (default 15)

    Returns:
    HashMap. Empty when no hidden position was found. Otherwise:
    - position: [x, y, z] ATL (z = hover height)
    - kind:     BUILDING | TERRAIN
    - score:    NUMBER
*/

params
[
    ["_drone", objNull],
    ["_center", []],
    ["_threats", []],
    ["_radius", 150],
    ["_ideal", 80],
    ["_hoverHeight", 15]
];

if (isNull _drone) exitWith
{
    createHashMap
};

if ((count _center) < 2) exitWith
{
    createHashMap
};

if ((count _threats) isEqualTo 0) exitWith
{
    createHashMap
};

private _candidates = [];

/*
    Buildings. nearestObjects returns nearest first; keep the closest
    six that are big enough to matter.
*/
private _buildings =
    (nearestObjects [_center, ["House"], _radius]) select
    {
        ((boundingBoxReal _x) select 2) > 3
    };

_buildings = _buildings select [0, 6];

{
    private _building = _x;

    private _wallRadius =
        ((boundingBoxReal _building) select 2) + 4;

    for "_angle" from 0 to 300 step 60 do
    {
        private _point = _building getPos [_wallRadius, _angle];

        _candidates pushBack
        [
            _point select 0,
            _point select 1,
            15,
            "BUILDING"
        ];
    };
} forEach _buildings;

/*
    Terrain rings.
*/
{
    private _ringRadius = _x;

    for "_angle" from 0 to 330 step 30 do
    {
        private _point = _center getPos [_ringRadius, _angle];

        _candidates pushBack
        [
            _point select 0,
            _point select 1,
            0,
            "TERRAIN"
        ];
    };
} forEach [_ideal * 0.6, _ideal, _ideal * 1.5];

/*
    Score hidden candidates. Prefer points near the preferred distance
    from the centre and not far from the drone.
*/
private _dronePosition = getPosATL _drone;
private _bestScore = -1e9;
private _best = createHashMap;

{
    _x params ["_candidateX", "_candidateY", "_bonus", "_kind"];

    private _candidate2D = [_candidateX, _candidateY];

    if (!(surfaceIsWater _candidate2D)) then
    {
        private _candidateASL =
        [
            _candidateX,
            _candidateY,
            (getTerrainHeightASL _candidate2D) + _hoverHeight
        ];

        private _hidden =
        [
            _candidateASL,
            _threats,
            _drone
        ] call KBCF_fnc_isPositionHidden;

        if (_hidden) then
        {
            private _score =
                100
                + _bonus
                - ((abs ((_candidate2D distance2D _center) - _ideal)) * 0.5)
                - ((_candidate2D distance2D _dronePosition) * 0.05);

            if (_score > _bestScore) then
            {
                _bestScore = _score;

                _best =
                createHashMapFromArray
                [
                    ["position", [_candidateX, _candidateY, _hoverHeight]],
                    ["kind", _kind],
                    ["score", _score]
                ];
            };
        };
    };
} forEach _candidates;

_best
