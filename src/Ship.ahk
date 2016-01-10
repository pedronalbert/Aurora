class Ship {
  static healPercent :=
  static shieldPercent :=
  static percentPerBar := 4.761904761904762
  static healBarsColor := 0x7FD878
  static healBarsShader := 15
  static shieldBarsColor := 0xD8D378
  static shieldBarsShader := 20
  static statosWindowCors := {}
  static lastCollectCors := [0,0]
  static cloackCpu :=

  init() {
    this.cloackCpu := ConfigManager.cloackCpu
    this.setStatWindowCors()
  }

  setStatWindowCors() {
    windowCors := Client.getShipStatsWindowCors()

    this.statosWindowCors.x1 := windowCors[1]
    this.statosWindowCors.y1 := windowCors[2]
    this.statosWindowCors.x2 := windowCors[1] + 190
    this.statosWindowCors.y2 := windowCors[2] + 105
  }

  getHealPercent() {
    this.healPercent := 0

    healBarsCorsX := this.statosWindowCors.x1 + 27
    healBarsCorsY := this.statosWindowCors.y1 + 46

    Loop, 21 {
      healBarsCorsX := healBarsCorsX + 3
      PixelSearch, x, y, healBarsCorsX, healBarsCorsY, healBarsCorsX, healBarsCorsY, % this.healBarsColor, % this.healBarsShader, Fast

      if ErrorLevel = 0
        this.healPercent += this.percentPerBar
    }
    return this.healPercent

  }

  getShieldPercent() {
    this.shieldPercent := 0
    shieldBarsCorsX := this.statosWindowCors.x1 + 27
    shieldBarsCorsY := this.statosWindowCors.y1 + 63

    Loop, 21 {
      shieldBarsCorsX := shieldBarsCorsX + 3

      PixelSearch, x, y, shieldBarsCorsX, shieldBarsCorsY, shieldBarsCorsX, shieldBarsCorsY, % this.shieldBarsColor, % this.shieldBarsShader, Fast

      if ErrorLevel = 0
        this.shieldPercent += this.percentPerBar
    }
    return this.shieldPercent
  }

  isMoving() {
    x := Minimap.windowCors.x1 + 114
    y := Minimap.windowCors.y1 + 37

    PixelGetColor, color, x, y

    if (color = "0xFFFFFF") {
      return true
    } else {
      return false
    }
  }

  isDead() {
    ImageSearch, corsX, corsY, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/repair_button.bmp

    if (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  approach(cors) {
    centerX := Client.windowCors.x2 / 2
    centerY := Client.windowCors.y2 / 2

    corsX := (centerX + cors[1]) / 2 ;midle point
    corsY := (centerY + cors[2]) / 2 ;middle point

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

    MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed
  }

  collect(cors) {
    lastCollectX := this.lastCollectCors[1]
    lastCollectY := this.lastCollectCors[2]

    if ( (cors[1] >= (lastCollectX - 5)) and (cors[1] <= (lastCollectX + 5)) and (cors[2] >= (lastCollectY - 5)) and (cors[2] <= (lastCollectY + 5))) {
        this.goAway()
    } else {
      this.lastCollectCors := cors
      MouseClick, Left, cors[1] + 3, cors[2] + 3, 1, ConfigManager.mouseSpeed
    }
  }

  goAway() {
    Minimap.move()
    Sleep, 3000
  }

  /*
   * Revive the ship
   * @param {string} mode - BASE | PORTAL
   * @return {string} mode used
  */
  revive(mode) {
    MouseMove, 0, 0 , ConfigManager.mouseSpeed ;move mouse away

    if (mode = "BASE") {
      image := "repair_base"
    } else {
      image := "repair_portal"
    }
    

    ImageSearch, corsX, corsY, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, % "*10 ./img/" image ".bmp"

    if (ErrorLevel = 0) {

      MouseClick, Left, corsX + 5, corsY + 5, 1, ConfigManager.mouseSpeed ;click on mode

      Sleep, 1000

      ImageSearch, corsX, corsY, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/repair_button.bmp

      if (ErrorLevel = 0) {
        Random, variationX, 5, 100
        Random, variationY, 5, 20

        MouseClick, Left, corsX + variationX, corsY + variationY, 1, ConfigManager.mouseSpeed ;click on repair button

        Sleep, 8000

        if (this.isDead()) {
          return false
        } else {
          return mode
        }
      }

    } else {
      if (this.revive("BASE")) {
        return "BASE"
      } else {
        return false
      }
    }
  }

  isInvisible() {
    cloackCors := Client.getCloackCors(this.cloackCpu)
 
    corsX := cloackCors[1]
    corsY := cloackCors[2]

    if (cloackCors) {
      PixelGetColor, color, corsX - 2, corsY + 2

      if (color = "0x846B29") {
        return false
      } else {
        return true
      }
    } else {
      return true
    }
  }

  useCloack()  {
    cloackCors := Client.getCloackCors(this.cloackCpu)

    if (isObject(cloackCors)) {
      MouseClick, Left,  % cloackCors[1] + 5, % cloackCors[2] + 5, 1, ConfigManager.mouseSpeed

      return true
    } else {
      return false
    }
  }

  changeConfig() {
    Send {c}
  }

}
