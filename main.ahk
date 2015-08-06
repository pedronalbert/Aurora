#SingleInstance, Force

#Include, ./client.ahk
#Include, ./minimap.ahk
#Include, ./ship.ahk


CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

SYSTEM_HEAL_TO_REPAIR := 10
SYSTEM_COLLECT_BOXS := false
SYSTEM_BOX_COLLECTED := 0


client := new Client()
minimap := new Minimap()
ship := new Ship()

TrayTip, Configuracion Lista, F1 - Iniciar Recollection `n F2 - Pausar Recollection

F1::
	SYSTEM_COLLECT_BOXS := true
	
	TrayTip, Recoleccion iniciada, F2 - Pausar Recoleccion

	Loop {
		if SYSTEM_COLLECT_BOXS {
			healPercent := ship.getHealPercent()

			if Not ship.isInvisible() {
				ship.setInvisible()
			}

			if (healPercent > SYSTEM_HEAL_TO_REPAIR) { 
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
				if Not (Client.isConnected()) {
					Ship.goAway() ;Si esta en zona radioactiva lo alejamos para asegurar que si esta disconnect

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
return

F2::
	TrayTip, Recolecction Pausada! , Cajas Obtenidas:  %SYSTEM_BOX_COLLECTED%
	SYSTEM_COLLECT_BOXS := false
return
