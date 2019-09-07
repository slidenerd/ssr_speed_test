This article will continue on from my [previous post](https://itnext.io/setting-up-webpack-for-ssr-with-vue-b6ff9125d359), where we implemented basic server side rendering. Now we will add hydration. If the application relies on an external resource, for example data retreived from an external endpoint, the data needs to be fetched and resolved __before__ we call `renderer.renderToString`.

For this example, we will fetch a post from [JSONPlaceholder](https://jsonplaceholder.typicode.com/posts/1). The data looks like this:

```json
{
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"
}
```

The strategy will go like this:

Client Side Rendering:

- in the App's `mounted` lifecycle hook, `dispatch` a Vuex `action`
- `commit` the response
- render as usual

Server Side Rendering:

- check for a static `asyncData` function we will make
- pass the store to `asyncData`, and call `dispatch(action)`
- commit the result
- now we have the required data, call `renderer.renderToString`

### Setup

We need some new modules. Namely:

- `axios` - a HTTP Client that works in a browser and node environment
- `vuex` - to store the data

Install them with:

```
npm install axios vuex --save
```


### Create the store

Let's make a store, and get it working on the dev server first. Create a store by running `touch src/store.js`. Inside it, add the following:

//# add-hydration:src/store.js?7824c789d5a62a81e3ab9d80c5121e24d11e793f

Standard Vuex, nothing special, so I won't go into any detail.

We need to use the store now. Update `create-app`:


//# add-hydration:src/create-app.js?7824c789d5a62a81e3ab9d80c5121e24d11e793f

We are now returning `{ app, store, App }`. This is because we will need access to both `App` and `store` in `src/server.js` later on.

If you run `npm run dev`, and visit `localhost:8080`, everything should still be working. Update `src/Hello.vue`, to dispatch the action in `mounted`, and retreive it using a `computed` property:

//# add-hydration:src/Hello.vue:1,2,3,4,5,6,9,12,13,14,27?c0a305b6e6cd8c2e0bcfd516ef30ebd0646c3884

`localhost:8080` should now display the `title` as well as `Hello`.

### Fetching the resources on the server

Run `npm run build && node src/server.js`, then visit `localhost:8000`. You will notice `Hello` is rendered, but the `post.title` is not. This is because `mounted` only runs in a browser. There are no dynamic updated when using SSR, only `created` and `beforeCreate` execute. See [here](https://ssr.vuejs.org/guide/universal.html#component-lifecycle-hooks) for more information. We need another way to dispatch the action.

In `Hello.vue`, add a `asyncData` function. This is not part of Vue, just a regular JavaScript function.

//# add-hydration:src/Hello.vue:12,13,14?69a413a30349d1ddc88e56d367b9547d23c09117

We have to pass `store` as an argument. This is because `asyncData` is not part of Vue, so it doesn't have access to `this`, so we cannot access the store - in fact, because we will call this function before calling `renderer.renderToString`, `this` doesn't even exist yet.

Now update `src/server.js` to call `asyncData`:

//# add-hydration:src/server.js:8-16?69a413a30349d1ddc88e56d367b9547d23c09117

Now we when render `app`, `store.state` should already contain `post`! Let's try it out:

```
npm run build && node src/server.js
```

Visting `localhost:8000` causes a error to be shown in the terminal:

```
(node:9708) UnhandledPromiseRejectionWarning: ReferenceError: XMLHttpRequest is not defined
    at /Users/lachlanmiller/javascript/vue/webpack-simple/dist/main.js:7:63038
    at new Promise (<anonymous>)
    at t.exports (/Users/lachlanmiller/javascript/vue/webpack-simple/dist/main.js:7:62939)
    at t.exports (/Users/lachlanmiller/javascript/vue/webpack-simple/dist/main.js:12:10624)
    at <anonymous>
    at process._tickCallback (internal/process/next_tick.js:188:7)
```

`XMLHttpRequest` is Web API, and does not exist in a Node environment. But why is this happening? `axios` is meant to work on both the client and server, right?

Let's take a look at `axios`:

```
cat node_modules/axios/package.json
```

There is a bunch of stuff. The fields are interested in are `browser` and `main`:

```
"main": "index.js"

...

"browser": {
  "./lib/adapters/http.js": "./lib/adapters/xhr.js"
}
```

`browser` is the source of the problem. See more about [browser](https://docs.npmjs.com/files/package.json#browser) on npm. Basically, if there is a `browser` field, and the `target` of the webpack build is `web`, it will use the `browser` field instead of `main`. Let's review our `config/server.js`:

//# add-hydration:config/server.js?69a413a30349d1ddc88e56d367b9547d23c09117

We did not specify `target`. If we check the documentation [here](https://webpack.js.org/concepts/targets/#multiple-targets), we can see that the default value for `target` is web. This means we are using the `axios` build intended for the client instead of the Node.js build. Update `config.server.js`:

//# add-hydration:config/server.js?d62db2ddb776beff22a453acd1aa23ff0a0bfa71

Now run 

```
npm run build && node src/server.js
```

 and visit `localhost:8000`. The `title` is rendered! Compare it to `localhost:8080` using the dev server - you can see that when we do the client side fetching, the title is blank briefly, until the request finished. Visiting `localhost:8000` doesn't have this problem, since the data is fetched before the app is even rendered.

### Conclusion

We saw how to write code that runs both on the server and client. This configuration is by no means robust and is not meant for use in a serious app, but illustrates how to set up different webpack configs for the client and server. 

In this post we learned:

- about `package.json`, specifically the `browser` property
- webpack's `target` property
- how to execute an ajax request on both the client and server

### Improvements

Many improvements remain:

- use Vue Router (both server and client side)
- more robust data fetching
- add some unit tests

The source code is available [here]().
