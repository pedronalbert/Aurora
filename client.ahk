#Include, ./ship.ahk

class Client {
	static boxCors := {}
	static searchBoxsSize := [{}, {}, {}, {}]

	init() {
		return true
	}

	setCors(top := 0, bottom := 0) {
		this.boxCors.x1 := 0
		this.boxCors.y1 := top

		this.boxCors.x2 := A_ScreenWidth
		this.boxCors.y2 := bottom
		
		this.setSearchBoxsSize()
	}

	/*
		Get cloack cors
		@param {Number} type - 10 | 50
	*/
	getCloackCors() {
		type := System.invisibleCpu
		
		ImageSearch, x, y, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, % "*5 ./img/cloack_" type ".bmp"

		if (ErrorLevel = 0) {
			return [x, y]
		} else {

			return false
		}
	}

	reload() {
		secondsWaiting := 0

		ImageSearch, corsX, corsY, 0, 0, A_ScreenWidth, A_ScreenHeight, *5 ./img/reload_firefox.bmp

		MouseClick, Left, corsX + 3, corsY + 3, 1, 40

		Sleep, 1000

		Loop { ;waiting connecting message
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
			if (this.isConnected()) {
				return true
			} else if (Ship.isDead()) {
				Ship.revive()
			}
			else {
				Sleep, 1000
				secondsWaiting++

				if (secondsWaiting > 10) {
					this.reload()
				}
			} 
		}
	}

	isConnected() {
		if (this.isDisconnect()) {
			return false
		} else { ;the may seem connect because the disconnect box doesn't appear but need to validate with the minimap
			ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/minimap_box.bmp

			if (ErrorLevel = 0) {
				return true
			}
			else {
				return false
			}	
		}
	}

	isDisconnect() {
		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/disconnect.bmp

		if (ErrorLevel = 0) {
			return true
		}
		else {
			return false
		}
	}

	connect() {
		secondsWaiting := 0

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *5 ./img/disconnect.bmp

		if (ErrorLevel = 0) {
			MouseClick, Left, corsX, corsY + 65, 1, 30
			
			Loop { ;waiting connected
				if (this.isConnected()) {
					return true
				}
				else {
					Sleep, 1000
					secondsWaiting++

					if (secondsWaiting > 10) {
						this.reload()
					}
				} 
			}
		} else {
			this.reload()
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
		TrayTip, Set Client coors, Put the cursor on the TOP of the game and press F3
		KeyWait, F3, D


		MouseGetPos, corsX, corsY
		this.boxCors.x1 := 0
		this.boxCors.y1 := corsY

		TrayTip, Set Client coors, Put the cursor on the BOTTOM of the game and press F4
		KeyWait, F4, D

		MouseGetPos, corsX, corsY
		this.boxCors.x2 := A_ScreenWidth
		this.boxCors.y2 := corsY

		TrayTip, Client coors setted successfully
	}

}