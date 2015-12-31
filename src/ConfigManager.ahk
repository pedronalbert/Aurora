class ConfigManager {
  static map := 24
  static clientWindowCors := {y1: 71, y2: 977}
  static moveMode := "COMPLETE"

  ;BonusBox
  static collectBonusBoxes := true
  static bonusBoxShader := 70

  ;GreenBoxes
  static collectGreenBooty := false
  static greenBootiesAmount := 10
  static greenBootyShader := 40

  ;Revive
  static reviveMode := "PORTAL"
  static reviveTimes := 0
  static reviveAfterSeconds := 10

  ;Pet
  static petActive := false
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
  static petCheckSeconds := 10
  static autoCloackCheckSeconds := 60
  static escapeCheckSeconds := 3
  static mouseSpeed := 2
}