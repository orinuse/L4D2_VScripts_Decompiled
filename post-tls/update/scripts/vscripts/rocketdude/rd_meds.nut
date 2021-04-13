//****************************************************************************************
//																						//
//										rd_meds.nut										//
//																						//
//****************************************************************************************



// All mushroom triggers to iterate over
// ----------------------------------------------------------------------------------------------------------------------------

::medkit_triggers	<- []




// Returns handle of the created prop_dynamic with a 'mushroom model'
// ----------------------------------------------------------------------------------------------------------------------------

::RD_healtkit_model <- function(pos, ang, shroomdata){
	local model = SpawnEntityFromTable("prop_dynamic_override",
	{
		// General
		targetname = "RD_HP_MODEL", origin = pos, angles = ang, body = 0, DefaultAnim = "idle", DisableBoneFollowers = 1,
		// Shadows and fade
		disablereceiveshadows = 1, disableshadows = 1, disableX360 = 0, ExplodeDamage = 0, ExplodeRadius = 0, fademaxdist = 0, fademindist = -1, fadescale = 0,
		// Glows
		glowbackfacemult = 1.0, glowcolor = shroomdata.glowColor, glowrange = shroomdata.glowRange, glowrangemin = 0, glowstate = shroomdata.glowstate, health = 0,
		// Model & Animation
		LagCompensate = 0, MaxAnimTime = 10, maxcpulevel = 0, maxgpulevel = 0, MinAnimTime = 5,
		mincpulevel = 0, mingpulevel = 0, model = "models/props_collectables/mushrooms_glowing.mdl", PerformanceMode = 0, pressuredelay = 0,
		RandomAnimation = 0, renderamt = 255, rendercolor = shroomdata.modelColor, renderfx = 0, rendermode = 0, SetBodyGroup = 0, skin = 0,
		solid = 0, spawnflags = 0, updatechildren = 0
	})
	model.SetModelScale(shroomdata.modelScaleMax, 0)
	return model
}




// Creates a survivor only filter for the mushrooms
// ----------------------------------------------------------------------------------------------------------------------------

SpawnEntityFromTable("filter_activator_team", { targetname = "RD_FILTER_SURVIVOR", origin = Vector(0,0,0), Negated = 0, filterteam = 2 } )
::worldspawn <- Entities.FindByClassname(null, "worldspawn")
::worldspawn.ValidateScriptScope()




// Returns handle of trigger to execute the healing function
// ----------------------------------------------------------------------------------------------------------------------------

::RD_healthkit_trigger <- function(pos, shroomdata){
	local triggerMin = shroomdata.triggerSize[0]
	local triggerMax = shroomdata.triggerSize[1]
	local zOffset = triggerMax.z
	local HP_Value = shroomdata.hp
	
	local triggerName = "RD_HP_TRIGGER"
	//
	local triggerTable =
	{
		targetname    = triggerName
		StartDisabled = 0
		spawnflags    = 1
		allowincap    = 1
		entireteam    = 0
		filtername    = "RD_FILTER_SURVIVOR"
		origin        = pos + Vector(0,0,zOffset)
	}

	local trigger = SpawnEntityFromTable( "trigger_multiple", triggerTable)
	//
	setTriggerSize(trigger,triggerMin,triggerMax)
	NetProps.SetPropInt(trigger, "m_Collision.m_nSolidType", 2)
	//
	EntFire( triggerName, "AddOutput", "OnStartTouch worldspawn:RunScriptCode:survivorMedKitTouch(activator):0:-1" )
	EntFire( triggerName, "AddOutput", "OnTouching worldspawn:RunScriptCode:survivorMedKitTouch(activator):0:-1" )
	//
	if(DevModeActive()){
		DebugDrawBox( triggerTable.origin, Vector(32,32,32), Vector(-32,-32,-32), 255, 255, 255, 0, 16)
	}
	return trigger
}




// Sets the trigger size in relation to the mushroom size
// ----------------------------------------------------------------------------------------------------------------------------

function setTriggerSize(trigger, vectorMins, vectorMaxs){
	if(trigger.IsValid()){
		if(typeof(vectorMins) == "Vector"){
			if(typeof(vectorMaxs) == "Vector"){
				NetProps.SetPropVector(trigger, "m_Collision.m_vecMins", vectorMins)
				NetProps.SetPropVector(trigger, "m_Collision.m_vecMaxs", vectorMaxs)
			}else{
				error("setTriggerSize error: vectorMaxs ment to be datatype vector")
			}
		}else{
			error("setTriggerSize error: vectorMins ment to be datatype vector")
		}
	}
}




// Creates a set of trigger and prop_dynamic_override ( healing mushroom )
// ----------------------------------------------------------------------------------------------------------------------------

::createRD_Medkit <- function(pos, ang, rotating, shroomdata){
	local HP_Val = shroomdata.hp

	local trigger = RD_healthkit_trigger(pos, shroomdata);
	local model = RD_healtkit_model(pos, ang, shroomdata);
	
	local mushroomTable =
	{
		model = model
		trigger = trigger
		restoreTime = shroomdata.restoreTime
		usetime = Time() - shroomdata.restoreTime
		usable = true
		hp = HP_Val
		modelScaleMin = shroomdata.modelScaleMin
		modelScaleMax = shroomdata.modelScaleMax
		glowstate = shroomdata.glowstate
		action = shroomdata.action
		flashColor = shroomdata.flashColor
	}
	medkit_triggers.append(trigger)
	
	addTableToEntityScope(trigger, mushroomTable)
	addTableToEntityScope(model, mushroomTable)
	
	if(rotating){
		AttachRotatorTo(model)
	}
}

::addTableToEntityScope <- function(ent, table){
	
	local scope = GetValidatedScriptScope(ent)
	
	foreach(key, value in table){
		scope[key] <- value
	}
}




// Mushrooms properties
// ----------------------------------------------------------------------------------------------------------------------------
::shroomProperties <-
{
	large 	= 	{ hp = 75, action = "HP", restoreTime = 16, modelColor = "255 185 0", flashColor = "255 185 0", glowRange = 256, glowstate = 3, glowColor = "255 185 0", GlowColorRelation = true, modelScaleMax = 7.0, modelScaleMin = 1.0, triggerSize = [ Vector(-28,-28,-28), Vector(28,28,28) ] }
	medium 	=	{ hp = 50, action = "HP", restoreTime = 16, modelColor = "220 0 255", flashColor = "220 0 255", glowRange = 256, glowstate = 3, glowColor = "220 0 255", GlowColorRelation = true, modelScaleMax = 5.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
	small	=	{ hp = 25, action = "HP", restoreTime = 16, modelColor = "0 105 255", flashColor = "0 105 255", glowRange = 256, glowstate = 3, glowColor = "0 105 255", GlowColorRelation = true, modelScaleMax = 3.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
	tiny	=	{ hp = 10, action = "HP", restoreTime = 16, modelColor = "255 255 255", flashColor = "255 255 255", glowRange = 256, glowstate = 3, glowColor = "255 255 255", GlowColorRelation = true, modelScaleMax = 2.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
	exp		=	{ hp = 0, action = "EXP", restoreTime = 8, modelColor = "0 0 0", flashColor = "0 0 0", glowRange = 128, glowstate = 3, glowColor = "255 0 0", GlowColorRelation = false, modelScaleMax = 4.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
	item	=	{ hp = 0, action = "ITEM", restoreTime = 16, modelColor = "0 0 255", flashColor = "0 0 255", glowRange = 512, glowstate = 3, glowColor = "0 0 255", GlowColorRelation = true, modelScaleMax = 4.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
	bh		=	{ hp = 0, action = "BH", restoreTime = 1, modelColor = "0 255 0", flashColor = "0 255 0", glowRange = 1024, glowstate = 3, glowColor = "0 255 0", GlowColorRelation = true, modelScaleMax = 4.0, modelScaleMin = 1.0, triggerSize = [ Vector(-16,-16,-16), Vector(16,16,16) ] }
}

foreach(dataset in shroomProperties){
	if(dataset.glowstate == 3 && dataset.GlowColorRelation){
		dataset.glowColor = getColorWithIntensity(dataset.modelColor, 77)
	}
}




// After a mushroom heals a player it should be invisible for 10 seconds
// ----------------------------------------------------------------------------------------------------------------------------

::setMedVisibility <- function(x, ent){
	
	local scope = GetValidatedScriptScope(ent)
	
	if(x == 0){
		NetProps.SetPropInt(ent, "m_Glow.m_iGlowType", 0)
		NetProps.SetPropInt(ent, "m_fEffects", NetProps.GetPropInt(ent, "m_fEffects") | (1 << 5))
		mushroomSizer(ent,scope.modelScaleMin, 0)
	}else{
		NetProps.SetPropInt(ent, "m_fEffects", 0)
		NetProps.SetPropInt(ent, "m_Glow.m_iGlowType", scope.glowstate)
		mushroomSizer(ent,scope.modelScaleMax, 0.1)
		EmitAmbientSoundOn("level/popup.wav", 1, 100, 100, ent)
	}
}




// Let's the mushroom "grow"
// ----------------------------------------------------------------------------------------------------------------------------

::mushroomSizer <- function(ent, scale, time){
	ent.SetModelScale(scale, time)
}




// Survivor touches a mushroom trigger
// ----------------------------------------------------------------------------------------------------------------------------

::survivorMedKitTouch <- function(player){
	
	// Has to be set when this fuction gets called via OnTouching because the activator is the trigger itself
	
	if(player.GetClassname() == "trigger_multiple"){
		player = Entities.FindByClassnameNearest("player", player.GetOrigin(), 256)
	}
	
	local playerPos = player.GetOrigin()
	local medkit_trigger = Entities.FindByNameNearest("RD_HP_TRIGGER", playerPos, 256)
	
	local scope = GetValidatedScriptScope(medkit_trigger)
	
	local HP_Val = scope.hp
	local action = scope.action
	local flashColor = split(scope.flashColor," ")
	
	local medkit_model = scope.model
	local mushroomUsed = false
	
	if(!IsPlayerABot(player)){
		if(!missionFailed){
			if(Time() >= scope.usetime + scope.restoreTime){
				if(action == "HP"){
					if(player.GetHealth() < player.GetMaxHealth() || player.IsIncapacitated()){
						healPlayer(player, HP_Val)
						mushroomUsed = true
					}
				}else if(action == "BH"){
					if(!(player in bunnyPlayers)){
						playerBecomesBunny(player)
						player.UseAdrenaline(7)
						mushroomUsed = true
					}
				}else if(action == "EXP"){
					executeExplosion(medkit_trigger)
					mushroomUsed = true
				}else if(action == "ITEM"){
					if(!player.IsIncapacitated()){
						local invTable = {}
						GetInvTable(player, invTable)
						if(!("slot2" in invTable)){
							giveRandomItem(player, medkit_trigger)
							mushroomUsed = true
						}
					}
				}
				if(mushroomUsed){
					scope.usetime = Time()
					scope.usable = false
					setMedVisibility(0, medkit_model)
					ScreenFade(player, flashColor[0].tointeger(), flashColor[1].tointeger(), flashColor[2].tointeger(), 128, 1.0, 0, 1)
				}
			}
		}
	}
}




// Sounds used by the mushrooms 
// ----------------------------------------------------------------------------------------------------------------------------

::mushroomSounds <-
{
	explosions =
	[
		"player/boomer/explode/explo_medium_09.wav",
		"player/boomer/explode/explo_medium_10.wav",
		"player/boomer/explode/explo_medium_14.wav"
	]
	misc =
	[
		"level/gnomeftw.wav",
		"player/laser_on.wav",
		"ui/menu_invalid.wav"
	]
}





::precacheSounds <- function(){
	foreach(collection in mushroomSounds){
		foreach(sound in collection){
			PrecacheSound(sound)
		}
	}
}




// Mushroom action ( explosion )
// ----------------------------------------------------------------------------------------------------------------------------

::executeExplosion <- function(ent){
	local location = ent.GetOrigin()
	local expTable =
	{
		origin = location
		fireballsprite = "sprites/zerogxplode.spr"
		ignoredClass = 0
		targetname = "exp"
		iMagnitude = 128
		spawnflags = 0
		iRadiusOverride = 128
		rendermode = 5
	}
	
	local exp = SpawnEntityFromTable("env_explosion", expTable)
	DoEntFire("!self", "explode", "", 0, exp, exp)
	local sounds = mushroomSounds.explosions
	EmitAmbientSoundOn(sounds[RandomInt(0, sounds.len() - 1)], 0.8, 100, 147, ent)
}




// Mushroom action ( bunny-hop )
// ----------------------------------------------------------------------------------------------------------------------------

::playerBecomesBunny <- function(player){
	if(!(player in bunnyPlayers)){
		if(player.IsValid()){
			bunnyPlayers[player] <- player
			ClientPrint(null, 5, "\x03" + player.GetPlayerName() + "\x01" + " is a bunny now.")
			EmitAmbientSoundOn("player/laser_on.wav", 1, 100, 180, player)
		}
	}
}




// Mushroom action ( random item )
// ----------------------------------------------------------------------------------------------------------------------------

::giveRandomItem <- function(player, shroom){
	local throwables = [ "weapon_pipe_bomb", "weapon_vomitjar", "weapon_molotov" ]
	player.GiveItem(throwables[RandomInt(0, throwables.len() - 1)])
	EmitAmbientSoundOn(mushroomSounds.misc[0], 0.5, 100, 170, shroom)
}




// Mushroom action ( healing )
// ----------------------------------------------------------------------------------------------------------------------------

::healPlayer <- function(player, val){
	
	local sndPitch = 100;
	switch(GetCharacterDisplayName(player)){
		case "Rochelle"	:	sndPitch = 115; break;
		case "Zoey"		: 	sndPitch = 135; break;
		default			: 	sndPitch = 100; break;
	}
	
	EmitAmbientSoundOn("player/items/pain_pills/pills_use_1.wav", 1, 100, sndPitch, player)
	StopAmbientSoundOn("player/heartbeatloop.wav", player) 
	player.UseAdrenaline(7)
	local newHP = player.GetHealth() + val
	local playerMaxHealth = player.GetMaxHealth()
	
	if(player.IsIncapacitated())
	{
		player.ReviveFromIncap()
		player.SetReviveCount(0)
		player.SetHealthBuffer(0)
		player.SetHealth(val)
	}
	else
	{
		if(newHP >= playerMaxHealth)
		{
			//NetProps.SetPropInt(player,"m_isGoingToDie",0)
			//NetProps.SetPropInt(player,"m_isIncapacitated",0)
			player.ReviveFromIncap()
			player.SetReviveCount(0)
			player.SetHealthBuffer(0)
			player.SetHealth(playerMaxHealth)
		}
		else
		{
			//NetProps.SetPropInt(player,"m_isGoingToDie",0)
			//NetProps.SetPropInt(player,"m_isIncapacitated",0)
			player.ReviveFromIncap()
			player.SetReviveCount(0)
			player.SetHealthBuffer(0)
			player.SetHealth(newHP)
		}
	}
}




// Called "OnGameplayStart" it will spawn mushrooms for the current map 
// ----------------------------------------------------------------------------------------------------------------------------

spawnMushrooms <- function(){
	if(mapName in mushroomPositions){
		foreach(DS in mushroomPositions[mapName]){
			createRD_Medkit(DS.origin, DS.angles, DS.rotating, shroomProperties[DS.type])
		}
	}
}




// When specified in mushroom definition the passed entity gets attached to a rotation entity
// ----------------------------------------------------------------------------------------------------------------------------

AttachRotatorTo <- function(ent){
	local pos = ent.GetOrigin()
	local rotName = UniqueString("_mushroom_rot")
	local rotator = SpawnEntityFromTable("func_rotating", { targetname = rotName, origin = pos, spawnflags = 67})
	NetProps.SetPropVector(rotator, "m_Collision.m_vecMins", Vector(1,1,1))
	NetProps.SetPropVector(rotator, "m_Collision.m_vecMaxs", Vector(-1,-1,-1))
	DoEntFire("!self", "SetParent", "!activator", 0.00, rotator, ent);

}



