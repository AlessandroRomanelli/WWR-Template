scriptName "fn_resetVariables";
/*--------------------------------------------------------------------
	Authors: Maverick & A.Roman
    File: fn_resetVariables.sqf

    Written by both authors
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_resetVariables.sqf"
#include "..\utils.h"
if (isServer && !hasInterface) exitWith {};

// Vars
[] call client_fnc_initGlobalVars;


private _isDefending = player getVariable ["side", side player] == WEST;
cl_enemySpawnMarker = if (_isDefending) then {
	"mobile_respawn_attackers"
} else {
	"mobile_respawn_defenders"
};


// Remove all actions
if (!isNil "cl_actionIDs") then {
	{
		[player, _x] call BIS_fnc_holdActionRemove;
	} forEach cl_actionIDs;
};

// Any beacons left?
private _beacon = player getVariable ["assault_beacon_obj", objNull];
if (!isNull _beacon) then {
	deleteVehicle _beacon;
};

// Start the ingame point feed
301 cutRsc ["rr_pointfeed","PLAIN"];

// Start top objective gui
400 cutRsc ["rr_objective_gui","PLAIN"];

// Wait until we have a ticket count
/* waitUntil {!isNil "sv_tickets" && !isNil "sv_tickets_total"}; */

// Display teammates and objective

[] call client_fnc_UIPreparation;

REMOVE_EXISTING_MEH("EachFrame", cl_onEachFrameIconRenderedID);
cl_onEachFrameIconRenderedID = [] call client_fnc_initUserInterface;

// Pointfeed init
cl_pointfeed_text = "";
cl_pointfeed_points = 0;

// Remove global vars
player setVariable ["kills",nil,true];
player setVariable ["deaths",nil,true];
player setVariable ["points",nil,true];

true
