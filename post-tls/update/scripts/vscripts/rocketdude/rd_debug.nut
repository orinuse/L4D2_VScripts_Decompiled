//****************************************************************************************
//																						//
//										rd_debug.nut									//
//																						//
//****************************************************************************************

// Check if dev mode is active
// ----------------------------------------------------------------------------------------------------------------------------

::DevModeActive <- function(){
	return Convars.GetFloat("developer")
}




// Switch from mushroom to mushroom
// ----------------------------------------------------------------------------------------------------------------------------

::debugMushroom <- null;

::GoToNextMushroom <- function(ent){
	if(!DevModeActive()){
		return
	}
	
	if(debugMushroom = Entities.FindByModel(debugMushroom, "models/props_collectables/mushrooms_glowing.mdl")){
		NetProps.SetPropInt(ent, "m_MoveType", 8)
		ent.SetOrigin(debugMushroom.GetOrigin() + Vector(0,0,64))
	}else{
		NetProps.SetPropInt(ent, "m_MoveType", 2)
	}
}