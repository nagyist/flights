wd = require 'wd'
browser = wd.remote '127.0.0.1', 8080
config = require '../config'
fs = require 'fs'
benchdb = require 'benchdb'
db = new benchdb 'http://127.0.0.1:5984/flights'
async = require 'async'
_ = require 'underscore'
random_ua = require 'random-ua'

srcInput = '#WizzTimeTableControl_AutocompleteTxtDeparture'
dstInput = '#WizzTimeTableControl_AutocompleteTxtArrival'
submitButton = '#WizzTimeTableControl_ButtonSubmit'

browser.on 'status', (info) ->
  console.log '\x1b[36m%s\x1b[0m', info

browser.on 'command', (meth, path, data) ->
  console.log ' > \x1b[33m%s\x1b[0m: %s', meth, path, data || ''

next = _(browser.next).bind(browser)
step = {}
buildPlaceholder = (name) ->
  -> _.partial.apply _, [next, name].concat(_.toArray arguments)
_.each _.functions(browser), (k) -> step[k] = buildPlaceholder k
step.getAttribute$ = (selector, attributeName) ->
  _(async.waterfall).partial [step.elementByCssSelector(selector),
    ((el, cb) -> next 'getAttribute', el, attributeName, cb)]
step.clickElement$ = (selector) ->
  _(async.waterfall).partial [step.elementByCssSelector(selector),
    _(next).partial 'clickElement']

dbCb = (err) ->
  if err
    console.log "error happened in BenchDb: #{ err }"

browser.chain()
  .init({ "phantomjs.page.settings.userAgent": random_ua.generate() })
  .get("http://wizzair.com/#{ config.locale }/TimeTable", (err) ->
    previousSource = false
    currentSource = null
    previousDestination = false
    currentDestination = null
    number = null
    i = 0
    sourceFn = (sourceCb) ->
      if currentSource? and currentSource
        [wholeString, name, code] = /(.+) \((.+)\)$/.exec currentSource
        if code.length > 0
          doc =
            type: 'airport'
            schema_version: 3
            code: code
            names: {}
          doc.names[config.locale] = name
          # FIXME: check for existing airport
          db.create doc, dbCb
      previousSource = currentSource
      ++i
      j = 1
      destinationFn = (cb) ->
        fnSteps = [step.clickElement$(srcInput),
          step.keys(wd.SPECIAL_KEYS['Back space'])]
        _(i).times -> fnSteps.push step.keys wd.SPECIAL_KEYS['Down arrow']
        fnSteps.push step.keys(wd.SPECIAL_KEYS.Tab),
          step.clickElement$(dstInput),
          step.keys(wd.SPECIAL_KEYS['Back space'])
        _(j).times -> fnSteps.push step.keys wd.SPECIAL_KEYS['Down arrow']
        fnSteps.push step.keys(wd.SPECIAL_KEYS.Tab),
          step.clickElement$(submitButton),
          step.waitForElementById('timetableSlider', 1),
          step.getAttribute$('span.item', 'data-flightnumber'),
          step.getAttribute$(srcInput, 'value'),
          step.getAttribute$(dstInput, 'value')
        async.series fnSteps, (err, results) ->
          if err instanceof Error and err.message isnt "Element didn't appear"
            console.log "got error #{err}, restarting step"
            next 'takeScreenshot', (err, screenshot) ->
              fs.writeFile 'blah.png', new Buffer(screenshot, 'base64'), encoding: 'binary', -> cb err
            return
          else
            if err instanceof Error and err.message is "Element didn't appear"
              err = null
            [number, currentSource, dst] = _(results).last(3)
            previousDestination = currentDestination
            currentDestination = dst
            ++j
            cb err
      destinationTest = ->
        if (previousSource isnt currentSource) and
            (previousDestination isnt currentDestination)
          console.log "got source #{currentSource}, destination #{currentDestination} with number #{number}"
        else
          true
      async.doUntil destinationFn, destinationTest, (err) -> sourceCb err
    sourceTest = -> previousSource is currentSource
    async.doUntil sourceFn, sourceTest, -> next 'quit')
