#include "..\script_component.hpp"
/*
 * Author: Andx
 * Statement for the ACE self action: hands the activation to the server, which decides whether
 * it starts a new coin check, counts as a toss into the active one, or is rejected.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

[QGVAR(activate), [ACE_player]] call CBA_fnc_serverEvent;
