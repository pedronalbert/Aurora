class ConfigManager {
  static map := 33
  static clientWindowCors := {y1: 71, y2: 977}
  static moveMode := "COMPLETE"

  ;BonusBox
  static collectBonusBoxes := true
  static bonusBoxShader := 75


  ;Event box
  static collectEventBoxes := false
  static eventBoxShader := 50

  ;GreenBoxes
  static collectGreenBooty := false
  static greenBootiesAmount := 45
  static greenBootyShader := 40

  ;Revive
  static reviveMode := "PORTAL"
  static reviveTimes := 20
  static reviveAfterSeconds := 15

  ;Pet
  static petActive := true
  static soloPet := false

  ;AutoSystems
  static escapeActive := true
  static escapeShield := 90
  static autoCloack := true
  static cloackCpu := 50
  static cloacksAmount := 5

  ;Advanced
  static deadCheckSeconds := 10
  static disconnectCheckSeconds := 10
  static petCheckSeconds := 15
  static autoCloackCheckSeconds := 60
  static escapeCheckSeconds := 3
  static mouseSpeed := 2
}