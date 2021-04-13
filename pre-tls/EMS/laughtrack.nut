//=========================================================
// Called when a boomer explodes.  Params will contain:
//		"userid"		"short"   	// Boomer that exploded
//		"attacker"		"short"		// player who caused the explosion
//		"splashedbile"	"bool"		// Exploding boomer splashed bile on Survivors
//=========================================================
function OnGameEvent_boomer_exploded( params )
{
	// so funny!
	Laugh()
}

//=========================================================
//=========================================================
function Laugh()
{
	local playerEnt = null
	while ( playerEnt = Entities.FindByClassname( playerEnt, "player" ) )
	{
		if (playerEnt.IsSurvivor() )
		{
			// fire entity IO at "!activator" and pass the player ent as the activator
			EntFire( "!activator", "SpeakResponseConcept", "PlayerLaugh", 0, playerEnt )
		}
	}
}