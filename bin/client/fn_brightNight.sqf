scriptName "fn_brightNight";
/*--------------------------------------------------------------------
	Author: Champ (ofpectag: CHBN)
    File: fn_brightNight.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/

#define __filename "fn_brightNight.sqf"
if (isServer && !hasInterface) exitWith {};

[] spawn {
	private _adjustLight = {
		CHBN_adjustBrightness = CHBN_adjustBrightness max 0 min 1;
		private _brightness = if (CHBN_adjustBrightness > 0) then {200 * abs (1 - (2 ^ CHBN_adjustBrightness))} else {0};
		CHBN_light setLightAttenuation [10e10,(30000 / (_brightness max 10e-10)),4.31918e-005,4.31918e-005];
		CHBN_light setLightAmbient CHBN_adjustColor;
	};

	waitUntil {time > 0};
	if (missionNamespace getVariable ["CHBN_running",false]) exitWith {systemChat "CHBN script is running. Addon disabled."};
	CHBN_running = true;

	CHBN_adjustBrightness = missionNamespace getVariable ["CHBN_adjustBrightness",0.5];
	CHBN_adjustColor = missionNamespace getVariable ["CHBN_adjustColor",[0.3,0.5,1]];

	if (!isNil "CHBN_light") then {deleteVehicle CHBN_light};
	CHBN_light = "#lightpoint" createVehicleLocal [0,0,0];
	CHBN_light setLightBrightness 1;
	CHBN_light setLightDayLight false;
	call _adjustLight;

	for "_i" from 0 to 1 step 0 do {
		private _adjustBrightness = CHBN_adjustBrightness;
		private _adjustColor = CHBN_adjustColor;
		waitUntil {!(_adjustBrightness isEqualTo CHBN_adjustBrightness) || !(_adjustColor isEqualTo CHBN_adjustColor)};
		call _adjustLight;
	};
};
