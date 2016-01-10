#SingleInstance, Force

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

;------------Vendors--------------
#Include, ./vendor/Gdip.ahk

#Include, ./src/ConfigManager.ahk
#Include, ./src/Client.ahk
#Include, ./src/Minimap.ahk
#Include, ./src/Ship.ahk
#Include, ./src/Collector.ahk
#Include, ./src/Pet.ahk
;---------------------------------------------------


F2::
  TrayTip, AuroraBot, Starting...
  Collector.init()
return

F3::
  TrayTip, AuroraBot, Paused...
  Collector.active := false
return