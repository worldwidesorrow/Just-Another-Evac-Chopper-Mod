Just Another Evac-Chopper Mod v1.6
==============

This is an updated version of JAEM by OtterNas3. This version is updated to be compatible with DayZ Epoch 1.0.6.2.
I have upgraded this version to be ZSC and Deploy Anything compatible. ZSC can be used as an option to pay for the creation of an evac chopper and Mudzereli's right-click actions can be used to call the evac chopper.

### Installation Instructions

1. Click ***[Clone or Download](https://github.com/worldwidesorrow/JAEM-v1.5/archive/JAEM-v1.6.zip)*** the green button on the right side of the Github page.

	> Recommended PBO tool for all "pack", "repack", or "unpack" steps: ***[PBO Manager](http://www.armaholic.com/page.php?id=16369)***
  
Note: all of the files that need to be modified are included in this repository if you prefer to use a merging tool to update your existing files. Otherwise, follow the instructions below.

### This install is rather complicated, so make sure you back up your existing mission and server PBOs in case you make a mistake.

2. Extract the downloaded folder and open it.
3. Unpack your mission PBO.
4. Copy the ***scripts*** folder over to the root of your mission folder, or if you already have a scripts folder copy the ***JAEM*** folder into it.
5. Copy the ***dayz_code*** folder over to the root of your mission folder if you don't already have it. If you already have a dayz_code folder and the same files from a previous install, you will edit your existing files in step 7.

6. init.sqf

	Find this line:

	```sqf
	call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\variables.sqf";	
	```
	
	Add the following line ***below*** it if you don't already have it from a previous install:
	
	```sqf
	call compile preprocessFileLineNumbers "dayz_code\init\variables.sqf";
	```
  
  	Find this line:

	```sqf
	call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\compiles.sqf";
	```
	
  	Add the following line ***below*** it if you don't already have it from a previous install:
	
	```sqf
	call compile preprocessFileLineNumbers "dayz_code\init\compiles.sqf";
	```
  
  	Find this line:

	```sqf
	waitUntil {scriptDone progress_monitor};
	```
	
  	Add the following lines ***above*** it. You might already have the remote_messages line from another mod:
	
	```sqf
	[] execVM "scripts\JAEM\EvacChopper_init.sqf";
	[] execVM "dayz_code\compile\remote_message.sqf";
	```

7. If you already have a custom fn_selfActions.sqf in directory dayz_code\init, open that file. If not you should have copied the one over from the download in step 5.

	Find this block of code:
	
	```sqf
	if (_isPZombie) then {
		if (s_player_attack < 0) then {
			s_player_attack = player addAction [localize "STR_EPOCH_ACTIONS_ATTACK", "\z\addons\dayz_code\actions\pzombie\pz_attack.sqf", _cursorTarget, 6, false, true];
		};
		if (s_player_callzombies < 0) then {
			s_player_callzombies = player addAction [localize "STR_EPOCH_ACTIONS_RAISEHORDE", "\z\addons\dayz_code\actions\pzombie\call_zombies.sqf",player, 5, true, false];
		};
		if (s_player_pzombiesvision < 0) then {
			s_player_pzombiesvision = player addAction [localize "STR_EPOCH_ACTIONS_NIGHTVIS", "\z\addons\dayz_code\actions\pzombie\pz_vision.sqf", [], 4, false, true, "nightVision", "_this == _target"];
		};
		if (!isNull _cursorTarget && (player distance _cursorTarget < 3)) then {
			_isZombie = _cursorTarget isKindOf "zZombie_base";
			_isHarvested = _cursorTarget getVariable["meatHarvested",false];
			_isMan = _cursorTarget isKindOf "Man"; //includes animals and zombies
			if (!alive _cursorTarget && _isMan && !_isZombie && !_isHarvested) then {
				if (s_player_pzombiesfeed < 0) then {
					s_player_pzombiesfeed = player addAction [localize "STR_EPOCH_ACTIONS_FEED", "\z\addons\dayz_code\actions\pzombie\pz_feed.sqf",_cursorTarget, 3, true, false];
				};
			} else {
				player removeAction s_player_pzombiesfeed;
				s_player_pzombiesfeed = -1;
			};
		} else {
			player removeAction s_player_pzombiesfeed;
			s_player_pzombiesfeed = -1;
		};
	};
	```
	
	Add the following block of code below it ***below*** it:
	
	```sqf
	// Call EvacChopper
	if (playerHasEvacField && {!evac_chopperUseClickActions}) then {
		if (player distance playersEvacField >= evac_chopperMinDistance && {!evac_chopperInProgress} && {isNull cursorTarget} && {speed player < 1} && {!_inVehicle}) then {
			if (evac_chopperNeedRadio == 1) then {
				if ("ItemRadio" in (items player)) then {
					if (s_player_evacCall < 0) then {
						s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",[],-1000,false,false,"",""];
					};
				};
			} else {
				if (s_player_evacCall < 0) then {
					s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",[],-1000,false,false,"",""];
				};
			};
		} else {
			player removeAction s_player_evacCall;
			s_player_evacCall = -1;
		};
	};
	```
	
   	Find this block of code:

	```sqf
	} else {
		if (_hasKey || _oldOwner) then {
		_lock = player addAction [format[localize "STR_EPOCH_ACTIONS_LOCK",_text], "\z\addons\dayz_code\actions\lock_veh.sqf",_cursorTarget, 1, true, true];
		s_player_lockunlock set [count s_player_lockunlock,_lock];
		s_player_lockUnlock_crtl = 1;
		};
	};
	```
	
  	Add the following block of code below it ***below*** it:
	
	```sqf
	// EvacChopper
	if (s_player_evacChopper_ctrl < 0) then {
		private ["_setEvac","_clearEvac"];
		if (_hasKey || _oldOwner) then {
			if ((_cursorTarget isKindOf "Helicopter") && (!playerHasEvacField)) then {
				_setEvac = player addAction [("<t color=""#0000FF"">" + ("Set Evac-Chopper") + "</t>"),"scripts\JAEM\SetEvacChopper.sqf",_cursorTarget,3,false,false];
				s_player_evacChopper set [count s_player_evacChopper,_setEvac];
				s_player_evacChopper_ctrl = 1;
			};
			if ((_cursorTarget isKindOf "Helicopter") && playerHasEvacField && (player distance playersEvacField < 10)) then {
				_clearEvac = player addAction [("<t color=""#0000FF"">" + ("Clear Evac-Chopper") + "</t>"),"scripts\JAEM\ClearEvacChopper.sqf",_cursorTarget,4,false,false];
				s_player_evacChopper set [count s_player_evacChopper,_clearEvac];
				s_player_evacChopper_ctrl = 1;
			};
		};
	} else {
		{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
		s_player_evacChopper_ctrl = -1;
	};
	```
  
  	Find this line (around line 1104):

	```sqf
	s_player_lockUnlock_crtl = -1;
	```
	
  	Add the following lines ***below*** it:
	
	```sqf
	{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
	s_player_evacChopper_ctrl = -1;
	```
  
8. If you already have a custom variables.sqf in directory dayz_code\init, open that file. If not you should have copied the one over from the download in step 5.
	
	Add the following lines to your custom variables.sqf.
	
	```sqf
	DayZ_SafeObjects set [count DayZ_SafeObjects, "HeliHRescue"];
	
	// Evac Chopper Static Variables
	playerHasEvacField = false; // DO NOT CHANGE.
	playersEvacField = objNull; // DO NOT CHANGE.
	s_player_evacChopper = []; // DO NOT CHANGE.
	evac_chopperInProgress = false; //DO NOT CHANGE.

	// Evac Chopper Config Variables
	evac_chopperPrice = 1; // This is the price players pay in full briefcases to set up an evac chopper.
	evac_chopperPriceZSC = 100000; // Price for evac chopper if you have ZSC Installed and evac_chopperUseZSC set to true.
	evac_chopperAllowRefund = false; // Allow players to get their money back when they remove an evac-chopper field.
	evac_chopperMinDistance = 500; // Minimum distance for player to call evac chopper. Do not set this lower than 500.
	evac_chopperZoneMarker = 0; // Evac zone marker type (0 = Landingpad | 1 = Smoke).
	evac_chopperNeedRadio = 0; // 1 - Require player to have a radio in gear to call evac chopper | 0 - Doesn't require radio to call evac chopper.
	evac_chopperUseClickActions = false; // If you have Deploy Anything installed and are going to use click actions to call the evac chopper, set this to true (disables call chopper self-action loop).
	evac_ChopperDisabledMarker = true; // Place a private map marker of the evac chopper's location
	
	if (isServer) then {"CallEvacChopper" addPublicVariableEventHandler {(_this select 1) spawn server_callEvacChopper;};};
	```
  
  	Add the entire block of code below this line if you don't already have it:
  
   ```sqf
    	//Player self-action handles
	```
	If you already have this section from a prior install then just add the following lines to the bottom above the };

	```sqf
	s_player_evacChopper_ctrl = -1;
	s_player_evacCall = -1;
	```
	Make sure you compare your file with the one in the download so the lines end up in the correct place.

9. If you already have a custom compiles.sqf in directory dayz_code\init, open that file. If not you should have copied the one over from the download in step 5.

 	Copy the following line over to the !isDedicated section if you don't have it already from a prior install:
  
    ```sqf
    	fnc_usec_selfactions = compile preprocessFileLineNumbers "dayz_code\compile\fn_selfActions.sqf";
  	```
    
10. This mod is dependent on the Epoch community stringtable. Download the stringtable ***[here](https://github.com/oiad/communityLocalizations/)*** and place file stringTable.xml in the root of your mission folder.
11. Repack your mission PBO.

12. Unpack your server PBO and open ***dayz_server\system\server_monitor.sqf***

	Find this line:

	```sqf
	_DZE_VehObjects = [];
	```
	
	Add the following line ***below*** it:
	
	```sqf
	PVDZE_EvacChopperFields = [];
	```
  
  	Find this line:

	```sqf
	if (_isDZ_Buildable || {(_isSafeObject && !_isTrapItem)}) then {
	```
	
	Add the following block of code ***above*** it:
	
	```sqf
	if ((typeOf _object) == "HeliHRescue") then {
				PVDZE_EvacChopperFields set [count PVDZE_EvacChopperFields, _object];
			};
	```
  
  	Find this line:

	```sqf
	publicVariable "sm_done";
	```
	
	Add the following block of code ***below*** it:
	
	```sqf
	if (isServer && (isNil "EvacServerPreload")) then {
    		publicVariable "PVDZE_EvacChopperFields";
    
   	 ON_fnc_evacChopperFieldsUpdate = {
        	private ["_action","_targetField"];
        	_action = _this select 0;
        	_targetField = _this select 1;
        
        if (_action == "add") then {
            PVDZE_EvacChopperFields = PVDZE_EvacChopperFields + [_targetField];
        };
        
        if (_action == "rem") then {
            PVDZE_EvacChopperFields = PVDZE_EvacChopperFields - [_targetField];
        };
        
        publicVariable "PVDZE_EvacChopperFields";
    	};

    	"PVDZE_EvacChopperFieldsUpdate" addPublicVariableEventHandler {(_this select 1) spawn ON_fnc_evacChopperFieldsUpdate};

    	EvacServerPreload = true;
	};
	```
  
13. open ***dayz_server\init\server_functions.sqf***

	Find this line:
	
	```sqf
	spawn_vehicles = compile preprocessFileLineNumbers "\z\addons\dayz_server\compile\spawn_vehicles.sqf";
	```
	
	Add the following line ***below*** it:
	
	```sqf
	server_callEvacChopper = compile preprocessFileLineNumbers "\z\addons\dayz_server\compile\server_callEvacChopper.sqf";
	```
	
14. Copy the file ***dayz_server\compile\server_callEvacChopper.sqf*** to the same directory in your server folder.

15. Repack you server PBO.

16. A complete set of the necessary BattlEye files have been provided in the BattlEye folder. If you have a fresh server or prefer to diffmerge then you can use these files. Otherwise follow the instructions below.

Note: These are to be used with the stock BattlEye filters that come with the 1.0.6.2 server files. If you are using a different set of filters then the numbers will not line up.

1. publicvariable.txt

	Add this to the end of line 2:
  
  	```sqf
	!=PVDZE_EvacChopperFieldsUpdate !=CallEvacChopper
	```
	
2. createvehicle.txt

	Add this to the end of line 2:
  
  	```sqf
	!="HeliHRescue"
	```
	
3. scripts.txt

	Add this to the end of line 17
  
  	```sqf
	!"\\dayz_code\\init\\compiles.sqf\"\nif (!isDedicated) then {\ndiag_log \"Loading custom client com"
	```
	
	Add this to the end of line 2:
  
  	```sqf
	!=" (s_player_evacCall < 0) then {\ns_player_evacCall = player addAction [(\"<t color=\"\"#0000FF\"\">\" + (\"Call Evac-Chopper\") + \"</t>\")"
	```
	
	Add this to the end of line 21:
 
  	```sqf
	!="time = time;\n_chopperPos = getPos _evacChopper;\n_marker = createMarkerLocal [\"EvacChopper\",_chopperPos];\n_marker setMarkerColorL"
	```
	
	Add this to the end of line 27:
 
  	```sqf
	!="me) > evac_chopperMarkerTimeout) then {_recovered = true; deleteMarkerLocal _marker; \"EVAC Chopper map marker deleted\" call dayz"
	```
	
	Add this to the end of line 38:
  
  	```sqf
	!="_this select 4;};\n\nif (_flightStatus == \"Arrived\") exitWith\n{\nhintSilent parseText format [\"\n			<t size='1.15'	font='Bitstream'a"
	```
	
	Add this to the end of line 58:
  
  	```sqf
	!="= createMarkerLocal [\"EvacChopper\",_chopperPos];\n_marker setMarkerColorLocal \"ColorBlack\";\n_marker setMarkerTypeLocal \"mil_objec"
	```
	
	Add this to the end of line 63:
  
  	```sqf
	!="ck\";\n_marker setMarkerTypeLocal \"mil_objective\";\n_marker setMarkerTextLocal \"EvacChopper\";\nwhile {!_recovered} do {\nif (!alive _"
	```
	
	Add this to the end of line 64:
  
  	```sqf
	!="rPos];\n_marker setMarkerColorLocal \"ColorBlack\";\n_marker setMarkerTypeLocal \"mil_objective\";\n_marker setMarkerTextLocal \"EvacCho"
	```
	
	Add this to the end of line 72:
  
  	```sqf
	!="FNC_GetPos;\n_canceled = false;\n\n\nfor \"_p\" from 1 to 5 do\n{\nsystemChat(format [\"Evac-Chopper get called in %1s - Move to cancel!\""
	```
	
***Deploy Anything Option***

If you want to use right click actions in deploy anything to call the evac chopper instead of the built in self-actions, then   find this variable in your custom variables.sqf
  
   Find this variable
  
  	```sqf
	evac_chopperUseClickActions = false;
	```
   
   and change to:
  
  	```sqf
	evac_chopperUseClickActions = true;
	```
	
   Open your mission file and find file ***overwrites\click_actions\config.sqf***.
  
   Add this to the bottom of the DZE_CLICK_ACTIONS array:
   
  	```sqf
	["ItemGPS","Call Evac Chopper","execVM 'scripts\JAEM\callEvacChopper.sqf';","true"]
	```
	
   Note: you can tie the right click action to any toolbelt item. I just chose ItemGPS as default. Make sure you put a comma on the one before the last.
  
   I had to add this exception to the end of line 32 in scripts.txt
  
  	```sqf
	!="execVM 'scripts\\JAEM\\callEvacChopper.sqf';"
	```

   You are finished with the install.
	
	
	




    
 
