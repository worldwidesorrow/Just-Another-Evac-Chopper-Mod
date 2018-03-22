DayZ_SafeObjects set [count DayZ_SafeObjects, "HeliHRescue"];

// Evac Chopper Static Variables
playerHasEvacField = false; // DO NOT CHANGE.
playersEvacField = objNull; // DO NOT CHANGE.
s_player_evacChopper = []; // DO NOT CHANGE.
evac_chopperInProgress = false; //DO NOT CHANGE.

// Evac Chopper Config Variables
evac_chopperPrice = 1; // This is the price players pay in full briefcases to set up an evac chopper (between 1-12 briefcases). Players must have the briefcases in their inventory.
evac_chopperUseZSC = false; // If you have ZSC installed you can set this to true and have players pay the amount below to set up an evac chopper.
evac_chopperPriceZSC = 100000; // Price for evac chopper if you have ZSC Installed and evac_chopperUseZSC set to true.
evac_chopperMinDistance = 500; // Minimum distance for player to call evac chopper. Do not set this lower than 500.
evac_chopperZoneMarker = 0; // Evac zone marker type (0 = Landingpad | 1 = Smoke).
evac_chopperNeedRadio = 0; // 1 - Require player to have a radio in gear to call evac chopper | 0 - Doesn't require radio to call evac chopper.
evac_chopperUseClickActions = false; // If you have Mudzereli's Deploy Anything installed and are going to use click actions to call the evac chopper, set this to true (disables call chopper self-action loop).
evac_ChopperDisabledMarker = true; // Place a private map marker of the evac chopper's location
evac_chopperMarkerTimeout = -1; // This will be the time in seconds that the marker will last before being deleted. (-1 = no timeout)

if (isServer) then {"CallEvacChopper" addPublicVariableEventHandler {(_this select 1) spawn server_callEvacChopper;};};

//Player self-action handles
dayz_resetSelfActions = {
	s_player_equip_carry = -1;
	s_player_fire = -1;
	s_player_cook = -1;
	s_player_boil = -1;
	s_player_packtent = -1;
	s_player_packtentinfected = -1;
	s_player_fillfuel = -1;
	s_player_grabflare = -1;
	s_player_removeflare = -1;
	s_player_studybody = -1;
	s_player_deleteBuild = -1;
	s_player_flipveh = -1;
	s_player_sleep = -1;
	s_player_fillfuel210 = -1;
	s_player_fillfuel20 = -1;
	s_player_fillfuel5 = -1;
	s_player_siphonfuel = -1;
	s_player_repair_crtl = -1;
	s_player_fishing = -1;
	s_player_fishing_veh = -1;
	s_player_gather = -1;
	s_player_destroytent = -1;
	s_player_attach_bomb = -1;
	s_player_upgradestorage = -1;
	s_player_Drinkfromhands = -1;
	/*s_player_lockhouse = -1; //Vanilla base building currently not used in Epoch
	s_player_unlockhouse = -1;
	s_player_openGate = -1;
	s_player_CloseGate = -1;
	s_player_breakinhouse = -1;
	s_player_setCode = -1;
	s_player_BuildUnLock = -1;
	s_player_BuildLock = -1;*/
	
	// EPOCH ADDITIONS
	s_player_packvault = -1;
	s_player_lockvault = -1;
	s_player_unlockvault = -1;
	s_player_attack = -1;
	s_player_callzombies = -1;
	s_player_showname = -1;
	s_player_pzombiesattack = -1;
	s_player_pzombiesvision = -1;
	s_player_pzombiesfeed = -1;
	s_player_tamedog = -1;
	s_player_parts_crtl = -1;
	s_player_movedog = -1;
	s_player_speeddog = -1;
	s_player_calldog = -1;
	s_player_feeddog = -1;
	s_player_waterdog = -1;
	s_player_staydog = -1;
	s_player_trackdog = -1;
	s_player_barkdog = -1;
	s_player_warndog = -1;
	s_player_followdog = -1;
	s_player_information = -1;	
	s_player_fuelauto = -1;
	s_player_fuelauto2 = -1;
	s_player_fillgen = -1;
	s_player_upgrade_build = -1;
	s_player_maint_build = -1;
	s_player_downgrade_build = -1;
	s_player_towing = -1;
	s_halo_action = -1;
	s_player_SurrenderedGear = -1;
	s_player_maintain_area = -1;
	s_player_maintain_area_force = -1;
	s_player_maintain_area_preview = -1;
	s_player_heli_lift = -1;
	s_player_heli_detach = -1;
	s_player_lockUnlock_crtl = -1;
	s_player_lockUnlockInside_ctrl = -1;
	s_player_toggleSnap = -1;
	s_player_toggleSnapSelect = -1;
	s_player_toggleSnapSelectPoint = [];
	snapActions = -1;
	s_player_plot_boundary = -1;
	s_player_plotManagement = -1;
	s_player_toggleDegree = -1;
	s_player_toggleDegrees=[];
	degreeActions = -1;
	s_player_toggleVector = -1;
	s_player_toggleVectors=[];
	vectorActions = -1;
	s_player_manageDoor = -1;
	
	// Custom Below
	
	s_player_evacChopper_ctrl = -1;
};
call dayz_resetSelfActions;