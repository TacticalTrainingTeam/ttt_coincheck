#include "..\script_component.hpp"
/*
 * Author: Andx
 * Plays the local player's chosen punishment animation (or a random one, per GVAR(punishment))
 * for PUNISHMENT_DURATION, then hands control back. Skipped if the player has opted out of coin
 * checks or can't safely play an exercise animation right now (dead, unconscious, in a vehicle).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// The server can't see this per-client setting, so it punishes everyone in range still holding
// their coin - opted-out players are filtered out here instead.
if (!GVAR(enabled)) exitWith {};

private _canExercise = {
    params ["_unit"];
    alive _unit && {isNull objectParent _unit} && {!(_unit getVariable ["ACE_isUnconscious", false])}
};

if !([ACE_player] call _canExercise) exitWith {};

private _anim = switch (GVAR(punishment)) do {
    case 1: {PUNISHMENT_ANIM_KNEE_BENDS};
    case 2: {PUNISHMENT_ANIM_PUSHUPS};
    default {selectRandom [PUNISHMENT_ANIM_KNEE_BENDS, PUNISHMENT_ANIM_PUSHUPS]};
};

// These are CutSceneAnimationBase/CivilExerciseActions moves, not part of the normal combat
// transition graph, so playMove (which queues behind the current move) never reaches them -
// playMoveNow has to be used to start them immediately.
ACE_player playMoveNow _anim;

[
    {
        params ["_unit", "_anim", "_canExercise"];

        // Only reset if the unit is still doing the exercise - never yank it out of an
        // unconscious, death or vehicle animation it entered in the meantime.
        if !([_unit] call _canExercise) exitWith {};
        if (animationState _unit != toLowerANSI _anim) exitWith {};

        // switchMove is local-effect; ACE's helper broadcasts it so everyone sees the reset.
        [_unit, "", 2] call ace_common_fnc_doAnimation;
    },
    [ACE_player, _anim, _canExercise],
    PUNISHMENT_DURATION
] call CBA_fnc_waitAndExecute;
