import Vue from "vue"
import Vuex from "vuex"
import axios from "axios"

Vue.use(Vuex)

export function createStore() {
  return new Vuex.Store({
    state: {
      post: {}
    },

    mutations: {
      SET_POST(state, { post }) {
        state.post = {...state.post, ...post}
      }
    },

    actions: {
      fetchPost({ commit }) {
        return axios.get("https://jsonplaceholder.typicode.com/posts/1")
          .then(response => commit("SET_POST", { post: response.data }))
      }
    }
  })
}
