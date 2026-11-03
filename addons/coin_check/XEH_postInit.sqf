#include "script_component.hpp"

if (isServer) then {
    GVAR(holders) = createHashMap;
    [QGVAR(requestStart), {_this call FUNC(serverStart)}] call CBA_fnc_addEventHandler;
    [QGVAR(toss), {_this call FUNC(serverToss)}] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};

[QGVAR(checkStarted), {_this call FUNC(handleCheckStarted)}] call CBA_fnc_addEventHandler;
[QGVAR(punish), {call FUNC(playPunishment)}] call CBA_fnc_addEventHandler;

// Settings forced by the server/mission may only arrive after postInit - wait for them so
// GVAR(distributionEnabled) isn't read while it still holds its default.
["CBA_settingsInitialized", {
    [
        {!isNull ACE_player && {GVAR(enabled)}},
        {
            [{[] call FUNC(distributeCoin)}, 3] call CBA_fnc_waitAndExecute;
        }
    ] call CBA_fnc_waitUntilAndExecute;
}] call CBA_fnc_addEventHandler;
