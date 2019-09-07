import Vue from 'vue';
import Vuex from 'vuex';

import Hello from '../components/Hello.vue';

Vue.use(Vuex);

new Vue({
  el: '#app',
  components: { Hello }
});