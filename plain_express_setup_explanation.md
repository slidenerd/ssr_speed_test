
Setup for plain express

 1. We use the [express-generator](https://www.npmjs.com/package/express-generator) to get a skeleton running.
 2. We do an ncu first using the [node-check-updates](https://www.npmjs.com/package/npm-check-updates) package discussed above.
 3. Take note of the versions of debug, cookie-parser, express and pug in case the packages break after updating
 4. Now do an ncu -u to update all packages to the latest version.
 5. We are going to setup [Server Side Rendering](https://stackoverflow.com/questions/16173469/what-is-server-side-rendering-of-javascript) on this simple boilerplate without using any of the fancy libraries that you keep hearing about on HackerNews and HackerNoon
 6. We first install [laravel-mix](https://laravel-mix.com/docs/4.1/installation) using the command below
 7. Laravel Mix is a nice shortcut to configure webpack quickly if you dont want to sit and fiddle with all the modules, loaders and plugins.
 8. npm i --save-dev laravel-mix
 9. Run the command below to generate a webpack config quickly
 10. cp node_modules/laravel-mix/setup/webpack.mix.js ./
 11. Add a folder called assets into the root of the plain_express folder
 12. Add multiple folders assets => js, assets => css, assets => components
 13. assets => js folder contains our client side JavaScript files that use Babel by default
 14. assets => css folder will contain our SCSS stylesheets
 15. asssets => components folder will contain our .vue components!
 16. Modify the public folder to also contain js and css folders inside.
 17. Currently, the public folder contains javascripts and stylesheets folder, lets remove them
 18. Open the views => layout.pug file
 19. We are going to remove any references to link tags or script tags
 20. Replace them with the following
 21. :mix(css) '/css/app.css'
 22. :mix(js) '/js/manifest.js'
 23. :mix(js) '/js/vendor.js
 24. :mix(js) '/js/app.js'
 25. The idea here is that we use [pug filters](https://pugjs.org/language/filters.html) and replace the links with the links to the file webpack generates after build
```
    app.use((req, res, next) => {
      app.locals.filters  = {
        mix: (text, options) => {
          const  newText  =  text.replace(/['"']/g, '');
          return  options.js  ?  `<script type="text/javascript" src="${manifest[newText]}"></script>`  :  `<link rel="stylesheet" type="text/css" href="${manifest[newText]}">`;
        },  
      };
      next();
    });
``` 
 26. Add the middleware above inside the express app.js file
 27. Add the line below at the top
 28. `var  manifest  =  require('./public/mix-manifest.json');`
 29. Laravel Mix generates a manifest which contains an object map where key is the uri of the css file before webpack was run and value is the uri of the css file after running build process.
 30. In simple words, we substitute the script tag links and css links with what webpack generates.
 31. Given we have assets => components folder setup with .vue components inside which are referenced by the javascript files inside assets => js folder, what we have is full blown custom server side rendering setup!!!