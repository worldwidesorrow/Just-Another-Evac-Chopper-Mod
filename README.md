Just Another Evac-Chopper Mod v1.5
==============

This is an updated version of JAEM by OtterNas3. This version is updated to be compatible with DayZ Epoch 1.0.6.2.
I have upgraded this version to be ZSC and Deploy Anything compatible. ZSC can be used as an option to pay for the creation of an evac chopper and Mudzereli's right-click actions can be used to call the evac chopper.

### Installation Instructions

1. Click ***[Clone or Download](https://github.com/worldwidesorrow/JAEM-v1.5/archive/master.zip)*** the green button on the right side of the Github page.

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
	
  	Add the following line ***above*** it:
	
	```sqf
	[] execVM "scripts\JAEM\EvacChopper_init.sqf";
	```

7. If you already have a custom fn_selfActions.sqf in directory dayz_code\init, open that file. If not you should have copied the one over from the download in step 5.

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
	//Evac Chopper
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
	};
	```
  
  	Find these two lines:

	```sqf
	{player removeAction _x} count s_player_lockunlock;s_player_lockunlock = [];
		s_player_lockUnlock_crtl = -1;
	```
	
  	Add the following lines ***below*** them:
	
	```sqf
	{player removeAction _x} count s_player_evacChopper;s_player_evacChopper = [];
		s_player_evacChopper_ctrl = -1;
	```
   	Use the file I provided in the download to compare your results with. The finished result should look like this.
  
  	```sqf
		} else {
			if (_hasKey || _oldOwner) then {
				_lock = player addAction [format[localize "STR_EPOCH_ACTIONS_LOCK",_text], "\z\addons\dayz_code\actions\lock_veh.sqf",_cursorTarget, 1, true, true];
				s_player_lockunlock set [count s_player_lockunlock,_lock];
				s_player_lockUnlock_crtl = 1;
			};
		};
		//Evac Chopper
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
		};
	};
	} else {
		{player removeAction _x} count s_player_lockunlock;s_player_lockunlock = [];
		s_player_lockUnlock_crtl = -1;
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

	Add the following line to your custom variables.sqf if you don't have it already. It does not matter where it is located in the file.

	```sqf
	DayZ_SafeObjects = DayZ_SafeObjects + ["HeliHRescue"];
	```
	
	If you already have a customized DayZ_SafeObjects array, then add HeliRescue to the end of it like shown above.
	
	Add the following lines to your custom variables.sqf. It does not matter where these are placed in the file.
	
	```sqf
	// Evac Chopper Static Variables
	playerHasEvacField = false; // DO NOT CHANGE.
	playersEvacField = objNull; // DO NOT CHANGE.
	s_player_evacChopper = []; // DO NOT CHANGE.

	// Evac Chopper Config Variables
	evac_chopperPrice = 1; // This is the price players pay in full briefcases to set up an evac chopper (between 1-12 	briefcases). Players must have the briefcases in their inventory.
	evac_chopperUseZSC = false; // If you have ZSC installed you can set this to true and have players pay the amount below to set up an evac chopper.
	evac_chopperPriceZSC = 100000; // Price for evac chopper if you have ZSC Installed and evac_chopperUseZSC set to true.
	evac_chopperMinDistance = 500; // Minimum distance for player to call evac chopper. Do not set this lower than 500.
	evac_chopperZoneMarker = 0; // Evac zone marker type (0 = Landingpad | 1 = Smoke).
	evac_chopperNeedRadio = 0; // 1 - Require player to have a radio in gear to call evac chopper | 0 - Doesn't require radio to call evac chopper.
	evac_chopperUseClickActions = false; // If you have Mudzereli's Deploy Anything installed and are going to use click actions to call the evac chopper, set this to true (disables call chopper self-action loop).
	```
  
  	Add the entire block of code below this line if you don't already have it:
  
   ```sqf
    	//Player self-action handles
	```
	If you already have this section from a prior install then just add the following line to the bottom above the };

	```sqf
	s_player_evacChopper_ctrl = -1;
	```
	Make sure you compare your file with the one in the download so the line ends up in the correct place.

9. If you already have a custom compiles.sqf in directory dayz_code\init, open that file. If not you should have copied the one over from the download in step 5.

 	Copy the following line over to the !isDedicated section if you don't have it already from a prior install:
  
    ```sqf
    	fnc_usec_selfactions = compile preprocessFileLineNumbers "dayz_code\compile\fn_selfActions.sqf";
  	```
    
10. Repack you mission PBO.

11. Unpack your server PBO and open ***dayz_server\system\server_monitor.sqf***

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
	_object setVariable ["CharacterID", _ownerID, true];
	```
	
	Add the following block of code ***below*** it:
	
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
  
12. Repack your server PBO

13. A complete set of the necessary BattlEye files have been provided in the BattlEye folder. If you have a fresh server or prefer to diffmerge then you can use these files. Otherwise follow the instructions below.

Note: These are to be used with the stock BattlEye filters that come with the 1.0.6.2 server files. If you are using a different set of filters then the numbers will not line up.

1. publicvariable.txt

   Add this to the end of line 2:
  
  	```sqf
	!=PVDZE_EvacChopperFieldsUpdate
	```
2. remoteexec.txt

  Add this to the end of line 2:
  
  	```sqf
	!="true" !="evacZoneReached = true; evacChopper land 'LAND';" !=""
	```
	
3. waypointcondition.txt

  Add this to the end of line 2:
  
  	```sqf
	!="true"
	```
	
4. waypointstatements.txt

  Add this to the end of line 2:
  
  	```sqf
	!="evacZoneReached = true; evacChopper land 'LAND';" !=""
	```
	
5. scripts.txt

  Add this to the end of line 17
  
  	```sqf
	!"\\dayz_code\\init\\compiles.sqf\"\nif (!isDedicated) then {\ndiag_log \"Loading custom client com"
	```
	
  Add this to the end of line 2:
  
  	```sqf
	!=" (s_player_evacCall < 0) then {\ns_player_evacCall = player addAction [(\"<t color=\"\"#0000FF\"\">\" + (\"Call Evac-Chopper\") + \"</t>\")"
	```
	
  Add this to the end of line 11:
 
  	```sqf
	!="er setPosATL ([evacChopper] call FNC_GetPos);\n_finishMarker attachTo [evacChopper,[0,0,0]];\n};\nif (_dayTime > 18.5 && _dayTime <"
	```
	
  Add this to the end of line 22:
  
  	```sqf
	!="up = createGroup WEST;\nevacChopperPilot = evacChopperGroup createUnit [\"USMC_Soldier_pilot\", evacChopper, [], 0,\"LIEUTENANT\"];\nr"
	```
	
  Add this to the end of line 38:
  
  	```sqf
	!="format[\"%1m\", round (evacChopper distance _evacZone)];\n};\n};\n\nhintSilent parseText format [\"\n		<t size='1.15'	font='Bitstream'al"
	```
	
  Add this to the end of line 47:
  
  	```sqf
	!="t;\nremoveallitems evacChopperPilot;\nevacChopperPilot removeAllEventHandlers \"HandleDamage\";\nevacChopperPilot addEventHandler [\"H"
	```
	
  Add this to the end of line 68:
  
  	```sqf
	!="Pos;\n_chopperStartPos = _getChopperStartPos;\n\n\nevacChopper setVehicleLock \"UNLOCKED\";\nevacChopperGroup = createGroup WEST;\nevacC"
	```
	
  Add this to the end of line 72:
  
  	```sqf
	!="FNC_GetPos;\n_canceled = false;\n\n\nfor \"_p\" from 1 to 5 do\n{\nsystemChat(format [\"Evac-Chopper get called in %1s - Move to cancel!\""
	```
	
### Mudzereli's Deploy Anything Option

  If you want to use right click actions in deploy anything to call the evac chopper instead of the built in self-actions, then find this variable in your custom variables.sqf
  
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
	
  Note: you can tie the right click action to any toolbelt item. I just chose ItemGPS as default.
  
   I had to add this exception to the end of line 32 in scripts.txt
  
  	```sqf
	!="execVM 'scripts\\JAEM\\callEvacChopper.sqf';"
	```
	
### ZSC Option

   If you have it installed, you can use ZSC to pay for you evac chopper creation. Find this variable in your custom variables.sqf:
  
  	```sqf
	evac_chopperUseZSC = false;
	```
	
   Change this variable to:
  
  	```sqf
	evac_chopperUseZSC = true;
	```
	
   You can adjust the price with this variable:
  
  	```sqf
	evac_chopperPriceZSC = 100000;
	```
	
   You are finished with the install.
	
	
	




    
 
