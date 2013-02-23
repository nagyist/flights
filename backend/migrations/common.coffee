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
    libPath = path.join dir, packageName
    if packageInfo.directories?
      libPath = path.join libPath, packageInfo.directories.lib
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

exports.httpGet = httpGet
exports.httpPut = httpPut
exports.httpPost = httpPost
exports.allDocs = allDocs
exports.validationDocUrl = validationDocUrl
exports.stringifyModule = stringifyModule
exports.rootUrl = root
