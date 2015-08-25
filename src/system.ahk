class System {
	static healToRepair := 95
	static bonusBoxCollected := 0
	static state := 
	static statePriority := 0

  ;User config
	static map := 
  static escapeActivated := 
  static escapeShield := 
  static invisibleActivated := 
  static invisibleCheckTime := 
  static invisibleCpu :=
  static bonusBoxShader := 
  static damageCheckTime :=
	static reviveMode :=
  static escapePortal := []
  static moveMode :=
  static petActivated :=


	isReady() {
		if (Client.init() and Minimap.init() and Ship.init()) {
      if (this.petActivated = 1) {
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
		
		this.statePriority := 0
		this.setState("FindBonusBox")
		this.setCheckTimers()

		Loop {
			if (this.state <> "Pause") {
				; ------------------------ STATES -------------------------------------

				if (this.state = "FindBonusBox") {
					bonusBox := Client.findBonusBox(this.bonusBoxShader)

					if (isObject(bonusBox)) {
						OutputDebug, % "Bonus box find x: " bonusBox[1] " y: " bonusBox[2]
						if (Ship.isMoving()) {
							Ship.approach(bonusBox)
							Sleep, 100
							this.setState("ApproachingToBonusBox")
						} else {
							Ship.collect(bonusBox)
							Sleep, 200
							this.setState("CollectingBonusBox")
						}
					} else {
						if (!Ship.isMoving()) {
							Minimap.move()
							Sleep, 100
						}
					}
				}

				if (this.state = "ApproachingToBonusBox") { 
					if (!Ship.isMoving()) {
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "CollectingBonusBox") {
					if (!Ship.isMoving()) {
						this.bonusBoxCollected++
						Sleep, 200
						this.setState("FindBonusBox")
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
          }

				}

				if (this.state = "BackingToMap") {
					if (Minimap.isInNewMap()) {
						this.setState("FinishRepair_Next_FindBonusBox", 1)
					}
				}

				if (this.state = "FinishRepair_Next_FindBonusBox") {
					if (Ship.getShieldPercent() >= 95) {
						Ship.changeConfig()
						Sleep, 2000

						if (Ship.getShieldPercent() >= 95) {
							if (Ship.getHealPercent() >= 95) {
								this.statePriority := 0
                this.setCheckTimers()
								this.setState("FindBonusBox")
							}
						}
					}
				}

				if (this.state = "FinishRepair_Next_FindBonusBox_SetTimers") {
					if (Ship.getShieldPercent() >= 95) {
            Ship.changeConfig()
            Sleep, 2000

            if (Ship.getShieldPercent() >= 95) {
              if (Ship.getHealPercent() >= 95) {
                this.setCheckTimers()
                this.statePriority := 0
                this.setState("FindBonusBox")
              }
            }
          }
				}

				if (this.state = "FinishRepair_Next_GenerateRoute" ) {
          if (Ship.getShieldPercent() >= 95) {
            Ship.changeConfig()
            Sleep, 2000

            if (Ship.getShieldPercent() >= 95) {
              if (Ship.getHealPercent() >= 95) {
                this.setCheckTimers()
                Minimap.generateBackToMapRoute()
                this.setState("GoToNextPortal", 1)
              }
            }
          }
				}

				if (this.state = "GoToNextPortal") {
					if (Minimap.goToNextPortal()) {
						Sleep, 200
						this.setState("WaitForNextPortal_Next_JumpToNewMap", 1)
					} else {
						this.statePriority := 0
            this.setCheckTimers()
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "WaitForNextPortal_Next_JumpToNewMap") {
					if (!Ship.isMoving()) {
						Minimap.saveLastCors()
						Sleep, 1000
						Send {j}

						this.setState("WaitForNextMap_Next_GoToNextPortal", 1)
					}
				}

				if (this.state = "WaitForNextMap_Next_GoToNextPortal", 1) {
					if (Minimap.isInNewMap()) {
						Sleep, 300
						this.setState("GoToNextPortal", 1)
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
		bonusBox := this.bonusBoxCollected

		TrayTip, Aurora Stopped, Boxs Collected: %bonusBox%
	}

	setCheckTimers() {
		if (this.invisibleActivated = 1) {
			SetTimer, invisibleCheck, % this.invisibleCheckTime
		}

		if (this.escapeActivated = 1) {
			SetTimer, damageCheck, % this.damageCheckTime
		}

    if (this.petActivated = 1) {
      SetTimer, petCheck, 10000
    }

    SetTimer, disconnectCheck, 5000
    SetTimer, deadCheck, 5000

		return

		invisibleCheck:
			if (!Ship.isInvisible(this.invisibleCpu)) {
				Ship.setInvisible(this.invisibleCpu)
			}
		return

		damageCheck:
			shieldPercent := Ship.getShieldPercent()
			healPercent := Ship.getHealPercent()
			if (healPercent > 0) { ;no puede estar muerto
				if (shieldPercent < System.escapeShield) {
						System.escapeToPortal()
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
        System.stopCheckTimers()
        reviveModeUsed := Ship.revive(System.reviveMode)
        
        if (reviveModeUsed = "BASE") {
          System.setState("FinishRepair_Next_GenerateRoute", 1)
        } else {
          System.setState("FinishRepair_Next_FindBonusBox_SetTimers", 1)
        }
      }
    return

    petCheck:
      if (Pet.isDead()) {
        Pet.repair()
        Sleep, 1000
      }

      if (Pet.isPaused()) {
        Pet.play()
        Sleep, 1000
      }

      if (Pet.isPasive()) {
        Pet.selectModule("autocollector")
        Sleep, 1000
      }
    return
	}

	stopCheckTimers() {
		SetTimer, invisibleCheck, Off
		SetTimer, damageCheck, Off
    SetTimer, petCheck, Off
    SetTimer, deadCheck, Off
    SetTimer, disconnectCheck, Off
	}

	setState(state, priority := 0) {
		if (priority >= this.statePriority) {
			this.state := state
			OutputDebug, % "State: " state " Priority: " priority

		}
	}

	escapeToPortal() {
		this.stopCheckTimers()
    portalCors := Minimap.getNearPortalCors()
    this.escapePortal := portalCors
    this.setState("GoToPortalForEscape", 1)
	}

}
