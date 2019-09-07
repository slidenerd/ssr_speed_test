In this article, I will show how to prepare a webpack setup from scratch to develop Vue apps, complete with `webpack-dev-server` and hot reload. We will see how to use create `rules` for `loaders`, and how to use `plugins`.

The source code can be found [here](https://github.com/lmiller1990/webpack-simple-vue/tree/basic).

### Setup

First, start of with an empty `package.json` by running `echo {} >> package.json`.

Next, we need to install webpack, the cli tool and the dev server with 

```bash
npm install webpack webpack-cli webpack-dev-server --save-dev
```

Before going any further, run `npx webpack`. `npx` is a tool to execute binaries - webpack created one for us, located in `node_modules/.bin/webpack`.

We get two errors:

```
WARNING in configuration
The 'mode' option has not been set, webpack will fallback to 'production' for this value. Set 'mode' option to 'development' or 'production' to enable defaults for each environment.
You can also set it to 'none' to disable any default behavior. Learn more: https://webpack.js.org/concepts/mode/

ERROR in Entry module not found: Error: Can't resolve './src' in '/Users/lachlanmiller/javascript/vue/webpack-simple'
```

The first one is complaining about the `mode` option - default is `production`. Let's fix that, and also add an npm script to `package.json` at the same time:

```js
"scripts": {
  "dev": "npx webpack --mode development"
}
```

Now we have one more error - `Can't resolve './src'`. So let's make `src` with `mkdir src`, then `touch src/index.js`. Now `npm run dev` yields:

```bash

Hash: 52bc792a675c1ee221f2
Version: webpack 4.10.2
Time: 71ms
Built at: 2018-05-30 23:58:42
  Asset      Size  Chunks             Chunk Names
main.js  3.77 KiB    main  [emitted]  main
Entrypoint main = main.js
[./src/index.js] 0 bytes {main} [built]
```

It also created `dist/main.js`. Take a look - it contains about a hundred lines of webpack boilerplate, and nothing else, since `src/index.js` is empty at the moment.

### Making a `webpack.config.js`

The next step is to create a config file to store our webpack settings. Let's use the default, `webpack.config.js`. Create that at root level. Before going any further, we will add a plugin, `HtmlWebpackPlugin`, by running `npm install html-webpack-plugin --save-dev`. This plugin lets us create a default `index.html`. and load the webpack bundle. Our `index.html` will need an `<div id="app"></div>` for the Vue appplication to mount. Create the template first, called `template.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
</head>
<body>
  <div id="app"></div>
</body>
</html>
```

Now inside of `webpack.config.js`, add the first lines of the webpack config:

```js
const path = require("path")
const HtmlWebpackPlugin = require("html-webpack-plugin")

module.exports = {
  entry: "./src/index.js",

  plugins: [
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, "template.html")
    })
  ]
}
```

We specify the entry - normally you specify the `output` too, but if you don't, it defaults to `dist/main.js`. We imported the plugin, and passed the template we want to use. Running `npm run dev` yields the following output:

```bash
Hash: dae6c53437d700ae34a8
Version: webpack 4.10.2
Time: 410ms
Built at: 2018-05-31 00:10:02
     Asset       Size  Chunks             Chunk Names
   main.js   3.77 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
Entrypoint main = main.js
```

A bunch more stuff, of which the some I omitted, is printed. Notice we now have `index.html` - take a look in `dist/index.html`.

### Adding Vue

Finally, it is time to add Vue with `npm install vue --save`. Node.js does not support `import` and `export` by default (as of 10.3 it does, __experimentally__, more [here](https://nodejs.org/api/esm.html)). Webpack, however, does (I'm not exactly sure how, perhaps using babel internally?). Anyway, that means we can use `import` and `export`! Update `src/index.js`:

```js
import Vue from "vue"

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: "#app",
    
    data() {
      return {
        msg: "Hello"
      }
    },

    template: "<div>{{ msg }}</div>"
  })
})
```

Now run `npm run dev`. We now see:

```sh
Hash: 9c0afed8a7477e9712d1
Version: webpack 4.10.2
Time: 645ms
Built at: 2018-05-31 00:23:36
     Asset       Size  Chunks             Chunk Names
   main.js    317 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

Now `main.js` is 317 kb! That's HUGE! Mainly because we are using the full build of Vue, without any minifying and so forth. It's okay for now. Run a server in `dist`, for example on MacOS you can do `cd dist && python -m SimpleHTTPServer`, and visiting `localhost:8000` should yield this error in the console:

```bash
[Vue warn]: You are using the runtime-only build of Vue where the template compiler is not available. Either pre-compile the templates into render functions, or use the compiler-included build.
```

This is because are using a `template` to construct our Vue app - the compiler which converts `template` into HTML and JavaScript is not available when using the runtime-only build (`import Vue from "vue"`). We need to use compiler included build, for now. We will fix this soon. Instead using `import Vue from "vue/dist/vue.esm.js"`, and run `npm run dev` once again. Now you should see "Hello" displayed.

### Adding `vue-loader`

Once of the best features of Vue is single file components (`.vue` files). Let's refactor `src/index.js` to use one. Create `Hello.vue` in `src` with `touch src/Hello.vue`. Inside add the following:

```html
<template>
  <div>{{ msg }}</div>
</template>

<script>
export default {
  name: "Hello",

  data() {
    return {
      msg: "Hello"
    }
  }
}
</script>
```

Update `src/index.js` to use the new component:

```js
import Vue from "vue/dist/vue.esm.js"
import Hello from "./Hello.vue"

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: "#app",
    
    components: {
      Hello
    },

    template: "<Hello />"
  })
})
```

Run `npm run dev` to compile away. Alas!

```bash
ERROR in ./src/Hello.vue
Module parse failed: Unexpected token (1:0)
You may need an appropriate loader to handle this file type.
| <template>
|   <div>{{ msg }}</div>
| </template>
 @ ./src/index.js 2:0-31 9:6-11
```

Webpack hit an error at line 2 of `src/index.js`. Webpack only knows about `.js` files out the the box. We "need an appropriate loader" to handle `.vue` files. Run `npm install vue-loader --save-dev`. Now update `webpack.config.js`:

```js
const VueLoaderPlugin = require('vue-loader/lib/plugin')

module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: "vue-loader"
      }
    ]
  },

  plugins: [
    // ...
    new VueLoaderPlugin()
  ]
}
```

More about `vue-loader` is found [here](https://vue-loader.vuejs.org/guide/#manual-configuration).

Running `npm run dev` __should__ now work, but actually it doesn't. You get:

```bash
ERROR in ./src/Hello.vue
Module build failed: Error: Cannot find module 'vue-template-compiler'
```

And several screens of webpack/vue-loader stacktraces. This is because `vue-loader` lists `vue-template-compiler` as a `peerDependency`, you can see it [here](https://github.com/vuejs/vue-loader/blob/b1023cd7ccff0203025db44cd3088550b3ac8558/package.json#L37), which means even though it isn't listed as a dependency, you need to have it installed. This sucks, it should be a dependency, but it's not for some reason (probably a good one, if you know please tell me). 

Anyway, as the error suggests we should run `npm install vue-template-compiler --save-dev`. Now `npm run dev` works! Visiting your server (mine is `localhost:8000`) should still show the Hello message.

```bash
Hash: fbbc205659d2efc8f1c6
Version: webpack 4.10.2
Time: 904ms
Built at: 2018-05-31 21:17:47
     Asset       Size  Chunks             Chunk Names
   main.js    327 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

Remember 327 KiB - this is about to get a lot smaller.

### Using a render function

Remember when we used `vue/dist/vue.esm.js` instead of just `vue`? Now it the time to fix it. The reason is the standard build does not include `vue-template-compiler`. This makes it slightly lighter. We will compile `.vue` files on the server, but in the production code, we will use a `render` function instead to make the bundle slightly lighter.

Update `src/index.js`:

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

Much nicer. Run `npm run dev`:

```bash
Hash: 97e9a78ffb673fafd97b
Version: webpack 4.10.2
Time: 821ms
Built at: 2018-05-31 21:18:35
     Asset       Size  Chunks             Chunk Names
   main.js    245 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

Actually, now the bundle is 245 KiB - a significant improvement from 327 KiB. Also, the code looks a bit nicer.

### Webpack Dev Server

Now the exciting part, the `dev-server`. Until now, we were building a new bundle (by hand) and refreshing `localhost:8000` like suckers. Let's automate that with `webpack-dev-server`. We installed `webpack-dev-server` at the start, so you should be able to use it already by running `npx webpack-dev-server`.

```bash
ℹ ｢wds｣: Project is running at http://localhost:8080/
ℹ ｢wds｣: webpack output is served from /
⚠ ｢wdm｣: Hash: 55f5a357f2dc60279c3f
Version: webpack 4.10.2
Time: 1210ms
Built at: 2018-05-31 21:26:08
     Asset       Size  Chunks             Chunk Names
   main.js    204 KiB       0  [emitted]  main
index.html  191 bytes          [emitted]
```

As noted, it is running at `localhost:8080`. You don't need your python server anymore! Visit `localhost:8080` and then try editing `src/Hello.vue`. When you save the file, it should automatically update. Occasionally doesn't, but mostly the dev server is pretty good and saves a lot of manually refreshing. It also preserves the state of the app (sometimes). `main.js` is now only 204 KiB, I am not sure why it is smaller when running the dev server.

Let's add a script in `package.json`:

```js
"scripts": {
  "build": "npx webpack",
  "dev": "npx webpack-dev-server --mode development"
}
```

The old `dev` script is now `build`. It will have `--mode production` at a later date. Lastly, we can add a few options to `webpack.config.js` to make the dev server a bit better. 

```js
module.exports = {
  // ...
  devServer: {
    overlay: true
  }
}
```

Now if there is a problem in our code, it will appear in the browser, so we can find it more quickly. Try creating a syntax error, and you should see something like this:

```bash
Failed to compile.

./src/Hello.vue?vue&type=script&lang=js (./node_modules/vue-loader/lib??vue-loader-options!./src/Hello.vue?vue&type=script&lang=js)
Module parse failed: Unexpected token (11:19)
You may need an appropriate loader to handle this file type.
|   data() {
|     return {
|       msg: "Hello",,
|     }
|   }
```

I added a extra `,`. `You may need an appropriate loader to handle this file type.` is probably not the most useful error message, but it's still faster than switching back to the terminal or checking the console. The line number is generally enough to help you find the problem.

### Summary

In this post, we

- setup up a `webpack.config.js` from scratch
- __understood__ every part of it
- learned how to use plugins (`HtmlWebpackPlugin`, `VueLoaderPlugin`)
- learned how to add `module rules`, to tell webpack how to pass certain files (`.vue`)

The total code in `webpack.config.js` is less than 30 lines, and not that complex. We now have a good base for modern development environment.

### Improvements

We can improve the webpack setup presented in a number of ways:

- add `babel-loader` to let us compile to ES5, to support old JavaScript (ew)
- add `babel-loader` to let us compile from ES7, ES8, and support new JavaScript (yay!)
- add [UgliyJsWebpackPlugin](https://github.com/webpack-contrib/uglifyjs-webpack-plugin) and make our bundle even smaller for production

And plenty more. A complex webpack config is daunting, but if you pull it into smaller pieces, each having a single, dedicated responsibility, suddenly it is't so difficult to understand. If something is difficult to understand, such as webpack, break it down into smaller pieces, until it is easy to understand.

The source code can be found [here](https://github.com/lmiller1990/webpack-simple-vue/tree/basic).

