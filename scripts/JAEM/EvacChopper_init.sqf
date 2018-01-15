/*------------------------------------*/
/* JAEM                               */
/* Just another Chopper-Evac Mod v1.4 */
/* OtterNas3                          */
/* 01/14/2014                         */
/* Last update: 06/14/2014            */
/*------------------------------------*/
// Updated for DayZ Epoch 1.0.6.2 by JasonTM.

private ["_evacCallerUID","_evacFields","_evacFieldID"];

/* Wait for the player full ingame so we can do checks an add the action-menu entry */
waitUntil {!isNil "Dayz_loginCompleted"};

/* Wait until the player recieves the publicVarible from the Server! */
waitUntil {!isNil "PVDZE_EvacChopperFields"};

/* Store the current Evac-Fields into a local variable for checks */
_evacFields = PVDZE_EvacChopperFields;

/* Checking if player has a Evac-Chopper to decide if we show the Call-Evac action menu */
_evacCallerUID = getPlayerUID player;

if ((count _evacFields) > 0) then
{
	{
		_evacFieldID = _x getVariable["ownerPUID","0"];
		if (_evacCallerUID == _evacFieldID) then {
			playerHasEvacField = true;
			playersEvacField = _x;
		};
	} forEach _evacFields;
};

if (!evac_chopperUseClickActions) then { // if evac_chopperUseClickActions is true then this call chopper selfaction loop is disabled.
	s_player_evacCall = -1;
	evac_chopperCallFunctions = false;

	while {true} do {
		uiSleep 3;

		if (((vehicle player) == player) && (isNull cursorTarget) && (playerHasEvacField) && (speed player < 1) && ((player distance playersEvacField) >= evac_chopperMinDistance)) then {
					
			if (evac_chopperNeedRadio == 1) then {
				evac_call_itemsPlayer = items player;
				evac_call_hasRadio = "ItemRadio" in evac_call_itemsPlayer;
				
				if (evac_call_hasRadio) then {
					evac_chopperCallFunctions = true;
					
					if (s_player_evacCall < 0) then {
						s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",[],-1000,false,false,"",""];
					};
				
				} else {
					evac_chopperCallFunctions = false;
					player removeAction s_player_evacCall;
					s_player_evacCall = -1;
				};
			
			} else {
				evac_chopperCallFunctions = true;
				
				if (s_player_evacCall < 0) then {
					s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",[],-1000,false,false,"",""];
				};
			};
			
		} else {
			
			if (evac_chopperCallFunctions) then {
				player removeAction s_player_evacCall;
				s_player_evacCall = -1;
				evac_chopperCallFunctions = false;
			};
		};
	};
};
