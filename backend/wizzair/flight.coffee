wd = require 'wd'
browser = wd.remote '127.0.0.1', 8080
config = require './config'
fs = require 'fs'

browser.on 'status', (info) ->
  console.log('\x1b[36m%s\x1b[0m', info);

browser.on 'command', (meth, path, data) ->
  console.log(' > \x1b[33m%s\x1b[0m: %s', meth, path, data || '');

browser.chain()
  .init()
  .get("http://wizzair.com/#{ config.locale }/TimeTable")
  .elementById('WizzTimeTableControl_AutocompleteTxtDeparture', (err, el) ->
    browser.next 'clickElement', el, -> console.log "did the click!")
  .keys('KTW')
  .keys(wd.SPECIAL_KEYS.Tab)
  .keys('BCN')
  .keys(wd.SPECIAL_KEYS.Tab)
  .elementById('WizzTimeTableControl_ButtonSubmit', (err, el) ->
    browser.next 'clickElement', el, -> console.log "did the click!")
  .waitForElementById('timetableSlider', 1, ->
    browser.next 'takeScreenshot', (err, screenshot) ->
      fs.writeFile 'blah.png', new Buffer(screenshot, 'base64'), encoding: 'binary')
  .quit()
