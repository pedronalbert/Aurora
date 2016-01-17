class ConfigManager {
  static targetMap := 33
  static moveMode := "COMPLETE"
  static clientCoorsY1 := 71
  static clientCoorsY2 :=  978

  ;BonusBox
  static collectBonusBoxes := true
  static soloPetCollect := true
  static refinateGarbage := true
  static bonusBoxShader := 75

  ;Event box
  static collectEventBoxes := false
  static eventBoxShader := 50

  ;Revive
  static reviveMode := "BASE"
  static reviveTimes := 20
  static reviveAfterSeconds := 10

  ;Pet
  static petActive := true
  static petRevive := true
  static petAutoLooter := true
  static petFullRepair := true

  ;AutoSystems
  static escapeActive := true
  static escapeShield := 95

  ;Autocloack
  static autoCloack := true
  static cloackCpu := 50
  static cloacksAmount := 10

  ;Advanced
  static deadCheckSeconds := 10
  static disconnectCheckSeconds := 10
  static petCheckSeconds := 5
  static autoCloackCheckSeconds := 60
  static escapeCheckSeconds := 3
  static garbageCheckSeconds := 10
  static mouseSpeed := 1
}