exports.config = {
  notifications: false,
  watcher: {
    awaitWriteFinish: true,
    usePolling: true
  },
  files: {
    javascripts: {
       joinTo: {
        "js/app.js": /^(web\/static\/js)/,
        "js/vendor.js": /^(node_modules)/
       },
       order: {
         before: []
       }
    },
    stylesheets: {
      joinTo: "css/app.css"
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      presets: [
        "env",
        "react"
        // [ "env", {
        //   "targets": {
        //     browsers: '> 2%'
        //   }
        // }]
      ],
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      mode: 'native',
      options: ['--verbose']
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true,
    // Whitelist the npm deps to be pulled in as front-end assets.
    // All other deps in package.json will be excluded from the bundle.
    //whitelist: ["popper.js", "bootstrap", "phoenix", "phoenix_html", "react", "react-dom", "react-select", "react-tag-input", "react-dnd", "react-dnd-html5-backend", "jquery", "pickadate"]
  }
};
