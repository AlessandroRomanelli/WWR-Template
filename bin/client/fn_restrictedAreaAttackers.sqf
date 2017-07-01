scriptName "fn_restrictedAreaAttackers";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_restrictedArea.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_restrictedAreaAttackers.sqf"

_entryTime = diag_tickTime;

// Wait until time is out or were out again
waitUntil {((diag_tickTime - _entryTime) > 15) || (player getVariable ["gameSide", "defenders"] == "attackers") && !(vehicle player in (list warnAreaAtk))};

// Evaluate
if (diag_tickTime - _entryTime > 15) then {
	player setDamage 1;
	["You have been killed for remaining in a restricted area"] spawn client_fnc_displayError;
};

// Delete myself ay!
cl_restrictedAreaAttackers_thread = nil;
