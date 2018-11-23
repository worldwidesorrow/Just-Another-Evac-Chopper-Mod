/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* OtterNas3								*/
/* 01/14/2014                         		*/
/* Updated for DayZ Epoch 1.0.6+ by JasonTM */
/* Last update: 11/20/2018            		*/
/*------------------------------------------*/

private ["_finished","_isowner","_obj","_objectID","_objectUID","_moneyInfo","_wealth","_success"];

if (dayz_actionInProgress) exitWith {localize "str_player_actionslimit" call dayz_rollingMessages;};
dayz_actionInProgress = true;

{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
s_player_evacChopper_ctrl = 1;

_obj = playersEvacField;
_isOwner = _obj getVariable["ownerPUID","0"];

if !(_isOwner == dayz_playerUID) exitWith {localize "STR_CL_EC_NOT_OWNER" call dayz_rollingMessages;};

_objectID = _obj getVariable["ObjectID","0"];
_objectUID = _obj getVariable["ObjectUID","0"];

localize "STR_CL_EC_CLEAR" call dayz_rollingMessages;

_finished = ["Medic",1] call fn_loopAction;
if (!_finished) exitWith {dayz_actionInProgress = false;};

if (evac_chopperAllowRefund) then {
	if (Z_SingleCurrency) then {
		_wealth = player getVariable[Z_MoneyVariable,0];
		player setVariable[Z_MoneyVariable,(_wealth + evac_chopperPriceZSC),true];
	} else {
		Z_Selling = true;
		_moneyInfo = 0 call Z_canAfford;
		_success = [evac_chopperPrice*10000,(_moneyInfo select 4),false,0,(_moneyInfo select 1),(_moneyInfo select 2),false] call Z_returnChange;
		if (!_success) exitWith {systemChat localize "STR_EPOCH_TRADE_GEAR_AND_BAG_FULL"; dayz_actionInProgress = false;};
	};
};

PVDZ_obj_Destroy = [_objectID,_objectUID,player,_obj,dayz_authKey];
publicVariableServer "PVDZ_obj_Destroy";

PVDZE_EvacChopperFieldsUpdate = ["rem",_obj];
publicVariableServer "PVDZE_EvacChopperFieldsUpdate";

playersEvacField = objNull;
playerHasEvacField = false;
dayz_actionInProgress = false;
s_player_evacChopper_ctrl = -1;
