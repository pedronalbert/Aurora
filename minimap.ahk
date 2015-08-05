#Include, ./client.ahk

class Minimap {
	static shaderVariation := 15
	static availableCors := {}
	static boxCors := {}

	__New() {
		this.setMinimapCors()
	}

	setMinimapCors() {
		ImageSearch, corsX, corsY, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *this.shaderVariation ./img/minimap_box.bmp

		If (ErrorLevel = 0) {
			this.boxCors.x1 := corsX
			this.boxCors.y1 := corsY
			this.boxCors.x2 := corsX + 176
			this.boxCors.y2 := corsY + 190

			this.availableCors.x1 := corsX + 25
			this.availableCors.y1 := corsY + 49
			this.availableCors.x2 := corsX + 212
			this.availableCors.y2 := corsY + 163
		} else {
			TrayTip, ERROR!, No se ha encontrado el minimapa
			Sleep, 5000
		}
	}
}