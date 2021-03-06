scriptName "fn_updateSpawnMenuCam";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_updateSpawnMenuCam.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_updateSpawnMenuCam.sqf"
#include "..\utils.h"

if (!cl_inSpawnMenu) exitWith {};
if (isNil "cl_spawnmenu_cam") exitWith {hint "1"};
if (isNull cl_spawnmenu_cam) exitWith {hint "2"};

// Get cam pos for spawn menu cam
private _stage = sv_cur_obj getVariable ["cur_stage", "Stage1"];
private _side = GAMESIDE(player);
private _pos = getArray(missionConfigFile >> "MapSettings" >> sv_mapSize >> "Stages" >> _stage >> "Spawns" >> _side >> "HQSpawn" >> "positionATL");

// Determine point between current pos and target pos
private _targetPos = [_pos, getPos sv_cur_obj] call client_fnc_getSectionCenter;
private _height = round (100*log(_pos distance2D sv_cur_obj))+50;

// Set cam pos height
_pos set[2, _height];

// Commit
cl_spawnmenu_cam camPreparePos _pos;
cl_spawnmenu_cam camPrepareTarget _targetPos;

cl_spawnmenu_cam camCommitPrepared 1.5;
true
