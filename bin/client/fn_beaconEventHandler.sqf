scriptName "fn_beaconEventHandler";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_beaconEventHandler.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_beaconEventHandler.sqf"
#include "..\utils.h"
if (isServer && !hasInterface) exitWith {};

WAIT_IF_NOT(cl_init_done);

private _beacon = param[0,objNull,[objNull]];

if (isNull _beacon) exitWith {};
private _owner = [_beacon] call client_fnc_getBeaconOwner;
if (isNull _owner) exitWith {};

// Check if this beacon is on our team
if (_owner getVariable ["side", sideUnknown] == player getVariable ["side", sideUnknown]) exitWith {};

_beacon addEventHandler ["HitPart", {
	_beacon = _this select 0 select 0;

	if (_beacon getVariable ["ran", false]) exitWith {};
	_beacon setVariable ["ran", true];

	// Get owner
	_owner = [_beacon] call client_fnc_getBeaconOwner;

	// Destroy
	deleteVehicle _beacon;

	// Points!
	["<t size='1.3' color='#FFFFFF'>RALLY POINT DESTROYED</t>", 15] call client_fnc_pointfeed_add;
	[15] call client_fnc_addPoints;

	// Send an information to the owner
	["Your rally point has been destroyed"] remoteExecCall ["client_fnc_displayError", _owner];
}];
