require('coffee-script')

express = require 'express'
partials = require 'express-partials'
path = require 'path'
# favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
expressWs = require 'express-ws'
coffeeScript = require 'connect-coffee-script'

routes = require './routes/index'
users = require './routes/users'

app = express()
expressWs(app)

app.set('views', path.join(__dirname, 'views'))
app.use(partials())

app.engine('hamlc', require('haml-coffee').__express)
app.set('view engine', 'hamlc')

app.use(logger('dev'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(coffeeScript(path.join(__dirname, 'public')))
app.use(require('stylus').middleware(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'public')))

app.use('/', routes)
app.use('/users', users)

app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next(err)

if app.get('env') == 'development'
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    res.render('error', {
      title: "Error",
      message: err.message,
      error: err
    })
else
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    res.render('error', {
      title: "Error",
      message: err.message,
      error: err
    })

module.exports = app

