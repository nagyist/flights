nodemailer = require 'nodemailer'

# create reusable transport method (opens pool of SMTP connections)
smtpTransport = nodemailer.createTransport "SMTP",
  service: "Gmail"
  auth:
    user: "unruhig@gmail.com"
    pass: "n3cr0d3@thm0rt"

# setup e-mail data with unicode symbols
mailOptions =
  from: 'flights mailer <unruhig@gmail.com>'
  to: "max.desyatov@gmail.com" # list of receivers
  subject: "Hello ✔" # Subject line
  text: "Hello world ✔" # plaintext body
  html: "<b>Hello world ✔</b>" # html body

# send mail with defined transport object
smtpTransport.sendMail mailOptions, (error, response) ->
  if error
    console.log(error)
  else
    console.log("Message sent: " + response.message)

  smtpTransport.close() # shut down the connection pool, no more messages
