#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side: runs once a coin check's response window has ended. Any participant (everyone
 * who was in range with their coin when the check started) still carrying their own coin never
 * presented it, so they lost - wherever they are now. Each of them is told to play their
 * punishment on their own machine, which skips it if they've opted out.
 *
 * Arguments:
 * 0: Ground weapon holder netId of the check <STRING>
 * 1: Participants <ARRAY of OBJECTs>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_holderNetId", "_participants"];

if (isNil QGVAR(activeCheck) || {(GVAR(activeCheck) select 0) != _holderNetId}) exitWith {};

{
    // Null if the participant disconnected in the meantime
    if (!isNull _x && {(_x call FUNC(hasCoin)) select 0}) then {
        [QGVAR(punish), [], _x] call CBA_fnc_targetEvent;
    };
} forEach _participants;
