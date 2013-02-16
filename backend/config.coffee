exports.config =
  mailDir: 'mailqueue' #directory where files with e-mail contents will be stored
  mailAuth:
    user: 'e-mail' #sender's e-mail
    pass: 'password' #password for this e-mail
  mailOptions:
    from: 'from field' #what will be written in from field
    to: 'receiver' # list of receivers