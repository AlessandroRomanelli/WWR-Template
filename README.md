#Changelog V0.63.4
+ [ADDED] Scoreboard now accessible by pressing "TAB";
+ [ADDED] Merderet River (Winter) map, GER vs US;
+ [ADDED] M1 Garand Rifle grenade for everyone, grenadiers get 2, grenadiers with ammo perk get 3;
+ [ADDED] AT Grenade to grenadiers, 2 with ammo perk;

* [CHANGED] Weapon progression, now handguns are unlocked before other rifles;
* [CHANGED] Increased the radius to activate the explosives on the radio stations, should make actions easier;
* [CHANGED] AT Mines replaced with working ones (TM-44 AT Mine);

* [FIXED] Backpack being dropped on the ground when spawning *needs testing*
* [FIXED] Panzershrek only having one round, 1 without perk, 3 with perk;
* [FIXED] Render display errors when switching sides (Map markers and GUI);

#Changelog V0.63.3
+ [ADDED] Panovo Map scenery;

* [CHANGED] Weapon progression, different starter rifle but same unlocks for everybody;
* [CHANGED] Defenders spawn at Spawn 4 of Omaha_2 to give attackers more room for sieging the radio station;
* [FIXED] Engineer AT now carries 2 missiles for the Bazooka, too;
* [FIXED] Mission difficulty changing to recruit when changing mission, custom is enforced;
* [FIXED] Backpacks dropping on the ground when spawning;
* [FIXED] Friendly-fire issue causing players not being able to spawn on player who have killed enemy players
          because flagged as team-killers by the game engine. GRNFOR is how hostile to BLUFOR.
* [FIXED] Panovo objects being APEX dependencies;

#Changelog V0.63.2
+ [ADDED] Randomized time and dynamic weather;
+ [ADDED] Teams will have to play both sides and then the map will be changed;
+ [ADDED] Map playlist;
+ [ADDED] Automated change after 2 rounds are played;
+ [ADDED] Omaha1 Map (US vs GER);
+ [ADDED] Omaha2 Map (US vs GER);
+ [ADDED] Panovo Map (GER vs SOV);

* [CHANGED] Time acceleration boosted up to 10x;
* [CHANGED] Smoke perk allows user to have two smokes instead of only one;
* [CHANGED] When player doesn't select a weapon, the basic rifle with 3 mags will be given to him;

- [REMOVED] *Environments*;
- [REMOVED] GPS Item;

#Changelog V0.63.1
+ [ADDED] Team switch at the end of each round (attackers <=> defenders);
+ [ADDED] More complex scenery for *Environment 1* Stage 1 to favor attackers;
+ [ADDED] *Environment 2*;
+ [ADDED] Ladders to exit trenches with more ease;
+ [ADDED] Gap in the "bush fences" for the players to go through;
+ [ADDED] Music changes depending on winner;

* [FIXED] Restricted areas;
* [FIXED] Doubled objects on objectives causing players not to be able to interact with objective;
* [CHANGED] M4A3_76 replaced by the M4A3_75;
* [CHANGED] Explosives specialist to carry AT-Mines;
* [CHANGED] Tickets reduced from 100 to 75;
* [CHANGED] Round time increased from 10m to 15m;

- [REMOVED] Ponds of water to avoid light artifacts;

#Changelog V0.62.9

+ [ADDED] Bad weather and night time environments;
+ [ADDED] Bright nights;
+ [ADDED] Grenadier perk:
            Grenade adapter for the M1 Garand now gives you rifle grenades;
+ [ADDED] Explosives Specialist perk:
            Explosives charges and different backpacks are given to set up ambush and kill zones;
+ [ADDED] Name tagging with different colors for grouped and ungrouped allies;
+ [ADDED] Weapons available to exclusive factions;
+ [ADDED] Scenery for *Environment 1* Stage 1 to decrease the amount of open space attackers have to go through;

* [CHANGED] Restricted area time limit increased to 15s;
* [CHANGED] Fallback time reduced to 60s;
* [CHANGED] Moved objectives outside collapsable buildings/hardly reachable places:
      *Environment 1* Stage 2 objective location;
      *Environment 1* Stage 3 objective location;

* [CHANGED] Moved spawns further away from objectives to prevent area restrictions:
      *Environment 1* Stage 2 defender spawn;
      *Environment 1* Stage 3 defender spawn;

* [CHANGED] Medic revive time speeded up by 4x, now taking only 0.5s;
* [CHANGED] MachineGunner role to Support;

- [REMOVED] Bolt-actions to prevent code-breaking;
- [REMOVED] MGs to preserve game balance;
- [REMOVED] Panther to preserve game balance;
