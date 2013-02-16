nodemailer = require 'nodemailer'
config = require('./config').config
extend = require 'node.extend'
fs = require 'fs'
walk = require 'walkdir'
path = require 'path'

# create reusable transport method (opens pool of SMTP connections)
smtpTransport = nodemailer.createTransport 'SMTP',
  service: 'Gmail'
  auth: config.mailAuth

fs.watch config.mailDir, (event) ->
  if event is 'rename'
    for filepath in walk.sync config.mailDir when fs.lstatSync(filepath).isFile()
      console.log "sending contents of file #{ filepath }"
      sendFileContents filepath

sendFileContents = (filepath) ->
  mailOptions =
    subject: (path.dirname(filepath).split path.sep).slice(-1)[0]
    html: fs.readFileSync filepath, 'UTF-8'

  # send mail with defined transport object
  smtpTransport.sendMail extend(mailOptions, config.mailOptions),
    (error, response) ->
      if error?
        console.log error
      else
        console.log "Message sent: #{ response.message }"
        if fs.existsSync filepath
          fs.unlink filepath

