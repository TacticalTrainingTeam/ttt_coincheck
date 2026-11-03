#include "..\script_component.hpp"
/*
 * Author: Andx
 * Condition for the ACE self action: shown whenever the setting is enabled and the unit is
 * carrying its coin. What exactly clicking it does (join the active check, get told one is
 * already running elsewhere, or start a new one) is decided at activation time rather than here.
 *
 * Arguments:
 * 0: Unit <OBJECT> (default: ACE_player)
 *
 * Return Value:
 * Whether the self action should be shown <BOOL>
 *
 * Public: No
 */

params [["_unit", ACE_player, [objNull]]];

if (!GVAR(enabled)) exitWith {false};

(_unit call FUNC(hasCoin)) params ["_hasCoin"];
_hasCoin
