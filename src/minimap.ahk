class Minimap {
  static windowCors := {}
  static minimapCors := {}
  static portalsCors := []
  static pixelEquivalentX := 1.112299465
  static pixelEquivalentY := 1.18360869565217
  static backToMapRoutes := []
  static backToMapRoutePosition :=
  static backToMapRoute :=
  static searchPointPosition := 
  static searchPoints := []
  static shipLastCors := []

  ;User config
  static configMap :=
  static configMoveMode :=

  init() {
    if (!this.setWindowCors()) {
      return false
    }

    Random, searchPointPositionRandom, 1, 25
    this.searchPointPosition := searchPointPositionRandom

    this.configMap := ConfigManager.map
    this.configMoveMode := ConfigManager.moveMode
    this.setPortalsCors()
    this.setBackToMapRoutes()
    this.setSearchPoints()

    return true
  }
  

  moveNextPoint() {
    shipCors := this.getShipCors()
    pointToGo := this.searchPoints[this.searchPointPosition]

    if ((shipCors[1] >= (pointToGo[1] - 2)) and  (shipCors[1] <= (pointToGo[1] + 2)) and (shipCors[2] >= (pointToGo[2] - 3)) and (shipCors[2] <= (pointToGo[2] + 3))) {
      ;Move to next point
      if (this.searchPointPosition = 25) {
        this.searchPointPosition := 1
      } else {
        this.searchPointPosition++
      }

    }

    Random, variationX, 0, 2
    Random, variationY, 0, 2

    cors := []
    cors[1] := this.searchPoints[this.searchPointPosition][1] + variationX
    cors[2] := this.searchPoints[this.searchPointPosition][2] + variationY

    this.goTo(cors)
  }

  generateBackToMapRoute() {
    this.backToMapRoute :=  this.backToMapRoutes[this.configMap]
    this.backToMapRoutePosition := 1
  }

  goTo(cors) {

    x := cors[1] + this.minimapCors.x1
    y := cors[2] + this.minimapCors.y1

    MouseClick, Left, x, y, 1 , 0
  }

  goToNextPortal() {
    nextMap := this.backToMapRoute[this.backToMapRoutePosition + 1]
    actualMap := this.backToMapRoute[this.backToMapRoutePosition]

    if (actualMap = this.configMap) {
      return false
    }

    if (nextMap >= 11 and nextMap <= 38) {
      for k, portal in this.portalsCors[actualMap] {
        if (portal.map = nextMap) {
          this.goTo(portal.cors)
          this.backToMapRoutePosition++

          return true
        }
      }
      return false
    } else {
      return false
    }
  }

  move() {
    if (this.configMoveMode = "RANDOM") {
      this.moveRandom()
    } else if (this.configMoveMode = "COMPLETE") {
      this.moveNextPoint()
    } else {
      this.movePaladioMode()
    }
  }

  moveRandom() {
    Random, corsX, 34, 145

    Random, sector, 1, 5  ; top (1, 2), center(3), bot(4, 5)

    if (sector <= 2) {
      Random, corsY, 1, 17
    } else if (sector = 3) {
      Random, corsY, 18, 102
    } else if (sector >= 4) {
      Random, corsY, 103, 114
    }

    cors := [corsX, corsY]

    this.goTo(cors)
  }

  getShipCors() {
    x := this.minimapCors.x1 + 96
    y := this.minimapCors.y2 + 58

    ImageSearch, corsX, corsY, this.minimapCors.x1, this.minimapCors.y1, this.minimapCors.x2, this.minimapCors.y2, *5 ./img/minimap_vertical_bar.bmp

    if (ErrorLevel = 0) {
      x := corsX
    }

    ImageSearch, corsX, corsY, this.minimapCors.x1, this.minimapCors.y1, this.minimapCors.x2, this.minimapCors.y2, *5 ./img/minimap_horizontal_bar.bmp

    if (ErrorLevel = 0) {
      y := corsY
    } else {
      ImageSearch, corsX, corsY, this.minimapCors.x1, this.minimapCors.y1, this.minimapCors.x2, this.minimapCors.y2, *8 ./img/minimap_arrow.bmp

      if (ErrorLevel = 0) {
        y := corsY + 6
      }
    }

    cors := [x - this.minimapCors.x1, y - this.minimapCors.y1]

    return cors
  }

  getNearPortalCors() {
    minDistance := 9999
    portalNearPos := 0
    shipCors := this.getShipCors()

    for k, portalCors in this.portalsCors[this.configMap] {
      a := (portalCors.cors[1] - shipCors[1])
      a := a * a

      b := (portalCors.cors[2] - shipCors[2])
      b := b * b

      distance := Sqrt( a + b )

      if (distance < minDistance) {
        minDistance := distance
        portalNearPos := k
      }
    }

    cors := [this.portalsCors[this.configMap][portalNearPos].cors[1], this.portalsCors[this.configMap][portalNearPos].cors[2]]

    return cors
  }

  getMapsString() {
    maps := "1-1|1-2|1-3|1-4|1-5|1-6|1-7|1-8|2-1|2-2|2-3|2-4|2-5|2-6|2-7|2-8|3-1|3-2|3-3|3-4|3-5|3-6|3-7|3-8"

    return maps
  }

  getMapsArray() {
    maps := [11, 12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38]

    return maps
  }

  setPortalsCors() {
    this.portalsCors[11] := []
    this.portalsCors[11][1] := {}
    this.portalsCors[11][1].map := 12
    this.portalsCors[11][1].cors := [16,102]

    this.portalsCors[12] := []
    this.portalsCors[12][1] := {}
    this.portalsCors[12][1].map := 13
    this.portalsCors[12][1].cors := [166,16]
    this.portalsCors[12][2] := {}
    this.portalsCors[12][2].map := 14
    this.portalsCors[12][2].cors := [166,102]

    this.portalsCors[13] := []
    this.portalsCors[13][1] := {}
    this.portalsCors[13][1].map := 12
    this.portalsCors[13][1].cors := [16,102]
    this.portalsCors[13][2] := {}
    this.portalsCors[13][2].map := 14
    this.portalsCors[13][2].cors := [166,102]

    this.portalsCors[14] := []
    this.portalsCors[14][1] := {}
    this.portalsCors[14][1].map := 12
    this.portalsCors[14][1].cors := [16,16]
    this.portalsCors[14][2] := {}
    this.portalsCors[14][2].map := 13
    this.portalsCors[14][2].cors := [166,16]

    this.portalsCors[15] := []
    this.portalsCors[15][1] := {}
    this.portalsCors[15][1].map := 16
    this.portalsCors[15][1].cors := [16,16]
    this.portalsCors[15][2] := {}
    this.portalsCors[15][2].map := 17
    this.portalsCors[15][2].cors := [16,102]

    this.portalsCors[16] := []
    this.portalsCors[16][1] := {}
    this.portalsCors[16][1].map := 18
    this.portalsCors[16][1].cors := [16,166]
    this.portalsCors[16][2] := {}
    this.portalsCors[16][2].map := 15
    this.portalsCors[16][2].cors := [166,102]

    this.portalsCors[17] := []
    this.portalsCors[17][1] := {}
    this.portalsCors[17][1].map := 18
    this.portalsCors[17][1].cors := [16,16]
    this.portalsCors[17][2] := {}
    this.portalsCors[17][2].map := 15
    this.portalsCors[17][2].cors := [166,16]

    this.portalsCors[18] := []
    this.portalsCors[18][1] := {}
    this.portalsCors[18][1].map := 16
    this.portalsCors[18][1].cors := [166,16]
    this.portalsCors[18][2] := {}
    this.portalsCors[18][2].map := 17
    this.portalsCors[18][2].cors := [166,102]

    this.portalsCors[21] := []
    this.portalsCors[21][1] := {}
    this.portalsCors[21][1].map := 22
    this.portalsCors[21][1].cors := [16,102]

    this.portalsCors[22] := []
    this.portalsCors[22][1] := {}
    this.portalsCors[22][1].map := 23
    this.portalsCors[22][1].cors := [16,102]
    this.portalsCors[22][2] := {}
    this.portalsCors[22][2].map := 24
    this.portalsCors[22][2].cors := [166,16]

    this.portalsCors[23] := []
    this.portalsCors[23][1] := {}
    this.portalsCors[23][1].map := 22
    this.portalsCors[23][1].cors := [166,16]
    this.portalsCors[23][2] := {}
    this.portalsCors[23][2].map := 24
    this.portalsCors[23][2].cors := [166,102]

    this.portalsCors[24] := []
    this.portalsCors[24][1] := {}
    this.portalsCors[24][1].map := 22
    this.portalsCors[24][1].cors := [16,16]
    this.portalsCors[24][2] := {}
    this.portalsCors[24][2].map := 23
    this.portalsCors[24][2].cors := [166,16]

    this.portalsCors[25] := []
    this.portalsCors[25][1] := {}
    this.portalsCors[25][1].map := 26
    this.portalsCors[25][1].cors := [16,16]
    this.portalsCors[25][2] := {}
    this.portalsCors[25][2].map := 27
    this.portalsCors[25][2].cors := [166,16]

    this.portalsCors[26] := []
    this.portalsCors[26][1] := {}
    this.portalsCors[26][1].map := 25
    this.portalsCors[26][1].cors := [16,102]
    this.portalsCors[26][2] := {}
    this.portalsCors[26][2].map := 25
    this.portalsCors[26][2].cors := [166,16]

    this.portalsCors[27] := []
    this.portalsCors[27][1] := {}
    this.portalsCors[27][1].map := 25
    this.portalsCors[27][1].cors := [16,102]
    this.portalsCors[27][2] := {}
    this.portalsCors[27][2].map := 28
    this.portalsCors[27][2].cors := [166,16]

    this.portalsCors[28] := []
    this.portalsCors[28][1] := {}
    this.portalsCors[28][1].map := 26
    this.portalsCors[28][1].cors := [16,102]
    this.portalsCors[28][2] := {}
    this.portalsCors[28][2].map := 27
    this.portalsCors[28][2].cors := [166,102]

    this.portalsCors[31] := []
    this.portalsCors[31][1] := {}
    this.portalsCors[31][1].map := 32
    this.portalsCors[31][1].cors := [16,16]

    this.portalsCors[32] := []
    this.portalsCors[32][1] := {}
    this.portalsCors[32][1].map := 33
    this.portalsCors[32][1].cors := [166,16]
    this.portalsCors[32][2] := {}
    this.portalsCors[32][2].map := 34
    this.portalsCors[32][2].cors := [16,16]

    this.portalsCors[33] := []
    this.portalsCors[33][1] := {}
    this.portalsCors[33][1].map := 34
    this.portalsCors[33][1].cors := [16,102]
    this.portalsCors[33][2] := {}
    this.portalsCors[33][2].map := 32
    this.portalsCors[33][2].cors := [166,102]

    this.portalsCors[34] := []
    this.portalsCors[34][1] := {}
    this.portalsCors[34][1].map := 32
    this.portalsCors[34][1].cors := [166,102]
    this.portalsCors[34][2] := {}
    this.portalsCors[34][2].map := 33
    this.portalsCors[34][2].cors := [166,16]

    this.portalsCors[35] := []
    this.portalsCors[35][1] := {}
    this.portalsCors[35][1].map := 36
    this.portalsCors[35][1].cors := [16,102]
    this.portalsCors[35][2] := {}
    this.portalsCors[35][2].map := 37
    this.portalsCors[35][2].cors := [166,102]

    this.portalsCors[36] := []
    this.portalsCors[36][1] := {}
    this.portalsCors[36][1].map := 35
    this.portalsCors[36][1].cors := [16,16]
    this.portalsCors[36][2] := {}
    this.portalsCors[36][2].map := 38
    this.portalsCors[36][2].cors := [166,102]

    this.portalsCors[37] := []
    this.portalsCors[37][1] := {}
    this.portalsCors[37][1].map := 35
    this.portalsCors[37][1].cors := [16,102]
    this.portalsCors[37][2] := {}
    this.portalsCors[37][2].map := 38
    this.portalsCors[37][2].cors := [166,102]

    this.portalsCors[38] := []
    this.portalsCors[38][1] := {}
    this.portalsCors[38][1].map := 37
    this.portalsCors[38][1].cors := [16,16]
    this.portalsCors[38][2] := {}
    this.portalsCors[38][2].map := 36
    this.portalsCors[38][2].cors := [16,102]
  }

  setSearchPoints() {
    this.searchPoints[1] := [36, 2]
    this.searchPoints[2] := [36, 110]
    this.searchPoints[3] := [53, 110]
    this.searchPoints[4] := [53, 2]
    this.searchPoints[5] := [72, 2]
    this.searchPoints[6] := [72, 110]
    this.searchPoints[7] := [90, 110]
    this.searchPoints[8] := [90, 2]
    this.searchPoints[9] := [108, 2]
    this.searchPoints[10] := [108, 110]
    this.searchPoints[11] := [126, 110]
    this.searchPoints[12] := [126, 2]
    this.searchPoints[13] := [144, 2]
    this.searchPoints[14] := [144, 110]
    this.searchPoints[15] := [136, 110]
    this.searchPoints[16] := [136, 2]
    this.searchPoints[17] := [118, 2]
    this.searchPoints[18] := [118, 110]
    this.searchPoints[19] := [99, 110]
    this.searchPoints[20] := [99, 2]
    this.searchPoints[21] := [81, 2]
    this.searchPoints[22] := [81, 110]
    this.searchPoints[23] := [63, 110]
    this.searchPoints[24] := [63, 2]
    this.searchPoints[25] := [44, 2]
  }

  setBackToMapRoutes() {
    this.backToMapRoutes[11] := [11]
    this.backToMapRoutes[12] := [11, 12]
    this.backToMapRoutes[13] := [11, 12, 13]
    this.backToMapRoutes[14] := [11, 12, 14]
    this.backToMapRoutes[15] := [18, 17, 15]
    this.backToMapRoutes[16] := [18, 16]
    this.backToMapRoutes[17] := [18, 17]
    this.backToMapRoutes[18] := [18]

    this.backToMapRoutes[21] := [21]
    this.backToMapRoutes[22] := [21, 22]
    this.backToMapRoutes[23] := [21, 22, 23]
    this.backToMapRoutes[24] := [21, 22, 24]
    this.backToMapRoutes[25] := [28, 27, 25]
    this.backToMapRoutes[26] := [28, 26]
    this.backToMapRoutes[27] := [28, 27]
    this.backToMapRoutes[28] := [28]

    this.backToMapRoutes[31] := [31]
    this.backToMapRoutes[32] := [31, 32]
    this.backToMapRoutes[33] := [31, 32, 33]
    this.backToMapRoutes[34] := [31, 32, 34]
    this.backToMapRoutes[35] := [38, 37, 35]
    this.backToMapRoutes[36] := [38, 36]
    this.backToMapRoutes[37] := [38, 37]
    this.backToMapRoutes[38] := [38]
  }

  setWindowCors() {
    if (!Client.minimapWindowIsOpen()) {
      Client.minimapWindowOpen()
      Sleep, 2000
    }
    
    if (Client.minimapWindowIsOpen()) {
      windowCors := Client.getMinimapWindowCors()

      this.windowCors.x1 := windowCors[1]
      this.windowCors.y1 := windowCors[2]
      this.windowCors.x2 := windowCors[1] + 176
      this.windowCors.y2 := windowCors[2] + 190

      this.minimapCors.x1 := windowCors[1] + 25
      this.minimapCors.y1 := windowCors[2] + 50
      this.minimapCors.x2 := this.minimapCors.x1 + 187
      this.minimapCors.y2 := this.minimapCors.y1 + 115

      return true
    } else {
      MsgBox, % "ERRROR! re-configure the client (Minimap.ahk)"

      return false
    }
  }

  /*
    Save in lastCors
  */
  saveLastCors() {
    this.shipLastCors := this.getShipCors()
  }

  isInNewMap() {
    lastCors := this.shipLastCors
    newCors := this.getShipCors()


    if (lastCors[1] > newCors[1]) {
      diff := lastCors[1] - newCors[1]
    } else {
      diff := newCors[1] - lastCors[1]
    }

    if diff > 40
      return true

    if (lastCors[2] > newCors[2]) {
      diff := lastCors[2] - newCors[2]
    } else {
      diff := newCors[2] - lastCors[2]
    }

    if (diff > 40) {
      return true
    }

    return false
  }
}
