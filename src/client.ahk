class Client {
  static windowCors := {}
  static searchAreas := [{}, {}, {}, {}]

  init() {
    if(this.setWindowCors() == false) {
      MsgBox, Error!, Darkorbit window not found!

      return false
    }

    this.setSearchAreas()
    windowsOpened := false

    ;Open Windows
    if (!this.shipStatsWindowIsOpened()) {
      if (!this.shipStatsWindowOpen()) {
        MsgBox, AuroraBot Error, Ship window not visible!
        return false
      } else {
        windowsOpened := true
      }
    }

    if (!this.minimapWindowIsOpened()) {
      if (!this.minimapWindowOpen()) {
        MsgBox, AuroraBot Error, Minimap window not visible!
        return false
      } else {
        windowsOpened := true
      }
    }

    if (this.questsWindowIsOpened()) {
      if (!this.questsWindowClose()) {
        MsgBox, AuroraBot Error, Quests window cant close
        return false
      } else {
        windowsOpened := true
      }
    }

    if (ConfigManager.petActive = true and this.petWindowIsOpened() = false) {
      if (!this.petWindowOpen()) {
        MsgBox, AuroraBot Error, Configure client coors
        return false
      } else {
        windowsOpened := true
      }
    }

    if(windowsOpened) {
      Sleep, 2000 ;wait for open complete
    }


    Minimap.init()
    Ship.init()

    if (ConfigManager.petActive) {
      Pet.init()
    }

    return true
  }

  setWindowCors() {
    ControlGetPos, posX, posY, width, height, GeckoFPSandboxChildWindow1, ahk_class MozillaWindowClass

    if(posY) {
      this.windowCors.x1 := posX
      this.windowCors.y1 := posY
      this.windowCors.x2 := this.windowCors.x1 + width
      this.windowCors.y2 := this.windowCors.y1 + height

      return true
    } else {
      return false
    }
  }

  setSearchAreas() {
		percentToIgnore := 0.06
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
      MouseClick, Left, corsX, corsY + 58, 1, ConfigManager.mouseSpeed
      MouseMove, 0, 0, ConfigManager.mouseSpeed

      ;Wait connected
      Loop {
        if (this.isConnected()) {
          return true
        } else {
          if (secondsWaiting > 15) {
            return false
          } else {
            Sleep, 1000
            secondsWaiting++
          }
        }
      }
    } else {
      return false
    }
  }

  reload() {
    secondsWaiting := 0
    ImageSearch, corsX, corsY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 ./img/reload_firefox.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX + 3, corsY + 3, 1, ConfigManager.mouseSpeed
      MouseMove, 0, 0, ConfigManager.mouseSpeed 

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
        if (this.isConnected() or this.isDead()) {
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

      Sleep, 1000
    } else {
      MsgBox, ERROR!, Reload button not found
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

  findEventBox() {
    eventBoxShader := ConfigManager.eventBoxShader
    i := 1

    Loop, 4 {
      ImageSearch, corsX, corsY, this.searchAreas[i].x1, this.searchAreas[i].y1, this.searchAreas[i].x2, this.searchAreas[i].y2 , *%eventBoxShader% ./img/client/event_box.bmp

      if (ErrorLevel = 0) {
        return [corsX, corsY]
      }
      i++
    }

    return false
  }

  findGreenBox() {
    bonusBoxShader := ConfigManager.greenBootyShader
    i := 1

    Loop, 4 {
      ImageSearch, corsX, corsY, this.searchAreas[i].x1, this.searchAreas[i].y1, this.searchAreas[i].x2, this.searchAreas[i].y2 , *%bonusBoxShader% ./img/client/green_box.bmp

      if (ErrorLevel = 0) {
        return [corsX, corsY]
      }
      i++
    }

    return false
  }

  questsWindowIsOpened() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/quests_button_opened.bmp

    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  questsWindowClose() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/quests_button_opened.bmp

    if (ErrorLevel = 0) {
      MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }

  shipStatsWindowIsOpened() {
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
      MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }

  getShipStatsWindowCors() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/ship_stats_window.bmp

    if (ErrorLevel = 0) {
      return [corsX, corsY]
    }
  }

  minimapWindowIsOpened() {
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
      MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }

  getMinimapWindowCors() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/minimap_window.bmp

    if (ErrorLevel = 0) {
      return [corsX, corsY]
    }
  }

  petWindowIsOpened() {
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
      MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }

  getPetWindowCors() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/client/pet_window.bmp

    if (ErrorLevel = 0) {
      return [corsX, corsY]
    }
  }

  takeScreenshot() {
    raster:=0x40000000 + 0x00CC0020
    screen=0|0|%A_ScreenWidth%|%A_ScreenHeight%
    outfile := A_ScriptDir "\screenshots\" A_Now ".bmp"
    pToken := Gdip_Startup()

    pBitmap := Gdip_BitmapFromScreen(screen, raster)

    Gdip_SaveBitmapToFile(pBitmap, outfile, 50)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
  }
}