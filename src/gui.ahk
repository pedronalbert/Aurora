Gui:
  userConfig := getUserConfigIni()
  maps := Minimap.getMapsString()
  Client.setCors(userConfig.client.top, userConfig.client.bottom)

  Gui, Add, Tab, w300 h480 Center, Basic Settings|Advanced Settings

  Gui, Add, Text, xp80 yp+40, Map:
  Gui, Add, DropDownList,% "w80 yp-1 xp+40 vMap AltSubmit Choose" userConfig.system.map, % maps

  Gui, Add, Text, x70 yp+40, Revive On:
  Gui, Add, DropDownList,% "w80 yp-1 xp+60 AltSubmit vSystem_ReviveMode Choose" userConfig.system.reviveMode, PORTAL|BASE

  Gui, Add, Text, x70 yp+40, Move mode:
  Gui, Add, DropDownList,% "w80 yp-1 xp+60 AltSubmit vSystem_MoveMode Choose" userConfig.system.moveMode, RANDOM|COMPLETE

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