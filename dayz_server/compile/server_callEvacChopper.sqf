/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* JasonTM									*/
/* Updated for DayZ Epoch 1.0.7+ by JasonTM */
/* Last update: 05-30-2021           		*/
/*------------------------------------------*/

local _chopper = _this select 0;
local _worldSpace = _this select 1;
local _startPos = _worldSpace select 0;
local _dir = _worldSpace select 1;
local _player = _this select 2;
local _clientKey = _this select 3;
local _playerUID = getPlayerUID _player;
local _pos = getPosATL _player;
local _owner = owner _player;

local _exitReason = [_this,"Call_chopper",_pos,_clientKey,_playerUID,_player] call server_verifySender;
if (_exitReason != "") exitWith {diag_log _exitReason};

local _evacZoneReached = false;
local _routeFinished = false;
local _disabled = false;
local _landingZone = objNull;
local _distance = 0;
local _flyHeight = 0;

if (evac_chopperZoneMarker == 1) then {
	_landingZone = "SmokeshellGreen" createVehicle _pos;
	_landingZone setPosATL _pos;
} else {
	_landingZone = "HeliHRescue" createVehicle _pos;
	_landingZone setDir (getDir _player);
	_landingZone setPosATL _pos;
};

local _evacPos = getPosATL _landingZone;

_group = createGroup EAST;
local _pilot = _group createUnit ["USMC_Soldier_pilot", _startPos, [], 0,"LIEUTENANT"];
_pilot allowDamage false;
_pilot assignAsDriver _chopper;
_pilot moveInDriver _chopper;
_pilot setSkill 1;
_group setBehaviour "CARELESS";
_group setCombatMode "BLUE";
_chopper setVehicleLock "LOCKED";
_chopper engineOn true;
_chopper flyInHeight 75;

local _wp = _group addWaypoint [_evacPos, 0];
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 5;
_wp setWaypointSpeed  "FULL" ;

while {alive _player && {!_routeFinished} && {alive _chopper} && {!_disabled}} do {
	uiSleep 0.5;
	
	if ((_chopper distance _evacPos) < 150 && !_evacZoneReached) then {
		_evacZoneReached = true; 
		_chopper land 'LAND';
	};
	
	if (!_evacZoneReached) then {
		_distance = format["%1m", round (_chopper distance _evacPos)];
		_flyHeight = (round (([_chopper] call FNC_GetPos) select 2));
		
		if ({alive _x} count crew _chopper == 0) exitWith {_disabled = true;};
		
		EvacChopperClient = [_flyHeight, speed _chopper, _distance, "InProgress"];
		_owner publicVariableClient "EvacChopperClient";
		
	} else {

		if ((([_chopper] call FNC_GetPos) select 2) < 1) exitWith {
			_routeFinished = true;
			moveOut _pilot;
			
			EvacChopperClient = [0,0,0,"Arrived",_chopper];
			_owner publicVariableClient "EvacChopperClient";
		};
		
		_distance = format["%1m", round (_chopper distance _evacPos)];
		_flyHeight = (round (([_chopper] call FNC_GetPos) select 2));
		
		EvacChopperClient = [_flyHeight, speed _chopper, _distance, "InProgress"];
		_owner publicVariableClient "EvacChopperClient";
	};
};

if (_disabled) exitWith {
	deleteVehicle _landingZone;
	deleteVehicle _pilot;
	
	EvacChopperClient = [0,0,0,"Disabled",_chopper];
	_owner publicVariableClient "EvacChopperClient";
	
	while {(count (wayPoints _group)) > 0} do {
		deleteWaypoint ((wayPoints _group) select 0);
	};
	
	waitUntil{uiSleep 1; count units group _pilot == 0};
	deleteGroup _group;
};

if (!alive _chopper) exitWith {
	deleteVehicle _landingZone;
	deleteVehicle _pilot;
	
	EvacChopperClient = [0,0,0,"Crashed"];
	_owner publicVariableClient "EvacChopperClient";
	
	while {(count (wayPoints _group)) > 0} do {
		deleteWaypoint ((wayPoints _group) select 0);
	};
	
	waitUntil{uiSleep 1; count units group _pilot == 0};
	deleteGroup _group;
};

if (!alive _player) exitWith {
	deleteVehicle _landingZone;
	local _returned = false;
	
	while {(count (wayPoints _group)) > 0} do {
		deleteWaypoint ((wayPoints _group) select 0);
	 };
	 
	local _wp2 = _group addWaypoint [_startPos, 0];
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointCompletionRadius 5;
	_wp2 setWaypointSpeed "FULL";
	
	while {!_returned && {alive _chopper}} do {
		
		if ((_chopper distance _startPos) < 150 && {!_routeFinished}) then {
			_routeFinished = true; 
			_chopper land 'LAND';
		};
		
		if ((([_chopper] call FNC_GetPos) select 2) < 1) then {
			_returned = true;
		};
	};
	
	moveOut _pilot;
	deleteVehicle _pilot;
	_chopper setDir _dir;
	_chopper setPosATL _startPos;
	
	while {(count (wayPoints _group)) > 0} do {
		deleteWaypoint ((wayPoints _group) select 0);
	};
	
	waitUntil{uiSleep 1; count units group _pilot == 0};
	deleteGroup _group;
};

deleteVehicle _landingZone;
deleteVehicle _pilot;

while {(count (wayPoints _group)) > 0} do {
	deleteWaypoint ((wayPoints _group) select 0);
};

waitUntil{uiSleep 1; count units group _pilot == 0};
deleteGroup _group;