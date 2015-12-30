class Collector {
  static healToRepair := 95
  static bonusBoxCollected := 0
  static state :=
  static statePriority := 0
  static escapePortal := []
  static cloacksUsed := 0

  static escapeChecker := {active: true, lastCheck: 0}
  static deadChecker := {active: true, lastCheck: 0}
  static disconnectChecker := {active: true, lastCheck: 0}
  static autoCloackChecker := {active: true, lastCheck: 0}
  static petChecker := {active: true, lastCheck: 0}

  isReady() {
    if (Client.init()) {
      Minimap.init()
      Ship.init()

      if (ConfigManager.petActive) {
        Pet.init()
      }

      return true
    } else {
      return false
    }
  }

  init() {
    if (Client.init()) {
      Minimap.init()
      Ship.init()

      if (ConfigManager.petActive) {
        Pet.init()
      }
    } else {
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
            this.escapeChecker.active := false
            this.deadChecker.active := false
            this.petChecker.active := false

            reviveModeUsed := Ship.revive(ConfigManager.reviveMode)

            if (reviveModeUsed = "PORTAL") {
              this.setState("FinishRepairAfterPortalRevive")
            } else if (reviveModeUsed = "BASE") {
              this.setState("FinishRepairAfterBaseRevive")
            } else if (reviveModeUsed = false) {
              Loop {
                Client.reload()

                if (Ship.isDead()) {
                  if (Ship.revive("BASE") = false) {
                    continue ;reload again
                  }
                }

                Client.questsWindowClose()
                this.setState("FinishRepairAfterBaseRevive")
                break
              }
            }

          }
        }
      }

      if (this.disconnectChecker.active) {
        timeDiff := nowTime - this.disconnectChecker.lastCheck

        if (timeDiff >= ConfigManager.disconnectCheckSeconds) {
          this.disconnectChecker.lastCheck := A_Now

          if (Client.isDisconnect()) {
            if (Client.connect()) {
              if (!Ship.isDead()) {
                Client.questsWindowClose()
                this.setState("Find")
              } else {
                if (Ship.revive("BASE") <> false) {
                  Client.questsWindowClose()
                  this.setState("FinishRepairAfterBaseRevive")
                } else {
                  Loop {
                    Client.reload()

                    if (Ship.isDead()) {
                      if (Ship.revive("BASE") = false) {
                        continue ;reload again
                      } else {
                        ;si revivio
                        Client.questsWindowClose()
                        this.setState("FinishRepairAfterBaseRevive")
                        break
                      }
                    } else {
                      Client.questsWindowClose()
                      this.setState("Find")
                      break
                    }
                  } 
                }
              }
            } else {
              Loop {
                Client.reload()

                if (Ship.isDead()) {
                  if (Ship.revive("BASE") = false) {
                    continue ;reload again
                  } else {
                    ;si revivio
                    Client.questsWindowClose()
                    this.setState("FinishRepairAfterBaseRevive")
                    break
                  }
                } else {
                  Client.questsWindowClose()
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
        bonusBoxCors := Client.findBonusBox()

        if (isObject(bonusBoxCors)) {
          if (Ship.isMoving()) {
            Ship.approach(bonusBoxCors)
            Sleep, 100

            this.setState("Approaching")
          } else {
            Ship.collect(bonusBoxCors)
            Sleep, 100

            this.setState("CollectingBonusBox")
          }
        } else {
          if (!Ship.isMoving()) {
            Minimap.move()
            Sleep, 500
          }
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
