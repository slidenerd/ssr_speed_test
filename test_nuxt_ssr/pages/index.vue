<template>
  <div class="container">
    <h1>Express</h1>
    <p>Welcome to Express</p>
    <hello></hello>
  </div>
</template>

<script>
import Hello from "~/components/Hello.vue";

export default {
  components: {
    Hello
  }
};
</script>