gulp    = require 'gulp'
coffee  = require 'gulp-coffee'
stylus  = require 'gulp-stylus'
hamlc   = require 'gulp-haml-coffee'
reload  = require 'gulp-livereload'
mocha   = require 'gulp-mocha'
fs      = require 'fs'

fork    = require('child_process').fork

packageDetails = JSON.parse fs.readFileSync 'package.json', 'utf8'
templateContext = {
  title: packageDetails.name
  version: packageDetails.version
}

console.log "Task Runner for", packageDetails.name, "version", packageDetails.version

clientBuildDir = './client/build/'
cfg =
  templateSrc: [
    './client/src/templates/display.hamlc'
    './client/src/templates/index.hamlc'
  ]
  templateWatch: [
    './client/src/templates/**/*.hamlc'
  ]
  templateDest: clientBuildDir
  styleSrc: [
    './client/src/stylus/style.styl'
  ]
  styleWatch: [
    './client/src/stylus/**/*.styl'
  ]
  styleDest: clientBuildDir + "css/"
  vendorScriptSrc: [
    './bower_components/angular-websocket/angular-websocket.min.js'
    './bower_components/angular/angular.min.js'
  ]
  vendorScriptDest: clientBuildDir + "js/"
  scriptSrc: [
    './client/src/coffeescripts/client.coffee'
  ]
  scriptWatch: [
    './client/src/coffeescripts/**/*.coffee'
  ]
  scriptDest: clientBuildDir + "js/"
  # imgSrc: './public/img/**/*.*'
  # imgDest: clientBuildDir + 'img/'
  fontSrc: [
    'bower_components/font-awesome-stylus/fonts/*'
    'bower_components/lato/font/**/*'
  ]
  fontDest: clientBuildDir + 'fonts/'
  testSrc: [
    './test/**/*.coffee'
  ]
  serverSrc: './server/**/*.coffee'

gulp.task 'build-templates', ->
  gulp.src cfg.templateSrc
    .pipe hamlc locals: templateContext
    .pipe gulp.dest cfg.templateDest
    .pipe reload()

gulp.task 'watch-templates', ->
  gulp.watch cfg.templateWatch, ['build-templates']

gulp.task 'build-styles', ->
  gulp.src cfg.styleSrc
    .pipe stylus()
    .pipe gulp.dest cfg.styleDest
    .pipe reload()

gulp.task 'watch-styles', ->
  gulp.watch cfg.styleWatch, ['build-styles']

gulp.task 'build-scripts', ->
  gulp.src cfg.vendorScriptSrc
    .pipe gulp.dest cfg.vendorScriptDest

  gulp.src cfg.scriptSrc
    .pipe coffee()
    .pipe gulp.dest cfg.scriptDest
    .pipe reload()

gulp.task 'watch-tests', ->
  gulp.watch [cfg.testSrc, cfg.serverSrc], ['test']

gulp.task 'watch-scripts', ->
  gulp.watch cfg.scriptWatch, ['build-scripts']

# gulp.task 'build-images', ->
#   gulp.src cfg.imgSrc
#     .pipe gulp.dest cfg.imgDest
#     .pipe reload()

# gulp.task 'watch-images', ->
#   gulp.watch cfg.imgSrc, ['build-images']

gulp.task 'build-fonts', ->
  gulp.src(cfg.fontSrc)
    .pipe gulp.dest cfg.fontDest
    .pipe reload()

gulp.task 'watch-fonts', ->
  gulp.watch cfg.fontSrc, ['build-fonts']

gulp.task 'livereload', ->
  reload.listen()

gulp.task 'build', ['build-templates', 'build-styles', 'build-scripts', 'build-fonts'] # , 'build-images']

gulp.task 'watch', ['livereload', 'build', 'watch-templates', 'watch-styles', 'watch-scripts', 'watch-fonts', 'watch-tests'], -> # , 'watch-images']
  test()

test = ->
  gulp.src cfg.testSrc
    .pipe mocha()

gulp.task 'test', ->
  test()

gulp.task 'default', ['build', 'test']

serve = ->
  fork 'server/app.coffee', ''

gulp.task 'serve', (cb) ->
  serve()

gulp.task 'watch-serve', ['watch'], (cb) ->
  serve()

