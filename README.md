Just Another Evac-Chopper Mod v1.6.1
==============

v1.6.1 Changelog
1. Fixed the self actions so that they refresh without having to look away from the helicopter.
2. Updated the click action option since deploy anything is now built into Epoch.
3. Both the click action and the self action can be used together if desired. Click action is the better option though.
4. Fixed an undefined variable error related to Z_persistentMoney.
5. Updated the placement of code in the files to be more consistent with the structure of Epoch Mod.
6. Updated the install instructions.


This is an updated version of JAEM by OtterNas3. This version is updated to be compatible with DayZ Epoch 1.0.7.
I have upgraded this version to be ZSC and Deploy Anything compatible.

### Installation Instructions

1. Click ***[<> Code or Download](https://github.com/worldwidesorrow/Just-Another-Evac-Chopper-Mod/archive/refs/heads/master.zip)*** the green button on the right side of the Github page.

	> Recommended PBO tool for all "pack", "repack", or "unpack" steps: ***[PBO Manager](https://pbo-manager-v-1-4.software.informer.com/1.4b/)***
  
Note: all of the files that need to be modified are included in this repository if you prefer to use a merging tool to update your existing files. Otherwise, follow the instructions below.

### This install is rather complicated, so make sure you back up your existing mission and server PBOs in case you make a mistake.

2. Extract the downloaded folder and open it.
3. Unpack your mission PBO.
4. Copy the ***scripts*** folder over to the root of your mission folder, or if you already have a scripts folder copy the ***JAEM*** folder into it.
5. Copy the ***dayz_code*** folder over to the root of your mission folder if you don't already have it. If you already have a dayz_code folder and the same files from a previous install, you will edit your existing files in step 7.

6. Open ***init.sqf***
  
  	Find this line:

	```sqf
	waitUntil {scriptDone progress_monitor};
	```
	
  	Add the following line ***above*** it.
	
	```sqf
	execVM "scripts\JAEM\EvacChopper_init.sqf";
	```

7. If you already have a custom fn_selfActions.sqf in directory dayz_code\compile, open that file. If not you should have copied the one over from the download in step 5.

	Note: If you are pulling fn_selfActions.sqf to the mission file, it should be placed in directory dayz_code/compile and the following line needs to be added to dayz_code\init\compiles.sqf in the !isDedicated section.
	
	```sqf
	fnc_usec_selfActions = compile preprocessFileLineNumbers "dayz_code\compile\fn_selfActions.sqf";
	```
	
	Find this line:
	
	```sqf
	local _text = "";
	```
	
	Add the following block of code ***below*** it. Note: if you are using the click action option you do not need to use the code directly below.
	
	```sqf
	// Call EvacChopper
	if (playerHasEvacField) then {
		if (!_inVehicle && !evac_chopperInProgress && {player distance playersEvacField >= evac_chopperMinDistance} && {isNull _cursorTarget} && {speed player < 1}) then {
			if (evac_chopperNeedRadio == 1) then {
				if ("ItemRadio" in (items player)) then {
					if (s_player_evacCall < 0) then {
						s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",false,-1000,false,false,"",""];
					};
				};
			} else {
				if (s_player_evacCall < 0) then {
					s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",false,-1000,false,false,"",""];
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
	if (DZE_VehicleKey_Changer) then {
		if (s_player_copyToKey < 0) then {
			if ((_hasKeymakerskit && _hasKey && !_isLocked && {(count _temp_keys) > 1}) || {_cursorTarget getVariable ["hotwired",false]}) then {
				s_player_copyToKey = player addAction [format["<t color='#0059FF'>%1</t>",localize "STR_CL_VKC_CHANGE_ACTION"],"\z\addons\dayz_code\actions\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,if (_cursorTarget getVariable ["hotwired",false]) then {"claim"} else {"change"}],5,false,true];
			};
		};
	};
	```
	
  	Add the following block of code ***below*** it.
	
	```sqf
	// EvacChopper Set and Remove
		if (!evac_chopperInProgress && _hasKey && {_cursorTarget isKindOf "Helicopter"}) then {
			if (!playerHasEvacField) then {
				if (s_player_evacSet < 0) then {
					s_player_evacSet = player addAction [("<t color=""#0000FF"">" + "Set Evac-Chopper" + "</t>"),"scripts\JAEM\SetEvacChopper.sqf",_cursorTarget,3,false,true];
				};
			} else {
				player removeAction s_player_evacSet;
				s_player_evacSet = -1;
			};
			if (playerHasEvacField && (player distance playersEvacField < 10)) then {
				if (s_player_evacRemove < 0) then {
					s_player_evacRemove = player addAction [("<t color=""#0000FF"">" + "Clear Evac-Chopper" + "</t>"),"scripts\JAEM\ClearEvacChopper.sqf",_cursorTarget,4,false,true];
				};
			} else {
				player removeAction s_player_evacRemove;
				s_player_evacRemove = -1;
			};
		};
	```
	
	Find these lines:
	
	```sqf
	{player removeAction _x} count s_player_lockunlock;s_player_lockunlock = [];
	s_player_lockUnlock_crtl = -1;
	player removeAction s_player_copyToKey;
	s_player_copyToKey = -1;
	```
	
	Add the following lines ***below*** it.
	
	```sqf
	player removeAction s_player_evacSet;
	s_player_evacSet = -1;
	player removeAction s_player_evacRemove;
	s_player_evacRemove = -1;
	```
	
  
  	Find these lines of code (above the comment //Dog actions on player self):

	```sqf
	player removeAction s_player_copyToKey;
	s_player_copyToKey = -1;
	player removeAction s_player_claimVehicle;
	s_player_claimVehicle = -1;	
	player removeAction s_garage_dialog;
	s_garage_dialog = -1;
	```
	
  	Add the following lines ***below*** it:
	
	```sqf
	player removeAction s_player_evacSet;
	s_player_evacSet = -1;
	player removeAction s_player_evacRemove;
	s_player_evacRemove = -1;
	```
  
8. Open ***dayz_code\init\variables.sqf***
	
	Find this line:
	
	```sqf
	//    Add custom reset actions here
	```
	
	Add the following lines ***below*** it:
	
	```sqf
	s_player_evacCall = -1;
	s_player_evacSet = -1;
	s_player_evacRemove = -1;
	```
	
	Find this line:
	
	```sqf
	call dayz_resetSelfActions;
	```
	
	Add the following lines ***below*** it:
	
	```sqf
	// Evac Chopper
	playerHasEvacField = false; // DO NOT CHANGE.
	playersEvacField = objNull; // DO NOT CHANGE.
	evac_chopperInProgress = false; //DO NOT CHANGE.
	```
	
	Below the }; place the following line. This line should be compile by all machines and should not be in the !isDedicated or the isServer sections.
	
	```sqf
	DayZ_SafeObjects set [count DayZ_SafeObjects, "HeliHRescue"];
	```
	
9. Open ***configVariables.sqf***

	Find this line:
	
	```sqf
	if (isServer) then {
	```
	
	Add the following lines ***below*** it:
	
	```sqf
	// Evac Chopper
	evac_chopperZoneMarker = 0; // Evac zone marker type (0 = Landingpad | 1 = Smoke).
	```
	
	Find this line:
	
	```sqf
	if (!isDedicated) then {
	```
	
	Add the following lines ***below*** it:
	
	```sqf
	// Evac Chopper
	evac_chopperPrice = 1; // This is the price players pay in full briefcases to set up an evac chopper.
	evac_chopperPriceZSC = 10000; // Price for evac chopper if you have ZSC Installed and evac_chopperUseZSC set to true.
	evac_chopperAllowRefund = false; // Allow players to get their money back when they remove an evac-chopper field.
	evac_chopperMinDistance = 500; // Minimum distance for player to call evac chopper. Do not set this lower than 500.
	evac_chopperNeedRadio = 0; // 1 - Require player to have a radio in gear to call evac chopper | 0 - Doesn't require radio to call evac chopper.
	evac_chopperDisabledMarker = true; // Place a private map marker of the evac chopper's location
	```
	
	If you wish to use a click action to call the evac chopper find this line:
	
	```sqf
	DZE_CLICK_ACTIONS = [
	```
	
	Add the following line ***below*** it:
	
	```sqf
	["ItemGPS","Call Evac Chopper","[1,1,1,true] execVM 'scripts\JAEM\callEvacChopper.sqf';","true"]
	```
	
	If you have other entries in that section, be mindful of the comma at the end.

10. ***Repack your mission PBO.***

11. Unpack your server PBO and open ***dayz_server\system\server_monitor.sqf***

	Find this line:

	```sqf
	dayz_serverIDMonitor = [];
	```
	
	Add the following line ***below*** it:
	
	```sqf
	PVDZE_EvacChopperFields = [];
	```
  
  	Find this line:

	```sqf
	if (_type == "Base_Fire_DZ") then {_object spawn base_fireMonitor;};
	```
	
	Add the following line ***below*** it:
	
	```sqf
	if (_type == "HeliHRescue") then {PVDZE_EvacChopperFields set [count PVDZE_EvacChopperFields, _object];};
	```
  
  	Find this line:

	```sqf
	publicVariable "sm_done";
	```
	
	Add the following line ***below*** it:
	
	```sqf
	publicVariable "PVDZE_EvacChopperFields";
	```
  
12. Open ***dayz_server\init\server_functions.sqf***

	Find this comment:
	
	```sqf
	// Precise base building 1.0.5
	```
	
	Add the following block of code ***above*** it:
	
	```sqf
	server_evacChopperUpdate = {
		local _action = _this select 0;
		local _field = _this select 1;
		if (_action == "add") then {PVDZE_EvacChopperFields = PVDZE_EvacChopperFields + [_field];};
		if (_action == "rem") then {PVDZE_EvacChopperFields = PVDZE_EvacChopperFields - [_field];};
		publicVariable "PVDZE_EvacChopperFields";
	};
	server_callEvacChopper = compile preprocessFileLineNumbers "\z\addons\dayz_server\compile\server_callEvacChopper.sqf";
	```
	
13. Copy the file ***dayz_server\compile\server_callEvacChopper.sqf*** to the compile folder in your server folder.

14. Open ***dayz_server\eventHandlers\server_eventHandler.sqf***

	Add the following lines to the very bottom:
	
	```sqf
	"CallEvacChopper" addPublicVariableEventHandler {(_this select 1) spawn server_callEvacChopper;};
	"PVDZE_EvacChopperFieldsUpdate" addPublicVariableEventHandler {(_this select 1) call server_evacChopperUpdate};
	```

14. ***Repack you server PBO.***

15. A complete set of the necessary BattlEye files have been provided in the BattlEye folder. If you have a fresh server or prefer to diffmerge then you can use these files. Otherwise follow the instructions below.

Note: I have not tested the BattlEye filter exceptions below in Epoch 1.0.7.1.

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

   You are finished with the install.
	
	
	




    
 
