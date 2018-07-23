scriptName "fn_updateMarkers";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_updateMarkers.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_updateMarkers.sqf"
if (isServer && !hasInterface) exitWith {};

_updateRestrictedZonesNow = param[0,false,[false]];

_HQPos1 = getArray(missionConfigFile >> "MapSettings" >> "Stages" >> ([] call client_fnc_getCurrentStageString) >> "Spawns" >> "defenders");
_HQPos2 = getArray(missionConfigFile >> "MapSettings" >> "Stages" >> ([] call client_fnc_getCurrentStageString) >> "Spawns" >> "attackers");
"mobile_respawn_defenders" setMarkerPosLocal _HQPos1;
"mobile_respawn_attackers" setMarkerPosLocal _HQPos2;

if (player getVariable "gameSide" == "defenders") then {
	cl_enemySpawnMarker = "";
	"mobile_respawn_defenders" setMarkerTypeLocal "b_unknown";
	"mobile_respawn_defenders" setMarkerTextLocal " Defenders HQ";

	"mobile_respawn_attackers" setMarkerTypeLocal "o_unknown";
	"mobile_respawn_attackers" setMarkerTextLocal " Attackers HQ";
} else {
	"mobile_respawn_defenders" setMarkerTypeLocal "o_unknown";
	"mobile_respawn_defenders" setMarkerTextLocal " Defenders HQ";

	"mobile_respawn_attackers" setMarkerTypeLocal "b_unknown";
	"mobile_respawn_attackers" setMarkerTextLocal " Attackers HQ";
};

"objective" setMarkerPosLocal getPos sv_cur_obj;
