/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* OtterNas3								*/
/* 01/14/2014                         		*/
/* Updated for DayZ Epoch 1.0.6+ by JasonTM */
/* Updated for DayZ Epoch 1.0.7+ by JasonTM */
/* Last update: 05-30-2021           		*/
/*------------------------------------------*/

if(evac_chopperInProgress) exitWith {format["%1 %2",localize "STR_CL_EC_NAME", localize "STR_EPOCH_PLAYER_96"] call dayz_rollingMessages;};
evac_chopperInProgress = true;

player removeAction s_player_evacCall;
s_player_evacCall = 1;

local _name = localize "STR_CL_EC_NAME";
local _cnt = 5;
local _locationPlayer = [player] call FNC_GetPos;
local _clickAction = _this select 3; // boolean

if (!playerHasEvacField) exitWith {
	format[localize "STR_EPOCH_PLAYER_118",_name] call dayz_rollingMessages;
	evac_chopperInProgress = false;
	s_player_evacCall = -1;
};

if (_clickAction && ((player distance playersEvacField) < evac_chopperMinDistance)) exitWith {
	format[localize "STR_CL_EC_MINIMUM_DISTANCE",evac_chopperMinDistance,_name] call dayz_rollingMessages;
	evac_chopperInProgress = false;
};

_NearChoppers = playersEvacField nearEntities ["Helicopter", 10];

if (count _NearChoppers == 0) exitWith {
	format[localize "STR_EPOCH_PLAYER_118",_name] call dayz_rollingMessages;
	evac_chopperInProgress = false;
	s_player_evacCall = -1;
};

local _evacChopper = _NearChoppers select 0;

/* 5 seconds timeout to cancel a call on accident */
for "_p" from 1 to _cnt do {
	systemChat format [localize "STR_CL_EC_COUNTDOWN",_name,_cnt];
	if (player distance _locationPlayer > 0.2) exitWith {
		evac_chopperInProgress = false;
		s_player_evacCall = -1;
	};
	uiSleep 1;
	_cnt = _cnt - 1;
};

if (!evac_chopperInProgress) exitWith {};

// Fuel check
if ((fuel _evacChopper) < 0.2) exitWith {
	localize "STR_CL_EC_UNABLETOEVAC" call dayz_rollingMessages;
	evac_chopperInProgress = false;
	s_player_evacCall = -1;
};

// Damage check - some helicopters don't have all of the hit points in the array so an isNil check is necessary.
{
	local _selection = getText (configFile >> "CfgVehicles" >> (typeOf _evacChopper) >> "HitPoints" >> _x >> "name");
	local _dam = _evacChopper getHit _selection;
	if (!(isNil "_dam") && {_dam >= .9}) exitWith {
		localize "STR_CL_EC_UNABLETOEVAC" call dayz_rollingMessages;
		evac_chopperInProgress = false;
		s_player_evacCall = -1;
	};
} forEach ["HitEngine","HitHRotor","HitVRotor"];

if (!evac_chopperInProgress) exitWith {};

local _chopperPos = [_evacChopper] call FNC_GetPos;
local _chopperDir = getDir _evacChopper;

CallEvacChopper = [_evacChopper,[_chopperPos,_chopperDir],player,dayz_authKey];
publicVariableServer "CallEvacChopper";
	
EvacChopperFlightStatus = {
	local _flyHeight = _this select 0;
	local _flySpeed = _this select 1;
	local _evacZoneDistance = _this select 2;
	local _flightStatus = _this select 3;
	local _evacChopper = objNull;
	if ((count _this) > 4) then {_evacChopper = _this select 4;};
	
	if (_flightStatus == "Arrived") exitWith {
		hintSilent parseText format ["
			<t size='1.15' font='Bitstream' align='center' color='#5882FA'>%1</t><br/>
			<t size='1'	font='Bitstream' align='center' color='#00FF00'>----------------------</t><br/>
			<t size='1.15' font='Bitstream' align='center' color='#FFBF00'>%2</t><br/>",
			toUpper localize "STR_CL_EC_NAME",
			localize "STR_CL_EC_ARRIVED"
		];
		_evacChopper spawn {
			local _evacChopper = _this;
			local _marker = objNull;
			if (sunOrMoon == 1) then {
				_marker = "SmokeShellGreen" createVehicle ([_evacChopper] call FNC_GetPos);
				_marker setPosATL ([_evacChopper] call FNC_GetPos);
				_marker attachTo [_evacChopper,[0,0,0]];
			} else {
				_marker = "RoadFlare" createVehicle ([_evacChopper] call FNC_GetPos);
				_marker setPosATL ([_evacChopper] call FNC_GetPos);
				_marker attachTo [_evacChopper, [0,0,0]];
						
				PVDZ_obj_RoadFlare = [_marker,0];
				publicVariable "PVDZ_obj_RoadFlare";
			};
			
			waitUntil {uiSleep 1; (player distance _evacChopper) < 10};
			
			PVDZE_veh_Lock = [_evacChopper,false];
			publicVariable "PVDZE_veh_Lock";
			
			format[localize "STR_BLD_UNLOCKED",localize "STR_CL_EC_NAME"] call dayz_rollingMessages;
			
			s_player_evacCall = -1;
			evac_chopperInProgress = false;	
		};
	};
	
	if (_flightStatus == "Crashed") exitWith {
		hintSilent parseText format ["
			<t size='1.15' font='Bitstream' align='center' color='#5882FA'>%1</t><br/>
			<t size='1' font='Bitstream' align='center' color='#00FF00'>----------------------</t><br/>
			<t size='1.15' font='Bitstream' align='center' color='#FFBF00'>%2</t><br/>",
			toUpper localize "STR_CL_EC_NAME",
			localize "STR_CL_EC_CRASHED"
		];
		s_player_evacCall = -1;
		evac_chopperInProgress = false;
	};
	
	if (_flightStatus == "Disabled") exitWith {
		hintSilent parseText format ["
			<t size='1.15' font='Bitstream' align='center' color='#5882FA'>%1</t><br/>
			<t size='1' font='Bitstream' align='center' color='#00FF00'>----------------------</t><br/>
			<t size='1.15' font='Bitstream' align='center' color='#FFBF00'>%2</t><br/>",
			localize "STR_CL_EC_NAME",
			localize "STR_CL_EC_DISABLED"
		];
		if (evac_chopperDisabledMarker) then {_evacChopper spawn DisabledChopperMarker;};
		s_player_evacCall = -1;
		evac_chopperInProgress = false;
	};
	
	hintSilent parseText format ["
		<t size='1.15' font='Bitstream' align='center' color='#5882FA'>%1</t><br/>
		<t size='1' font='Bitstream' align='center' color='#00FF00'>----------------------</t><br/>
		<t size='1' font='Bitstream' align='left' color='#FFBF00'>Altitude:</t><t size='1' font='Bitstream' align='right'>%2</t><br/>
		<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Flight Speed:</t><t size='1' font='Bitstream' align='right'>%3</t><br/>
		<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Distance:</t><t size='1' font='Bitstream' align='right'>%4</t><br/>",
		toUpper localize "STR_CL_EC_NAME",_flyHeight, _flySpeed, _evacZoneDistance
	];
};

DisabledChopperMarker = {
	local _evacChopper = _this;
	local _recovered = false;
	local _chopperPos = getPosATL _evacChopper;
	local _marker = createMarkerLocal ["EvacChopper",_chopperPos];
	_marker setMarkerColorLocal "ColorBlack";
	_marker setMarkerTypeLocal "mil_objective";
	_marker setMarkerTextLocal (localize "STR_CL_EC_NAME");
	format["STR_CL_EC_MARKER",localize "STR_CL_EC_NAME"] call dayz_rollingMessages; // localize the first part?///////////////////////
	
	while {!_recovered} do {
		if ((player distance _chopperPos) < 10) then {
			_recovered = true;
			deleteMarkerLocal _marker;
			
			PVDZE_veh_Lock = [_evacChopper,false];
			publicVariable "PVDZE_veh_Lock";
			
			format[localize "STR_BLD_UNLOCKED",localize "STR_CL_EC_NAME"] call dayz_rollingMessages;
		};
	uiSleep 3;
	};
};