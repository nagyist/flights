http = require 'http'
urlParse = require('url').parse
extend = require 'node.extend'
path = require 'path'
fs = require 'fs'
walk = require 'walkdir'
_ = require 'underscore'

root = 'http://127.0.0.1:5984/flights/'
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

validationDocUrl = "#{ root }_design/validation"

readPackageJson = (moduleDir, packageName) ->
  filePath = path.join moduleDir, packageName, 'package.json'
  if fs.existsSync filePath
    JSON.parse(fs.readFileSync filePath)

stringifyModule = (moduleName, packageName) ->
  for dir in process.env.NODE_PATH.split ':'
    packageInfo = readPackageJson dir, packageName
    libPath = path.join dir, packageName, packageInfo.directories.lib
    if packageInfo? and fs.existsSync libPath
        filePath = path.join libPath, "#{ moduleName }.js"
        return fs.readFileSync filePath, 'UTF-8'

stringifyPackage = (packageName) ->
  result = {}

  for dir in process.env.NODE_PATH.split ':'
    packageInfo = readPackageJson dir
    mainPath = path.join dir, packageName, packageInfo.main
    if packageInfo? and fs.existsSync mainPath
      mainDir = path.dirname mainPath
      for file in walk.sync mainDir when path.extname(file) is '.js'
        relativeFilePath = path.relative mainDir, file
        modulePath =
          path.join(path.dirname(relativeFilePath),
                    path.basename(relativeFilePath, '.js')).split(path.sep)
        reduceFun = (res, el) ->
          result = {}
          result[el] = res
          result

        fileContents = fs.readFileSync file, 'UTF-8'

        result =
          extend result,
                _.reduce(modulePath.reverse(), reduceFun, fileContents)

  result

validateDocUpdate = (newDoc, oldDoc, userCtx, secObj) ->
  if not newDoc._deleted?
    validate = require('lib/json-schema').validate
    schema = require('lib/schema1').schema

    result = validate newDoc, schema

    if not result.valid
      throw { forbidden: JSON.stringify(result.errors) }

httpGet validationDocUrl, (doc) ->
  validationDocument =
    _id: '_design/validation'
    lib:
      'json-schema': stringifyModule 'json-schema', 'commonjs-utils'
      schema1: fs.readFileSync 'schema1.js', 'UTF-8'
    validate_doc_update: validateDocUpdate + ''

  if doc._rev?
    validationDocument._rev = doc._rev
  httpPut validationDocUrl, validationDocument, (response) ->
    console.log response

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