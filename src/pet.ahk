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
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/play.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    }

  }

  repair() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/repair.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    }
  }

  selectModule(module) {
    ;Open the dropdown
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/arrow.bmp
    
    MouseClick, Left,% x + 2,% y + 2, 1, 0
    Sleep, 500

    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2,% "*10 ./img/pet/module_" module ".bmp"

    MouseClick, Left, x, y, 1, 0    
  }

  isDead() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/repair.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPaused() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/play.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPasive() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *10 ./img/pet/pasive.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }


}