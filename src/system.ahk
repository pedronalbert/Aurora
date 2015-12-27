class System {
	static healToRepair := 95
	static bonusBoxCollected := 0
	static state :=
	static statePriority := 0
  static escapePortal := []

  ;User config
  static configMap :=
  static configEscapeActive :=
  static configEscapeShield :=
  static configInvisibleActive :=
  static configInvisibleCheckTime :=
  static configInvisibleCpu :=
  static configBonusBoxShader :=
  static configDamageCheckTime :=
  static configReviveMode :=
  static configMoveMode :=
  static configPetActive :=


	isReady() {
		if (Client.init(this.configBonusBoxShader) and Minimap.init(this.configMap, this.configMoveMode) and Ship.init()) {
      if (this.configPetActive = 1) {
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
					bonusBoxCors := Client.findBonusBox()

					if (isObject(bonusBoxCors)) {
						OutputDebug, % "Bonus box find x: " bonusBoxCors[1] " y: " bonusBoxCors[2]

						if (Ship.isMoving()) {
							Ship.approach(bonusBoxCors)
							Sleep, 100

							this.setState("ApproachingToBonusBox")
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

				if (this.state = "ApproachingToBonusBox") {
					if (!Ship.isMoving()) {
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "CollectingBonusBox") {
					if (!Ship.isMoving()) {
            Sleep, 100
						this.bonusBoxCollected++
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
								this.setState("FindBonusBox")
                this.setCheckTimers()
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
                this.statePriority := 0
                this.setState("FindBonusBox")
                this.setCheckTimers()
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
						this.setState("FindBonusBox")
            this.setCheckTimers()
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
    SetTimer, disconnectCheck, off
    SetTimer, deadCheck, off
		bonusBox := this.bonusBoxCollected

		TrayTip, Aurora Stopped, Boxs Collected: %bonusBox%
	}

	setCheckTimers() {
		if (this.configInvisibleActive = 1) {
			SetTimer, invisibleCheck, % this.configInvisibleCheckTime
		}

		if (this.configEscapeActive = 1) {
			SetTimer, damageCheck, % this.configDamageCheckTime
		}

    if (this.configPetActive = 1) {
      SetTimer, petCheck, 10000
    }

    SetTimer, disconnectCheck, 5000
    SetTimer, deadCheck, 5000
    SetTimer, clientCheck, 60000

		return

		invisibleCheck:
			if (!Ship.isInvisible(System.configInvisibleCpu)) {
				Ship.setInvisible(System.configInvisibleCpu)
			}
		return

		damageCheck:
			shieldPercent := Ship.getShieldPercent()
			healPercent := Ship.getHealPercent()
      OutputDebug, % "DamageCheck heal: " healPercent " shield: " shieldPercent
			if (healPercent > 0) { ;La vida tiene que ser visible o correra cuando este en zona radioactiva
				if (shieldPercent < System.configEscapeShield) {
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
        reviveModeUsed := Ship.revive(System.configReviveMode)

        OutputDebug, % "Ship revived on: " reviveModeUsed

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
      if(Client.questsIsOpen) {
        Client.questsClose()
      }
    return
	}

	stopCheckTimers() {
		SetTimer, invisibleCheck, Off
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

}
