private _contact = createHashMapFromArray
[
    ["id", netId _target],
    ["object", _target],
    ["classification", "UNKNOWN"],
    ["position", getPosATL _target],
    ["velocity", velocity _target],
    ["confidence", 1],
    ["threat", 0],
    ["firstSeen", serverTime],
    ["lastSeen", serverTime],
    ["source", _source],
    ["reservation", createHashMap]
];