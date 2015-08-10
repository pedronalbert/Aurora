#Include, ./client.ahk
#Include, ./minimap.ahk

class Ship {
	static healPercent := 
	static shieldPercent :=
	static healBarsShader := 15
	static shieldBarsShader := 15
	static statsBoxCors := {}

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

	getShieldPercent() {
		this.shieldPercent := 0
		shieldBarsCorsX := this.statsBoxCors.x1 + 27
		shieldBarsCorsY := this.statsBoxCors.y1 + 63
		shieldBarsShader := this.shieldBarsShader
		shieldBarsColor := 0xD8D378
		shieldPercentBar := 4.761904761904762

		i := 0

		Loop, 21 {
			i++
			shieldBarsCorsX := shieldBarsCorsX + 3

			PixelSearch, barCorsX, barCorsY, shieldBarsCorsX, shieldBarsCorsY, shieldBarsCorsX, shieldBarsCorsY, shieldBarsColor, shieldBarsShader, Fast
			
			if ErrorLevel = 0
				this.shieldPercent := this.shieldPercent + shieldPercentBar
		}

		return this.shieldPercent
	}

	approach(cors) {
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
	}

	collect(cors) {
		MouseClick, Left, cors[1] + 3, cors[2] + 3, 1, 0
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

		cors := [corsX, corsY]

		Minimap.goTo(cors)
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

	getCloackCors() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/cloack_10.bmp

		if (ErrorLevel = 0) {
			return [corsX, corsY]
		} else {
			return false
		}
	}

	isInvisible() {
		cloackCors := this.getCloackCors()

		corsX := cloackCors[1]
		corsY := cloackCors[2]

		if (cloackCors) {
			PixelGetColor, color, corsX - 2, corsY + 2

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
		cloackCors := this.getCloackCors()

		corsX := cloackCors[1]
		corsY := cloackCors[2]

		if (cloackCors) {
			MouseClick, Left, corsX + 10, corsY + 10, 1, 5
		}
	}

}
