#include "..\script_component.hpp"
/*
 * Author: Andx
 * Plays the toss gesture and moves a unit's coin from its inventory into the shared ground
 * weapon holder of a coin check. Does nothing if the holder doesn't exist (yet) on this machine,
 * so the coin is never removed without landing somewhere.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Coin classname <STRING>
 * 2: Ground weapon holder <OBJECT>
 *
 * Return Value:
 * Whether the coin was tossed <BOOL>
 *
 * Public: No
 */

params ["_unit", "_class", "_holder"];

if (isNull _holder) exitWith {
    [LLSTRING(holderMissing), true] call ace_common_fnc_displayText;
    false
};

[_unit, "PutDown"] call ace_common_fnc_doGesture;
_unit removeItem _class;
_holder addItemCargoGlobal [_class, 1];

[LLSTRING(tossed), true] call ace_common_fnc_displayText;

true
