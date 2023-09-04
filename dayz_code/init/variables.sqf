if (isServer) then {
	
};

if (!isDedicated) then {
	dayz_resetSelfActions1 = dayz_resetSelfActions;
	dayz_resetSelfActions = {
		call dayz_resetSelfActions1;
		//    Add custom reset actions here
		s_player_evacCall = -1;
		s_player_evacSet = -1;
		s_player_evacRemove = -1;
	
	};
	call dayz_resetSelfActions;	

	// Evac Chopper
	playerHasEvacField = false; // DO NOT CHANGE.
	playersEvacField = objNull; // DO NOT CHANGE.
	evac_chopperInProgress = false; //DO NOT CHANGE.
};

DayZ_SafeObjects set [count DayZ_SafeObjects, "HeliHRescue"];