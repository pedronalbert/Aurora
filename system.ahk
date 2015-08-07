#Include, ./client.ahk
#Include, ./ship.ahk
#Include, ./minimap.ahk

class System {
	static healToRepair := 50
	static bonusBoxShader := 20
	static bonusBoxCollected := 0
	static collectBoxs := false
	static map := 0

	isReady() {
		if (Client.isReady() and Minimap.isReady() and Ship.isReady()) {
			return true
		} else {
			return false
		}
	}

	initCollect() {
		this.escapeToPortal()
		
		this.collectBoxs := true

		TrayTip, Recoleccion iniciada, F2 - Pausar Recoleccion

		ship := new Ship()

		Loop {
			if this.collectBoxs {
				healPercent := ship.getHealPercent()

				if Not ship.isInvisible() {
					ship.setInvisible()
				}

				If Client.isDisconnect() { ;Disconnect screen
					Client.connect()
				}

				if (healPercent > this.healToRepair) { 
					if ship.isMoving() {
						bonus_box := this.findBonusBox()

						if bonus_box { ;Si consigue una caja se le acerca
							ship.approach(bonus_box)

							bonus_box := this.findBonusBox()

							if bonus_box {
								ship.collect(bonus_box)
								this.bonusBoxCollected++
							} else {
								ship.moveRandom()
							}
						}

					} else { ;Si no se mueve
						bonus_box := this.findBonusBox()

						if bonus_box {
							ship.collect(bonus_box)
							this.bonusBoxCollected++
						} else {
							ship.moveRandom()
						}
						
					}
				} else { ;Si no tiene vida suficiente
					if (healPercent = 0) { ;si no se ve la vida
						ship.moveRandom() ;lo sacamos de la zona radioactiva
						Sleep, 3000

						if (ship.getHealPercent = 0) {
							Sleep, 2000 ;damos un tiempo por si se esta muriendo

							if (!ship.isAlive()) {
								ship.revive()
							}		
						}
					} else {
						;TODO go to repair
					}
				}
			} else { ;Si detienen el bot cerramos el ciclo
				break
			}
		}
	}

	pauseCollect() {
		this.collectBoxs := false
		boxCollected := this.bonusBoxCollected

		TrayTip, Recoleccion pausada, Cajas obtenidas: %boxCollected%
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

	escapeToPortal() {
		this.collectBoxs := false

		portalCors := Minimap.getNearPortalCors()

		Minimap.goTo(portalCors)
		ExitApp
	}
}