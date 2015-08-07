#Include, ./client.ahk


class Minimap {
	static boxCors := {}
	static availableBoxCors := {}
	static portalsCors := []
	static pixelEquivalentX := 1.112299465
	static pixelEquivalentY := 1.18260869565217

	isReady() {
		if (this.setBoxCors()) {
			this.setPortalsCors()
			return true
		} else {
			return false
		}
	}

	setPortalsCors() {
		this.portalsCors[27] := [[20, 115], [185, 20]]
		this.portalsCors[28] := [[185, 115], [20, 185]]
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
			MsgBox, , ERROR!, No se encuentra el minimapa `n `n Reconfigure las coordenadas y abra el minimapa.

			return false
		}
	}

	getNearPortalCors() {
		map := 27
		minDistance := 9999
		portalNearPos := 0
		shipCors := this.getShipCors()

		for k, portalCors in this.portalsCors[map] {
			a := (portalCors[1] - shipCors[1])
			a := a * a

			b := (portalCors[2] - shipCors[2])
			b := b * b

			distance := Sqrt( a - b )

			if (distance < minDistance) {
				minDistance := distance
				portalNearPos := k
			}
		} 



		cors := [this.portalsCors[map][portalNearPos][1], this.portalsCors[map][portalNearPos][2]]

		a := cors[1]
		b := cors[2]

		return cors
	}

	screenPosToCors(x, y) {
		x := (x - this.availableBoxCors.x1) * this.pixelEquivalentX
		y := (y - this.availableBoxCors.y1) * this.pixelEquivalentY

		return [x, y]
	}

	corsToScreenPos(x, y) {
		x := (x / this.pixelEquivalentX) + this.availableBoxCors.x1
		y := (y / this.pixelEquivalentY) + this.availableBoxCors.y1

		return [x, y]
	}

	getShipCors() {
		x := this.availableBoxCors.x2 * 0.50
		y := this.availableBoxCors.y2 * 0.50

		ImageSearch, corsX, corsY, this.availableBoxCors.x1, this.availableBoxCors.y1, this.availableBoxCors.x2, this.availableBoxCors.y2, *5 ./img/minimap_vertical_bar.bmp
	
		if (ErrorLevel = 0) {
			x := corsX
		}

		ImageSearch, corsX, corsY, this.availableBoxCors.x1, this.availableBoxCors.y1, this.availableBoxCors.x2, this.availableBoxCors.y2, *5 ./img/minimap_horizontal_bar.bmp
	
		if (ErrorLevel = 0) {
			y := corsY
		}

		cors := this.screenPosToCors(x, y)

		return cors
	}

	goTo(cors) {
		cors := this.corsToScreenPos(cors[1], cors[2])

		corsX := cors[1]
		corsY := cors[2]

		MouseClick, Left, corsX, corsY, 1 , 0

		Sleep, 50
	}
}
