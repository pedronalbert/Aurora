#Include, ./client.ahk


class Minimap {
	static boxCors := {}
	static availableBoxCors := {}
	static portalsCors := []
	static pixelEquivalentX := 1.112299465
	static pixelEquivalentY := 1.18360869565217
	static routes := []
	static routePosition :=
	static route :=

	init() {
		if (this.setBoxCors()) {
			this.setPortalsCors()
			this.setRoutes()
			OutputDebug, % "Minimap is Ready!"
			return true
		} else {
			return false
		}
	}

	setBoxCors() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/minimap_box.bmp

		If (ErrorLevel = 0) {
			this.boxCors.x1 := corsX
			this.boxCors.y1 := corsY
			this.boxCors.x2 := corsX + 176
			this.boxCors.y2 := corsY + 190

			this.availableBoxCors.x1 := corsX + 25
			this.availableBoxCors.y1 := corsY + 50
			this.availableBoxCors.x2 := this.availableBoxCors.x1 + 187
			this.availableBoxCors.y2 := this.availableBoxCors.y1 + 115

			return true
		} else {
			MsgBox, % "ERROR!, the minimap is not visible, set to visible or re-configure the client coors"
			return false
		}
	}

	getShipCors() {
		x := this.availableBoxCors.x1 + 96
		y := this.availableBoxCors.y2 + 58

		ImageSearch, corsX, corsY, this.availableBoxCors.x1, this.availableBoxCors.y1, this.availableBoxCors.x2, this.availableBoxCors.y2, *5 ./img/minimap_vertical_bar.bmp
	
		if (ErrorLevel = 0) {
			x := corsX
		}

		ImageSearch, corsX, corsY, this.availableBoxCors.x1, this.availableBoxCors.y1, this.availableBoxCors.x2, this.availableBoxCors.y2, *5 ./img/minimap_horizontal_bar.bmp
	
		if (ErrorLevel = 0) {
			y := corsY
		}

		cors := [x - this.availableBoxCors.x1, y - this.availableBoxCors.y1]

		return cors
	}


	goTo(cors) {

		cors[1] += this.availableBoxCors.x1
		cors[2] += this.availableBoxCors.y1

		MouseClick, Left,% cors[1], % cors[2], 1 , 0

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

	setRoutes() {
		this.routes[11] := [11]
		this.routes[12] := [11, 12]
		this.routes[13] := [11, 12, 13]
		this.routes[14] := [11, 12, 14]
		this.routes[15] := [18, 17, 15]
		this.routes[16] := [18, 16]
		this.routes[17] := [18, 17]
		this.routes[18] := [18]

		this.routes[21] := [21]
		this.routes[22] := [21, 22]
		this.routes[23] := [21, 22, 23]
		this.routes[24] := [21, 22, 24]
		this.routes[25] := [28, 27, 25]
		this.routes[26] := [28, 26]
		this.routes[27] := [28, 27]
		this.routes[28] := [28]

		this.routes[31] := [31]
		this.routes[32] := [31, 32]
		this.routes[33] := [31, 32, 33]
		this.routes[34] := [31, 32, 34]
		this.routes[35] := [38, 37, 35]
		this.routes[36] := [38, 36]
		this.routes[37] := [38, 37]
		this.routes[38] := [38]

	}

	generateRoute() {
		this.route :=  this.routes[System.map]
		this.routePosition := 1
	}

	goToNextPortal() {
		nextMap := this.route[this.routePosition + 1]
		actualMap := this.route[this.routePosition]

		OutputDebug, % "next map: " nextMap " actual map: " actualMap

		if (actualMap = System.map) {
			return false
		}

		if (nextMap >= 11 and nextMap <= 38) {
			for k, portal in this.portalsCors[actualMap] {
				if (portal.map = nextMap) {
					this.goTo(portal.cors)
					this.routePosition++

					return true
				}
			}
			return false
		} else {
			return false
		}
	}

	getNearPortalCors() {
		map := System.map
		minDistance := 9999
		portalNearPos := 0
		shipCors := this.getShipCors()

		for k, portalCors in this.portalsCors[map] {
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

		cors := [this.portalsCors[map][portalNearPos].cors[1], this.portalsCors[map][portalNearPos].cors[2]]

		OutputDebug, % "Near portal: " cors[1] " , " cors[2] 
		return cors
	}

}
