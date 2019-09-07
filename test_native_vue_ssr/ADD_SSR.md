In this article, I will continue on from the work in my previous post, where I set up a webpack config from scratch for Vue. I will now add support for server side rendering, with `vue-server-renderer`. 

Server side rendering is where the HTML for the application is constructed dynamically by the server using Node.js. The newly rendered HTML is then sent back in the response. This is in contrast to client side rendering, where JavaScript bundled by Webpack is to the client as is, where it is processed by the browser JavaScript engine. There are benefits to both approaches, which will not be discussed in this post.

The source code can be found [here](https://github.com/lmiller1990/webpack-simple-vue/tree/add_server_rendering).

## Splitting `webpack.config.js`

A different webpack config is required, depending on whether the application is rendered on server or the client. We want to support both - for development, `webpack-dev-server` is a powerful tool, which delegates the processing and rendering to the client. In production, we will render on the server. A lot of the webpack config can be shared, such as `module`, where we declare `loaders`. Create a folder and two new files for the non unique webpack settings:

```
mkdir config && touch config/client.js config/server.js
```

The current `webpack.config.js` contains four properties:

1. entry
2. module
3. plugins
4. dev-server

`module` contains the loading rules for `.vue` files, which both server and client rendering requires. The rest of the properties will be unique the client rendering, so move them to `config/client.js`:

```js
const path = require("path")
const HtmlWebpackPlugin = require("html-webpack-plugin")

module.exports = {
  entry: "./src/index.js",

  plugins: [
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, "template.html")
    })
  ],

  devServer: {
    overlay: true
  }
}
```

Add a minimal setup in `config/server.js`:

```js
const path = require("path")

module.exports = {
}
```

Also, move `template.html` into `config`: 

```
mv template.html config/template.html
```

`npm run dev` shoud still work.

## Adding `webpack-merge`

There is some duplication in `webpack.config.js` now. We have to join the base config and with client by typing

```js
plugins: [
  VueLoaderPlugin(), 
  config.HtmlWebpackPlugin: ...
]
```

When we add some server configuration, it will then look like:

```js
plugins: [
  VueLoaderPlugin(), 
]

if (development) 
  plugins.push(HtmlWebpackPlugin)
else if (production) 
  plugins.push(some production only plugin...)
```

This gets confusing very quickly. There is a better way: `webpack-merge`, which will handle the merging for us.

```
npm install webpack-merge --save
```

Now use `webpack-merge` to clean up `webpack.config.js`:

```js
const VueLoaderPlugin = require("vue-loader/lib/plugin")
const merge = require("webpack-merge")
const clientConfig = require("./config/client")
const serverConfig = require("./config/server")

const commonConfig = {
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: "vue-loader"
      }
    ]
  },

  plugins: [
    new VueLoaderPlugin(),
  ]
}

module.exports = mode => {
  if (mode === "development") {
    return merge(commonConfig, clientConfig, {mode})
  }

  if (mode === "production") {
    return merge(commonConfig, serverConfig, {mode})
  }
}
```

Now `module.exports` returns a function. Webpack checks for the presence of a function exported from `webpack,config.js`, and if it is one, calls it with a `mode` argument. `mode`, oddly enough, corresponds to the `--env` argument, not `--mode`, so update the `scripts` section in `package.json`:

```js
"scripts": {
  "build": "npx webpack --env production",
  "dev": "npx webpack-dev-server --env development"
 }
```

`npm run dev` should still be working fine. If you visit `localhost:8080`, inspect the source of the page (not using the devtools, the actual page source) you should see:


```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
</head>
<body>
  <div id="app"></div>
<script type="text/javascript" src="main.js"></script></body>
</html>
```

Notice the `msg`, `Hello` does not appear here - that is because it is rendered on the *client*. We will see a different page source when rendering on the server.

## The server side `entry`

The server rendering bundle will use a different entry point. Create a file for it:

```
touch src/create-app.js
```

This fuction will create the Vue app which we want to render. Add the following code:

```js
import Vue from "vue"
import Hello from "./Hello.vue"

export function createApp() {
  return new Vue({
    el: "#app",
    render: h => h(Hello)
  })
}
```

Look familiar? It is similar to the code in `src/index.js`. Take a look:

```js
import Vue from "vue"
import Hello from "./Hello.vue"

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: "#app",
    
    render: h => h(Hello)
  })
})
```

The difference is `document.addEventListener...`. `document` and the other Web APIs are not available in Node.js, which is why we need two different renderers. Refactor `src/index.js`:

```js
import {createApp} from "./create-app"

document.addEventListener("DOMContentLoaded", () => {
  createApp()
})
```

Let's try out new production config.

```
npm run build
```

```
Built at: 2018-06-03 22:48:16
  Asset      Size  Chunks             Chunk Names
main.js  66.2 KiB       0  [emitted]  main
Entrypoint main = main.js
[0] (webpack)/buildin/global.js 489 bytes {0} [built]
[2] ./src/create-app.js + 6 modules 4.59 KiB {0} [built]
    | ./src/create-app.js 150 bytes [built]
    | ./src/Hello.vue 1.05 KiB [built]
```

Looks good. Let's see if we can use the module in a Node.js environment:

```js
node
> const { createApp } = require("./dist/main")
undefined
> createApp()
TypeError: createApp is not a function
>
```

We have a problem.

## `output.library` and `output.libraryTarget`

We need to set some `output` options in `config/server.js`. The documetation for `output` is [here](https://webpack.js.org/configuration/output/).

We are interested in `library` and `libraryTarget`. The defaults are:

```js
output: {
  libraryTarget: "var",
  library: undefined
}
```

`var` means webpack will assign our exports to `var`, which are attached to the `window` object for use in the browser (a UMD. Since `library` is undefined, however, webpack simply does nothing. Although the variable isn't assigned, in `src/index.js` we do:

```js
document.addEvenListener("DOMContentLoaded" ...)
```

So the Vue app still mounts. To get an idea of the options and what they do, run

```
mv dist/main.js dist/main_2.js
```

And try adding the following:


```
output: {
  libraryTarget: "var",
  library: "Bundle"
}
```

And run `npm run build`. Let's compare the two:


```
diff dist/main.js dist/main_2.js

< var Bundle=function(t){var e={};function n(r){if(e[r])return...

---

> !function(t){var e={};function n(r){if(e[r])return...
```

Now our bundle is assigned to a variable called `Bundle`. If you want, `cd dist && python -m SimpleHTTPServer`, then in the browser console and check:

```
> window.Bundle

Module {
  __esModule: true, 
  Symbol(Symbol.toStringTag): "Module"
}
createApp: (...)Symbol(Symbol.toStringTag): "Module"
__esModule: true
get createApp: ƒ ()
__proto__: Object

> Bundle.createApp

ƒ s(){return new r.a({el:"#app",render:t=>t(a)})}
```

We want to execute in a Node.js environment. We we need to target `commonjs2`. Update `config/server.js`:

```js
const path = require("path")

module.exports = {
  entry: "./src/create-app.js",

  output: {
    libraryTarget: "commonjs2"
  }
}
```

And run `npm run build`. Let's compare the outputs again with `diff dist/main.js dist/main_2.js`

```js
< !function(t){var e={};function n(r){if(e[r])return...

---

> < module.exports=function(t){var e={};function n(r){if(e[r])return
```

Looks good! Now we have `module.exports`. We can check using Node:

```
node
> const {createApp} = require("./dist/main")
> createApp
[Function: s]
```

There are other things you can pass to `library` and `libraryTarget` - find out more in the [documentation](https://webpack.js.org/configuration/output/).

## Adding a server (express)

Now that we have a way to create the Vue app on the server, we need to serve it somehow. The easiest way to see this in action is with an express server. I personally like Rails better, and will go into that in a future article.

Anyway, add `express`, and `vue-server-renderer`

```
npm install express vue-server-renderer --save
```

Create a file for the server code with `touch src/server.js`.

```js
const express = require("express")
const renderer = require("vue-server-renderer").createRenderer()
const {createApp} = require("../dist/main")

const server = express()

server.get("*", (req, res) => {
  const app = createApp()

  renderer.renderToString(app).then(html => {
    res.end(html)
  })
})

server.listen(8000, () => console.log("Started server on port 8000."))
```

There are two interesting parts here:

```js
const renderer = require("vue-server-renderer").createRenderer()
```

Which instantiates an server renderer instance, and:

```js
renderer.renderToString(app).then(html => {
  res.end(html)
})
```

Which takes our app, renders it and returns the markup as a string. All that is left is to serve the markup to the user. More info about Vue server renderer is [here](https://ssr.vuejs.org/guide/#rendering-a-vue-instance).

We can try out by running:

```
npm run build && node src/server.js
```

If everything it working, you can now visit `localhost:8000` and you should see the same old hello message. However, inspecting the element using the devtools shows:

```
<div data-server-rendered="true">Hello</div>
```

Indicating it was rendered on the server. Let's compare the page source to the client rendered source, shown earler:

### client rendered:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
</head>
<body>
  <div id="app"></div>
<script type="text/javascript" src="main.js"></script></body>
</html>
```

### server rendered:

```
<div data-server-rendered="true">Hello</div>
```

Notice `<div app>` is not shown anywhere? It is replaced when we we generate the markup using the server renderer, so all that is served is the actual markup.

## Conclusion

In this article, we covered:

- the different environments webpack can target
- how to use `webpack-merge`
- how to user `library` and `libraryTarget`
- refactor and share code between the server and client

## Improvments

Many improvements are left, which will be covered in the future, such as:

- hydrating the app on the server (server rendering using some dynamic data like the user id)
- routing (both client and server)
- use ES6 syntax, like `import` and `export` in Node.js with babel

The source code can be found [here](https://github.com/lmiller1990/webpack-simple-vue/tree/add_server_rendering).
