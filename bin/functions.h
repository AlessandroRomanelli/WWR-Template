// Client
class Maverick_Functions_Client {
	tag = "client";
	class functions {
		file = "bin\client";
		class init {headerType = -1;};
		class preInit {preInit = 1;};
		class waitForServer {};
		class spawn {};
		class getSectionCenter {};
		class populateSpawnMenu {};
		class loadStatistics {};
		class getLoadedEquipment {};
		class weaponDetails {};
		class validateEquipment {};
		class loadSpawnpoints {};
		class MPHit {};
		class kill {};
		class setupEventHandlers {};
		class spawnPlayer {};
		class spawnPlayerAtLocation {};
		class spawnPlayerAtObject {};
		class displayError {};
		class startIngameGUI {};
		class equipWeapons {};
		class addPoints {};
		class displayUnlockWeapon {};
		class unlockAttachment {};
		class displayUnlockAttachment {};
		class medic_unitDied {};
		class medic_reviveUnit {};
		class revive {};
		class killed {};
		class equipAll {};
		class regenerateHP {};
		class MCOMarmed {};
		class armMCOM {};
		class disarmMCOM {};
		class MCOMdestroyed {};
		class displayObjectiveMessage {};
		class hint {};
		class endMatch {};
		class resetVariables {};
		class resetPlayer {};
		class waitingForMatchToEnd {};
		class getUnlockableAttachments {};
		class squadSpawn {};
		class updateMarkers {};
		class updateRestrictions {};
		class updateLine {};
		class giveStatistics {};
		class saveStatistics {};
		class say3D {};
		class getNextUnlockableWeapon {};
		class displayKillfeed {};
		class renderKillfeed {};
		class administrationKill {};
		class restoreAmmo {};
		class displayInfo {};
		class initClass {};
		class objectiveArmedGUIAnimation {};
		class beaconSpawn {};
		class disableChannels {};
		class spawnBeaconSoundLoop {};
		class matchTimer {};
		class vehicleSpawned {};
		class getAllAmmoVehicles {};
		class spawnPlayerInVehicle {};
		class getBeaconOwner {};
		class beaconEventHandler {};
		class countAssist {};
		class evaluateAssistInfo {};
		class getUsedPerksForClass {};
		class setUsedPerksForClass {};
		class getPerkInstructions {};
		class initPerks {};
		class cleanUp {};
		class initHoldActions {};
		class teamBalanceKick {};
		class remoteExecution {};
		class dumpObjects {};
		class instantTeamBalanceCheck {};
		class initKeyHandler {};
		class vehicleDisabled {};
		class displayKeyBindingHint {};
		class restrictedArea {};
		class validatePointsEarned {};
		class updateSpawnMenuCam {};
		class revealFriendlyUnits {};
		class onEachFramePreparation {};
		class displaySpawnRestriction {};
		class moveUnitIntoVehicle {};
		class teleport {};
		class displayAds {};
		class drawMapUnits {};
		class getCurrentSideLoadout {};
		class initGlobalVars {};
		class brightNight {postInit = 1;};
		class getSquadPerks {};
		class setSquadPerks {};
		class checkClassRestriction {};
		class encryptData {};
		class getFallbackTime {};
		class spotTarget {};
		class moveWithinVehicle {};
		class getObjectiveDistance {};
		class initUserInterface {};
		class meleeTakedown {};
		class getUnitIcon {};
		class sideSwitch {};
		class displayAdminArea {};
		class populateAdminArea {};
		class spawnModal {};

		// Pointfeed
		class pointfeed_add {};
		class displayKillcam {};

		// Spawn menu
		class spawnMenu_displayPrimaryWeaponSelection {};
		class spawnMenu_displaySecondaryWeaponSelection {};
		class spawnMenu_displayPrimaryAttachmentSelection {};
		class spawnMenu_displaySecondaryAttachmentSelection {};
		class spawnMenu_displayGroupManagement {};
		class spawnMenu_loadClasses {};
		class spawnMenu_getClassAndSpawn {};
		class spawnMenu_displayClassCustomization {};
	};
};

// Server
class Maverick_Functions_Server {
	tag = "server";
	class functions {
		file = "bin\server";
		class init {};
		class updateVars {};
		class log {};
		class engine {};
		class cleanUp {};
		class spawnObjectives {};
		class decideMapSize {};
		class refreshTickets {};
		class endRound {};
		class matchTimer {};
		class persistentVehicleManager {};
		class stageVehicleManager {};
		class importantObjects {};
		class loadWeather {};
		class loadPersistentWeather {};
		class scriptMonitoring {};
		class autoTeamBalancer {};
		class monitorVehicle {};
		class waitForPlayers {};
		class generateGroupName {};
		class assignSide {};
		class sideSwitch {};
		class selectNextMap {};

		// Database
		class db_getPlayer {};
		class db_setPlayer {};
		class db_connect {};
		class db_asyncCall {};
		class db_prepareString {};
	};
};

class Maverick_Functions_Admin {
	tag = "admin";
	class functions {
		file = "bin\admin";
		class kickPlayer {};
		class killPlayer {};
		class switchPlayer {};
		class isAdmin {};
		class spectate {};
	};
};
