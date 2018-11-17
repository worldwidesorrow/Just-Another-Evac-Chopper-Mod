private ["_chopperDir","_worldSpace","_disabledChopper","_pos","_chopperStartPos","_activatingPlayer","_clientKey","_playerUID","_exitReason","_routeFinished","_heliHRescue","_evacZonePos","_evacZoneDistance","_startZoneWaypoint","_evacZoneWaypoint","_dayTime","_finishMarker"];

evacChopper = _this select 0;
_worldSpace = _this select 1;
_chopperStartPos = _worldSpace select 0;
_chopperDir = _worldSpace select 1;
_activatingPlayer = _this select 2;
_clientKey = _this select 3;
_playerUID = getPlayerUID _activatingPlayer;
_pos = [_activatingPlayer] call FNC_GetPos;

_exitReason = [_this,"CallEvacChopper",_pos,_clientKey,_playerUID,_activatingPlayer] call server_verifySender;
if (_exitReason != "") exitWith {diag_log _exitReason};

//Reset of the checkpoint bool's
evacZoneReached = false;
_routeFinished = false;
_disabledChopper = false;


// Create the Evacuation Zone Marker
if (evac_chopperZoneMarker == 1) then {
	_heliHRescue = "SmokeshellGreen" createVehicle ([_activatingPlayer] call FNC_GetPos);
	_heliHRescue setPosATL ([_activatingPlayer] call FNC_GetPos);
} else {
	_heliHRescue = "HeliHRescue" createVehicle ([_activatingPlayer] call FNC_GetPos);
	_heliHRescue setDir (getDir _activatingPlayer);
	_heliHRescue setPosATL ([_activatingPlayer] call FNC_GetPos);
};

_evacZonePos = [_heliHRescue] call FNC_GetPos;

// Unlock the Chopper and create the AI Pilot
evacChopper setVehicleLock "UNLOCKED";
evacChopperGroup = createGroup WEST;
evacChopperPilot = evacChopperGroup createUnit ["USMC_Soldier_pilot", evacChopper, [], 0,"LIEUTENANT"];
removeAllWeapons evacChopperPilot;
removeAllItems evacChopperPilot;
evacChopperPilot removeAllEventHandlers "HandleDamage";
evacChopperPilot addEventHandler ["HandleDamage", {false}];
evacChopperPilot allowDamage false;
evacChopperPilot assignAsDriver evacChopper;
evacChopperPilot moveInDriver evacChopper;
evacChopperPilot setSkill 1;
evacChopperGroup setBehaviour "CARELESS";
uiSleep 1;

//Lock the Chopper again so no one can jump in
evacChopper setVehicleLock "LOCKED";

//Turn the Engine on and set fly height for the Pilot
evacChopper engineOn true;
evacChopper flyInHeight 75;

//Create the Waypoint for the Evacuation Zone
_startZoneWaypoint = evacChopperGroup addWaypoint [_chopperStartPos, 0];
_startZoneWaypoint setWaypointBehaviour "CARELESS";
_startZoneWaypoint setWaypointType "MOVE";
_startZoneWaypoint setWaypointCompletionRadius 5;
_startZoneWaypoint setWaypointSpeed "FULL";
_evacZoneWaypoint = evacChopperGroup addWaypoint [_evacZonePos, 0];
_evacZoneWaypoint setWaypointBehaviour "CARELESS";
_evacZoneWaypoint setWaypointType "MOVE";
_evacZoneWaypoint setWaypointCompletionRadius 5;
_evacZoneWaypoint setWaypointSpeed  "FULL" ;
_evacZoneWaypoint setWaypointStatements ["true", "evacZoneReached = true; evacChopper land 'LAND';"];
_evacZoneWaypoint setWaypointCombatMode "BLUE";

// Start loop. Checking for player still alive - Evac Zone reached - Chopper still alive - Chopper not disabled
while {alive _activatingPlayer && !_routeFinished && alive evacChopper && !_disabledChopper} do {
	uiSleep 0.5;
	// Still on his way
	if (!evacZoneReached) then {
		// Flight status information
		_evacZoneDistance = format["%1m", round (evacChopper distance _evacZonePos)];
		_flyHeight = (round (([evacChopper] call FNC_GetPos) select 2));
		
		// If the helicopter becomes disabled, the pilot will land, exit the helicopter,
		// and run towards the evac zone waypoint. This could cause the script to hang for a long
		// time, so we exit the loop
		if ({alive _x} count crew evacChopper == 0) exitWith {_disabledChopper = true;};
		
		// Send the flight status information to the client to display in the monitor
		EvacChopperClient = [_flyHeight, speed evacChopper, _evacZoneDistance,"InProgress"];
		(owner _activatingPlayer) publicVariableClient "EvacChopperClient";
		
	} else {
		//Arrived!
		if ((([evacChopper] call FNC_GetPos) select 2) < 1) then {
			waitUntil {uiSleep 1; !isEngineOn evacChopper};
			_routeFinished = true;
			
			// Send the flight status information to the client to display in the monitor
			EvacChopperClient = [0,0,0,"Arrived",evacChopper];
			(owner _activatingPlayer) publicVariableClient "EvacChopperClient";
			
			_evacZoneWaypoint = evacChopperGroup addWaypoint [_evacZonePos, 0];
			_evacZoneWaypoint setWaypointType "GETOUT";
		} else {
			_evacZoneDistance = format["%1m", round (evacChopper distance _evacZonePos)];
			_flyHeight = (round (([evacChopper] call FNC_GetPos) select 2));
			
			// Send the flight status information to the client to display in the monitor
			EvacChopperClient = [_flyHeight, speed evacChopper, _evacZoneDistance,"InProgress"];
			(owner _activatingPlayer) publicVariableClient "EvacChopperClient";
		};
	};
};

// Exit the script with hint if the chopper becomes disabled
// Send chopper information for optional client-side marker
if (_disabledChopper) exitWith {
	{deleteWaypoint _x} forEach wayPoints evacChopperGroup;
	deleteVehicle evacChopperPilot;
	waitUntil{uiSleep 1; count units group evacChopperPilot == 0};
	deleteGroup evacChopperGroup;
	deleteVehicle _heliHRescue;
	
	// Send the flight status information to the client to display in the monitor
	EvacChopperClient = [0,0,0,"Disabled",evacChopper];
	(owner _activatingPlayer) publicVariableClient "EvacChopperClient";
};

// If Chopper got destroyed delete AI Pilot and his group, give a Hint to the player about the Crash and exit the script.
if (!alive evacChopper) exitWith {
	{deleteWaypoint _x} forEach wayPoints evacChopperGroup;
	deleteVehicle evacChopperPilot;
	waitUntil{uiSleep 1; count units group evacChopperPilot == 0};
	deleteGroup evacChopperGroup;
	deleteVehicle _heliHRescue;
	
	// Send the flight status information to the client to display in the monitor
	EvacChopperClient = [0,0,0,"Crashed"];
	(owner _activatingPlayer) publicVariableClient "EvacChopperClient";
};

// If player dies, have the AI pilot fly back to start position, remove the AI Pilot and his group, delete the Evac-Zone Marker and exit the script.
if (!alive _activatingPlayer) exitWith {
	deleteVehicle _heliHRescue;
	{deleteWaypoint _x} forEach wayPoints evacChopperGroup;
	_evacZoneWaypoint = evacChopperGroup addWaypoint [_chopperStartPos, 0];
	_evacZoneWaypoint setWaypointBehaviour "CARELESS";
	_evacZoneWaypoint setWaypointType "MOVE";
	_evacZoneWaypoint setWaypointCompletionRadius 5;
	_evacZoneWaypoint setWaypointSpeed  "FULL" ;
	_evacZoneWaypoint setWaypointStatements ["true","evacChopper land 'LAND';"];
	_evacZoneWaypoint setWaypointCombatMode "BLUE";
	_evacZoneWaypoint setWaypointType "GETOUT";
	waitUntil{uiSleep 1; {_x in evacChopper} count units group evacChopperPilot == 0};
	{deleteWaypoint _x} forEach wayPoints evacChopperGroup;
	deleteVehicle evacChopperPilot;
	waitUntil{uiSleep 1; count units group evacChopperPilot == 0};
	deleteGroup evacChopperGroup;
	evacChopper setDir _chopperDir;
	evacChopper setPosATL _chopperStartPos;
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

//Delete the target zone marker
deleteVehicle _heliHRescue;

//delete the Smoke/Flare marker
deleteVehicle _finishMarker;

//We delete the AI Pilot his group and the Evac-Zone Marker
//Wait until Pilot left the Chopper
waitUntil{uiSleep 1; {_x in evacChopper} count units group evacChopperPilot == 0};
{deleteWaypoint _x} forEach wayPoints evacChopperGroup;
deleteVehicle evacChopperPilot;

//Wait until the pilot is deleted so we can delete the group
waitUntil{uiSleep 1; count units group evacChopperPilot == 0};
deleteGroup evacChopperGroup;