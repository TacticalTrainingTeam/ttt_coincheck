#include "..\script_component.hpp"
/*
 * Author: Andx
 * CBA global event handler run on every client when the server grants a new coin check.
 * Records it so the self action can react to it, tosses the initiator's own coin now that the
 * check is granted, and prompts the other participants to respond.
 *
 * Arguments:
 * 0: Ground weapon holder netId <STRING>
 * 1: Position of the check <POSITION>
 * 2: Response deadline, in CBA_missionTime <NUMBER>
 * 3: Initiator netId <STRING>
 * 4: Participant netIds, as determined by the server <ARRAY of STRINGs>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_holderNetId", "_pos", "_endTime", "_initiatorNetId", "_participantIds"];

GVAR(activeCheck) = [_holderNetId, _pos, _endTime, _initiatorNetId];

if (netId ACE_player == _initiatorNetId) exitWith {
    (ACE_player call FUNC(hasCoin)) params ["_hasCoin", "_class"];
    if (!_hasCoin) exitWith {};

    [ACE_player, _class, _holderNetId, _pos] call FUNC(respond);
    GVAR(respondedHolderId) = _holderNetId;

    [format [LLSTRING(started), RESPONSE_RADIUS, RESPONSE_TIME], true] call ace_common_fnc_displayText;
};

if (!GVAR(enabled)) exitWith {};
// Use the server's participant list rather than this client's own distance check, so exactly
// the players who will be evaluated get prompted.
if !(netId ACE_player in _participantIds) exitWith {};

(ACE_player call FUNC(hasCoin)) params ["_hasCoin"];
if (!_hasCoin) exitWith {};

[format [LLSTRING(prompt), round (_endTime - CBA_missionTime)], true] call ace_common_fnc_displayText;
