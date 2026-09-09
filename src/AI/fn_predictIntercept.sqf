/*
    File: fn_predictIntercept.sqf

    Description:
    Predicts the true intercept point for a drone
    against a moving target using a quadratic solution.
*/

params
[
    ["_drone", objNull],
    ["_contact", createHashMap]
];

if (isNull _drone) exitWith
{
    [0,0,0]
};

if ((count _contact) isEqualTo 0) exitWith
{
    [0,0,0]
};

private _targetPosition =
[
    _contact
] call KBCF_fnc_predictPosition;

private _dronePosition = getPosASL _drone;

private _velocity =
    _contact getOrDefault
    [
        "velocity",
        [0,0,0]
    ];

private _droneSpeed = 50;

/*
    Relative position
*/
private _rx = (_targetPosition # 0) - (_dronePosition # 0);
private _ry = (_targetPosition # 1) - (_dronePosition # 1);
private _rz = (_targetPosition # 2) - (_dronePosition # 2);

/*
    Target velocity
*/
private _vx = _velocity # 0;
private _vy = _velocity # 1;
private _vz = _velocity # 2;

/*
    Quadratic:
    (v·v - s²)t² + 2(r·v)t + r·r = 0
*/
private _a =
    (_vx * _vx) +
    (_vy * _vy) +
    (_vz * _vz) -
    (_droneSpeed * _droneSpeed);

private _b =
    2 *
    (
        (_rx * _vx) +
        (_ry * _vy) +
        (_rz * _vz)
    );

private _c =
    (_rx * _rx) +
    (_ry * _ry) +
    (_rz * _rz);

private _interceptTime = -1;

/*
    Handle near-linear cases
*/
if (abs _a < 0.0001) then
{
    if (abs _b > 0.0001) then
    {
        _interceptTime = -_c / _b;
    };
}
else
{
    private _discriminant =
        (_b * _b) -
        (4 * _a * _c);

    if (_discriminant >= 0) then
    {
        private _root =
            sqrt _discriminant;

        private _t1 =
            (-_b + _root) / (2 * _a);

        private _t2 =
            (-_b - _root) / (2 * _a);

        if (_t1 > 0 && _t2 > 0) then
        {
            _interceptTime = _t1 min _t2;
        }
        else
        {
            if (_t1 > 0) then
            {
                _interceptTime = _t1;
            };

            if (_t2 > 0) then
            {
                if (_interceptTime < 0 || {_t2 < _interceptTime}) then
                {
                    _interceptTime = _t2;
                };
            };
        };
    };
};

/*
    No valid intercept
*/
if (_interceptTime <= 0) then
{
    _contact set ["interceptQuality",0];
    _contact set ["interceptTime",-1];
    _contact set ["interceptPosition",_targetPosition];

    _targetPosition
};

/*
    Calculate intercept point
*/
private _interceptPosition =
[
    (_targetPosition # 0) + (_vx * _interceptTime),
    (_targetPosition # 1) + (_vy * _interceptTime),
    (_targetPosition # 2) + (_vz * _interceptTime)
];

private _interceptQuality =
    (100 - _interceptTime) max 0;

_contact set
[
    "interceptPosition",
    _interceptPosition
];

_contact set
[
    "interceptTime",
    _interceptTime
];

_contact set
[
    "interceptQuality",
    _interceptQuality
];

[
    "INTERCEPT",
    format
    [
        "Time:%1 | Quality:%2 | Position:%3",
        round _interceptTime,
        round _interceptQuality,
        _interceptPosition
    ]
] call KBCF_fnc_log;

_interceptPosition