/*------------------------------------*/
/* JAEM                               */
/* Just another Chopper-Evac Mod v1.4 */
/* OtterNas3                          */
/* 01/14/2014                         */
/* Last update: 06/14/2014            */
/*------------------------------------*/
// Updated for DayZ Epoch 1.0.6.2 by JasonTM

private ["_chopperDir","_marker","_evacChopper","_canceled","_cnt","_locationPlayer","_evacFieldID","_checkForChopper","_evacCallerUID","_evacFields","_chopperPos","_evacZoneDistance","_part","_damage","_hitpoints","_evacChopperFuel"];

if (!evac_chopperUseClickActions) then {player removeAction s_player_evacCall; s_player_evacCall = 1;};

evac_chopperInProgress = true;

if (evac_chopperUseClickActions && ((player distance playersEvacField) < evac_chopperMinDistance)) exitWith {
	format["You must be at least %1 meters away to call your Evac-Chopper",evac_chopperMinDistance] call dayz_rollingMessages;
	evac_chopperInProgress = false;
};

_cnt = 5;
_locationPlayer = [player] call FNC_GetPos;
_canceled = false;

/* 5 seconds timeout to cancel a call on accident */
for "_p" from 1 to 5 do
{
	systemChat(format ["Evac-Chopper get called in %1s - Move to cancel!",_cnt]);
	if (player distance _locationPlayer > 0.2) exitWith {_canceled = true;};
	uiSleep 1;
	_cnt = _cnt - 1;
};

if (_canceled) exitWith {"Evac-Chopper call canceled!" call dayz_rollingMessages;
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
};

"Searching for your Evac-Chopper - Please wait..." call dayz_rollingMessages;
uiSleep 2;

// Setting needed variables to check which Evac-Field the player owns
_evacCallerUID = getPlayerUID player;

// Re-check for evac fields if none found.
if (!playerHasEvacField) then { 
	_evacFields = PVDZE_EvacChopperFields;
	if ((count _evacFields) > 0) then {
		{
			_evacFieldID = _x getVariable["ownerPUID","0"];
			if (_evacCallerUID == _evacFieldID) then {
				playerHasEvacField = true;
				playersEvacField = _x;
			};
		} forEach _evacFields;
	};
};

// Player has no evac field, exit
if (!playerHasEvacField) exitWith {
	"Sorry but you dont have an Evac-Chopper" call dayz_rollingMessages;
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
};

// Player has an evac field now check if a Chopper is on it
_checkForChopper = playersEvacField nearEntities ["Helicopter", 10];
if ((count _checkForChopper) > 0) then {
	_evacChopper = _checkForChopper select 0;
} else {
	"Sorry but there is no Chopper on your Evac-Field" call dayz_rollingMessages;
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
		breakOut "exit";
};

// We found a Chopper
"Player Evac-Chopper found - Checking Fuel and Damage" call dayz_rollingMessages;
uiSleep 5;

// Fuel check
_evacChopperFuel = fuel _evacChopper;
if (_evacChopperFuel < 0.2) exitWith {
	"Sorry but the Fuel of your Evac-Chopper is too low to fly to you" call dayz_rollingMessages;
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
};

// Damage check
_part = "";
_hitpoints = _evacChopper call vehicle_getHitpoints;
{			
	_damage = [_evacChopper,_x] call object_getHit;
	if(["Engine",_x,false] call fnc_inString) then {
		_part = "PartEngine";
	};

	if(["HRotor",_x,false] call fnc_inString) then {
		_part = "PartVRotor";
	};

	if (_damage >= 1 && (_part == "PartEngine" || _part == "PartVRotor")) then {
		if(_part == "PartEngine") exitWith {
			"Sorry but the Engine of your Evac-Chopper is too damaged to fly" call dayz_rollingMessages;
			_canceled = true;
		};
		if (_part == "PartVRotor") exitWith {
			_canceled = true;
			"Sorry but the Main-Rotor of your Evac-Chopper is too damaged to fly" call dayz_rollingMessages;
		};
	};
} forEach _hitpoints;

if (_canceled) exitWith {if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;}; evac_chopperInProgress = false;};

// Get needed positions
_chopperPos = [_evacChopper] call FNC_GetPos;
_chopperDir = getDir _evacChopper;

// Fuel and damage check complete
"Checks complete - Your Evac-Chopper is starting" call dayz_rollingMessages;

CallEvacChopper = [_evacChopper,[_chopperPos,_chopperDir],player,dayz_authKey];
publicVariableServer "CallEvacChopper";
	
EvacChopperFlightStatus = {
	private ["_flyHeight","_flySpeed","_evacZoneDistance","_flightStatus","_evacChopper"];
	_flyHeight = _this select 0;
	_flySpeed = _this select 1;
	_evacZoneDistance = _this select 2;
	_flightStatus = _this select 3;
	if ((count _this) > 4) then {_evacChopper = _this select 4;};
	
	if (_flightStatus == "Arrived") exitWith
	{
		hintSilent parseText format ["
			<t size='1.15'	font='Bitstream'align='center' 	color='#5882FA'>EVAC-Chopper</t>			<br/>
			<t size='1'		font='Bitstream'align='center' 	color='#00FF00'>----------------------</t>	<br/>
			<t size='1.15'	font='Bitstream'align='center' 	color='#FFBF00'>!!! ARRIVED !!!</t>			<br/>"
		];
		[_evacChopper] spawn {
		private "_evacChopper";
		_evacChopper = _this select 0;
		waitUntil {uiSleep 1; (player distance _evacChopper) < 10};
		PVDZE_veh_Lock = [_evacChopper,false];
		publicVariable "PVDZE_veh_Lock";
		"Owner detected, chopper unlocked" call dayz_rollingMessages;
		};
	};
	
	if (_flightStatus == "Crashed") exitWith
	{
		hintSilent parseText format ["
			<t size='1.15'	font='Bitstream'align='center' 	color='#5882FA'>EVAC-Chopper</t>			<br/>
			<t size='1'		font='Bitstream'align='center' 	color='#00FF00'>----------------------</t>	<br/>
			<t size='1.15'	font='Bitstream'align='center' 	color='#FFBF00'>!!! CRASHED !!!</t>			<br/>"
		];
	};
	
	if (_flightStatus == "Disabled") exitWith
	{
		hintSilent parseText format ["
			<t size='1.15'	font='Bitstream'align='center' 	color='#5882FA'>EVAC-Chopper</t>			<br/>
			<t size='1'		font='Bitstream'align='center' 	color='#00FF00'>----------------------</t>	<br/>
			<t size='1.15'	font='Bitstream'align='center' 	color='#FFBF00'>!!! DISABLED !!!</t>			<br/>"
		];
		// Create optional private map marker for the disabled chopper
		if (evac_ChopperDisabledMarker) then {[_evacChopper] spawn DisabledChopperMarker;};
	};
	
	// Showing a Hint-Box with information to the player about the Evac-Chopper - Height - Speed - Distance
	hintSilent parseText format ["
		<t size='1.15'	font='Bitstream'align='center' 	color='#5882FA'>EVAC-Chopper</t>			<br/>
		<t size='1'		font='Bitstream'align='center' 	color='#00FF00'>----------------------</t>	<br/>
		<t size='1'		font='Bitstream'align='left' 	color='#FFBF00'>Fly Height:</t>				<t size='1'		font='Bitstream'align='right'>%1</t><br/>
		<t size='1'		font='Bitstream'align='left' 	color='#FFBF00'>Fly Speed:</t>				<t size='1'		font='Bitstream'align='right'>%2</t><br/>
		<t size='1'		font='Bitstream'align='left' 	color='#FFBF00'>Distance:</t>				<t size='1'		font='Bitstream'align='right'>%3</t><br/>",
		_flyHeight, _flySpeed, _evacZoneDistance
	];
};

DisabledChopperMarker = {
	private ["_marker","_evacChopper","_recovered","_time","_chopperPos"];
	_evacChopper = _this select 0;
	if (evac_ChopperUsemarkerTimeOut) then {format["Your marker will disappear in %1 seconds, make note of EVAC Chopper's location",evac_chopperMarkerTimeout] call dayz_rollingMessages;};
	"A private marker has been placed on the map for your disabled Evac Chopper" call dayz_rollingMessages;
	_recovered = false;
	_time = time;
	_chopperPos = getPos _evacChopper;
	_marker = createMarkerLocal ["EvacChopper",_chopperPos];
	_marker setMarkerColorLocal "ColorBlack";
	_marker setMarkerTypeLocal "mil_objective";
	_marker setMarkerTextLocal "EvacChopper";
	while {!_recovered} do {
	if (evac_ChopperUsemarkerTimeOut) then {
		if ((time - _time) > evac_chopperMarkerTimeout) then {_recovered = true; deleteMarkerLocal _marker; "EVAC Chopper map marker deleted" call dayz_rollingMessages;};
	};
	if ((player distance _chopperPos) < 10) then
	{
		_recovered = true;
		deleteMarkerLocal _marker;
		PVDZE_veh_Lock = [_evacChopper,false];
		publicVariable "PVDZE_veh_Lock";
		"Owner detected, Chopper unlocked, Marker Removed" call dayz_rollingMessages;
	};
	uiSleep 3;
	};
};



//reset the action menu variable
if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
evac_chopperInProgress = false;	


//Thats it for the Evacutaion process
//Hope you enjoyed it :)
//Moo,
//Otter