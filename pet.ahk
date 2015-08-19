class Pet {

  static boxCors := {}

  init() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_box.bmp

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

  isDead() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_repair.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPaused() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_play.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPasive() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_state_pasive.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  play() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_play.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    }

  }

  repair() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_repair.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    }
  }

  selectCollect() {
    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_arrow.bmp
    
    MouseClick, Left, x, y, 1, 0
    Sleep, 500

    ImageSearch, x, y, Client.boxCors.x1, Client.boxCors.y1, Client.boxCors.x2, Client.boxCors.y2, *5 ./img/pet_module_collector.bmp

    MouseClick, Left, x, y, 1, 0    
  }
}