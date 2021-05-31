/*------------------------------------------*/
/* JAEM                               		*/
/* Just another Chopper-Evac Mod v1.6 		*/
/* OtterNas3								*/
/* 01/14/2014                         		*/
/* Updated for DayZ Epoch 1.0.6+ by JasonTM */
/* Updated for DayZ Epoch 1.0.7+ by JasonTM */
/* Last update: 05-30-2021           		*/
/*------------------------------------------*/

waitUntil {!isNil "PVDZE_EvacChopperFields"};

{
	if (getPlayerUID player == _x getVariable["ownerPUID","0"]) then {
		playerHasEvacField = true;
		playersEvacField = _x;
	};
} count PVDZE_EvacChopperFields;

"EvacChopperClient" addPublicVariableEventHandler {(_this select 1) call EvacChopperFlightStatus};
