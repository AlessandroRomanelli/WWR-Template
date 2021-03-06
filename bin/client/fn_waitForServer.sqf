scriptName "fn_waitForServer";
/*--------------------------------------------------------------------
	Author: A. Roman
    File: fn_waitForServer.sqf

    Written by A. Roman
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_waitForServer.sqf"
#include "..\utils.h"

#define HEX_GREEN "#00FF00"
#define HEX_YELLOW "#FFFF00"
#define HEX_RED "#FF0000"

#define KEY_SPACE 57

if (isServer && !hasInterface) exitWith {};

player setVariable ["playerInitOK", true, true];
// Apparently the server isnt done selecting a map yet
60000 cutRsc ["waitingForPlayers", "PLAIN"];

REMOVE_EXISTING_MEH("EachFrame", cl_waitingThread);
VARIABLE_DEFAULT(sv_setting_MinPlayers, 0);
cl_waitingThread = addMissionEventHandler["EachFrame", {
  private _display = uiNamespace getVariable ["waitingForPlayers", displayNull];
  private _title = _display displayCtrl 1100;
  private _connectedCtrl = _display displayCtrl 1101;
  private _readyCtrl = _display displayCtrl 1102;
  private _required = _display displayCtrl 1103;
  private _players = (WEST countSide allPlayers) + (EAST countSide allPlayers);
  private _readyPlayers = {_x getVariable ["playerInitOK", false]} count allPlayers;
  private "_color";
  if (_readyPlayers < round(_players*0.4)) then {
    _color = HEX_RED;
  } else {
    if (_readyPlayers >= round(_players*0.4) && _readyPlayers < round(_players*0.8)) then {
      _color = HEX_YELLOW;
    } else {
      _color = HEX_GREEN;
    };
  };
  private _enoughPlayers = count allPlayers > sv_setting_MinPlayers;
  _title ctrlSetStructuredText (parseText (["WAITING FOR MORE PLAYERS", "WAITING FOR PLAYERS TO LOAD"] select _enoughPlayers));
  _connectedCtrl ctrlSetStructuredText (parseText (format ["CONNECTED: %1", _players]));
  _readyCtrl ctrlSetStructuredText (parseText (format ["READY: <t color='%2'>%1</t>", _readyPlayers, _color]));
  _required ctrlSetStructuredText (parseText (format ["REQUIRED: <t color='%2'>%1</t>", sv_setting_MinPlayers, [HEX_RED, HEX_GREEN] select _enoughPlayers]));
}];

if (!isNil "cl_admin_key_h") then {
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", cl_admin_key_h];
};
cl_admin_key_h = (findDisplay 46) displayAddEventHandler ["KeyDown", {
	private _DIKcode = _this select 1;
	private _h = false;
	if (_DIKcode == KEY_ESC) then {
		[] call client_fnc_displayAdminArea;
		_h = true;
	};
	_h
}];

waitUntil{sv_gameStatus isEqualTo 2};

(findDisplay 46) displayRemoveEventHandler ["KeyDown", cl_admin_key_h];
cl_admin_key_h = nil;

removeMissionEventHandler ["EachFrame", cl_waitingThread];

cl_waitingThread = nil;

// Cycle..
60000 cutText ["", "PLAIN"];

[] call client_fnc_spawn;
