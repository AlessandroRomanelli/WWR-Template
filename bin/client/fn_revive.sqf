scriptName "fn_revive";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_revive.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_revive.sqf"
if (isServer && !hasInterface) exitWith {};

_savior = param [0, objNull, [objNull]];
_adminRevive = param [1, false, [false]];

// Pos
_pos = getPosATL player;

if (!(_adminRevive) && {_pos distance (getPosWorld _savior) > 10}) then {
	_pos = getPosATL _savior;
	_dir = getDir _savior;
	_rdist = random 2;
	_pos set [0, (_pos select 0)+sin(_dir)*_rdist];
	_pos set [1, (_pos select 1)+cos(_dir)*_rdist];
};

// Make sure the spawn menu script gets cancelled
cl_revived = true;

// Looks like we have been revived :)
setPlayerRespawnTime 0.1;
sleep 0.2;

// Set pos
player setPosATL _pos;
player playActionNow "PlayerProne";

// Message
if (!isNull _savior) then {
	[format ["You have been revived by %1", name _savior]] spawn client_fnc_displayInfo;
} else {
	["You have been revived"] spawn client_fnc_displayInfo;
};

// Lets get back our weapons + one mag which was in the old weapon
[true] spawn client_fnc_equipWeapons;

if (!isNil "rr_respawn_thread") then {
	terminate rr_respawn_thread;
};

// Destroy cam
cl_spawnmenu_cam cameraEffect ["TERMINATE","BACK"];
camDestroy cl_spawnmenu_cam;
player switchCamera "INTERNAL";

// Destroy all objects that are left of us
_objs = nearestObjects [player, ["Man","GroundWeaponHolder", "WeaponHolder"], 5];
{
	deleteVehicle _x;
} forEach _objs;

// Give player all his items
[] spawn client_fnc_equipAll;

// Reenable hud
300 cutRsc ["default","PLAIN"];
cl_gui_thread = [] spawn client_fnc_startIngameGUI;

player setVariable ["unitDmg", 0];
player setVariable ["isAlive", true];
player setVariable ["wasHS", false];

sleep 1;
setPlayerRespawnTime 15;
cl_revived = false;

// Not in spawn menu
cl_inSpawnMenu = false;

// Hold actions
[] spawn client_fnc_initHoldActions;
