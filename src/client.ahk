class Client {
  static windowCors := {}
  static searchAreas := [{}, {}, {}, {}]


  init() {
    this.setWindowCors(ConfigManager.clientWindowCors.y1, ConfigManager.clientWindowCors.y2)
    this.setSearchAreas()

    if (this.questsWindowIsOpen()) {
      this.questsWindowClose()
    }

    return true
  }

  setWindowCors(y1, y2) {
    this.windowCors.x1 := 0
    this.windowCors.y1 := y1
    this.windowCors.x2 := A_ScreenWidth
    this.windowCors.y2 := y2
  }

  setSearchAreas() {
		percentToIgnore := 0.08
		pixelsToIgnore := this.windowCors.y2 * percentToIgnore
		percentPosToIgnore := 0.61

		this.searchAreas[1].x1 := this.windowCors.x1
		this.searchAreas[1].y1 := this.windowCors.y1
		this.searchAreas[1].x2 := this.windowCors.x2
		this.searchAreas[1].y2 := this.windowCors.y2 * percentPosToIgnore - pixelsToIgnore

		this.searchAreas[2].x1 := this.windowCors.x1
		this.searchAreas[2].y1 := this.searchAreas[1].y2 + (pixelsToIgnore * 2)
		this.searchAreas[2].x2 := this.windowCors.x2
		this.searchAreas[2].y2 := this.windowCors.y2

		this.searchAreas[3].x1 := this.windowCors.x1
		this.searchAreas[3].y1 := (this.windowCors.y2 * 0.40)
		this.searchAreas[3].x2 := (this.windowCors.x2 * 0.50) - pixelsToIgnore
		this.searchAreas[3].y2 := this.windowCors.y2 * 0.80

		this.searchAreas[4].x1 := (this.windowCors.x2 * 0.50) + pixelsToIgnore
		this.searchAreas[4].y1 := (this.windowCors.y2 * 0.40)
		this.searchAreas[4].x2 := this.windowCors.x2
		this.searchAreas[4].y2 := this.windowCors.y2 * 0.80
	}

  connect() {
    secondsWaiting := 0

    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/disconnect.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX, corsY + 58, 1, 0
      MouseMove, 0, 0, 0

      ;Wait connected
      Loop {
        if (this.isConnected()) {
          return true
        } else {
          if (secondsWaiting > 15) {
            this.reload()
          } else {
            Sleep, 1000
            secondsWaiting++
          }
        }
      }
    } else {
      this.reload()
    }
  }

  reload() {
    secondsWaiting := 0

    ImageSearch, corsX, corsY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 ./img/reload_firefox.bmp

    MouseClick, Left, corsX + 3, corsY + 3, 1, 0

    ;Wait loading
    Loop {
      if (this.isLoading()) {
        break
      } else {
        if (secondsWaiting > 30) {
          this.reload()
        } else {
          Sleep, 1000
          secondsWaiting++
        }
      }
    }

    secondsWaiting := 0

    ;Wait connecting appear
    Loop {
      if (this.isConnecting()) {
        break
      } else {
        if (secondsWaiting > 120) {
          this.reload()
        } else {
          Sleep, 1000
          secondsWaiting++
        }
      }
    }

    secondsWaiting := 0

    ;Wait connected
    Loop {
      if (this.isConnected()) {
        break
      } else {
        if (secondsWaiting > 15) {
          this.reload()
        } else {
          Sleep, 1000
          secondsWaiting++
        }
      }
    }
  }
  
  isConnected() {
    if (this.isDisconnect()) {
      return false
    } else {
      ;Si no esta desconectado necesitamos validar que el minimapa está visible
      ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/minimap_window.bmp

      if (ErrorLevel = 0) {
        return true
      }
      else {
        return false
      }
    }
  }

  isDisconnect() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/disconnect.bmp

    if (ErrorLevel = 0) {
      return true
    }
    else {
      return false
    }
  }

  isLoading() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/loading.bmp

    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isConnecting() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/connecting.bmp

    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  getCloackCors(cpuType) {
    ImageSearch, x, y, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, % "*10 ./img/cloack_" cpuType ".bmp"

    if (ErrorLevel = 0) {
      return [x, y]
    } else {
      return false
    }
  }

  getWindowCorsFromUser() {
    y1 :=
    y2 :=

    TrayTip, Set Client coors, Put the cursor on the TOP of the game and press F6
    KeyWait, F6, D


    MouseGetPos, corsX, corsY
    y1 := corsY

    TrayTip, Set Client coors, Put the cursor on the BOTTOM of the game and press F7
    KeyWait, F7, D

    MouseGetPos, corsX, corsY
    y2 := corsY

    return [y1, y2]
  }

  findBonusBox() {
  	bonusBoxShader := ConfigManager.bonusBoxShader
		i := 1

		Loop, 4 {
			ImageSearch, corsX, corsY, this.searchAreas[i].x1, this.searchAreas[i].y1, this.searchAreas[i].x2, this.searchAreas[i].y2 , *%bonusBoxShader% ./img/client/bonus_box.bmp

			if (ErrorLevel = 0) {
				return [corsX, corsY]
			}
			i++
		}

		return false
  }

  questsWindowIsOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/quests_button_open.bmp

    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  questsWindowClose() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/quests_button_open.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX, corsY, 1, 0
    }
  }

  shipStatsWindowIsOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/ship_stats_window.bmp
    
    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  shipStatsWindowOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/ship_stats_button.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX, corsY, 1, 0
    }
  }

  getShipStatsWindowCors() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/ship_stats_window.bmp

    if (ErrorLevel = 0) {
      return [corsX, corsY]
    }
  }

  minimapWindowIsOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/minimap_window.bmp
    
    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  minimapWindowOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/minimap_button.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX, corsY, 1, 0
    }
  }

  getMinimapWindowCors() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/minimap_window.bmp

    if (ErrorLevel = 0) {
      return [corsX, corsY]
    }
  }

  petWindowIsOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/pet_window.bmp
    
    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  petWindowOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/pet_button.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX, corsY, 1, 0
    }
  }

  getPetWindowCors() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/pet_window.bmp

    if (ErrorLevel = 0) {
      return [corsX, corsY]
    }
  }
}