class Pet {

  static windowCors := {}

  init() {
    this.setWindowCors()
  }

  setWindowCors() {
    windowCors := Client.getPetWindowCors()

    this.windowCors.x1 := windowCors[1]
    this.windowCors.y1 := windowCors[2]
    this.windowCors.x2 := windowCors[1] + 275
    this.windowCors.y2 := windowCors[2] + 400
  }

  isDead() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/dead.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isAlive() {
    if(this.isDead()) {
      return false
    } else {
      return true
    }
  }

  isPasive() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/pasive.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }
  
  isRepairing() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/repairing.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPlaying() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/playing.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }


  isPaused() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/paused.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isAutocollectorActive() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/autocollector_active.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isInColdown() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/coldown.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  modulesIsOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/modules_button_open.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    } 
  }

  openModules() {
    if(this.modulesIsOpen() = false) {
      ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/modules_button.bmp

      if(ErrorLevel = 0) {
        MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed
        
        timeWaiting += 0

        Loop { ;wait reviven
          if(this.modulesIsOpen()) {
            Sleep, 150
            break
          } else {

            if(timeWaiting >= 2000) {
              break
            }

            Sleep, 100
            timeWaiting += 100
          }
        }

        return true
      } else {
        return false
      }
    }
  }

  setAutocollector() {
    this.openModules()

    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/module_autocollector.bmp

    if(ErrorLevel = 0) {
      MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed
      Sleep, 500

      return true
    } else {
      return false
    }
  }

  openCommerceWindow() {
    this.openModules()

    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/module_commerce.bmp

    if(ErrorLevel = 0) {
      MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed

      timeWaiting := 0

      Loop { ;wait for prometid
        if(Client.commerceWindowIsOpen()) {
          return true
        } else {

          if(timeWaiting >= 4000) {
            return false
          }

          Sleep, 100
          timeWaiting += 100
        }
      }
    } else {
      return false
    }
  }

  sellMaterials() {
    if(this.openCommerceWindow()) {
      commerceWindowCors := Client.getCommerceWindowCors()

      anchor := []
      anchor[1] := commerceWindowCors[1] + 40
      anchor[2] := commerceWindowCors[2] + 178

      Loop 6 {
        MouseClick, Left, anchor[1], anchor[2], 1, ConfigManager.mouseSpeed
        Sleep, 500

        anchor[1] += 80
      }

      MouseClick, Left, commerceWindowCors[1], commerceWindowCors[2], 1, ConfigManager.mouseSpeed
      Sleep, 3000

      return true
    } else {
      return false
    }
  }

  repair() {
    this.openModules()

    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/module_repair.bmp

    if(ErrorLevel = 0) {
      MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }

  revive() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/dead.bmp

    if(ErrorLevel = 0) {
      MouseGetPos, mouseX, mouseY
      MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed
      MouseMove, mouseX, mouseY, ConfigManager.mouseSpeed

      timeWaiting := 0

      Loop { ;wait reviven
        if(this.isPaused()) {
          break
        } else {

          if(timeWaiting >= 2000) {
            break
          }

          Sleep, 100
          timeWaiting += 100
        }
      }
    }
  }

  play() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *10 ./img/pet/paused.bmp

    if(ErrorLevel = 0) {
      MouseGetPos, mouseX, mouseY
      MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed
      MouseMove, mouseX, mouseY, ConfigManager.mouseSpeed
    }

    timeWaiting := 0

    Loop { ;wait reviven
      if(this.isPasive()) {
        break
      } else {

        if(timeWaiting >= 2000) {
          break
        }

        Sleep, 100
        timeWaiting += 100
      }
    }
  }
}