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
		this.routes[35] := [38, 37, 35]
		this.routes[36] := [38, 36]
		this.routes[37] := [38, 37]
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
