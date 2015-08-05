class Client {
	static boxCors := {}
	static shipStatsBoxCors := {}
	static bonusBoxShader := 100
	static statsBoxShader := 15
	static bonusBoxSize := 1

	__New() {
		this.setClientCors()
		this.setShipStatsBoxCors()
		this.setBonusBoxSize()
	}

	setClientCors() {
		TrayTip, Configuracion, Colocar puntero sobre esquina SUPERIOR del juego y presionar Numpad8, 10000
		KeyWait, Numpad8, D


		MouseGetPos, corsX, corsY
		this.boxCors.x1 := 0
		this.boxCors.y1 := corsY

		TrayTip, Configuracion, Colocar puntero sobre esquina INFERIOR del juego y presionar Numpad2, 10000
		KeyWait, Numpad2, D

		MouseGetPos, corsX, corsY
		this.boxCors.x2 := A_ScreenWidth
		this.boxCors.y2 := corsY
	}

	setBonusBoxSize() {
		this.bonusBoxSize := this.boxCors.x2 * 0.0430
	}

	searchBonusBox() {
		shaderVariation := this.bonusBoxShader

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2 , *%shaderVariation% ./img/bonus_box.bmp

		if (ErrorLevel = 0) {
			return [corsX, corsY]
		} else {
			return false
		}

	}


	setShipStatsBoxCors() {
		shaderVariation := 15

		ImageSearch, corsX, corsY, this.boxCors.x1, this.boxCors.y1, this.boxCors.x2, this.boxCors.y2, *%shaderVariation% ./img/ship_stats_box.bmp

		If (ErrorLevel = 0) {
			this.shipStatsBoxCors.x1 := corsX
			this.shipStatsBoxCors.y1 := corsY
			this.shipStatsBoxCors.x2 := corsX + 190
			this.shipStatsBoxCors.y2 := corsY + 105
		} else {
			TrayTip, ERROR!, No se encuentra el estado de la nave
			Sleep, 5000
		}
	}
}