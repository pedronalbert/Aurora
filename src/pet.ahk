class Pet {

  static windowCors := {}

  init() {
    if (!this.setWindowCors()) {
      return false
    }

    return true
  }

  setWindowCors() {
    if (!Client.petWindowIsOpen()) {
      Client.petWindowOpen()
      Sleep, 2000
    }
    
    if (Client.petWindowIsOpen()) {
      windowCors := Client.getPetsWindowCors()

      this.windowCors.x1 := windowCors[1]
      this.windowCors.y1 := windowCors[2]
      this.windowCors.x2 := windowCors[1] + 269
      this.windowCors.y2 := windowCors[2] + Client.windowCors.y2

      return true
    } else {
      MsgBox, % "ERRROR! Pet not found"

      return false
    }
  }

  play() {
    ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/pet/play.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    } else {
  }

  }

  repair() {
    ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/pet/repair.bmp

    If (ErrorLevel = 0) {
      MouseClick, Left, x, y, 1, 0
      MouseMove, 0, 0, 0
    } else {
  }
  }

  openModules() {

  ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/pet/arrow.bmp

  If (ErrorLevel = 0) {
    MouseClick, Left,% x + 2,% y + 2, 1, 0
    Sleep, 1000
  } else {
  }
  }

  selectModule(module) {
    this.openModules()

    ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2,% "*10 ./img/pet/module_" module ".bmp"

  If (ErrorLevel = 0) {
    MouseClick, Left, x, y, 1, 0
  } else {
  }
  }

  isDead() {
    ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/pet/repair.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPaused() {
    ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/pet/play.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }

  isPasive() {
    ImageSearch, x, y, Client.windowCors.x1, Client.windowCors.y1, Client.windowCors.x2, Client.windowCors.y2, *10 ./img/pet/pasive.bmp

    If (ErrorLevel = 0) {
      return true
    } else {
      return false
    }
  }


}