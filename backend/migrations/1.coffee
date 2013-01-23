http = require 'http'
urlParse = require('url').parse

httpMethod = (url, method, startCb, endCb) ->
  options = urlParse url
  options.method = method

  result = ''

  callback = (response) ->
    response.on 'data', (chunk) ->
      result += chunk

    response.on 'end', () ->
      endCb(JSON.parse result)

  req = http.request(options, callback)
  if (startCb)
    startCb(req)
  req.end()

httpGet = (url, cb) -> httpMethod url, 'GET', null, cb

httpBody = (url, method, endCb, body) ->
  startCb = (request) ->
    request.write(JSON.stringify body)
  httpMethod url, method, startCb, endCb

httpPut = (url, endCb, body) -> httpBody url, 'PUT', endCb, body
httpPost = (url, endCb, body) -> httpBody url, 'POST', endCb, body

allDocsUrl = 'http://192.168.1.103:5984/flights/_all_docs?include_docs=true'

httpGet allDocsUrl, (result) ->
  for row in result.rows
    console.log row.doc.price