#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side handler for a unit activating the coin check self action. Starts a new check if
 * none is running, otherwise accepts the unit's toss if it was eligible when the check started,
 * is still in range and hasn't tossed yet, and tells it why not otherwise.
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

if (!alive _unit) exitWith {};

(_unit call FUNC(hasCoin)) params ["_hasCoin"];
if (!_hasCoin) exitWith {};

if (isNil QGVAR(activeCheck)) exitWith {
    [_unit] call FUNC(serverStart);
};

GVAR(activeCheck) params ["", "_pos", "_eligible", "_responded"];

if (_unit in _responded) exitWith {
    [QGVAR(notify), [LSTRING(alreadyTossed)], _unit] call CBA_fnc_targetEvent;
};

if (_unit in _eligible && {_unit distance _pos <= RESPONSE_RADIUS}) exitWith {
    [_unit] call FUNC(serverToss);
};

[QGVAR(notify), [LSTRING(inProgress)], _unit] call CBA_fnc_targetEvent;
