#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./minimap.ahk
#Include, ./pet.ahk
/*
	FindBonusBox
	ApproachToBonusBox
*/
class System {
	static healToRepair := 95
	static bonusBoxCollected := 0
	static state := 
	static statePriority := 0
	static stateSeconds := 0
	static lastShipCors := []

	static escapeActivated := 
	static escapeShield := 
	static invisibleActivated := 
	static invisibleCheckTime := 
	static invisibleCpu :=
	static bonusBoxShader := 
	static damageCheckTime :=
	static map := 
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
					bonusBox := this.findBonusBox()

					if (isObject(bonusBox)) {
						OutputDebug, % "Bonus box find x: " bonusBox[1] " y: " bonusBox[2]
						if (Ship.isMoving()) {
							Ship.approach(bonusBox)
							Sleep, 100
							this.setState("ApproachingToBonusBox")
						} else {
							Ship.collect(bonusBox)
							Sleep, 300
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
						Sleep, 300
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "GoToPortalForEscape") {
          Minimap.goTo(this.escapePortal)
          Sleep, 200

					if (!Ship.isMoving()) {
						this.lastShipCors := Minimap.getShipCors()
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
          if (this.isInNewMap()) {
            this.lastShipCors := Minimap.getShipCors()
            Sleep, 1000
            Send {j}
            this.setState("BackingToMap", 1)
          }

				}

				if (this.state = "BackingToMap") {
					if (this.isInNewMap()) {
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
                Minimap.generateRoute()
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
						this.lastShipCors := Minimap.getShipCors()
						Sleep, 1000
						Send {j}

						this.setState("WaitForNextMap_Next_GoToNextPortal", 1)
					}
				}

				if (this.state = "WaitForNextMap_Next_GoToNextPortal", 1) {
					if (this.isInNewMap()) {
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

	findBonusBox() {
		shaderVariation := this.bonusBoxShader
		i := 1

		Loop, 4 {
			ImageSearch, corsX, corsY, Client.searchBoxsSize[i].x1, Client.searchBoxsSize[i].y1, Client.searchBoxsSize[i].x2, Client.searchBoxsSize[i].y2 , *%shaderVariation% ./img/bonus_box.bmp

			if (ErrorLevel = 0) {
				return [corsX, corsY]
			} else {
				ImageSearch, corsX, corsY, Client.searchBoxsSize[i].x1, Client.searchBoxsSize[i].y1, Client.searchBoxsSize[i].x2, Client.searchBoxsSize[i].y2 , *%shaderVariation% ./img/event_box.bmp

				if (ErrorLevel = 0) {
				  return [corsX, corsY]
        }
			}
			i++
		}
		return false
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
			if (!Ship.isInvisible()) {
				Ship.setInvisible()
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
        Pet.selectCollect()
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

	isInNewMap() {
		lastCors := this.lastShipCors
		newCors := Minimap.getShipCors()
    
		if (lastCors[1] > newCors[1]) {
			diferencia := lastCors[1] - newCors[1]
		} else {
			diferencia := newCors[1] - lastCors[1]
		}

		if diferencia > 40
			return true

		if (lastCors[2] > newCors[2]) {
			diferencia := lastCors[2] - newCors[2]
		} else {
			diferencia := newCors[2] - lastCors[2]
		}

		if diferencia > 40
			return true

		return false
	}

}
