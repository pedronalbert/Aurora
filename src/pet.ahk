class Pet {

  static boxCors := {}

  init() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/box.bmp

    If (ErrorLevel = 0) {
      this.boxCors.x1 := x
      this.boxCors.y1 := y
      this.boxCors.x2 := x + 269
      this.boxCors.y2 := Client.boxCors.y2

      return true
    } else {
      MsgBox, % "ERRROR! the pet window is not visible"
      return false
    }
  }

  play() {
	OutputDebug, % "Pet Play"
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/play.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    } else {
	  OutputDebug, % "ERROR! Pet Play button is not found"
	}

  }

  repair() {
	OutputDebug, % "Pet Repair"
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/repair.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    } else {
	  OutputDebug, % "ERROR! Pet Repair buttton is not found"
	}
  }

  openModules() {
	OutputDebug, % "Ship OpenModules"

	ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/arrow.bmp

	If (ErrorLevel = 0) {
	  MouseClick, Left,% x + 2,% y + 2, 1, 0
		Sleep, 1000
	} else {
	  OutputDebug, % "ERROR! Pet select modules is not found"
	}
  }

  selectModule(module) {
	OutputDebug, % "Pet selectModule " module
    this.openModules()

    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2,% "*10 ./img/pet/module_" module ".bmp"

	If (ErrorLevel = 0) {
	  MouseClick, Left, x, y, 1, 0
	} else {
	  OutputDebug, % "ERROR! Pet module: " module " is not found"
	}
  }

  isDead() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/repair.bmp

    If (ErrorLevel = 0) {
	  OutputDebug, % "Pet is dead"
      return true
    } else {
	  OutputDebug, % "Pet is alive"
      return false
    }
  }

  isPaused() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/play.bmp

    If (ErrorLevel = 0) {
	  OutputDebug, % "Pet is paused"
      return true
    } else {
	  OutputDebug, % "Pet is playing"
      return false
    }
  }

  isPasive() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/pasive.bmp

    If (ErrorLevel = 0) {
	  OutputDebug, % "Pet is pasive"
      return true
    } else {
	  OutputDebug, % "Pet is not pasive"
      return false
    }
  }


}