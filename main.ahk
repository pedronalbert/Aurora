#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./system.ahk


Gui:
	userConfig := getUserConfigIni()
	Client.setCors(userConfig.clientTop, userConfig.clientBottom)

	Gui, Add, Tab, w300 h450 Center, Basic Settings|Advanced Settings

	Gui, Add, Text, xp80 yp+40, Map:
	Gui, Add, DropDownList,% "w80 yp-1 xp+40 vMap Choose1", 35|36|37|38

	Gui, Add, Text, x70 yp+40, Revive On:
	Gui, Add, DropDownList,% "w80 yp-1 xp+60 vSystem_ReviveMode Choose1", PORTAL|BASE

	Gui, Add, GroupBox, x40 yp+30 w240 h85, Escape System
	Gui, Add, Text,x60 yp+20, Activate
	Gui, Add, Checkbox,% "xp+50 yp vEscapeSystem_Activated Checked" userConfig.escapeSystem_Activated
	Gui, Add, Text,x60 yp+25, Shield (`%)
	Gui, Add, Slider, xp+50 yp-1 Range1-99 ToolTipRight vEscapeSystem_Shield,% userConfig.escapeSystem_Shield

	Gui, Add, GroupBox, x40 yp+50 w240 h65, Invisible System
	Gui, Add, Text,x60 yp+20, Activate
	Gui, Add, Checkbox,% "xp+50 yp vInvisibleSystem_Activated Checked" userConfig.invisibleSystem_Activated
	Gui, Add, Text,x60 yp+20, CPU
	Gui, Add, DropDownList,% "w50 yp-1 xp+50 vInvisibleSystem_Cpu Choose1", 10|50

	Gui, Add, GroupBox, x40 yp+40 w240 h80, Client Coors 
	Gui, Add, Text,x60 yp+20 ,% "Coors   Top: " userConfig.clientTop " Bottom: " userConfig.clientBottom
	Gui, Add, Button, x90 yp+20 w150 gReconfigClient, Set Client Coors

	Gui, Add, Button, x60 yp+70 w200 h30 gInitCollect, Iniciar Recoleccion

	; ---------- Tab2 ----------------

	Gui, Tab, 2
	Gui, Add, Text, x40 y60, Bonus Box Shader
	Gui, Add, Slider, xp+120 yp-3 Range1-50 ThickInterval1 Thick18 ToolTipRight vSystem_BonusBoxShader, % userConfig.system_BonusBoxShader

	Gui, Add, Text, x40 yp50, Damage Checker (ms)
	Gui, Add, Edit, xp+130 yp-3 w60 vSystem_DamageCheckTime, % userConfig.system_DamageCheckTime

	Gui, Add, Text, x40 yp40, Invisible Checker (ms)
	Gui, Add, Edit, xp+130 yp-3 w60 vSystem_InvisibleCheckTime, % userConfig.invisibleSystem_CheckTime

	Gui, Show, , DarkOrbit Bot by pedronalbert
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
}

getUserConfigIni() {
	userConfig := {}

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

	userConfig.system_BonusBoxShader := System_BonusBoxShader
	userConfig.system_ReviveMode := System_ReviveMode
	userConfig.system_DamageCheckTime := System_DamageCheckTime
	userConfig.escapeSystem_Activated := EscapeSystem_Activated
	userConfig.escapeSystem_Shield := EscapeSystem_Shield
	userConfig.invisibleSystem_Activated := InvisibleSystem_Activated
	userConfig.invisibleSystem_CheckTime := InvisibleSystem_CheckTime
	userConfig.invisibleSystem_Cpu := InvisibleSystem_Cpu
	userConfig.clientTop := ClientTop
	userConfig.clientBottom := ClientBottom

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

	System.escapeActivated := EscapeSystem_Activated
	System.escapeShield := EscapeSystem_Shield
	System.damageCheckTime := System_DamageCheckTime
	System.reviveMode := System_ReviveMode
	System.invisibleActivated := InvisibleSystem_Activated
	System.invisibleCheckTime := System_InvisibleCheckTime
	System.invisibleCpu := InvisibleSystem_Cpu
	System.bonusBoxShader := System_BonusBoxShader
	System.map := Map
}
