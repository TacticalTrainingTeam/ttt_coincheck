#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side: puts a unit's coin into the active check's ground weapon holder, records the unit
 * as having tossed and tells its machine to drop the coin from its inventory. The engine deletes
 * a holder as soon as its last item is taken out, so if someone emptied the pile, a new holder is
 * created at the check's position - a tossed coin always lands somewhere.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit"];

(_unit call FUNC(hasCoin)) params ["", "_class"];
GVAR(activeCheck) params ["_holder", "_pos", "", "_responded"];

if (isNull _holder) then {
    _holder = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
    _holder setPosATL _pos;
    GVAR(activeCheck) set [0, _holder];
};

_holder addItemCargoGlobal [_class, 1];
_responded pushBack _unit;

[QGVAR(toss), [_class], _unit] call CBA_fnc_targetEvent;
