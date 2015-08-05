#Include, ./client.ahk
#Include, ./minimap.ahk
#Include, ./ship.ahk

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

SYSTEM_HEAL_TO_REPAIR := 10
SYSTEM_COLLECT_BOXS := false
SYSTEM_BOX_COLLECTED := 0

TrayTip, Esperando comando, F1 - Iniciar Recollection `n F2 - Pausar Recollection

F1::
	SYSTEM_COLLECT_BOXS := true
	client := new Client()
	minimap := new Minimap()
	ship := new Ship()
	
	TrayTip, Recoleccion iniciada, F2 - Pausar Recoleccion

	Loop {
		if SYSTEM_COLLECT_BOXS {
			ship.checkHealPercent()

			if Not ship.isInvisible() {
				ship.setInvisible()
			}

			if (ship.healPercent > SYSTEM_HEAL_TO_REPAIR) { 
				if ship.isMoving() {
					bonus_box := Client.searchBonusBox()

					if bonus_box { ;Si consigue una caja se le acerca
						ship.approach(bonus_box)

						bonus_box := Client.searchBonusBox()

						if bonus_box {
							ship.collect(bonus_box)
							SYSTEM_BOX_COLLECTED++
						} else {
							ship.moveRandom()
						}
					}

				} else { ;Si no se mueve
					bonus_box := Client.searchBonusBox()

					if bonus_box {
						ship.collect(bonus_box)
						SYSTEM_BOX_COLLECTED++
					} else {
						ship.moveRandom()
					}
					
				}
			} else { ;Si no tiene vida suficiente
				ship.checkAlive()
				ship.checkConnectState()

				if Not ship.alive { ;si esta muerto
					ship.revive()
				}

				if Not ship.connected {
					ship.connect()
				}
			}
		} else { ;Si detienen el bot cerramos el ciclo
			break
		}
	}
return

F2::
	TrayTip, Recolecction Pausada! , Cajas Obtenidas:  %SYSTEM_BOX_COLLECTED%
	SYSTEM_COLLECT_BOXS := false
return
