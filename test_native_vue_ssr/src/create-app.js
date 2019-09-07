import Vue from "vue"
import App from "./Hello.vue"
import { createStore } from "./store"

export function createApp() {
  const store = createStore()

  const app = new Vue({
    el: "#app",
    store,
    render: h => h(App)
  })

  return { app, store, App }
}

