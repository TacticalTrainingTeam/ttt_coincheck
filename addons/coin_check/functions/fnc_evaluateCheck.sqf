#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side: runs once a coin check's response window has ended and closes the check. Every
 * player who was eligible at the start but never tossed their coin lost - each of them is told to
 * play their punishment on their own machine, which picks it per their setting or skips it if
 * they've opted out.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

GVAR(activeCheck) params ["", "", "_eligible", "_responded"];
GVAR(activeCheck) = nil;

{
    [QGVAR(punish), [], _x] call CBA_fnc_targetEvent;
} forEach ((_eligible - _responded) select {!isNull _x});
