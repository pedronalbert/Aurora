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
  TrayTip, AuroraBot, Initializing...
	Collector.init()
return

F3::
  Loop {
    TrayTip, AuroraBot, Paused
    Sleep, 10000
  }
return