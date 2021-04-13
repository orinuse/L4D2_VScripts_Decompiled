//resource manager
// this script table can be accessed at root scope with g_ResourceManager

DBG <- 0

currentResources <- 0

function debugPrint( string )
{
	if( DBG )
	{
		printl( "** " + string )
	}
}

// ----------------------------------------------------------------------------
function Purchase( cost )
{
	debugPrint("PURCHASE RUNNING!....")
	
	if( CanAfford( cost ) )
	{
		debugPrint("Buying, Price is: " + cost + " currentResources: " + currentResources)
		RemoveResources( cost )		
		debugPrint("new avail resources: " + currentResources ) 
		return true
	}

	debugPrint("***Not Enough resources!****")
	debugPrint("Current currentResources: " + currentResources ) 
	return false

}

// ----------------------------------------------------------------------------
function CanAfford( cost )
{
	debugPrint("Price is: " + cost)
	
	if( cost <= currentResources)
	{
		
		debugPrint("Price is: " + cost + " currentResources: " + currentResources + " You can afford this!")
		return true
	}
	if( cost > currentResources)
	{
		debugPrint("NOPE, can't buy. Current currentResources: " + currentResources ) 
		return false
	}
}

// ----------------------------------------------------------------------------
function AddResources( val )
{
	debugPrint("adding resources")
	currentResources += val
	debugPrint("added " + val + " new total is: " + currentResources)
	
	UpdateHud()
}

// ----------------------------------------------------------------------------
function RemoveResources( val ) 
{
	debugPrint("removing resources")
	currentResources -= val
	if( currentResources < 0 )
	{
		debugPrint("Warning: Resource count is less than zero - this shouldn't happen. Clamping to 0.")
		currentResources = 0
	}
	
	debugPrint("subtracted " + val + " new total is: " + currentResources)
	
	UpdateHud()
}

// ----------------------------------------------------------------------------
// updates the root table value that the HUD UI examines every frame
// ----------------------------------------------------------------------------
function UpdateHud()
{
	// TEMP: changed this to a newkey instead of assignment... The director options set by finale scripts
	// will slam HoldoutResources to 0 when the button is pressed, but this resource manager file is athoratative anyway
	// Still need to decide what to do about storing the holdout specific script vars that are smuggled to C... May need HoldoutGameOptions table?
	g_MapScript.LocalScript.DirectorOptions.HoldoutResources <- currentResources

	local params = { newcount=currentResources };
	FireScriptEvent( "on_resources_changed", params );
}

//UpdateHud()
