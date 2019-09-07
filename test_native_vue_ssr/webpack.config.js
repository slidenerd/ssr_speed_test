const merge = require("webpack-merge")
const VueLoaderPlugin = require("vue-loader/lib/plugin")
const clientConfig = require("./config/client")
const serverConfig = require("./config/server")

const commonConfig = {
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: "vue-loader"
      },
    ]
  },

  plugins: [
    new VueLoaderPlugin(),
  ]
}

module.exports = mode => {
  if (mode === "development") {
    return merge(commonConfig, clientConfig, { mode })
  }
  if (mode === "production" || mode === "none") {
    return merge(commonConfig, serverConfig, { mode })
  }
}

