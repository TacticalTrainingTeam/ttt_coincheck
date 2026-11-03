#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side handler for a tossed coin: adds it to the check's ground weapon holder. The engine
 * deletes a holder as soon as its last item is taken out, so if someone emptied the pile, a new
 * holder is created at the check's position - a tossed coin always lands somewhere.
 *
 * Arguments:
 * 0: Check ID, the netId of the check's original holder <STRING>
 * 1: Position of the check <POSITION>
 * 2: Coin classname <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_checkId", "_pos", "_class"];

private _holder = GVAR(holders) getOrDefault [_checkId, objNull];

if (isNull _holder) then {
    _holder = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
    _holder setPosATL _pos;
    GVAR(holders) set [_checkId, _holder];
};

_holder addItemCargoGlobal [_class, 1];
