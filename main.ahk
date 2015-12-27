#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, ./src/client.ahk
#Include, ./src/minimap.ahk
#Include, ./src/ship.ahk
#Include, ./src/system.ahk
#Include, ./src/pet.ahk


#Include, ./src/gui.ahk

;---------------------------------------------------
F2::
	Gui, Destroy
	System.pauseCollect()
	Gosub, Gui
return

;--------------------------------------------

InitCollect:
	setSystemConfig()
	updateUserConfigIni()

	Gui, Destroy

	if (System.isReady()) {
		System.initCollect()	
	} else {
		Gosub, Gui
	}
return 

ReconfigClient:
	Gui, Hide

	Client.openCorsSetter()
	setSystemConfig()
	updateUserConfigIni()

	Gui, Destroy
	Gosub, Gui
return

GuiClose:
	ExitApp

;-------------------------------------------------------------------

updateUserConfigIni() {
	GuiControlGet, Map
	GuiControlGet, System_ReviveMode
	GuiControlGet, System_MoveMode

	IniWrite, % Map, config.ini, System, Map
	IniWrite, % System.configEscapeActive, config.ini, EscapeSystem, Activated
	IniWrite, % System.configEscapeShield, config.ini, EscapeSystem, Shield
	IniWrite, % System.configInvisibleActive, config.ini, InvisibleSystem, Activated
	IniWrite, % System.configInvisibleCheckTime, config.ini, InvisibleSystem, CheckTime
	IniWrite, % System.configInvisibleCpu, config.ini, InvisibleSystem, Cpu
	IniWrite, % System.configBonusBoxShader, config.ini, System, BonusBoxShader
	IniWrite, % System.configDamageCheckTime, config.ini, System, DamageCheckTime
	IniWrite, % Client.boxCors.y1, config.ini, Client, Top
	IniWrite, % Client.boxCors.y2, config.ini, Client, Bottom
	IniWrite, % System_MoveMode, config.ini, System, MoveMode
	IniWrite, % System_ReviveMode, config.ini, System, ReviveMode
	IniWrite, % System.configPetActive, config.ini, Pet, Activated
}

getUserConfigIni() {
	userConfig := {}
  userConfig.system := {}
  userConfig.invisibleSystem := {}
  userConfig.client := {}
  userConfig.escapeSystem := {}
  userConfig.petSystem := {}

  IniRead, System_BonusBoxShader, config.ini, System, BonusBoxShader
  IniRead, System_ReviveMode, config.ini, System, ReviveMode
  IniRead, System_DamageCheckTime, config.ini, System, DamageCheckTime
  IniRead, System_MoveMode, config.ini, System, MoveMode
  IniRead, System_Map, config.ini, System, Map
  IniRead, EscapeSystem_Activated, config.ini, EscapeSystem, Activated
  IniRead, EscapeSystem_Shield, config.ini, EscapeSystem, Shield
  IniRead, InvisibleSystem_Activated, config.ini, InvisibleSystem, Activated
  IniRead, InvisibleSystem_CheckTime, config.ini, InvisibleSystem, CheckTime
  IniRead, InvisibleSystem_Cpu, config.ini, InvisibleSystem, Cpu
  IniRead, ClientTop, config.ini, Client, Top
  IniRead, ClientBottom, config.ini, Client, Bottom
  IniRead, PetSystem_Activated, config.ini, Pet, Activated

  userConfig.system.bonusBoxShader := System_BonusBoxShader
	userConfig.system.reviveMode := System_ReviveMode
	userConfig.system.damageCheckTime := System_DamageCheckTime
	userConfig.system.moveMode := System_MoveMode
	userConfig.system.map := System_Map
	userConfig.escapeSystem.activated := EscapeSystem_Activated
	userConfig.escapeSystem.shield := EscapeSystem_Shield
	userConfig.invisibleSystem.activated := InvisibleSystem_Activated
	userConfig.invisibleSystem.checkTime := InvisibleSystem_CheckTime
	userConfig.invisibleSystem.cpu := InvisibleSystem_Cpu
	userConfig.client.top := ClientTop
	userConfig.client.bottom := ClientBottom
	userConfig.petSystem.activated := PetSystem_Activated

	return userConfig
}

setSystemConfig() {
	GuiControlGet, Map
	GuiControlGet, System_ReviveMode
	GuiControlGet, System_MoveMode
	GuiControlGet, EscapeSystem_Activated
	GuiControlGet, EscapeSystem_Shield
	GuiControlGet, InvisibleSystem_Activated
	GuiControlGet, InvisibleSystem_Cpu
	GuiControlGet, System_InvisibleCheckTime
	GuiControlGet, System_BonusBoxShader
	GuiControlGet, System_DamageCheckTime
	GuiControlGet, PetSystem_Activated

	mapsList := Minimap.getMapsArray()
	reviveModeList := ["PORTAL", "BASE"]
	moveModeList := ["RANDOM", "COMPLETE"]
	
	mapSelected := mapsList[Map]
	reviveModeSelected := reviveModeList[System_ReviveMode]
	moveModeSelected := moveModeList[System_MoveMode]

	System.configMap := mapSelected
	System.configEscapeActive := EscapeSystem_Activated
	System.configEscapeShield := EscapeSystem_Shield
	System.configInvisibleActive := InvisibleSystem_Activated
	System.configInvisibleCheckTime := System_InvisibleCheckTime
	System.configInvisibleCpu := InvisibleSystem_Cpu
	System.configBonusBoxShader := System_BonusBoxShader
	System.configDamageCheckTime := System_DamageCheckTime
	System.configReviveMode := reviveModeSelected
	System.configMoveMode := moveModeSelected
	System.configPetActive := PetSystem_Activated
}
