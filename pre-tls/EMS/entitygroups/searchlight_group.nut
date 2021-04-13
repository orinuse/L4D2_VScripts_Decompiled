//-------------------------------------------------------
// Autogenerated from 'searchlight.vmf'
//-------------------------------------------------------
Searchlight <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.unnamed,
			EntityGroup.SpawnTables.generator_1_spotlight_4,
			EntityGroup.SpawnTables.generator_1_spotlight_2_body,
			EntityGroup.SpawnTables.generator_1_spotlight_1_body,
			EntityGroup.SpawnTables.generator_1_spotlight_4_body,
			EntityGroup.SpawnTables.generator_1_spotlight_3_body,
			EntityGroup.SpawnTables.generator_1_spotlight_2,
			EntityGroup.SpawnTables.generator_1_spotlight_1,
			EntityGroup.SpawnTables.generator_1_spotlight_3,
			EntityGroup.SpawnTables.unnamed1,
			EntityGroup.SpawnTables.unnamed2,
			EntityGroup.SpawnTables.unnamed3,
			EntityGroup.SpawnTables.unnamed4,
			EntityGroup.SpawnTables.gas_nozzle,
			EntityGroup.SpawnTables.generator_1_brake_light_sprite,
			EntityGroup.SpawnTables.generator_1_brake_light_sprite1,
			EntityGroup.SpawnTables.unnamed5,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.generator_1_spotlight_4_body,
			EntityGroup.SpawnTables.generator_1_spotlight_rotator,
			EntityGroup.SpawnTables.pour_target,
			EntityGroup.SpawnTables.event_scavenge_pour,
			EntityGroup.SpawnTables.generator_1_spotlight_3,
			EntityGroup.SpawnTables.generator_1_idle_sound,
			EntityGroup.SpawnTables.generator_1_spotlight_4,
			EntityGroup.SpawnTables.generator_1_spotlight_1,
			EntityGroup.SpawnTables.generator_1_brake_light_sprite1,
			EntityGroup.SpawnTables.generator_1_brake_light_sprite,
			EntityGroup.SpawnTables.generator_1_spotlight_3_body,
			EntityGroup.SpawnTables.generator_1_spotlight_2,
			EntityGroup.SpawnTables.gas_nozzle,
			EntityGroup.SpawnTables.generator_1_light_off_sound,
			EntityGroup.SpawnTables.generator_1_light_on_sound,
			EntityGroup.SpawnTables.unnamed5,
			EntityGroup.SpawnTables.unnamed4,
			EntityGroup.SpawnTables.unnamed3,
			EntityGroup.SpawnTables.unnamed2,
			EntityGroup.SpawnTables.unnamed1,
			EntityGroup.SpawnTables.unnamed,
			EntityGroup.SpawnTables.generator_script,
			EntityGroup.SpawnTables.generator_1_spotlight_1_body,
			EntityGroup.SpawnTables.generator_1_spotlight_2_body,
			EntityGroup.SpawnTables.generator_1_sputter_sound,
			EntityGroup.SpawnTables.generator_1_stop_sound,
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		SpawnTables =
		{
			unnamed = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					body = "0"
					disablereceiveshadows = "0"
					ExplodeDamage = "0"
					ExplodeRadius = "0"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "0"
					glowrangemin = "0"
					glowstate = "0"
					LagCompensate = "0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_vehicles/floodlight_generator_nolight_static.mdl"
					PerformanceMode = "0"
					pressuredelay = "0"
					RandomAnimation = "0"
					renderamt = "255"
					rendercolor = "255 128 64"
					renderfx = "0"
					rendermode = "0"
					SetBodyGroup = "0"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					StartDisabled = "0"
					updatechildren = "0"
					origin = Vector( 0.906898, 0, 0 )
				}
			}
			generator_1_spotlight_4 = 
			{
				SpawnInfo =
				{
					classname = "point_spotlight"
					angles = Vector( -45, 90, 0 )
					fademindist = "-1"
					fadescale = "1"
					HaloScale = "60"
					HDRColorScale = "0.7"
					parentname = "generator_1_spotlight_4_body"
					renderamt = "255"
					rendercolor = "255 255 255"
					spawnflags = "0"
					spotlightlength = "500"
					spotlightwidth = "50"
					targetname = "generator_1_spotlight_4"
					origin = Vector( 2.3338, 18.741, 95 )
					connections =
					{
						OnLightOff =
						{
							cmd1 = "generator_1_spotlight_4_bodySkin10-1"
							cmd2 = "generator_1_light_off_soundPlaySound0-1"
						}
						OnLightOn =
						{
							cmd1 = "generator_1_spotlight_4_bodySkin00-1"
							cmd2 = "generator_1_light_on_soundPlaySound0-1"
						}
					}
				}
			}
			generator_1_spotlight_2_body = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( -45, 270, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_lamp.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "1"
					solid = "6"
					spawnflags = "0"
					targetname = "generator_1_spotlight_2_body"
					origin = Vector( 1.9069, -35, 86 )
				}
			}
			generator_1_spotlight_1_body = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( -45, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_lamp.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "1"
					solid = "6"
					targetname = "generator_1_spotlight_1_body"
					origin = Vector( 26.9069, -9.99999, 86 )
				}
			}
			generator_1_spotlight_4_body = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( -45, 90, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_lamp.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "1"
					solid = "6"
					targetname = "generator_1_spotlight_4_body"
					origin = Vector( 1.9069, 15, 86 )
				}
			}
			generator_1_spotlight_3_body = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( -45, 180, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_lamp.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "1"
					solid = "6"
					spawnflags = "0"
					targetname = "generator_1_spotlight_3_body"
					origin = Vector( -23.0931, -9.99999, 86 )
				}
			}
			generator_1_spotlight_2 = 
			{
				SpawnInfo =
				{
					classname = "point_spotlight"
					angles = Vector( -45, 270, 0 )
					fademindist = "-1"
					fadescale = "1"
					HaloScale = "60"
					HDRColorScale = "0.7"
					parentname = "generator_1_spotlight_2_body"
					renderamt = "255"
					rendercolor = "255 255 255"
					spawnflags = "0"
					spotlightlength = "500"
					spotlightwidth = "50"
					targetname = "generator_1_spotlight_2"
					origin = Vector( 3, -38, 95 )
					connections =
					{
						OnLightOff =
						{
							cmd1 = "generator_1_spotlight_2_bodySkin10-1"
							cmd2 = "generator_1_light_off_soundPlaySound0-1"
						}
						OnLightOn =
						{
							cmd1 = "generator_1_spotlight_2_bodySkin00-1"
							cmd2 = "generator_1_light_on_soundPlaySound0-1"
						}
					}
				}
			}
			generator_1_spotlight_1 = 
			{
				SpawnInfo =
				{
					classname = "point_spotlight"
					angles = Vector( -45, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					HaloScale = "60"
					HDRColorScale = "0.7"
					parentname = "generator_1_spotlight_1_body"
					renderamt = "255"
					rendercolor = "255 255 255"
					spawnflags = "0"
					spotlightlength = "500"
					spotlightwidth = "50"
					targetname = "generator_1_spotlight_1"
					origin = Vector( 31, -10, 95 )
					connections =
					{
						OnLightOff =
						{
							cmd1 = "generator_1_spotlight_1_bodySkin10-1"
							cmd2 = "generator_1_light_off_soundPlaySound0-1"
						}
						OnLightOn =
						{
							cmd1 = "generator_1_spotlight_1_bodySkin00-1"
							cmd2 = "generator_1_light_on_soundPlaySound0-1"
						}
					}
				}
			}
			generator_1_spotlight_3 = 
			{
				SpawnInfo =
				{
					classname = "point_spotlight"
					angles = Vector( -45, 180, 0 )
					fademindist = "-1"
					fadescale = "1"
					HaloScale = "60"
					HDRColorScale = "0.7"
					parentname = "generator_1_spotlight_3_body"
					renderamt = "255"
					rendercolor = "255 255 255"
					spawnflags = "0"
					spotlightlength = "500"
					spotlightwidth = "50"
					targetname = "generator_1_spotlight_3"
					origin = Vector( -27, -10, 95 )
					connections =
					{
						OnLightOff =
						{
							cmd1 = "generator_1_spotlight_3_bodySkin10-1"
							cmd2 = "generator_1_light_off_soundPlaySound0-1"
						}
						OnLightOn =
						{
							cmd1 = "generator_1_spotlight_3_bodySkin00-1"
							cmd2 = "generator_1_light_on_soundPlaySound0-1"
						}
					}
				}
			}
			unnamed1 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_base.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					origin = Vector( 1.9069, -29, 82.3421 )
				}
			}
			unnamed2 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_base.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					origin = Vector( 20.9069, -9.99999, 82.3421 )
				}
			}
			unnamed3 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 90, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_base.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					origin = Vector( 1.9069, 9, 82.3421 )
				}
			}
			unnamed4 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 180, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_wasteland/light_spotlight01_base.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					origin = Vector( -17.0931, -9.99999, 82.3421 )
				}
			}
			generator_1_spotlight_rotator = 
			{
				SpawnInfo =
				{
					classname = "func_rotating"
					angles = Vector( 0, 0, 0 )
					disablereceiveshadows = "0"
					disableshadows = "0"
					disableX360 = "0"
					dmg = "0"
					fademaxdist = "0"
					fademindist = "-1"
					fadescale = "1"
					fanfriction = "20"
					maxcpulevel = "0"
					maxgpulevel = "0"
					maxspeed = "30"
					mincpulevel = "0"
					mingpulevel = "0"
					origin = Vector( 1.91, -10, 64.99 )
					renderamt = "255"
					rendercolor = "255 255 255"
					renderfx = "0"
					rendermode = "0"
					solidbsp = "0"
					spawnflags = "144"
					targetname = "generator_1_spotlight_rotator"
					volume = "10"
					connections =
					{
						OnUser2 =
						{
							cmd1 = "generator_1_stop_soundPlaySound0-1"
							cmd2 = "generator_1_idle_soundStopSound0-1"
							cmd3 = "generator_1_sputter_soundStopSound0-1"
							cmd4 = "generator_1_brake_light_spriteHideSprite0-1"
						}
						OnUser1 =
						{
							cmd1 = "generator_1_brake_light_spriteShowSprite0-1"
						}
						OnUser3 =
						{
							cmd1 = "generator_1_sputter_soundPlaySound0-1"
							cmd2 = "generator_1_idle_soundStopSound2-1"
							cmd3 = "generator_1_idle_soundPlaySound0-1"
						}
						OnUser4 =
						{
							cmd1 = "generator_1_idle_soundPlaySound0-1"
							cmd2 = "generator_1_sputter_soundStopSound0-1"
						}
					}
				}
			}
			generator_script = 
			{
				SpawnInfo =
				{
					classname = "logic_script"
					targetname = "@generator_script"
					thinkfunction = "GeneratorThink"
					vscripts = "holdout_searchlight"
					origin = Vector( -45.2756, -21.627, 9.7347 )
				}
			}
			pour_target = 
			{
				SpawnInfo =
				{
					classname = "point_prop_use_target"
					nozzle = "gas_nozzle"
					origin = Vector( 6.3, -57.66, 54.15 )
					spawnflags = "1"
					targetname = "pour_target"
					connections =
					{
						OnUseFinished =
						{
							cmd1 = "@generator_scriptRunScriptCodeAddFuel()0-1"
						}
					}
				}
			}
			gas_nozzle = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					body = "0"
					disablereceiveshadows = "1"
					disableshadows = "1"
					ExplodeDamage = "0"
					ExplodeRadius = "0"
					fademaxdist = "2200"
					fademindist = "2000"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "255 31 26"
					glowrange = "1800"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_vehicles/radio_generator_fillup.mdl"
					PerformanceMode = "0"
					pressuredelay = "0"
					RandomAnimation = "0"
					renderamt = "255"
					rendercolor = "255 255 255"
					renderfx = "0"
					rendermode = "0"
					SetBodyGroup = "0"
					skin = "0"
					solid = "0"
					spawnflags = "0"
					StartDisabled = "0"
					targetname = "gas_nozzle"
					updatechildren = "0"
					origin = Vector( 2.02121, 2.3892, -0.828777 )
				}
			}
			event_scavenge_pour = 
			{
				SpawnInfo =
				{
					classname = "info_game_event_proxy"
					event_name = "explain_scavenge_goal"
					range = "800"
					spawnflags = "1"
					targetname = "event_scavenge_pour"
					origin = Vector( 2.16168, -49.654, 65.7347 )
				}
			}
			generator_1_stop_sound = 
			{
				SpawnInfo =
				{
					classname = "ambient_generic"
					cspinup = "0"
					fadeinsecs = "0"
					fadeoutsecs = "0"
					health = "10"
					lfomodpitch = "0"
					lfomodvol = "0"
					lforate = "0"
					lfotype = "0"
					message = "scavenge.generator_turnoff"
					pitch = "100"
					pitchstart = "100"
					preset = "0"
					radius = "1250"
					spawnflags = "48"
					spindown = "0"
					spinup = "0"
					targetname = "generator_1_stop_sound"
					volstart = "0"
					origin = Vector( 0, -66.654, 23.7347 )
				}
			}
			generator_1_sputter_sound = 
			{
				SpawnInfo =
				{
					classname = "ambient_generic"
					cspinup = "0"
					fadeinsecs = "0"
					fadeoutsecs = "0"
					health = "10"
					lfomodpitch = "0"
					lfomodvol = "0"
					lforate = "0"
					lfotype = "0"
					message = "scavenge.generator_sputter_loop"
					pitch = "100"
					pitchstart = "100"
					preset = "0"
					radius = "1250"
					spawnflags = "16"
					spindown = "0"
					spinup = "0"
					targetname = "generator_1_sputter_sound"
					volstart = "0"
					origin = Vector( 17, -64.654, 15.7347 )
				}
			}
			generator_1_idle_sound = 
			{
				SpawnInfo =
				{
					classname = "ambient_generic"
					cspinup = "0"
					fadeinsecs = "0"
					fadeoutsecs = "0"
					health = "10"
					lfomodpitch = "0"
					lfomodvol = "0"
					lforate = "0"
					lfotype = "0"
					message = "scavenge.generator_on_loop"
					pitch = "100"
					pitchstart = "100"
					preset = "0"
					radius = "1250"
					spawnflags = "16"
					spindown = "0"
					spinup = "0"
					targetname = "generator_1_idle_sound"
					volstart = "0"
					origin = Vector( -17, -68.654, 16.7347 )
				}
			}
			generator_1_brake_light_sprite = 
			{
				SpawnInfo =
				{
					classname = "env_sprite"
					disablereceiveshadows = "0"
					fademindist = "-1"
					fadescale = "1"
					framerate = "10.0"
					GlowProxySize = "4"
					HDRColorScale = ".7"
					maxdxlevel = "0"
					mindxlevel = "0"
					model = "sprites/light_glow01.vmt"
					renderamt = "240"
					rendercolor = "255 61 55"
					renderfx = "0"
					rendermode = "9"
					scale = "0.39"
					spawnflags = "0"
					targetname = "generator_1_brake_light_sprite"
					origin = Vector( -17, -48.654, 30.7347 )
				}
			}
			generator_1_brake_light_sprite1 = 
			{
				SpawnInfo =
				{
					classname = "env_sprite"
					disablereceiveshadows = "0"
					fademindist = "-1"
					fadescale = "1"
					framerate = "10.0"
					GlowProxySize = "4"
					HDRColorScale = ".7"
					maxdxlevel = "0"
					mindxlevel = "0"
					model = "sprites/light_glow01.vmt"
					renderamt = "240"
					rendercolor = "255 61 55"
					renderfx = "0"
					rendermode = "9"
					scale = "0.39"
					spawnflags = "0"
					targetname = "generator_1_brake_light_sprite"
					origin = Vector( 18, -47.654, 29.7347 )
				}
			}
			generator_1_light_on_sound = 
			{
				SpawnInfo =
				{
					classname = "ambient_generic"
					cspinup = "0"
					fadeinsecs = "0"
					fadeoutsecs = "0"
					health = "10"
					lfomodpitch = "0"
					lfomodvol = "0"
					lforate = "0"
					lfotype = "0"
					message = "c2m5.stage_light_on"
					pitch = "100"
					pitchstart = "100"
					preset = "0"
					radius = "1250"
					spawnflags = "48"
					spindown = "0"
					spinup = "0"
					targetname = "generator_1_light_on_sound"
					volstart = "0"
					origin = Vector( -20, -37.654, 71.857 )
				}
			}
			generator_1_light_off_sound = 
			{
				SpawnInfo =
				{
					classname = "ambient_generic"
					cspinup = "0"
					fadeinsecs = "0"
					fadeoutsecs = "0"
					health = "10"
					lfomodpitch = "0"
					lfomodvol = "0"
					lforate = "0"
					lfotype = "0"
					message = "c2m5.house_light_off"
					pitch = "100"
					pitchstart = "100"
					preset = "0"
					radius = "1250"
					spawnflags = "48"
					spindown = "0"
					spinup = "0"
					targetname = "generator_1_light_off_sound"
					volstart = "0"
					origin = Vector( -3, -38.654, 71.857 )
				}
			}
			unnamed5 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_buildables/spotlight_arms.mdl"
					parentname = "generator_1_spotlight_rotator"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					origin = Vector( 2, -10, 56 )
				}
			}
		} // SpawnTables
	} // EntityGroup
} // Searchlight

RegisterEntityGroup( "Searchlight", Searchlight )