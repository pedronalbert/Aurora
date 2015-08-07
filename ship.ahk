#Include, ./client.ahk
#Include, ./minimap.ahk

class Ship {
	static healPercent := 0
	static collectAttemps := 1
	static lastCollectCorsBox := {x1: 0, y1: 0, x2: 0, y2: 0}
	static healBarsShader := 15
	static statsBoxCors := {}

	;caching varis
	static cloackCors := {x: 0, y: 0}
	static hasCloacks := true

	__New() {
		this.setCloacks()
	}

	isReady() {
		if (this.setStatsBoxCors()) {
			return true
		} else {
			return false
		}
	}

	setStatsBoxCors() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/ship_stats_box.bmp

		If (ErrorLevel = 0) {
			this.statsBoxCors.x1 := corsX
			this.statsBoxCors.y1 := corsY
			this.statsBoxCors.x2 := corsX + 190
			this.statsBoxCors.y2 := corsY + 105

			return true
		} else {
			MsgBox , , ERROR!, No se encuentra el estado de la nave `n `n Reconfigure las coordenadas y abra el estado de la nave con barras visibles.

			return false
		}
	}

	getHealPercent() {
		this.healPercent := 0
		healBarCorsX := this.statsBoxCors.x1 + 27
		healBarCorsY := this.statsBoxCors.y1 + 46
		healBarsShader := this.healBarsShader
		healBarsColor := 0x7FD878
		healPercentPerBar := 4.761904761904762

		i := 0

		Loop, 21 {
			i++
			healBarCorsX := healBarCorsX + 3
			PixelSearch, barCorsX, barCorsY, healBarCorsX, healBarCorsY, healBarCorsX, healBarCorsY, healBarsColor, healBarsShader, Fast

			if ErrorLevel = 0
				this.healPercent := this.healPercent + healPercentPerBar
		}

		return this.healPercent
	}

	approach(cors) {
		miliSecondsWait := 0

		centerX := Client.boxCors.x2 / 2
		centerY := Client.boxCors.y2 / 2

		corsX := (centerX + cors[1]) / 2 ;punto medio
		corsY := (centerY + cors[2]) / 2 ;punto medio

		if(corsX > centerX) {
			diff := corsX - centerX

			if(diff < 170) {
				corsX := centerX + 170
			}
		} else {
			diff := centerX - corsX

			if(diff < 170) {
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

				if(miliSecondsWait > 3000) { ;si tiene tiempo esperando a que se aproxime es bug
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
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/repair_button.bmp

		if (ErrorLevel = 0) {
			return false
		} else {
			return true
		}

	}

	revive() {
		MouseMove, 0, 0 , 0
		
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/repair_portal.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX + 5, corsY + 5, 1, 15 ;click on repair portal

			Sleep, 1000

			ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/repair_button.bmp

			if (ErrorLevel = 0) {
				MouseClick, Left, corsX + 30, corsY + 5, 1, 15 ;click on repair button

				Sleep, 8000

				if Not this.isAlive()
					Client.reloadClient()
			}
		}
	}

	moveRandom() {
		Random, corsX, 40, 160

		Random, sector, 1, 5  ; top (1, 2), center(3), bot(4, 5)

		if (sector <= 2) {
			Random, corsY, 2, 12
		} else if (sector = 3) {
			Random, corsY, 20, 100
		} else if (sector >= 4) {
			Random, corsY, 116, 126
		}

		corsX := Minimap.availableBoxCors.x1 + (corsX * Minimap.pixelEquivalentX)
		corsY := Minimap.availableBoxCors.y1 + (corsY * Minimap.pixelEquivalentY)

		MouseClick, Left, corsX, corsY, 1, 0

		Sleep, 50
	}

	isMoving() {
		x := Minimap.boxCors.x1 + 114
		y := Minimap.boxCors.y1 + 37

		PixelGetColor, color, x, y

		if (color = "0xFFFFFF") {
			return true
		} else {
			return false
		}
	}

	setCloacks() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/cloack_10.bmp

		if (ErrorLevel = 0) {
			this.cloackCors.x := corsX
			this.cloackCors.y := corsY 
			this.hasCloacks := true 
		}
		else {
			this.hasCloacks := false
		}
	}

	isInvisible() {
		if (this.hasCloacks) {
			PixelGetColor, color, this.cloackCors.x - 2, this.cloackCors.y + 2

			if (color = "0x68B8C8") {
				return true
			} else {
				return false
			}
		} else {
			return true
		}
	}

	setInvisible()  {
		if (this.hasCloacks) {
			MouseClick, Left, this.cloackCors.x + 10, this.cloackCors.y + 10, 1, 5

			Sleep, 3000

			if (!this.isInvisible) {
				this.hasCloacks := false
			}
		}
	}

}
