//****************************************************************************************
//																						//
//								rd_custom_map_support.nut								//
//																						//
//****************************************************************************************




// Spawn mushrooms from map entities 
// ----------------------------------------------------------------------------------------------------------------------------

spawnMapSidedMushrooms <- function(){
	
	local mushroomTarget = null

	local types = [ "tiny", "small", "medium", "large", "bh", "exp", "item" ]
	
	foreach(type in types){
		while(mushroomTarget = Entities.FindByName(mushroomTarget, "rd_mushroom_" + type)){
			createRD_Medkit(mushroomTarget.GetOrigin(), mushroomTarget.GetAngles().ToKVString(), false, shroomProperties[type])
		}
	}
	
	foreach(type in types){
		while(mushroomTarget = Entities.FindByName(mushroomTarget, "rd_mushroom_" + type + "_rotating")){
			createRD_Medkit(mushroomTarget.GetOrigin(), mushroomTarget.GetAngles().ToKVString(), true, shroomProperties[type])
		}
	}
}




// Timers and stats
// ----------------------------------------------------------------------------------------------------------------------------

::resetPlayerStats <- function(){
	if(activator.IsValid()){
		if(activator in PlayerTimeData){
			if(activator.GetZombieType() == ZombieTypes.SURVIVOR){
				local prevBest = PlayerTimeData[activator].time_best
				PlayerTimeData[activator] <- { timerActive = false, finished = false, startTime = Time(), endTime = Time(), time_best = prevBest, ticks = 0, seconds = 0 }
				ClientPrint(activator, 5, BLUE + activator.GetPlayerName() + " | 00:00")
				EmitAmbientSoundOn("ui/littlereward.wav", 0.5, 100, 110, activator)
			}
		}
	}
}

::startTimer <- function(){
	if(activator.IsValid()){
		if(activator in PlayerTimeData){
			if(activator.GetZombieType() == ZombieTypes.SURVIVOR){
				resetPlayerStats()
				PlayerTimeData[activator].timerActive = true
			}
		}
	}
}

::mapFinished <- function(){
	
	if(PlayerTimeData[activator].finished == true){
		return
	}
	
	printFinalGroundTime(activator)
	PlayerTimeData[activator].finished = true
	resetPlayerStats()
	
	local playerSpawn = Entities.FindByName(null, "rd_player_start")
	if(playerSpawn != null){
		activator.SetOrigin(playerSpawn.GetOrigin())
	}else{
		ClientPrint(null, 5, "ERROR: ENTITY 'rd_player_start' NOT FOUND")
	}
}

