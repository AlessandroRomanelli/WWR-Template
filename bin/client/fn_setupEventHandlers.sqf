scriptName "fn_setupEventHandlers";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV) & A. Roman
    File: fn_setupEventHandlers.sqf

    Written by both authors
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_setupEventHandlers.sqf"
if (isServer && !hasInterface) exitWith {};

// Remove all handlers
player removeAllEventHandlers "Take";
player removeAllEventHandlers "InventoryOpened";
player removeAllEventHandlers "Fired";
player removeAllEventHandlers "Hit";
player removeAllEventHandlers "HitPart";
player removeAllEventHandlers "Killed";
player removeAllEventHandlers "Respawn";
player removeAllEventHandlers "HandleDamage";
[missionNamespace, "groupPlayerChanged"] call BIS_fnc_removeAllScriptedEventHandlers;
[missionNamespace, "switchedToExtCamera"] call BIS_fnc_removeAllScriptedEventHandlers;
[missionNamespace, "playAreaChanged"] call BIS_fnc_removeAllScriptedEventHandlers;
[missionNamespace, "objStatusChanged"] call BIS_fnc_removeAllScriptedEventHandlers;
[missionNamespace, "playerSwimChanged"] call BIS_fnc_removeAllScriptedEventHandlers;
[missionNamespace, "newEnemiesNearby"] call BIS_fnc_removeAllScriptedEventHandlers;

// Custom Event Handler for Group Change
cl_groupSize = -1;
cl_playAreaPos = [0,0,0];
cl_obj_status = -1;
cl_playerSwimming = !(isTouchingGround player) && (surfaceIsWater (getPosATL player));
cl_enemiesNearby = 0;
removeMissionEventHandler["Map", cl_mapObserverID];
cl_mapObserverID = addMissionEventHandler["Map", {
		params ["_mapIsOpened"];
		if (_mapIsOpened && !cl_mapSetup) then {
			cl_mapSetup = true;
			private _fullScreenMapCtrl = (findDisplay 12) displayCtrl 51;
			_fullScreenMapCtrl ctrlMapAnimAdd [0, 0.075, getPosATL sv_cur_obj];
			ctrlMapAnimCommit _fullScreenMapCtrl;
		};
		if (_mapIsOpened) then {
			300 cutText ["", "PLAIN"];
		} else {
			300 cutRsc ["playerHUD", "PLAIN"];
		};
}];

removeMissionEventHandler["EachFrame", cl_eventObserverID];
cl_eventObserverID = addMissionEventHandler["EachFrame", {
		private ["_data"];
		_data = count (units group player);
		if !(_data isEqualTo cl_groupSize) then {
			[missionNamespace, "groupPlayerChanged"] call BIS_fnc_callScriptedEventHandler;
			cl_groupSize = _data;
		};

		_data = cameraView;
		if (_data isEqualTo "EXTERNAL") then {
			[missionNamespace, "switchedToExtCamera"] call BIS_fnc_callScriptedEventHandler;
		};

		_data = getPosATL playArea;
		if !(_data isEqualTo cl_playAreaPos) then {
			[missionNamespace, "playAreaChanged"] call BIS_fnc_callScriptedEventHandler;
			cl_playAreaPos = _data;
		};

		_data = sv_cur_obj getVariable ["status", -1];
		if !(_data isEqualTo cl_obj_status) then {
			[missionNamespace, "objStatusChanged", [_data]] call BIS_fnc_callScriptedEventHandler;
			cl_obj_status = _data;
		};

		_data = !(isTouchingGround player) && (surfaceIsWater (getPosATL player));
		if !(_data isEqualTo cl_playerSwimming) then {
			[missionNamespace, "playerSwimChanged"] call BIS_fnc_callScriptedEventHandler;
			cl_playerSwimming = _data;
		};

		private _enemiesNearby = ((getPosATL player) nearEntities ["Man", 10]) select {alive _x && {(_x getVariable ["gameSide", ""]) != (player getVariable ["gameSide", ""])}};
		_data =  count _enemiesNearby;
		if !(_data isEqualTo cl_enemiesNearby) then {
			[missionNamespace, "newEnemiesNearby", [_enemiesNearby]] call BIS_fnc_callScriptedEventHandler;
			cl_enemiesNearby = _data;
		};
}];

// If the group size changes (either we left or some other people joined) update the perks
[missionNamespace, "groupPlayerChanged", {
	[] call client_fnc_getSquadPerks;
}] call bis_fnc_addScriptedEventHandler;

[missionNamespace, "playAreaChanged", {
	["playArea"] call client_fnc_updateLine;
}] call bis_fnc_addScriptedEventHandler;

[missionNamespace, "playerSwimChanged", {
	if (("swim" in cl_squadPerks) && {player getVariable ["isAlive", false]} && {isNull (objectParent player)} && {!(isTouchingGround player)} && {(surfaceIsWater (getPosATL player))}) then {
		player setAnimSpeedCoef 3;
	} else {
		if ("sprint" in cl_squadPerks) then {
			player setAnimSpeedCoef 1.3;
		} else {
			player setAnimSpeedCoef 1.15;
		};
	};
}] call bis_fnc_addScriptedEventHandler;

[missionNamespace, "objStatusChanged", {
	// Update objective marker to reflect status
		private _status = param [0, -1, [0]];
		[true] call client_fnc_updateMarkers;
		if (_status isEqualTo 1) then {
			// Make the UI at the top blink
			[] spawn client_fnc_objectiveArmedGUIAnimation;
		};
}] call bis_fnc_addScriptedEventHandler;

[missionNamespace, "switchedToExtCamera", {
	private _infFP = (["InfantryFPOnly", 1] call BIS_fnc_getParamValue) isEqualTo 1;
	private _vehFP = (["VehicleFPOnly", 0] call BIS_fnc_getParamValue) isEqualTo 1;
	if (isNull objectParent player) then {
		if (_infFP) then {
			player switchCamera "INTERNAL";
		};
	} else {
		if (_vehFP) then {
			player switchCamera "INTERNAL";
			["Third person view for vehicles is disabled"] call client_fnc_displayError;
		};
	};
}] call bis_fnc_addScriptedEventHandler;

[missionNamespace, "newEnemiesNearby", {
	params [["_enemiesNearby", [], []]];
	{
		if (_x getVariable ["melee_action", -1] != -1) then {
			[_x, _x getVariable "melee_action"] call BIS_fnc_holdActionRemove;
		};
		private _id = [
		/* 0 object */							_x,
		/* 1 action title */					"Melee Kill",
		/* 2 idle icon */						WWRUSH_ROOT+"pictures\support.paa",
		/* 3 progress icon */					WWRUSH_ROOT+"pictures\support.paa",
		/* 4 condition to show */				"(_this distance _target) < 2.5 && {alive _target} && {(_target getRelDir _this) > 90 && (_target getRelDir _this) < 270}",
		/* 5 condition for action */			"(_this distance _target) < 2.5 && {alive _target} && {(_target getRelDir _this) > 90 && (_target getRelDir _this) < 270}",
		/* 6 code executed on start */			{},
		/* 7 code executed per tick */			{},
		/* 8 code executed on completion */		{
			params ["_target", "_caller"];
			[_caller] remoteExecCall ["client_fnc_meleeTakedown", _target];
		},
		/* 9 code executed on interruption */	{},
		/* 10 arguments */						[],
		/* 11 action duration */				0.5,
		/* 12 priority */						500,
		/* 13 remove on completion */			true,
		/* 14 show unconscious */				false
		] call BIS_fnc_holdActionAdd;
		_x setVariable ["melee_action", _id];
	} forEach _enemiesNearby;
}] call bis_fnc_addScriptedEventHandler;

// Automatic magazine recombination
player addEventHandler ["Take", {
	private _magInfo = magazinesAmmoFull player;
	private _curMag = currentMagazine player;
	private _bulletCount = 0;
	{
		if ((_x select 0) == _curMag AND !(_x select 2)) then {
			_bulletCount = _bulletCount + (_x select 1);
			player removeMagazine _curMag;
		};
	} forEach _magInfo;

	if (_bulletCount == 0) exitWith {};

	private _maxBulletCountPerMag = getNumber(configfile >> "CfgMagazines" >> _curMag >> "count");
	private _fillMags = true;
	while {_fillMags} do
	{
		if (_bulletCount > _maxBulletCountPerMag) then
		{
			_bulletCount = _bulletCount - _maxBulletCountPerMag;
			player addMagazine [_curMag, _maxBulletCountPerMag];
		} else {
			player addMagazine [_curMag, _bulletCount];
			_fillMags = false;
		};
	};
}];

// Direction indicators and inventory blocker
player addEventHandler ["InventoryOpened", {closeDialog 0;true;}];

player addEventHandler ["Hit",{
	private _d = [_this select 0, _this select 1] call BIS_fnc_relativeDirTo;
	if (_d >= 315 || _d <= 45) then {351 cutRsc ["cu","PLAIN"];};
	if (_d >= 45 AND _d <= 135) then {352 cutRsc ["cr","PLAIN"];};
	if (_d >= 135 AND _d <= 225) then {353 cutRsc ["cd","PLAIN"];};
	if (_d >= 225 AND _d <= 315) then {354 cutRsc ["cl","PLAIN"];};
	if ((_this select 1) == player) then {
		351 cutRsc ["cu","PLAIN"];
		352 cutRsc ["cr","PLAIN"];
		353 cutRsc ["cd","PLAIN"];
		354 cutRsc ["cl","PLAIN"];
	};
}];

// Hit
player addEventHandler ["Hit",
{
	// Stop any hp regeneration thread
	if (!isNil "client_hpregeneration_thread") then {
		terminate client_hpregeneration_thread;
	};

	// In combat
	if !(player getVariable ["inCombat", false]) then {
		player setVariable ["inCombat",true,true];
	};

	// Did we get hit by a player? Add it to our assist-array
	private _causedBy = _this select 1;
	if (!isNull _causedBy && isPlayer _causedBy) then {
		["Assists detected 0"] call server_fnc_log;
		[_causedBy, _this select 2] call client_fnc_countAssist;
	};

	// Hp regeneration
	client_hpregeneration_thread = [] spawn client_fnc_regenerateHP;
}];

// Killed
player addEventHandler ["Killed", {
	private _victim = _this select 0;
	private _lastDeath = _victim getVariable ["lastDeath", 0];
	//Avoiding more than one time each 1/10 of a second
	if (diag_tickTime - _lastDeath > 0.1) then {
		_victim setVariable ["lastDeath", diag_tickTime];
		_victim setVariable ["wwr_unit_loadout", getUnitLoadout _victim];
		private _killer = _this select 1;
		private _instigator = _this select 2;
		// Increase deaths
		cl_deaths = cl_deaths + 1;
		cl_total_deaths = cl_total_deaths + 1;

		_victim setVariable ["deaths",cl_deaths,true];

		if (!isNull _instigator) then {
			_killer = _instigator;
		};

		[format ["You have been killed by killer %1", str _killer]] call server_fnc_log;
		[format ["You have been killed by instigator %1", str _instigator]] call server_fnc_log;

		// Attempt to retrieve the grenade that killed the unit
		private _grenade = _victim getVariable ["grenade_kill", ""];
		// Check if the player was killed via melee takedown
		private _meleeKiller = _victim getVariable ["melee_killer", objNull];
		private _wasMelee = false;
		if (!isNull _meleeKiller) then {
			_killer = _meleeKiller;
			_wasMelee = true;
		};
		// Send message to killer that he killed someone
		if ((!isNull _victim) && {!isNull _killer} && {_victim != _killer}) then {
			if (_victim getVariable ["isAlive", false]) then {
        private _wasHS = _victim getVariable ["wasHS", false];
				[_victim, _wasHS, _grenade, _wasMelee] remoteExecCall ["client_fnc_kill", _killer];
				_victim setVariable ["isAlive", false];
			};
			// you have been killed by message
			[format ["You have been killed by<br/>%1", [_killer] call client_fnc_getUnitName]] call client_fnc_displayInfo;

		};
		// Send message to all units that we are reviveable
		// As this package gets send to all clients we might aswell use it to share our information regarding assists (damage that was inflicted on us)
		[_victim, _killer, cl_assistsInfo, _grenade, _wasMelee] remoteExec ["client_fnc_medic_unitDied", 0];
		_victim setVariable ["grenade_kill", nil];
		// Disable hud
		["rr_spawn_bottom_right_hud_renderer", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		300 cutRsc ["default","PLAIN"];

		rr_respawn_thread = [] spawn client_fnc_killed;

		_victim setVariable ["isAlive", false];

		private _spawnSafeDistance = (getNumber (missionConfigFile >> "MapSettings" >> sv_mapSize >> "safeSpawnDistance"));
		private _spawnSafeTime = ["SpawnSafeTime", 5] call BIS_fnc_getParamValue;
		private _spawnMarker = format ["mobile_respawn_%1", _victim getVariable "gameSide"];
		if (_killer getVariable ["gameSide", "attackers"] != (_victim getVariable ["gameSide", "defenders"]) &&
				{(diag_tickTime - cl_spawn_tick) < _spawnSafeTime} &&
				{(_victim distance (getMarkerPos _spawnMarker)) < _spawnSafeDistance}) exitWith {
			// Info
			["Your killer has been punished for spawn camping, your death will not be counted"] call client_fnc_displayError;
			cl_deaths = cl_deaths - 1;
			cl_total_deaths = cl_total_deaths - 1;

			// Revive us
			[objNull, true] spawn client_fnc_revive;

			// Kill the killer
			["You have been killed for spawn camping"] remoteExecCall ["client_fnc_administrationKill",_killer];
		};
	};
}];

// Assign current weapon to player when firing (to avoid PUT and THROW)
player addEventHandler ["Fired", {
  params ["_unit", "_weapon"];
  private _lastWepon = _unit getVariable ["lastWeaponFired", ""];
  if !(_weapon isEqualTo _lastWepon) then
  {
    _unit setVariable ["lastWeaponFired", _weapon,true];
  };
}];

// Handledamage
player addEventHandler ["HandleDamage", {
	params ["_unit", "_hitSelection", "_damage", "_shooter", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
	// Instigator is defined? If yes, it's more accurate than shooter
	if (!isNull _instigator) then {
		_shooter = _instigator;
	};
	// If the shooter is still unknown, highly reduce damage
	if (isNull _shooter) exitWith {_damage/10};
	private _shooterSide = _shooter getVariable ["gameSide", "attackers"];
	private _unitSide = _unit getVariable ["gameSide", "defenders"];
	private _grenades = ["lib_us_mk_2", "lib_shg24", "lib_rg42", "lib_millsbomb"];
	if (_damage >= 1 && {(toLower _projectile) in _grenades}) then {
		_unit setVariable ["grenade_kill", _projectile];
	};
	// Is the shooter on the opposite side of the victim and is the victim alive?
	if ((_shooterSide != _unitSide) && _unit getVariable ["isAlive", true]) then {
		//If critical damage to the head kill the victim and reward the shooter with HS bonus
		if (_damage >= 0.3 && {_hitSelection in ["head", "face_hub"]}) then {
			// Has the HS kill already been awarded?
			if (!(_unit getVariable ["wasHS", false])) then {
				_unit setVariable ["wasHS", true];
        _damage = 1 + _damage;
			};
		} else {
			// Get the last weapon the shooter fired
			private _shooterWeapon = _shooter getVariable ["lastWeaponFired", ""];
			// Was it not defined? Get the current one, we might be lucky
			if (_shooterWeapon isEqualTo "") then {
				_shooterWeapon = currentWeapon _shooter;
			};
			// Is it not a listed weapon?
			private _isWeaponListed = isClass(missionConfigFile >> "Unlocks" >> _shooterSide >> _shooterWeapon);
			// If it is listed, get the multiplier, else don't do anything and use 1
			private _damageMultiplier = if (_isWeaponListed) then {getNumber(missionConfigFile >> "Unlocks" >> _shooterSide >> _shooterWeapon >> "damageMultiplier")} else {1};
			// Handle only the global hit part
			if (_hitSelection isEqualTo "") then {
				// Set the damage we are dealing according to the weapon that got us
				_damage = (damage _unit) + (_damage * _damageMultiplier);
				// If the damage is non fatal
				if (_damage > 0 && _damage < 1) then {
					// Display hit marker
					_damage remoteExec ["client_fnc_MPHit", _shooter];
				};
			} else {
				// Don't damage the part if it's not the global hit part
				_damage = _unit getHit _hitSelection;
			};
		};
	};

	// If instead the shooter is on the same side as the victim (friendly fire) and it's not suicide
	if (((_shooterSide == _unitSide) && {_shooter != _unit})) then {
		// Disable damage
		_damage = damage _unit;
	};
 _damage
}];

// Getin Eventhandler for vehicles
player addEventHandler ["GetInMan", {
	private _unit = param[0, objNull, [objNull]];
	private _vehicle = param[2, objNull, [objNull]];
	_vehicle allowDamage true;

	_vehicle enableSimulation true;

	if (_vehicle isKindOf "Air") then {
		private _fuelTime = getNumber(missionConfigFile >> "Vehicles" >> "Plane" >> "fuelTime");
		[format["YOU HAVE %1 SECONDS WORTH OF FUEL, BE QUICK!", _fuelTime]] call client_fnc_displayInfo;
		_vehicle setVectorUp [0,0,1];
		private _velocity = (vectorDir _vehicle) vectorMultiply 50;
		_vehicle setVelocity _velocity;
	};

	/* if ((count (crew _vehicle) > 0) && {_vehicle getVariable ["last_man", objNull] != objNull}) then {
		_vehicle setVariable ["last_man", objNull, true];
	}; */

	_vehicle removeAllEventHandlers "Killed";
	_vehicle addEventHandler ["Killed", {
		params ["_vehicle", "_killer", "_instigator"];

		if (!isNull _instigator) then {
			_killer = _instigator;
		};

		if (!isPlayer _killer) then {
			_killer = _vehicle getVariable ["last_hit_source", objNull];
		};

		if (isNull _killer) exitWith {};

		if ((local _vehicle) && {player getVariable ["side", sideUnknown] != _killer getVariable ["side", sideUnknown]}) exitWith {
			private _vehType = typeOf _vehicle;
			private _planes = getArray(missionConfigFile >> "Vehicles" >> "planes");
			private _htanks = getArray(missionConfigFile >> "Vehicles" >> "htanks");
			private _ltanks = getArray(missionConfigFile >> "Vehicles" >> "ltanks");
			private _apc = getArray(missionConfigFile >> "Vehicles" >> "apc");
			private _ifv = getArray(missionConfigFile >> "Vehicles" >> "ifv");
			if (_vehType in _apc || _vehType in _ifv) exitWith {
				[200, true, "ARMORED CAR"] remoteExec ["client_fnc_vehicleDisabled", _killer];
			};
			if (_vehType in _ltanks) exitWith {
				[300, true, "LIGHT TANK"] remoteExec ["client_fnc_vehicleDisabled", _killer];
			};
			if (_vehType in _htanks) exitWith {
				[500, true, "MEDIUM TANK"] remoteExec ["client_fnc_vehicleDisabled", _killer];
			};
			if (_vehType in _planes) exitWith {
				[500, true, "AIRPLANE"] remoteExec ["client_fnc_vehicleDisabled", _killer];
			};
			[100, true, "VEHICLE"] remoteExec ["client_fnc_vehicleDisabled", _killer];
		};
 }];

	// Always make sure we have an hit eventhandler
	_vehicle removeAllEventHandlers "HandleDamage";
	_vehicle addEventHandler ["HandleDamage", {
		params ["_vehicle", "_hitSelection", "_damage", "_shooter", "_projectile"];
  	private _rockets = ["LIB_60mm_M6", "LIB_R_88mm_RPzB", "LIB_1Rnd_89m_PIAT"];
		if (_projectile in _rockets) then {
			_damage = damage _vehicle + (_damage*2);
		};
		_damage
	}];

	_vehicle removeAllEventHandlers "Hit";
	_vehicle addEventHandler ["Hit", {
		params ["_vehicle", "_source", "_damage", "_shooter"];
		if (!isNull _shooter) then {
			_source = _shooter;
		};
		if ((!isNull _source) && (_damage > 0.1) && {_source != player}) then {
			0.1 remoteExec ["client_fnc_MPHit", _source];
		};

		if (_vehicle getVariable ["disabled", false]) exitWith {};

		if (local _vehicle && {(player getVariable ["side", sideUnknown]) != (_source getVariable ["side", sideUnknown])} && {!(canMove _vehicle)}) then {
			_vehicle setVariable ["disabled", true, true];
			if (_vehicle isKindOf "Tank") then {
				200 remoteExec ["client_fnc_vehicleDisabled", _source];
			};
			if (_vehicle isKindOf "Car") then {
				100 remoteExec ["client_fnc_vehicleDisabled", _source];
			};
			if (isPlayer _source && {_damage > 0.01}) then {
				_vehicle setVariable ["last_hit_source", _source, true];
			};
		};
	}];

	if (_vehicle isKindOf "Air") then {
		if ((typeOf _vehicle) isEqualTo "NonSteerable_Parachute_F") then {
			[_vehicle] spawn {
				private _vehicle = param[0, objNull, [objNull]];
				waitUntil{(getPosATL _vehicle) select 2 < 3};
				deleteVehicle _vehicle;
			};
		} else {
			[_vehicle] spawn {
				private _vehicle = param[0, objNull, [objNull]];
				private _fuelTime = getNumber(missionConfigFile >> "Vehicles" >> "Plane" >> "fuelTime");
				uiSleep (_fuelTime - 10);
				private _timeLeft = diag_tickTime + 10;
				while {_timeLeft > diag_tickTime && ((vehicle player) isEqualTo _vehicle)} do {
					[format["YOU'LL RUN OUT OF FUEL IN %1 SECONDS<br /><t size='1.25'>PREPARE TO BAIL OUT!</t>", round (_timeLeft - diag_tickTime)]] call client_fnc_displayError;
					uiSleep 1;
				};
				if ((vehicle player) isEqualTo _vehicle) then {
					_vehicle setFuel 0;
				};
			};
		};
	};
}];

player addEventHandler ["GetOutMan", {
	private _vehicle = param[2, objNull, [objNull]];
	if (count (crew _vehicle) == 0) then {
		_vehicle setVariable ["last_man", player, true];
	};
	private _pos = getPos player;
	if ((_vehicle isKindOf "Air") && (_pos select 2 > 5)) then {
		private _velPlayer = (velocity player) vectorMultiply 0.1;
		player setVelocity _velPlayer;
		if (player getVariable ["hasChute", true]) then {
			["PRESS <t size='1.5'>[SPACE BAR]</t> TO OPEN YOUR PARACHUTE!"] call client_fnc_displayInfo;
		};
	};
}];
true
