class Refinator {
  refinateResource(resource) {
    ImageSearch, corsX, corsY, 0, 0, Client.windowCors.x2, Client.windowCors.y2, % "*5 ./img/client/" resource ".bmp"

    if(ErrorLevel = 0) {
      ;click to resource "refinateResource"
      corsY += 80

      MouseClick, Left, corsX, corsY, 1, ConfigManager.mouseSpeed

      timeWaiting := 0

      Loop { ;wait for prometid
        ImageSearch, arrowCorsX, arrowCorsY, 0, 0, Client.windowCors.x2, Client.windowCors.y2, *5 ./img/client/refinator_selector_arrow.bmp

        if(ErrorLevel = 0) {
          break
        } else {

          if(timeWaiting >= 2000) {
            break
            return false
          }

          Sleep, 100
          timeWaiting += 100
        }
      }

      ;click arrow
      MouseClick, Left, arrowCorsX, arrowCorsY, 1, ConfigManager.mouseSpeed

      anchorY := arrowCorsY

      ;wait for select opened
      timeWaiting := 0

      Loop {
        PixelGetColor, color, arrowCorsX, arrowCorsY + 20

        if(color = "0xFFD89A") {
          break
        } else {
          if(timeWaiting >= 2000) {
            break
            return false
          }
        }

        Sleep, 100
        timeWaiting += 100
      }

      ;find last amount
      Loop {
        anchorY += 20

        PixelGetColor, color, arrowCorsX, anchorY

        if(color = "0xFFFFFF" or color = "0xFFD89A") {
          amountYCors := anchorY
        } else {
          break
        }
      }

      ;select amount
      MouseClick, Left, arrowCorsX, amountYCors, 1, ConfigManager.mouseSpeed
      
      ;wait for select close
      timeWaiting := 0

      Loop {
        PixelGetColor, color, arrowCorsX, arrowCorsY + 20

        if(color <> "0xFFD89A") {
          break
        } else {
          if(timeWaiting > 2000) {
            break
            return false
          }
        }

        Sleep, 100
        timeWaiting += 100
      }


      ;click refinateResource
      MouseClick, Left, arrowCorsX - 65, arrowCorsY + 43, 1, ConfigManager.mouseSpeed
      

      timeWaiting := 0
      Loop { ;wait for finish
        ImageSearch, corsX, corsY, 0, 0, Client.windowCors.x2, Client.windowCors.y2, *5 ./img/client/prometid.bmp

        if(ErrorLevel = 0) {
          break
        } else {

          if(timeWaiting >= 3000) {
            break
            return false
          }

          Sleep, 100
          timeWaiting += 100
        }
      }
    }
  }

  refinateAll() {
    Client.openRefinatorWindow()
    this.refinateResource("prometid")
    this.refinateResource("duranium")
    this.refinateResource("promerium")
    Client.closeRefinatorWindow()
  }
}