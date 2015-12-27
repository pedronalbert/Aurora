class Client {
	static boxCors := {}
	static searchBoxsSize := [{}, {}, {}, {}]
	static configBonusBoxShader

	init(bonusBoxShader) {
		this.configBonusBoxShader := bonusBoxShader
		
		return true
	}

	reload() {
		OutputDebug, % "Client reload"
		secondsWaiting := 0

		ImageSearch, corsX, corsY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 ./img/reload_firefox.bmp

		MouseClick, Left, corsX + 3, corsY + 3, 1, 25

		Sleep, 1000

		Loop { ;waiting connecting message
			OutputDebug, % "Waiting for connecting"
			if (this.isConnecting()) {
				break
			}
			else {
				Sleep, 1000
				secondsWaiting++

				if (secondsWaiting > 120) {
					this.reload()
				}
			}
		}

		secondsWaiting := 0

		Loop { ;waiting connected or dead
			OutputDebug, % "Waiting for connected or dead"
			if (this.isConnected()) {
				return true
			} else if (Ship.isDead()) {
				return true
			}
			else {
				Sleep, 1000
				secondsWaiting++

				if (secondsWaiting > 30) {
					this.reload()
				}
			}
		}
	}

	connect() {
	    OutputDebug, % "Client connect"
		secondsWaiting := 0

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/disconnect.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY + 65, 1, 30

			Loop { ;waiting connected
				OutputDebug, % "Waiting for connected"
				if (this.isConnected()) {
					return true
				}
				else {
					Sleep, 1000
					secondsWaiting++

					if (secondsWaiting > 30) {
						this.reload()
					}
				}
			}
		} else {
			this.reload()
		}
	}

	isConnected() {
		if (this.isDisconnect()) {
			return false
		} else {
		;validate with minimap
			ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/minimap_box.bmp

			if (ErrorLevel = 0) {
				OutputDebug, % "Client is connected because minimap is visible"
				return true
			}
			else {
				OutputDebug, % "Client is disconnect because minimap is not visible"
				return false
			}
		}
	}

	isDisconnect() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/disconnect.bmp

		if (ErrorLevel = 0) {
			OutputDebug, % "Client is disconnect"
			return true
		}
		else {
			OutputDebug, % "Clien is not disconnect"
			return false
		}
	}

	isConnecting() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/connecting.bmp

		if (ErrorLevel = 0) {
			OutputDebug, % "Client is connecting"
			return true
		} else {
			OutputDebug, % "Client is not connecting"
			return false
		}
	}

	setCors(top := 0, bottom := 0) {
		this.boxCors.x1 := 0
		this.boxCors.y1 := top
		this.boxCors.x2 := A_ScreenWidth
		this.boxCors.y2 := bottom
		this.setSearchBoxsSize()
	}

	getCloackCors(invisibleCpu) {
		ImageSearch, x, y, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, % "*10 ./img/cloack_" invisibleCpu ".bmp"

		if (ErrorLevel = 0) {
			OutputDebug, % "Cloack CPU " invisibleCpu " found"
			return [x, y]
		} else {
			OutputDebug, % "ERROR! Cloack CPU " invisibleCpu " is not found"
			return false
		}
	}

	setSearchBoxsSize() {
		percentToIgnore := 0.08
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

	openCorsSetter() {
		TrayTip, Set Client coors, Put the cursor on the TOP of the game and press F6
		KeyWait, F6, D


		MouseGetPos, corsX, corsY
		this.boxCors.x1 := 0
		this.boxCors.y1 := corsY

		TrayTip, Set Client coors, Put the cursor on the BOTTOM of the game and press F7
		KeyWait, F7, D

		MouseGetPos, corsX, corsY
		this.boxCors.x2 := A_ScreenWidth
		this.boxCors.y2 := corsY

		TrayTip, Client coors setted successfully
	}

	findBonusBox() {
		bonusBoxShader := this.configBonusBoxShader
		i := 1

		Loop, 4 {
			ImageSearch, corsX, corsY, Client.searchBoxsSize[i].x1, Client.searchBoxsSize[i].y1, this.searchBoxsSize[i].x2, this.searchBoxsSize[i].y2 , *%bonusBoxShader% ./img/bonus_box.bmp

			if (ErrorLevel = 0) {
				return [corsX, corsY]
			}
			i++
		}

		return false
	}

	questsIsOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/quests_button_open.bmp

		if (ErrorLevel = 0) {
			return true
		} else {
			return false
		}
	}

	questsClose() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/quests_button_open.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY, 1, 0
		}
	}

	shipStatsWindowIsOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/ship_stats_window.bmp
		
		if (ErrorLevel = 0) {
			return true
		} else {
			return false
		}
	}

	shipStatsWindowOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/ship_stats_button.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY, 1, 0
		}
	}

	getShipStatsWindowCors() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/ship_stats_window.bmp

		if (ErrorLevel = 0) {
			return [corsX, corsY]
		}
	}

	minimapWindowIsOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/minimap_window.bmp
		
		if (ErrorLevel = 0) {
			return true
		} else {
			return false
		}
	}

	minimapWindowOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/minimap_button.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY, 1, 0
		}
	}

	getMinimapWindowCors() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/minimap_window.bmp

		if (ErrorLevel = 0) {
			return [corsX, corsY]
		}
	}

	petWindowIsOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/pet_window.bmp
		
		if (ErrorLevel = 0) {
			return true
		} else {
			return false
		}
	}

	petWindowOpen() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/pet_button.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY, 1, 0
		}
	}

	getPetWindowCors() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *10 ./img/client/pet_window.bmp

		if (ErrorLevel = 0) {
			return [corsX, corsY]
		}
	}


}