scriptName "fn_onEachFramePreparation";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_onEachFramePreparation.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_onEachFramePreparation.sqf"

// Inline function to determine icon
_getIcon = {
	_unit = param[0,objNull,[objNull]];
	if (_unit getVariable ["class",""] == "medic") exitWith {"pictures\medic.paa"};
	if (_unit getVariable ["class",""] == "engineer") exitWith {"pictures\engineer.paa"};
	if (_unit getVariable ["class",""] == "support") exitWith {"pictures\support.paa"};
	if (_unit getVariable ["class",""] == "recon") exitWith {"pictures\recon.paa"};
	"pictures\assault.paa";
};

// Variables
cl_onEachFrame_squad_members = [];
cl_onEachFrame_squad_beacons = [];
cl_onEachFrame_team_members = [];
cl_onEachFrame_team_reviveable = [];

while {true} do {
	// Temp vars
	_squad_members = [];
	_squad_beacons = [];
	_team_members = [];
	_toBeRevived = [];

	// Fill with data
	{
		_name = (_x getVariable ["name", "ERROR: No Name"]);
		if (_x != player) then {
			if (side (group _x) == side (group player)) then {
				if ((group _x) == (group player)) then {
					// Does this unit provide a beacon
					if (cl_inSpawnMenu) then {
						_beacon = _x getVariable ["assault_beacon_obj", objNull];
						if (!isNull _beacon) then {
							_squad_beacons pushBack [(getPosATLVisual _beacon), format["%1's Spawnbeacon", _name]];
						};
					};

					// Is he alive
					if (alive _x) then {
						// The player should not be on the debug island
						if (_x distance cl_safePos > 200) then {
							_alpha = [0.75, 0.55] select (_x distance player > 50);
							_icon = [_x] call _getIcon;
							_squad_members pushBack [_x, _name, (MISSOIN_ROOT+_icon), _alpha];
						};
					};
				} else {
					if (_x distance cl_safePos > 200 && alive _x) then {
						if (cl_inSpawnMenu || ((vehicle player) isKindOf "Air")) then {
							_team_members pushBack [_x, _name, (MISSON_ROOT+"pictures\teammate.paa")]];
						} else {
							// Only teammates within 100 meters
							if (_x distance player < 100 || _x == (driver vehicle cursorTarget) || _x == (driver vehicle cursorTarget)) then {
								_team_members pushBack [_x, _name, (MISSON_ROOT+"pictures\teammate.paa")];
							};
						};
					};
				};
			};
		};
	} forEach AllUnits;

	// Own beacon?
	if (cl_inSpawnMenu) then {
		_myBeacon = player getVariable ["assault_beacon_obj", objNull];
		if (!isNull _myBeacon) then {
			_squad_beacons pushBack [(getPosATLVisual _myBeacon), format["%1's Spawnbeacon", (player getVariable ["name", "ERROR: No Name"])]];
		};
	};

	// Medics
	if (cl_class == "medic") then {
		{
			if (alive player && _x distance player < 25) then {
				if (_x getVariable ["side", sideUnknown] == playerSide) then {
					_toBeRevived pushBack [_x, format["%1pictures\revive.paa",MISSION_ROOT]];
				};
			};
		} forEach AllDeadMen;
	};

	// Overwrite variables
	cl_onEachFrame_squad_members = _squad_members;
	cl_onEachFrame_squad_beacons = _squad_beacons;
	cl_onEachFrame_team_members = _team_members;
	cl_onEachFrame_team_reviveable = _toBeRevived;
};
