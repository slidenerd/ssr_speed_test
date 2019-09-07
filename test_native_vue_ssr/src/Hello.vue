<template>
  <div>
    <h1>Express</h1>
    <p>Welcome to Express</p>
    <p>{{ greeting }} I am a Vue Component!</p>
  </div>
</template>

<script>
module.exports = {
  asyncData(store) {
    return store.dispatch("fetchPost");
  },
  mounted() {
    this.$store.dispatch("fetchPost");
  },

  data: function() {
    return {
      greeting: "Hello"
    };
  },
  computed: {
    post() {
      return this.$store.state.post;
    }
  }
};
</script>

