//****************************************************************************************
//																						//
//									rd_hud_controller.nut								//
//																						//
//****************************************************************************************




// Flag and position tables
// ----------------------------------------------------------------------------------------------------------------------------

::HUDFlags <- {
	PRESTR = 1
	POSTSTR = 2
	BEEP = 4
	BLINK = 8
	AS_TIME = 16
	COUNTDOWN_WARN = 32
	NOBG = 64
	ALLOWNEGTIMER = 128
	ALIGN_LEFT = 256
	ALIGN_CENTER = 512
	ALIGN_RIGHT = 768
	TEAM_SURVIVORS = 1024
	TEAM_INFECTED = 2048
	TEAM_MASK = 3072
	NOTVISIBLE = 16384
}

::HUDPositions <- {
	LEFT_TOP = 0
	LEFT_BOT = 1
	MID_TOP = 2
	MID_BOT = 3
	RIGHT_TOP = 4
	RIGHT_BOT = 5
	TICKER = 6
	FAR_LEFT = 7
	FAR_RIGHT = 8
	MID_BOX = 9
	SCORE_TITLE = 10
	SCORE_1 = 11
	SCORE_2 = 12
	SCORE_3 = 13
	SCORE_4 = 14
}




// Main hud definition
// ----------------------------------------------------------------------------------------------------------------------------

RD_HUD <-
{
	Fields = 
	{
		timer = { slot = HUDPositions.MID_BOX, flags = HUDFlags.ALIGN_CENTER | HUDFlags.NOBG, name = "timer", datafunc = @()GetPlayerTimes() }
	}
}




// Returns one string for all survivors
// ----------------------------------------------------------------------------------------------------------------------------

::GetPlayerTimes <- function(){
	local str = ""
	
	foreach(ent in GetHumanSurvivors()){
		str += (GetCharacterDisplayName(ent) + ": ")
		if(ent in PlayerTimeData){
			if(!ent.IsDead() && !ent.IsDying()){
				if(PlayerTimeData[ent].timerActive){
					if(!PlayerTimeData[ent].finished){
						str += g_MapScript.TimeToDisplayString(Time() - PlayerTimeData[ent].startTime)
					}else{
						str += "Finished(" + g_MapScript.TimeToDisplayString(PlayerTimeData[ent].endTime - PlayerTimeData[ent].startTime) + ")"
					}
				}else{
					str += "0:00" 
				}
			}else{
				str += "(Dead)"
			}
		}
		str += "  "
	}
	return str
}




// Voting to disable the timer hud
// ----------------------------------------------------------------------------------------------------------------------------

function ChangeHudState(ent){
	local scope = GetValidatedScriptScope(ent)
	scope["speedrun_timer"] <- true
	
	foreach(player in GetHumanSurvivors()){
		local playerscope = GetValidatedScriptScope(player)
		if(!("speedrun_timer" in playerscope)){
			ClientPrint(null, 5, GREEN + ent.GetPlayerName() + WHITE + " voted to " + ( IsTimerHudActive() ? "disable" : "enable" ) + " the timer hud")
			return
		}
	}
	
	if(IsTimerHudActive()){
		DisableTimerHud()
	}else{
		EnableTimerHud()
	}
	
	foreach(player in GetHumanSurvivors()){
		local scope = GetValidatedScriptScope(player)
		if("speedrun_timer" in scope){
			player.GetScriptScope().rawdelete("speedrun_timer")
		}
	}
	
	ClientPrint(null, 5, WHITE + "Hud has been " + GREEN + ( IsTimerHudActive() ? "enabled" : "disabled") )
}




// Enable / disable the hud
// ----------------------------------------------------------------------------------------------------------------------------

function EnableTimerHud(){
	RD_HUD.Fields.timer.flags <- RD_HUD.Fields.timer.flags & ~HUDFlags.NOTVISIBLE
	HUDPlace(HUDPositions.MID_BOX, 0.0, 0.0, 1.0, 0.05)
}




function EnableTickerHud(){
	Ticker_AddToHud(RD_HUD, "!info in chat to print mutation details to your console", true)
	HUDPlace(HUDPositions.TICKER, 0.0, 0.0, 0.99, 0.25)
	Ticker_SetTimeout(16)
	Ticker_SetBlinkTime(16)
	RD_HUD.Fields.ticker.flags <- HUDFlags.ALIGN_CENTER | HUDFlags.NOBG | HUDFlags.BLINK
}




function DisableTimerHud(){
	RD_HUD.Fields.timer.flags <- RD_HUD.Fields.timer.flags | HUDFlags.NOTVISIBLE
}




// Checks if the timer hud is currently visible
// ----------------------------------------------------------------------------------------------------------------------------

function IsTimerHudActive(){
	return !(RD_HUD.Fields.timer.flags & HUDFlags.NOTVISIBLE)
}


EnableTimerHud()

EnableTickerHud()

HUDSetLayout(RD_HUD)




