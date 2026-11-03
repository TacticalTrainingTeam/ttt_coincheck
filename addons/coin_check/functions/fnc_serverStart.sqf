#include "..\script_component.hpp"
/*
 * Author: Andx
 * Server-side handler for a coin-check start request: creates the shared ground weapon holder,
 * records who is taking part (everyone in range with their coin at this moment) and becomes the
 * authoritative source for the check, then announces it to everyone via a CBA global event.
 * Ignored if a check is already running - only one can be active at a time.
 *
 * Arguments:
 * 0: Initiator netId <STRING>
 * 1: Initiator's position <POSITION>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unitNetId", "_pos"];

if (!isNil QGVAR(activeCheck) && {(GVAR(activeCheck) select 2) > CBA_missionTime}) exitWith {};
if (isNull (objectFromNetId _unitNetId)) exitWith {};

private _holder = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
_holder setPosATL _pos;

private _endTime = CBA_missionTime + RESPONSE_TIME;

// Everyone in range and carrying their coin right now is part of this check - walking away
// doesn't get them out of it, and walking in later doesn't pull them in.
private _participants = allPlayers select {
    _x distance _pos <= RESPONSE_RADIUS && {(_x call FUNC(hasCoin)) select 0}
};

// The original holder's netId doubles as the check's ID, even if fnc_serverToss later has to
// replace the holder after it was emptied.
GVAR(holders) set [netId _holder, _holder];
GVAR(activeCheck) = [netId _holder, _pos, _endTime, _unitNetId];

[
    QGVAR(checkStarted),
    [netId _holder, _pos, _endTime, _unitNetId, _participants apply {netId _x}]
] call CBA_fnc_globalEvent;

[
    {_this call FUNC(evaluateCheck)},
    [netId _holder, _participants],
    RESPONSE_TIME
] call CBA_fnc_waitAndExecute;
