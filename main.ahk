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
	IniWrite, % System_MoveMode, config.ini, System, MoveMode
	IniWrite, % System_ReviveMode, config.ini, System, ReviveMode
	IniWrite, % System.escapeActivated, config.ini, EscapeSystem, Activated
	IniWrite, % System.escapeShield, config.ini, EscapeSystem, Shield
	IniWrite, % System.invisibleActivated, config.ini, InvisibleSystem, Activated
	IniWrite, % System.invisibleCheckTime, config.ini, InvisibleSystem, CheckTime
	IniWrite, % System.invisibleCpu, config.ini, InvisibleSystem, Cpu
	IniWrite, % System.bonusBoxShader, config.ini, System, BonusBoxShader
	IniWrite, % System.damageCheckTime, config.ini, System, DamageCheckTime
	IniWrite, % Client.boxCors.y1, config.ini, Client, Top
	IniWrite, % Client.boxCors.y2, config.ini, Client, Bottom
	IniWrite, % System.petActivated, config.ini, Pet, Activated
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

	System.map := mapSelected
	System.reviveMode := reviveModeSelected
	System.moveMode := moveModeSelected
	System.escapeActivated := EscapeSystem_Activated
	System.escapeShield := EscapeSystem_Shield
	System.damageCheckTime := System_DamageCheckTime
	System.invisibleActivated := InvisibleSystem_Activated
	System.invisibleCheckTime := System_InvisibleCheckTime
	System.invisibleCpu := InvisibleSystem_Cpu
	System.bonusBoxShader := System_BonusBoxShader
	System.petActivated := PetSystem_Activated
}
