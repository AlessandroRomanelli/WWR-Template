scriptName "fn_generateGroupName";
/*--------------------------------------------------------------------
	Author: A. Roman
    File: fn_generateGroupName.sqf

    Written by A.Roman
  	You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_generateGroupName.sqf"

params ["_group","_faction"];

waitUntil {isNil "sv_grpName_lock" || {sv_grpName_lock}};
sv_grpName_lock = true;

private _usNames =  ["Able","Baker","Charlie","Dog","Easy"];
private _gerNames = ["Anton","Bertha","Casar","Dora","Emil"];
private _sovNames = ["Alexey","Boris","Maxim","Dmitry","Filipp"];

{
  if (isNil _x) then {
    missionNamespace setVariable [_x, 0];
  };
} forEach ["sv_grpName_idx_US", "sv_grpName_idx_GER", "sv_grpName_idx_SOV"];

private ["_currentName", "_size"];

if (_faction == "US" || _faction == "UK") then {
  _size = count _usNames;
  sv_grpName_idx_US;
  _currentName = format ["%1-%2", _usNames select (sv_grpName_idx_US % _size), floor(sv_grpName_idx_US / _size) + 1];
  sv_grpName_idx_US = sv_grpName_idx_US + 1;
};

if (_faction == "GER") then {
  _size = count _gerNames;
  sv_grpName_idx_GER;
  _currentName = format ["%1-%2", _gerNames select (sv_grpName_idx_GER % _size), floor(sv_grpName_idx_GER / _size) + 1];
  sv_grpName_idx_GER = sv_grpName_idx_GER + 1;
};

if (_faction == "SOV") then {
  _size = count _sovNames;
  sv_grpName_idx_SOV;
  _currentName = format ["%1-%2", _sovNames select (sv_grpName_idx_SOV % _size), floor(sv_grpName_idx_SOV / _size) + 1];
  sv_grpName_idx_SOV = sv_grpName_idx_SOV + 1;
};

_group setGroupIdGlobal [_currentName];

sv_grpName_lock = false;
true
