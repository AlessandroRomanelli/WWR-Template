scriptName "fn_MCOMdestroyed";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_MCOMdestroyed.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_MCOMdestroyed.sqf"

// Warning
["THE OBJECTIVE HAS BEEN DESTROYED"] spawn client_fnc_displayObjectiveMessage;

// Update the last-mcom-destroyed time
//cl_blockSpawnUntil = diag_tickTime + (getNumber(missionConfigFile >> "GeneralConfig" >> "FallBackSeconds"));
//cl_blockSpawnForSide = "attackers";
//[] spawn client_fnc_displaySpawnRestriction;

_fallBackTime = "FallBackSeconds" call bis_fnc_getParamValue;

// Clean our spawnbeacons
_beacon = player getVariable ["assault_beacon_obj", objNull];
if (!isNull _beacon) then {
	deleteVehicle _beacon;
};

// Update spawn cam
[] spawn client_fnc_updateSpawnMenuCam;

// Animation
_animate = {
	disableSerialization;
	_c = (uiNamespace getVariable ["rr_objective_gui",displayNull]) displayCtrl 0;

	// Get pos
	_pos = ctrlPosition _c;

	// Move to new position
	_c ctrlSetPosition [0.443281 * safezoneW + safezoneX, 0.203 * safezoneH + safezoneY, 0.108281 * safezoneW, 0.187 * safezoneH];
	_c ctrlCommit 0.25;
	sleep 6.5;

	// Move to old pos
	_c ctrlSetPosition _pos;
	_c ctrlCommit 0.25;
};

// Param is TRUE if the just destroyed mcom was NOT the last one
if (param[0,false,[false]]) then {
	// If this objective was NOT the last one, reset the time!
	[(getNumber(missionConfigFile >> "MapSettings" >> "roundTime")) + _fallBackTime, _fallBackTime] call client_fnc_initMatchTimer;

	// Update markers
	[] spawn client_fnc_updateMarkers;

	// If we are attacker, block the next mcom for now
	if (player getVariable "gameSide" == "attackers") then {
		cl_enemySpawnMarker = "objective";
	};

	sleep 3;
	[format["DEFENDERS HAVE %1 SECONDS TO FALL BACK", _fallBackTime]] spawn client_fnc_displayObjectiveMessage;
	if (player getVariable ["gameSide", "defenders"] == "defenders") then {
		[area_def, "playArea"] spawn client_fnc_updateLine;
	} else {
		[area_atk, "playArea"] spawn client_fnc_updateLine;
	};
	sleep (_fallBackTime-3);
	if (player getVariable "gameSide" == "attackers") then {
		playSound format["attackOrder_%1", floor random 4+1];
		["NEW OBJECTIVE HAS BEEN ASSIGNED, PUSH!"] spawn client_fnc_displayObjectiveMessage;
	} else {
		playSound format["defendOrder_%1", floor random 4+1];
		["NEW OBJECTIVE HAS BEEN ASSIGNED, DEFEND!"] spawn client_fnc_displayObjectiveMessage;
	};
	[] spawn _animate;

	// Update markers
	[] spawn client_fnc_updateRestrictions;
};

// Reload mcom interaction
[] spawn client_fnc_objectiveActionUpdate;
