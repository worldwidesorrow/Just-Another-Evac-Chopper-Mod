/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* OtterNas3								*/
/* 01/14/2014                         		*/
/* Updated for DayZ Epoch 1.0.6+ by JasonTM */
/* Updated for DayZ Epoch 1.0.7+ by JasonTM */
/* Last update: 05-30-2021           		*/
/*------------------------------------------*/

if (!DZE_permanentPlot) exitWith {diag_log "EVAC-CHOPPER: You have to have DZE_permanentPlot enabled.";};

if (evac_chopperInProgress) exitWith {format["%1 %2",_name, localize "STR_EPOCH_PLAYER_96"] call dayz_rollingMessages;};
evac_chopperInProgress = true;

{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
s_player_evacChopper_ctrl = 1;

if (player getVariable["combattimeout",0] >= diag_tickTime) exitWith {
	evac_chopperInProgress = false; 
	localize "str_epoch_player_43" call dayz_rollingMessages;
};

local _name = localize "STR_CL_EC_NAME";
local _veh = _this select 3;
local _pos = [_veh] call FNC_GetPos;
local _dir = getDir _veh;

if (!DZE_BuildOnRoads) then {
	if (isOnRoad _pos) exitWith {localize "STR_EPOCH_BUILD_FAIL_ROAD" call dayz_rollingMessages;};
	evac_chopperInProgress = false;
};

if (playerHasEvacField) exitWith {
	evac_chopperInProgress = false;
	format[localize "STR_CL_EC_EXISTS",_name] call dayz_rollingMessages;
};

if ((_pos) select 2 >= 3) exitWith {
	evac_chopperInProgress = false;
	format[localize "STR_EPOCH_PLAYER_168",1] call dayz_rollingMessages;
};

local _amount = [(evac_chopperPrice * 10000), evac_chopperPriceZSC] select Z_SingleCurrency;
local _enoughMoney = false;
local _moneyInfo = [false,[],[],[],0];
local _wealth = player getVariable [(["cashMoney","globalMoney"] select Z_persistentMoney),0];

if (Z_SingleCurrency) then {
	_enoughMoney = (_wealth >= _amount);
} else {
	Z_Selling = false;
	if (Z_AllowTakingMoneyFromVehicle) then {false call Z_checkCloseVehicle};
	_moneyInfo = _amount call Z_canAfford;
	_enoughMoney = _moneyInfo select 0;
};

local _success = [([player,_amount,_moneyInfo,true,0] call Z_payDefault),true] select Z_SingleCurrency;
if (!_success && _enoughMoney) exitWith {systemChat localize "STR_EPOCH_TRADE_GEAR_AND_BAG_FULL"; evac_chopperInProgress = false;};

if (_enoughMoney) then {
	_success = [true,(_amount <= _wealth)] select Z_SingleCurrency;
	if (_success) then {
		local _canBuild = false;
		local _nearestPole = objNull;
		local _ownerID = 0;
		local _requireplot = DZE_requireplot;
		local _plotcheck = [player, false] call FNC_find_plots;
		local _distance = DZE_PlotPole select 0;
		local _IsNearPlot = _plotcheck select 1;
		local _nearestPole = _plotcheck select 2;

		if (_IsNearPlot == 0) then {
			if (_requireplot == 0) then {
				_canBuild = true;
			};
		} else {
			_ownerID = _nearestPole getVariable["CharacterID","0"];
			if (dayz_characterID == _ownerID) then {
				_canBuild = true;
			} else {
				local _buildcheck = [player, _nearestPole] call FNC_check_access;
				local _isowner = _buildcheck select 0;
				local _isfriendly = ((_buildcheck select 1) or (_buildcheck select 3));
				if (_isowner || _isfriendly) then {
					_canBuild = true;
				};
			};
		};

		if (!_canBuild) exitWith {
			if (_isNearPlot == 0) then {
				format[localize "STR_EPOCH_PLAYER_135",localize "str_epoch_player_246",_distance] call dayz_rollingMessages;
			} else {
				localize "STR_EPOCH_PLAYER_134" call dayz_rollingMessages;
			};
		};

		format[localize "STR_EPOCH_PLAYER_138",_name] call dayz_rollingMessages;

		local _finished = ["Medic",1] call fn_loopAction;
		if (!_finished) exitWith {};
		
		if (Z_SingleCurrency) then {player setVariable[(["cashMoney","globalMoney"] select Z_persistentMoney),(_wealth - _amount),true];} else {[player,_amount,_moneyInfo,false,0] call Z_payDefault};
		
		local _obj = createVehicle ["HeliHRescue", _pos, [], 0, "CAN_COLLIDE"];
		_obj addEventHandler ["HandleDamage", {false}];
		_obj enableSimulation false;
		_obj setDir _dir;
		_obj setPosATL _pos;
		local _vector = [(vectorDir _obj),(vectorUp _obj)];
		_obj setVariable ["CharacterID",dayz_characterID,true];
		_obj setVariable ["ownerPUID",dayz_playerUID,true];
		
		PVDZ_obj_Publish = [dayz_characterID,_obj,[_dir,_pos,dayz_playerUID,_vector],[],player,dayz_authKey];
		publicVariableServer "PVDZ_obj_Publish";
		
		PVDZE_EvacChopperFieldsUpdate = ["add",_obj];
		publicVariableServer "PVDZE_EvacChopperFieldsUpdate";

		playerHasEvacField = true;
		playersEvacField = _obj;

	} else {
		systemChat localize "STR_EPOCH_TRADE_DEBUG";
	};
} else {
	local _itemText = if (Z_SingleCurrency) then {CurrencyName} else {[_amount,true] call z_calcCurrency};
	if (Z_SingleCurrency) then {
		format[localize "STR_CL_EC_NEED_COINS",[_amount] call BIS_fnc_numberText,_itemText,_name] call dayz_rollingMessages;
	} else {
		format[localize "STR_CL_EC_NEED_BRIEFCASES",_itemText,_name] call dayz_rollingMessages;
	};
};

evac_chopperInProgress = false;
s_player_evacChopper_ctrl = -1;
