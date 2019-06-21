scriptName "fn_waitForPlayers";
/*--------------------------------------------------------------------
	Author: A. Roman
    File: fn_waitForPlayers.sqf

    Written by A. Roman
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_waitForPlayers.sqf"

private _isDebug = (["Debug", 0] call BIS_fnc_getParamValue) == 1;

if (!_isDebug && sv_gameCycle == 0) then {
  private _minPlayers = ["MinPlayers", 4] call BIS_fnc_getParamValue;
  waitUntil{(playersNumber WEST + playersNumber INDEPENDENT) >= _minPlayers};
  private _then = diag_tickTime;
  waitUntil{ (diag_tickTime - _then >= 60) || {({_x getVariable ["playerInitOK", false]} count allPlayers) >= (floor ((playersNumber WEST + playersNumber INDEPENDENT)*0.8))} };
  uiSleep 1;
};
true