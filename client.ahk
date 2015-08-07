#Include, ./ship.ahk

class Client {
	static boxCors := {}
	static shipStatsBoxCors := {}
	static bonusBoxShader := 20
	static searchBoxsSize := [{}, {}, {}, {}]
	static corsSetted := false
	static minimapBoxCors := {}
	static minimapAvailableBoxCors := {}

	init() {
		if(!this.corsSetted) {
			this.setClientCors()
		}

		this.setSearchBoxsSize()
	}

	isReady() {
		if (this.setShipStatsBoxCors() and this.setMinimapCors()) {
			return true
		}
		else {
			return false
		}
	}

	setClientCors() {
		TrayTip, Configuracion, Colocar puntero sobre esquina SUPERIOR del juego y presionar Numpad8, 10000
		KeyWait, Numpad8, D


		MouseGetPos, corsX, corsY
		this.boxCors.x1 := 0
		this.boxCors.y1 := corsY

		TrayTip, Configuracion, Colocar puntero sobre esquina INFERIOR del juego y presionar Numpad2, 10000
		KeyWait, Numpad2, D

		MouseGetPos, corsX, corsY
		this.boxCors.x2 := A_ScreenWidth
		this.boxCors.y2 := corsY

		this.corsSetted := true
	}

	setSearchBoxsSize() {
		percentToIgnore := 0.10
		pixelsToIgnore := this.boxCors.y2 * percentToIgnore
		percentPosToIgnore := 0.60

		this.searchBoxsSize[1].x1 := this.boxCors.x1
		this.searchBoxsSize[1].y1 := this.boxCors.y1
		this.searchBoxsSize[1].x2 := this.boxCors.x2
		this.searchBoxsSize[1].y2 := this.boxCors.y2 * percentPosToIgnore

		this.searchBoxsSize[2].x1 := this.boxCors.x1
		this.searchBoxsSize[2].y1 := this.searchBoxsSize[1].y2 + pixelsToIgnore
		this.searchBoxsSize[2].x2 := this.boxCors.x2
		this.searchBoxsSize[2].y2 := this.boxCors.y2 

		this.searchBoxsSize[3].x1 := this.boxCors.x1
		this.searchBoxsSize[3].y1 := (this.boxCors.y2 * 0.40)
		this.searchBoxsSize[3].x2 := (this.boxCors.x2 * 0.50) - pixelsToIgnore
		this.searchBoxsSize[3].y2 := this.boxCors.y2 * 0.80

		this.searchBoxsSize[4].x1 := (this.boxCors.x2 * 0.50) + pixelsToIgnore
		this.searchBoxsSize[4].y1 := (this.boxCors.y2 * 0.40)
		this.searchBoxsSize[4].x2 := this.boxCors.x2
		this.searchBoxsSize[4].y2 := this.boxCors.y2 * 0.80
	}

	searchBonusBox() {
		shaderVariation := this.bonusBoxShader
		i := 1

		Loop, 4 {
			ImageSearch, corsX, corsY, this.searchBoxsSize[i].x1, this.searchBoxsSize[i].y1, this.searchBoxsSize[i].x2, this.searchBoxsSize[i].y2 , *%shaderVariation% ./img/bonus_box.bmp

			if (ErrorLevel = 0) {
				return [corsX, corsY]
			} 
			i++
		}

		return false
	}


	setShipStatsBoxCors() {

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/ship_stats_box.bmp

		If (ErrorLevel = 0) {
			this.shipStatsBoxCors.x1 := corsX
			this.shipStatsBoxCors.y1 := corsY
			this.shipStatsBoxCors.x2 := corsX + 190
			this.shipStatsBoxCors.y2 := corsY + 105

			return true
		} else {
			MsgBox, ERROR!, No se encuentra el estado de la nave

			return false
		}
	}

	reloadClient() {
		secondsWaiting := 0

		ImageSearch, corsX, corsY, 0, 0, A_ScreenWidth, A_ScreenHeight, *5 ./img/reload_firefox.bmp

		MouseClick, Left, corsX + 3, corsY + 3, 1, 40

		Sleep, 1000

		Loop { ;waiting connecting box
			if this.isConnecting() {
				break
			}
			else {
				Sleep, 1000
				secondsWaiting++

				if (secondsWaiting > 120) {
					break
				}
			} 

		}

		secondsWaiting := 0

		Loop { ;waiting connected
			if (this.isConnected()) {
				break
			}
			else {
				Sleep, 1000
				secondsWaiting++

				if (secondsWaiting > 10) {
					break
				}
			} 

		}

		if Not this.isConnected()
			this.reloadClient()

	}

	isConnected() {

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/minimap_box.bmp

		if (ErrorLevel = 0) {
			return true
		}
		else {
			ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/repair_button.bmp

			if (ErrorLevel = 0) {
				return true
			}
			else {
				return false
			}
		}


	}

	connect() {
		secondsWaiting := 0

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/disconnect.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY + 65, 1, 30
			
			Loop { ;waiting connected
				if (this.isConnected()) {
					break
				}
				else {
					Sleep, 1000
					secondsWaiting++

					if (secondsWaiting > 10) {
						break
					}
				} 
			}

			if Not this.isConnected()
				this.reloadClient()

		} else {
			this.reloadClient()
		}
	}

	isConnecting() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/connecting.bmp

		if (ErrorLevel = 0) {
			return true
		} else {
			return false
		}
	}

	setMinimapCors() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/minimap_box.bmp

		If (ErrorLevel = 0) {
			this.minimapBoxCors.x1 := corsX
			this.minimapBoxCors.y1 := corsY
			this.minimapBoxCors.x2 := corsX + 176
			this.minimapBoxCors.y2 := corsY + 190

			this.minimapAvailableBoxCors.x1 := corsX + 25
			this.minimapAvailableBoxCors.y1 := corsY + 49
			this.minimapAvailableBoxCors.x2 := corsX + 212
			this.minimapAvailableBoxCors.y2 := corsY + 163

			return true
		} else {
			MsgBox, ERROR!, No se ha encontrado el minimapa

			return false
		}
	}

}