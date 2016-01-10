class Minimap {
  static windowCors := {}
  static minimapCors := {}
  static portalsCors := []
  static pixelEquivalentX := 1.112299465
  static pixelEquivalentY := 1.18360869565217
  static roamingPointPosition := 
  static roamingPoints := []
  static backToTargetMap := {route: [], actualIndex: 0}

  ;User config
  static targetMap :=
  static configMoveMode :=

  init() {
    this.setWindowCors()
 
    ;Random position on search
    Random, searchPointPositionRandom, 1, 25
    this.roamingPointPosition := searchPointPositionRandom

    this.targetMap := ConfigManager.targetMap

    if(this.targetMap = 0) {
      MsgBox, Aurora Error!, Map number not found
      return false
    }

    this.configMoveMode := ConfigManager.moveMode
    this.setPortalsCors()
    this.setSearchPoints()

    return true
  }
  

  moveNextRoamingPoint() {
    shipCors := this.getShipCors()
    pointToGo := this.roamingPoints[this.roamingPointPosition]

    if ((shipCors[1] >= (pointToGo[1] - 2)) and  (shipCors[1] <= (pointToGo[1] + 2)) and (shipCors[2] >= (pointToGo[2] - 3)) and (shipCors[2] <= (pointToGo[2] + 3))) {
      ;Move to next point
      if (this.roamingPointPosition = 25) {
        this.roamingPointPosition := 1
      } else {
        this.roamingPointPosition++
      }

    }

    Random, variationX, 0, 2
    Random, variationY, 0, 2

    cors := []
    cors[1] := this.roamingPoints[this.roamingPointPosition][1] + variationX
    cors[2] := this.roamingPoints[this.roamingPointPosition][2] + variationY

    this.goTo(cors)
  }

  ;Cors: minimap relative cors
  goTo(cors) {

    x := cors[1] + this.minimapCors.x1
    y := cors[2] + this.minimapCors.y1

    MouseClick, Left, x, y, 1 , ConfigManager.mouseSpeed
  }

  move() {
    if (this.configMoveMode = "COMPLETE") {
      this.moveNextRoamingPoint()
    } else {
      this.moveRandom()
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

    for k, portalCors in this.portalsCors[this.targetMap] {
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

    cors := [this.portalsCors[this.targetMap][portalNearPos].cors[1], this.portalsCors[this.targetMap][portalNearPos].cors[2]]

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
    this.roamingPoints[1] := [36, 2]
    this.roamingPoints[2] := [36, 110]
    this.roamingPoints[3] := [53, 110]
    this.roamingPoints[4] := [53, 2]
    this.roamingPoints[5] := [72, 2]
    this.roamingPoints[6] := [72, 110]
    this.roamingPoints[7] := [90, 110]
    this.roamingPoints[8] := [90, 2]
    this.roamingPoints[9] := [108, 2]
    this.roamingPoints[10] := [108, 110]
    this.roamingPoints[11] := [126, 110]
    this.roamingPoints[12] := [126, 2]
    this.roamingPoints[13] := [144, 2]
    this.roamingPoints[14] := [144, 110]
    this.roamingPoints[15] := [136, 110]
    this.roamingPoints[16] := [136, 2]
    this.roamingPoints[17] := [118, 2]
    this.roamingPoints[18] := [118, 110]
    this.roamingPoints[19] := [99, 110]
    this.roamingPoints[20] := [99, 2]
    this.roamingPoints[21] := [81, 2]
    this.roamingPoints[22] := [81, 110]
    this.roamingPoints[23] := [63, 110]
    this.roamingPoints[24] := [63, 2]
    this.roamingPoints[25] := [44, 2]
  }

  setWindowCors() {
      windowCors := Client.getMinimapWindowCors()

      this.windowCors.x1 := windowCors[1]
      this.windowCors.y1 := windowCors[2]
      this.windowCors.x2 := windowCors[1] + 176
      this.windowCors.y2 := windowCors[2] + 190

      this.minimapCors.x1 := windowCors[1] + 25
      this.minimapCors.y1 := windowCors[2] + 50
      this.minimapCors.x2 := this.minimapCors.x1 + 187
      this.minimapCors.y2 := this.minimapCors.y1 + 115
  }

  isInTargetMap() {
    if(this.targetMap <> this.getActualMap()) {
      return false
    } else {
      return true
    }
  }

  getActualMap() {
    firstNumberX1 := this.windowCors.x1 + 25
    firstNumberY1 := this.windowCors.y1 + 33
    map := 10
    valid := true

    number := 1
    Loop {
      ImageSearch, corsX, corsY, firstNumberX1, firstNumberY1, firstNumberX1 + 8, firstNumberY1 + 9,% "*50 ./img/minimap_numbers/" number ".bmp"

      if(ErrorLevel = 0) {
        map *= number
        break
      } else {
        if(number > 4) {
          valid := false
          break
        } else {
          number++
        }
      }
    }

    secondNumberX1 := this.windowCors.x1 + 36
    secondNumberY1 := this.windowCors.y1 + 33

    number := 1

    Loop {
      ImageSearch, corsX, corsY, secondNumberX1, secondNumberY1, secondNumberX1 + 8, secondNumberY1 + 9,% "*50 ./img/minimap_numbers/" number ".bmp"

      if(ErrorLevel = 0) {
        map += number
        break
      } else {
        if(number > 8) {
          valid := false
          break
        } else {
          number++
        }
      }
    }

    if(valid) {
      return map
    } else {
      return 0
    }
  }

  generateBackRoute(originMap, destinyMap) {
    nextMap := originMap
    actualMap := originMap
    route := []

    if(originMap < destinyMap) {
      nextMap++
    } else {
      nextMap--
    }

    Loop {
      loops := this.portalsCors[actualMap].MaxIndex()

      ;Find destiny map
      i := 1
      destinyFound := false

      Loop %loops% {
        portalMap := this.portalsCors[actualMap][i].map

        if(portalMap = destinyMap) {
          route.Push(destinyMap)
          actualMap := destinyMap
          destinyFound := true
        } 
        i++
      }

      ;Find next map
      if(destinyFound = false) {
        i := 1
        destinyFound := false

        Loop %loops% {
          portalMap := this.portalsCors[actualMap][i].map

          if(portalMap = nextMap) {
            route.Push(nextMap)
            actualMap := nextMap
            destinyFound := true
          } 
          i++
        }
      }

      if(actualMap = destinyMap) {
        break
      } else {
        if(originMap < destinyMap) {
          nextMap++
        } else {
          nextMap--
        }
      }
    }

    return route
  }

  getPortalCors(origenMap, destinyMap) {
    portalCors :=
    loops := this.portalsCors[origenMap].MaxIndex()

    i := 1
    Loop %loops% {
      portalMap := this.portalsCors[origenMap][i].map

      if(portalMap = destinyMap) {
        return this.portalsCors[origenMap][i].cors
      } 
      
      i++
    }

    return false
  }

  generateBackToTargetMap() {
    this.backToTargetMap.route := this.generateBackRoute(this.getActualMap(), this.targetMap)
    this.backToTargetMap.actualIndex := 1
  }

  getNextBackToTargetMapPortal() {
    actualMap := this.getActualMap()

    if(this.targetMap = actualMap) {
      return false
    }

    nextMap := this.backToTargetMap.route[this.backToTargetMap.actualIndex]
    this.backToTargetMap.actualIndex++

    return this.getPortalCors(actualMap, nextMap)
  }
}
