gulp    = require 'gulp'
coffee  = require 'gulp-coffee'
stylus  = require 'gulp-stylus'
hamlc   = require 'gulp-haml-coffee'
reload  = require 'gulp-livereload'

fork    = require('child_process').fork

clientBuildDir = './client/build/'
cfg =
  templateSrc: './client/src/templates/**/*.hamlc'
  templateDest: clientBuildDir
  styleSrc: './client/src/stylus/**/*.styl'
  styleDest: clientBuildDir + "css/"
  scriptSrc: './client/src/coffeescripts/**/*.coffee'
  scriptDest: clientBuildDir + "js/"
  # imgSrc: './public/img/**/*.*'
  # imgDest: clientBuildDir + 'img/'
  fontSrc: [
    'bower_components/font-awesome-stylus/fonts/*'
    'bower_components/lato/font/**/*'
  ]
  fontDest: clientBuildDir + 'fonts/'
  testSrc: './test/**/*.coffee'

gulp.task 'build-templates', ->
  gulp.src cfg.templateSrc
    .pipe hamlc()
    .pipe gulp.dest cfg.templateDest
    .pipe reload()

gulp.task 'watch-templates', ->
  gulp.watch cfg.templateSrc, ['build-templates']

gulp.task 'build-styles', ->
  gulp.src cfg.styleSrc
    .pipe stylus()
    .pipe gulp.dest cfg.styleDest
    .pipe reload()

gulp.task 'watch-styles', ->
  gulp.watch cfg.styleSrc, ['build-styles']

gulp.task 'build-scripts', ->
  gulp.src cfg.scriptSrc
    .pipe coffee()
    .pipe gulp.dest cfg.scriptDest
    .pipe reload()

gulp.task 'watch-scripts', ->
  gulp.watch cfg.scriptSrc, ['build-scripts']

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

gulp.task 'watch', ['livereload', 'build', 'watch-templates', 'watch-styles', 'watch-scripts', 'watch-fonts'] # , 'watch-images']

gulp.task 'test', ->
  console.log "TODO: Write tests"

gulp.task 'default', ['build', 'test']

gulp.task 'serve', (cb) ->
  fork 'server/app.coffee', ''

gulp.task 'watch-serve', ['watch', 'serve']

