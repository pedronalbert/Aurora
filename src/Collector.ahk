class Collector {
  static active := false
  static bonusBoxCollected := 0
  static state :=
  static statePriority := 0
  static cloacksUsed := 0
  static reviveTimes := 0
  static greenBoxesCollected := 0

  static escapeChecker := {active: true, lastCheck: 0}
  static deadChecker := {active: true, lastCheck: 0}
  static disconnectChecker := {active: true, lastCheck: 0}
  static autoCloackChecker := {active: true, lastCheck: 0}
  static petChecker := {active: true, lastCheck: 0}

  init() {
    Client.setWindowCors()

    if(Ship.isDead()) {
      if (this.reviveTimes <= ConfigManager.reviveTimes || ConfigManager.reviveTimes = 0) {
        revive := Ship.revive(ConfigManager.reviveMode)

        if (revive = "PORTAL") {
          this.active := true
          this.reviveTimes++
          this.setState("FinishRepairAfterPortalRevive")
        } else if (revive = "BASE") {
          this.active := true
          this.reviveTimes++
          this.setState("FinishRepairAfterBaseRevive")
        } else if (revive = false) {
          Client.reload()
          this.init()
        }
      } else {
        MsgBox, Aurora Stoped, Revive times limit reach

        return false
      }
    } else {
      ;Normal init
      if (!Client.init()) {
        return false
      }

      actualMap := Minimap.getActualMap()

      if(actualMap > 0 and ConfigManager.targetMap <> actualMap) {
        ConfigManager.targetMap := actualMap ;Cambio de mapa temporal en caso de estar en mapa incorrecto
      }

      this.escapeChecker.active := ConfigManager.escapeActive
      this.petChecker.active := ConfigManager.petActive
      this.autoCloackChecker.active := ConfigManager.autoCloack
      this.active := true

      this.setState("Find")
    }

    
    Loop {
      if (this.active = false) {
        return false
      }

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
            Client.takeScreenshot()

            if (this.reviveTimes <= ConfigManager.reviveTimes || ConfigManager.reviveTimes = 0) {
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
                Client.reload()
                this.init()
              }
            } else {
              MsgBox, Aurora Stoped, Revive times limit reach

              return false
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
              this.init()
            } else { ;No conectó directamente
              Client.reload()
              this.init()
            }
          }
        }
      }

      if (this.petChecker.active) {
        timeDiff := nowTime - this.petChecker.lastCheck

        if (timeDiff >= ConfigManager.petCheckSeconds) {
          this.petChecker.lastCheck := A_Now

          if (Pet.isDead()) {
            Pet.revive()
          }

          if (Pet.isPaused()) {
            Pet.play()
          }

          if (Pet.isPasive()) {
            Pet.setAutocollector()
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
        objectFound := false

        if (ConfigManager.collectEventBoxes = true and objectFound = false) {
          eventBox := Client.findEventBox()

          if (isObject(eventBox)) {
            if (Ship.isMoving()) {
              Ship.approach(eventBox)
              Sleep, 100

              objectFound := true
              this.setState("Approaching")
            } else {
              if (ConfigManager.soloPet) {
                ;Wait pet collect
                objectFound := true
              } else {
                Ship.collect(eventBox)
                Sleep, 100

                objectFound := true
                this.setState("CollectingBonusBox")
              }
            }
          } else {
            objectFound := false
          }
        }

        if (ConfigManager.collectBonusBoxes = true and objectFound = false) {
          bonusBoxCors := Client.findBonusBox()

          if (isObject(bonusBoxCors)) {
            if (Ship.isMoving()) {
              Ship.approach(bonusBoxCors)
              Sleep, 100

              objectFound := true
              this.setState("Approaching")
            } else {
              if (ConfigManager.soloPet) {
                ;Wait pet collect
                objectFound := true
              } else {
                Ship.collect(bonusBoxCors)
                Sleep, 100

                objectFound := true
                this.setState("CollectingBonusBox")
              }
            }
          } else {
            objectFound := false
          }
        }

        if (objectFound = false and Ship.isMoving() = false) {
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
        if (Minimap.isInTargetMap() == false) {
          Send {j}
          Sleep, 1000

          this.setState("BackingToMapAfterEscape")
        }

      }

      if (this.state = "BackingToMapAfterEscape") {
        if (Minimap.isInTargetMap()) {
          this.setState("FinishRepairAfterEscape")
        }
      }

      if (this.state = "FinishRepairAfterEscape") {
        if (Ship.getShieldPercent() >= 95) {
          Ship.changeConfig()
          Sleep, 3000

          if (Ship.getShieldPercent() >= 95) {
            if (Ship.getHealPercent() >= 95) {
              this.init()
            }
          }
        }
      }

      if (this.state = "FinishRepairAfterPortalRevive") {
        Client.init()

        if (Ship.getShieldPercent() >= 95) {
          Ship.changeConfig()
          Sleep, 6500

          if (Ship.getShieldPercent() >= 95) {
            if (Ship.getHealPercent() >= 95) {
              this.init()
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
