/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* OtterNas3								*/
/* 01/14/2014                         		*/
/* Updated for DayZ Epoch 1.0.6+ by JasonTM */
/* Last update: 11/20/2018            		*/
/*------------------------------------------*/

private ["_itemText","_buildcheck","_playerMoney","_finished","_sfx","_dis","_isowner","_isfriendly","_IsNearPlot","_distance","_plotcheck","_requireplot","_friendlies","_ownerID","_nearestPole","_canBuild","_vector","_allNearRescueFields","_locationPlayer","_cnt","_objID","_targetVehicle","_hasBriefcase","_location","_dir","_obj"];

if (!DZE_permanentPlot) exitWith {diag_log "EVAC-CHOPPER: You have to have DZE_permanentPlot enabled.";};

_name = localize "STR_CL_EC_NAME";

if (dayz_actionInProgress) exitWith {localize "str_player_actionslimit" call dayz_rollingMessages;};
dayz_actionInProgress = true;

{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
s_player_evacChopper_ctrl = 1;

if (player getVariable["combattimeout",0] >= diag_tickTime) exitWith {dayz_actionInProgress = false; localize "str_epoch_player_43" call dayz_rollingMessages;};

_targetVehicle = _this select 3;
_location = [_targetVehicle] call FNC_GetPos;
_dir = getDir _targetVehicle;

if (!DZE_BuildOnRoads) then {
		if (isOnRoad _location) exitWith {localize "STR_EPOCH_BUILD_FAIL_ROAD" call dayz_rollingMessages;};
		dayz_actionInProgress = false;
};

if (playerHasEvacField) exitWith {
	dayz_actionInProgress = false;
	format[localize "STR_CL_EC_EXISTS",_name] call dayz_rollingMessages;
};

if ((_location) select 2 >= 3) then {
	dayz_actionInProgress = false;
	format[localize "STR_EPOCH_PLAYER_168",1] call dayz_rollingMessages;
};

_amount = if (Z_SingleCurrency) then {evac_chopperPriceZSC} else {evac_chopperPrice*10000};
_enoughMoney = false;
_moneyInfo = [false,[],[],[],0];
_wealth = player getVariable[Z_MoneyVariable,0];

if (Z_SingleCurrency) then {
	_enoughMoney = (_wealth >= _amount);
} else {
	Z_Selling = false;
	if (Z_AllowTakingMoneyFromVehicle) then {false call Z_checkCloseVehicle};
	_moneyInfo = _amount call Z_canAfford;
	_enoughMoney = _moneyInfo select 0;
};

_success = if (Z_SingleCurrency) then {true} else {[player,_amount,_moneyInfo,true,0] call Z_payDefault};

if (!_success && {_enoughMoney}) exitWith {systemChat localize "STR_EPOCH_TRADE_GEAR_AND_BAG_FULL"; dayz_actionInProgress = false;};

_fail = false;

if (_enoughMoney) then {
	
	_success = if (Z_SingleCurrency) then {_amount <= _wealth} else {true};
	
	if (_success) then {

		_canBuild = false;
		_nearestPole = objNull;
		_ownerID = 0;
		_friendlies = [];
		_requireplot = DZE_requireplot;
		_plotcheck = [player, false] call FNC_find_plots;
		_distance = DZE_PlotPole select 0;
		_IsNearPlot = _plotcheck select 1;
		_nearestPole = _plotcheck select 2;

		if (_IsNearPlot == 0) then {
			if (_requireplot == 0) then {
				_canBuild = true;
			};
		} else {
			_ownerID = _nearestPole getVariable["CharacterID","0"];
			if (dayz_characterID == _ownerID) then {
				_canBuild = true;
			} else {
				_buildcheck = [player, _nearestPole] call FNC_check_access;
				_isowner = _buildcheck select 0;
				_isfriendly = ((_buildcheck select 1) or (_buildcheck select 3));
				if (_isowner || _isfriendly) then {
					_canBuild = true;
				};
			};
		};

		if (!_canBuild) exitWith {
			dayz_actionInProgress = false;
			if (_isNearPlot == 0) then {
				format[localize "STR_EPOCH_PLAYER_135",localize "str_epoch_player_246",_distance] call dayz_rollingMessages;
			} else {
				localize "STR_EPOCH_PLAYER_134" call dayz_rollingMessages;
			};
			_fail = true;
		};

		format[localize "STR_EPOCH_PLAYER_138",_name] call dayz_rollingMessages;

		_finished = ["Medic",1] call fn_loopAction;
		if (!_finished) exitWith {dayz_actionInProgress = false; _fail = true;};
		
		if (Z_SingleCurrency) then {player setVariable[Z_MoneyVariable,(_wealth - _amount),true];} else {[player,_amount,_moneyInfo,false,0] call Z_payDefault};
		
		_obj = createVehicle ["HeliHRescue", _location, [], 0, "CAN_COLLIDE"];
		_obj addEventHandler ["HandleDamage", {false}];
		_obj enableSimulation false;
		_obj setDir _dir;
		_obj setPosATL _location;
		_vector = [(vectorDir _obj),(vectorUp _obj)];
		_obj setVariable ["CharacterID",dayz_characterID,true];
		_obj setVariable ["ownerPUID",dayz_playerUID,true];
		
		PVDZ_obj_Publish = [dayz_characterID,_obj,[_dir,_location,dayz_playerUID,_vector],[],player,dayz_authKey];
		publicVariableServer "PVDZ_obj_Publish";
		
		PVDZE_EvacChopperFieldsUpdate = ["add",_obj];
		publicVariableServer "PVDZE_EvacChopperFieldsUpdate";

		dayz_actionInProgress = false;
		s_player_evacChopper_ctrl = -1;
		playerHasEvacField = true;
		playersEvacField = _obj;

	} else {
		systemChat localize "STR_EPOCH_TRADE_DEBUG";
	};
	
	if (_fail) exitWith {};
} else {
	_itemText = if (Z_SingleCurrency) then {CurrencyName} else {[_amount,true] call z_calcCurrency};
	if (Z_SingleCurrency) then {
		format[localize "STR_CL_EC_NEED_COINS",[_amount] call BIS_fnc_numberText,_itemText,_name] call dayz_rollingMessages;
	} else {
		format[localize "STR_CL_EC_NEED_BRIEFCASES",_itemText,_name] call dayz_rollingMessages;
	};
};

