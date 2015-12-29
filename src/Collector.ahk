class Collector {
  static healToRepair := 95
  static bonusBoxCollected := 0
  static state :=
  static statePriority := 0
  static escapePortal := []
  static cloacksUsed := 0


  isReady() {
    if (Client.init() and Minimap.init() and Ship.init()) {
      if (ConfigManager.petActive) {
        if (Pet.init()) {
          return true
        } else {
          return false
        }
      }
      return true
    } else {
      return false
    }
  }

  initCollect() {
    this.resetPriority()
    this.setState("Find")
    this.setCheckTimers()

    Loop {
      if (this.state <> "Pause") {
        ; ------------------------ STATES -------------------------------------

        if (this.state = "Find") {
          bonusBoxCors := Client.findBonusBox()

          if (isObject(bonusBoxCors)) {
            OutputDebug, % "Bonus box find x: " bonusBoxCors[1] " y: " bonusBoxCors[2]

            if (Ship.isMoving()) {
              Ship.approach(bonusBoxCors)
              Sleep, 100

              this.setState("Approaching")
              continue
            } else {
              if (ConfigManager.soloPet = 1) {
                Sleep, 500 ;wait for pet collect
              } else {
                Ship.collect(bonusBoxCors)
                Sleep, 150
                this.setState("CollectingBonusBox") 
                continue
              }
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
            continue
          }
        }

        if (this.state = "CollectingBonusBox") {
          if (!Ship.isMoving()) {
            this.bonusBoxCollected++
            this.setState("Find")
            continue
          }
        }

        if (this.state = "GoToPortalForEscape") {
          Minimap.goTo(this.escapePortal)
          Sleep, 200

          if (!Ship.isMoving()) {
            Minimap.saveLastCors()
            Sleep, 1000
            Send {j}

            this.setState("EscapingToPortal_Next_BackToMap", 1)
            continue
          }

          if (Ship.getShieldPercent() <= 15) {
            Ship.changeConfig()
            Sleep, 500
          }
        }

        if (this.state ="EscapingToPortal_Next_BackToMap") {
          if (Minimap.isInNewMap()) {
            Minimap.saveLastCors()
            Sleep, 1000
            Send {j}
            this.setState("BackingToMap", 1)
            continue
          }

        }

        if (this.state = "BackingToMap") {
          if (Minimap.isInNewMap()) {
            this.setState("FinishRepair_Next_Find", 1)
            continue
          }
        }

        if (this.state = "FinishRepair_Next_Find") {
          if (Ship.getShieldPercent() >= 95) {
            Ship.changeConfig()
            Sleep, 2000

            if (Ship.getShieldPercent() >= 95) {
              if (Ship.getHealPercent() >= 95) {
                this.statePriority := 0
                this.setState("Find")
                this.setCheckTimers()
              }
            }
          }
        }

      } else {
        break
      }
    }
  }

  pauseCollect() {
    this.setState("Pause", 3)
    this.stopCheckTimers()
    SetTimer, disconnectCheck, off
    SetTimer, deadCheck, off
    bonusBox := this.bonusBoxCollected

    TrayTip, Aurora Stopped, Boxs Collected: %bonusBox%
  }

  setCheckTimers() {
    if (ConfigManager.autoCloack) {
      SetTimer, cloackCheck, % ConfigManager.invisibleCheckTime
    }

    if (ConfigManager.escapeActive) {
      SetTimer, damageCheck, % ConfigManager.damageCheckTime
    }

    if (ConfigManager.petActive) {
      SetTimer, petCheck, 5000
    }

    SetTimer, disconnectCheck, 5000
    SetTimer, deadCheck, 5000
    SetTimer, clientCheck, 60000

    return

    cloackCheck:
      if (!Ship.isInvisible()) {
        if (ConfigManager.cloacksAmount > Collector.cloacksUsed) {
          Ship.useCloack()
          Collector.cloacksUsed++
        } else {
          SetTimer, cloackCheck, Off
        }
      }
    return

    damageCheck:
      shieldPercent := Ship.getShieldPercent()
      healPercent := Ship.getHealPercent()
      OutputDebug, % "DamageCheck heal: " healPercent " shield: " shieldPercent
      if (healPercent > 0) { ;La vida tiene que ser visible o correra cuando este en zona radioactiva
        if (shieldPercent < ConfigManager.escapeShield) {
          Collector.escapeToPortal()
        }
      }
    return

    disconnectCheck:
      if (Client.isDisconnect()) {
        Client.connect()
      }
    return

    deadCheck:
      if (Ship.isDead()) {
        Collector.stopCheckTimers()
        reviveModeUsed := Ship.revive()

        Collector.setState("FinishRepair_Next_Find", 1)
      }
    return

    petCheck:
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
    return

    clientCheck:
      if (Client.questsIsOpen) {
        Client.questsClose()
      }
    return
  }

  stopCheckTimers() {
    SetTimer, cloackCheck, Off
    SetTimer, damageCheck, Off
    SetTimer, petCheck, Off
    SetTimer, clientCheck, Off
  }

  setState(state, priority := 0) {
    if (priority >= this.statePriority and this.state <> state) {
      this.state := state

      OutputDebug, % "New state: " state " Priority: " priority
    }
    
  }

  escapeToPortal() {
    OutputDebug, % "EscapeToPortal Called"
    this.stopCheckTimers()
    portalCors := Minimap.getNearPortalCors()
    this.escapePortal := portalCors
    this.setState("GoToPortalForEscape", 1)
  }

  resetPriority() {
    this.statePriority := 0
  }
}
