scriptName "fn_engine";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_engine.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_engine.sqf"
#include "..\utils.h"

["Server engine has been started"] call server_fnc_log;

// Server is now ready
sv_serverReady = true;
[["sv_serverReady"]] call server_fnc_updateVars;

// Persistent weather
VARIABLE_DEFAULT(sv_setting_MapWeather, 0);
if (sv_setting_MapWeather == 0) then {
	[] call server_fnc_loadPersistentWeather;
	["Persistent weather loaded"] call server_fnc_log;
};

// Script monitoring
[] spawn server_fnc_scriptMonitoring;

// Initial start, make sure units requesting time will also not be able to spawn for a certain amount of seconds

if (!isNil "sv_east_group") then {
	deleteGroup sv_east_group;
};
if (!isNil "sv_west_group") then {
	deleteGroup sv_west_group;
};

sv_east_group = createGroup EAST;
sv_east_group deleteGroupWhenEmpty false;
sv_west_group = createGroup WEST;
sv_west_group deleteGroupWhenEmpty false;

VARIABLE_DEFAULT(sv_setting_InitialFallback, 60);
VARIABLE_DEFAULT(sv_setting_AutoTeamBalancer, 1);

// Server engine loop
while {true} do {
	// Kill old threads
	TERMINATE_SCRIPT(sv_persistentVehicleManager_thread);
	TERMINATE_SCRIPT(sv_stageVehicleManager_thread);
	TERMINATE_SCRIPT(sv_matchTimer_thread);
	TERMINATE_SCRIPT(sv_autoTeamBalancer_thread);
	TERMINATE_SCRIPT(sv_corpse_cleaner_thread);

	["Old threads have been killed"] call server_fnc_log;
	[] spawn server_fnc_initParams;
	waitUntil{!isNil "sv_setting_MinPlayers"};
	[] call server_fnc_waitForPlayers;

	// Delete all objects off the map
	[] call server_fnc_cleanUp;
	["Map has been cleaned"] call server_fnc_log;

	// Get random map from config
	if (sv_gameCycle % 2 == 0) then {
		sv_mapSize = [] call server_fnc_decideMapSize;
		[["sv_mapSize"]] call server_fnc_updateVars;
	};
	/* ["Map has been selected"] spawn server_fnc_log; */


	// Load weather
	if (sv_setting_MapWeather == 1) then {
		[] call server_fnc_loadWeather;
		["Weather has been loaded"] call server_fnc_log;
	};

	// Spawn in MCOMs
	[] call server_fnc_spawnObjectives;
	["Objectives have been spawned"] call server_fnc_log;

	//[] call server_fnc_importantObjects;
	//["Important objects have been restored"] spawn server_fnc_log;

	// Refresh tickets
	[] call server_fnc_refreshTickets;
	["Tickets have been reset"] call server_fnc_log;

	// Make a new matchtimer with matchStart param true so it gets broadcasted to all clients
	sv_matchTimer_thread = [true, sv_setting_InitialFallback] spawn server_fnc_matchTimer;
	["Matchtimer has been started"] call server_fnc_log;

	// Map has been selected, broadcast
	sv_gameStatus = 2; // Game may start now
	[["sv_gameStatus"]] call server_fnc_updateVars;

	// Start persistent vehicle manager
	if (isClass(missionConfigFile >> "MapSettings" >> sv_mapSize >> "PersistentVehicles")) then {
		sv_persistentVehicleManager_thread = [] spawn server_fnc_persistentVehicleManager;
		["Persistent vehicles manager has been started"] call server_fnc_log;
	};

	// Start stage vehicle manager (vehicles that spawn at different locations)
	sv_stageVehicleManager_thread = [] spawn server_fnc_stageVehicleManager;
	["Stage vehicles manager has been started"] call server_fnc_log;

	// Start autobalancer (will auto close when the match ends)
	if (sv_setting_AutoTeamBalancer == 1) then {
		sv_autoTeamBalancer_thread = [] spawn server_fnc_autoTeamBalancer;
	};

	sv_corpse_cleaner_thread = [] spawn {
		while {sv_gameStatus == 2} do {
			{
					if (!isPlayer _x) then {
						if (_x getVariable ["toClean", false]) then {
							deleteVehicle _x;
						};
						_x setVariable ["toClean", true];
					};
			} forEach allDeadMen;
			uiSleep 15;
		};
	};


	waitUntil {sv_gameStatus == 4};
	["Restarting engine..."] call server_fnc_log;

	// Count up cycles
	sv_gameCycle = sv_gameCycle + 1;
	[["sv_gameCycle"]] call server_fnc_updateVars;
	[format["Cycle %1 has been finished", sv_gameCycle]] call server_fnc_log;

	// If we have OnMatchEndRestart enabled, restart the mission rather than just keep running
	VARIABLE_DEFAULT(sv_setting_MaxMatchDuration, 10800);
	VARIABLE_DEFAULT(sv_setting_RotationsPerMatch, 2);
	private _missions = getArray(missionConfigFile >> "GeneralConfig" >> "mapsPool");
	private _currentMission = [format["%1.%2", missionName, worldName]];
	private _missionsPool = _missions - _currentMission;
	if (((sv_gameCycle >= sv_setting_RotationsPerMatch) || ((sv_setting_MaxMatchDuration != -1) && (sv_setting_MaxMatchDuration <= diag_tickTime))) && isDedicated) then {
		["Attempting to restart mission...."] call server_fnc_log;
		uiSleep 1;
		private _mission = if (!isNil "sv_nextMap") then {sv_nextMap} else {selectRandom _missionsPool};
		(getText(missionConfigFile >> "GeneralConfig" >> "commandPassword")) serverCommand format["#mission %1 custom", _mission];
		uiSleep 5;
		endMission "MatchEnd";
	};
};
