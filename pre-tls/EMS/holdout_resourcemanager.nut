//resource manager

currentRes <- 8//starting resource count
newRes <- 0 	// new resource count 
incRes <- 0   //increment Resources
cost <- 0			
maxRes <- 10	//resource cap

function resMan(incRes)
{
	newRes = currentRes + incRes
	currentRes = newRes
	
	printl("New Total: " + currentRes + " from current: " + currentRes + " and incoming: " + incRes )

	//adding resource cap
	if( currentRes >= maxRes )
	{
		currentRes = maxRes
	}

	buttonStatus() //refresh button state
	
	// ummmm, yea, well, ye
	// TEMP: changed this to a newkey instead of assignment... The director options set by finale scripts
	// will slam HoldoutResources to 0 when the button is pressed, but this resource manager file is athoratative anyway
	// Still need to decide what to do about storing the holdout specific script vars that are smuggled to C... May need HoldoutGameOptions table?
	g_MapScript.LocalScript.DirectorOptions.HoldoutResources <- currentRes
	return currentRes
}

//this gets called when a button is first pressed. it should verify that there are enough resources for the current
//purchase.
function checkPurchase(cost)
{
	local absCost = abs(cost)
	if( absCost > currentRes )
	{
		//printl( "Not Enoug Money for Purchase" )
		buttonStatus() //refresh button state
		
	}	
	else
	{
		//printl( "Ok to buy!!" )
		buttonStatus() //refresh button state	
	}

}

function buttonStatus()
{
 	
 	if( currentRes < 3 ) 
 	{
 		if( currentRes < 2 )
 		{
 			if( currentRes < 1 )
 			{
 				EntFire( "case_disable_buttons", "InValue", 1)
 				EntFire( "case_disable_buttons", "InValue", 2)
 				EntFire( "case_disable_buttons", "InValue", 3)
 				//printl ( "disable all" )
 				
 			}
 			else
 			{
	 			EntFire( "case_enable_buttons", "InValue", 1 )
	 			EntFire( "case_disable_buttons", "InValue", 2)
	 			EntFire( "case_disable_buttons", "InValue", 3)
	 			//printl( "disable 2 and 3, enable 1" )
	 		}
	 	}
	 	
	 	else
	 	{	 	
	 		EntFire( "case_disable_buttons", "InValue", 3)
 			EntFire( "case_enable_buttons", "InValue", 2 )
 			EntFire( "case_enable_buttons", "InValue", 1 ) 
 			//printl ( "disable 3, enable 2, enable 1" )	
 		}
 				
 	}
 	else
 	{
 		EntFire( "case_enable_buttons", "InValue", 3)
 		EntFire( "case_enable_buttons", "InValue", 2 )
 		EntFire( "case_enable_buttons", "InValue", 1 )		
 		//printl( "all enabled!" ) 		
 	}	
}
