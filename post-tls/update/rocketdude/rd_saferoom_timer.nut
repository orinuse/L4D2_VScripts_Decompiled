//****************************************************************************************
//																						//
//									rd_saferoom_timer.nut								//
//																						//
//****************************************************************************************



::countDownActive		<- false
::countDownStamp		<- Time()
::countdownTime			<- 3

if(!IsSoundPrecached("ui/beep07.wav")){
	PrecacheSound("ui/beep07.wav")
}

if(!IsSoundPrecached("ui/beep22.wav")){
	PrecacheSound("ui/beep22.wav")
}




// Executed by the chatcommand !countdown it will check of everybody wants to make a countdown
// ----------------------------------------------------------------------------------------------------------------------------

::saferoomTimerUseStamp <- Time()

::startSafeRoomTimer <- function(ent){
	
	if(!AllInStartSafeRoom()){
		return
	}
	
	if(!(mapName in survivorSpawnPoints)){
		ClientPrint(null, 5, "This function is only available for maps of c1-c14.")
		return
	}
	
	if(NetProps.GetPropInt(Entities.FindByClassname(null, "terror_gamerules"), "m_bInIntro")){
		return
	}
	
	if(!(Time() > saferoomTimerUseStamp + 5)){
		ClientPrint(null, 5, "This function can only be used every 5 seconds.")
		return
	}

	local playerscope = GetValidatedScriptScope(ent)
	if(!("countdown_vote" in playerscope)){
		playerscope["countdown_vote"] <- true
		foreach(player in GetHumanSurvivors()){
			local playerscope = GetValidatedScriptScope(player)
			if(!("countdown_vote" in playerscope)){
				ClientPrint(null, 5, GREEN + ent.GetPlayerName() + WHITE + " voted to start a countdown.")
				return
			}
		}
	}
	
	if(!countDownActive){
		countDownActive = true
		countDownStamp = Time()
		FreezePlayers()
		SetPlayersStartPositions()
		saferoomTimerUseStamp = Time()
		foreach(player in GetHumanSurvivors()){
			player.ValidateScriptScope()
			player.GetScriptScope().rawdelete("countdown_vote")
		}
	}
}




// Gets called from Think() function
// ----------------------------------------------------------------------------------------------------------------------------

::safeRoomTimer <- function(){
	if(countDownActive){
		if(Time() > countDownStamp + 1){
			if(countdownTime > 0){
				printTimeToChat()
				countdownTime--
				countDownStamp = Time()
			}else{
				printGoToChat()
				countDownActive = false
				countdownTime = 3
			}
		}
	}
}




// Prints timer to chat and outputs sound to all players
// ----------------------------------------------------------------------------------------------------------------------------

::printTimeToChat <- function(){
	
	local players = GetHumanSurvivors()
	
	ClientPrint(null, 5,  GREEN + countdownTime)
	foreach(player in players){
		EmitAmbientSoundOn("ui/beep07.wav", 0.75, 100, 100, player)	
	}
}

::printGoToChat <- function(){

	local players = GetHumanSurvivors()

	ClientPrint(null, 5,  ORANGE + "GO!")
	UnfreezePlayers()
	foreach(player in players){
		EmitAmbientSoundOn("ui/beep22.wav", 0.75, 100, 100, player)
	}
}




// Check if all survivors are in the beginning saferoom ( Re-entering possible )
// ----------------------------------------------------------------------------------------------------------------------------

::AllInStartSafeRoom <- function(){
	foreach(player in GetHumanSurvivors()){
		if(ResponseCriteria.GetValue(player, "instartarea" ) == "0"){
			return false
		}
	}
	return true
}


::FreezePlayers <- function(){
	foreach(player in GetHumanSurvivors()){
		NetProps.SetPropInt(player, "movetype", 0)
	}
}

::UnfreezePlayers <- function(){
	foreach(player in GetHumanSurvivors()){
		NetProps.SetPropInt(player, "movetype", 2)
	}	
}




// Sets the origin of all present players to one of in the saferoom positioned info_survivor_position entities.
// This method is only ment to be used when all survivors are in the saferoom!
// ----------------------------------------------------------------------------------------------------------------------------

::SetPlayersStartPositions <- function(){

	local offsets = [ Vector(16,16,0), Vector(16,-16,0), Vector(-16,-16,0), Vector(-16,16,0) ]
	
	local counter = 0
	
	foreach(player in GetHumanSurvivors()){
		if(counter == 4){
			counter = 0
		}
		player.SetOrigin(survivorSpawnPoints[ mapName ] + offsets[counter])
		counter++
	}
}




// These are player origins for all beginning saferooms ( c1-c14 ). We spawn every player with an offset
// ----------------------------------------------------------------------------------------------------------------------------

::survivorSpawnPoints <-
{
	c1m1_hotel				= Vector(599.989,5630.53,2851.46)
	c1m2_streets			= Vector(2360.92,5124.73,452.031)
	c1m3_mall				= Vector(6628.92,-1433.91,28.0313)
	c1m4_atrium				= Vector(-2090.7,-4624.16,540.031)

	c2m1_highway			= Vector(10895.7,7873.87,-548.574)
	c2m2_fairgrounds		= Vector(1636.83,2719.81,8.03125)
	c2m3_coaster			= Vector(4343.23,2048.8,-59.9688)
 	c2m4_barns				= Vector(3116.18,3330.29,-183.969)
	c2m5_concert			= Vector(-825.861,2292.01,-251.969)

	c3m1_plankcountry		= Vector(-12546.3,10456.1,248.893)
	c3m2_swamp 				= Vector(-8160.61,7615.23,16.0313)
	c3m3_shantytown			= Vector(-5709.34,2143.82,140.031)
	c3m4_plantation			= Vector(-5011.12,-1672.01,-92.8118)
	
	c4m1_milltown_a			= Vector(-7073.8,7719.17,117.924)
	c4m2_sugarmill_a		= Vector(3628.58,-1679.04,236.531)
	c4m3_sugarmill_b		= Vector(-1803.96,-13698.4,134.031)
	c4m4_milltown_b			= Vector(3910.57,-1569.59,236.281)
	c4m5_milltown_escape 	= Vector(-3367.6,7853.06,124.031)
	
	c5m1_waterfront			= Vector(798.114,676.213,-477.969)
	c5m2_park				= Vector(-3966.59,-1261.61,-339.969)
	c5m3_cemetery			= Vector(6402.67,8410.15,4.03125)
	c5m4_quarter			= Vector(-3291.22,4889.5,72.0313)
	c5m5_bridge				= Vector(-12039.5,5833.28,132.031)

	c6m1_riverbank			= Vector(911.249,3774.63,98.0062)
	c6m2_bedlam				= Vector(3157.03,-1218.18,-291.969)
	c6m3_port				= Vector(-2410.05,-456.402,-251.969)
	
	c7m1_docks				= Vector(13838.7,2583.8,36.2599)
	c7m2_barge				= Vector(10726.2,2445.25,180.031)
	c7m3_port				= Vector(1123.67,3230.13,174.531)
	
	c8m1_apartment			= Vector(2004.74,913.544,436.031)
	c8m2_subway				= Vector(2907.06,3063.35,20.0313)
	c8m3_sewers				= Vector(10948.2,4729.64,20.0313)
	c8m4_interior			= Vector(12376.7,12567.9,20.0313)
	c8m5_rooftop			= Vector(5405.11,8388.72,5540.03)

	c9m1_alleys				= Vector(-9951.59,-8578.78,-2.66612)
	c9m2_lots				= Vector(278.24,-1301.6,-171.969)
	
	c10m1_caves				= Vector(-11745.4,-14862.1,-214.225)
	c10m2_drainage 			= Vector(-11014.6,-9103.6,-587.969)
	c10m3_ranchhouse		= Vector(-8263.9,-5550.87,-20.9688)
	c10m4_mainstreet		= Vector(-3082.28,-23.326,164.031)
	c10m5_houseboat			= Vector(2120.59,4742.14,-59.9688)
	
	c11m1_greenhouse		= Vector(6815.1,-672.996,772.031)
	c11m2_offices			= Vector(5278.98,2785.43,52.0313)
	c11m3_garage			= Vector(-5368.26,-3069.3,20.0313)
	c11m4_terminal			= Vector(-447.003,3577.39,300.031)
	c11m5_runway			= Vector(-6716.97,12066.8,156.031)
	
	c12m1_hilltop			= Vector(-8073.41,-15118.7,283.495)
	c12m2_traintunnel		= Vector(-6611.49,-6712.19,352.031)
	c12m3_bridge			= Vector(-927.759,-10382.7,-59.9688)
	c12m4_barn				= Vector(7754.14,-11374,444.031)
	c12m5_cornfield			= Vector(10480.9,-566.041,-24.9688)
	
	c13m1_alpinecreek		= Vector(-3012.43,-589.132,68.0313)
	c13m2_southpinestream	= Vector(8566.48,7505.06,500.031)
	c13m3_memorialbridge	= Vector(-4372.79,-5150.93,100.031)
	c13m4_cutthroatcreek	= Vector(-3387.78,-9284.08,364.031)
	
	c14m1_junkyard			= Vector(-4189.09,-10697.9,-296.294)
	c14m2_lighthouse		= Vector(2220.41,-1103.17,452.031)
}




// Prevent players from using restartFromSaferoom on a finale
// ----------------------------------------------------------------------------------------------------------------------------

::valveFinaleMaps <-
[
	"c1m4_atrium"
	"c2m5_concert"
	"c3m4_plantation"
	"c4m5_milltown_escape"
	"c5m5_bridge"
	"c6m3_port"
	"c7m3_port"
	"c8m5_rooftop"
	"c9m2_lots"
	"c10m5_houseboat"
	"c11m5_runway"
	"c12m5_cornfield"
	"c13m4_cutthroatcreek"
	"c14m2_lighthouse"
]




//insafespot
//incheckpoint
