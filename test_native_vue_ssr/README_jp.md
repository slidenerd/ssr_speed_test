この記事でゼロからVueに使える`webpack`環境を立ち上げます。フィーチャー：

- `webpack-dev-server`
- ホットリロード
- ローダーの使い方(`vue-loader`)
- プラグインの使い方(`HtmlWebpackPlugin`)
- [Vueのビルド](https://jp.vuejs.org/v2/guide/installation.html#%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%93%E3%83%AB%E3%83%89%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)の違いの説明。(`umd`, `common`, `esm`)

[ソースはここです](https://github.com/lmiller1990/webpack-simple-vue/tree/basic)。

## 設定

`package.json`をつくります。

```bash
echo {} >> package.json
```

`webpack`、`cli`、`webpack-dev-server`をインストールします。

```
npm install webpack webpack-cli webpack-dev-server --save-dev
```

動いているか確認します。`npx webpack`. `npx`はNode.jsのバイナリーを実行するツールです。インストールしたバイナリーは`node_modules/.bin`にあります。

```
ls node_modules/.bin | grep web

webpack
webpack-cli
webpack-dev-server
```

`npx webpack`を実行すると、２つのエラーが出て来ます。



```sh
WARNING in configuration
The 'mode' option has not been set, webpack will fallback to 'production' for this value. Set 'mode' option to 'development' or 'production' to enable defaults for each environment.
You can also set it to 'none' to disable any default behavior. Learn more: https://webpack.js.org/concepts/mode/
```

2.

```
ERROR in Entry module not found: Error: Can't resolve './src' in '/Users/lachlanmiller/javascript/vue/webpack-simple'
```

1個目は`mode`と関係があります。`mode`を設定しないと、デフォルトは`production`。設定しましょう。`package.json`の中で`scripts`に`dev`コマンドを追加します：

```js
"scripts": {
  "dev": "npx webpack --mode development"
}
```

これから`npm webpack`ではなく`npm run dev`で実行します。

次のエラーは：

```
Can't resolve './src' in ...
```

ウェブパックのデフォルトエントリーポイントは`src.index.js`。まだ`webpack.config.js`を作っていないのでそこで探しています。作りましょう。

``` 
mkdir src && touch src/index.js
```

`npm run dev`を実行すると：

```

Hash: 52bc792a675c1ee221f2
Version: webpack 4.10.2
Time: 71ms
Built at: 2018-05-30 23:58:42
  Asset      Size  Chunks             Chunk Names
main.js  3.77 KiB    main  [emitted]  main
Entrypoint main = main.js
[./src/index.js] 0 bytes {main} [built]
```

バンドルしたコードを`dist/main.js`にあります。

## Hello Webpack

上のアウトプットを見ると`3.77 KiB`が書いてあります。なぜ？まだコードを１行もを書いていません！

確認してみてください。`cat dist/main.js`を実行すると、１００行くらいのコードがあって、最後に

```
/***/ "./src/index.js":
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
/*! no static exports found */
/***/ (function(module, exports) {

eval("\n\n//# sourceURL=webpack:///./src/index.js?");

/***/ })

/******/ });
```

これはバンドルした`src/index.js`。まだ何も書いていないので何もないです。`src/index.js`を更新します：

```js
const HELLO = "WORLD"
```

そして`npm run dev && cat dist/main.js`：

```java
/***/ "./src/index.js":
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
/*! no static exports found */
/***/ (function(module, exports) {

eval("const HELLO = \"WORLD\"\n\n\n//# sourceURL=webpack:///./src/index.js?");

/***/ })
```

入りました！バンドルのサイズを見てみると：

```
Built at: 2018-06-01 20:08:21
     Asset       Size  Chunks             Chunk Names
   main.js   3.79 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

`3.77 KiB -> 3.79 KiB`に増えました。

## `mode`

```
npx webpack --mode production
```

を実行して見ます。

```
Built at: 2018-06-01 20:09:43
     Asset       Size  Chunks             Chunk Names
   main.js  930 bytes       0  [emitted]  main
index.html  191 bytes          [emitted]
```

`930 bytes`になりました！ `cat dist/main.js`を実行すると：

```
!function(e){var t={};function r(n){if(t[n])return t[n].exports;var o=t[n]={i:n,l:!1,exports:{}};return e[n].call(o.exports,o,o.exports,r),o.l=!0,o.exports}r.m=e,r.c=t,r.d=function(e,t,n){r.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:n})},r.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},r.t=function(e,t){if(1&t&&(e=r(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var n=Object.create(null);if(r.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var o in e)r.d(n,o,function(t){return e[t]}.bind(null,o));return n},r.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return r.d(t,"a",t),t},r.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},r.p="",r(r.s=0)}([function(e,t){}]);%
```

長い１行だけです。ミニファイしてくれました。

```
cat dist/main.js | grep WORLD
```

すると、何も出てこないです。`dist/main.js`を目で確認したら、びっくりします。`const HELLO = "WORLD"`がなくなりました。なぜ？変数を定義したが、使っていないのでウェブパックを無視して削除してくれました。`production`モードなので、できるだけバンドルを小さくしてくれました。`src/index.js`を更新します：

```js
export const HELLO = "WORLD"
```

`npx webpack --mode production`を実行して、そして

```
cat dist/main.js | grep WORLD
```

ちゃんと出て来ました！目で確認すると、

```js
("use strict";r.r(t),r.d(t,"HELLO",function(){return n});const n="WORLD"}]);
```

のようなコードがあります。

## `webpack.config.js`

`config`ファイルを作りましょう。`touch webpack.config.js`。その中で、

```js
module.exports = {
  entry: "./src/index.js"
}
```

## `HtmlWebpackPlugin`

最初のプラグインを入れます。簡単な`index.html`を作るプラグインをインストールします：

```
npm install html-webpack-plugin --save-dev
```

Vueを入れたいので、`<div id="app"></div>`が必要です。欲しいテンプレートを作ります。`touch template.html`を実行して、このコードを入れます：

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

`webpack.config.js`を更新します：

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

`plugins`は配列です。使いたいプラグインを入れて、そして`options`オブジェクトを渡します。ここで`template`オプションで`HtmlWebpackPlugin`に使いたい`template`を渡します。

また`npm run dev`を実行して、`cat dist/index.html`をすると：

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

`HtmlWebpackPlugin`で

```
<script type="text/javascript" src="main.js"></script></body>
```

入りました。

## `Vue`を追加

ようやく`Vue`を入れます。

```js
npm install vue --save
```

普段は`babel`などでコンパイルしないと`import`, `export`を使えないですが、`webpack`でバンドルしているので`import`と`export`が使えます！`src/index.js`を更新：

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

`npm run dev`。そして：

```
Hash: 9c0afed8a7477e9712d1
Version: webpack 4.10.2
Time: 645ms
Built at: 2018-05-31 00:23:36
     Asset       Size  Chunks             Chunk Names
   main.js    317 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

`317 KiB`になりました。`Vue`をミニファイしていないビルドを使っているので大きいです。とりあえず大丈夫です。あとで直します。

サーバーを立ち上げると、ブラウザでバンドルした`main.js`が動けるはずです。パイソンでサーバーを実行します：

```
cd dist && python -m SimpleHTTPServer
```

そして`localhost:8000`にアクセスと・・・何もないです。ブラウザのコンソールを見ると：

```
[Vue warn]: You are using the runtime-only 
build of Vue where the template compiler is not available. 
Either pre-compile the templates into render functions, 
or use the compiler-included build.
```

理由は、`template`オプションでヴVueのマークアップで作っていることです。

```
template: "<div>{{ msg }}</div>"
```

`vue-template-compiler`はこのビルドに入っていないので、上のコードをコンパイルできません。`Node.js`で`import`するとこれはデフォルトとなります。`src/index.js`を更新します：

```js
import Vue from "vue/dist/vue.esm.js"
```

エラーが消えたはずです。Helloが見えるはずです。

## `vue-loader` (`.vue`ファイル）

`.vue`ファイルを使って見ましょう。

```
touch src/Hello.vue
```

そしてこのコードを入れます：

```vue
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

`src/index.js`を更新してコンポーネントを使って見ます：

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

`npm run dev`を実行したら：

```
ERROR in ./src/Hello.vue
Module parse failed: Unexpected token (1:0)
You may need an appropriate loader to handle this file type.
| <template>
|   <div>{{ msg }}</div>
| </template>
 @ ./src/index.js 2:0-31 9:6-11
```

`webpack`は`.vue`ファイルの読み込み方がわからないので。`You may need an appropriate loader`というエラーが出て来ました。デフォルトの設定で、`.js`しか読み込めないです。インストールしましょう：

```
npm install vue-loader --save-dev
```

そして`webpack.config.js`を更新する：

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

`vue-loader`の細かいは[ここ](https://vue-loader.vuejs.org/)。日本語がありません。

また`npm run dev`を実行すると、うまくいくはずなのに・・・

```
ERROR in ./src/Hello.vue
Module build failed: Error: 
Cannot find module 'vue-template-compiler'
```

なぜかというと、`vue-loader`は`vue-template-compiler`を`peerDependency`として使っています。そうなると、`npm install`を実行しても、インストールされません。

```
npm install vue-template-compiler --save-dev
```

で対応できます。

そして`npm run dev`を実行して、動いているはずです。（まだ`python`サーバーを立ち上げていたなら。）

```
Built at: 2018-05-31 21:17:47
     Asset       Size  Chunks             Chunk Names
   main.js    327 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

`327 KiB`を覚えてください。もうすぐ軽くなります。

## `render`関数でバンドルを軽く

`vue/dist/vue.esm.js`を使う前のエラーメッセージをレビューします：

```
Either pre-compile the templates into render functions, 
or use the compiler-included build.
```

前は、`vue/dist/vue.esm.js`を使うことで、`compiler`を入れました。その代わりに、`render`関数を使ってみましょう。`src/index.js`を更新します：

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

`render`関数を使うことで、もう少しシンプルになりました。`npm run dev`を実行して：

```
Built at: 2018-05-31 21:18:35
     Asset       Size  Chunks             Chunk Names
   main.js    245 KiB    main  [emitted]  main
index.html  191 bytes          [emitted]
```

`245 KiB`になりました！`327 KiB`より全然軽くなりました。`--mode production`なら：

```
     Asset       Size  Chunks             Chunk Names
   main.js   66.2 KiB       0  [emitted]  main
index.html  191 bytes          [emitted]
```

`66.2 KiB`となります。

## `dev-server`とホットリロード

`webpack-dev-server`を簡単に使えます。


```
npx webpack-dev-server
```

だけで実行できます。

```
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

`http://localhost:8080/`にアクセスすると、見れるはずです。`python`のサーバーがいらなくなりますた。`Hello.vue`を更新して、保存すると自動に更新されるはずです。

`webpack.config.js`をもう一回更新します：

```js
module.exports = {
  // ...
  devServer: {
    overlay: true
  }
}
```

すると、JSのコンパイルエラーがあれば、ブラウザのオーバーレイで表示されます。

## まとめ

この記事で：

- ゼロから`webpack.config.js`を作りました
- `webpack`の設定が理解しました
- プラグインの使い方を学びました
    - `VueLoaderPlugin`
    - `HtmlWebpackPlugin`
- `module`に`rules`を追加ました
    - `test: /\.vue$/`

３０行だけの`webpack.config.js`だけでモダーン開発環境を作りました。

## 改善

- `babel-loader`を追加して、古いブラウズをサポートする（泣）
- `babel-loader`を追加して、新しいES7などをサポートする(嬉)

[ソースはここです](https://github.com/lmiller1990/webpack-simple-vue/tree/basic)。


