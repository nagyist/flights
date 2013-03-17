nodemailer = require 'nodemailer'
config = require './config'
extend = require 'node.extend'
fs = require 'fs'
walk = require 'walkdir'
path = require 'path'
_ = require 'underscore'
colors = require('./log_colors').colors

# create reusable transport method (opens pool of SMTP connections)
smtpTransport = nodemailer.createTransport 'SMTP',
  service: 'Gmail'
  auth: config.senderMailAuth

fileOk = (filepath, cb) ->
  if not filepath in filesInWork
    fs.lstat filepath, (error, stats) ->
      if error?
        console.log error.error
      else if stats.isFile() and not stats.isSymbolicLink()
        cb()

dirOk = (filepath, cb) ->
  if not dirpath of watchedDirectories
    fs.lstat filepath, (error, stats) ->
      if error?
        console.log error.error
      else if stats.isDirectory() and not stats.isSymbolicLink()
        cb()

watchedDirectories = {}
filesInWork = []

checkTree = (dirpath) ->
  for filepath in walk.sync dirpath
    fileOk filepath, ->
      console.log "sending contents of file #{ filepath }".info
      filesInWork.push filepath
      sendFileContents filepath
    dirOk filepath, ->
      watch filepath

watch = (dirpath) ->
  watchedDirectories[dirpath] = fs.watch dirpath, (event) ->
    if event is 'rename'
      checkTree dirpath

main = ->
  checkTree config.mailDir
  watch config.mailDir

parentDirname = (filepath) ->
  _.last path.dirname(filepath).split(path.sep)

removeFileOrDir = (filepath) ->
  fs.existsSync filepath, (exists) ->
    if exists
      fs.unlink filepath, (error) ->
        if error?
          console.log error.error
        else
          console.log "just removed file #{ filepath }".info

sendFileContents = (filepath) ->
  mailOptions =
    subject: parentDirname filepath
    html: fs.readFileSync filepath, 'UTF-8'

  smtpTransport.sendMail extend(mailOptions, config.mailOptions),
    (error, response) ->
      if error?
        console.log error.error
      else
        console.log "Message sent: #{ response.message }".info
        removeFileOrDir filepath

if require.main is module
  main()

exports.main = main
