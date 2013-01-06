phantom.injectJs './parseuri.js'

casper = require('casper').create exitOnError: true
fs = require('fs');

locale = 'en-GB'

route = {}

serveFile = (fileName, mode = 'r') ->
  (_, response) ->
    casper.echo "serving file with name #{ fileName }", 'INFO'
    response.statusCode = 200
    fileStream = fs.open fileName, mode
    if mode.indexOf('b') isnt -1
      casper.echo "serving file as binary"
      response.setEncoding 'binary'
    response.write fileStream.read()
    response.close()

route.timetable = (query, response) ->
  casper.start "http://wizzair.com/#{ locale }/TimeTable", ->
    sourceInput = '#WizzTimeTableControl_AutocompleteTxtDeparture'
    @sendKeys sourceInput, query.src
    @sendKeys sourceInput, 16777221
    destinationInput = '#WizzTimeTableControl_AutocompleteTxtArrival'
    @sendKeys destinationInput, query.dst
    @sendKeys destinationInput, 16777221
    @click '#WizzTimeTableControl_ButtonSubmit'
    @echo "requesting a timetable from #{ query.src } to #{ query.dst }", 'INFO'
    @waitForSelector '#timetableSlider', ->
      @echo "got a timetable, making a screenshot", 'INFO'
      @capture 'blah.png'
      serveFile('blah.png', 'rb')({}, response)

  casper.run ->
    @echo "casper workflow finished", 'INFO'

route.home = serveFile 'home.html'

server = require('webserver').create()
service = server.listen '0.0.0.0:8080', (request, response) ->
  method = parseUri(request.url).path.substring(1)
  casper.echo "got a request for method #{ method }", 'INFO'
  query = getQueryDict request.url
  route[method] query, response

