# REQUIRES

dotenv = require("dotenv").load()
gulp = require "gulp"
jade = require "gulp-jade"
coffee = require "gulp-coffee"
stylus = require "gulp-stylus"
reload = require "gulp-livereload"
plumber = require "gulp-plumber"
image = require "gulp-image"
mocha = require "gulp-mocha"
nodemon = require "nodemon"
path = require "path"

fork = require("child_process").fork

# TASK AND DEPLOYMENT CONFIGURATION

if not process.env.NODE_ENV?
  process.env.NODE_ENV = "production"

appDir = "./client/"
appSrcDir = appDir + "src/"
appPublicDir = appDir + "build/"

cfg =
  stylesheetsSrc: [appSrcDir + "css/style.styl"]
  stylesheetsDest: appPublicDir + "css/"
  pagesSrc: [appSrcDir + "pages/**/*.jade"]
  pagesDest: appPublicDir
  imagesSrc: [appSrcDir + "img/**/*.+(png|jpg|gif|ico|swf)"]
  imagesDest: appPublicDir + "img/"
  scriptsSrc: [appSrcDir + "js/**/*.coffee"]
  scriptsDest: appPublicDir + "js/"

  testSrc: ["./test/**/*.coffee"]

  vendorFontSrc: ["./bower_components/lato/font/**/*.*", "./bower_components/font-awesome-stylus/fonts/**/*.*"]
  vendorFontDest: appPublicDir + "font/"
  vendorScriptsSrc: ["./bower_components/angular/angular.min.js"]
  vendorScriptsDest: appPublicDir + "js/vendor/"

  templatesSrc: [appSrcDir + "pages/**/*.jade", appSrcDir + "partials/**/*.jade"]
  stylesSrc: [appSrcDir + "css/**/*.styl"]

  serverExec: "coffee"
  serverIndex: path.join __dirname, "server/app.coffee"
  serverWatch: [path.join __dirname, "server/"]

# BUILD TASKS

buildPages = ->
  gulp.src(cfg.pagesSrc)
    .pipe(plumber())
    .pipe(jade())
    .pipe(gulp.dest(cfg.pagesDest))
    .pipe(reload())

buildStylesheets = ->
  gulp.src(cfg.stylesheetsSrc)
    .pipe(plumber())
    .pipe(stylus())
    .pipe(gulp.dest(cfg.stylesheetsDest))
    .pipe(reload())

buildImages = ->
  gulp.src(cfg.imagesSrc)
    .pipe(plumber())
    .pipe(image())
    .pipe(gulp.dest(cfg.imagesDest))
    .pipe(reload())

buildScripts = ->
  gulp.src(cfg.scriptsSrc)
    .pipe(plumber())
    .pipe(coffee())
    .pipe(gulp.dest(cfg.scriptsDest))
    .pipe(reload())

buildVendorFonts = ->
  gulp.src(cfg.vendorFontSrc)
    .pipe(plumber())
    .pipe(gulp.dest(cfg.vendorFontDest))
    .pipe(reload())

buildVendorScripts = ->
  gulp.src(cfg.vendorScriptsSrc)
    .pipe(plumber())
    .pipe(gulp.dest(cfg.vendorScriptsDest))
    .pipe(reload())

gulp.task "build-pages", buildPages
gulp.task "build-stylesheets", buildStylesheets
gulp.task "build-images", buildImages
gulp.task "build-scripts", buildScripts

gulp.task "vendor-fonts", buildVendorFonts
gulp.task "vendor-scripts", buildVendorScripts

gulp.task "build-all", ["build-stylesheets", "build-pages", "build-images", "build-scripts", "vendor-scripts", "vendor-fonts", "test"]
gulp.task "build", ["build-all"]

# WATCH TASKS
# Note: Watch tasks should call the respective build tasks!

gulp.task "watch-templates", ->
  gulp.watch cfg.templatesSrc, ["build-pages"], (e) ->
    console.log e

gulp.task "watch-styles", ->
  gulp.watch cfg.stylesSrc, ["build-stylesheets"], (e) ->
    console.log e

gulp.task "watch-images", ->
  gulp.watch cfg.imagesSrc, ["build-images"], (e) ->
    console.log e

gulp.task "watch-tests", ["test"], ->
  gulp.watch cfg.testSrc, ["test"], (e) ->
    console.log e

gulp.task "watch-scripts", ->
  gulp.watch cfg.scriptsSrc, ["build-scripts"], (e) ->
    console.log e

gulp.task "watch-all", ["livereload", "watch-styles", "watch-templates", "watch-scripts", "watch-tests", "build"]

gulp.task "watch", ["watch-all"]

# MISC/DEVELOPMENT TASKS

gulp.task "livereload", ->
  reload.listen { quiet: true }

test = ->
  gulp.src(cfg.testSrc)
    .pipe(plumber())
    .pipe(mocha())

gulp.task "test", ->
  test()

serve = ->
  nodemonOptions =
    execMap:
      js: cfg.serverExec
    script: cfg.serverIndex
    watch: cfg.serverWatch
    ext: "noop"
  nodemon(nodemonOptions).on("restart", ->
    console.log "Relaunching server..."
  )

gulp.task "serve", ->
  serve()

gulp.task "watch-serve", ["watch"], ->
  serve()

if process.env.NODE_ENV == "production"
  gulp.task "default", ["build-all", "test"]
else
  gulp.task "default", ["watch-serve"]

