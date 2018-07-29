scriptName "fn_refreshTickets";
/*--------------------------------------------------------------------
	Author: Maverick (ofpectag: MAV)
    File: fn_refreshTickets.sqf

	<Maverick Applications>
    Written by Maverick Applications (www.maverick-apps.de)
    You're not allowed to use this file without permission from the author!
--------------------------------------------------------------------*/
#define __filename "fn_refreshTickets.sqf"

_maxTickets = "MaxTickets" call bis_fnc_getParamValue;
_minTickets = "MinTickets" call bis_fnc_getParamValue;

_attackers = (count allPlayers)/2;

_ticketRate = "TicketsRate" call bis_fnc_getParamValue;

_tickets = ceil (_attackers * _ticketRate);

if (_tickets > _maxTickets) then {
  _tickets = _maxTickets;
} else {
  if (_tickets < _minTickets) then {
    _tickets = _minTickets;
  };
};

// Set tickets
sv_tickets = _tickets;
sv_tickets_total = _tickets;

// Broadcast
[["sv_tickets","sv_tickets_total"]] spawn server_fnc_updateVars;
