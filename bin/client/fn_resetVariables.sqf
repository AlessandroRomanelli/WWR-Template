scriptName "fn_resetVariables";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_resetVariables.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_resetVariables.sqf"
if (isServer && !hasInterface) exitWith {};

// Remove all actions
if (!isNil "cl_actionIDs") then {
	{
		[player, _x] call BIS_fnc_holdActionRemove;
	} forEach cl_actionIDs;
};

// Vars
cl_kills = 0;
cl_deaths = 0;
cl_points = 0;
cl_killfeed = [];
cl_spawn_tick = 0;
cl_timelineevents = [];
cl_revived = false;
cl_inSpawnMenu = false;
cl_beacon_used = 0;
cl_class = "";
cl_assistsInfo = [];
cl_classPerk = "";
cl_squadPerk = "";
cl_actionIDs = [];
cl_mcomDefAtt = 0;
cl_pointsBelowMinimumPlayers = 0;
cl_enemySpawnMarker = if (player getVariable "gameSide" == "defenders") then {"mobile_respawn_attackers"} else {"mobile_respawn_defenders"};
cl_blockTimer = false;
TEMPWARNING = nil;
cl_onEachFrame_squad_members = [];
cl_onEachFrame_squad_beacons = [];
cl_onEachFrame_team_members = [];
cl_onEachFrame_team_reviveable = [];

// Any beacons left?
_beacon = player getVariable ["assault_beacon_obj", objNull];
if (!isNull _beacon) then {
	deleteVehicle _beacon;
};

// Start the ingame point feed
301 cutRsc ["rr_pointfeed","PLAIN"];

// Start top objective gui
400 cutRsc ["rr_objective_gui","PLAIN"];

// Setup the objective icon at the top
if (player getVariable "gameSide" == "defenders") then {
	disableSerialization;
	_d = uiNamespace getVariable ["rr_objective_gui", displayNull];
	(_d displayCtrl 0) ctrlSetText "pictures\objective_defender.paa";
};

// Wait until we have a ticket count
waitUntil {!isNil "sv_tickets" && !isNil "sv_tickets_total"};

// Display teammates and objective
if (isNil "rr_iconrenderer_executed") then {
	rr_iconrenderer_executed = true;
	/* ["rr_spawn_iconrenderer", "onEachFrame"] call bis_fnc_removeStackedEventHandler; */
	/* ["rr_spawn_iconrenderer", "onEachFrame", { */
	onEachFrame {
		/* {
			if (side _x == playerSide) then {
				if (alive _x) then {
					if (_x != player) then {
						_pos = getPosATLVisual _x;
						_pos set [2, (_pos select 2) + 1.85];

						if (group _x == group player) then {
							if (cl_inSpawnMenu) then {
								if (_x distance sv_cur_obj < 3500) then {
									// Squad member! Determine picture
									_icon = call {
										if (_x getVariable ["class",""] == "medic") exitWith {"pictures\medic.paa"};
										if (_x getVariable ["class",""] == "engineer") exitWith {"pictures\engineer.paa"};
										if (_x getVariable ["class",""] == "support") exitWith {"pictures\support.paa"};
										"pictures\assault.paa";
									};

									// Determine alpha value
									//_alpha = if (_x distance player > 50) then {0.55} else {1};
									_alpha = [0.85, 0.35] select (_x distance player > 50);
									drawIcon3D[format["%1%2",MISSION_ROOT, _icon], [1,1,1,_alpha], _pos, 1.5, 1.5, 0, name _x, 2, 0.04, "PuristaMedium", "center", true];

									// Draw spawn beacons
									_beacon = _x getVariable ["assault_beacon_obj", objNull];
									if (!isNull _beacon) then {
										drawIcon3D[format["%1%2",MISSION_ROOT, _icon], [1,1,1,_alpha], (getPosATLVisual _beacon), 1.5, 1.5, 0, format["%1's Spawnbeacon", name _x], 2, 0.04, "PuristaMedium", "center", true];
									};
								};
								} else {
									// Not in the spawn menu, just render the normal squad icons without spawn beacons
									_icon = call {
										if (_x getVariable ["class",""] == "medic") exitWith {"pictures\medic.paa"};
										if (_x getVariable ["class",""] == "engineer") exitWith {"pictures\engineer.paa"};
										if (_x getVariable ["class",""] == "support") exitWith {"pictures\support.paa"};
										"pictures\assault.paa";
									};

									// Alpha and render
									//_alpha = if (_x distance player > 50) then {0.55} else {1};
									_alpha = [0.85, 0.35] select (_x distance player > 50);
									drawIcon3D[format["%1%2",MISSION_ROOT, _icon], [1,1,1,_alpha], _pos, 1.5, 1.5, 0, name _x, 2, 0.04, "PuristaMedium", "center", true];
								};
								} else {
									// Icon for teammates
									if (!cl_inSpawnMenu) then {
										_d = if ((vehicle player) isKindOf "Air") then {2000} else {50};
										if (_x distance player < _d || _x == (driver vehicle cursorObject) || _x == (driver vehicle cursorTarget)) then {
											drawIcon3D[format["%1pictures\teammate.paa",MISSION_ROOT], [1,1,1,0.75], _pos, 0.5, 0.5, 0, "", 2, 0.035, "PuristaMedium", "center", false];
										};
										} else {
											if (_x distance sv_cur_obj < 3500) then {
												drawIcon3D[format["%1pictures\teammate.paa",MISSION_ROOT], [1,1,1,0.75], _pos, 0.5, 0.5, 0, "", 2, 0.035, "PuristaMedium", "center", false];
											};
										};
									};
								};
								} else {
									if (cl_inSpawnMenu) then {
										if ((group _x) == (group player)) then {
											_beacon = _x getVariable ["assault_beacon_obj", objNull];
											if (!isNull _beacon) then {
												drawIcon3D["", [1,1,1,_alpha], (getPosATLVisual _beacon), 1.5, 1.5, 0, format["%1's Spawnbeacon", name _x], 2, 0.04, "PuristaMedium", "center", true];
											};
										};
									};
								};
							};
							} forEach allPlayers;

							if (cl_class == "medic" && cl_classPerk == "defibrillator") then {
								{
									if (_x distance player < 25) then {
										if (_x getVariable ["side", sideUnknown] == playerSide) then {
											_pos = getPosATLVisual _x;
											_pos set [2, (_pos select 2) + 0.1];
											drawIcon3D[format["%1pictures\revive.paa",MISSION_ROOT], [1,1,1,0.8], _pos, 1.5, 1.5, 0, "", 2, 0.035, "PuristaMedium", "center", false];
										};
									};
									} forEach AllDeadMen;
								}; */


		// Objectives
		_pos = getPosATLVisual sv_cur_obj;
		_pos set [2, (_pos select 2) + 0.5];

		_alpha = 1 - ((((player getRelDir _pos) - 180)/180)^30);

		if (player getVariable ["gameSide", "defenders"] == "defenders") then {
			drawIcon3D [format ["%1pictures\objective_defender.paa",MISSION_ROOT],[1,1,1,_alpha],_pos,1.5,1.5,0,format["Defend (%1m)", round(player distance sv_cur_obj)],2,0.04, "PuristaLight", "center", true];
		} else {
			drawIcon3D [format ["%1pictures\objective_attacker.paa",MISSION_ROOT],[1,1,1,_alpha],_pos,1.5,1.5,0,format["Attack (%1m)", round(player distance sv_cur_obj)],2,0.04, "PuristaLight", "center", true];
		};

		// Squad icons
		{
			_pos = getPosATLVisual (_x select 0);
			_pos set [2, (_pos select 2) + 1.85];
			drawIcon3D[_x select 2, [1,1,1, _x select 3], _pos, 1.5, 1.5, 0, _x select 1, 2, 0.04, "PuristaMedium", "center", true];
		} forEach cl_onEachFrame_squad_members;

		// Squad spawn beacons
		{
			drawIcon3D["", [1,1,1,1], _x select 0, 1.5, 1.5, 0, _x select 1, 2, 0.04, "PuristaMedium", "center", true];
		} forEach cl_onEachFrame_squad_beacons;

		// Team icons
		{
			_unit = _x select 0;
			_pos = getPosATLVisual _unit;
			_pos set [2, (_pos select 2) + 1.85];
			if (_unit == (driver vehicle cursorObject) || _unit == (driver vehicle cursorTarget)) then {
				drawIcon3D[_x select 2, [1,1,1,0.75], _pos, 0.5, 0.5, 0, _x select 1, 2, 0.03, "PuristaMedium", "center", false];
			} else {
				drawIcon3D[_x select 2, [1,1,1,0.25], _pos, 0.5, 0.5, 0, "", 2, 0.03, "PuristaMedium", "center", false];
			};
		} forEach cl_onEachFrame_team_members;

		// Revive icons
		if (cl_class == "medic" && cl_classPerk == "defibrillator") then {
			{
				_pos = getPosATLVisual (_x select 0);
				_pos set [2, (_pos select 2) + 0.1];
				drawIcon3D[_x select 1, [1,1,1,0.8], _pos, 1.5, 1.5, 0, "", 2, 0.035, "PuristaMedium", "center", false];
			} forEach cl_onEachFrame_team_reviveable;
		};


		_d = uiNamespace getVariable ["rr_objective_gui", displayNull];
		(_d displayCtrl 1) ctrlSetStructuredText parseText format ["<t size='1' color='#FFFFFF' shadow='2' font='PuristaMedium' align='left'>%1</t>", sv_tickets];
		(_d displayCtrl 4) ctrlSetStructuredText parseText format ["<t size='1' color='#FFFFFF' shadow='2' font='PuristaMedium' align='right'>%1</t>", [cl_matchTime, "MM:SS"] call bis_fnc_secondsToString];
		(_d displayCtrl 2) progressSetPosition (sv_tickets / sv_tickets_total);

		// MERGE OF INGAME GUI
		_hud = uiNameSpace getVariable ["playerHUD",displayNull];
		_HUD_currentAmmo = _hud displayCtrl 100;
		_HUD_reserveAmmo = _hud displayCtrl 101;
		_HUD_firemode = _hud displayCtrl 102;
		_HUD_healthPlus = _hud displayCtrl 103;
		_HUD_healthPoints = _hud displayCtrl 104;
		_HUD_zeroing = _hud displayCtrl 105;
		_HUD_slashBetweenAmmo = _hud displayCtrl 106;
		_HUD_grenades = _hud displayCtrl 107;
		_HUD_typeGrenade = _hud displayCtrl 108;

		_currentAmmo = 0;
		_reserveAmmo = 0;
		_grenades    = 0;
		_fireMode = "";

		_mode = currentWeaponMode gunner vehicle player;
		if (typeName _mode == "STRING") then {
			if (_mode == "Single") then {_fireMode = "SNGL"};
			if (_mode in ["Burst","Burst2rnd"]) then {_fireMode = "BRST"};
			if (_mode == "FullAuto" OR _mode == "manual") then {_fireMode = "AUTO"};
		} else {_fireMode = "---"};

		if (vehicle player == player || {(driver vehicle player != player) && {gunner vehicle player != player} && {commander vehicle player != player}}) then {
			{
				if ((_x select 0) == (currentMagazine player) AND (_x select 2)) then
				{
					_currentAmmo = (_x select 1);
				};
				if ((_x select 0) == (currentMagazine player) AND !(_x select 2)) then
				{
					_reserveAmmo = _reserveAmmo + (_x select 1);
				};
				if ((_x select 0) isEqualTo ((currentThrowable player) select 0)) then
				{
					_grenades = _grenades + 1;
				};
			} forEach (magazinesAmmoFull player);
		} else {
			if (driver (vehicle player) == player) then {
				_currentAmmo = format ["%1", abs (floor (speed (vehicle player)))];
				_reserveAmmo = format ["%1°", floor getDir (vehicle player)];
				_fireMode = "KM/H";
			} else {
				_currentAmmo = (vehicle player) ammo (currentWeapon (vehicle player));
				_reserveAmmo = [] call {
					_reserveAmmo = 0 - ((vehicle player) ammo (currentWeapon (vehicle player)));
					{if ((_x select 0) isEqualto (currentMagazine (vehicle player))) then {_reserveAmmo = _reserveAmmo + (_x select 1)}} forEach magazinesAmmo (vehicle player);
					_reserveAmmo};
			};
		};

		_grenadeIcon = if (((currentThrowable player) select 0) in ["LIB_US_Mk_2", "LIB_shg24"]) then {"pictures\frag.paa"} else {"pictures\smoke.paa"};
		if ((currentThrowable player) isEqualto []) then {
			_grenadeIcon = "";
		};

		if (_grenades isEqualTo 0) then {_grenades = ""};

		_HUD_currentAmmo  ctrlSetText format ["%1",_currentAmmo];
		_HUD_reserveAmmo  ctrlSetText format ["%1",_reserveAmmo];
		_HUD_firemode     ctrlSetStructuredText parseText format ["<t align='left' size='1'>[</t><t align='center' size='1'>%1</t><t align='right' size='1'>]</t>",_fireMode];
		_HUD_healthPoints ctrlSetText format ["%1",floor((1-(damage player))*100)];
		_HUD_zeroing  		ctrlSetText format ["%1m", currentZeroing player];
		_HUD_typeGrenade	ctrlSetText _grenadeIcon;
		_HUD_grenades			ctrlSetText format ["%1", _grenades];

		// warning if we are too close to the enemy spawn
		if (alive player && {!(vehicle player isKindOf "Air")} && {player getVariable ["isAlive", false]}) then {
			if (player distance (getMarkerPos cl_enemySpawnMarker) < 100) then {
				30 cutRsc ["rr_restrictedAreaSpawn", "PLAIN"];
				if (isNil "cl_restrictedArea_thread") then {
					cl_restrictedArea_thread = [] spawn client_fnc_restrictedArea;
				};
			};
		};

		if (alive player && {!(vehicle player isKindOf "Air")}) then {
			if (player getVariable ["gameSide", "attackers"] == "attackers") then {
				if ((!(vehicle player in (list area_atk))) && {player getVariable ["isAlive", false]}) then {
					sleep 0.25;
					30 cutRsc ["rr_restrictedArea", "PLAIN"];
					_display = uiNamespace getVariable ["rr_restrictedArea", displayNull];
					if (diag_tickTime - (player getVariable "entryTime") < 20) then {
						(_display displayCtrl 1101) ctrlSetStructuredText parseText format ["<t size='5' color='#FFFFFF' shadow='2' align='center' t font='PuristaBold'>%1s</t>", ([21 - diag_tickTime + (player getVariable "entryTime"), "MM:SS", true] call bis_fnc_secondsToString) select 1];
					};
					if (isNil "cl_restrictedAreaAttackers_thread") then {
						cl_restrictedAreaAttackers_thread = [] spawn client_fnc_restrictedAreaAttackers;
					};
				};
			};
		};

		if (alive player && {!(vehicle player isKindOf "Air")}) then {
			if (player getVariable ["gameSide", "defenders"] == "defenders") then {
				if ((not (vehicle player in (list area_def))) && player getVariable ["isAlive", false]) then {
					30 cutRsc ["rr_restrictedArea", "PLAIN"];
					_display = uiNamespace getVariable ["rr_restrictedArea", displayNull];
					if (diag_tickTime - (player getVariable "entryTime") < 20) then {
						(_display displayCtrl 1101) ctrlSetStructuredText parseText format ["<t size='5' color='#FFFFFF' shadow='2' align='center' t font='PuristaBold'>%1s</t>", ([21 - diag_tickTime + (player getVariable "entryTime"), "MM:SS", true] call bis_fnc_secondsToString) select 1];
					};
					if (isNil "cl_restrictedAreaDefenders_thread") then {
						cl_restrictedAreaDefenders_thread = [] spawn client_fnc_restrictedAreaDefenders;
					};
				};
			};

			if ((cl_squadPerk == "swim") && {alive player} && {((vehicle player) isEqualto player)} && {!(isTouchingGround player)} && {(surfaceIsWater (getPosWorld player))}) then {
				player setAnimSpeedCoef 3;
			} else {
				player setAnimSpeedCoef 1;
			};
		};
	};
	/* }] call BIS_fnc_addStackedEventHandler; */
};

// Pointfeed init
cl_pointfeed_text = "";
cl_pointfeed_points = 0;

// Remove global vars
player setVariable ["kills",nil,true];
player setVariable ["deaths",nil,true];
player setVariable ["points",nil,true];
