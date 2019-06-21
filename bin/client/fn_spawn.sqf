scriptName "fn_spawn";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_spawn.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_spawn.sqf"
if (isServer && !hasInterface) exitWith {};


// Not too fast
if (diag_tickTime - (missionNamespace getVariable ["cl_spawnmenu_lastStartTick", 0]) < 1) exitWith {};
cl_spawnmenu_lastStartTick = diag_tickTime;

cl_inSpawnMenu = true;

// Set player to safe location
player setPos cl_safePos;

player setVariable ["wasHS", false];


// Strip player
removeUniform player;
removeBackpackGlobal player;
removeAllWeapons player;
removeGoggles player;
removeHeadgear player;
removeAllAssignedItems player;
removeVest player;

// Mute sound
//0 fadeSound 0;
0 fadeRadio 0;

// No damage
player allowDamage false;

// Reset array of assists
cl_assistsInfo = [];

// Delete layers that may be still there
60000 cutRsc ["default", "PLAIN"];
60001 cutRsc ["default", "PLAIN"];

400 cutRsc ["rr_objective_gui","PLAIN"];
// Setup the objective icon at the top
if (player getVariable "gameSide" == "defenders") then {
	disableSerialization;
	private _d = uiNamespace getVariable ["rr_objective_gui", displayNull];
	(_d displayCtrl 0) ctrlSetText WWRUSH_ROOT+"pictures\objective_defender.paa";
};

// If the server will restart after this round, display a visual warning at the top right
if (sv_gameCycle >= ((["RotationsPerMatch", 2] call BIS_fnc_getParamValue) - 1)) then {
	15 cutRsc ["rr_topRightWarning", "PLAIN"];
	((uiNamespace getVariable ["rr_topRightWarning", displayNull]) displayCtrl 0) ctrlSetStructuredText parseText "<t size='1.2' color='#FE4629' shadow='2' align='right'>LAST ROUND BEFORE MAP CHANGE</t>"
};


//Keeping the role updated
if (sv_gameCycle % 2 == 0) then {
	if (playerSide == WEST) then {
		player setVariable ["gameSide", "defenders", true];
	} else {
		player setVariable ["gameSide", "attackers", true];
	};
} else {
	if (playerSide == WEST) then {
		player setVariable ["gameSide", "attackers", true];
	} else {
		player setVariable ["gameSide", "defenders", true];
	};
};

private _marker1 = createMarkerLocal ["mobile_respawn_defenders",[0,0]];
if (_marker1 != "") then {
	_marker1 setMarkerTypeLocal (["o_unknown","b_unknown"] select ((player getVariable "gameSide") == "defenders"));
	_marker1 setMarkerTextLocal " Defenders HQ";
};

private _marker2 = createMarkerLocal ["mobile_respawn_attackers",[0,0]];
if (_marker2 != "") then {
	_marker1 setMarkerTypeLocal (["b_unknown","o_unknown"] select ((player getVariable "gameSide") == "defenders"));
	_marker2 setMarkerTextLocal " Attackers HQ";
};

// Markers
[] call client_fnc_updateMarkers;

// Hide hud
showHUD [true,false,false,false,false,true,false,true,false];

// Run equipment checks
[] call client_fnc_getLoadedEquipment;
[] call client_fnc_validateEquipment;


// Disable voice channels
[] call client_fnc_disableChannels;

removeUniform player;
removeVest player;
removeHeadgear player;
removeBackpack player;

// Markers
[playArea] call client_fnc_updateRestrictions;


// Wait until the objectives are available
waitUntil {!isNil "sv_stage1_obj" && !isNil "sv_stage2_obj" && !isNil "sv_stage3_obj" && !isNil "sv_stage4_obj"};

private _objectives = [sv_stage1_obj, sv_stage2_obj, sv_stage3_obj, sv_stage4_obj];
{
	if (_forEachIndex > 0) then {
		_x setVariable ["pre_stage", format["Stage%1", _forEachIndex]];
	};
	_x setVariable ["cur_stage", format["Stage%1", _forEachIndex + 1]];
	if (_forEachIndex != (count _objectives - 1)) then {
		_x setVariable ["nex_stage", format["Stage%1", _forEachIndex + 2]];
	};
} forEach _objectives;

// Get cam pos for spawn menu cam
private _stage = sv_cur_obj getVariable ["cur_stage", "Stage1"];
private _side = player getVariable "gameSide";
private _pos = getArray(missionConfigFile >> "MapSettings" >> sv_mapSize >> "Stages" >> _stage >> "Spawns" >> _side >> "HQSpawn" >> "positionATL");

// Determine point between current pos and target pos
private _targetPos = [_pos, getPos sv_cur_obj] call client_fnc_getSectionCenter;
private _height = round (100*log(_pos distance2D sv_cur_obj))+50;
// Set cam pos height
_pos set[2, _height];

// Display all buildings
setObjectViewDistance 1000;
setViewDistance 1250;

// DUMMY WEAPON SO THE PLAYER DOESNT PLAY THE ANIMATION WHEN HE SPAWNS
removeAllWeapons player;

// Create spawn cam
private _created = false;
if (isNil "cl_spawnmenu_cam") then {
	diag_log "SPAWNMENU_CAM WAS NIL";
	cl_spawnmenu_cam = "camera" camCreate (getPos player);
	cl_spawnmenu_cam cameraEffect ["Internal", "Back"];
	cl_spawnmenu_cam camSetFOV .90;
	cl_spawnmenu_cam camSetFocus [150, 1];
	cl_spawnmenu_cam camCommit 0;
	_created = true;
} else {
	if (isNull cl_spawnmenu_cam) then {
		diag_log "SPAWNMENU_CAM WAS NULL";
		cl_spawnmenu_cam = "camera" camCreate (getPos player);
		cl_spawnmenu_cam cameraEffect ["Internal", "Back"];
		cl_spawnmenu_cam camSetFOV .90;
		cl_spawnmenu_cam camSetFocus [150, 1];
		cl_spawnmenu_cam camCommit 0;
		_created = true;
	} else {
		diag_log "SPAWNMENU_CAM WAS NEITHER";
		cl_spawnmenu_cam camSetFOV .90;
		cl_spawnmenu_cam camSetFocus [150, 1];
		cl_spawnmenu_cam camCommit 0.5;
	};
};
uiSleep 0.05;
showCinemaBorder false;
cameraEffectEnableHUD true;

cl_spawnmenu_cam camPreparePos _pos;
cl_spawnmenu_cam camPrepareTarget _targetPos;

// If the camera is new, commit instantly, otherwise zoom out slowly
if (_created) then {
	cl_spawnmenu_cam camCommitPrepared 0;
	60000 cutRsc ["rr_spawn","PLAIN"];
} else {
	cl_spawnmenu_cam camCommitPrepared 1.5;
};

// Create spawn dialog
createDialog "rr_spawnmenu";

private _menuDisplay = (findDisplay 5000);

// Disable ESC
_menuDisplay displayAddEventHandler ["KeyDown",{
	private _handled = false;
	if ((_this select 1) == 1) then {
		_handled = true; // Block ESC
	};
	_handled;
}];

// Blurry background?
if (getNumber(missionConfigFile >> "GeneralConfig" >> "PostProcessing") == 1) then {
	["DynamicBlur", 400, [0.5]] spawn {
		params ["_name", "_priority", "_effect"];
		while {
			cl_spawnmenu_blur = ppEffectCreate [_name, _priority];
			cl_spawnmenu_blur < 0
		} do {
			_priority = _priority + 1;
		};
		cl_spawnmenu_blur ppEffectEnable true;
		cl_spawnmenu_blur ppEffectAdjust _effect;
		cl_spawnmenu_blur ppEffectCommit 0.1;
	};
};

// Populate the structured texts
[] call client_fnc_populateSpawnMenu;

scaleCtrl = {
	params [["_ctrl", controlNull, [controlNull]],["_factor", 0, [0]], ["_time", 0, [0]]];
	private _ctrlPos = ctrlPosition _ctrl;
	private _delta = ((_ctrlPos select 2)*(_factor - 1))/2;
	private _newPos = [(_ctrlPos select 0) - _delta, (_ctrlPos select 1) - _delta, (_ctrlPos select 2)*_factor, (_ctrlPos select 3)*_factor];
  _ctrl ctrlSetPosition _newPos;
	_ctrl ctrlCommit _time;
	true
};

// TODO: Move this to PFH
animateCtrl = {
	params [["_objective", objNUll, [objNull]],["_ctrl", controlNull, [controlNull]],["_factor", 0, [0]], ["_time", 0, [0]]];
	private _ctrlPos = ctrlPosition _ctrl;
	if (!isNil "cl_objectiveSpawnAnimation") exitWith {};
		cl_objectiveSpawnAnimation = true;
	while {(str _objective) isEqualTo (str sv_cur_obj)} do {
		[_ctrl, _factor, _time] call scaleCtrl;
		uiSleep (_time + 0.1);
		_ctrl ctrlSetPosition _ctrlPos;
		_ctrl ctrlCommit _time;
		uiSleep (_time + 0.1);
	};
	_ctrl ctrlSetPosition _ctrlPos;
	_ctrl ctrlCommit 0;
	cl_objectiveSpawnAnimation = nil;
	[] call updateObjectiveProgress;
};
// TODO: Move this to PFH
updateObjectiveProgress = {
	private _display = findDisplay 5000;
	for "_i" from 1 to 4 do {
		private _idc = 1200 + _i;
		private _ctrlObj = _display displayCtrl _idc;
		private _IntToAlpha = ["", "A", "B", "C", "D"];
		private _playerSide = player getVariable ["gameSide", "defenders"];
		private _picturePath = WWRUSH_ROOT+"pictures\"+(format["obj_%1_%2", _IntToAlpha select _i, _playerSide])+".paa";
		private _objective = missionNamespace getVariable [format["sv_stage%1_obj", _i], objNull];
		_ctrlObj ctrlSetText _picturePath;
		if !(_objective isEqualTo sv_cur_obj) then {
			_ctrlObj ctrlSetTextColor [1,1,1,0.25];
		} else {
			_ctrlObj ctrlSetTextColor [1,1,1,1];
			[_objective, _ctrlObj, 1.1, 0.5] spawn animateCtrl;
		};
		if ((_objective getVariable ["status", -1]) isEqualTo 3) then {
			_ctrlObj ctrlSetTextColor [-1, -1, -1, 0.25];
		};
	};
	true
};

[_menuDisplay] spawn updateObjectiveProgress;

(_menuDisplay displayCtrl 1200) ctrlSetFade 1;
(_menuDisplay displayCtrl 1200) ctrlCommit 0;

{
	(_menuDisplay displayCtrl _x) ctrlEnable true;
	(_menuDisplay displayCtrl _x) ctrlAddEventHandler["MouseEnter", {
		private _display = findDisplay 5000;
		(_display displayCtrl 1200) ctrlSetFade 0;
		(_display displayCtrl 1200) ctrlCommit 0.25;
	}];
	(_menuDisplay displayCtrl _x) ctrlAddEventHandler["MouseExit", {
		private _display = findDisplay 5000;
		(_display displayCtrl 1200) ctrlSetFade 1;
		(_display displayCtrl 1200) ctrlCommit 0.5;
	}];
} forEach [1201,1202,1203,1204];

// Enable spawn buttons // REDONE WITH LISTBOX UPDATE // SEE SPAWNMENU_LOADCLASSES
(_menuDisplay displayCtrl 302) ctrlAddEventHandler ["ButtonDown",{
	profileNamespace setVariable ["rr_class_preferred", cl_class];
	[] call client_fnc_spawnMenu_getClassAndSpawn
}];

// Enable abort button
(_menuDisplay displayCtrl 303) ctrlAddEventHandler ["ButtonDown",{
	[] call client_fnc_saveStatistics;
	endMission "MatchLeft";
}];

// Add eventhandlers to the dialog and hide the weapon selection
cl_spawnmenu_currentWeaponSelectionState = 0; // Nothing open
disableSerialization;

{(_menuDisplay displayCtrl _x) ctrlSetStructuredText parseText "<t size='0.75' color='#ffffff'' shadow='2' font='PuristaMedium' align='center'>[CLICK ABOVE TO OPEN]</t>"} forEach [2001,2002];

// Event handlers for hover actions
{
	(_menuDisplay displayCtrl _x) ctrlRemoveAllEventHandlers "ButtonDown";
	(_menuDisplay displayCtrl _x) ctrlRemoveAllEventHandlers "MouseEnter";
	(_menuDisplay displayCtrl _x) ctrlRemoveAllEventHandlers "MouseExit";
	(_menuDisplay displayCtrl _x) ctrlAddEventHandler ["MouseEnter", {
		private _display = findDisplay 5000;
		if ((_this select 0) isEqualTo (_display displayCtrl 15)) then {
			if (cl_spawnmenu_currentWeaponSelectionState != 1) then {
				(_display displayCtrl 207) ctrlSetBackgroundColor [0.725,0.588,0.356,0.8];
			};
		} else {
			private _secondaryWeapons = cl_equipConfigurations select {(getText(missionConfigFile >> "Unlocks" >> player getVariable "gameSide" >> _x >> "type")) == "secondary"};
			if (cl_spawnmenu_currentWeaponSelectionState != 2 && {count _secondaryWeapons != 0}) then {
				(_display displayCtrl 209) ctrlSetBackgroundColor [0.725,0.588,0.356,0.8];
			};
		};
	}];
	(_menuDisplay displayCtrl _x) ctrlAddEventHandler ["MouseExit", {
		private _display = findDisplay 5000;
		if (cl_spawnmenu_currentWeaponSelectionState != 1) then {
			(_display displayCtrl 207) ctrlSetBackgroundColor [0.12,0.14,0.16,0.8];
		};
		if (cl_spawnmenu_currentWeaponSelectionState != 2) then {
			(_display displayCtrl 209) ctrlSetBackgroundColor [0.12,0.14,0.16,0.8];
		};
	}];
} forEach [15,16];

(_menuDisplay displayCtrl 15) ctrlAddEventHandler ["ButtonDown", {
	[] call client_fnc_spawnMenu_displayPrimaryWeaponSelection;
}];

(_menuDisplay displayCtrl 16) ctrlAddEventHandler ["ButtonDown", {
	private _secondaryWeapons = cl_equipConfigurations select {(getText(missionConfigFile >> "Unlocks" >> player getVariable "gameSide" >> _x >> "type")) == "secondary"};
	if (count _secondaryWeapons != 0) then {
		[] call client_fnc_spawnMenu_displaySecondaryWeaponSelection;
	};
}];

// Activate weapons' background event handler
/* (_menuDisplay displayCtrl 2) ctrlEnable true; */

// Close menu upon mouse exit
/* (_menuDisplay displayCtrl 2) ctrlAddEventHandler ["MouseExit", {
	if (cl_spawnmenu_currentWeaponSelectionState != 0) then {
		if (cl_spawnmenu_currentWeaponSelectionState == 1) then {
			[] spawn client_fnc_spawnMenu_displayPrimaryWeaponSelection;
		} else {
			[] spawn client_fnc_spawnMenu_displaySecondaryWeaponSelection;
		};
	};
}]; */

/* (_menuDisplay displayCtrl 12) ctrlAddEventHandler ["ButtonDown",{[] spawn client_fnc_spawnMenu_displayPrimaryAttachmentSelection;}];
(_menuDisplay displayCtrl 13) ctrlAddEventHandler ["ButtonDown",{[] spawn client_fnc_spawnMenu_displaySecondaryAttachmentSelection;}]; */
(_menuDisplay displayCtrl 100) ctrlAddEventHandler ["ButtonDown",{
	[] call client_fnc_spawnMenu_displayGroupManagement;
}];

// Hide the weapon selection listbox and its background + the attachment listboxes and their backgrounds
{
	(_menuDisplay displayCtrl _x) ctrlShow false;
} forEach [
	2,3,
	20,21,22,25,23,24,26,27,28,29
];

[false] spawn client_fnc_spawnMenu_loadClasses;
[] spawn {
	[] call client_fnc_loadSpawnpoints;
	private _display = findDisplay 5000;
	private _spawnCtrl = _display displayCtrl 8;
	waitUntil {(lbSize _spawnCtrl) > 0};
	_spawnCtrl lbSetCurSel 0;
};

cl_fnc_follow_unit = {
	params ["_unit"];
	while {cl_inSpawnMenu && {!isNull _unit} && {alive _unit}} do {
		private _newPos = getPosATL _unit;
		private _height = round (100*log(_newPos distance2D sv_cur_obj))+50;
		private _targetPos = [_newPos, getPos sv_cur_obj] call client_fnc_getSectionCenter;
		_newPos set [2, _height];
		cl_spawnmenu_cam camSetPos _newPos;
		cl_spawnmenu_cam camSetTarget _targetPos;
		cl_spawnmenu_cam camCommit 1;
		waitUntil {camCommitted cl_spawnmenu_cam};
	};

};

private _spawnCtrl = _menuDisplay displayCtrl 8;
_spawnCtrl ctrlAddEventHandler ["MouseButtonClick", {
	params ["_control"];
	private _spawnDisplay = findDisplay 5000;
	private _spawnName = _control lbData (lbCurSel _control);
	if ((_control lbValue (lbCurSel _control)) == -1) then {
		private _stage = sv_cur_obj getVariable ["cur_stage", "Stage1"];
		private _side = player getVariable ["gameSide", ""];
		if (_side == "" || _stage == "") exitWith {};
		private _newPos = getArray(missionConfigFile >> "MapSettings" >> sv_mapSize >> "Stages" >> _stage >> "Spawns" >> _side >> _spawnName >> "positionATL");
		private _targetPos = [_newPos, getPos sv_cur_obj] call client_fnc_getSectionCenter;
		private _height = round (100*log(_newPos distance2D sv_cur_obj))+50;
		_newPos set [2, _height];
		cl_spawnmenu_cam camSetPos _newPos;
		cl_spawnmenu_cam camSetTarget _targetPos;
		cl_spawnmenu_cam camCommit 1;
	} else {
		private _unit = objectFromNetId _spawnName;
		if (!isNil "cl_cam_follow_unit") then {
			terminate cl_cam_follow_unit;
		};
		cl_cam_follow_unit = [_unit] spawn cl_fnc_follow_unit;
	};

	(_spawnDisplay displayCtrl 9) lbSetCurSel -1;
}];

private _vehiclesCtrl = _menuDisplay displayCtrl 9;
_vehiclesCtrl ctrlAddEventHandler ["MouseButtonClick", {
	params ["_control"];
	private _spawnDisplay = findDisplay 5000;
	private _vehName = _control lbData (lbCurSel _control);
	private _newPos = getPosATL (missionNamespace getVariable [_vehName, objNull]);
	private _height = round (100*log(_newPos distance2D sv_cur_obj))+50;
	private _targetPos = [_newPos, getPos sv_cur_obj] call client_fnc_getSectionCenter;
	_newPos set [2, _height];
	cl_spawnmenu_cam camSetPos _newPos;
	cl_spawnmenu_cam camSetTarget _targetPos;
	cl_spawnmenu_cam camCommit 1;
	(_spawnDisplay displayCtrl 8) lbSetCurSel -1;
}];

if (isNil "TEMPWARNING") then {
	createDialog "rr_info_box";
	((findDisplay 10000) displayCtrl 0) ctrlSetStructuredText parseText ("<t size='1' color='#FFFFFF' shadow='2' align='left'>
	<t font='PuristaBold'>WWRush</t>
	<br/>V"+getText(missionConfigFile >> "version")+"
	<br/>
	<br/><t font='PuristaBold'>Changelog</t>
	<br/><a href='https://github.com/AlessandroRomanelli/WWR-Template/blob/master/ChangeLog.md'>Learn more</a>
	<br/>
	<br/><t font='PuristaBold'>Github Repository</t>
	<br/><a href='https://github.com/AlessandroRomanelli/WWR-Template'>Browse Files</a></t>");
	playSound "introSong";
	TEMPWARNING = true;
};

player enableStamina false;
player forceWalk false;
player setSpeaker "NoVoice";

if (isNil "unitMarkers_running") then {
	[] spawn client_fnc_drawMapUnits;
};

private _registeredGroups = ["GetAllGroupsOfSide", [playerSide]] call BIS_fnc_dynamicGroups;
if !((group player) in _registeredGroups) then {
	if !(count _registeredGroups isEqualTo 0) then {
	  {
	    private _privateGroup = _x getVariable ["bis_dg_pri", false];
	    if ((count units _x > 0) && (count units _x < 5) && !_privateGroup) exitWith {
	      ["AddGroupMember", [_x, player]] remoteExec ["BIS_fnc_dynamicGroups", 2];
	    };
	  } forEach _registeredGroups;
	} else {
	  ["RegisterGroup", [group player, player]] remoteExec ["BIS_fnc_dynamicGroups", 2];
	};
};
