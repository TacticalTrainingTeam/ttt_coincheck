#include "..\script_component.hpp"
/*
 * Author: Andx
 * Client-side handler for a toss the server accepted: plays the toss gesture and removes the
 * coin from the local player's inventory. The server has already put it into the check's pile.
 *
 * Arguments:
 * 0: Coin classname <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_class"];

[ACE_player, "PutDown"] call ace_common_fnc_doGesture;
ACE_player removeItem _class;

[LLSTRING(tossed), true] call ace_common_fnc_displayText;
