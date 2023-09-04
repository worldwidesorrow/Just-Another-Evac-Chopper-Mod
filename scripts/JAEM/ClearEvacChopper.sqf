/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* OtterNas3								*/
/* 01/14/2014                         		*/
/* Updated for DayZ Epoch 1.0.6+ by JasonTM */
/* Updated for DayZ Epoch 1.0.7+ by JasonTM */
/* Last update: 05-30-2021           		*/
/*------------------------------------------*/

if(evac_chopperInProgress) exitWith {format["%1 %2",_name, localize "STR_EPOCH_PLAYER_96"] call dayz_rollingMessages;};
evac_chopperInProgress = true;

player removeAction s_player_evacRemove;
s_player_evacRemove = 1;

local _obj = playersEvacField;
local _isOwner = _obj getVariable["ownerPUID","0"];

if !(_isOwner == dayz_playerUID) exitWith {
	localize "STR_CL_EC_NOT_OWNER" call dayz_rollingMessages;
	evac_chopperInProgress = false;
	s_player_evacRemove = -1;
};

//local _objectID = _obj getVariable["ObjectID","0"];
//local _objectUID = _obj getVariable["ObjectUID","0"];

localize "STR_CL_EC_CLEAR" call dayz_rollingMessages;

local _finished = ["Medic",1] call fn_loopAction;
if (!_finished) exitWith {evac_chopperInProgress = false; s_player_evacRemove = -1;};

local _success = true;

if (evac_chopperAllowRefund) then {
	if (Z_SingleCurrency) then {
		local _wealth = player getVariable[(["cashMoney","globalMoney"] select Z_persistentMoney),0];
		player setVariable[(["cashMoney","globalMoney"] select Z_persistentMoney),(_wealth + evac_chopperPriceZSC),true];
	} else {
		Z_Selling = true;
		local _moneyInfo = 0 call Z_canAfford;
		_success = [evac_chopperPrice*10000,(_moneyInfo select 4),false,0,(_moneyInfo select 1),(_moneyInfo select 2),false] call Z_returnChange;
		//if (!_success) exitWith {systemChat localize "STR_EPOCH_TRADE_GEAR_AND_BAG_FULL"; evac_chopperInProgress = false; s_player_evacRemove = -1;};
	};
};

if (!_success) exitWith {systemChat localize "STR_EPOCH_TRADE_GEAR_AND_BAG_FULL"; evac_chopperInProgress = false; s_player_evacRemove = -1;};

PVDZ_obj_Destroy = [netID player,netID _obj,dayz_authKey];
publicVariableServer "PVDZ_obj_Destroy";

PVDZE_EvacChopperFieldsUpdate = ["rem",_obj];
publicVariableServer "PVDZE_EvacChopperFieldsUpdate";

playersEvacField = objNull;
playerHasEvacField = false;
evac_chopperInProgress = false;
s_player_evacRemove = -1;