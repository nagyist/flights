wd = require 'wd'
browser = wd.remote '127.0.0.1', 8080
config = require '../config'
fs = require 'fs'
db = require 'benchdb'
async = require 'async'
_ = require 'underscore'

srcInputId = 'WizzTimeTableControl_AutocompleteTxtDeparture'
srcInput = null
dstInputId = 'WizzTimeTableControl_AutocompleteTxtArrival'

browser.on 'status', (info) ->
  console.log '\x1b[36m%s\x1b[0m', info

browser.on 'command', (meth, path, data) ->
  console.log ' > \x1b[33m%s\x1b[0m: %s', meth, path, data || ''

browser.chain()
  .init()
  .get("http://wizzair.com/#{ config.locale }/TimeTable")
  .elementById(srcInputId, (err, el) ->
    srcInput = el)
  .elementById(dstInputId, (err, dstInput) ->
    currentSource = null
    previousDestination = null
    currentDestination = null
    i = 1
    next = _(browser.next).bind(browser)
    fn = (cb) ->
      fnSteps = [
        _(next).partial('clickElement', srcInput),
        _(next).partial('keys', wd.SPECIAL_KEYS['Back space']),
        _(next).partial('keys', wd.SPECIAL_KEYS['Down arrow']),
        _(next).partial('keys', wd.SPECIAL_KEYS.Tab)
        _(next).partial('clickElement', dstInput),
        _(next).partial('keys', wd.SPECIAL_KEYS['Back space'])]
      _(i).times -> fnSteps.push _(next).partial 'keys', wd.SPECIAL_KEYS['Down arrow']
      fnSteps.push _(next).partial('keys', wd.SPECIAL_KEYS.Tab),
        _(next).partial('getValue', srcInput),
        _(next).partial('getValue', dstInput)
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
