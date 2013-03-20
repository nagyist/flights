wd = require 'wd'
browser = wd.remote '127.0.0.1', 8080
config = require '../config'
fs = require 'fs'
db = require 'benchdb'
async = require 'async'
_ = require 'underscore'
random_ua = require 'random-ua'

srcInputId = 'WizzTimeTableControl_AutocompleteTxtDeparture'
srcInput = null
dstInputId = 'WizzTimeTableControl_AutocompleteTxtArrival'

browser.on 'status', (info) ->
  console.log '\x1b[36m%s\x1b[0m', info

browser.on 'command', (meth, path, data) ->
  console.log ' > \x1b[33m%s\x1b[0m: %s', meth, path, data || ''

next = _(browser.next).bind(browser)
step = {}
buildPlaceholder = (name) ->
  -> _.partial.apply _, [next, name].concat(_.toArray arguments)
_.each _.functions(browser), (k) -> step[k] = buildPlaceholder k

browser.chain()
  .init({ "phantomjs.page.settings.userAgent": random_ua.generate() })
  .get("http://wizzair.com/#{ config.locale }/TimeTable")
  .elementById(srcInputId, (err, el) ->
    srcInput = el)
  .elementById(dstInputId, (err, dstInput) ->
    previousSource = null
    currentSource = null
    previousDestination = null
    currentDestination = null
    i = 1
    fn = (cb) ->
      fnSteps = [
        step.clickElement(srcInput),
        step.keys(wd.SPECIAL_KEYS['Back space']),
        step.keys(wd.SPECIAL_KEYS['Down arrow']),
        step.keys(wd.SPECIAL_KEYS.Tab),
        step.clickElement(dstInput),
        step.keys(wd.SPECIAL_KEYS['Back space'])]
      _(i).times -> fnSteps.push step.keys wd.SPECIAL_KEYS['Down arrow']
      fnSteps.push step.keys(wd.SPECIAL_KEYS.Tab),
        step.getValue(srcInput),
        step.getValue(dstInput)
      async.series fnSteps, (err, results) ->
        [src, dst] = _(results).last(2)
        currentSource = src
        previousDestination = currentDestination
        currentDestination = dst
        ++i
        cb err
    test = ->
      if previousDestination isnt currentDestination
        console.log "got source #{currentSource}, destination #{currentDestination}"
      else
        true
    async.doUntil fn, test, ->)
  .takeScreenshot((err, screenshot) ->
      fs.writeFile 'blah.png', new Buffer(screenshot, 'base64'), encoding: 'binary')
  .quit()
