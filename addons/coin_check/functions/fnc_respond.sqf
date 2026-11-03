#include "..\script_component.hpp"
/*
 * Author: Andx
 * Plays the toss gesture, removes a unit's coin from its inventory and hands it to the server,
 * which puts it into the check's shared ground weapon holder (recreating it if it was emptied).
 * Going through the server means the coin never depends on the holder existing on this machine.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Coin classname <STRING>
 * 2: Check ID, the netId of the check's original holder <STRING>
 * 3: Position of the check <POSITION>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_class", "_checkId", "_pos"];

[_unit, "PutDown"] call ace_common_fnc_doGesture;
_unit removeItem _class;
[QGVAR(toss), [_checkId, _pos, _class]] call CBA_fnc_serverEvent;

[LLSTRING(tossed), true] call ace_common_fnc_displayText;
