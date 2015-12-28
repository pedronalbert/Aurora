#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, ./src/ConfigManager.ahk
#Include, ./src/Client.ahk
#Include, ./src/Minimap.ahk
#Include, ./src/Ship.ahk
#Include, ./src/Collector.ahk
#Include, ./src/Pet.ahk

;---------------------------------------------------
F2::
	if (Collector.isReady()) {
		TrayTip, AuroraBot, Bot iniciado
		Collector.initCollect()
	} else {
		TrayTip, AuroraBot, Error
	}
return

F3::
  Collector.pauseCollect()
return