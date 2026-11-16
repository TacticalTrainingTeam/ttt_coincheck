#include "script_component.hpp"

if (isServer) then {
    [QGVAR(activate), {_this call FUNC(serverActivate)}] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};

[QGVAR(notify), {
    params ["_key", ["_args", []]];

    // The server can't see the per-client GVAR(enabled), so opted-out players filter here.
    if (!GVAR(enabled)) exitWith {};

    [format ([localize _key] + _args), true] call ace_common_fnc_displayText;
}] call CBA_fnc_addEventHandler;
[QGVAR(toss), {_this call FUNC(respond)}] call CBA_fnc_addEventHandler;
[QGVAR(punish), {call FUNC(playPunishment)}] call CBA_fnc_addEventHandler;

// Settings forced by the server/mission may only arrive after postInit - wait for them so
// GVAR(distributionEnabled) isn't read while it still holds its default.
["CBA_settingsInitialized", {
    [
        {!isNull ACE_player},
        {
            [{[] call FUNC(distributeCoin)}, 5] call CBA_fnc_waitAndExecute;
        }
    ] call CBA_fnc_waitUntilAndExecute;
}] call CBA_fnc_addEventHandler;
