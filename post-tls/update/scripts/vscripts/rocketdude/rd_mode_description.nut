//****************************************************************************************
//																						//
//								rd_mode_description.nut									//
//																						//
//****************************************************************************************




// Output the most important facts about this mode to the players console
// ----------------------------------------------------------------------------------------------------------------------------

::printMutationInfo <- function(ent){
	
	local line = "_______________________________________________________________________________________________"
	local txt = [
	
		"-------------------------------- RocketDude by ReneTM --------------------------------"
		" "
		"In this mutation, there are no bot survivors and the human Survivors start with 200 health."
		"They are equipped with a Grenade Launcher with infinite ammo and clip size, and either a sharp melee weapon or a Magnum."
		"The Grenade Launcher's grenades do full damage to infected but only 1 to the survivors."
		"They travel in a straight line like in TF2. There are only pills and adrenaline shots to pickup."
		"All medkits and defibs are gone. There are different kinds of mushrooms spread over the map."
		"They can be picked up by walking over them. Some may be hard to reach."
		" "
		line
		" "
		" "
		" "
		" "
		"Green       : Server sided autobhop"
		"Dark Blue   : Random throwable if the players inventory allows it"
		"Black       : Explosive! I would not touch them"
		" "
		"Yellow      : +75 HP"
		"Pink        : +50 HP"
		"Blue        : +25 HP"
		"White       : +10 HP"
		" "
		"! Touching those health mushrooms also removes any tempoary health and \"black and white\" state !"
		line
		" "
		" "
		"Specialties:"
		" "
		"When all survivors are on the ground and the round would restart \"the last chance\" mode gets activated."
		"This mode being active, the survivors will have the chance, to get revived by killing any special or boss infected."
		"This mode can only be active once. Survivors will be black and white after this mode."
		"Destroying \"Skeeting\" tank-rocks mid-air will give you +5hp."
		"When you are incapped, but other survivors are still up, you can get revived by killing any special or boss infected."
		"Survivors are able to crawl while being incapped. Keep your eyes open for mushrooms."
		" "
		line
		" "
		" "
		"Chatcommands:"
		" "
		"!hud           -> Vote to enable/disable the timer hud"
		"!countdown     -> Vote to start a countdown while being in saferoom"
		" "
		"Local usage only:"
		"----------------"
		"!speedrunmode  -> Vote to toggle between speedrunmode which disables all infected and normal mode"
		"!saveangles    -> Annoyed by survivors looking the wrong direction? Save your eye angles :)"
		"!stats         -> Print players besttimes to console"
		"!r             -> Vote to jump back to the saferoom to retry"
	]
	
	foreach(line in txt){
		ClientPrint(ent, 5, GREEN + line)
	}
	for(local i = 0; i < 10; i++){
		ClientPrint(ent, 5, " ")
	}
	ClientPrint(ent, 5, GREEN + "Check the console for information!")
}

