//****************************************************************************************
//																						//
//										rd_utils.nut									//
//																						//
//****************************************************************************************


getroottable()["TRACE_MASK_ALL"] <- -1
getroottable()["TRACE_MASK_SHOT"] <- 1174421507
getroottable()["TRACE_MASK_VISION"] <- 33579073
getroottable()["TRACE_MASK_NPC_SOLID"] <- 33701899
getroottable()["TRACE_MASK_PLAYER_SOLID"] <- 33636363
getroottable()["TRACE_MASK_VISIBLE_AND_NPCS"] <- 33579137


getroottable()["WHITE"]		<- "\x01"
getroottable()["BLUE"]		<- "\x03"
getroottable()["ORANGE"]	<- "\x04"
getroottable()["GREEN"]		<- "\x05"


::ZombieTypes <-
{
	COMMON		= 0
	SMOKER		= 1
	BOOMER		= 2
	HUNTER		= 3
	SPITTER		= 4
	JOCKEY		= 5
	CHARGER		= 6
	WITCH		= 7
	TANK		= 8
	SURVIVOR	= 9
	MOB			= 10
	WITCHBRIDE	= 11
	MUDMEN		= 12
}

::TEAMS <-
{ 
	SPECTATOR	= 1
	SURVIVOR	= 2
	INFECTED	= 3
}

::damageTypes <-
{
	GENERIC			= 0
	CRUSH			= 1
	BULLET			= 2
	SLASH			= 4
	BURN			= 8
	VEHICLE			= 16
	FALL			= 32
	BLAST			= 64
	CLUB			= 128
	SHOCK			= 256
	SONIC			= 512
	ENERGYBEAM		= 1024
	DROWN			= 16384
	PARALYSE		= 32768
	NERVEGAS		= 65536
	POISON			= 131072
	RADIATION		= 262144
	DROWNRECOVER	= 524288
	ACID			= 1048576
	SLOWBURN		= 2097152
	REMOVENORAGDOLL	= 4194304
}


// Creates the think timer which calls "Think()" every tick
// ----------------------------------------------------------------------------------------------------------------------------

function createThinkTimer(){
	local timer = null
	while (timer = Entities.FindByName(null, "thinkTimer")){
		timer.Kill()
	}
	timer = SpawnEntityFromTable("logic_timer", { targetname = "thinkTimer", RefireTime = 0.01 })
	timer.ValidateScriptScope()
	timer.GetScriptScope()["scope"] <- this

	timer.GetScriptScope()["func"] <- function (){
		scope.Think()
	}
	timer.ConnectOutput("OnTimer", "func")
	EntFire("!self", "Enable", null, 0, timer)
}




// Remove all deathcams e.g on c8m5_rooftop
// ----------------------------------------------------------------------------------------------------------------------------

function removeDeathFallCameras(){
	local deathCam = null
	while (deathCam = Entities.FindByClassname(deathCam, "point_deathfall_camera")){
		deathCam.Kill()
	}
}




// All needed cvars
// ----------------------------------------------------------------------------------------------------------------------------

::cvars <-
{
	// Survivor settings
	sv_infinite_ammo = 1
	survivor_allow_crawling = 1
	survivor_crawl_speed = 45
	first_aid_kit_max_heal = 200
	survivor_respawn_with_guns = 0
	first_aid_heal_percent = 0.8
	z_grab_ledges_solo = 1
	z_tank_incapacitated_decay_rate = 5
	// Grenadelauncher settings
	grenadelauncher_velocity = 1100
	grenadelauncher_startpos_right = 0
	grenadelauncher_startpos_forward = 16
	grenadelauncher_vel_variance = 0
	grenadelauncher_vel_up = 0
	// Force settings
	phys_explosion_force = 4096
	melee_force_scalar = 16
	melee_force_scalar_combat_character = 512
	phys_pushscale = 512
	// Infected settings
	z_force_attack_from_sound_range = 512
	z_brawl_chance = 1
	// Medicals
	pain_pills_health_threshold = 199
	pain_pills_health_value = 100
	// Items
	sv_infected_riot_control_tonfa_probability = 0
	sv_infected_ceda_vomitjar_probability = 0
	// Votes
	sv_vote_creation_timer = 8
	sv_vote_plr_map_limit = 128
	// Misc
	z_spawn_flow_limit = 99999
	director_afk_timeout = 99999
	mp_allowspectators = 0
	// Disable Placeholder bots
	director_transition_timeout = 1
}




local cvarChangeTime = Time()

function checkCvars(){
	if(Time() > cvarChangeTime + 4){
		foreach(var, value in cvars){
			if(Convars.GetFloat(var) != value.tofloat()){
				Convars.SetValue(var, value)
			}
		}
		cvarChangeTime = Time()
	}
}




// Create a func_timescale entity for the "bullet time"
// ----------------------------------------------------------------------------------------------------------------------------

timeScaler <- null
function createBulletTimerEntity(){
	while (timeScaler = Entities.FindByName(null, "timeScaler")){
		timeScaler.Kill()
	}
	timeScaler = SpawnEntityFromTable("func_timescale",
		{
			targetname = "timeScaler"
			acceleration = 0.05
			angles = "0 0 0"
			origin = Vector(0, 0, 0)
			blendDataMultiplier = 3.0
			minBlendRate = 0.1
			desiredTimescale = 0.25
		}
	)
}




// We roll a dice with probability of X to decide if event Y will occur 
// ----------------------------------------------------------------------------------------------------------------------------

function rollDice(probability){
	local roll = RandomInt(1, 100)
	
	if(probability == 100){
		return true
	}else if(roll <= probability){
		return true
	}
	return false
}




// Returns the closest survivor in any radius
// ----------------------------------------------------------------------------------------------------------------------------

function getClosestSurvivorTo(ent){
	local survivor = null
	local previousDistance = 0.0
	local closest = null
	local currentDistance = null
	
	foreach(survivor in GetSurvivors()){
		if(survivor != ent){
			if(previousDistance == 0.0){
				previousDistance = (ent.GetOrigin() - survivor.GetOrigin()).Length()
				closest = survivor
			}else{
				currentDistance = (ent.GetOrigin() - survivor.GetOrigin()).Length()
				if(currentDistance < previousDistance){
					previousDistance = currentDistance
					closest = survivor
				}
			}
		}
	}
	return closest
}




// Returns array of all players (bots included)
// ----------------------------------------------------------------------------------------------------------------------------

function GetSurvivors(){
	local ent = null
	while (ent = Entities.FindByClassname(ent, "player")){
		if (ent.GetZombieType() == 9){
			yield ent
		}
	}
}


// Returns array of all survivors (bots excluded)
// ----------------------------------------------------------------------------------------------------------------------------

::GetHumanSurvivors <- function(){
	local ent = null
	while (ent = Entities.FindByClassname(ent, "player")){
		if (ent.GetZombieType() == 9 && !IsPlayerABot(ent)){
			yield ent
		}
	}
}




// Validates script scope and returns it
// ----------------------------------------------------------------------------------------------------------------------------

::GetValidatedScriptScope <- function(ent){
	ent.ValidateScriptScope()
	return ent.GetScriptScope()
}




// Precache survivor models so game wont crash due to the "cm_NoSurvivorBots = 1" bug...Valve please fix
// ----------------------------------------------------------------------------------------------------------------------------

function precacheSurvivorModels(){
	
	local path = "models/survivors/"
	local models =
	[
		"survivor_coach.mdl", "survivor_gambler.mdl", "survivor_manager.mdl", "survivor_mechanic.mdl",
		"survivor_namvet.mdl", "survivor_biker.mdl", "survivor_producer.mdl", "survivor_teenangst.mdl"
	]

	foreach(model in models){
		if (!IsModelPrecached( path + model)){
			PrecacheModel(path + model)
		}
	}
}




// Precache projectile models and mushroom
// ----------------------------------------------------------------------------------------------------------------------------

function precacheRocketDudeModels(){
	
	local models =
	[
		"models/props_collectables/mushrooms_glowing.mdl",
		"models/w_models/weapons/w_rd_grenade_scale_x4_burn.mdl",
		"models/w_models/weapons/w_rd_grenade_scale_x4.mdl"
	]
	
	foreach(model in models){
		if(!IsModelPrecached(model)){
			PrecacheModel(model)
		}
	}
}




// Check if the current map is a valve map
// ----------------------------------------------------------------------------------------------------------------------------

::IsValveMap <- function(){
	if (valveMaps.find(mapName) == null){
		return false
	}
	return true
}




// Array of maps c1 - c14
// ----------------------------------------------------------------------------------------------------------------------------

::valveMaps <- [
	// DEAD CENTER
	"c1m1_hotel"
	"c1m2_streets"
	"c1m3_mall"
	"c1m4_atrium"
	// DARK CARNIVAL
	"c2m1_highway"
	"c2m2_fairgrounds"
	"c2m3_coaster"
	"c2m4_barns"
	"c2m5_concert"
	// SWAMP FEVER
	"c3m1_plankcountry"
	"c3m2_swamp"
	"c3m3_shantytown"
	"c3m4_plantation"
	// HARD RAIN
	"c4m1_milltown_a"
	"c4m2_sugarmill_a"
	"c4m3_sugarmill_b"
	"c4m4_milltown_b"
	"c4m5_milltown_escape"
	// THE PARISH
	"c5m1_waterfront"
	"c5m1_waterfront_sndscape"
	"c5m2_park"
	"c5m3_cemetery"
	"c5m4_quarter"
	"c5m5_bridge"
	// THE PASSING
	"c6m1_riverbank"
	"c6m2_bedlam"
	"c6m3_port"
	// THE SACRIFICE
	"c7m1_docks"
	"c7m2_barge"
	"c7m3_port"
	// NO MERCY
	"c8m1_apartment"
	"c8m2_subway"
	"c8m3_sewers"
	"c8m4_interior"
	"c8m5_rooftop"
	// CRASH COURSE
	"c9m1_alleys"
	"c9m2_lots"
	// DEATH TOLL
	"c10m1_caves"
	"c10m2_drainage"
	"c10m3_ranchhouse"
	"c10m4_mainstreet"
	"c10m5_houseboat"
	// DEAD AIR
	"c11m1_greenhouse"
	"c11m2_offices"
	"c11m3_garage"
	"c11m4_terminal"
	"c11m5_runway"
	// BLOOD HARVEST
	"c12m1_hilltop"
	"c12m2_traintunnel"
	"c12m3_bridge"
	"c12m4_barn"
	"c12m5_cornfield"
	// COLD STREAM
	"c13m1_alpinecreek"
	"c13m2_southpinestream"
	"c13m3_memorialbridge"
	"c13m4_cutthroatcreek"
	// THE LAST STAND
	"c14m1_junkyard"
	"c14m2_lighthouse"
]




// Mushroom positions of maps ( c1 -14 )
// ----------------------------------------------------------------------------------------------------------------------------

::mushroomPositions <-
{
	c1m1_hotel =
	[
		{ origin = Vector(910.302,5475.81,2656.03), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(3430.85,7487.11,1664.03), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(2168.26,5703.24,2464.03), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(2480.38,6217.6,2656.03), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(2311.68,7656.3,2464.03), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(1924.48,5762.97,1336.03), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(540.982,4832.06,1320.03), angles = "0 0 0", rotating = false, type = "large" }
	]
	c1m2_streets =
	[
		{ origin = Vector(1059.62,4854.1,704.031), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-6132.59,-1135.09,472.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-3897.52,2238.46,320.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-1253.71,777.393,811.381), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-5343.9,-2082.83,456.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-8619.01,-2111.07,963.138), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-7171.31,-4490.4,1224.7), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(1598.73,4225.02,521.433), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-2223.24,982.305,41.804), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-4588.86,1475.42,440.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-8635.88,-4498.73,440.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c1m3_mall =
	[
		{ origin = Vector(6447.99,-2648.58,288.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(1294.77,-2343.76,325.803), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(675.635,-4834.9,536.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(3600.03,-2384.03,825.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(4008.45,-290.606,0.03125), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(2266.34,-1561.81,536.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-198.189,-5201.84,415.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1891.39,-4127.36,574.433), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(6997.87,-1362.59,152.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(3896.59,-2873.28,318.958), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(2754.07,-1866.65,280.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(2414.66,-2412.11,536.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1584.63,-5446.67,364.031), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(-1239.21,-4472.65,318.958), angles = "0 0 0", rotating = false, type = "large" }
	]
	c1m4_atrium =
	[
		{ origin = Vector(-1806.74,-4825.39,621.031), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-2388.27,-3878.41,824.031), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(-3856.95,-3123.88,536.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-2572.11,-5303.06,553.52), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-6031.35,-3306.58,792.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-3340.16,-4001.26,744.781), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-5103.33,-3918.44,408.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-4451.52,-3207.95,106.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-3209.12,-3865.85,107.617), angles = "0 90 0", rotating = false, type = "large" }
		{ origin = Vector(-5343.23,-4186.55,1080.03), angles = "0 0 0", rotating = false, type = "large" }
	]
	c2m1_highway =
	[
		{ origin = Vector(9530.42,8430.98,-176.474), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(2273.79,4287.25,-936.719), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(2188.58,3274.16,-807.969), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(3462.18,8450.17,-843.079), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1168.83,2091.84,-1738.7), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(6915.73,7505.84,-675.791), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(3015.77,6931.89,-899.608), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(2914.95,4895.79,-507.969), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1163.45,2193.78,-1213.73), angles = "0 0 0", rotating = false, type = "large" }
		{ origin = Vector(-1334.14,-2035.05,-510.97), angles = "0 0 0", rotating = false, type = "large" }
	]
	c2m2_fairgrounds =
	[
		{ origin = Vector(3966.348633,-465.165253,48.42), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-1985.2,-3877.99,32.0313), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-3616.02,-721.635,0.03125), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(1576.99,1513.79,8.03125), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-3329.16,-4239.81,352.595), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(2710.8,516.643,200.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-2126.08,318.905,128.031), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(-874.256,-1539.82,128.031), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(-1493.91,-4415.5,-1.77925), angles = "0 0 0", rotating = false, type = "large" }
	]
	c2m3_coaster =
	[
		{ origin = Vector(2048.36,3296.04,196.031), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-1582.4,1617.42,128.281), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-87.7301,3973.93,208.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(2797.84,1638.93,-35.5456), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-3968.39,1550.79,413.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-66.8414,3611.93,208.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-2754.75,1143.2,620.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-3743.81,3732.83,544.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c2m4_barns =
	[
		{ origin = Vector(3138.24,3629.02,-3.96875), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-2756.8,1308.9,-43.9688), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(1081.55,1024.68,-147.969), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(2166.15,1419.64,18.4938), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-226.231,886.084,387.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-1918.83,95.4541,32.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-3042.29,1694.38,-255.969), angles = "0 0 0", rotating = false, type = "large" }
		{ origin = Vector(3715.38,662.404,-191.969), angles = "0 0 0", rotating = false, type = "tiny" }
	]
	c2m5_concert =
	[
		{ origin = Vector(-1096.98,2354.9,-255.969), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-2308.02,3211.99,140.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-2637.91,3340.46,312.678), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-448.975,2760.9,-255.969), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1979.98,2505.26,191.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-2679.04,2500.67,191.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c3m1_plankcountry =
	[
		{ origin = Vector(-10586.4,10170.8,571.008), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-5590.18,6843.73,220.031), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(-980.031,4902.7,144.16), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-1067.97,4902.7,144.16), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-1022.58,4902.7,144.16), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-8121.03,7213.5,266.604), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-5392.27,5891.52,256.034), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(-6212.27,7861.63,48.0313), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-3386.78,6069.38,698.369), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(-2159.44,8640.77,253.1), angles = "0 0 0", rotating = false, type = "large" }
		{ origin = Vector(-1022.87,4946.13,332.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c3m2_swamp =
	[
		{ origin = Vector(-8114.13,5131.93,295.391), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-1801.48,2818.93,47.6229), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(-1884.05,3218.16,36.4844), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(1936.43,1250.89,19.2292), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(7614.55,3192.79,122.329), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1895.61,3104.54,226.169), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(4779.86,1102.69,41.265), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(8702.53,512.321,569.088), angles = "0 0 0", rotating = false, type = "large" }
	]
	c3m3_shantytown =
	[
		{ origin = Vector(-5293.03,1199.51,871.913), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-4088.94,-3094.7,189.711), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(-659.526,-2485.02,4.4949), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-4605.58,-236.376,181.425), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(1532.24,-4869.25,24.0313), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-2651.48,-931.619,74.849), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-5504.8,-3256.66,308.68), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(3013.28,-4477.09,86.1035), angles = "0 90 0", rotating = false, type = "large" }
	]
	c3m4_plantation =
	[
		{ origin = Vector(-3650.61,-1527.09,542.849), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(1665.36,900.156,127.237), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(1788.93,-415.403,224.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(2591.66,57.0649,224.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(2032.64,252.058,416.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(1664.07,314.551,416.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(1663.35,291.383,224.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(1320.5,251.85,416.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(2743.47,-3207.78,65.3052), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(3040.81,2016.1,133.507), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1426.21,-3443.73,187.907), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1665.04,536.081,640.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1867.68,-138.64,600.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c4m1_milltown_a =
	[
		{ origin = Vector(-5801.77,7494.31,1009.75), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(383.878,3381.04,368.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-6356.01,7456.24,104.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-1547.58,6908.92,200.773), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(4152.82,1222.7,184.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-609.475,6187.33,296.031), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(1482.28,4149.37,435.32), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(3617.5,2161.08,368.155), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(3338.04,179.84,586.974), angles = "0 0 0", rotating = false, type = "large" }
	]
	c4m2_sugarmill_a =
	[
		{ origin = Vector(4260,-3671.71,406.515), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-719.081,-7283.16,441.979), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-921.116,-8917.79,295.392), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(2429.61,-5696.4,124.659), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(4315.07,-4528.41,97.6315), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-10.6827,-12670.2,113.272), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(3212.06,-3036.58,1164.28), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(2725.17,-4272.82,329.469), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(2581.79,-6098.72,100.829), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-345.992,-8559.92,624.281), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(-1507.19,-13161,1141.23), angles = "0 0 0", rotating = false, type = "large" }
	]
	c4m3_sugarmill_b =
	[
		{ origin = Vector(-925.624,-13530.8,432.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-53.2867,-6479.09,441.729), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(2434.5,-5315.34,194.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(2587.19,-6096.47,100.157), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(4114.54,-3217.8,406.265), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1106.24,-8463.68,624.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(936.826,-6244.9,638.807), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(430.224,-4582.72,310.428), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1741.85,-3929.74,737.02), angles = "0 0 0", rotating = false, type = "large" }
	]
	c4m4_milltown_b =
	[
		{ origin = Vector(3331.17,-847.188,586.974), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(665.963,2783.55,227.927), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(387.227,3489.37,336.38), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(4327.79,1780.41,363.761), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(673.109,4776.85,131.802), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-1486.32,7441.23,366.277), angles = "0 0 0", rotating = false, type = "large" }
	]
	c4m5_milltown_escape =
	[
		{ origin = Vector(-5868.91,8159.17,348.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-4641.69,7626.45,479.597), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(-6338.14,7169.93,104.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-5432.06,7068.65,100.536), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-5315.37,8567.07,584.038), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-7088.42,7698.42,113.924), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(-5815.44,6623.25,126.972), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-5801.8,7496.52,1009.75), angles = "0 0 0", rotating = false, type = "large" }
	]
	c5m1_waterfront =
	[
		{ origin = Vector(-335.683,64.8597,-52.3949), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-1177.66,-2398.49,144.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-2347.78,-553.647,-367.969), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-2720.07,-1612.63,-13.3263), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-1904.66,-1864.33,-71.9454), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-3068.68,-2336.01,-157.992), angles = "0 0 0", rotating = false, type = "medium" }
	]
	c5m2_park =
	[
		{ origin = Vector(-5054.91,-2216.52,-127.982), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-9802.61,-5213.03,-79.9688), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-8046.08,-6670.04,-247.969), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-7940.64,-6671.62,-247.969), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-7551.83,-416.524,-127.969), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-7166.92,-3491.44,44.5587), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-8789.87,-5193.33,89.7595), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-8113.72,-5774.25,485.766), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-6815.91,-8437.09,250.906), angles = "0 0 0", rotating = false, type = "large" }
	]
	c5m3_cemetery =
	[
		{ origin = Vector(6127.99,7700.52,208.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(5907.05,1012.93,155.243), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(2837.89,2634.4,176.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(4728.95,4570.35,131.378), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(4432.79,3202.69,154.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(6189.01,1337.86,-159.969), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(8768.77,-6591.84,756.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(7417.2,-8926.28,264.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c5m4_quarter =
	[
		{ origin = Vector(-2368.29,3616.46,64.0313), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-639.981,1607.46,224.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-569.655,1031.48,96.0313), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-3650.66,3888.94,384.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(29.7625,-1607.78,287.837), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-1193.22,1488.05,452.401), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-813.288,-2031.78,422.465), angles = "0 0 0", rotating = false, type = "large" }
	]
	c5m5_bridge =
	[
		{ origin = Vector(-6151.38,6420.53,765.699), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-1954.61,6463.8,852.885), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(2792.36,6336.46,790.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(2792.36,6450.22,790.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(2792.36,6211.1,790.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-7031.1,6298.27,456.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-12334.9,6552.2,453.565), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-3862.72,6225.25,897.47), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(2290.68,6425.58,790.031), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(14201,6326.86,790.031), angles = "0 90 0", rotating = false, type = "large" }
	]
	c6m1_riverbank =
	[
		{ origin = Vector(669.412,3116.3,640.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(1168,4459.88,510.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(2095.14,1641.12,352.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(4520.78,2670.4,555.536), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(4461.7,2397.54,224.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-4004.19,554.621,864.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-4223.99,1571.49,727.091), angles = "0 0 0", rotating = false, type = "large" }
	]
	c6m2_bedlam =
	[
		{ origin = Vector(2148.07,-1201.23,288.031), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(1750.27,3709.59,-275.002), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(1498.32,4839.88,-159.969), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-224.862,1354.13,28.093), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(1213.93,1966.51,336.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(998.689,2701.23,96.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1589.86,4615.77,32.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(2868.05,5702.03,-1063.97), angles = "0 90 0", rotating = false, type = "large" }
		{ origin = Vector(5883.71,4207.33,-890.867), angles = "0 0 0", rotating = false, type = "large" }
	]
	c6m3_port =
	[
		{ origin = Vector(-2248.68,-646.404,320.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-1761.71,256.046,156.841), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(583.696,1765.25,160.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-1184.55,-952.523,0.03125), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-788.678,-952.523,0.03125), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-1379.67,-952.523,0.03125), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-374.426,-889.011,0.0760522), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(447.796,1824.08,160.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-901.026,2123.37,320.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(345.633,-358.962,184.031), angles = "0 0 0", rotating = false, type = "small" }
	]
	c7m1_docks =
	[
		{ origin = Vector(14063.8,2301.94,16.2378), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(10153.7,449.507,129.809), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(11410.8,-229.048,-63.9688), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(12001.8,-787.905,-35.1111), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(5208.64,552.395,382.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(4679.74,764.071,303.384), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(2516.95,-188.518,138.451), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(3404.88,1676.66,336.031), angles = "0 90 0", rotating = false, type = "large" }
	]
	c7m2_barge =
	[
		{ origin = Vector(9920.64,608.323,322.374), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-3827.21,671.672,342.031), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(2140.39,1436.81,132.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(5435.93,755.192,256.282), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(10062.7,2095.96,305.796), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-593.486,2559.1,756.694), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-2894.79,725.009,576.031), angles = "0 90 0", rotating = false, type = "large" }
	]
	c7m3_port =
	[
		{ origin = Vector(1052.7,2623.67,544.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-2137.34,-539.338,-95.9688), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(680.945,2047.86,160.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(583.284,1770.19,160.758), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-938.757,931.624,352.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(736.739,2264.6,640.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(1560.46,168.305,345.56), angles = "0 90 0", rotating = false, type = "large" }
	]
	c8m1_apartment =
	[
		{ origin = Vector(1811.17,1797.96,640.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(896.289,3030.33,637.176), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(2797.04,4191.32,15.8693), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(334.88,767.923,957.29), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(2624.62,2212.92,945.241), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(1976.26,3944.68,608.031), angles = "0 0 0", rotating = false, type = "large" }
		{ origin = Vector(3493.26,4004.85,1436.03), angles = "0 0 0", rotating = false, type = "tiny" }
	]
	c8m2_subway =
	[
		{ origin = Vector(2937.46,4155.97,-178.67), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(8467.56,3832.97,376.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(4526.2,3801.29,-287.969), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(2204.75,3968.89,-335.969), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(6775.15,2899.15,-178.67), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(7567.9,3417.3,424.031), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(8328.45,4596.1,1216.03), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(8805.87,5685.34,768.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c8m3_sewers =
	[
		{ origin = Vector(12631.2,5360.45,957.54), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(12712.9,6696.47,800.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(13137.6,7424.46,16.0313), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(11203.7,5091.59,712.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(11852.1,7923.79,276.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(13711,10120.7,-358.28), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(13068.6,10985.1,-191.969), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(13070.8,11448,-277.217), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(13788.6,11101.2,746.031), angles = "0 0 0", rotating = false, type = "large" }
		{ origin = Vector(13198.7,13927.2,5624.03), angles = "0 0 0", rotating = false, type = "large" }
	]
	c8m4_interior =
	[
		{ origin = Vector(12162.3,13317.7,42.4583), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(13687.1,14624.8,576.031), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(12718.3,14651.8,424.772), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(13695.3,13991.1,5641.54), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(12314.1,13388.4,152.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(13439.6,15006.3,624.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(14045.5,14862.1,5920.03), angles = "0 0 0", rotating = false, type = "large" }
	]
	c8m5_rooftop =
	[
		{ origin = Vector(7487.75,9322.88,6314.71), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(5986.62,7845.9,6210.03), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(7303.02,8911.17,6092.24), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(7048.08,9024.08,6096.03), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(6960.91,9464.52,5644.03), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(7022.35,7746.25,16.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(7714.38,9340.58,5952.03), angles = "0 0 0", rotating = false, type = "large" }
	]
	c9m1_alleys =
	[
		{ origin = Vector(-8671.74,-9921.56,384.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(205.191,-6577.32,-45.685), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-2334.43,-8371.1,0.03125), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-7876.03,-10448,192.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-6194.29,-10207.2,348.124), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(-2692.39,-9362.13,362.682), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-1326.74,-3292.39,445.932), angles = "0 0 0", rotating = false, type = "large" }
	]
	c9m2_lots =
	[
		{ origin = Vector(1621.53,-1232.15,186.989), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(6858.532,6943.091,223.031), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(7559.25,6343.99,48.0313), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(7559.25,6680.94,48.0313), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(7535.98,6160.13,427.767), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(3568.14,-492.286,35.807), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(1761.86,218.214,45.0175), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(7844.706,6643.726,375.036), angles = "0 90 0", rotating = false, type = "large" }
	]
	c10m1_caves =
	[
		{ origin = Vector(-11659.9,-13385.5,554.054), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-12974.9,-6724.85,176.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-12244.6,-5599.09,-73.601), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-13089.6,-5241.27,-287.969), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-12349.5,-9805.34,496.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-12974.9,-5860.65,176.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-10690.6,-4991.48,688.028), angles = "0 90 0", rotating = false, type = "large" }
	]
	c10m2_drainage =
	[
		{ origin = Vector(-11215.6,-8447.19,-273.116), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-8220.77,-8322.58,-452.1), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-9873.86,-7689.84,-376.396), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-10213.5,-8154.52,-162.483), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-9872.4,-6733.67,-307.969), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-7846.5,-6987.36,-457.214), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-8826.14,-7633.1,953.457), angles = "0 0 0", rotating = false, type = "large" }
	]
	c10m3_ranchhouse =
	[
		{ origin = Vector(-9839.35,-6342.99,89.6114), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-4811.54,-1131.53,506.244), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-9440.1,-2750.96,-38.9688), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-6958,-1886.3,8.03125), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-8059.92,-5811.83,400.031), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-12539.413,-6515.756,408.296), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-9092.79,-3946.72,356.642), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-5081.95,-1693.59,626.119), angles = "0 0 0", rotating = false, type = "large" }
	]
	c10m4_mainstreet =
	[
		{ origin = Vector(-3068.25,-57.6381,1039.03), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(2790.76,-1699.64,336.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-1375.73,-4670.05,-55.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-1425.11,-4670.65,-55.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(137.127,-1897.99,112.031), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(2756.35,-2412.78,336.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(1617.19,-4384.35,96.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-673.274,-4583.52,176.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-1399.49,-4674.15,192.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c10m5_houseboat =
	[
		{ origin = Vector(2123.12,2634.09,326.222), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(4225.13,-5089.24,-170.896), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(2874.1,2413.57,-39.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(3065.88,2759.15,-39.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(3952.22,256.841,324.537), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(3854.66,4218.71,320.031), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(4264.85,-4686.83,231.018), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(2195.19,-4720.26,-35.1493), angles = "0 0 0", rotating = false, type = "large" }
	]
	c11m1_greenhouse =
	[
		{ origin = Vector(6418.19,-690.905,831.396), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(3427.550,1374.021,819.144), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(3518.21,2217.03,183.338), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(3370.21,731.601,554.228), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(2910.57,2108.9,416.535), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(4351.72,-300.349,1116.8), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(3394.22,-871.949,1029.47), angles = "0 0 0", rotating = false, type = "large" }
	]
	c11m2_offices =
	[
		{ origin = Vector(5488.19,4064.33,434.733), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(7419.72,3330.88,1212.23), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(7513.56,5654.95,16.0313), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(5839.04,3168.24,523.664), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(6272.13,1022.59,16.0313), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(5447.53,3558.41,303.983), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(6623.48,4828.47,600.482), angles = "0 0 0", rotating = false, type = "large" }
	]
	c11m3_garage =
	[
		{ origin = Vector(-3838.76,-3139.08,936.54), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-5872.75,-1719.78,512.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-3488.1,2854.93,32.0313), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-3647.99,2854.92,31.0313), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-3565.8,2854.83,32.0313), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-4952.03,-2623.2,352.031), angles = "0 90 0", rotating = false, type = "tiny" }
		{ origin = Vector(-6805.34,-1273.95,550.072), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-5239.47,124.543,1301.27), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-2881.81,3153.91,160.031), angles = "0 90 0", rotating = false, type = "large" }
	]
	c11m4_terminal =
	[
		{ origin = Vector(-93.3845,4457.05,144.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(98.4939,3620.52,16.0313), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(1163.08,4456.62,296.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(710.154,5631.1,296.031), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(541.737,3785.52,536.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(471.801,2959.14,348.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(2130.92,1586.85,448.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(2780.61,6941.86,313.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c11m5_runway =
	[
		{ origin = Vector(-6838.83,9651.14,568.031), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-5431.83,11812.2,62.8417), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-5418.15,10341.3,60.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-6900.6,11531.3,-191.969), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-6891.96,10827.7,-191.969), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-5795.82,9010.43,176.974), angles = "0 0 0", rotating = false, type = "large" }
	]
	c12m1_hilltop =
	[
		{ origin = Vector(-8089.921,-15117.432,277.785), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-6446.82,-8719.63,1015.15), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-6553.63,-7570.19,384.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-6418.22,-7523.43,365.19), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-6367.87,-7414.88,377.974), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-10427.594,-13344.635,746.753), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-10980.1,-10901.5,938.975), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-8990.35,-8981.87,1062.03), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-7808.35,-9486.53,992.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c12m2_traintunnel =
	[
		{ origin = Vector(-8229.1,-7517.71,160.353), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-7719.68,-8901.63,304.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-4604.06,-8322.47,-63.5097), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-4175.46,-8323.85,-63.9688), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-3711.27,-8392.14,-63.1514), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-8740.09,-7214.79,200.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-8547.49,-8900.32,304.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-7563.7,-8612.52,826.025), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-4185.79,-8717.72,232.031), angles = "0 90 0", rotating = false, type = "large" }
	]
	c12m3_bridge =
	[
		{ origin = Vector(-1137.81,-10944.3,160.031), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(1827.29,-12229.5,484.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(1913.03,-12602.3,-31.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(2030.97,-12602.3,-31.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(1970.48,-12602.3,-31.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-952.414,-10439.4,72.0312), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(3342.01,-14299.5,169.088), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(4914.05,-13113.9,1141.33), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(5932.44,-13851.9,272.05), angles = "0 0 0", rotating = false, type = "large" }
	]
	c12m4_barn =
	[
		{ origin = Vector(9334.13,-9355.23,932.537), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(11022.1,-4584.55,324.481), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(10382,-2600.35,-63.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(10526,-2600.35,-63.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(10453.7,-2600.35,-63.9688), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(7488.13,-10687,897.565), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(10616.6,-7429.15,274.641), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(9688.78,-4243.98,722.381), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(10453.7,-1712.4,268.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c12m5_cornfield =
	[
		{ origin = Vector(10059.6,821.12,462.47), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(7138.16,270.204,596.031), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(8960.78,3370.82,201.741), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(9060.78,3370.82,204.697), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(9272.22,3547.45,961.057), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(8446.37,422.173,590.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(6823.95,1191.26,794.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(7186.65,2650.19,1034.12), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(7536.12,2649.97,1034.12), angles = "0 0 0", rotating = false, type = "large" }
	]
	c13m1_alpinecreek =
	[
		{ origin = Vector(-2778.1,1140.71,255.406), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(1200.27,1406.95,1601.38), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(992.23,183.899,585.485), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(1120.63,183.726,585.398), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-2876.72,2797.21,1273), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-2332,3247.16,976.031), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(869.342,2451.07,805.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(880.042,-464,476.011), angles = "0 90 0", rotating = false, type = "large" }
	]
	c13m2_southpinestream =
	[
		{ origin = Vector(7961.18,6390.28,585.92), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(6728,2925.41,1216.03), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(78.6595,8679.27,-404.969), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(8107.63,4172.91,649.555), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(5677.56,2211.83,1090), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(4905.09,2577.37,1120.03), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-356.712,4977.07,272.031), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-348.279,6151.25,302.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c13m3_memorialbridge =
	[
		{ origin = Vector(-2169.22,-4092.02,1758.03), angles = "0 90 0", rotating = true, type = "bh" }
		{ origin = Vector(-2169.54,-4092.02,2201.03), angles = "0 90 0", rotating = false, type = "item" }
		{ origin = Vector(1003.74,-4472.38,590.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-3844.47,-4095.34,896.031), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(6777.83,-4114.74,2201.03), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(3687.47,-4074.24,2201.03), angles = "0 90 0", rotating = false, type = "medium" }
		{ origin = Vector(3686.79,-4095.17,896.031), angles = "0 90 0", rotating = false, type = "large" }
	]
	c13m4_cutthroatcreek =
	[
		{ origin = Vector(-3872.6,-8143.45,723.031), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-772.295,3198.8,-101.969), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-1174.01,4688.39,180.031), angles = "0 0 0", rotating = false, type = "exp" }
		{ origin = Vector(-3622.38,-5926.86,623.746), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-3916.44,-3227.55,360.898), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-653.084,1568.25,18.0313), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-391.136,3752.91,88.0313), angles = "0 0 0", rotating = false, type = "large" }
	]
	c14m1_junkyard =
	[
		{ origin = Vector(-4227.94,-8819.65,103), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-2505.24,1649.99,182.772), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(-4450.59,2204.69,-58.7463), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-1669.74,-5730.32,-300.582), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(-2676.9,2190.81,-50.752), angles = "0 0 0", rotating = false, type = "small" }
		{ origin = Vector(-4814.390,2711.914,100.450), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-2407,7408.93,168.031), angles = "0 0 0", rotating = false, type = "large" }
	]
	c14m2_lighthouse =
	[
		{ origin = Vector(1319.83,344.463,830.588), angles = "0 0 0", rotating = true, type = "bh" }
		{ origin = Vector(-2479.24,5569.72,-101.291), angles = "0 0 0", rotating = false, type = "item" }
		{ origin = Vector(320.403,923.429,560.905), angles = "0 90 0", rotating = false, type = "exp" }
		{ origin = Vector(-4567.81,3575.97,1400.03), angles = "0 0 0", rotating = false, type = "tiny" }
		{ origin = Vector(479.378,946.381,696.031), angles = "0 90 0", rotating = false, type = "small" }
		{ origin = Vector(-981.672,2524.87,701.112), angles = "0 0 0", rotating = false, type = "medium" }
		{ origin = Vector(-4725,5825,-92.968), angles = "0 0 0", rotating = false, type = "large" }
	]
}




// Output count of mushroom statistics
// ----------------------------------------------------------------------------------------------------------------------------

::map_mushroom_stats <- {}

::outputMushroomData <- function(){
	
	map_mushroom_stats.clear()
	local count_total = 0
	local nl = "\n"
	
	foreach(mapname, mushroomArray in mushroomPositions){
		foreach(DS in mushroomArray){
			local type = DS.type
			if(!(mapname in map_mushroom_stats)){
				map_mushroom_stats[mapname] <- { bh = 0, exp = 0, item = 0, tiny = 0, small = 0, medium = 0, large = 0 }
			}
			map_mushroom_stats[mapname][type] += 1
			count_total += 1
		}
	}
	
	printl("- - - - Mushroom stats - - - -" + nl)
	//
	printl("Total count of placed mushrooms: " + count_total + " ( " + mushroomPositions[mapName].len() + " in this map )" + nl)
	//
	foreach(mapname, datatable in map_mushroom_stats){
		printl("================== " + mapname + " " + GetCharChain("=", 32 - mapname.len() ) + nl)
		printl("BunnyHop: " + datatable.bh + "  Explosive: " + datatable.exp + "  Item: " + datatable.item)
		printl("Tiny: " + datatable.tiny + "  Small: " + datatable.small + "  Medium: " + datatable.medium + "  Large: " + datatable.large + nl)
	}
}




// Returns a concatenated string of the passed string with length of num
// ----------------------------------------------------------------------------------------------------------------------------

::GetCharChain <- function(str, num){
	local txt = ""
	for(local i = 0; i < num; i++){
		txt += str
	}
	return txt
}




// Returns the slot the weapon belongs to
// ----------------------------------------------------------------------------------------------------------------------------

function getItemSlot(item){
	local className = item.GetClassname()
	
	local slot0 =
	[
		"weapon_grenade_launcher","weapon_rifle_m60",
		"weapon_rifle","weapon_rifle_desert","weapon_rifle_ak47",
		"weapon_rifle_sg552","weapon_smg_mp5",
		"weapon_shotgun_chrome","weapon_pumpshotgun",
		"weapon_shotgun_spas","weapon_autoshotgun",
		"weapon_smg","weapon_smg_silenced",
		"weapon_hunting_rifle","weapon_sniper_military",
		"weapon_sniper_scout","weapon_sniper_awp"
	]
	local slot1 = 
	[
		"weapon_melee","weapon_chainsaw",
		"weapon_pistol","weapon_pistol_magnum"
	]
	local slot2 =
	[
		"weapon_molotov","weapon_pipe_bomb","weapon_vomitjar"
	]
	local slot3 =
	[
		"weapon_first_aid_kit","weapon_defibrillator",
		"weapon_upgradepack_explosive","weapon_upgradepack_incendiary"
	]
	local slot4 =
	[
		"weapon_adrenaline","weapon_pain_pills"
	]
	local slot5 = 
	[
		"weapon_oxygentank","weapon_propanetank","weapon_gascan",
		"weapon_gnome","weapon_cola_bottles","weapon_fireworkcrate"
	]

	if(slot0.find(className) != null){
		return "slot0"
	}else if(slot1.find(className) != null){
		return "slot1"
	}else if(slot2.find(className) != null){
		return "slot2"
	}else if(slot3.find(className) != null){
		return "slot3"
	}else if(slot4.find(className) != null){
		return "slot4"
	}else if(slot5.find(className) != null){
		return "slot5"
	}else{
		return null
	}
}




// This will track timings of the survivor
// ----------------------------------------------------------------------------------------------------------------------------

::PlayerTimeData <- {}

function PlayerTimer(ent){

	if(!(ent in PlayerTimeData)){
		PlayerTimeData[ent] <- { timerActive = false, finished = false, startTime = Time(), endTime = Time(), time_best = 0, ticks = 0, seconds = 0 }
	}
	
	if(PlayerIsOnGround(ent)){
		if(ent in PlayerTimeData){
			if(!PlayerTimeData[ent].finished){
				if(PlayerTimeData[ent].ticks < 30){
					PlayerTimeData[ent].ticks += 1
				}else{
					PlayerTimeData[ent].ticks = 0
					PlayerTimeData[ent].seconds += 1
				}
			}
		}
	}
}




// Check if survivor reached the saferoom
// ----------------------------------------------------------------------------------------------------------------------------

function survivorSaferoomCheck(ent){
	if(!PlayerTimeData[ent].finished){
		if( ResponseCriteria.GetValue(ent, "incheckpoint" ) == "1" ){
			printFinalGroundTime(ent)
			ProcessSurvivorTime(ent)
		}
	}
}




// Iteration over all human player and pass them to different methods
// ----------------------------------------------------------------------------------------------------------------------------

function PlayerFunctions(){
	foreach(ent in GetHumanSurvivors()){
		if(ent.IsValid()){
			PlayerTimer(ent)
			survivorSaferoomCheck(ent)
		}
	}
}




// Returns true when player is on the ground
// ----------------------------------------------------------------------------------------------------------------------------

function PlayerIsOnGround(player){
	if(NetProps.GetPropInt(player, "m_fFlags") & 1){
		return true
	}
	return false
}




// Print a chat message in color x 
// ----------------------------------------------------------------------------------------------------------------------------

function toChat(color, message, sound){
	local player = Entities.FindByClassname(null, "player")
	switch(color)
	{
		case "white"	: color = "\x01" ; break
		case "blue"		: color = "\x03" ; break
		case "orange"	: color = "\x04" ; break
		case "green"	: color = "\x05" ; break
	}
	switch(sound)
	{
		case "reward"	: sound = "ui/littlereward.wav" ; break
		case "error"	: sound = "ui/beep_error01.wav" ; break
		case "click"	: sound = "ui/menu_click01.wav" ; break
	}
	ClientPrint(null, 5, color + message)
	if(sound != null){
		EmitAmbientSoundOn( sound, 1, 100, 100, player)
	}
}




// Will change the model of "tank_rock" to a log when it is a L4D1 map
// When "last chance mode" is active, the rock will start glowing
// ----------------------------------------------------------------------------------------------------------------------------

function tankrockListener(){
	local rock = null

	while(rock = Entities.FindByClassname(rock, "tank_rock")){
		if(rock.IsValid()){
			local scope = GetValidatedScriptScope(rock)
			
			if(survivorSet == 1){
				if(!("usesLog" in scope)){
					rock.SetModel("models/props_foliage/tree_trunk.mdl")
					scope["usesLog"] <- true
				}
			}
			
			// When last change mode is active we need to enable the glow on all new rocks
			if(last_chance_active){
				if(!("glowing" in scope)){
					NetProps.SetPropInt(rock, "m_Glow.m_iGlowType", 3)
					rock.GetScriptScope()["glowing"] <- true
				}
			}
		}
	}
}




// Returns the given color with changed intesity as string 
// ----------------------------------------------------------------------------------------------------------------------------

function getColorWithIntensity(color, intensity){	

	local values = split(color, " ")
	
	local rNew = values[0].tofloat()
	local gNew = values[1].tofloat()
	local bNew = values[2].tofloat()

	rNew	= (rNew / 100 * intensity).tointeger()
	gNew	= (gNew / 100 * intensity).tointeger()
	bNew	= (bNew / 100 * intensity).tointeger()

	return "" + rNew + " " + gNew + " " + bNew
}




// Is the current server a local one
// ----------------------------------------------------------------------------------------------------------------------------

function OnLocalServer(){
	if(GetListenServerHost() == null){
		return false
	}
	return true
}


