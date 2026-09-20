/*
    File: fn_isPositionHidden.sqf

    Description:
    Checks whether a position is hidden from every listed threat by
    terrain or by objects (buildings, walls, trees).

    For each threat, a line is traced from its eye position to the
    candidate position:
    - terrainIntersectASL catches ridges, reverse slopes and gullies
    - lineIntersectsSurfaces (VIEW/FIRE geometry) catches buildings
      and other objects

    Params:
    0: ARRAY  - candidate position (ASL)
    1: ARRAY  - threats (objects)
    2: OBJECT - object to ignore in the trace (normally the drone)

    Returns:
    BOOL - true if no threat has line of sight to the position
*/

params
[
    ["_positionASL", [0,0,0]],
    ["_threats", []],
    ["_ignore", objNull]
];

private _visibleIndex =
    _threats findIf
    {
        private _eye = [];

        if (_x isKindOf "CAManBase") then
        {
            _eye = eyePos _x;
        }
        else
        {
            _eye = AGLToASL (_x modelToWorld [0, 0, 2]);
        };

        (!(terrainIntersectASL [_eye, _positionASL]))
        && {
            (
                lineIntersectsSurfaces
                [
                    _eye,
                    _positionASL,
                    _x,
                    _ignore,
                    true,
                    1,
                    "VIEW",
                    "FIRE"
                ]
            ) isEqualTo []
        }
    };

_visibleIndex isEqualTo -1
