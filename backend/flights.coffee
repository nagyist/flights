phantom.injectJs './parseuri.js'

casper = require('casper').create
  onError: (self, m) ->        # Any "error" level message will be written
    console.log('FATAL:' + m)  # on the console output and PhantomJS will
    self.exit()                # terminate

fs = require 'fs'
utils = require 'utils'

locale = 'en-GB'

route = {}

serveRedirect = (url, response) ->
  casper.echo "serving redirect to url #{ url }"
  response.statusCode = 301
  response.headers = Location: url
  response.write('')
  response.close()

serveFile = (filePath, response, mode = 'r') ->
  casper.echo "serving file with name \"#{ filePath }\"", 'INFO'
  if not fs.isReadable filePath
    casper.echo "file \"#{ filePath }\" not readable for static serving", 'WARNING'
    response.statusCode = 404
    response.write "can't open #{ filePath }"
    response.close()
  else
    response.statusCode = 200
    fileStream = fs.open filePath, mode
    if mode.indexOf('b') isnt -1
      casper.echo "serving file as binary"
      response.setEncoding 'binary'
    response.write fileStream.read()
    response.close()

route.timetable = (_, query, response) ->
  casper.start "http://wizzair.com/#{ locale }/TimeTable", ->
    sourceInput = '#WizzTimeTableControl_AutocompleteTxtDeparture'
    @sendKeys sourceInput, query.src
    @sendKeys sourceInput, 16777221
    destinationInput = '#WizzTimeTableControl_AutocompleteTxtArrival'
    @sendKeys destinationInput, query.dst, removeFocus: false
    @sendKeys destinationInput, 16777217,
        bringFocus: false
        removeFocus: true
    @click '#WizzTimeTableControl_ButtonSubmit'
    @echo "requesting a timetable from #{ query.src } to #{ query.dst }", 'INFO'
    @waitForSelector '#timetableSlider', ->
      hey = @evaluate ((source, destination) ->
        result = []
        $('span.flights_daylist').filter(-> $('span.item', this).length > 0)
          .each ->
            item = $('span.item', this)
            result.push
              timestamp: (new Date()).valueOf()
              date: $('strong', this).attr 'data-datetime'
              flight: item.attr 'data-flightnumber'
              time: item.attr 'data-time'
              price: $('span.price', this).text()
              source: source
              destination: destination
#                schema_version: 1
#                type: 'timetable_item'
        result), query.src, query.dst
      if hey.length > 0
        postBody = JSON.stringify hey[0]
        @thenOpen 'http://127.0.0.1:5984/flights/', (
          method: 'post'
          data: postBody
          encoding: 'utf8'
          headers:
            'Content-Type': 'application/json'), -> @echo @getPageContent()
      @echo "got a timetable with result #{ JSON.stringify hey[0] }, making a screenshot", 'INFO'
      @capture 'blah.png'
      serveFile 'blah.png', response, 'rb'

  casper.run ->
    @echo "casper workflow finished", 'INFO'

route.home = (pathLeft, _, response) ->
  if pathLeft.length > 0
    serveFile pathLeft.join('/'), response
  else
    serveRedirect 'home/static/index.html', response

route['favicon.ico'] = (_, __, response) ->
  serveFile 'static/favicon.ico', response

server = require('webserver').create()
service = server.listen '0.0.0.0:8080', (request, response) ->
  url = request.url
  [method, pathLeft...] = parseUri(url).path.substring(1).split '/'
  casper.echo "got a request for method #{ method }", 'INFO'
  query = getQueryDict url
  if route[method]?
    route[method] pathLeft, query, response
  else
    casper.echo "404 for url #{ url }", 'WARNING'
    response.statusCode = 404
    response.write '404'
    response.close()

