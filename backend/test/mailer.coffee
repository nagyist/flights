config = require('../config').config
mailer = require '../mailer'
extend = require 'node.extend'
colors = require '../log_colors'.colors
inbox = require 'inbox'

client = inbox.createConnection false, 'imap.gmail.com',
  secureConnection: true,
  auth: config.recipientMailAuth

exports.testSomething = (test) ->
  test.expect(1);

  client.connect()

  client.on 'connect', ->
    client.openMailbox 'INBOX', (error, info) ->
      if error?
        console.log error.error

      client.listMessages -1, (err, messages) ->
        messages.forEach (message) ->
          console.log "#{ message.UID }: #{message.title}".info
          test.ok(message.UID is 7703, 'this assertion should pass');
          client.close()
          test.done();

