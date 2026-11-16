#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side: starts a coin check at the initiator's position. Creates the shared ground weapon
 * holder, fixes who is eligible (every living player in range carrying their coin), tosses the
 * initiator's coin, prompts the other eligible players and schedules the evaluation.
 *
 * Arguments:
 * 0: Initiator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit"];

private _pos = getPosATL _unit;

private _holder = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
_holder setPosATL _pos;

private _eligible = allPlayers select {
    alive _x && {_x distance _pos <= RESPONSE_RADIUS} && {(_x call FUNC(hasCoin)) select 0}
};

// [holder, position, eligible units, units that tossed]
GVAR(activeCheck) = [_holder, _pos, _eligible, []];

[_unit] call FUNC(serverToss);

[QGVAR(notify), [LSTRING(started), [RESPONSE_RADIUS, RESPONSE_TIME]], _unit] call CBA_fnc_targetEvent;
[QGVAR(notify), [LSTRING(prompt), [RESPONSE_TIME]], _eligible - [_unit]] call CBA_fnc_targetEvent;

[FUNC(evaluateCheck), [], RESPONSE_TIME] call CBA_fnc_waitAndExecute;
