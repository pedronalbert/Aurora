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
    this.windowCors.y2 := windowCors[2] + 300
  }

  isDead() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/dead.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPasive() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/module_pasive.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPlaying() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/playing.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }


  isPaused() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/paused.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  modulesIsOpen() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/modules_button_open.bmp

    if(ErrorLevel = 0) {
      return true
    } else {
      return false
    } 
  }

  openModules() {
    if(this.modulesIsOpen() = false) {
      ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/modules_button.bmp

      if(ErrorLevel = 0) {
        MouseGetPos, mouseX, mouseY
        MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed
        MouseMove, mouseX, mouseY, ConfigManager.mouseSpeed
        
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

    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/module_autocollector.bmp

    if(ErrorLevel = 0) {
      MouseGetPos, mouseX, mouseY
      MouseClick, Left, corsX + 1, corsY + 1, 1, ConfigManager.mouseSpeed
      MouseMove, mouseX, mouseY, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }


  revive() {
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/dead.bmp

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
    ImageSearch, corsX, corsY, this.windowCors.x1, this.windowCors.y1, this.windowCors.x2, this.windowCors.y2, *5 ./img/pet/paused.bmp

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