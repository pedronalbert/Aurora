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
	static bonusBoxShader := 
	static damageCheckTime :=
	static map := 


	isReady() {
		if (Client.isReady() and Minimap.isReady() and Ship.isReady()) {
			return true
		} else {
			return false
		}
	}

	initCollect() {
		TrayTip, Recoleccion iniciada, F2 - Pausar Recoleccion

		Ship.getHealPercent() ;update class property
		Ship.getShieldPercent() ;update class property

		this.statePriority := 0
		this.setState("FindBonusBox")
		this.setCheckTimers()

		Loop {
			if (this.state <> "Pause") {

				healPercent := Ship.getHealPercent()
				shieldPercent := Ship.getShieldPercent()

				If Client.isDisconnect() { ;Disconnect screen
					Client.connect()
				}

				if (healPercent = 0) { ;Si no se le ve la vida
					Ship.moveRandom() ;Get out radioactive zone

					Sleep, 3000

					if (Ship.getHealPercent() = 0) { ;reget the heal
						;Si la vida sigue siendo 0 le damos un tiempo por si se esta muriendo
						Sleep, 2000

						if (!Ship.isAlive()) {
							this.stopCheckTimers()
							Ship.revive()
							this.setState("WaitForFinishRepairAndSetTimers")
						}
					}

				}

				; ------------------------ STATES -------------------------------------

				if (this.state = "FindBonusBox") {
					bonusBox := this.findBonusBox()

					if (isObject(bonusBox)) {
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
							Ship.moveRandom()
							Sleep, 100
						}
					}
				}

				if (this.state = "ApproachingToBonusBox") {
					if (!Ship.isMoving()) {
						this.setState("FindBonusBox")
					} else {
						if (this.stateSeconds > 3) {
							this.setState("FindBonusBox")
						}
					}
				}

				if (this.state = "CollectingBonusBox") {
					if (!Ship.isMoving()) {
						this.bonusBoxCollected++
						Sleep, 100
						this.setState("FindBonusBox")
					} else {
						if (this.stateSeconds > 3) {
							this.setState("FindBonusBox")
						}
					}
				}

				if (this.state = "WaitForFinishRepair") {
					if (healPercent >= this.healToRepair and shieldPercent >= this.escapeShield) {
						this.setState("FindBonusBox")
					}
				}

				if (this.state = "GoToPortalForJump", 1) {
					if (!Ship.isMoving()) {
						this.lastShipCors := Minimap.getShipCors()
						Sleep, 1000
						Send {j}

						this.setState("JumpingPortal", 1)
					}
				}

				if (this.state ="JumpingPortal") {
					;Bug esperando salto
					
					if (this.isInNewMap()) {
						this.lastShipCors := Minimap.getShipCors()
						Sleep, 1000
						Send {j}
						this.setState("ComingToMap", 1)
					}
				}

				if (this.state = "ComingToMap") {
					if (this.isInNewMap()) {
						this.setState("WaitForFinishRepairAndSetTimers", 1)
					}
				}

				if (this.state = "WaitForFinishRepairAndSetTimers") {
					if (healPercent >= this.healToRepair and shieldPercent >= this.escapeShield) {
						this.statePriority := 0
						this.setCheckTimers()
						this.setState("FindBonusBox")
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

		TrayTip, Recoleccion pausada, Cajas obtenidas: %bonusBox%
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
			;TrayTip, State, %state% Priority: %priority%

			SetTimer, stateTimer, 1000

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

		this.setState("GoToPortalForJump", 1)
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
