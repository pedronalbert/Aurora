class Collector {
  static healToRepair := 95
  static bonusBoxCollected := 0
  static state :=
  static statePriority := 0
  static escapePortal := []
  static cloacksUsed := 0
  static reviveTimes := 0

  static escapeChecker := {active: true, lastCheck: 0}
  static deadChecker := {active: true, lastCheck: 0}
  static disconnectChecker := {active: true, lastCheck: 0}
  static autoCloackChecker := {active: true, lastCheck: 0}
  static petChecker := {active: true, lastCheck: 0}
  static greenBoxesCollected := 0

  init() {
    if (!Client.init()) {
      return false
    }

    this.escapeChecker.active := ConfigManager.escapeActive
    this.petChecker.active := ConfigManager.petActive
    this.autoCloackChecker.active := ConfigManager.autoCloack

    this.setState("Find")

    Loop {
      nowTime := A_Now

      ;----- Checkers -----
      if (this.escapeChecker.active) {
        timeDiff := nowTime - this.escapeChecker.lastCheck

        if (timeDiff >= ConfigManager.escapeCheckSeconds) {
          this.escapeChecker.lastCheck := A_Now

          if (Ship.getHealPercent() > 0 and Ship.getShieldPercent() <= ConfigManager.escapeShield) {
            this.escapeChecker.active := false
            this.petChecker.active := false
            this.autoCloackChecker.active := false

            portalCors := Minimap.getNearPortalCors()
            Minimap.goTo(portalCors)
            Sleep, 500

            this.setState("GoingToEscapePortal")
          }
        }
      }

      if (this.deadChecker.active) {
        timeDiff := nowTime - this.deadChecker.lastCheck

        if (timeDiff >= ConfigManager.deadCheckSeconds) {
          this.deadChecker.lastCheck := A_Now

          if (Ship.isDead()) {
            if (this.reviveTimes <= ConfigManager.reviveTimes) {
              this.escapeChecker.active := false
              this.deadChecker.active := false
              this.petChecker.active := false

              ;Wait reviveSeconds 
              seconds := ConfigManager.reviveAfterSeconds * 1000
              Sleep, seconds

              revive := Ship.revive(ConfigManager.reviveMode)

              if (revive = "PORTAL") {
                this.reviveTimes++
                this.setState("FinishRepairAfterPortalRevive")
              } else if (revive = "BASE") {
                this.reviveTimes++
                this.setState("FinishRepairAfterBaseRevive")
              } else if (revive = false) {
                Loop {
                  Client.reload()

                  if (Ship.isDead()) {
                    if (Ship.revive("BASE") = false) {
                      continue ;reload again
                    }
                  }

                  Client.init()
                  this.reviveTimes++
                  this.setState("FinishRepairAfterBaseRevive")
                  break
                }
              }
            } else {
              return false ;Pause
            }
          }
        }
      }

      if (this.disconnectChecker.active) {
        timeDiff := nowTime - this.disconnectChecker.lastCheck

        if (timeDiff >= ConfigManager.disconnectCheckSeconds) {
          this.disconnectChecker.lastCheck := A_Now

          if (Client.isDisconnect()) {
            if (Client.connect()) { ;Si conecta diractamente
              if (Ship.isDead()) {
                if (this.reviveTimes <= ConfigManager.reviveTimes) {
                  ;Wait reviveSeconds 
                  seconds := ConfigManager.reviveAfterSeconds * 1000
                  Sleep, seconds

                  revive := Ship.revive("BASE")

                  if (revive <> false) {
                    this.reviveTimes++
                    this.setState("FinishRepairAfterBaseRevive")
                  } else { ;Si no revivio
                    Loop {
                      Client.reload()

                      if (Ship.isDead()) {
                        if (Ship.revive("BASE") = false) {
                          continue ;reload again
                        }
                      }

                      Client.init()
                      this.reviveTimes++
                      this.setState("FinishRepairAfterBaseRevive")
                      break
                    }
                  }
                } else {
                  return false ;Stop bot
                }

              } else { ;Si no esta muerto
                Client.init()
                this.setState("Find")
              }
            } else { ;No conectó directamente
              Loop {
                Client.reload()

                if (Ship.isDead()) {
                  if (this.reviveTimes <= ConfigManager.reviveTimes) {
                    ;Wait reviveSeconds 
                    seconds := ConfigManager.reviveAfterSeconds * 1000
                    Sleep, seconds

                    revive := Ship.revive("BASE")

                    if (revive <> false) {
                      this.reviveTimes++
                      this.setState("FinishRepairAfterBaseRevive")
                    } else { ;Si no revivio
                      Loop {
                        Client.reload()

                        if (Ship.isDead()) {
                          if (Ship.revive("BASE") = false) {
                            continue ;reload again
                          }
                        }

                        Client.init()
                        this.reviveTimes++
                        this.setState("FinishRepairAfterBaseRevive")
                        break
                      }
                    }
                  } else {
                    return false ;Stop bot
                  }
                } else { ;Si no esta muerto
                  Client.init()
                  this.setState("Find")
                  break
                }
              }
            }
          }
        }
      }

      if (this.petChecker.active) {
        timeDiff := nowTime - this.petChecker.lastCheck

        if (timeDiff >= ConfigManager.petCheckSeconds) {
          this.petChecker.lastCheck := A_Now

          if (Pet.isDead()) {
            Pet.repair()
            Sleep, 800
          }

          if (Pet.isPaused()) {
            Pet.play()
            Sleep, 800
          }

          if (Pet.isPasive()) {
            Pet.selectModule("autocollector")
          }
        }
      }

      if (this.autoCloackChecker.active) {
        timeDiff := nowTime - this.autoCloackChecker.lastCheck

        if (timeDiff >= ConfigManager.autoCloackCheckSeconds) {
          this.autoCloackChecker.lastCheck := A_Now

          if (!Ship.isInvisible()) {
            if (ConfigManager.cloacksAmount > this.cloacksUsed) {
              if (Ship.useCloack()) {
                this.cloacksUsed++
              }
            }
          }
        }
      }

      ;----- States------
      if (this.state = "Find") {
        roaming := false

        if (ConfigManager.collectGreenBoxes = true and this.greenBoxesCollected < ConfigManager.greenBoxesAmount) {
          greenBoxCors := Client.findGreenBox()

          if (isObject(greenBoxCors)) {
            if (Ship.isMoving()) {
              Ship.approach(greenBoxCors)
              Sleep, 100

              roaming := false
              this.setState("Approaching")
            } else {
              Ship.collect(greenBoxCors)
              Sleep, 100

              roaming := false
              this.setState("CollectingGreenBox")
            }
          } else {
            roaming := true
          }
        } else if(ConfigManager.collectBonusBoxes) {
          bonusBoxCors := Client.findBonusBox()

          if (isObject(bonusBoxCors)) {
            if (Ship.isMoving()) {
              Ship.approach(bonusBoxCors)
              Sleep, 100

              roaming := false
              this.setState("Approaching")
            } else {
              if (ConfigManager.soloPet) {
                ;Wait pet collect
                roaming := false
              } else {
                Ship.collect(bonusBoxCors)
                Sleep, 100

                roaming := false
                this.setState("CollectingBonusBox")
              }
            }
          } else {
            roaming := true
          }
        }

        if (roaming = true and Ship.isMoving() = false) {
          Minimap.move()
          Sleep, 500
        }
      }

      if (this.state = "Approaching") {
        if (!Ship.isMoving()) {
          this.setState("Find")
        }
      }

      if (this.state = "CollectingBonusBox") {
        if (!Ship.isMoving()) {
          Sleep, 100
          this.setState("Find")
        }
      }

      if (this.state = "CollectingGreenBox") {
        if (!Ship.isMoving()) {
          Sleep, 6000
          this.greenBoxesCollected++
          this.setState("Find")
        }
      }

      if (this.state = "GoingToEscapePortal") {
        if (!Ship.isMoving()) {
          Minimap.saveLastCors()
          Sleep, 500
          Send {j}
          Sleep, 3000
          this.setState("JumpingEscapePortal")
        }

        if (Ship.getShieldPercent() <= 15) {
          Ship.changeConfig()
          Sleep, 500
        }
      }

      if (this.state ="JumpingEscapePortal") {
        if (Minimap.isInNewMap()) {
          Minimap.saveLastCors()
          Send {j}
          Sleep, 1000

          this.setState("BackingToMapAfterEscape")
        }

      }

      if (this.state = "BackingToMapAfterEscape") {
        if (Minimap.isInNewMap()) {
          this.setState("FinishRepairAfterEscape")
        }
      }

      if (this.state = "FinishRepairAfterEscape") {
        if (Ship.getShieldPercent() >= 95) {
          Ship.changeConfig()
          Sleep, 3000

          if (Ship.getShieldPercent() >= 95) {
            if (Ship.getHealPercent() >= 95) {
              this.escapeChecker.active := ConfigManager.escapeActive
              this.petChecker.active := ConfigManager.petActive
              this.autoCloackChecker.active := ConfigManager.autoCloack
              this.setState("Find")
            }
          }
        }
      }

      if (this.state = "FinishRepairAfterPortalRevive") {
        if (Ship.getShieldPercent() >= 95) {
          Ship.changeConfig()
          Sleep, 6500

          if (Ship.getShieldPercent() >= 95) {
            if (Ship.getHealPercent() >= 95) {
              this.escapeChecker.active := ConfigManager.escapeActive
              this.deadChecker.active := true
              this.petChecker.active := ConfigManager.petActive
              this.setState("Find")
            }
          }
        }
      }
    }
  }

  setState(newState) {
    this.state := newState

    OutputDebug, % "new state: " newState 
  }
}
