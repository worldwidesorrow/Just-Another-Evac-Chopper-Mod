private ["_owner","_chopper","_pilot","_group","_returned","_dir","_worldSpace","_disabled","_pos","_startPos","_player","_clientKey","_playerUID","_exitReason","_routeFinished","_landingZone","_evacZonePos","_distance","_wp","_wp2","_flyHeight","_evacZoneReached"];

_chopper = _this select 0;
_worldSpace = _this select 1;
_startPos = _worldSpace select 0;
_dir = _worldSpace select 1;
_player = _this select 2;
_clientKey = _this select 3;
_playerUID = getPlayerUID _player;
_pos = [_player] call FNC_GetPos;
_owner = owner _player;

_exitReason = [_this,"Call_chopper",_pos,_clientKey,_playerUID,_player] call server_verifySender;
if (_exitReason != "") exitWith {diag_log _exitReason};

_evacZoneReached = false;
_routeFinished = false;
_disabled = false;

if (evac_chopperZoneMarker == 1) then {
	_landingZone = "SmokeshellGreen" createVehicle ([_player] call FNC_GetPos);
	_landingZone setPosATL ([_player] call FNC_GetPos);
} else {
	_landingZone = "HeliHRescue" createVehicle ([_player] call FNC_GetPos);
	_landingZone setDir (getDir _player);
	_landingZone setPosATL ([_player] call FNC_GetPos);
};

_evacZonePos = [_landingZone] call FNC_GetPos;

_group = createGroup EAST;
_pilot = _group createUnit ["USMC_Soldier_pilot", _startPos, [], 0,"LIEUTENANT"];
_pilot allowDamage false;
_pilot assignAsDriver _chopper;
_pilot moveInDriver _chopper;
_pilot setSkill 1;
_group setBehaviour "CARELESS";
_group setCombatMode "BLUE";
_chopper setVehicleLock "LOCKED";
_chopper engineOn true;
_chopper flyInHeight 75;

_wp = _group addWaypoint [_evacZonePos, 0];
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 5;
_wp setWaypointSpeed  "FULL" ;

while {alive _player && {!_routeFinished} && {alive _chopper} && {!_disabled}} do {
	uiSleep 0.5;
	
	if ((_chopper distance _evacZonePos) < 150 && !_evacZoneReached) then {
		_evacZoneReached = true; 
		_chopper land 'LAND';
	};
	
	if (!_evacZoneReached) then {
		_distance = format["%1m", round (_chopper distance _evacZonePos)];
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
		
		_distance = format["%1m", round (_chopper distance _evacZonePos)];
		_flyHeight = (round (([_chopper] call FNC_GetPos) select 2));
		
		EvacChopperClient = [_flyHeight, speed _chopper, _distance, "InProgress"];
		_owner publicVariableClient "EvacChopperClient";
	};
};

if (_disabled) exitWith {
	deleteVehicle _landingZone;
	deleteVehicle _pilot;
	waitUntil{uiSleep 1; count units group _pilot == 0};
	deleteGroup _group;
	
	EvacChopperClient = [0,0,0,"Disabled",_chopper];
	_owner publicVariableClient "EvacChopperClient";
};

if (!alive _chopper) exitWith {
	deleteVehicle _landingZone;
	deleteVehicle _pilot;
	waitUntil{uiSleep 1; count units group _pilot == 0};
	deleteGroup _group;
	
	EvacChopperClient = [0,0,0,"Crashed"];
	_owner publicVariableClient "EvacChopperClient";
};

if (!alive _player) exitWith {
	deleteVehicle _landingZone;
	_returned = false;
	
	while {(count (wayPoints _group)) > 0} do
	 {
	  deleteWaypoint ((wayPoints _group) select 0);
	 };
	 
	_wp2 = _group addWaypoint [_startPos, 0];
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
	waitUntil{uiSleep 1; count units group _pilot == 0};
	deleteGroup _group;
	_chopper setDir _dir;
	_chopper setPosATL _startPos;
};

deleteVehicle _landingZone;
deleteVehicle _pilot;
waitUntil{uiSleep 1; count units group _pilot == 0};
deleteGroup _group;