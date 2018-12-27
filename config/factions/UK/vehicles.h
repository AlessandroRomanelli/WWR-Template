faction = "UK";
marker = "LIB_Faction_US_ARMY";

class Vehicle {
  displayName = "";
  className = "";
  respawnTime = 0;
  positionATL[] = {};
  dir = 0;
  script = "";
  populationReq = 0;
};

class Plane: Vehicle {
  respawnTime = 300;
  populationReq = 10;
  fuelTime = 90;
};

class Plane_CAP: Plane {
  displayName = "P-39 'Airacobra'";
  className = "LIB_US_P39_2";
};

class Plane_CAS: Plane {
  displayName = "P-47 'Thunderbolt'";
  className = "LIB_P47";
};

class H_Tank: Vehicle {
  displayName = "M4A3 Sherman Firefly";
  className = "LIB_M4A4_FIREFLY";
  respawnTime = 300;
  populationReq = 20;
};

class L_Tank: Vehicle {
  displayName = "M3A3 Stuart";
  className = "LIB_M3A3_Stuart";
  respawnTime = 180;
  populationReq = 14;
};

class APC: Vehicle {
  displayName = "M8 Greyhound";
  className = "LIB_M8_Greyhound";
  respawnTime = 120;
  populationReq = 10;
};

class Car_HMG: Vehicle {
  displayName = "M3 Scout Car";
  className = "LIB_US_Scout_M3_FFV";
  respawnTime = 60;
  populationReq = 6;
};

class Truck: Vehicle {
  displayName = "Austin K5";
  className = "LIB_AustinK5_Tent";
  respawnTime = 30;
};

class Car: Vehicle {
  displayName = "Willys Jeep";
  className = "LIB_US_Willys_MB";
  respawnTime = 15;
};
