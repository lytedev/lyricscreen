gulp     = require 'gulp'
hamlc    = require 'gulp-haml-coffee'
stylus   = require 'gulp-stylus'
coffee   = require 'gulp-coffee'
electron = require 'gulp-electron'
shell    = require 'gulp-shell'

mocha = require 'gulp-mocha'

clientBuildDir = './src/client/build/'
cfg =
  templateSrc: './src/client/**/*.hamlc'
  templateDest: clientBuildDir
  styleSrc: './src/client/**/*.styl'
  styleDest: clientBuildDir
  scriptSrc: './src/client/**/*.coffee'
  scriptDest: clientBuildDir
  fontSrc: [
    'bower_components/font-awesome-stylus/fonts/*'
    'bower_components/lato/font/**/*'
  ]
  fontDest: clientBuildDir + 'fonts/'
  testSrc: './tests/**/*.coffee'

gulp.task 'build-client-templates', ->
  gulp.src(cfg.templateSrc)
    .pipe hamlc()
    .pipe gulp.dest cfg.templateDest

gulp.task 'build-client-styles', ->
  gulp.src(cfg.styleSrc)
    .pipe stylus()
    .pipe gulp.dest cfg.styleDest

gulp.task 'build-client-scripts', ->
  gulp.src(cfg.scriptSrc)
    .pipe coffee()
    .pipe gulp.dest cfg.scriptDest

gulp.task 'build-client-fonts', ->
  gulp.src(cfg.fontSrc)
    .pipe gulp.dest cfg.fontDest

gulp.task 'build-client', ['build-client-scripts', 'build-client-styles', 'build-client-templates', 'build-client-fonts']

gulp.task 'test', ['build-client'], ->
  gulp.src(cfg.testSrc)
    .pipe mocha()

gulp.task 'run', ['build-client'], shell.task ['electron ' + __dirname]

gulp.task 'default', ['build-client', 'run']
