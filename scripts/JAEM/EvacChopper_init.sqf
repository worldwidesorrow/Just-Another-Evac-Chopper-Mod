/*------------------------------------*/
/* JAEM                               */
/* Just another Chopper-Evac Mod v1.4 */
/* OtterNas3                          */
/* 01/14/2014                         */
/* Last update: 06/14/2014            */
/*------------------------------------*/

private ["_evacCallerUID","_evacFields","_evacFieldID"];

/////////////////////////////////////////////////
////// Need a Radio to call Evac-Chopper? ///////
////// 1 = Need Radio | 0 = No need Radio ///////
evac_needRadio = 0;
/////////////////////////////////////////////////
// Evac-Zone marker type Smoke or Landingpad? ///
////////// 0 = Landingpad | 1 = Smoke ///////////
evac_zoneMarker = 0;
/////////////////////////////////////////////////
/// Minimum Distance to call for Evac-Chopper ///
///////// Dont set this lower then 500! /////////
evac_minDistance = 300;
/////////////////////////////////////////////////
///  Allowed Choppers to use as Evac-Chopper  ///
evac_AllowedChoppers = [
	"AH1Z","AH64D_EP1","AH64D","AH64D_Sidewinders","AH6X_DZ",
	"AH6X_EP1","AH6J_EP1","AW159_Lynx_BAF","BAF_Apache_AH1_D","BAF_Merlin_HC3_D",
	"CH_47F_BAF","CH_47F_EP1","CH_47F_EP1_DZ","CH_47F_EP1_DZE","CSJ_GyroC",
	"CSJ_GyroCover","CSJ_GyroP","Ka137_MG_PMC","Ka137_PMC","Ka52",
	"Ka52Black","Ka60_GL_PMC","Ka60_PMC","Mi17_CDF","Mi17_Civilian",
	"Mi17_Civilian_DZ","Mi17_DZ","Mi17_Ins","Mi17_medevac_CDF","Mi17_medevac_INS",
	"Mi17_medevac_RU","Mi17_rockets_RU","Mi17_TK_EP1","Mi17_UN_CDF_EP1","Mi171Sh_CZ_EP1",
	"Mi171Sh_rockets_CZ_EP1","Mi24_D","Mi24_D_TK_EP1","Mi24_P","Mi24_V",
	"MH60S","MH6J_DZ","MH6J_EP1","MV22","MV22_DZ",
	"pook_H13_medevac","pook_H13_medevac_CDF","pook_H13_medevac_TAK","pook_H13_medevac_INS","pook_H13_medevac_UNO",
	"pook_H13_medevac_PMC","pook_H13_medevac_GUE","pook_H13_medevac_CIV","pook_H13_medevac_CIV_RU","pook_H13_gunship",
	"pook_H13_gunship_CDF","pook_H13_gunship_UNO","pook_H13_gunship_PMC","pook_H13_gunship_GUE","pook_H13_gunship_TAK",
	"pook_H13_gunship_INS","pook_H13_transport","pook_H13_transport_CDF","pook_H13_transport_UNO","pook_H13_transport_PMC",
	"pook_H13_transport_GUE","pook_H13_transport_TAK","pook_H13_transport_INS","pook_H13_civ","pook_H13_civ_white",
	"pook_H13_civ_slate","pook_H13_civ_black","pook_H13_civ_yellow","pook_H13_civ_ru","pook_H13_civ_ru_white",
	"pook_H13_civ_ru_slate","pook_H13_civ_ru_black","pook_H13_civ_ru_yellow","UH1H_DZ","UH1H_DZE",
	"UH1H_TK_EP1","UH1H_TK_GUE_EP1","UH1Y_DZ","UH1Y_DZE","UH60M_EP1",
	"UH60M_EP1_DZ","UH60M_EP1_DZE","UH60M_MEV_EP1"
];
/////////////////////////////////////////////////
/////////////// DONT EDIT BELOW ! ///////////////
/////////////////////////////////////////////////

/* Needed functions in Evac-Chopper scripts */

/* Wait for the player full ingame so we can do checks an add the action-menu entry */
//waitUntil {!isNil "dayz_animalCheck"};

/* Wait until the player recieves the publicVarible from the Server! */
waitUntil {!isNil "PVDZE_EvacChopperFields"};

/* Store the current Evac-Fields into a local variable for checks */
_evacFields = PVDZE_EvacChopperFields;

/* Checking if player has a Evac-Chopper to decide if we show the Call-Evac action menu */
_evacCallerUID = getPlayerUID player;
//playerHasEvacField = false;
//playersEvacField = objNull;
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

s_player_evacCall = -1;
evac_callfunctions = false;


while{true} do {
	uiSleep 3;

	if (((vehicle player) == player) && (isNull cursorTarget) && (playerHasEvacField) && (speed player < 1) && ((player distance playersEvacField) >= evac_MinDistance)) then {
				
		if (evac_needRadio == 1) then {
			evac_call_itemsPlayer = items player;
			evac_call_hasRadio = "ItemRadio" in evac_call_itemsPlayer;
			
			if (evac_call_hasRadio) then {
				evac_callFunctions = true;
				
				if (s_player_evacCall < 0) then {
					s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",[],-1000,false,false,"",""];
				};
			
			} else {
				evac_callFunctions = false;
				player removeAction s_player_evacCall;
				s_player_evacCall = -1;
			};
		
		} else {
			evac_callFunctions = true;
			
			if (s_player_evacCall < 0) then {
				s_player_evacCall = player addAction [("<t color=""#0000FF"">" + ("Call Evac-Chopper") + "</t>"),"scripts\JAEM\CallEvacChopper.sqf",[],-1000,false,false,"",""];
			};
		};
		
	} else {
		
		if (evac_callFunctions) then {
			player removeAction s_player_evacCall;
			s_player_evacCall = -1;
			evac_callFunctions = false;
		};
	};
};
