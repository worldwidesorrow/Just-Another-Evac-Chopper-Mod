/*------------------------------------*/
/* JAEM                               */
/* Just another Chopper-Evac Mod v1.4 */
/* OtterNas3                          */
/* 01/14/2014                         */
/* Last update: 06/14/2014            */
/*------------------------------------*/
/*
Updated for DayZ Epoch 1.0.6.2 with ZSC support by JasonTM
*/

private ["_playerMoney","_finished","_sfx","_dis","_isowner","_isfriendly","_IsNearPlot","_distance","_plotcheck","_requireplot","_friendlies","_ownerID","_nearestPole","_canBuild","_vector","_allNearRescueFields","_locationPlayer","_cnt","_objID","_targetVehicle","_hasBriefcase","_location","_dir","_obj"];

if (dayz_actionInProgress) exitWith {localize "str_player_actionslimit" call dayz_rollingMessages;};
dayz_actionInProgress = true;

{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
s_player_evacChopper_ctrl = 1;

if (!DZE_permanentPlot) exitWith {"You must have DZE_permanentPlot turned on to use this mod." call dayz_rollingMessages;};

if (player getVariable["combattimeout",0] >= diag_tickTime) exitWith {dayz_actionInProgress = false; localize "str_epoch_player_43" call dayz_rollingMessages;};

//Getting the target Vehicle and needed variables
_targetVehicle = _this select 3;
_location = [_targetVehicle] call FNC_GetPos;
_dir = getDir _targetVehicle;

if (!DZE_BuildOnRoads) then {
		if (isOnRoad _location) exitWith {localize "STR_EPOCH_BUILD_FAIL_ROAD" call dayz_rollingMessages;};
		dayz_actionInProgress = false;
};

//Because we can only make a Helipad on Terrain and not on buildings or buildables
//We check if the Chopper height is below 1m above Terrain
if ((_location) select 2 >= 3) then {
	dayz_actionInProgress = false;
	"Sorry but Evac-Choppers need to be built on flat Terrain" call dayz_rollingMessages;
	"Make sure you dont stand on a Building or a built object!" call dayz_rollingMessages;
};
//Check if player has the needed amount of money to pay for the Evac-Chopper. If not exit script
if (evac_chopperUseZSC && Z_singleCurrency) then {
	_playerMoney = player getVariable [Z_MoneyVariable,0];
	if (_playerMoney < evac_chopperPriceZSC) exitWith {
		dayz_actionInProgress = false;
		format["Making an Evac-Chopper costs %1 Coins", evac_chopperPriceZSC] call dayz_rollingMessages;
		breakOut "exit";
	};
} else {	
	_hasBriefcase = {_x == "ItemBriefcase100oz"} count (magazines player);
	if (_hasBriefcase < evac_chopperPrice) exitWith {
		dayz_actionInProgress = false;
		format["Making an Evac-Chopper costs %1 Full Briefcases", evac_chopperPrice] call dayz_rollingMessages;
	};
};

//If player already has an Evac-Chopper tell him that only 1 Evac-Chopper is allowed
if (playerHasEvacField) exitWith {
	dayz_actionInProgress = false;
	"WARNING! You already have an Evac-Chopper" call dayz_rollingMessages;
};

// Initialize Build Check Variables
_canBuild = false;
_nearestPole = objNull;
_ownerID = 0;
_friendlies = [];
_requireplot = DZE_requireplot;
_plotcheck = [player, false] call FNC_find_plots;
_distance = DZE_PlotPole select 0;
_IsNearPlot = _plotcheck select 1;
_nearestPole = _plotcheck select 2;

// Start Build Checks
if (_IsNearPlot == 0) then {
	if (_requireplot == 0) then {
		_canBuild = true;
	};
} else {
	_ownerID = _nearestPole getVariable["CharacterID","0"];
	if (dayz_characterID == _ownerID) then {
		_canBuild = true;
	} else {
		if (DZE_permanentPlot) then {
			_buildcheck = [player, _nearestPole] call FNC_check_access;
			_isowner = _buildcheck select 0;
			_isfriendly = ((_buildcheck select 1) or (_buildcheck select 3));
			if (_isowner || _isfriendly) then {
				_canBuild = true;
			};
		} else {
			_friendlies	= player getVariable ["friendlyTo",[]];
			if (_ownerID in _friendlies) then {
				_canBuild = true;
			};
		};
	};
};

// If build checks do not pass, exit script
if (!_canBuild) exitWith {
	dayz_actionInProgress = false;
	if (_isNearPlot == 0) then {
		format[localize "STR_EPOCH_PLAYER_135",localize "str_epoch_player_246",_distance] call dayz_rollingMessages;
	} else {
		localize "STR_EPOCH_PLAYER_134" call dayz_rollingMessages;
	};
};

//Before we start the building process, we give the player a warning that the Evac-Chopper needs free sight around
"WARNING! Evac-Chopper needs free sight to all sides, Make sure you have no objects like Buildings or Trees around!" call dayz_rollingMessages;
uiSleep 3;
"Building Evac-Chopper, move to cancel" call dayz_rollingMessages;

//Build Animation
_finished = ["Medic",1] call fn_loopAction;
if (!_finished) exitWith {dayz_actionInProgress = false;"You have canceled your Evac_Chopper" call dayz_rollingMessages;};

// Remove money from player
if (evac_chopperUseZSC && Z_singleCurrency) then {
	_playerMoney = player getVariable [Z_MoneyVariable,0];
	player setVariable [Z_MoneyVariable,_playerMoney - evac_chopperPriceZSC,true];
	"Thanks for your payment!" call dayz_rollingMessages;
	call player_forceSave;
} else {
	[player, "ItemBriefcase100oz", evac_chopperPrice] call BIS_fnc_invRemove;
	"Thanks for your payment!" call dayz_rollingMessages;
	call player_forceSave;
};

// Build helipad
_obj = createVehicle ["HeliHRescue", _location, [], 0, "CAN_COLLIDE"];
_obj addEventHandler ["HandleDamage", {false}];
_obj enableSimulation false;
_obj setDir _dir;
_obj setPosATL _location;
_vector = [(vectorDir _obj),(vectorUp _obj)];

// Send publishing information to server
_obj setVariable ["CharacterID",dayz_characterID,true];
if (DZE_permanentPlot) then {
	_obj setVariable ["ownerPUID",dayz_playerUID,true];
	PVDZ_obj_Publish = [dayz_characterID,_obj,[_dir,_location,dayz_playerUID,_vector],[],player,dayz_authKey];
} else {
	PVDZ_obj_Publish = [dayz_characterID,_obj,[_dir,_location, _vector],[],player,dayz_authKey];
};
publicVariableServer "PVDZ_obj_Publish";
PVDZE_EvacChopperFieldsUpdate = ["add",_obj];
publicVariableServer "PVDZE_EvacChopperFieldsUpdate";

//Set end variables
dayz_actionInProgress = false;
s_player_evacChopper_ctrl = -1;
playerHasEvacField = true;
playersEvacField = _obj;

"You have made an Evac-Chopper" call dayz_rollingMessages;

//Thats it for the creation part of the Evac-Chopper
//Hope you enjoyed it :)
//Moo,
//Otter
