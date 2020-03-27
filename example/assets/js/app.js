import css from "../css/app.css"
import "phoenix_html"

import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}

Hooks.Jumpers = {
  updated() {
    jump("#" + this.el.getAttribute("phx-value-dir"), 100);
  }
}

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks })

liveSocket.connect()

function backToRegular(targ) {
  $(targ).removeClass("larger");
}

function jump(targ, to) {
  $(targ).addClass("larger");
  setTimeout(backToRegular, to, targ)
}
