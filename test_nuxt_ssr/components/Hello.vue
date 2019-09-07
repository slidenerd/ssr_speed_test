<template>
  <p>{{ greeting }} I am a Vue Component!</p>
</template>

<script>
module.exports = {
  data: function () {
    return {
      greeting: 'Hello'
    }
  }
}
</script>