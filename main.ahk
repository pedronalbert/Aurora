#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./system.ahk
#Include, ./pet.ahk


Gui:
	userConfig := getUserConfigIni()
	Client.setCors(userConfig.client.top, userConfig.client.bottom)

	Gui, Add, Tab, w300 h480 Center, Basic Settings|Advanced Settings

	Gui, Add, Text, xp80 yp+40, Map:
	Gui, Add, DropDownList,% "w80 yp-1 xp+40 vMap Choose1", 11|12|13|14|15|16|17|18|21|22|23|24|25|26|27|28|31|32|33|34|35|36|37|38

	Gui, Add, Text, x70 yp+40, Revive On:
	Gui, Add, DropDownList,% "w80 yp-1 xp+60 vSystem_ReviveMode Choose1", PORTAL|BASE

	Gui, Add, Text, x70 yp+40, Move mode:
	Gui, Add, DropDownList,% "w80 yp-1 xp+60 vSystem_MoveMode Choose1", RANDOM|COMPLETE

	Gui, Add, Text, x120 yp+30, PET:
	Gui, Add, Checkbox,% "xp+30 yp vPetSystem_Activated Checked" userConfig.petSystem.activated

	Gui, Add, GroupBox, x40 yp+20 w240 h85, Escape System
	Gui, Add, Text,x60 yp+20, Activate
	Gui, Add, Checkbox,% "xp+50 yp vEscapeSystem_Activated Checked" userConfig.escapeSystem.activated
	Gui, Add, Text,x60 yp+25, Shield (`%)
	Gui, Add, Slider, xp+50 yp-1 Range1-99 ToolTipRight vEscapeSystem_Shield,% userConfig.escapeSystem.shield

	Gui, Add, GroupBox, x40 yp+50 w240 h65, AutoCloack System
	Gui, Add, Text,x60 yp+20, Activate
	Gui, Add, Checkbox,% "xp+50 yp vInvisibleSystem_Activated Checked" userConfig.invisibleSystem.activated
	Gui, Add, Text,x60 yp+20, CPU
	Gui, Add, DropDownList,% "w50 yp-1 xp+50 vInvisibleSystem_Cpu Choose1", 10|50

	Gui, Add, GroupBox, x40 yp+40 w240 h80, Client Coors 
	Gui, Add, Text,x60 yp+20 ,% "Coors   Top: " userConfig.client.top " Bottom: " userConfig.client.bottom
	Gui, Add, Button, x90 yp+20 w150 gReconfigClient, Set Client Coors

	Gui, Add, Button, x60 yp+60 w200 h30 gInitCollect, Init Collect

	; ---------- Tab2 ----------------

	Gui, Tab, 2
	Gui, Add, Text, x40 y60, Bonus Box Shader
	Gui, Add, Slider, xp+120 yp-3 Range1-50 ThickInterval1 Thick18 ToolTipRight vSystem_BonusBoxShader, % userConfig.system.bonusBoxShader

	Gui, Add, Text, x40 yp50, Damage Checker (ms)
	Gui, Add, Edit, xp+130 yp-3 w60 vSystem_DamageCheckTime, % userConfig.system.damageCheckTime

	Gui, Add, Text, x40 yp40, Invisible Checker (ms)
	Gui, Add, Edit, xp+130 yp-3 w60 vSystem_InvisibleCheckTime, % userConfig.invisibleSystem.checkTime

	Gui, Show, , AuroraBot by @pedronalbert
Return

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
	IniWrite, % System.escapeActivated, config.ini, EscapeSystem, Activated
	IniWrite, % System.escapeShield, config.ini, EscapeSystem, Shield
	IniWrite, % System.invisibleActivated, config.ini, InvisibleSystem, Activated
	IniWrite, % System.invisibleCheckTime, config.ini, InvisibleSystem, CheckTime
	IniWrite, % System.invisibleCpu, config.ini, InvisibleSystem, Cpu
	IniWrite, % System.bonusBoxShader, config.ini, System, BonusBoxShader
	IniWrite, % System.damageCheckTime, config.ini, System, DamageCheckTime
	IniWrite, % System.reviveMode, config.ini, System, ReviveMode
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
  IniRead, EscapeSystem_Activated, config.ini, EscapeSystem, Activated
  IniRead, EscapeSystem_Shield, config.ini, EscapeSystem, Shield
  IniRead, InvisibleSystem_Activated, config.ini, InvisibleSystem, Activated
  IniRead, InvisibleSystem_CheckTime, config.ini, InvisibleSystem, CheckTime
  IniRead, InvisibleSystem_Cpu, config.ini, InvisibleSystem, Cpu
  IniRead, ClientTop, config.ini, Client, Top
  IniRead, ClientBottom, config.ini, Client, Bottom
  IniRead, PetSystem_Activated, config.ini Pet, Activated

  userConfig.system.bonusBoxShader := System_BonusBoxShader
	userConfig.system.reviveMode := System_ReviveMode
	userConfig.system.damageCheckTime := System_DamageCheckTime
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
	GuiControlGet, EscapeSystem_Activated
	GuiControlGet, EscapeSystem_Shield
	GuiControlGet, InvisibleSystem_Activated
	GuiControlGet, InvisibleSystem_Cpu
	GuiControlGet, System_InvisibleCheckTime
	GuiControlGet, System_BonusBoxShader
	GuiControlGet, System_DamageCheckTime
	GuiControlGet, System_ReviveMode
	GuiControlGet, System_MoveMode
	GuiControlGet, PetSystem_Activated

	System.escapeActivated := EscapeSystem_Activated
	System.escapeShield := EscapeSystem_Shield
	System.damageCheckTime := System_DamageCheckTime
	System.reviveMode := System_ReviveMode
	System.invisibleActivated := InvisibleSystem_Activated
	System.invisibleCheckTime := System_InvisibleCheckTime
	System.invisibleCpu := InvisibleSystem_Cpu
	System.bonusBoxShader := System_BonusBoxShader
	System.map := Map
	System.moveMode := System_MoveMode
	System.petActivated := PetSystem_Activated
}
