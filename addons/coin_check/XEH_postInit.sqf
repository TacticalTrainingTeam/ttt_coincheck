#include "script_component.hpp"

if (isServer) then {
    GVAR(holders) = createHashMap;
    [QGVAR(requestStart), {_this call FUNC(serverStart)}] call CBA_fnc_addEventHandler;
    [QGVAR(toss), {_this call FUNC(serverToss)}] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};

[QGVAR(checkStarted), {_this call FUNC(handleCheckStarted)}] call CBA_fnc_addEventHandler;
[QGVAR(punish), {call FUNC(playPunishment)}] call CBA_fnc_addEventHandler;

[
    {!isNull ACE_player && {GVAR(enabled)}},
    {
        [{[] call FUNC(distributeCoin)}, 3] call CBA_fnc_waitAndExecute;
    }
] call CBA_fnc_waitUntilAndExecute;
