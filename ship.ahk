#Include, ./minimap.ahk
#Include, ./client.ahk

class Ship {
	statsBox := {} 
	healPercent := 0
	collectAttemps := 1
	connected := false
	static lastCollectCorsBox := {x1: 0, y1: 0, x2: 0, y2: 0}
	static minimapAvailableCors := {}
	static minimapBoxCors := {}

	__New() {
		this.getHealPercent()
		this.checkConnectState()
	}

	getHealPercent() {
		this.healPercent := 0
		healBarCorsX := Client.shipStatsBoxCors.x1 + 27
		healBarCorsY := Client.shipStatsBoxCors.y1 + 46
		i := 0

		Loop, 21 {
			i++
			healBarCorsX := healBarCorsX + 3
			PixelSearch, barCorsX, barCorsY, healBarCorsX, healBarCorsY, healBarCorsX, healBarCorsY, 0x7FD878, 50, Fast

			if ErrorLevel = 0
				this.healPercent := this.healPercent + 4.761904761904762
		}

		return this.healPercent
	}

	approach(cors) {
		miliSecondsWait := 0
		centerX := Client.boxCors.x2 / 2
		centerY := Client.boxCors.y2 / 2

		corsX := (centerX + cors[1]) / 2
		corsY := (centerY + cors[2]) / 2

		if(corsX > centerX) {
			diferencia := corsX - centerX

			if(diferencia < 170) {
				corsX := centerX + 170
			}
		} else {
			diferencia := centerX - corsX

			if(diferencia < 170) {
				corsX := centerX - 170
			}
		}

		MouseClick, Left, corsX, corsY, 1, 0

		Sleep, 200

		Loop {
			Sleep, 100

			if Not this.isMoving() {
				break
			} else {
				miliSecondsWait += 100

				if(miliSecondsWait > 3000) {
					MouseClick, Left, (Client.boxCors.x2 / 2) - 50, Client.boxCors.y2 / 2, 1, 0
					break
				}
			}

		}
	}

	setLastCollectCorsBox(cors) {
		this.lastCollectCorsBox.x1 := cors[1] - 5
		this.lastCollectCorsBox.y1 := cors[2] - 5
		this.lastCollectCorsBox.x2 := cors[1] + 5
		this.lastCollectCorsBox.y2 := cors[2] + 5
	}

	isNearLastCollect(cors) {
		if ((cors[1] >= this.lastCollectCorsBox.x1) and (cors[1] <= this.lastCollectCorsBox.x2)) {
			if ((cors[2] >= this.lastCollectCorsBox.y1) and (cors[2] <= this.lastCollectCorsBox.y2)) {
				return true
			}
		}

		return false
	}

	collect(cors) {
		miliSecondsWait := 0

		if (this.isNearLastCollect(cors)) {
			this.collectAttemps++

			if (this.collectAttemps > 4) {
				this.goAway()
			} else {
				Sleep, 500
			}
		} else {
			this.collectAttemps := 1

			MouseClick, Left, cors[1] + 5, cors[2] + 5, 1, 0

			this.setLastCollectCorsBox(cors)

			Sleep, 100

			Loop { ;esperamos hasta que se quede quieto
				Sleep, 100
				
				if Not this.isMoving() {
					break
				} else {
					miliSecondsWait += 100

					if (miliSecondsWait > 7000) {
						this.goAway()
						break
					} 
				}
			}

			Sleep, 250 ;Time to disappear the box
		}
	}

	goAway() {
		this.moveRandom()
		Sleep, 3000
	}

	isAlive() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *15 ./img/repair_button.bmp

		if (ErrorLevel = 0) {
			return false
		} else {
			return true
		}

	}

	revive() {
		Random, randomTime, 2000, 5000

		Sleep, randomTime

		MouseMove, 50, 50 , 15
		
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *15 ./img/repair_portal.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX + 5, corsY + 5, 1, 50 ;click on repair portal

			Sleep, 1000

			ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *15 ./img/repair_button.bmp

			if (ErrorLevel = 0) {
				MouseClick, Left, corsX + 30, corsY + 5, 1, 50 ;click on repair button

				Sleep, 8000

				if Not this.isAlive()
					Client.reloadClient()
			}
		}
	}

	moveRandom() {
		pixelEquivalent := 0.8984375
		Random, corsX, 40, 160

		Random, sector, 1, 5  ; top (1, 2), center(3), bot(4, 5)

		if (sector <= 2) {
			Random, corsY, 2, 12
		} else if (sector = 3) {
			Random, corsY, 20, 100
		} else if (sector >= 4) {
			Random, corsY, 116, 126
		}

		corsX := Minimap.availableCors.x1 + (corsX * pixelEquivalent)
		corsY := Minimap.availableCors.y1 + (corsY * pixelEquivalent)

		MouseClick, Left, corsX, corsY, 1, 0

		Sleep, 200
	}

	isMoving() {
		x1 := Minimap.boxCors.x1 + 106
		x2 := Minimap.boxCors.x1 + 145
		y1 := Minimap.boxCors.y1 + 31
		y2 := Minimap.boxCors.y1 + 43

		PixelSearch, corsX, corsY, x1, y1, x2, y2, 0xFFFFFF, 20, Fast

		if (ErrorLevel = 0) {
			return true
		}
		else {
			return false
		}
	}


	isConnecting() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *15 ./img/connecting.bmp

		if (ErrorLevel = 0) {
			return true
		} else {
			return false
		}
	}

	getCloackCors() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *15 ./img/cloack_10.bmp

		if (ErrorLevel = 0) {
			return [corsX, corsY]
		}
		else {
			return false
		}
	}

	isInvisible() {
		cloackCors := this.getCloackCors()

		if cloackCors {
			PixelGetColor, color, cloackCors[1] - 2, cloackCors[2] + 2

			if (color = "0x68B8C8") {
				return true
			} else {
				return false
			}
		} else {
			return true ; devolvemos true si no hay cloacks
		}
	}

	setInvisible()  {
		cloackCors := this.getCloackCors()

		if (cloackCors) {
			MouseClick, Left, cloackCors[1] + 10, cloackCors[2] + 10, 1, 5

			Sleep, 2000
		}
	}
}