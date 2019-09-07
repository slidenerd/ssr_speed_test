const path = require("path")

module.exports = {
  entry: "./src/create-app.js",

  target: "node",

  output: {
    libraryTarget: "commonjs2"
  }
}
