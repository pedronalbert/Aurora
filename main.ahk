#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./system.ahk



Gui:
	Gui, New
	Gui, Add, Text, , Reparar
	Gui, Add, Edit, w30 vhealToRepair, 50
	Gui, Add, Text, , BonusBoxShader
	Gui, Add, Edit, w30 vbonusBoxShader, 20
	Gui, Add, Button, gInitCollect, Iniciar Recoleccion
	Gui, Show
return

InitCollect:
	GuiControlGet, healToRepair
	GuiControlGet, bonusBoxShader
	Gui, Destroy

	Client.bonusBoxShader := bonusBoxShader
	System.healToRepair := healToRepair

	Client.init()

	if (Client.isReady()) {
		System.initCollect()	
	}
return 

F2::
	System.pauseCollect()
	Gosub, Gui
return
