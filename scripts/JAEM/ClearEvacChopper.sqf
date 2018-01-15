/*------------------------------------*/
/* JAEM                               */
/* Just another Chopper-Evac Mod v1.4 */
/* OtterNas3                          */
/* 01/14/2014                         */
/* Last update: 06/14/2014            */
/*------------------------------------*/
// Updated for DayZ Epoch 1.0.6.2 by JasonTM.

/*Files used as reference to update this file: remove.sqf */

private ["_finished","_isfriendly","_isowner","_nearestPole","_IsNearPlot","_plotcheck","_canRemove","_isOwnerOfObj","_objOwnerID","_obj","_locationPlayer","_objectID","_objectUID","_location1","_location2"];

if (dayz_actionInProgress) exitWith {localize "str_player_actionslimit" call dayz_rollingMessages;};
dayz_actionInProgress = true;

{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
s_player_evacChopper_ctrl = 1;

_obj = playersEvacField;
_objOwnerID = "0";
_isOwnerOfObj = false;

if (DZE_permanentPlot) then {
	_objOwnerID = _obj getVariable["ownerPUID","0"];
	_isOwnerOfObj = (_objOwnerID == dayz_playerUID);
} else {
	_objOwnerID = _obj getVariable["CharacterID","0"];
	_isOwnerOfObj = (_objOwnerID == dayz_characterID);
};

_objectID = _obj getVariable["ObjectID","0"];
_objectUID = _obj getVariable["ObjectUID","0"];

_canRemove = false;
_plotcheck = [player, false] call FNC_find_plots;
_IsNearPlot = _plotcheck select 1;
_nearestPole = _plotcheck select 2;

if(_IsNearPlot >= 1) then {
	// Since there are plot poles nearby we need to check ownership && friend status
	_buildcheck = [player, _nearestPole] call FNC_check_access;
	_isowner = _buildcheck select 0;
	_isfriendly = ((_buildcheck select 1) or (_buildcheck select 3));
	if (_isowner || _isfriendly) then {
		_canRemove = true;
	};
};

// If canRemove checks do not pass, exit script
if (!_canRemove) exitWith {
	dayz_actionInProgress = false;
	if (_isNearPlot == 0) then {
		"You are unable to disable the Evac-Chopper" call dayz_rollingMessages;
	};
};

if (_canRemove) then {
	"Disabling Evac-Chopper, move to cancel" call dayz_rollingMessages;
	//Build Animation
	_finished = ["Medic",1] call fn_loopAction;
	if (!_finished) exitWith {dayz_actionInProgress = false; "You have canceled disabling your Evac-Chopper" call dayz_rollingMessages;};
	
	// Sound Effects
	_dis=20;
	_sfx = "repair";
	[player,_sfx,0,false,_dis] call dayz_zombieSpeak;
	
	if (_finished) then {
		//Send Information to the server
		PVDZ_obj_Destroy = [_objectID,_objectUID,player,_obj,dayz_authKey];
		publicVariableServer "PVDZ_obj_Destroy";
		PVDZE_EvacChopperFieldsUpdate = ["rem",_obj];
		publicVariableServer "PVDZE_EvacChopperFieldsUpdate";
		
		// Set end variables
		playersEvacField = objNull;
		playerHasEvacField = false;
		dayz_actionInProgress = false;
		s_player_evacChopper_ctrl = -1;
	
		"You have disabled your Evac-Chopper, you can choose another location" call dayz_rollingMessages;
	};
};