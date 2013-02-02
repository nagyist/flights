http = require 'http'
urlParse = require('url').parse
extend = require 'node.extend'

root = 'http://192.168.1.103:5984/flights/'
jsonHeader = { 'Content-Type': 'application/json' }

httpProto = (url, options, startCb, endCb) ->
  options = extend(options, urlParse url)

  result = ''

  callback = (response) ->
    response.on 'data', (chunk) ->
      result += chunk

    response.on 'end', () ->
      endCb(JSON.parse result)

  req = http.request(options, callback)
  if startCb?
    startCb req
  req.end()

httpGet = (url, cb) -> httpProto url, method: 'GET', null, cb

httpBodyJson = (url, method, body, endCb) ->
  startCb = (request) ->
    request.write(JSON.stringify body)
  httpProto url, { method: method, headers: jsonHeader }, startCb, endCb

httpPut = (url, body, endCb) -> httpBodyJson url, 'PUT', body, endCb
httpPost = (url, body, endCb) -> httpBodyJson url, 'POST', body, endCb

allDocs = (cb) ->
  httpGet "#{ root }_all_docs?include_docs=true", (docs) ->
    cb(row.doc for row in docs.rows)

#allDocs (docs) ->
#  for doc in docs
#    doc.schema_version = 1
#    doc.type = 'timetable_item'
#
#  bulk_update =
#    docs: docs
#
#  httpPostJson "#{ root }_bulk_docs", bulk_update, (response_object) ->
#    console.log response_object

validationDocUrl = "#{ root }_design/validation"

validateDocUpdate = (newDoc, oldDoc, userCtx, secObj) ->
  if not newDoc._deleted? && not newDoc.schema_version?
    throw {forbidden: 'Document must have a schema version.'}

httpGet validationDocUrl, (doc) ->
  validationDocument =
    _id: '_design/validation'
    #  lib:
    #    jsv: stringifyModule 'JSV'
    validate_doc_update: validateDocUpdate + ''

  if doc._rev?
    validationDocument._rev = doc._rev
  httpPut validationDocUrl, validationDocument, (response) ->
    console.log response