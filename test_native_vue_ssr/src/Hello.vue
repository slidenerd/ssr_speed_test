<template>
  <div>
    <h1>Express</h1>
    <p>Welcome to Express</p>
    <p>{{ greeting }} I am a Vue Component!</p>
  </div>
</template>

<script>
module.exports = {

  data: function() {
    return {
      greeting: "Hello"
    };
  }
};
</script>

