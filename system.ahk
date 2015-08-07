#Include, ./client.ahk
#Include, ./ship.ahk

class System {
	static healToRepair := 50
	static bonusBoxCollected := 0
	static collectBoxs := false

	initCollect() {
		this.collectBoxs := true

		TrayTip, Recoleccion iniciada, F2 - Pausar Recoleccion

		ship := new Ship()

		Loop {
			if this.collectBoxs {
				healPercent := ship.getHealPercent()

				if Not ship.isInvisible() {
					ship.setInvisible()
				}

				if (healPercent > this.healToRepair) { 
					if ship.isMoving() {
						bonus_box := Client.searchBonusBox()

						if bonus_box { ;Si consigue una caja se le acerca
							ship.approach(bonus_box)

							bonus_box := Client.searchBonusBox()

							if bonus_box {
								ship.collect(bonus_box)
								this.bonusBoxCollected++
							} else {
								ship.moveRandom()
							}
						}

					} else { ;Si no se mueve
						bonus_box := Client.searchBonusBox()

						if bonus_box {
							ship.collect(bonus_box)
							this.bonusBoxCollected++
						} else {
							ship.moveRandom()
						}
						
					}
				} else { ;Si no tiene vida suficiente
					if Not (Client.isConnected()) {
						ship.goAway() ;Si esta en zona radioactiva lo alejamos para asegurar que si esta disconnect

						if Not (Client.isConnected()) {
							Client.connect()
						}
						
					} else {
						if Not ship.isAlive(){ ;si esta muerto
							ship.revive()
						}
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
}