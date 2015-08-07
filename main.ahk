#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./system.ahk



Gui:
	IniRead, ini_system_healToRepair, config.ini, System, healToRepair
  IniRead, ini_system_bonusBoxShader, config.ini, System, bonusBoxShader

	Gui, New
	Gui, Add, Text, , Reparar
	Gui, Add, Edit, w30 vhealToRepair, %ini_system_healToRepair%
	Gui, Add, Text, , BonusBoxShader
	Gui, Add, Edit, w30 vbonusBoxShader, %ini_system_bonusBoxShader%
	Gui, Add, Button, gInitCollect, Iniciar Recoleccion
	Gui, Add, Button, gReconfigClient, Reconfigurar Coordenadas
	Gui, Show
return

InitCollect:
	setConfig()

	Gui, Destroy

	if (System.isReady()) {
		System.initCollect()	
	} else {
		Gosub, Gui
	}
return 


F2::
	System.pauseCollect()
	Gosub, Gui
return

;-------------------------------------------------------------------

setConfig() {
	GuiControlGet, healToRepair
	GuiControlGet, bonusBoxShader


	System.healToRepair := healToRepair
	System.bonusBoxShader := bonusBoxShader

	updateSystemIni()

	IniRead, ini_client_top, config.ini, Client, top
  IniRead, ini_client_bottom, config.ini, Client, bottom

	if (ini_client_top > -1) {
		Client.setClientCors(false, ini_client_top, ini_client_bottom)
	} else {
		Client.setClientCors(true)
		updateClientIni()
	}
}

updateSystemIni() {
	healToRepair := System.healToRepair
	bonusBoxShader := System.bonusBoxShader

	IniWrite, %healToRepair%, config.ini, System, healToRepair
	IniWrite, %bonusBoxShader%, config.ini, System, bonusBoxShader
}

updateClientIni() {
	client_top := Client.boxCors.y1
	client_bottom := Client.boxCors.y2

	IniWrite, %client_top%, config.ini, Client, top
	IniWrite, %client_bottom%, config.ini, Client, bottom
}

ReconfigClient:
	Client.setClientCors(true)

	updateClientIni()

	Gosub, Gui
return