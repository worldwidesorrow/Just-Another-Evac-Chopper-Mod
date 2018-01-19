/*------------------------------------*/
/* JAEM                               */
/* Just another Chopper-Evac Mod v1.4 */
/* OtterNas3                          */
/* 01/14/2014                         */
/* Last update: 06/14/2014            */
/*------------------------------------*/
// Updated for DayZ Epoch 1.0.6.2 by JasonTM

private ["_canceled","_cnt","_locationPlayer","_evacFieldID","_checkForChopper","_evacCallerUID","_evacFields","_heliHRescue","_routeFinished","_evacZone","_chopperStartPos","_getChopperStartPos","_evacZoneDistance","_startZoneWaypoint","_evacZoneWaypoint","_part","_damage","_hitpoints","_evacChopperFuel","_finishMarker","_evacZonePos","_dayTime"];

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
	evacChopper = _checkForChopper select 0;
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
_evacChopperFuel = fuel evacChopper;
if (_evacChopperFuel < 0.2) exitWith {
	"Sorry but the Fuel of your Evac-Chopper is too low to fly to you" call dayz_rollingMessages;
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
};

// Damage check
_part = "";
_hitpoints = evacChopper call vehicle_getHitpoints;
{			
	_damage = [evacChopper,_x] call object_getHit;
	if(["Engine",_x,false] call fnc_inString) then {
		_part = "PartEngine";
	};

	if(["HRotor",_x,false] call fnc_inString) then {
		_part = "PartVRotor";
	};

	if (_damage >= 1 && (_part == "PartEngine" || _part == "PartVRotor")) then {
		if(_part == "PartEngine") exitWith {
			"Sorry but the Engine of your Evac-Chopper is too damaged to fly" call dayz_rollingMessages;
			if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
				evac_chopperInProgress = false;
		};
		if (_part == "PartVRotor") exitWith {
			"Sorry but the Main-Rotor of your Evac-Chopper is too damaged to fly" call dayz_rollingMessages;
			if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
				evac_chopperInProgress = false;
		};
	};
} forEach _hitpoints;

// Fuel and damage check complete
"Checks complete - Your Evac-Chopper is starting" call dayz_rollingMessages;

// Create the Evacuation Zone Marker
if (evac_chopperZoneMarker == 1) then {
	_heliHRescue = "SmokeshellGreen" createVehicle ([player] call FNC_GetPos);
	_heliHRescue setPosATL ([player] call FNC_GetPos);
} else {
	_heliHRescue = "HeliHRescue" createVehicle ([player] call FNC_GetPos);
	_heliHRescue setDir (getDir player);
	_heliHRescue setPosATL ([player] call FNC_GetPos);
};

//Reset of the checkpoint bool's
evacZoneReached = false;
_routeFinished = false;

// Get needed positions
_evacZonePos = [_heliHRescue] call FNC_GetPos;
_evacZone = _evacZonePos;
_getChopperStartPos = [evacChopper] call FNC_GetPos;
_chopperStartPos = _getChopperStartPos;

// Unlocking the Chopper and create the AI Pilot
evacChopper setVehicleLock "UNLOCKED";
evacChopperGroup = createGroup WEST;
evacChopperPilot = evacChopperGroup createUnit ["USMC_Soldier_pilot", evacChopper, [], 0,"LIEUTENANT"];
removeallweapons evacChopperPilot;
removeallitems evacChopperPilot;
evacChopperPilot removeAllEventHandlers "HandleDamage";
evacChopperPilot addEventHandler ["HandleDamage", {false}];
evacChopperPilot allowDamage false;
evacChopperPilot assignAsDriver evacChopper;
evacChopperPilot moveInDriver evacChopper;
evacChopperPilot setSkill 1;
evacChopperGroup setBehaviour "CARELESS";
uiSleep 1;

//Lock the Chopper again so noone can jump in
evacChopper setVehicleLock "LOCKED";

//Turn the Engine on and set fly height for the Pilot
evacChopper engineOn true;
evacChopper flyInHeight 200;

//Create the Waypoint for the Evacuation Zone
_startZoneWaypoint = evacChopperGroup addWaypoint [_chopperStartPos, 0];
_startZoneWaypoint setWaypointBehaviour "CARELESS";
_startZoneWaypoint setWaypointType "MOVE";
_startZoneWaypoint setWaypointCompletionRadius 5;
_startZoneWaypoint setWaypointSpeed "FULL";
_evacZoneWaypoint = evacChopperGroup addWaypoint [_evacZone, 0];
_evacZoneWaypoint setWaypointBehaviour "CARELESS";
_evacZoneWaypoint setWaypointType "MOVE";
_evacZoneWaypoint setWaypointCompletionRadius 5;
_evacZoneWaypoint setWaypointSpeed  "FULL" ;
_evacZoneWaypoint setWaypointStatements ["true", "evacZoneReached = true; evacChopper land 'LAND';"];
_evacZoneWaypoint setWaypointCombatMode "BLUE";

// Start loop. Checking for player still alive - Evac Zone reached - Chopper still alive
while {alive player && !_routeFinished && alive evacChopper} do {
	uiSleep 0.5;
	// Still on his way
	if (!evacZoneReached) then {
		_evacZoneDistance = format["%1m", round (evacChopper distance _evacZone)];
	} else {
		//Arrived!
		if ((([evacChopper] call FNC_GetPos) select 2) < 1) then {
			waitUntil {!isEngineOn evacChopper};
			_routeFinished = true;
			_evacZoneDistance = "!!! ARRIVED !!!";
			_evacZoneWaypoint = evacChopperGroup addWaypoint [_evacZone, 0];
			_evacZoneWaypoint setWaypointType "GETOUT";
		} else {
			_evacZoneDistance = format["%1m", round (evacChopper distance _evacZone)];
		};
	};
	// Showing a Hint-Box with information to the player about the Evac-Chopper - Height - Speed - Distance
	hintSilent parseText format ["
		<t size='1.15'	font='Bitstream'align='center' 	color='#5882FA'>EVAC-Chopper</t>			<br/>
		<t size='1'		font='Bitstream'align='center' 	color='#00FF00'>----------------------</t>	<br/>
		<t size='1'		font='Bitstream'align='left' 	color='#FFBF00'>Fly Height:</t>				<t size='1'		font='Bitstream'align='right'>%1</t><br/>
		<t size='1'		font='Bitstream'align='left' 	color='#FFBF00'>Fly Speed:</t>				<t size='1'		font='Bitstream'align='right'>%2</t><br/>
		<t size='1'		font='Bitstream'align='left' 	color='#FFBF00'>Distance:</t>				<t size='1'		font='Bitstream'align='right'>%3</t><br/>",
		(round (([evacChopper] call FNC_GetPos) select 2)), (round (speed evacChopper)), _evacZoneDistance
	];
};

// If Chopper got destroyed delete AI Pilot and his group, give a Hint to the player about the Crash and exit the script.
if (!alive evacChopper) exitWith {
	{deleteWaypoint _x} forEach waypoints evacChopperGroup;
	deleteVehicle evacChopperPilot;
	waitUntil{count units group evacChopperPilot == 0};
	deleteGroup evacChopperGroup;
	deleteVehicle _heliHRescue;
	hintSilent parseText format ["
		<t size='1.15'	font='Bitstream'align='center' 	color='#5882FA'>EVAC-Chopper</t>			<br/>
		<t size='1'		font='Bitstream'align='center' 	color='#00FF00'>----------------------</t>	<br/>
		<t size='1.15'	font='Bitstream'align='center' 	color='#FFBF00'>!!! CRASHED !!!</t>			<br/>"
	];
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
};

// If player dies reset the Evac-Chopper to the start position, remove the AI Pilot and his group, delete the Evac-Zone Marker and exit the script.
if (!alive player) exitWith {
	deleteVehicle _heliHRescue;
	evacChopper engineOn false;
	evacChopper setPosATL _chopperStartPos;
	evacChopper setVelocity [0,0,0.01];
	{deleteWaypoint _x} forEach waypoints evacChopperGroup;
	_evacZoneWaypoint = evacChopperGroup addWaypoint [_chopperStartPos, 0];
	_evacZoneWaypoint setWaypointType "GETOUT";
	waitUntil{{_x in evacChopper} count units group evacChopperPilot == 0};
	{deleteWaypoint _x} forEach waypoints evacChopperGroup;
	deleteVehicle evacChopperPilot;
	waitUntil{count units group evacChopperPilot == 0};
	deleteGroup evacChopperGroup;
	evacChopper setVehicleLock "LOCKED";
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
		evac_chopperInProgress = false;
};

//Create Visible Marker
_dayTime = dayTime;
if (_dayTime > 6 && _dayTime < 18.5) then {
	_finishMarker = "SmokeShellGreen" createVehicle ([evacChopper] call FNC_GetPos);
	_finishMarker setPosATL ([evacChopper] call FNC_GetPos);
	_finishMarker attachTo [evacChopper,[0,0,0]];
};
if (_dayTime > 18.5 && _dayTime < 6) then {
	_finishMarker = "ARTY_Flare_Medium" createVehicle ([evacChopper] call FNC_GetPos);
	_finishMarker setPosATL ([evacChopper] call FNC_GetPos);
	_finishMarker attachTo [evacChopper, [0,0,0]];
};

//We delete the AI Pilot his group and the Evac-Zone Marker
//Wait until Pilot left the Chopper
waitUntil{{_x in evacChopper} count units group evacChopperPilot == 0};
{deleteWaypoint _x} forEach waypoints evacChopperGroup;
deleteVehicle evacChopperPilot;

//Wait until the pilot is deleted so we can delete the group
waitUntil{count units group evacChopperPilot == 0};
deleteGroup evacChopperGroup;

//Delete the target zone marker
deleteVehicle _heliHRescue;

/*
//If player dies reset the Evac-Chopper to the start position, remove the AI Pilot and his group, delete the Evac-Zone Marker and exit the script
if (!alive player) exitWith {
	deleteVehicle _finishMarker;
	deleteVehicle _heliHRescue;
	evacChopper setPosATL _chopperStartPos;
	evacChopper setVelocity [0,0,0.01];
	{deleteWaypoint _x} forEach waypoints evacChopperGroup;
	_evacZoneWaypoint = evacChopperGroup addWaypoint [_chopperStartPos, 0];
	_evacZoneWaypoint setWaypointType "GETOUT";
	waitUntil{{_x in evacChopper} count units group evacChopperPilot == 0};
	{deleteWaypoint _x} forEach waypoints evacChopperGroup;
	deleteVehicle evacChopperPilot;
	waitUntil{count units group evacChopperPilot == 0};
	deleteGroup evacChopperGroup;
	evacChopper setVehicleLock "LOCKED";
	if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
};
*/

if (alive player) then {
//Wait until the player moves close to the Evac-Chopper
waitUntil {(player distance evacChopper) < 10};

//Player is close to the chopper so unlock it.
"Owner detected - ACCESS GRANTED! Have a good Flight!" call dayz_rollingMessages;
evacChopper setVehicleLock "UNLOCKED";
};

//delete the Smoke/Flare marker
deleteVehicle _finishMarker;

//reset the action menu variable
if (!evac_chopperUseClickActions) then {s_player_evacCall = -1;};
evac_chopperInProgress = false;	


//Thats it for the Evacutaion process
//Hope you enjoyed it :)
//Moo,
//Otter