import Vue from "vue"
import App from "./Hello.vue"
import { createStore } from "./store"

export function createApp() {
  const app = new Vue({
    el: "#app",
    render: h => h(App)
  })

  return { app, App }
}

