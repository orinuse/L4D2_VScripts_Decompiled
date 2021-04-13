//****************************************************************************************
//																						//
//										rd_events.nut									//
//																						//
//****************************************************************************************




::devs <- {}
	
devs["STEAM_1:0:26359107"] <- { name = "ReneTM", role = "creator" }
devs["STEAM_1:0:16327272"] <- { name = "Derdoron", role = "Beta Tester" }




// Chat commands
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_player_say(params){

	local text,ent = null
	
	if("userid" in params && params.userid == 0){
		return
	}
	
	text = strip(params["text"].tolower())
	ent = GetPlayerFromUserID(params["userid"])

	if(text.len() < 1){
		return
	}
	
	local steamID = ent.GetNetworkIDString()
	local scope = GetValidatedScriptScope(ent)

	switch(text){

		case "!version" :
		if(steamID in devs){
			ClientPrint(null, 5, BLUE + "RocketDude " + rocketdude_version)
		}
		break
		
		case "!countdown" :
		startSafeRoomTimer(ent)
		break
		
		case "!r" :
		restartFromSaferoom(ent)
		break
		
		case "!saveangles" :
		savePlayerEyeAngles(ent)
		break
		
		case "!speedrunmode" :
		speedrunModeToggle(ent)
		break
		
		case "!hud" :
		ChangeHudState(ent)
		break
		
		case "!stats" :
		outputStats(ent)
		break
		
		case "!info" :
		printMutationInfo(ent)
		break
		
		case "!g2mushroom" :
		GoToNextMushroom(ent)
		break
	}
}




function OnGameEvent_player_first_spawn(params){
	
	local orangestar = ORANGE + "★"

	if(params["isbot"] == 0){
		local player = GetPlayerFromUserID(params.userid)
		local steamID = player.GetNetworkIDString()

		if(steamID in devs){
			local invTable = {}
			GetInvTable(player, invTable)
			if("slot1" in invTable && invTable.slot1.GetClassname() == "weapon_melee"){
				if(NetProps.GetPropString(invTable.slot1, "m_strMapSetScriptName") != "crowbar"){
					invTable.slot1.Kill()
					player.GiveItemWithSkin("crowbar", 1)
				}else{
					NetProps.SetPropInt(invTable.slot1, "m_nSkin", 1)
				}
			}
			ClientPrint(null, 5, orangestar + GREEN + " RocketDude " + devs[steamID].role + BLUE + " " + player.GetPlayerName() + WHITE + " joined the game.")
		}
	}
}




// "The right man in the wrong place can make all the difference in the world"
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_player_changename(params){
	local player = GetPlayerFromUserID(params["userid"])
	local invTable = {}
	GetInvTable(player, invTable)
	
	if("newname" in params && params["newname"] == "Dr. Gordon Freeman"){
		if("slot1" in invTable && invTable.slot1.GetClassname() == "weapon_melee"){
			if(NetProps.GetPropString(invTable.slot1, "m_strMapSetScriptName") == "crowbar"){
				NetProps.SetPropInt(invTable.slot1, "m_nSkin", 1)
			}
		}
	}
}




function OnGameEvent_player_spawn(params){

	local player = GetPlayerFromUserID(params["userid"])
	
	if(player.GetZombieType() == 9 && !IsPlayerABot(player)){
		placeRocketDudeDecals()
		teleportToSurvivor(player)
		
		DoEntFire("!self", "DisableLedgeHang", "", 0.0, player, player)
		DoEntFire("!self", "ignorefalldamagewithoutreset", "99999", 0.0, player, player)

		if(NetProps.GetPropInt(player, "m_iMaxHealth") != 200){
			NetProps.SetPropInt(player, "m_iMaxHealth", 200)
		}
	}
}




function teleportToSurvivor(player){
	local target = getClosestSurvivorTo(player)
	
	if(target == null){
		return
	}
	
	if((player.GetOrigin() - target.GetOrigin()).Length() < 256){
		return
	}
	
	if(target.IsValid()){
		if(!target.IsDead() && !target.IsDying()){
			if(Director.HasAnySurvivorLeftSafeArea()){
				player.SetOrigin(target.GetOrigin())
			}
		}
	}
}




function OnGameEvent_player_incapacitated(params){
	
	if("attackerentid" in params){
		if(EntIndexToHScript(params.attackerentid).GetClassname() == "trigger_hurt"){
			return
		}
	}

	if(!lastChanceUsed){
		lastChanceSwitch(params)
	}
}




// When a survivor stands full hp in a mushroom trigger volume the function is unlocked
// again and the survivor gets hurt a touchtest should be done
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_player_hurt(params){
	if(GetPlayerFromUserID(params.userid).GetZombieType() == 9){
		foreach(trigger in medkit_triggers){
			DoEntFire("!self", "TouchTest", "", 0, trigger, trigger)
		}
	}
}




// Disable glows when survivors enter "last chance mode" but fail
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_mission_lost(params){
	disableInfectedGlows()
}




// Called when any player dies. Purpose mostly for bullet time, reviving survivors from being incap and "last chance"
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_player_death(params){
	
	local victim = null
	local attacker = null
	local victimClass = null
	
	if("userid" in params){
		victim = GetPlayerFromUserID(params["userid"])
	} else if("entityid" in params){
		victim = EntIndexToHScript(params["entityid"])
	}
	if("attacker" in params){
		attacker = GetPlayerFromUserID(params["attacker"])
	} else if("attackerentid" in params){
		attacker = EntIndexToHScript(params["attackerentid"])
	}
	
	if(!lastChanceUsed){
		lastChanceSwitch(params)	
	}
	
	if(victim.IsPlayer() && victim.GetZombieType() == 9){
		ClientPrint(null, 5, BLUE + victim.GetPlayerName() + WHITE + " did not finish this map. The map finished them.")
	}
	

	if(victim.GetClassname() != "infected"){
		if(victim.GetClassname() == "witch" || victim.GetZombieType() != 9){	// Killed witch or any Special infected or tank
			if(attacker != null && attacker.IsPlayer()){						// Dont do anything when the map is the killer
				if(attacker.GetZombieType() == 9){
					if(attacker.IsIncapacitated()){
						if(!missionFailed){
							if(last_chance_active){
								stopLastChanceMode()
								attacker.ReviveFromIncap()
							}else{
								if(!allSurvivorsIncap()){
									attacker.ReviveFromIncap()
								}else{
									ClientPrint(null, 5, BLUE + "Time to say goodbye")
								}
							}
							EmitAmbientSoundOn("player/orch_hit_csharp_short", 1, 100, 100, attacker)
						}
					}
				}
			}
		}
	}else{
		if(attacker != null && attacker.GetClassname() == "player" && attacker.GetZombieType() == 9){
			bulletTime()
		}
	}
}




// Set tank's health in relation to the current difficulty
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_tank_spawn(params){
	local tank = EntIndexToHScript(params.tankid)
	local health = 0
	switch(Convars.GetStr("z_difficulty").tolower()){
		case "easy" :
			health = 8000;	break
		case "normal" :
			health = 16000;	break
		case "hard" :
			health = 32000;	break
		case "impossible" :
			health = 64000;	break
	}
	tank.SetMaxHealth(health)
	tank.SetHealth(health)
}




// Set witch health in relation to the current difficulty
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_witch_spawn(params){
	local witch = EntIndexToHScript(params.witchid)
	local health = 0
	
	switch(Convars.GetStr("z_difficulty").tolower()){
		case "easy" :
			health = 2048;	break
		case "normal" :
			health = 4096;	break
		case "hard" :
			health = 8192;	break
		case "impossible" :
			health = 16384; break
	}
	witch.SetMaxHealth(health)
	witch.SetHealth(health)
}




// Avoid multiple rocketlaunchers on the ground 
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_item_pickup(params){
	local player = GetPlayerFromUserID(params["userid"])
	local playerInv = {}
	if(player.GetZombieType() == 9 && !IsPlayerABot(player)){
		GetInvTable(player, playerInv)
		if("slot0" in playerInv){
			if(playerInv["slot0"].GetClassname() != "weapon_grenade_launcher"){
				playerInv["slot0"].Kill()
				player.GiveItem("weapon_grenade_launcher")
			}
		}
		
		// Gives devs a golden crowbar
		if(player.GetNetworkIDString() in devs){
			if("slot1" in playerInv){
				if(NetProps.GetPropString(playerInv.slot1, "m_strMapSetScriptName") == "crowbar"){
					NetProps.SetPropInt(playerInv.slot1, "m_nSkin", 1)
				}
			}
		}
	}
}




function OnGameEvent_weapon_drop(params){
	if("propid" in params){
		local droppedItem = EntIndexToHScript(params.propid)
		if(droppedItem.GetClassname() == "weapon_grenade_launcher"){
			droppedItem.Kill()
		}
	}
}

::entityChangesDone <- false

function OnGameEvent_player_left_checkpoint(params){
	if("userid" in params){
		local player = GetPlayerFromUserID(params["userid"])
		if(player.GetZombieType() == 9 && !IsPlayerABot(player) && !player.IsDead()){
			if(player in PlayerTimeData){
				if(!PlayerTimeData[player].finished){
					PlayerTimeData[player].timerActive = true
					PlayerTimeData[player].startTime = Time()
					PlayerTimeData[player].seconds = 0
					PlayerTimeData[player].ticks = 0
					EmitAmbientSoundOn("ui/beep07.wav", 0.5, 100, 107, player)
					ClientPrint(player, 5, BLUE + player.GetPlayerName() + " | 00:00")
				}
			}
		
			if(!IsPlayerABot(player)){
				if(!entityChangesDone){
					DoEntFire("worldspawn", "RunScriptCode", "killFixEntities()", 2, player, player)
					DoEntFire("worldspawn", "RunScriptCode", "mapSpecifics()", 4, player, player)
					entityChangesDone = true
				}
			}

			DoEntFire("!self", "DisableLedgeHang", "", 0.0, player, player)
			DoEntFire("!self", "ignorefalldamagewithoutreset", "99999", 0.0, player, player)

			if(NetProps.GetPropInt(player, "m_iMaxHealth") != 200){
				NetProps.SetPropInt(player, "m_iMaxHealth", 200)
			}
		}
	}
}




// Like in Portal 1 we want to challange the player to do as less steps as possible or atleast to spend as less time on the 
// ground as possible. Event "player_footstep" is non-functional atm...Valve please fix
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_finale_vehicle_leaving(param){
	finalGroundTimeOutput()
}




function OnGameEvent_finale_win(param){
	finalGroundTimeOutput()
}




function finalGroundTimeOutput(){
	foreach(player,datatable in PlayerTimeData){
		if(player.IsValid()){
			if(!player.IsDead() && !player.IsDying() && !player.IsIncapacitated()){
				if(!PlayerTimeData[player].finished){
					printFinalGroundTime(player)
					ProcessSurvivorTime(player)
				}
			}
		}
	}
}




function ProcessSurvivorTime(ent){
	
	local tTable = PlayerTimeData[ent]
	tTable.endTime = Time()
	
	if(tTable.time_best == 0){
		tTable.time_best = tTable.endTime - tTable.startTime
	}else{
		if((tTable.endTime - tTable.startTime) < tTable.time_best){
			tTable.time_best = (tTable.endTime - tTable.startTime)
		}
	}
	tTable.finished = true
}




::printFinalGroundTime <- function(ent){
	if(!ent.IsDead() && !ent.IsDying() && !ent.IsIncapacitated()){
		local sec = PlayerTimeData[ent].seconds
		local fracs = PlayerTimeData[ent].ticks.tofloat()
		if(fracs > 0){
			fracs = (fracs / 30)
		}
		local groundTime = sec + fracs
		local time_curr = limitDecimalPlaces( Time() - (PlayerTimeData[ent].startTime).tofloat() )
		local midAirPercent = getMidAirPercentage(groundTime, time_curr)
		
		ClientPrint(null, 5, BLUE + ent.GetPlayerName() + WHITE + " finished this map in " + BLUE + time_curr + WHITE + " seconds and spent " + BLUE + midAirPercent + WHITE + " % midair")
		EmitAmbientSoundOn("ui/menu_invalid.wav", 0.75, 100, 110, ent)
		
		local diff = GetSpeedrunStats(ent, time_curr)

		// Speedrun tracker
		
		if( diff != null ){
			if( diff < 0){
				ClientPrint(null, 5, WHITE + "Thats a new personal record for " + mapName + GREEN + " ( "  + diff.tostring() + " seconds )")
				return
			}else if(diff > 0){
				ClientPrint(null, 5, ORANGE + "( +" + ( diff.tostring()) + " seconds )" )
				return
			}
		}
	}
}




::getMidAirPercentage <- function(groundTime, time_curr){
	local airTime = time_curr - groundTime
	local airPercentage = (( airTime / time_curr ) * 100).tofloat()
	return limitDecimalPlaces(airPercentage)
}




::limitDecimalPlaces <- function(var){
	return (var * 100).tointeger() / 100.0
}




// Check if the text from the file is a "number"
// ----------------------------------------------------------------------------------------------------------------------------

::isNumeric <- function(value){
	local newValue
	local dots = 0
	local numbers = ["0","1","2","3","4","5","6","7","8","9","."]
	for(local i=0; i < value.len(); i++){
		local checkChar = value.slice(i, i+1)
		if(checkChar == "."){
			dots++
		}
		if(dots > 1){
			return false
		}
		if(numbers.find(checkChar) == null){
			return false
		}
	}
	return true
}




// Record output for the local player
// ----------------------------------------------------------------------------------------------------------------------------

::GetSpeedrunStats <- function(player, newTime){
	
	// Restrict saving for the local player
	if(!(player == GetListenServerHost())){
		return null
	}
	
	local filePath = "rocketdude/speedrun/"
	local fileName = mapName + ".txt"
	
	local savedTime = FileToString(filePath + fileName)
	
	// Save a file when there is none
	if(savedTime == null || savedTime.len() == 0 || !isNumeric(savedTime)){
		StringToFile(filePath + fileName, newTime.tostring() )
		return null
	}
	
	try{
		savedTime = savedTime.tofloat()
	}catch(exception){
		return null
	}
	
	if(newTime < savedTime){
		StringToFile(filePath + fileName, newTime.tostring() )
	}
	
	return (newTime - savedTime)
}




// Typing sv_cheats 1 on local server would result in every cheat flagged variable reset
// ----------------------------------------------------------------------------------------------------------------------------

function OnGameEvent_server_cvar(param){
	if("cvarname" in param){
		local cvar = param.cvarname
		if(cvar == "sv_cheats"){
			checkCvars()
		}
	}
}




__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

