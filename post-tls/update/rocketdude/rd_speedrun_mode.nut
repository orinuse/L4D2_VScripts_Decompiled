//****************************************************************************************
//																						//
//										rd_speedrun_mode.nut							//
//																						//
//****************************************************************************************




// Playing locally allows the player to enable the speedrun mode.
// !speedrunmode to toggle it. !r to respawn in the saferoom
// ----------------------------------------------------------------------------------------------------------------------------

::speedrunModeEnabled <- false

::speedrunModeToggle <- function(ent){
	
	if(!OnLocalServer()){
		return
	}
	
	ent.ValidateScriptScope()
	local scope = ent.GetScriptScope()
	scope["speedrun_mode"] <- true
	
	foreach(player in GetHumanSurvivors()){
		local playerscope = player.GetScriptScope()
		if(!("speedrun_mode" in playerscope)){
			ClientPrint(null, 5, GREEN + ent.GetPlayerName() + WHITE + " voted to " + ( speedrunModeEnabled ? "disable" : "enable" ) + " the speedrun mode!")
			return
		}
	}
	
	speedrunModeEnabled = !speedrunModeEnabled
	
	local speedrunDirector =
	{
		ProhibitBosses	= [true, false]
		MobMaxSize		= [0, 30]
		CommonLimit		= [0, 30]
		MobSpawnMinTime	= [9999, 90]
		MobSpawnMaxTime	= [9999, 180]
		MaxSpecials		= [0, 6]
		SpecialRespawnInterval = [9999, 45]
	}
	
	foreach(var,valarr in speedrunDirector){
		if(speedrunModeEnabled){
			SessionOptions[var.tostring()] <- valarr[0]
			removeAllInfected()
		}else{
			SessionOptions[var.tostring()] <- valarr[1]
		}
	}
	
	foreach(player in GetHumanSurvivors()){
		player.GetScriptScope().rawdelete("speedrun_mode")
	}
	
	ClientPrint(null, 5, WHITE + "Speedrun mode " + GREEN + ( speedrunModeEnabled ? "enabled" : "disabled") )
}




// While being in speedrun mode the survivor can jump back to the saferoom to restart his run
// ----------------------------------------------------------------------------------------------------------------------------

::restartFromSaferoom <- function(ent){
	
	if(!speedrunModeEnabled){
		ClientPrint(null, 5, WHITE + "Jumping back to the saferoom is restricted to " + GREEN + "speedrunmode!")
		return
	}
	
	if(!(Director.GetMapName() in survivorSpawnPoints)){
		return
	}
	
	if(valveFinaleMaps.find(Director.GetMapName()) != null){
		ClientPrint(null, 5, WHITE + "Jumping back to the saferoom is disabled for finales")
		return
	}
	
	local scope = GetValidatedScriptScope(ent)
	
	scope["go_back_2_safe"] <- true
	
	foreach(player in GetHumanSurvivors()){
		local playerscope = player.GetScriptScope()
		if(!("go_back_2_safe" in playerscope)){
			ClientPrint(null, 5, GREEN + ent.GetPlayerName() + WHITE + " voted to go back to the saferoom!")
			return
		}
	}
	
	foreach(player in GetHumanSurvivors()){
		local playerscope = GetValidatedScriptScope(player)
		playerscope.rawdelete("go_back_2_safe")
		local prevBest = PlayerTimeData[player].time_best
		PlayerTimeData[player] <- { timerActive = false, finished = false, startTime = Time(), endTime = Time(), time_best = prevBest, ticks = 0, seconds = 0 }
		bunnyPlayers.rawdelete(player)
		NetProps.SetPropInt(player, "m_afButtonDisabled", NetProps.GetPropInt(player, "m_afButtonDisabled") & ~2)
		GLOBALS.allowBulletTime = false
		
		// Set player eye angles when there are any saved
		if(player in SavedplayerEyeAngles){
			player.SnapEyeAngles(SavedplayerEyeAngles[player].EyeAngles)
		}
		player.SetVelocity(Vector(0,0,256))
	}
	
	SetPlayersStartPositions()
	setPlayersHealth()
}




// Prints all times of known maps to the console
// ----------------------------------------------------------------------------------------------------------------------------

::outputStats <- function(ent){
	
	if(ent != GetListenServerHost()){
		return
	}
	
	foreach(mapname in valveMaps){
		local str = null
		str = FileToString("rocketdude/speedrun/" + mapname + ".txt")
		if(str != null){
			str = strip(str)
			if(isNumeric(str)){
				ClientPrint(ent, 5, GREEN + mapname + GetCharChain(" ", 32 - mapname.len()) + ": " + str)
			}else{
				ClientPrint(ent, 5, ORANGE + mapname + GetCharChain(" ", 32 - mapname.len()) + ": INVALID DATA IN TEXT FILE")
			}
		}else{
			ClientPrint(ent, 5, BLUE + mapname + GetCharChain(" ", 32 - mapname.len()) + ": NO RECORD YET")
		}
	}
	for(local i = 0; i < 10; i++){
		ClientPrint(ent, 5, " ")
	}
	ClientPrint(ent, 5, GREEN + "Check the console for your stats!")
}




// Removes all infected like nb_delete_all does
// ----------------------------------------------------------------------------------------------------------------------------

::removeAllInfected <- function(){
	local player = null
	local witch = null
	local common = null
	
	while(player = Entities.FindByClassname(player, "player")){
		if(IsPlayerABot(player) && player.GetZombieType() != 9){
			player.Kill()
		}
	}
	
	while(witch = Entities.FindByClassname(witch, "witch")){
		if(witch.IsValid()){
			witch.Kill()
		}
	}
	
	while(common = Entities.FindByClassname(common, "infected")){
		if(common.IsValid()){
			common.Kill()
		}
	}
}




// Save player angles for speedrunning
// ----------------------------------------------------------------------------------------------------------------------------

::SavedplayerEyeAngles <- {}

function savePlayerEyeAngles(ent){
	
	if(!OnLocalServer()){
		ClientPrint(null, 5, WHITE + "Saving player angles is restricted to local servers!")
		return
	}
	
	if(!speedrunModeEnabled){
		ClientPrint(null, 5, WHITE + "Enable speedrunmode first ( " + GREEN + "!speedrunmode" + WHITE + " in chat )!")
		return
	}
	
	if(ResponseCriteria.GetValue(ent, "instartarea" ) == "0"){
		ClientPrint(null, 5, WHITE + "Move to the start area to save your eye angles!")
		return
	}
	
	if(ent.IsValid()){
		SavedplayerEyeAngles[ent] <- { EyeAngles = ent.EyeAngles() }
		ClientPrint(null, 5, WHITE + "Your eye angles got " + GREEN + "saved!")
	}
}

