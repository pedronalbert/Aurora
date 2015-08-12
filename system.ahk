#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./minimap.ahk
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


	isReady() {
		if (Client.init() and Minimap.init() and Ship.init()) {
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
				Ship.updateStats()

				if (Client.isDisconnect()) { ;Disconnect screen
					Client.connect()
				}

				if (Ship.isDead()) {
					this.stopCheckTimers()
					reviveModeUsed := Ship.revive(this.reviveMode)
					
					if (reviveModeUsed = "BASE") {
						this.setState("FinishRepair_Next_GenerateRoute", 1)
					} else {
						this.setState("FinishRepair_Next_FindBonusBox_SetTimers", 1)
					}
				}
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
							Sleep, 100
							this.setState("CollectingBonusBox")
						}
					} else {
						if (!Ship.isMoving()) {
							Minimap.moveRandom()
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
						Sleep, 100
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "GoToPortalForEscape") {
					if (!Ship.isMoving()) {
						this.lastShipCors := Minimap.getShipCors()
						Sleep, 1000
						Send {j}

						this.setState("EscapingToPortal_Next_BackToMap", 1)
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
					if (Ship.healPercent >= this.healToRepair and Ship.shieldPercent >= this.escapeShield) {
						this.statePriority := 0
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "FinishRepair_Next_FindBonusBox_SetTimers") {
					if (Ship.healPercent >= this.healToRepair and Ship.shieldPercent >= this.escapeShield) {
						this.setCheckTimers()
						this.statePriority := 0
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "FinishRepair_Next_GenerateRoute" ) {
					if (Ship.healPercent >= this.healToRepair and Ship.shieldPercent >= this.escapeShield) {
						this.setCheckTimers()
						Minimap.generateRoute()
						this.setState("GoToNextPortal", 1)
					}
				}

				if (this.state = "GoToNextPortal") {
					if (Minimap.goToNextPortal()) {
						Sleep, 200
						this.setState("WaitForNextPortal_Next_JumpToNewMap", 1)
					} else {
						this.statePriority := 0
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
		this.setState("Pause", 1)
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

		return

		invisibleCheck:
			if (!Ship.isInvisible()) {
				Ship.setInvisible()
			}
		return

		damageCheck:
			shieldPercent := Ship.shieldPercent
			healPercent := Ship.healPercent

			if (healPercent > 0) { ;no puede estar muerto
				if (shieldPercent < System.escapeShield) {
						System.escapeToPortal()
				}
			}
		return
	}

	stopCheckTimers() {
		SetTimer, invisibleCheck, Off
		SetTimer, damageCheck, Off
	}

	setState(state, priority := 0) {
		if (priority >= this.statePriority) {
			this.state := state
			this.stateSeconds := -1
			OutputDebug, % "State: " state " Priority: " priority

			SetTimer, stateTimer, 1000

			return 

			stateTimer:
				System.stateSeconds += 1
			return
		}
	}

	escapeToPortal() {
		this.stopCheckTimers()

		portalCors := Minimap.getNearPortalCors()

		Minimap.goTo(portalCors)

		Sleep, 100

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
